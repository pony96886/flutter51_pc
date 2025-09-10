import 'package:chaguaner2023/components/card/adoptCard.dart';
import 'package:chaguaner2023/components/card/mall_order_card.dart';
import 'package:chaguaner2023/components/cg_tabview.dart';
import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/list/public_list.dart';
import 'package:chaguaner2023/components/nodata.dart';
import 'package:chaguaner2023/components/page_title_bar.dart';
import 'package:chaguaner2023/components/tab/nav_tab_bar_mixin.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/pageviewmixin.dart';
import 'package:chaguaner2023/view/homepage/nakedchat/nakedchat_ordercard.dart';
import 'package:extended_tabs/extended_tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MineUserMallOrderPage extends StatefulWidget {
  const MineUserMallOrderPage({Key? key}) : super(key: key);

  @override
  State<MineUserMallOrderPage> createState() => _MineUserMallOrderPageState();
}

class _MineUserMallOrderPageState extends State<MineUserMallOrderPage> with SingleTickerProviderStateMixin {
  TabController? tabController;
  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    tabController!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HeaderContainer(
        child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: PreferredSize(
                child: PageTitleBar(
                  centerWidget: NavTabBarWidget(
                    tabBarHeight: 44.0.w,
                    tabVc: tabController,
                    isScrollable: false,
                    tabs: ['裸聊', '商城', '包养'],
                    textPadding: EdgeInsets.symmetric(horizontal: 12.5.w),
                    selectedIndex: tabController!.index,
                    norTextStyle: TextStyle(color: StyleTheme.cTitleColor, fontSize: 16.sp),
                    selTextStyle:
                        TextStyle(color: StyleTheme.cTitleColor, fontSize: 18.sp, fontWeight: FontWeight.bold),
                    indicatorStyle: NavIndicatorStyle.none,
                  ),
                ),
                preferredSize: Size(double.infinity, 44.w)),
            body: ExtendedTabBarView(controller: tabController, children: [
              //裸聊
              CgTabView(
                  padding: EdgeInsets.only(bottom: 12.w, left: 15.w, right: 15.w),
                  isCenter: false,
                  spacing: 0,
                  isFlex: true,
                  type: CgTabType.redRaduis,
                  defaultStyle: TextStyle(color: Color(0xff1e1e1e), fontSize: 14.w),
                  activeStyle: TextStyle(color: Colors.white, fontSize: 14.w),
                  tabs: [
                    '全部',
                    '待确认',
                    '已完成',
                  ],
                  pages: [
                    PageViewMixin(
                      child: PublicList(
                          isShow: true,
                          limit: 15,
                          isFlow: false,
                          isSliver: false,
                          api: '/api/girlchat/my_order',
                          data: {'cate': 0},
                          itemBuild: (context, index, data, page, limit, getListData) {
                            return NakedChatOrderCard(
                              data: data,
                            );
                          }),
                    ),
                    PageViewMixin(
                      child: PublicList(
                          isShow: true,
                          limit: 15,
                          isFlow: false,
                          isSliver: false,
                          api: '/api/girlchat/my_order',
                          data: {'cate': 1},
                          itemBuild: (context, index, data, page, limit, getListData) {
                            return NakedChatOrderCard(
                              data: data,
                            );
                          }),
                    ),
                    PageViewMixin(
                      child: PublicList(
                          isShow: true,
                          limit: 15,
                          isFlow: false,
                          isSliver: false,
                          api: '/api/girlchat/my_order',
                          data: {'cate': 2},
                          itemBuild: (context, index, data, page, limit, getListData) {
                            return NakedChatOrderCard(
                              data: data,
                            );
                          }),
                    ),
                  ]),
//商城
              CgTabView(
                  padding: EdgeInsets.only(bottom: 12.w, left: 15.w, right: 15.w),
                  isCenter: false,
                  spacing: 0,
                  isFlex: true,
                  type: CgTabType.redRaduis,
                  defaultStyle: TextStyle(color: Color(0xff1e1e1e), fontSize: 14.w),
                  activeStyle: TextStyle(color: Colors.white, fontSize: 14.w),
                  tabs: [
                    '全部',
                    '待发货',
                    '待收货',
                    '已收货',
                    '评价',
                  ],
                  pages: [
                    PageViewMixin(
                      child: PublicList(
                          padding: EdgeInsets.symmetric(horizontal: 15.w),
                          api: '/api/product/order_list',
                          noController: true,
                          mainAxisSpacing: 10.w,
                          crossAxisSpacing: 6.w,
                          data: {'for_seller': 0, 'status': -1},
                          isShow: true,
                          noData: NoData(
                            text: '还没有商品哦～',
                          ),
                          itemBuild: (context, index, data, page, limit, getListData) {
                            return MallOrderCard(data: data);
                          }),
                    ),
                    PageViewMixin(
                      child: PublicList(
                          api: '/api/product/order_list',
                          noController: true,
                          mainAxisSpacing: 10.w,
                          crossAxisSpacing: 6.w,
                          data: {'for_seller': 0, 'status': 0},
                          isShow: true,
                          noData: NoData(
                            text: '还没有商品哦～',
                          ),
                          itemBuild: (context, index, data, page, limit, getListData) {
                            return MallOrderCard(data: data);
                          }),
                    ),
                    PageViewMixin(
                      child: PublicList(
                          api: '/api/product/order_list',
                          noController: true,
                          mainAxisSpacing: 10.w,
                          crossAxisSpacing: 6.w,
                          data: {'for_seller': 0, 'status': 1},
                          isShow: true,
                          noData: NoData(
                            text: '还没有商品哦～',
                          ),
                          itemBuild: (context, index, data, page, limit, getListData) {
                            return MallOrderCard(data: data);
                          }),
                    ),
                    PageViewMixin(
                      child: PublicList(
                          api: '/api/product/order_list',
                          noController: true,
                          mainAxisSpacing: 10.w,
                          crossAxisSpacing: 6.w,
                          data: {'for_seller': 0, 'status': 2},
                          isShow: true,
                          noData: NoData(
                            text: '还没有商品哦～',
                          ),
                          itemBuild: (context, index, data, page, limit, getListData) {
                            return MallOrderCard(data: data);
                          }),
                    ),
                    PageViewMixin(
                      child: PublicList(
                          api: '/api/product/order_list',
                          noController: true,
                          mainAxisSpacing: 10.w,
                          crossAxisSpacing: 6.w,
                          data: {'for_seller': 0, 'status': 3},
                          isShow: true,
                          noData: NoData(
                            text: '还没有商品哦～',
                          ),
                          itemBuild: (context, index, data, page, limit, getListData) {
                            return MallOrderCard(data: data);
                          }),
                    ),
                  ]),
              PageViewMixin(
                child: PublicList(
                    isShow: true,
                    limit: 15,
                    isFlow: false,
                    isSliver: false,
                    api: '/api/keep/my_order',
                    row: 2,
                    mainAxisSpacing: 7.w,
                    crossAxisSpacing: 7.w,
                    aspectRatio: 0.7,
                    itemBuild: (context, index, data, page, limit, getListData) {
                      return AdoptCard(adoptData: data);
                    }),
              ),
            ])));
  }
}
