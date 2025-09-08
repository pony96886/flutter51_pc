import 'package:chaguaner2023/components/page_status.dart';
import 'package:chaguaner2023/components/pullrefreshlist.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/http.dart';
import 'package:chaguaner2023/utils/index.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import '../../utils/network_http.dart';

typedef BuildWidgetData = Function(
    BuildContext context, int index, dynamic data, int page, int limit, Function getListData);

class PublicList extends StatefulWidget {
  final bool isShow; //是否展示
  final BuildWidgetData? itemBuild;
  final String? api; //接口地址
  final Map? data; //传递参数
  final int? limit;
  final bool? isFlow; //是否瀑布流
  final int? row;
  final bool? noRefresh;
  final bool? isSliver;
  final Widget? sliverHead;
  final double? bottomPadding;
  final double? aspectRatio;
  final String? nullText; //无数据提示
  final ScrollController? controller;
  final bool? noController;
  final double? mainAxisSpacing;
  final double? crossAxisSpacing;
  final Widget? noData;
  final double? cacheExtent;
  final Function(Map)? then; //请求完成
  final EdgeInsetsGeometry? padding;
  final bool? noPull;
  final String? emitName;

  PublicList(
      {Key? key,
      this.isShow = true,
      required this.api,
      this.data,
      this.limit = 20,
      this.isFlow = false,
      this.noRefresh = false,
      this.bottomPadding = 0,
      required this.itemBuild,
      this.aspectRatio = 1.5,
      this.row = 1,
      this.nullText,
      this.controller,
      this.isSliver = false,
      this.sliverHead,
      this.noController = false,
      this.mainAxisSpacing = 7,
      this.crossAxisSpacing = 7,
      this.noData,
      this.cacheExtent,
      this.then,
      this.padding,
      this.noPull = false,
      this.emitName})
      : super(key: key);

  @override
  _PublicListState createState() => _PublicListState();
}

class _PublicListState extends State<PublicList> {
  ScrollController _controller = ScrollController();
  bool isload = false;
  bool isAll = false;
  bool loading = true;
  bool networkErr = false;
  bool initPage = false;
  Map reqData = {'page': 1, 'limit': 20};
  List? searchData;

  Future getSearchResult() async {
    if (networkErr) {
      reqData = {'page': 1, 'limit': 20};
      if (widget.data is Map) {
        reqData.addAll(widget.data!);
      }
      networkErr = false;
      isAll = false;
      loading = true;
      setState(() {});
    }
    try {
      Response<dynamic> res = await NetworkHttp.instance.post(widget.api!, data: reqData);

      List resdata = [];
      isload = false;
      CommonUtils.debugPrint("${widget.api}:请求的返回${res.data}");
      widget.then?.call(res.data['data']);

      if (res.data['status'] != 0) {
        if (res.data['data'] != null && res.data['data'] is List) {
          resdata = res.data['data'] ?? [];
        } else {
          resdata = (res.data['data']?['list'] ?? res.data['data']?['categories']) ?? [];
        }

        isAll = resdata.length < reqData['limit'];

        if (reqData['page'] == 1) {
          searchData = resdata;
        } else {
          searchData!.addAll(resdata);
        }

        loading = false;
        setState(() {});
      } else {
        if (res.data['msg'] == "token无效") {
          AppGlobal.apiToken.value = '';
          Box box = AppGlobal.appBox!;
          box.delete('apiToken');
          getHomeConfig(AppGlobal.appContext!).then((value) {
            AppGlobal.appContext!.go('/home/loginPage/2');
          });
        }
        CommonUtils.showText(res.data['msg']);
      }
      CommonUtils.debugPrint(searchData);
    } catch (e) {
      networkErr = true;
      setState(() {});
      CommonUtils.debugPrint('错误:$e');
    }
  }

  void refreshList(e) {
    loading = true;
    reqData['page'] = 1;
    isAll = false;
    setState(() {});
    getSearchResult();
  }

  @override
  void initState() {
    super.initState();
    if (widget.data is Map) {
      reqData.addAll(widget.data!);
    }
    EventBus().on(widget.emitName, refreshList);
    reqData['limit'] = widget.limit;

    if (widget.isShow && !initPage) {
      initPage = true;
      getSearchResult();
    }
  }

  @override
  void dispose() {
    super.dispose();
    EventBus().off(widget.emitName, refreshList);
  }

  @override
  void didUpdateWidget(PublicList oldWidget) {
    super.didUpdateWidget(oldWidget);
    bool isSame = true;

    if (widget.api != oldWidget.api) {
      isSame = false;
    }

    widget.data?.forEach((key, value) {
      if (widget.data?[key] != oldWidget.data?[key]) {
        isSame = false;
      }
    });

    if (!isSame && initPage) {
      loading = true;
      reqData['page'] = 1;
      isAll = false;
      initPage = false;
      setState(() {});

      reqData.addAll(widget.data ?? {'page': 1, 'limit': widget.limit});
      if (widget.isShow) {
        initPage = true;
        getSearchResult();
      }
    }

    if (widget.isShow && !initPage) {
      initPage = true;
      getSearchResult();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isSliver!) {
      return networkErr
          ? PageStatus.noNetWork(onTap: () {
              loading = true;
              reqData['page'] = 1;
              isAll = false;
              setState(() {});
              getSearchResult();
            })
          : PullRefreshList(
              isAll: isAll,
              onLoading: () {
                if (isAll || isload) {
                  return;
                }
                isload = true;
                reqData['page']++;
                getSearchResult();
              },
              onRefresh: widget.noRefresh!
                  ? null
                  : () {
                      loading = true;
                      reqData['page'] = 1;
                      isAll = false;
                      setState(() {});
                      getSearchResult();
                    },
              child: CustomScrollView(cacheExtent: widget.cacheExtent ?? 3.sh, slivers: [
                widget.sliverHead == null
                    ? SliverToBoxAdapter()
                    : SliverToBoxAdapter(
                        child: widget.sliverHead,
                      ),
                loading
                    ? SliverToBoxAdapter(
                        child: PageStatus.loading(true),
                      )
                    : (searchData!.isEmpty
                        ? SliverToBoxAdapter(
                            child: PageStatus.noData(text: widget.nullText),
                          )
                        : (widget.row == 1
                            ? SliverPadding(
                                padding: widget.padding ?? EdgeInsets.zero,
                                sliver: SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                  (BuildContext context, int index) {
                                    return widget.itemBuild!(
                                        context, index, searchData![index], reqData['page'], reqData['limit'], () {
                                      return searchData;
                                    });
                                  },
                                  childCount: searchData!.length,
                                )),
                              )
                            : SliverGrid(
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: widget.row!,
                                  mainAxisSpacing: widget.mainAxisSpacing!,
                                  crossAxisSpacing: widget.crossAxisSpacing!,
                                  childAspectRatio: widget.aspectRatio!,
                                ),
                                delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
                                  return widget.itemBuild!(
                                      context, index, searchData![index], reqData['page'], reqData['limit'], () {
                                    return searchData;
                                  });
                                }, childCount: searchData!.length),
                              )))
              ]));
    }

    if (widget.noPull!) {
      return CustomScrollView(
        cacheExtent: 5.sh,
        slivers: [
          loading
              ? SliverToBoxAdapter(
                  child: PageStatus.loading(true),
                )
              : (searchData!.isEmpty
                  ? SliverToBoxAdapter(
                      child: widget.noData ?? PageStatus.noData(text: widget.nullText!),
                    )
                  : (widget.row == 1
                      ? SliverPadding(
                          padding: widget.padding ?? EdgeInsets.zero,
                          sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                            (BuildContext context, int index) {
                              return widget.itemBuild!(
                                  context, index, searchData![index], reqData['page'], reqData['limit'], () {
                                return searchData;
                              });
                            },
                            childCount: searchData!.length,
                          )),
                        )
                      : SliverGrid(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: widget.row!,
                            mainAxisSpacing: widget.mainAxisSpacing!,
                            crossAxisSpacing: widget.crossAxisSpacing!,
                            childAspectRatio: widget.aspectRatio!,
                          ),
                          delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
                            return widget.itemBuild!(
                                context, index, searchData![index], reqData['page'], reqData['limit'], () {
                              return searchData;
                            });
                          }, childCount: searchData!.length),
                        )))
        ],
      );
    }

    return networkErr
        ? PageStatus.noNetWork(onTap: () {
            loading = true;
            reqData['page'] = 1;
            isAll = false;
            setState(() {});
            getSearchResult();
          })
        : loading
            ? PageStatus.loading(true)
            : PullRefreshList(
                isAll: isAll,
                onLoading: () {
                  if (isAll || isload) {
                    return;
                  }
                  isload = true;
                  reqData['page']++;
                  getSearchResult();
                },
                onRefresh: widget.noRefresh!
                    ? null
                    : () {
                        loading = true;
                        reqData['page'] = 1;
                        isAll = false;
                        setState(() {});
                        getSearchResult();
                      },
                child: searchData!.isEmpty
                    ? (widget.noData ?? PageStatus.noData(text: widget.nullText))
                    : (widget.row == 1
                        ? ListView.builder(
                            physics: const ClampingScrollPhysics(),
                            padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).padding.bottom + AppGlobal.webBottomHeight,
                            ),
                            shrinkWrap: true,
                            cacheExtent: widget.cacheExtent ?? 3.sh,
                            controller: widget.controller == null && !widget.noController! ? _controller : null,
                            itemCount: searchData!.length,
                            itemBuilder: (context, index) {
                              return widget.itemBuild!(
                                  context, index, searchData![index], reqData['page'], reqData['limit'], () {
                                return searchData;
                              });
                            })
                        : (widget.isFlow!
                            ? WaterfallFlow.builder(
                                shrinkWrap: true,
                                controller: widget.controller == null && !widget.noController! ? _controller : null,
                                cacheExtent: widget.cacheExtent ?? 3.sh,
                                physics: ClampingScrollPhysics(),
                                padding: EdgeInsets.only(
                                    top: 10.w,
                                    bottom: MediaQuery.of(context).padding.bottom +
                                        AppGlobal.webBottomHeight +
                                        widget.bottomPadding!,
                                    left: 10.w,
                                    right: 10.w),
                                itemCount: searchData!.length,
                                gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: widget.row!,
                                    mainAxisSpacing: ScreenUtil().setWidth(10),
                                    crossAxisSpacing: ScreenUtil().setWidth(10)),
                                itemBuilder: (BuildContext context, int index) {
                                  return widget.itemBuild!(
                                      context, index, searchData![index], reqData['page'], reqData['limit'], () {
                                    return searchData;
                                  });
                                })
                            : GridView.builder(
                                controller: widget.controller == null && !widget.noController! ? _controller : null,
                                cacheExtent: widget.cacheExtent ?? 3.sh,
                                shrinkWrap: true,
                                physics: ClampingScrollPhysics(),
                                padding: EdgeInsets.only(
                                    left: 10.w,
                                    right: 10.w,
                                    bottom: MediaQuery.of(context).padding.bottom +
                                        AppGlobal.webBottomHeight +
                                        widget.bottomPadding!,
                                    top: 20.w),
                                itemCount: searchData!.length,
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: widget.row!,
                                  mainAxisSpacing: widget.mainAxisSpacing!,
                                  crossAxisSpacing: widget.crossAxisSpacing!,
                                  childAspectRatio: widget.aspectRatio!,
                                ),
                                itemBuilder: (context, index) {
                                  return widget.itemBuild!(
                                      context, index, searchData![index], reqData['page'], reqData['limit'], () {
                                    return searchData;
                                  });
                                }))),
              );
  }
}
