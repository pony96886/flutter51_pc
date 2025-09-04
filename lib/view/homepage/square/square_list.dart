import 'package:bot_toast/bot_toast.dart';
import 'package:chaguaner2023/components/networkErr.dart';
import 'package:chaguaner2023/components/nodata.dart';
import 'package:chaguaner2023/components/page_status.dart';
import 'package:chaguaner2023/components/pullrefreshlist.dart';
import 'package:chaguaner2023/store/homeConfig.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/http.dart';
import 'package:chaguaner2023/utils/netimage_tool.dart';
import 'package:chaguaner2023/view/homepage/squarePages.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class SquareList extends StatefulWidget {
  final Map
      tabList; // 例 {'type':[{'title':'认证'},'title':‘未认证’],'name':['title':'老王','title':'老张']};
  final String? api; // api地址
  final Function(Map data)? build;
  final int row;
  final double aspectRatio;
  final double mainAxisSpacing;
  final Map?
      filter; //exclude 排除 fixed 固定传值 'exclude': { 'type': [0] }, 'fixed': {'is_money': 0}
  final double crossAxisSpacing;
  final List? ads; //广告
  final int? id;
  SquareList(
      {Key? key,
      required this.tabList,
      this.api,
      this.build,
      this.row = 1,
      this.aspectRatio = 1,
      this.mainAxisSpacing = 10,
      this.crossAxisSpacing = 10,
      this.filter,
      this.ads,
      this.id})
      : super(key: key);

  @override
  _SquareListState createState() => _SquareListState();
}

class _SquareListState extends State<SquareList> {
  String? api;
  bool isload = false;
  bool isAll = false;
  bool loading = true;
  bool networkErr = false;
  Map reqData = {'page': 1, 'limit': 20};
  Map selectTab = {};
  int? postType;
  @override
  void initState() {
    super.initState();
    api = widget.api;
    widget.tabList?.keys.forEach((element) {
      selectTab[element] = 0;
    });
    getSearchResult();
  }

  List? searchData;
  Future getSearchResult() async {
    widget.tabList?.keys.forEach((element) {
      if (element == 'type' && (widget.id == 1 || widget.id == 2)) {
        reqData[element] = widget.tabList?[element][selectTab[element]]['id'];
      } else if (element == 'post_type') {
        int? _type = widget.tabList?['post_type'][selectTab[element]]['value'];
        _type = _type == -1 ? null : _type;
        if (postType != _type) {
          postType = _type;
          selectTab['type'] = 0;
        }
        reqData[element] = selectTab[element];
      } else {
        reqData[element] = selectTab[element];
      }
      setState(() {});
      if (widget.tabList![element] != null &&
          widget.tabList![element][selectTab[element]]['api'] != null) {
        //如果tab筛选需要请求新接口
        api = widget.tabList![element][selectTab[element]]['api'];
      } else {
        api = widget.api;
      }
    });

    //如果有固定的Value值
    widget.tabList?.keys.forEach((element) {
      if (reqData[element] != null &&
          widget.tabList?[element][selectTab[element]]['value'] != null) {
        reqData[element] =
            widget.tabList?[element][selectTab[element]]['value'];
      }
    });
    //如果有固定传值
    if (widget.filter?['fixed'] != null) {
      widget.filter!['fixed'].keys.forEach((element) {
        reqData[element] = widget.filter!['fixed'][element];
      });
    }
    //如果需要排除值
    if (widget.filter?['exclude'] != null) {
      widget.filter?['exclude'].keys.forEach((element) {
        if (widget.filter?['exclude'][element].indexOf(reqData[element]) >= 0) {
          if (reqData[element] == null) return;
          reqData.remove(element);
        }
      });
    }

    //排除不要的字段
    widget.tabList!.forEach((key, value) {
      widget.tabList![key].forEach((element) {
        if (element['exclude'] != null && reqData[key] == element['value']) {
          reqData.remove(element['exclude']);
        }
      });
    });

    CommonUtils.debugPrint("请求 $api******$reqData");
    try {
      List topResData = [];
      if (api == "/api/goods/listFilter" && reqData['type'] == 2) {
        var topResult = await getTopList();
        if (topResult!['status'] == 1) {
          if (topResult['data'] != null && topResult['data'] is List) {
            topResData.addAll(topResult['data']);
          }
        }
      }
      Response<dynamic> res = await PlatformAwareHttp.post(api!, data: reqData);
      List resdata;
      isload = false;
      if (res.data['status'] != 0) {
        if (res.data['data'] != null && res.data['data'] is List) {
          resdata = (res.data['data'] == null ? [] : res.data['data']);
        } else {
          resdata =
              (res.data['data'] != null && res.data['data']['list'] != null
                  ? res.data['data']['list']
                  : []);
        }

        isAll = resdata.length < reqData['limit'];
        if (reqData['page'] == 1) {
          searchData = resdata;
          if (topResData.isNotEmpty) {
            searchData!.insertAll(0, [...topResData]);
          }
        } else {
          searchData!.addAll(resdata);
        }
        loading = false;
        setState(() {});
      } else {
        if (res.data['msg'] == "token无效") {
          getSearchResult();
        }
        CommonUtils.showText(res.data['msg']);
      }
      // CommonUtils.debugPrint(searchData);
    } catch (e) {
      networkErr = true;
      if (mounted) {
        setState(() {});
      }
      CommonUtils.debugPrint('错误:$e');
    }
  }

  _onTapSwiper(String type, String _adsUrl) {
    var members = Provider.of<HomeConfig>(context, listen: false).member;
    var aff = members.aff;
    var chaid = members.uuid;
    var types = type;
    String urls = "$_adsUrl?aff=$aff&chaid=$chaid";
    if (['', null, false].contains(_adsUrl)) {
      BotToast.showText(text: '未配置跳转链接', align: Alignment(0, 0));
      return;
    }
    if (types == "1") {
      // 内部路由
      AppGlobal.appRouter?.push(CommonUtils.getRealHash('$_adsUrl'));
    } else if (types == "2") {
      // WebViewPage
      AppGlobal.appRouter?.push(
          CommonUtils.getRealHash('activityPage/${Uri.encodeComponent(urls)}'));
    } else if (types == "3") {
      // 外部浏览器
      CommonUtils.launchURL(urls);
    } else if (types == "4") {
      // 外部浏览器
      CommonUtils.launchURL("$_adsUrl");
    } else if (types == "5") {
      // WebViewPage
      AppGlobal.appRouter?.push(CommonUtils.getRealHash(
          'activityPage/${Uri.encodeComponent(_adsUrl)}'));
    }
  }

  ScrollController controller = ScrollController();
  @override
  Widget build(BuildContext context) {
    return networkErr
        ? NetworkErr(
            errorRetry: () {
              reqData['page'] = 1;
              isload = false;
              isAll = false;
              loading = true;
              networkErr = false;
              setState(() {});
            },
          )
        : Padding(
            padding:
                EdgeInsets.symmetric(horizontal: widget.row != 1 ? 15.w : 0),
            child: PullRefreshList(
              onLoading: () {
                if (isAll || isload || loading) {
                  return;
                }
                isload = true;
                reqData['page']++;
                getSearchResult();
              },
              child: CustomScrollView(
                physics: ClampingScrollPhysics(),
                // controller: controller,
                cacheExtent: 5.sh,
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.only(top: 5.w),
                    sliver: SliverToBoxAdapter(
                      child: widget.tabList.length == 0
                          ? Container()
                          : Container(
                              padding: EdgeInsets.symmetric(horizontal: 15.w),
                              width: widget.tabList.keys.length * 115.w,
                              margin: EdgeInsets.only(bottom: 10.w),
                              height: 65.w,
                              color: Color(0xfff8f6f1),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: widget.tabList!.keys.map((_key) {
                                  return SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: TabsContainer(
                                        tabs: widget.tabList![_key],
                                        filter:
                                            _key == 'type' ? postType : null,
                                        selectTabIndex: selectTab[_key],
                                        onTabs: (e) {
                                          if (selectTab[_key] == e) return;
                                          selectTab[_key] = e;
                                          reqData['page'] = 1;
                                          isload = false;
                                          isAll = false;
                                          loading = true;
                                          networkErr = false;
                                          getSearchResult();
                                        },
                                      ));
                                }).toList(),
                              )),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: widget.ads == null
                        ? Container()
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: widget.ads!.asMap().keys.map((e) {
                              return widget.ads![e]['position'] != 2
                                  ? Container()
                                  : Stack(
                                      children: [
                                        GestureDetector(
                                            onTap: () {
                                              _onTapSwiper(
                                                  widget.ads![e]['type']
                                                      .toString(),
                                                  widget.ads![e]['url']);
                                              // if (widget.ads![e]['type'] == 1) {
                                              //   CommonUtils.launchURL(
                                              //       widget.ads![e]['url']);
                                              // } else {
                                              //   AppGlobal.appRouter?.push(
                                              //       '/tackDetailPage/' +
                                              //           widget.ads![e]['url']
                                              //               .toString());
                                              // }
                                            },
                                            child: Container(
                                                margin: EdgeInsets.only(
                                                    bottom: 10.w),
                                                decoration: BoxDecoration(
                                                  boxShadow: [
                                                    //阴影
                                                    BoxShadow(
                                                        color: Colors.black12,
                                                        offset:
                                                            Offset(0, 0.5.w),
                                                        blurRadius: 2.5.w)
                                                  ],
                                                  color: Colors.white,
                                                ),
                                                width:
                                                    ScreenUtil().screenWidth -
                                                        30.w,
                                                height: 150.w,
                                                child: NetImageTool(
                                                  fit: BoxFit.cover,
                                                  url: widget.ads![e]
                                                      ['img_full_url'],
                                                  radius:
                                                      BorderRadius.circular(10),
                                                ))),
                                      ],
                                    );
                            }).toList(),
                          ),
                  ),
                  loading
                      ? SliverToBoxAdapter(
                          child: PageStatus.loading(true),
                        )
                      : (searchData!.length == 0
                          ? SliverToBoxAdapter(
                              child: NoData(
                              text: '没有数据啦～',
                            ))
                          : (widget.row == 1
                              ? SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                  (BuildContext context, int index) {
                                    return widget.build!(searchData![index]);
                                  },
                                  childCount: searchData!.length,
                                ))
                              : SliverGrid(
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: widget.row,
                                    mainAxisSpacing: widget.mainAxisSpacing,
                                    crossAxisSpacing: widget.crossAxisSpacing,
                                    childAspectRatio: widget.aspectRatio,
                                  ),
                                  delegate: SliverChildBuilderDelegate(
                                      (BuildContext context, int index) {
                                    return widget.build!(searchData![index]);
                                  }, childCount: searchData!.length),
                                ))),
                ],
              ),
            ),
          );
  }
}
