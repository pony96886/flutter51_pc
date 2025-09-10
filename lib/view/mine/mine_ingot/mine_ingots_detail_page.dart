import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/list/public_list.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:chaguaner2023/utils/pageviewmixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MineIngotsDetailPage extends StatefulWidget {
  MineIngotsDetailPage({Key? key}) : super(key: key);

  @override
  _MineIngotsDetailPageState createState() => _MineIngotsDetailPageState();
}

class _MineIngotsDetailPageState extends State<MineIngotsDetailPage> with TickerProviderStateMixin {
  TabController? _tabController;
  int _selectedTabIndex = 0;

  List _tabs = [
    {
      'title': '收益',
      'activeWidth': 80.w,
      'inActiveWidth': 80.w,
    },
    {
      'title': '支出',
      'activeWidth': 80.w,
      'inActiveWidth': 80.w,
    }
  ];
  double getTabWidth(key) {
    // 控制激活与非激活的宽度
    if (_selectedTabIndex == key) {
      return _tabs[key]['activeWidth'];
    } else {
      return _tabs[key]['inActiveWidth'];
    }
  }

  @override
  void initState() {
    super.initState();
    ;
    _tabController = TabController(vsync: this, length: 2);
    _tabController!.addListener(() {
      _selectedTabIndex = _tabController!.index;
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(
          color: StyleTheme.cTitleColor,
        ),
        title: PreferredSize(
            child: Container(
              margin: new EdgeInsets.only(left: 60.w),
              height: 50.w,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      indicatorColor: Colors.transparent,
                      indicatorPadding: EdgeInsets.all(0),
                      labelPadding: EdgeInsets.all(0),
                      tabs: _tabs
                          .asMap()
                          .keys
                          .map(
                            (key) => Tab(
                              child: Stack(
                                children: <Widget>[
                                  Positioned(
                                      bottom: 9.w,
                                      child: _selectedTabIndex == key
                                          ? LocalPNG(
                                              url: 'assets/images/tab-underline.png',
                                              fit: BoxFit.fitHeight,
                                              height: 9.w,
                                            )
                                          : Text(' ')),
                                  Container(
                                      width: getTabWidth(key),
                                      color: Colors.transparent,
                                      height: 50.w,
                                      alignment: Alignment.centerLeft,
                                      margin: EdgeInsets.only(left: 6.w),
                                      child: Text(_tabs[key]['title'],
                                          style: _selectedTabIndex == key
                                              ? TextStyle(
                                                  color: StyleTheme.cTitleColor,
                                                  fontSize: 18.sp,
                                                  fontWeight: FontWeight.w700)
                                              : TextStyle(color: StyleTheme.cTitleColor, fontSize: 14.sp))),
                                ],
                              ),
                            ),
                          )
                          .toList()),
                ],
              ),
              padding: EdgeInsets.only(left: 0),
              color: Colors.transparent,
            ),
            preferredSize: Size(double.infinity, 50.w)),
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        child: Column(
          children: <Widget>[
            DefaultTextStyle(
                style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 14.w, fontWeight: FontWeight.w300),
                child: Padding(
                  padding: new EdgeInsets.only(bottom: 9.w),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                          flex: 1,
                          child: Center(
                            child: Text('时间'),
                          )),
                      Container(
                        width: 100.w,
                        child: Center(
                          child: Text('类型'),
                        ),
                      ),
                      Expanded(
                          flex: 1,
                          child: Center(
                            child: Text('数量'),
                          )),
                    ],
                  ),
                )),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  PageViewMixin(
                    child: PublicList(
                        isShow: true,
                        limit: 30,
                        isFlow: false,
                        isSliver: false,
                        api: '/api/user/listMoneyDetail',
                        data: {'type': 1},
                        row: 1,
                        itemBuild: (context, index, data, page, limit, getListData) {
                          return withdrawItem(data['time'], data['source'], data['coinCnt'].toString());
                        }),
                  ),
                  PageViewMixin(
                      child: PublicList(
                          isShow: true,
                          limit: 30,
                          isFlow: false,
                          isSliver: false,
                          api: '/api/user/listMoneyDetail',
                          data: {'type': 2},
                          row: 1,
                          itemBuild: (context, index, data, page, limit, getListData) {
                            return withdrawItem(
                                data['time'].toString(), data['source'].toString(), data['coinCnt'].toString());
                          })),
                ],
              ),
            )
          ],
        ),
      ),
    ));
  }

  Widget withdrawItem(String time, String state, String monney) {
    return DefaultTextStyle(
        style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 14.sp),
        child: Row(
          children: <Widget>[
            Expanded(
                flex: 1,
                child: Center(
                  child: Text(time),
                )),
            Container(
              width: 100.w,
              child: Center(
                child: Text(state == null ? '-' : state.toString()),
              ),
            ),
            Expanded(
                flex: 1,
                child: Center(
                  child: Text(monney),
                )),
          ],
        ));
  }
}
