import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/list/public_list.dart';
import 'package:chaguaner2023/components/page_status.dart';
import 'package:chaguaner2023/components/pagetitlebar.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:chaguaner2023/utils/pageviewmixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class WinningRecord extends StatefulWidget {
  WinningRecord({Key? key}) : super(key: key);

  @override
  _WinningRecordState createState() => _WinningRecordState();
}

class _WinningRecordState extends State<WinningRecord> with TickerProviderStateMixin {
  Map<String, RefreshController> _refreshController = {};
  TabController? _tabController;
  bool loading = true;
  int selectIndex = 0;
  List _tabs = [];
  @override
  void initState() {
    super.initState();
    lotteryRecordTab().then((res) {
      if (res!['status'] != 0) {
        _tabs = res['data'];
        loading = false;
        _tabs.forEach((item) {
          _refreshController[item['key']] = RefreshController(initialRefresh: false);
        });
        _tabController = TabController(vsync: this, length: _tabs.length);
        _tabController!.addListener(() {
          selectIndex = _tabController!.index;
          setState(() {});
        });
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    _tabController!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HeaderContainer(
        child: Scaffold(
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
          child: PageTitleBar(
            title: '往期记录',
          ),
          preferredSize: Size(double.infinity, 44.w)),
      body: loading
          ? PageStatus.loading(mounted)
          : Column(
              children: [
                TabBar(
                    controller: _tabController,
                    indicatorPadding: EdgeInsets.all(0),
                    labelPadding: EdgeInsets.all(0),
                    isScrollable: true,
                    indicatorColor: Colors.transparent,
                    tabs: _tabs
                        .asMap()
                        .keys
                        .map((key) => Padding(
                              padding: EdgeInsets.only(left: 15.w),
                              child: CustomTab(tabIndex: selectIndex, keyIndex: key, title: _tabs[key]['title']),
                            ))
                        .toList()),
                WinningRecordTitle(),
                Expanded(
                    child: TabBarView(
                        controller: _tabController,
                        children: _tabs.asMap().keys.map((e) {
                          return PageViewMixin(
                              child: PublicList(
                                  isShow: true,
                                  limit: 20,
                                  isFlow: false,
                                  isSliver: false,
                                  nullText: '${_tabs[e]['title']}还没有记录～',
                                  api: "/api/lottery/log",
                                  data: {'id': _tabs[e]['id']},
                                  row: 1,
                                  itemBuild: (context, index, data, page, limit, getListData) {
                                    return WinningRecordItem(
                                      recordItem: data,
                                    );
                                  }));
                        }).toList()))
              ],
            ),
    ));
  }

  Widget norecord(value) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(vertical: 15.w, horizontal: 10.w),
      child: Text(
        _tabs[value]['title'],
        style: TextStyle(color: StyleTheme.cBioColor, fontSize: 14.sp),
      ),
    );
  }
}

class CustomTab extends StatelessWidget {
  final int? tabIndex;
  final int? keyIndex;
  final String? title;
  const CustomTab({Key? key, this.tabIndex, this.keyIndex, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Positioned(
              bottom: 0,
              child: LocalPNG(
                url: 'assets/images/tab-underline-long.png',
                alignment: Alignment.center,
                fit: BoxFit.fitHeight,
                height: tabIndex == keyIndex ? 9.w : 0,
              )),
          Text(
            '$title',
            style: TextStyle(
              color: StyleTheme.cTitleColor,
              fontWeight: tabIndex == keyIndex ? FontWeight.bold : FontWeight.normal,
              fontSize: tabIndex == keyIndex ? 18.sp : 14.sp,
            ),
          )
        ],
      ),
    );
  }
}

class WinningRecordTitle extends StatelessWidget {
  const WinningRecordTitle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 9.w, horizontal: 15.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              flex: 1,
              child: Center(
                  child: Text(
                "期数",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: StyleTheme.color30,
                  fontSize: 14.sp,
                ),
              ))),
          Expanded(
              flex: 2,
              child: Center(
                  child: Text(
                "开奖时间",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: StyleTheme.color30,
                  fontSize: 14.sp,
                ),
              ))),
          Expanded(
              flex: 2,
              child: Center(
                  child: Text(
                "中奖用户",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: StyleTheme.color30,
                  fontSize: 14.sp,
                ),
              )))
        ],
      ),
    );
  }
}

class WinningRecordItem extends StatelessWidget {
  final Map? recordItem;
  const WinningRecordItem({Key? key, this.recordItem}) : super(key: key);

  String handleDateTime() {
    return recordItem!['updated_at'].split(' ')[0].replaceAll('-', '/');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 9.w, horizontal: 15.w),
      child: Row(
        children: [
          Expanded(
              flex: 1,
              child: Center(
                  child: Text(
                "第" + recordItem!['lottery_num'].toString() + "期",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: StyleTheme.cTitleColor,
                  fontSize: 14.sp,
                ),
              ))),
          Expanded(
              flex: 2,
              child: Center(
                  child: Text(
                handleDateTime(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: StyleTheme.cTitleColor,
                  fontSize: 14.sp,
                ),
              ))),
          Expanded(
              flex: 2,
              child: Center(
                  child: Text(
                recordItem!['nickname'].toString(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: StyleTheme.cTitleColor,
                  fontSize: 14.sp,
                ),
              ))),
        ],
      ),
    );
  }
}
