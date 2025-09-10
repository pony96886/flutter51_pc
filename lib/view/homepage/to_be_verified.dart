import 'package:chaguaner2023/components/card/V3zhaopiaoCard.dart';
import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/loading.dart';
import 'package:chaguaner2023/components/networkErr.dart';
import 'package:chaguaner2023/components/nodata.dart';
import 'package:chaguaner2023/components/page_title_bar.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ToBeVerifiedPage extends StatefulWidget {
  ToBeVerifiedPage({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => ToBeVerifiedState();
}

class ToBeVerifiedState extends State<ToBeVerifiedPage> {
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  List? unconfirmData;
  bool loading = true;
  bool networkErr = false;
  // 加载数据需要参数
  int page = 1; //页数
  bool isAll = false; //数据是否已加载完
  bool isLoading = false;
  int limit = 10;
  ScrollController scrollController = ScrollController();
  void _onRefresh() async {
    page = 1;
    unconfirmData = null;
    loading = true;
    isLoading = false;
    isAll = false;
    setState(() {});
    initData();
    _refreshController.refreshCompleted();
  }

  initData() async {
    setState(() {
      networkErr = false;
    });
    var unconfirmList = await getUnconfirmList(page, limit);
    if (page == 1) {
      if (unconfirmList!['status'] != 0) {
        setState(() {
          unconfirmData = unconfirmList['data'];
          loading = false;
        });
      } else {
        setState(() {
          networkErr = true;
        });
        return;
      }
      if (unconfirmList['data'].length < limit) {
        setState(() {
          isAll = true;
          isLoading = !(unconfirmList['data'].length < limit);
        });
      }
    } else {
      if (unconfirmList!['status'] != 0 && unconfirmList['data'].length > 0) {
        setState(() {
          unconfirmData!.addAll(unconfirmList['data']);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = !(unconfirmList['data'].length < limit);
          isAll = true;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        if (!isAll && !isLoading) {
          setState(() {
            page++;
            isLoading = true;
          });
          initData();
        }
      }
    });
    initData();
  }

  @override
  Widget build(BuildContext context) {
    return HeaderContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
            child: PageTitleBar(
              title: '待验证茶帖',
            ),
            preferredSize: Size(double.infinity, 44.w)),
        body: networkErr
            ? NetworkErr(
                errorRetry: () {
                  initData();
                },
              )
            : (loading
                ? Loading()
                : (SmartRefresher(
                    controller: _refreshController,
                    enablePullUp: false,
                    enablePullDown: true,
                    physics: ClampingScrollPhysics(),
                    onRefresh: _onRefresh,
                    header: WaterDropMaterialHeader(
                      backgroundColor: StyleTheme.cDangerColor,
                    ),
                    child: unconfirmData!.length == 0
                        ? NoData(
                            text: '您还没有购买茶帖哦~',
                          )
                        : ListView.separated(
                            controller: scrollController,
                            physics: ClampingScrollPhysics(),
                            padding: EdgeInsets.only(top: 5.w, bottom: ScreenUtil().bottomBarHeight + 20.w),
                            itemCount: unconfirmData!.length + 1,
                            // physics: ClampingScrollPhysics(),
                            separatorBuilder: (BuildContext context, int index) => Divider(
                                  color: Colors.transparent,
                                  height: 15.w,
                                ),
                            itemBuilder: (BuildContext context, int index) {
                              return index != unconfirmData!.length
                                  ? V3ZhaoPiaoCard(
                                      key: Key('zhaopiao_card_$index'),
                                      type: 5,
                                      index: index,
                                      reqCallBack: (i) {
                                        unconfirmData!.removeAt(i);
                                        setState(() {});
                                        // initData();
                                      },
                                      zpInfo: unconfirmData![index],
                                    )
                                  : renderMore();
                            })))),
      ),
    );
  }

  String loadData = '数据加载中...';
  String noData = '没有更多数据';

  Widget renderMore() {
    return Padding(
      padding: EdgeInsets.only(top: 15.w, bottom: 15.w),
      child: Center(
        child: Text(
          isLoading ? loadData : noData,
          style: TextStyle(color: StyleTheme.cBioColor),
        ),
      ),
    );
  }
}
