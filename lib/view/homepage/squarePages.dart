import 'dart:async';
import 'dart:io';
import 'package:bot_toast/bot_toast.dart';
import 'package:chaguaner2023/components/VerticalModalSheet.dart';
import 'package:chaguaner2023/components/appBar/V3SearchAppBar.dart';
import 'package:chaguaner2023/components/card/V3zhaopiaoCard.dart';
import 'package:chaguaner2023/components/card/reportCard.dart';
import 'package:chaguaner2023/components/card/rezhengCard.dart';
import 'package:chaguaner2023/components/card/tzyh.dart';
import 'package:chaguaner2023/components/cgDialog.dart';
import 'package:chaguaner2023/components/detail_ad.dart';
import 'package:chaguaner2023/components/loading.dart';
import 'package:chaguaner2023/components/tab/tab_nav_shuimo.dart';
import 'package:chaguaner2023/store/global.dart';
import 'package:chaguaner2023/store/signInConfig.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/cgprivilege.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/http.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:chaguaner2023/utils/log_utils.dart';
import 'package:chaguaner2023/utils/netimage_tool.dart';
import 'package:chaguaner2023/view/homepage/square/square_list.dart';
import 'package:chaguaner2023/view/im/im.dart';
import 'package:chaguaner2023/view/im/im_page.dart';
import 'package:common_utils/common_utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh_notification/pull_to_refresh_notification.dart';

import '../../utils/cache/image_net_tool.dart';

class SquarePages extends StatefulWidget {
  SquarePages({Key? key}) : super(key: key);

  @override
  _SquarePagesState createState() => _SquarePagesState();
}

class _SquarePagesState extends State<SquarePages> with TickerProviderStateMixin {
  final GlobalKey<PullToRefreshNotificationState> pullKey = GlobalKey<PullToRefreshNotificationState>();
  AnimationController? _animoteLottie;
  ScrollController _scrollViewController = ScrollController();
  double maxDragOffset = 100.w;
  int _selectedTabIndex = 0;
  TabController? _tabController;
  int jpNum = 0; //精品报告数量
  int limit = 10;
  int selectFaceIndex = 0;
  String? cityCode;
  bool loadmore = true;
  List tabList = [];
  bool pageLoading = true; //页面Loading 避免请求菜单时出现异常
  List renzhengData = [];
  List peifuData = [];
  List _banner = [];
  List absList = []; //列表广告
  List _menu = [
    {
      'id': 0,
      'title': '全部',
      'activeWidth': 100.w,
      'inActiveWidth': 100.w,
    }
  ];
  List _tabs = [];
  Map? filterList;
  Map<int, String> apiList = {
    1: '/api/info/getInfoList',
    2: '/api/info/getInfoList',
    3: '/api/goods/listFilter',
    4: '/api/info/confirmList'
  };
  Map<int, Map> parmasList = {
    1: {
      'exclude': {
        'type': [0],
        'post_type': [-1]
      },
      'fixed': {'is_money': 0, 'authentication': 0}
    },
    2: {
      'exclude': {
        'type': [0]
      },
      'fixed': {'is_money': 1, 'authentication': 1}
    },
    4: {
      'fixed': {'auth': 1}
    }
  };
  List _smartTabs = [
    {'title': '最新'},
    {'title': '智能排序'},
    {
      'title': '只看未解锁',
      'api': '/api/goods/getInfoList',
    }
  ];

  intPageState() async {
    _tabController = TabController(vsync: this, length: _tabs.length);
    _animoteLottie = AnimationController(vsync: this);
    intMenu(() async {
      await initHeaderBanner();
      intTabList();
      refreshFc();
      onSignUpList();
      getSystemNotice().then((msg) => {
            if (msg != null && msg['status'] != 0)
              {
                Provider.of<GlobalState>(context, listen: false).setMsgLength(msg['data']['systemNoticeCount'] ??
                    0 + msg['data']['feedCount'] ??
                    0 + msg['data']['groupMessageCount'] ??
                    0)
              }
          });
      CommonUtils.checkStoragePermission();
      _scrollViewController = ScrollController(initialScrollOffset: 0.0);
    });
  }

  getJpNum() {
    intMenu(refreshFc);
  }

  initHeaderBanner() async {
    var result = await getDetail_ad(901);
    if (result != null && result['status'] != 0) {
      _banner = result['data'];
    }
  }

  getTuiJian() {
    renzhengData = [];
    peifuData = [];
    listAuth().then((res) {
      if (res['status'] != 0) {
        renzhengData = res['data'];
        listGuarantee().then((rz) {
          if (rz['status'] != 0) {
            peifuData = rz['data'];
            pageLoading = false;
          } else {
            BotToast.showText(text: res.msg, align: Alignment(0, 0));
          }
          setState(() {});
        });
      } else {
        BotToast.showText(text: res.msg, align: Alignment(0, 0));
      }
    });
  }

  @override
  void initState() {
    super.initState();
    intPageState();
  }

  @override
  void dispose() {
    _animoteLottie!.dispose();
    _scrollViewController.dispose();
    _tabController!.dispose();
    super.dispose();
  }

  // get
  intMenu([Function? callBack]) {
    setState(() {
      pageLoading = true;
    });
    getMenuList().then((res) {
      if (res['status'] != 0) {
        if (res['data']['topTab'].length > 0) {
          tabList = res['data']['topTab'];
          final topTabs = (res['data']?['topTab'] as List ?? [])
              .where((e) => e is Map) // 过滤出符合条件的元素
              .cast<Map>();
          _tabs = []; //初始化菜单
          Future.forEach<Map>(
            topTabs,
            (e) {
              _tabs.add({
                'id': e['id'] ?? '',
                'title': e['title'] ?? '',
                'type': e['type'] ?? '',
                'activeWidth': 90.w,
                'inActiveWidth': 80.w,
              });
            },
          );
          _tabController = TabController(vsync: this, length: _tabs.length);
          //点击tab
          _tabController!.addListener(() {
            _selectedTabIndex = _tabController!.index;
            setState(() {});
          });
          callBack!();
          getTuiJian();
        }
        _tabController!.index = _selectedTabIndex;
      }
    });
  }

  List postTypeList = [
    {'value': -1, 'title': '全部'},
    {'value': 0, 'title': '店家发布'},
    {'value': 1, 'title': '个人分享'}
  ];

  List payoutTypeList = [
    {'value': -1, 'title': '全部'},
    {'value': 0, 'title': '店家发布'},
    {'value': 1, 'title': '楼凤精选'}
  ];

  intTabList() {
    var tabLists = Provider.of<GlobalState>(context, listen: false).infotype;
    if (tabLists.length > 0) {
      tabLists.forEach((e) {
        _menu
            .add({'id': e['id'], 'title': e['title'], 'activeWidth': 100.w, 'inActiveWidth': 100.w, 'type': e['type']});
      });
    }
    // 1 茶友分享 2 赔付专区 3 认证专区 4 精品报告
    filterList = {
      1: {
        'post_type': postTypeList,
        'type': _menu,
        'filter': _smartTabs,
      },
      2: {
        'post_type': payoutTypeList,
        'type': _menu,
        'filter': _smartTabs,
      },
      3: {
        'type': [
          {'title': '茶女郎', 'value': 2},
          {'title': '茶牛郎', 'value': 3},
        ],
        'score': [
          {'value': 'min-100', 'title': '不限'},
          {'value': '60-70', 'title': '60-70分'},
          {'value': '70-80', 'title': '70-80分'},
          {'value': '80-90', 'title': '80-90分'},
          {'value': '90-max', 'title': '90+'}
        ],
        'order': [
          {'title': '热门', 'value': 1},
          {'title': '最新', 'value': 2},
        ]
      },
    };
  }

  _unreadCount() async {
    var msg = await getSystemNotice();
    if (msg != null && msg['status'] != 0) {
      Provider.of<GlobalState>(context, listen: false).setMsgList(msg['data']);
      Provider.of<GlobalState>(context, listen: false).setMsgLength(msg['data']['systemNoticeCount'] ??
          0 + msg['data']['feedCount'] ??
          0 + msg['data']['messageCount'] ??
          0 + msg['data']['groupMessageCount'] ??
          0);
    }
  }

  refreshFc() async {
    getTuiJian();
    var res = await getAds();
    if (res['status'] != 0 && res['data'] != null) {
      absList = res['data'];
    }
    setState(() {});
  }

  // 下拉刷新
  Future<bool> onRefresh() async {
    _unreadCount();
    refreshFc();
    _animoteLottie!.forward();
    return await Future.delayed(const Duration(milliseconds: 2000), () {
      _animoteLottie!.reset();
      return true;
    });
  }

  onSignUpList() async {
    Response signInResult = await PlatformAwareHttp.post('/api/user/getSignUp');
    context.read<SignInConfig>().setData(signInResult.data['data']);
  }

  _onTapHeaderTitle({double toScroll = 1.0}) {
    _scrollViewController.animateTo(toScroll, duration: Duration(milliseconds: 400), curve: Curves.linear);
  }

  Widget buildPulltoRefreshHeader(PullToRefreshScrollNotificationInfo? info) {
    final double offset = info?.dragOffset ?? 0.0;
    return SliverToBoxAdapter(
      child: Container(
        alignment: Alignment.bottomCenter,
        width: double.infinity,
        height: offset,
        child: Stack(
          children: [
            LocalPNG(
              width: double.infinity,
              height: double.infinity,
              url: "assets/images/appbg2.png",
              fit: BoxFit.fitWidth,
              alignment: Alignment(-offset / maxDragOffset, -offset / maxDragOffset),
            ),
            kIsWeb
                ? Container(
                    width: double.infinity,
                    height: offset,
                    alignment: Alignment.bottomCenter,
                    child: LocalPNG(
                      url: 'assets/images/downrefresh.gif',
                      height: offset,
                      fit: BoxFit.fitWidth,
                      call: (duration) {
                        _animoteLottie!.duration = duration;
                        _animoteLottie!.stop();
                      },
                    ),
                  )
                : Lottie.asset(
                    "assets/lottie/pull_refresh/data.json",
                    width: double.infinity,
                    height: offset,
                    fit: BoxFit.contain,
                    controller: _animoteLottie,
                    alignment: Alignment.bottomCenter,
                    filterQuality: FilterQuality.low,
                    onLoaded: (composition) {
                      _animoteLottie!.duration = composition.duration;
                      _animoteLottie!.stop();
                    },
                  ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Container(
        color: Colors.transparent,
        child: Stack(
          children: [
            LocalPNG(
                height: 250.w,
                url: "assets/images/home/squarebg.png",
                fit: BoxFit.fitWidth,
                alignment: Alignment.topLeft),
            Scaffold(
              appBar: PreferredSize(
                  child: Padding(
                    padding: EdgeInsets.only(top: kIsWeb ? 0 : 15.w, bottom: kIsWeb ? 5.w : 0),
                    child: V3SearchAppBarWidget(
                      isHidden: true,
                      callBack: (areaCode) {
                        cityCode = areaCode.toString();
                        getJpNum();
                      },
                      tapSearch: () {
                        AppGlobal.appRouter?.push(CommonUtils.getRealHash('searchResult'));
                      },
                      tapFilter: () {
                        VerticalModalSheet.show(
                            context: context, child: tabsContainer(), direction: VerticalModalSheetDirection.TOP);
                      },
                      tapTitle: _onTapHeaderTitle,
                    ),
                  ),
                  preferredSize: Size.fromHeight(ScreenUtil().statusBarHeight + (kIsWeb ? 50.w : 20.w))),
              backgroundColor: Colors.transparent,
              body: PullToRefreshNotification(
                // pullBackOnRefresh: true,
                onRefresh: onRefresh,
                maxDragOffset: maxDragOffset,
                armedDragUpCancel: false,
                key: pullKey,
                child: NestedScrollView(
                    physics: ClampingScrollPhysics(),
                    controller: _scrollViewController,
                    headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                      return [
                        PullToRefreshContainer((PullToRefreshScrollNotificationInfo? e) {
                          return buildPulltoRefreshHeader(e);
                        }),
                        SliverAppBar(
                          leading: Container(),
                          pinned: false,
                          elevation: 0,
                          backgroundColor: Colors.transparent,
                          expandedHeight: ScreenUtil().setWidth(100 +
                              (_banner.length == 0 ? 0 : 175) +
                              (renzhengData.length > 0 ? 135 : 0) +
                              (peifuData.length > 0 ? 135 : 0)),
                          flexibleSpace: FlexibleSpaceBar(
                            collapseMode: CollapseMode.parallax,
                            background: Column(
                              children: [
                                _banner.length > 0
                                    ? RepaintBoundary(
                                        child: Container(
                                        margin: EdgeInsets.only(top: 5.w, left: 15.w, right: 15.w),
                                        height: 175.w,
                                        child: Detail_ad(
                                            radius: 18.w,
                                            width: ScreenUtil().screenWidth - 30.w,
                                            height: 175.w,
                                            app_layout: true,
                                            data: _banner),
                                      ))
                                    : SizedBox(height: 0),
                                _menuView(),
                                renzhengData.length > 0
                                    ? tuijianList('认证茶女郎&茶铺推荐', 'renzheng', renzhengData)
                                    : Container(),
                                peifuData.length > 0 ? tuijianList('赔付资源推荐', 'peifu', peifuData) : Container()
                              ],
                            ),
                          ),
                          excludeHeaderSemantics: true,
                          systemOverlayStyle: SystemUiOverlayStyle.dark,
                        ),
                      ];
                    },
                    body: pageLoading
                        ? Loading()
                        : Column(
                            children: [
                              TabNavShuimo(
                                bgColor: true,
                                tabs: _tabs,
                                tabController: _tabController,
                                selectedTabIndex: _selectedTabIndex,
                              ).build(context),
                              Expanded(
                                  child: filterList == null
                                      ? Loading()
                                      : TabBarView(
                                          controller: _tabController,
                                          children: _tabs.asMap().keys.map((e) {
                                            dynamic _id = _tabs[e]['id'];
                                            return SquareList(
                                                ads: _id == 1 ? absList : null, //茶友分享插入广告
                                                api: apiList[_id],
                                                tabList: filterList![_id] ?? {},
                                                filter: parmasList[_id],
                                                row: _id == 3 ? 2 : 1,
                                                id: _id,
                                                aspectRatio: 0.7,
                                                mainAxisSpacing: 5.w,
                                                crossAxisSpacing: 5.w,
                                                build: (Map data) {
                                                  return getCardType(_id, data);
                                                });
                                          }).toList()))
                            ],
                          )),
              ),
              bottomNavigationBar: BottomAppBar(
                child: Container(
                  color: Colors.white,
                  height: kIsWeb
                      ? 25.w
                      : Platform.isAndroid
                          ? 55.w
                          : 25.w,
                ),
              ),
              floatingActionButton: Padding(
                padding: EdgeInsets.only(bottom: kIsWeb ? AppGlobal.webBottomHeight + 20.w : 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SignInFloatingButton(),
                    ChaXiaoWaiButton(
                      uuid: UserInfo.serviceUuid,
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget tianzi() {
    var vipClub = Provider.of<GlobalState>(context).profileData?['vip_club'] ?? 0;
    return TianZiYiHao(vipClub: vipClub);
  }

  Widget tabsContainer() {
    return Container();
  }

  Widget tuijianList(String? title, String? type, List? dataList) {
    return Padding(
      padding: EdgeInsets.only(top: 15.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 15.w, right: 15.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LocalPNG(width: 15.w, height: 15.w, url: 'assets/images/tuijian-icon.png', fit: BoxFit.cover),
                    SizedBox(
                      width: 5.5.w,
                    ),
                    Text(
                      title!,
                      style: TextStyle(fontSize: 15.sp, color: StyleTheme.cTitleColor, fontWeight: FontWeight.w500),
                    )
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    // _onTapHeaderTitle(toScroll: 550.w);
                    if (type == 'renzheng') {
                      AppGlobal.appRouter?.push(CommonUtils.getRealHash('authenticationList'));
                      // _selectedTabIndex =
                      //     tabList.indexWhere((v) => v['id'] == 3);
                      // _tabController?.animateTo(_selectedTabIndex);
                    } else {
                      AppGlobal.appRouter?.push(CommonUtils.getRealHash('payoutList'));
                      // _selectedTabIndex =
                      //     tabList.indexWhere((v) => v['id'] == 2);
                      // _tabController?.animateTo(_selectedTabIndex);
                    }
                    // setState(() {});
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '更多',
                        style: TextStyle(
                          color: Color(0xff969696),
                          fontSize: 12.sp,
                        ),
                      ),
                      Container(
                        width: 6.w,
                        height: 11.w,
                        margin: EdgeInsets.only(left: 5.5.w),
                        child:
                            LocalPNG(width: 6.w, height: 11.w, url: 'assets/images/right-icon.png', fit: BoxFit.cover),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 19.w),
            height: 82.w,
            child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: ClampingScrollPhysics(),
                padding: EdgeInsets.only(left: 30.w),
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      if (type == 'renzheng') {
                        AppGlobal.appRouter?.push(CommonUtils.getRealHash('gilrDrtailPage/' +
                            dataList![index]['id'].toString() +
                            '/' +
                            dataList[index]['type'].toString()));
                      } else {
                        AppGlobal.appRouter?.push(CommonUtils.getRealHash(
                            'resourcesDetailPage/null/' + dataList![index]['id'].toString() + '/null/null/null'));
                      }
                    },
                    child: recommendCard(
                        dataList![index]['title'],
                        dataList[index]['price'].toString(),
                        type == 'renzheng'
                            ? (dataList[index]['resources'].length == 0 ? '' : dataList[index]['resources'][0]['url'])
                            : (dataList[index]['pic'].length == 0 ? '' : dataList[index]['pic'][0]['url']),
                        type == 'renzheng' ? dataList[index]['girl_face'].toString() : null,
                        (dataList[index]['type'] ?? 0),
                        dataList[index]['status'].toString()),
                  );
                },
                separatorBuilder: (BuildContext context, int index) => Container(
                      width: 5.w,
                    ),
                itemCount: dataList!.length),
          )
        ],
      ),
    );
  }

  Widget recommendCard(String? title, String? fee, String url, String? girlFace, int type, String girlStatus) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: Container(
        width: 110.w,
        height: 82.w,
        child: Stack(
          children: [
            ImageNetTool(
              url: url,
              fit: BoxFit.cover,
            ),
            Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  height: 48.5.w,
                  padding: EdgeInsets.symmetric(vertical: 4.5.w, horizontal: 6.5.w),
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                    colors: [Colors.black54, Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  )),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        title!,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      fee == 'null'
                          ? Container()
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(top: 3.5.w),
                                  padding: EdgeInsets.symmetric(horizontal: 4.5.w),
                                  height: 11.w,
                                  decoration:
                                      BoxDecoration(borderRadius: BorderRadius.circular(3), color: Color(0xffdbc1a0)),
                                  child: Center(
                                    child: Container(
                                        constraints: BoxConstraints(maxWidth: 87.w),
                                        child: Text(
                                          fee!,
                                          style: TextStyle(fontSize: 8.sp, color: Colors.white),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        )),
                                  ),
                                )
                              ],
                            )
                    ],
                  ),
                )),
            type == 2
                ? Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      height: 17.w,
                      padding: EdgeInsets.symmetric(horizontal: 3.w),
                      decoration: BoxDecoration(
                          color: Color(0xffee4257), borderRadius: BorderRadius.only(bottomLeft: Radius.circular(5))),
                      child: Center(
                        child: Text.rich(
                            TextSpan(text: '颜值:', style: TextStyle(color: Colors.white, fontSize: 10.sp), children: [
                          TextSpan(
                            text: girlFace,
                            style: TextStyle(color: Color(0xffffff96), fontSize: 10.sp),
                          ),
                          TextSpan(
                            text: '分',
                            style: TextStyle(color: Colors.white, fontSize: 10.sp),
                          )
                        ])),
                      ),
                    ))
                : Container(),
            girlStatus == '5'
                ? Positioned(
                    top: 5.w,
                    left: 5.w,
                    child: LocalPNG(width: 36.w, height: 13.w, url: 'assets/images/xiuxi.png', fit: BoxFit.cover))
                : Container()
          ],
        ),
      ),
    );
  }

  Widget _menuView() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.only(top: 10.w, left: 10.w, right: 10.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          
          MenuCard(
              onTap: () {
                AppGlobal.appRouter?.push(CommonUtils.getRealHash('cgmallPage'));
              },
              image: "assets/images/home/cgmallbg.png"),
          MenuCard(
              onTap: () {
                AppGlobal.appRouter?.push(CommonUtils.getRealHash('adoptPage'));
              },
              image: "assets/images/home/adopt.png"),
          MenuCard(
              onTap: () {
                AppGlobal.appRouter?.push(CommonUtils.getRealHash('cgrankPage'));
              },
              image: "assets/images/home/rankbg.png"),
          AppGlobal.enableGirlChat == 1
              ? MenuCard(
                  onTap: () {
                    AppGlobal.appRouter?.push(CommonUtils.getRealHash('nakedChat'));
                  },
                  image: "assets/images/home/nakedchat.png")
              : SizedBox(),
          MenuCard(
              onTap: () {
                AppGlobal.appRouter?.push(CommonUtils.getRealHash('talkListPage'));
              },
              image: "assets/images/home/teataklbg.png"),
          MenuCard(
              onTap: () {
                AppGlobal.appRouter?.push(CommonUtils.getRealHash('reportPage'));
              },
              image: "assets/images/home/reportbg.png"),
          MenuCard(
              onTap: () {
                AppGlobal.appRouter?.push(CommonUtils.getRealHash('teaBlackList'));
              },
              image: "assets/images/home/blackrankbg.png"),
          // MenuCard(
          //     onTap: () {
          //       AppGlobal.appRouter
          //           .push(CommonUtils.getRealHash('toBeVerifiedPage'));
          //     },
          //     image: "assets/images/home/waitcertifibg.png"),
        ],
      ),
    );
  }

  Widget getCardType(int id, Map data) {
    if (id != 4) {
      // 认证区妹子
      if (id == 3) {
        return RenZhengCard(chapuData: data);
      }
      //招嫖卡片
      return V3ZhaoPiaoCard(
        isPeifu: id == 2,
        zpInfo: data,
      );
    } else {
      //精品报告
      return ReportCard(reportInfo: data);
    }
  }
}

class GameButton extends StatelessWidget {
  GameButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AppGlobal.appRouter?.push(CommonUtils.getRealHash('games'));
      },
      child: SizedBox(
        width: 65.w,
        height: 62.5.w,
        child: ImageNetTool(
          fit: BoxFit.contain,
          url: UserInfo.gameIconUrl!,
        ),
      ),
    );
  }
}

class SignInFloatingButton extends StatelessWidget {
  SignInFloatingButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int? dayvalue = Provider.of<SignInConfig>(context).days;
    return (dayvalue ?? 0) >= 15
        ? SizedBox()
        : Padding(
            padding: EdgeInsets.symmetric(vertical: 10.w),
            child: FloatingActionButton(
                //悬浮按钮
                // elevation: 0,
                backgroundColor: Colors.transparent,
                heroTag: 'signin',
                child: LocalPNG(
                    url: "assets/images/sign/floating-button.png", alignment: Alignment.center, fit: BoxFit.contain),
                onPressed: () {
                  AppGlobal.appRouter?.push(CommonUtils.getRealHash('myMonyPage'));
                  // showDialog(
                  //   context: context,
                  //   builder: (_) => SignInPage(),
                  // );
                }),
          );
  }
}

class ChaXiaoWaiButton extends StatelessWidget {
  final String? uuid;
  final bool isXiaowai;
  ChaXiaoWaiButton({Key? key, this.uuid, this.isXiaowai = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String cyStr = 'chaxiaowai';
    String zxKfStr = 'zaixiankefu';
    String levAssStr = isXiaowai ? cyStr : zxKfStr;

    return GestureDetector(
      onTap: () {
        if (isXiaowai) {
          if (CgPrivilege.getPrivilegeStatus(PrivilegeType.infoSystem, PrivilegeType.privilegeDedicated)) {
            if (WebSocketUtility.imToken == null) {
              CommonUtils.getImPath(context, callBack: () {
                AppGlobal.chatUser = FormUserMsg(isVipDetail: true, uuid: uuid!, nickname: '茶小歪', avatar: 'chaxiaowai');
                AppGlobal.appRouter?.push(CommonUtils.getRealHash('llchat'));
              });
            } else {
              AppGlobal.chatUser = FormUserMsg(isVipDetail: true, uuid: uuid!, nickname: '茶小歪', avatar: 'chaxiaowai');
              AppGlobal.appRouter?.push(CommonUtils.getRealHash('llchat'));
            }
          } else {
            CgDialog.cgShowDialog(context, '温馨提示', '请前往开通会员', ['取消', '确认'], callBack: () {
              AppGlobal.appRouter?.push(CommonUtils.getRealHash('memberCardsPage'));
            });
          }
        } else {
          AppGlobal.appRouter?.push(CommonUtils.getRealHash('onlineServicePage'));
        }
      },
      behavior: HitTestBehavior.translucent,
      child: Container(
        margin: EdgeInsets.only(bottom: 20.w),
        width: 67.7.w,
        height: 84.3.w,
        child: LocalPNG(
            width: 67.7.w,
            height: 84.3.w,
            url: "assets/images/home/$levAssStr.png",
            alignment: Alignment.center,
            fit: BoxFit.contain),
      ),
    );
  }
}

class MenuCard extends StatelessWidget {
  final String? image;
  final GestureTapCallback? onTap;
  const MenuCard({Key? key, this.image, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 5.w),
        decoration: BoxDecoration(
          color: Colors.transparent,
        ),
        child: Column(children: <Widget>[
          LocalPNG(
            url: image,
            width: 75.w,
            height: 75.w,
          ),
        ]),
      ),
    );
  }
}

class TabsContainer extends StatefulWidget {
  final List? tabs;
  final int? selectTabIndex;
  final Function? onTabs;
  final bool? needLimit;
  final int? filter;
  TabsContainer({Key? key, this.tabs, this.selectTabIndex, this.onTabs, this.needLimit = false, this.filter})
      : super(key: key);

  @override
  _TabsContainerState createState() => _TabsContainerState();
}

class _TabsContainerState extends State<TabsContainer> {
  int? index;

  @override
  void initState() {
    super.initState();
    index = widget.selectTabIndex;
  }

  onTapTabsItem(int vipValue, int e) {
    // if (widget.needLimit && vipValue == 0 && e == 1) {
    //   BotToast.showText(text: '只有会员才能使用智能排序', align: Alignment(0, 0));
    //   return;
    // }
    setState(() {
      index = e;
    });
    widget.onTabs!(e);
  }

  @override
  void didUpdateWidget(covariant TabsContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectTabIndex != index) {
      index = widget.selectTabIndex;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    var vipValue;
    var profile = Provider.of<GlobalState>(context).profileData;
    if (["", null, false, 0].contains(profile)) {
      vipValue = 0;
    } else {
      vipValue = profile?['vip_level'];
    }
    return Container(
      child: Row(
        children: widget.tabs!.asMap().keys.map((e) {
          if (widget.filter == null) {
            return TabsItem(
              title: widget.tabs![e]['title'],
              index: index!,
              keys: e,
              onTap: () {
                onTapTabsItem(vipValue, e);
              },
            );
          } else {
            return widget.tabs![e]['type'] == widget.filter || widget.tabs![e]['type'] == null
                ? TabsItem(
                    title: widget.tabs![e]['title'],
                    index: index!,
                    keys: e,
                    onTap: () {
                      onTapTabsItem(vipValue, e);
                    },
                  )
                : const SizedBox();
          }
        }).toList(),
      ),
    );
  }
}

class TabsItem extends StatelessWidget {
  final String? title;
  final int? index;
  final int? keys;
  final GestureTapCallback? onTap;
  TabsItem({Key? key, this.title, this.index, this.onTap, this.keys}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(right: 21.5.w),
        child: Stack(
          children: <Widget>[
            Positioned(
                top: 0,
                right: 0,
                child: index == keys
                    ? Opacity(
                        opacity: 0.8,
                        child: Container(
                          width: 12.w,
                          height: 12.w,
                          decoration:
                              BoxDecoration(color: StyleTheme.cDangerColor, borderRadius: BorderRadius.circular(10)),
                        ),
                      )
                    : SizedBox()),
            Text("$title",
                style: index == keys
                    ? TextStyle(color: Color(0xff646464), fontSize: 12.sp, fontWeight: FontWeight.w700)
                    : TextStyle(color: Color(0xff646464), fontSize: 12.sp)),
          ],
        ),
      ),
    );
  }
}
