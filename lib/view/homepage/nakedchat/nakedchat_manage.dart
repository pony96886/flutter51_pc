import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/list/public_list.dart';
import 'package:chaguaner2023/components/pagetitlebar.dart';
import 'package:chaguaner2023/components/tab/nav_tab_bar_mixin.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/pageviewmixin.dart';
import 'package:chaguaner2023/view/homepage/nakedchat/nakedchat_card.dart';
import 'package:chaguaner2023/view/homepage/nakedchat/nakedchat_ordercard.dart';
import 'package:extended_tabs/extended_tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NaledChatManage extends StatefulWidget {
  const NaledChatManage({Key? key}) : super(key: key);

  @override
  State<NaledChatManage> createState() => _NaledChatManageState();
}

class _NaledChatManageState extends State<NaledChatManage>
    with TickerProviderStateMixin {
  TabController? tabController;
  TabController? mangeController;
  TabController? orderController;
  List tabs = ['信息管理', '订单列表'];
  List mangeTabs = ['审核中', '审核通过', '审核失败'];
  List orderTabs = ['全部', '待确认', '已完成'];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = TabController(length: tabs.length, vsync: this);
    mangeController = TabController(length: mangeTabs.length, vsync: this);
    orderController = TabController(length: orderTabs.length, vsync: this);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    tabController!.dispose();
    mangeController!.dispose();
    orderController!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HeaderContainer(
        child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Column(
              children: [
                PageTitleBar(
                  title: '裸聊管理',
                  rightWidget: GestureDetector(
                    onTap: () {
                      AppGlobal.appRouter
                          ?.push(CommonUtils.getRealHash('nakechatPublish'));
                    },
                    child: Text(
                      '发布',
                      style: TextStyle(
                          color: StyleTheme.cTitleColor, fontSize: 14.sp),
                    ),
                  ),
                ),
                NavTabBarWidget(
                  tabBarHeight: 44.0.w,
                  tabVc: tabController,
                  tabs: tabs.map((e) => e as String).toList(),
                  isScrollable: false,
                  textPadding: EdgeInsets.symmetric(horizontal: 12.5.w),
                  selectedIndex: tabController!.index,
                  norTextStyle:
                      TextStyle(color: StyleTheme.cTitleColor, fontSize: 14.sp),
                  selTextStyle: TextStyle(
                      color: StyleTheme.cTitleColor,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold),
                  indicatorStyle: NavIndicatorStyle.none,
                ),
                Expanded(
                    child: ExtendedTabBarView(
                        controller: tabController,
                        children: [
                      //信息管理
                      Column(
                        children: [
                          NavTabBarWidget(
                            tabBarHeight: 44.0.w,
                            tabVc: mangeController,
                            isScrollable: false,
                            tabs: mangeTabs.map((e) => e as String).toList(),
                            // containerPadding: EdgeInsets.symmetric(horizontal: 70.w),
                            textPadding:
                                EdgeInsets.symmetric(horizontal: 12.5.w),
                            selectedIndex: mangeController!.index,
                            norTextStyle: TextStyle(
                                color: StyleTheme.cTitleColor, fontSize: 14.sp),
                            selTextStyle:
                                TextStyle(color: Colors.white, fontSize: 14.sp),
                            indicatorStyle: NavIndicatorStyle.cus_icon,
                            indicator: LineIndicator(
                                isCenter: true,
                                width: 75.w,
                                height: 25.w,
                                color: StyleTheme.cDangerColor),
                          ),
                          Expanded(
                              child: ExtendedTabBarView(
                            controller: mangeController,
                            children: [
                              PageViewMixin(
                                child: PublicList(
                                    isShow: true,
                                    limit: 30,
                                    isFlow: false,
                                    isSliver: false,
                                    api: '/api/girlchat/my',
                                    data: {'cate': 0},
                                    row: 2,
                                    aspectRatio: 0.74,
                                    mainAxisSpacing: 10.w,
                                    crossAxisSpacing: 5.w,
                                    itemBuild: (context, index, data, page,
                                        limit, getListData) {
                                      return NakedchtCard(
                                        data: data,
                                      );
                                    }),
                              ),
                              PageViewMixin(
                                child: PublicList(
                                    isShow: true,
                                    limit: 30,
                                    isFlow: false,
                                    isSliver: false,
                                    api: '/api/girlchat/my',
                                    data: {'cate': 1},
                                    row: 2,
                                    aspectRatio: 0.74,
                                    mainAxisSpacing: 10.w,
                                    crossAxisSpacing: 5.w,
                                    itemBuild: (context, index, data, page,
                                        limit, getListData) {
                                      return NakedchtCard(
                                        data: data,
                                      );
                                    }),
                              ),
                              PageViewMixin(
                                child: PublicList(
                                    isShow: true,
                                    limit: 30,
                                    isFlow: false,
                                    isSliver: false,
                                    api: '/api/girlchat/my',
                                    data: {'cate': 2},
                                    row: 2,
                                    aspectRatio: 0.74,
                                    mainAxisSpacing: 10.w,
                                    crossAxisSpacing: 5.w,
                                    itemBuild: (context, index, data, page,
                                        limit, getListData) {
                                      return NakedchtCard(
                                        data: data,
                                      );
                                    }),
                              )
                            ],
                          ))
                        ],
                      ),
                      //订单管理
                      Column(
                        children: [
                          NavTabBarWidget(
                            tabBarHeight: 44.0.w,
                            tabVc: orderController,
                            tabs: orderTabs.map((e) => e as String).toList(),
                            isScrollable: false,
                            textPadding:
                                EdgeInsets.symmetric(horizontal: 12.5.w),
                            selectedIndex: orderController!.index,
                            norTextStyle: TextStyle(
                                color: StyleTheme.cTitleColor, fontSize: 14.sp),
                            selTextStyle:
                                TextStyle(color: Colors.white, fontSize: 14.sp),
                            indicatorStyle: NavIndicatorStyle.cus_icon,
                            indicator: LineIndicator(
                                isCenter: true,
                                width: 75.w,
                                height: 25.w,
                                color: StyleTheme.cDangerColor),
                          ),
                          Expanded(
                              child: ExtendedTabBarView(
                            controller: orderController,
                            children: [
                              PageViewMixin(
                                child: PublicList(
                                    isShow: true,
                                    limit: 30,
                                    isFlow: false,
                                    isSliver: false,
                                    api: '/api/girlchat/order_list',
                                    data: {'cate': 0},
                                    row: 1,
                                    itemBuild: (context, index, data, page,
                                        limit, getListData) {
                                      return NakedChatOrderCard(
                                          data: data, type: 2);
                                    }),
                              ),
                              PageViewMixin(
                                child: PublicList(
                                    isShow: true,
                                    limit: 30,
                                    isFlow: false,
                                    isSliver: false,
                                    api: '/api/girlchat/order_list',
                                    data: {'cate': 1},
                                    row: 1,
                                    itemBuild: (context, index, data, page,
                                        limit, getListData) {
                                      return NakedChatOrderCard(
                                          data: data, type: 2);
                                    }),
                              ),
                              PageViewMixin(
                                child: PublicList(
                                    isShow: true,
                                    limit: 30,
                                    isFlow: false,
                                    isSliver: false,
                                    api: '/api/girlchat/order_list',
                                    data: {'cate': 2},
                                    row: 1,
                                    itemBuild: (context, index, data, page,
                                        limit, getListData) {
                                      return NakedChatOrderCard(
                                          data: data, type: 2);
                                    }),
                              )
                            ],
                          ))
                        ],
                      )
                    ]))
              ],
            )));
  }
}
