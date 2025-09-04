import 'package:chaguaner2023/components/card/youhuiquan_card.dart';
import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/list/public_list.dart';
import 'package:chaguaner2023/components/pagetitlebar.dart';
import 'package:chaguaner2023/components/tab/tab_nav_shuimo.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/index.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:chaguaner2023/utils/pageviewmixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MyCards extends StatefulWidget {
  MyCards({Key? key}) : super(key: key);

  @override
  _MyCardsState createState() => _MyCardsState();
}

class _MyCardsState extends State<MyCards> with TickerProviderStateMixin {
  Map<int, RefreshController> _refreshController = {};
  int _selectedTabIndex = 0;
  int limit = 20;
  TabController? _tabController;

  List _tabs = [
    {
      'req': 'canUse',
      'title': '待使用',
      'activeWidth': 85.w,
      'inActiveWidth': 80.w,
    },
    {
      'req': 'used',
      'title': '已使用',
      'activeWidth': 85.w,
      'inActiveWidth': 80.w,
    },
    {
      'req': 'expired',
      'title': '已过期',
      'activeWidth': 85.w,
      'inActiveWidth': 80.w,
    }
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: _tabs.length);
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

  Widget _NoCard() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LocalPNG(
            width: 150.w,
            height: 150.w,
            url: 'assets/images/pintuan/nocard.png',
          ),
          Text(
            '还没有优惠券呢',
            style: TextStyle(
                fontSize: 14.sp, color: StyleTheme.cBioColor, height: 2),
          ),
          Text(
            '雅间预约妹子成功',
            style: TextStyle(
                fontSize: 12.sp, color: StyleTheme.cDangerColor, height: 2),
          ),
          Text(
            '并进行评价即可获得元宝优惠券',
            style: TextStyle(
                fontSize: 12.sp, color: StyleTheme.cDangerColor, height: 2),
          ),
          GestureDetector(
            onTap: () {
              context.pop();
              EventBus().emit('changeHomeTap', 1);
            },
            child: Container(
              height: 50.w,
              width: 275.w,
              margin: EdgeInsets.only(top: 50.w),
              child: Stack(
                children: [
                  LocalPNG(
                      height: 50.w,
                      width: 275.w,
                      url: 'assets/images/mymony/money-img.png',
                      fit: BoxFit.cover),
                  Center(
                    child: Text(
                      '前往预约',
                      style: TextStyle(color: Colors.white, fontSize: 15.sp),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return HeaderContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
            child: PageTitleBar(
              title: '卡券包',
              rightWidget: GestureDetector(
                  onTap: () {
                    AppGlobal.appRouter
                        ?.push(CommonUtils.getRealHash('exchangeCoupon'));
                  },
                  child: Center(
                    child: Container(
                      margin: new EdgeInsets.only(right: 15.w),
                      child: Text(
                        '兑优惠券',
                        style: TextStyle(
                            color: StyleTheme.cTitleColor,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  )),
            ),
            preferredSize: Size(double.infinity, 44.w)),
        body: Column(
          children: [
            TabNavShuimo(
              bgColor: true,
              tabs: _tabs,
              tabController: _tabController,
              selectedTabIndex: _selectedTabIndex,
            ).build(context),
            Expanded(
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15.w),
                    child: TabBarView(controller: _tabController, children: [
                      PageViewMixin(
                          child: PublicList(
                              noData: _NoCard(),
                              isShow: true,
                              limit: 15,
                              isFlow: false,
                              isSliver: false,
                              api: '/api/coupon/getUserCouponList',
                              data: {'filter': 'canUse'},
                              row: 1,
                              itemBuild: (context, index, data, page, limit,
                                  getListData) {
                                return YouHuiQuanCard(cardData: data);
                              })),
                      PageViewMixin(
                          child: PublicList(
                              noData: _NoCard(),
                              isShow: true,
                              limit: 15,
                              isFlow: false,
                              isSliver: false,
                              api: '/api/coupon/getUserCouponList',
                              data: {'filter': 'used'},
                              row: 1,
                              itemBuild: (context, index, data, page, limit,
                                  getListData) {
                                return YouHuiQuanCard(cardData: data);
                              })),
                      PageViewMixin(
                        child: PublicList(
                            noData: _NoCard(),
                            isShow: true,
                            limit: 15,
                            isFlow: false,
                            isSliver: false,
                            api: '/api/coupon/getUserCouponList',
                            data: {'filter': 'expired'},
                            row: 1,
                            itemBuild: (context, index, data, page, limit,
                                getListData) {
                              return YouHuiQuanCard(cardData: data);
                            }),
                      )
                    ])))
          ],
        ),
      ),
    );
  }
}
