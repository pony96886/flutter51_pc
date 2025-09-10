import 'package:chaguaner2023/components/card/V3zhaopiaoCard.dart';
import 'package:chaguaner2023/components/card/reportCard.dart';
import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/list/public_list.dart';
import 'package:chaguaner2023/components/tab/nav_tab_bar_mixin.dart';
import 'package:chaguaner2023/components/tab/tab_nav.dart';
import 'package:chaguaner2023/store/global.dart';
import 'package:chaguaner2023/store/homeConfig.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/index.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:chaguaner2023/utils/pageviewmixin.dart';
import 'package:extended_tabs/extended_tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MineMyTeaPostPage extends StatefulWidget {
  MineMyTeaPostPage({Key? key, this.initTab}) : super(key: key);
  final int? initTab;
  @override
  _MineMyTeaPostPageState createState() => _MineMyTeaPostPageState();
}

class _MineMyTeaPostPageState extends State<MineMyTeaPostPage> with TickerProviderStateMixin {
  ScrollController scrollController = ScrollController();

  TabController? tabController;
  TabController? mangeController;
  int tabsIndex = 0;
  int activeIndex = 0;
  int limit = 10;
  bool loadmore = true;
  int listType = 1;
  bool networkErr = false;
  List tabs = [
    {'title': '发布'},
    {'title': '收藏'},
    {'title': '解锁'},
    {'title': '报告'},
  ];
  List mangeTabs = ['已发报告', '解锁报告'];
  _getNumInfo() async {
    var _number = await getProfilePage();
    Provider.of<GlobalState>(context, listen: false).setProfile(_number!['data']);
    Provider.of<HomeConfig>(context, listen: false).setCoins(_number['data']['coin']);
    Provider.of<HomeConfig>(context, listen: false).setMoney(_number['data']['money']);
    Provider.of<HomeConfig>(context, listen: false).setAgent(_number['data']['agent']);
  }

  @override
  void initState() {
    super.initState();
    tabsIndex = widget.initTab!;
    tabController = new TabController(vsync: this, length: tabs.length, initialIndex: tabsIndex);
    tabController!.addListener(() {
      tabsIndex = tabController!.index;
      setState(() {});
    });

    mangeController = new TabController(vsync: this, length: mangeTabs.length);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    tabController!.dispose();
    mangeController!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var w;
    return HeaderContainer(
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: PreferredSize(
              child: TabBar(
                  controller: tabController,
                  indicatorPadding: EdgeInsets.all(0),
                  labelPadding: EdgeInsets.all(0),
                  indicatorColor: Colors.transparent,
                  tabs: tabs
                      .asMap()
                      .keys
                      .map((key) => CustomTab(tabIndex: tabsIndex, keyIndex: key, title: tabs[key]['title']))
                      .toList()),
              preferredSize: Size.fromHeight(45.w),
            ),
            iconTheme: IconThemeData(
              color: StyleTheme.cTitleColor,
            ),
            actions: <Widget>[
              IconButton(
                padding: EdgeInsets.only(right: 20.0),
                icon: Icon(Icons.arrow_left),
                onPressed: () {},
                iconSize: 30.0,
                color: Colors.transparent,
              )
            ],
            backgroundColor: Colors.transparent,
            elevation: 0,
            systemOverlayStyle: SystemUiOverlayStyle.dark,
          ),
          body: ExtendedTabBarView(
            controller: tabController,
            children: <Widget>[
              PageViewMixin(
                child: PublicList(
                    emitName: 'myPost',
                    isShow: true,
                    limit: 15,
                    isFlow: false,
                    isSliver: false,
                    api: '/api/info/myPost',
                    row: 1,
                    data: {},
                    itemBuild: (context, index, data, page, limit, getListData) {
                      return V3ZhaoPiaoCard(
                          refreshCallBack: () {
                            EventBus().emit('myPost');
                          },
                          deleteCallBack: () {
                            EventBus().emit('myPost');
                          },
                          type: 4,
                          zpInfo: data);
                    }),
              ),
              PageViewMixin(
                child: PublicList(
                    emitName: 'getFavoriteList',
                    isShow: true,
                    limit: 15,
                    isFlow: false,
                    isSliver: false,
                    api: '/api/user/getFavoriteList',
                    row: 1,
                    data: {},
                    itemBuild: (context, index, data, page, limit, getListData) {
                      return V3ZhaoPiaoCard(
                        type: 3,
                        refreshCallBack: () {
                          EventBus().emit('getFavoriteList');
                        },
                        deleteCallBack: () {
                          EventBus().emit('getFavoriteList');
                        },
                        zpInfo: data,
                      );
                    }),
              ),
              Container(
                child: Column(
                  children: [
                    TabNav(
                        rightWidth: 142,
                        leftWidth: 142,
                        setTabState: (val) {
                          listType = val ? 1 : 2;
                          setState(() {});
                        },
                        leftTitle: '未验证',
                        rightTitle: '已验证',
                        rightChild: PageViewMixin(
                          child: PublicList(
                              isShow: true,
                              limit: 15,
                              isFlow: false,
                              isSliver: false,
                              api: '/api/user/myUnlock',
                              data: {'status': 2},
                              row: 1,
                              itemBuild: (context, index, data, page, limit, getListData) {
                                return V3ZhaoPiaoCard(
                                    refreshCallBack: () {}, deleteCallBack: () {}, zpInfo: data, type: 1);
                              }),
                        ),
                        leftChild: PageViewMixin(
                          child: PublicList(
                              isShow: true,
                              limit: 15,
                              isFlow: false,
                              isSliver: false,
                              api: '/api/user/myUnlock',
                              data: {'status': 1},
                              row: 1,
                              itemBuild: (context, index, data, page, limit, getListData) {
                                return V3ZhaoPiaoCard(
                                    refreshCallBack: () {}, deleteCallBack: () {}, zpInfo: data, type: 5);
                              }),
                        )),
                  ],
                ),
              ),
              Column(
                children: [
                  NavTabBarWidget(
                    tabBarHeight: 44.0.w,
                    tabVc: mangeController,
                    isScrollable: false,
                    tabs: mangeTabs.map((e) => e as String).toList(),
                    // containerPadding: EdgeInsets.symmetric(horizontal: 70.w),
                    textPadding: EdgeInsets.symmetric(horizontal: 12.5.w),
                    selectedIndex: mangeController!.index,
                    norTextStyle: TextStyle(color: StyleTheme.cTitleColor, fontSize: 14.sp),
                    selTextStyle: TextStyle(color: Colors.white, fontSize: 14.sp),
                    indicatorStyle: NavIndicatorStyle.cus_icon,
                    indicator: LineIndicator(isCenter: true, width: 75.w, height: 25.w, color: StyleTheme.cDangerColor),
                  ),
                  Expanded(
                      child: ExtendedTabBarView(
                    controller: mangeController,
                    children: [
                      PageViewMixin(
                        child: PublicList(
                            isShow: true,
                            limit: 15,
                            isFlow: false,
                            isSliver: false,
                            api: '/api/info/myConfirmList',
                            data: {},
                            row: 1,
                            itemBuild: (context, index, data, page, limit, getListData) {
                              return ReportCard(reportInfo: data);
                            }),
                      ),
                      PageViewMixin(
                        child: PublicList(
                            isShow: true,
                            limit: 15,
                            isFlow: false,
                            isSliver: false,
                            api: '/api/info/myUnlockConfirmList',
                            data: {},
                            row: 1,
                            itemBuild: (context, index, data, page, limit, getListData) {
                              return ReportCard(reportInfo: data);
                            }),
                      ),
                    ],
                  ))
                ],
              )
            ],
          )),
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
                url: 'assets/images/tabsitem.png',
                alignment: Alignment.center,
                fit: BoxFit.fitWidth,
                width: 50.w,
                height: tabIndex == keyIndex ? 9.w : 0,
              )),
          Text(
            '$title',
            style: TextStyle(
              color: StyleTheme.cTitleColor,
              fontSize: tabIndex == keyIndex ? 17.sp : 14.sp,
            ),
          )
        ],
      ),
    );
  }
}
