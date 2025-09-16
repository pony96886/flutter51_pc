import 'package:chaguaner2023/components/detail_ad.dart';
import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/list/public_list.dart';
import 'package:chaguaner2023/components/page_status.dart';
import 'package:chaguaner2023/components/page_title_bar.dart';
import 'package:chaguaner2023/components/tab/nav_tab_bar_mixin.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:chaguaner2023/utils/pageviewmixin.dart';
import 'package:chaguaner2023/view/homepage/nakedchat/nakedchat_card.dart';
import 'package:chaguaner2023/view/homepage/online_service.dart';
import 'package:chaguaner2023/view/im/im.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:extended_tabs/extended_tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:marquee/marquee.dart';

class NakedChatPage extends StatefulWidget {
  const NakedChatPage({Key? key}) : super(key: key);

  @override
  State<NakedChatPage> createState() => _NakedChatPageState();
}

class _NakedChatPageState extends State<NakedChatPage> with SingleTickerProviderStateMixin {
  List _banner = [];
  ScrollController _scrollViewController = ScrollController();
  bool loading = true;
  String tips = '';
  TabController? tabController;
  List tabs = [];

  @override
  void initState() {
    getTabs();
    super.initState();
  }

  getTabs() {
    getGirlchatTab().then((res) {
      if (res!['status'] != 0) {
        tabs = res['data']['nav_list'];
        _banner = res['data']['banner'];
        tips = res['data']['tips'];
        tabController = TabController(length: tabs.length, vsync: this);
        loading = false;
        setState(() {});
      } else {
        CommonUtils.showText(res['msg']);
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    tabController!.dispose();
    _scrollViewController.dispose();
  }

  bannerWidget() {
    return _banner.length > 0
        ? RepaintBoundary(
            child: Container(
            margin: EdgeInsets.only(top: 5.w, left: 15.w, right: 15.w),
            height: 175.w,
            child: Detail_ad(radius: 18.w, width: ScreenUtil().screenWidth - 30.w, app_layout: true, data: _banner),
          ))
        : SizedBox(height: 0);
  }

  @override
  Widget build(BuildContext context) {
    return HeaderContainer(
        child: Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            children: [
              PageTitleBar(
                title: '裸聊预约',
                rightWidget: GestureDetector(
                  onTap: () {
                    AppGlobal.appRouter?.push(CommonUtils.getRealHash('searchResult'), extra: {'index': 5});
                  },
                  child: Padding(
                    padding: EdgeInsets.only(left: 15.w),
                    child: LocalPNG(
                      url: "assets/images/home/searchicon.png",
                      width: 25.w,
                      height: 25.w,
                    ),
                  ),
                ),
              ),
              Expanded(child: loading ? PageStatus.loading(true) : _buildScrollView())
            ],
          ),
        ),
        Positioned(
            right: 15.w,
            bottom: ScreenUtil().bottomBarHeight + 43.w,
            child: GestureDetector(
              onTap: () {
                if (WebSocketUtility.agent == 2) {
                  AppGlobal.appRouter?.push(CommonUtils.getRealHash('naledChatManage'));
                } else {
                  ServiceParmas.type = 'chat';
                  AppGlobal.appRouter?.push(CommonUtils.getRealHash('onlineServicePage'));
                }
              },
              child: LocalPNG(
                url: WebSocketUtility.agent == 2
                    ? "assets/images/home/nakedchat_gl.png"
                    : "assets/images/home/nakedchat_add.png",
                width: 50.w,
                height: 50.w,
              ),
            ))
      ],
    ));
  }

  Widget _buildScrollView() {
    return ExtendedNestedScrollView(
        physics: ClampingScrollPhysics(),
        controller: _scrollViewController,
        headerSliverBuilder: (BuildContext context, bool b) {
          return [
            SliverToBoxAdapter(
              child: bannerWidget(),
            ),
            SliverToBoxAdapter(
              child: tips.isEmpty
                  ? SizedBox()
                  : Padding(
                      padding: EdgeInsets.only(left: 15.w, right: 15.w, top: 10.w),
                      child: Row(
                        children: [
                          LocalPNG(
                            url: "assets/images/home/icon_notices.png",
                            width: 18.w,
                            height: 18.w,
                          ),
                          SizedBox(
                            width: 4.w,
                          ),
                          Expanded(
                              child: SizedBox(
                            height: 18.w,
                            child: new Marquee(
                              text: tips,
                              style: new TextStyle(color: StyleTheme.cTitleColor, fontSize: 12.sp),
                              scrollAxis: Axis.horizontal,
                            ),
                          ))
                        ],
                      ),
                    ),
            )
          ];
        },
        body: Column(
          children: [
            NavTabBarWidget(
              tabBarHeight: 44.0.w,
              tabVc: tabController,
              tabs: tabs.map((e) => (e['name'] ?? e['title']).toString()).toList(),
              // containerPadding: EdgeInsets.symmetric(horizontal: 70.w),
              textPadding: EdgeInsets.symmetric(horizontal: 6.w),
              selectedIndex: tabController!.index,
              norTextStyle: TextStyle(color: StyleTheme.cTitleColor, fontSize: 14.sp),
              selTextStyle: TextStyle(color: StyleTheme.cTitleColor, fontSize: 18.sp, fontWeight: FontWeight.bold),
              indicatorStyle: NavIndicatorStyle.none,
            ),
            Expanded(
                child: ExtendedTabBarView(
                    controller: tabController,
                    children: tabs.map(
                      (e) {
                        return PageViewMixin(
                          child: PublicList(
                              controller: _scrollViewController,
                              isShow: true,
                              limit: 30,
                              isFlow: false,
                              isSliver: false,
                              api: '/api/girlchat/list',
                              data: {'tag_id': e['id']},
                              row: 2,
                              aspectRatio: 0.74,
                              mainAxisSpacing: 10.w,
                              crossAxisSpacing: 5.w,
                              itemBuild: (context, index, data, page, limit, getListData) {
                                return NakedchtCard(
                                  data: data,
                                );
                              }),
                        );
                      },
                    ).toList()))
          ],
        ));
  }
}
