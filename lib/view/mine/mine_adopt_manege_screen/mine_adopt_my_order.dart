import 'package:flutter/material.dart';
import 'package:chaguaner2023/components/card/adoptCard.dart';
import 'package:chaguaner2023/components/list/public_list.dart';
import 'package:chaguaner2023/components/tab/tab_nav_shuimo.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/pageviewmixin.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MineAdoptMyOrder extends StatefulWidget {
  MineAdoptMyOrder({Key? key}) : super(key: key);

  @override
  _MineAdoptMyOrderState createState() => _MineAdoptMyOrderState();
}

class _MineAdoptMyOrderState extends State<MineAdoptMyOrder>
    with TickerProviderStateMixin {
  int _tabsIndex = 0;
  TabController? _tabController;
  int limit = 10;
  bool networkErr = false;
  List _tabs = [
    {
      'status': 0,
      'key': 'all',
      'title': '审核中',
      'activeWidth': 70.w,
      'inActiveWidth': 70.w,
    },
    {
      'status': 1,
      'key': 'auditpass',
      'title': '审核通过',
      'activeWidth': 70.w,
      'inActiveWidth': 70.w,
    },
    {
      'status': 2,
      'key': 'failedaudit',
      'title': '审核失败',
      'activeWidth': 70.w,
      'inActiveWidth': 70.w,
    }
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: _tabs.length);
    //点击tab
    _tabController!.addListener(() {
      setState(() {
        _tabsIndex = _tabController!.index;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _tabController!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          TabNavShuimo(
            tabWidth: (1.sw - 20.w) / _tabs.length,
            tabStyle: BoxDecoration(
                color: StyleTheme.cDangerColor,
                borderRadius: BorderRadius.circular(12.5)),
            tabs: _tabs,
            tabController: _tabController,
            selectedTabIndex: _tabsIndex,
          ),
          Expanded(
              child: TabBarView(
                  physics: ClampingScrollPhysics(),
                  controller: _tabController,
                  children: _tabs.asMap().keys.map((e) {
                    return PageViewMixin(
                      child: PublicList(
                          isShow: true,
                          limit: 15,
                          isFlow: false,
                          isSliver: false,
                          api: '/api/keep/my_list',
                          data: {'status': _tabs[e]['status']},
                          mainAxisSpacing: 7.w,
                          crossAxisSpacing: 7.w,
                          aspectRatio: 0.7,
                          row: 2,
                          itemBuild:
                              (context, index, data, page, limit, getListData) {
                            return AdoptCard(adoptData: data);
                          }),
                    );
                  }).toList()))
        ],
      ),
    );
  }
}
