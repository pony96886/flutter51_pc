import 'dart:io';
import 'dart:math';
import 'package:bot_toast/bot_toast.dart';
import 'package:chaguaner2023/components/VerticalModalSheet.dart';
import 'package:chaguaner2023/components/appBar/V3ElegentAppBar.dart';
import 'package:chaguaner2023/components/card/elegantCard.dart';
import 'package:chaguaner2023/components/cgDialog.dart';
import 'package:chaguaner2023/components/detail_ad.dart';
import 'package:chaguaner2023/components/loading.dart';
import 'package:chaguaner2023/components/nodata.dart';
import 'package:chaguaner2023/store/global.dart';
import 'package:chaguaner2023/store/sharedPreferences.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/cgprivilege.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/index.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:chaguaner2023/utils/netimage_tool.dart';
import 'package:chaguaner2023/view/homepage/squarePages.dart';
import 'package:chaguaner2023/view/im/im.dart';
import 'package:chaguaner2023/view/im/im_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh_notification/pull_to_refresh_notification.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

class ElegantRoomPages extends StatefulWidget {
  ElegantRoomPages({Key? key}) : super(key: key);

  @override
  _ElegantRoomPagesState createState() => _ElegantRoomPagesState();
}

class _ElegantRoomPagesState extends State<ElegantRoomPages> with TickerProviderStateMixin {
  final GlobalKey<PullToRefreshNotificationState> key = GlobalKey<PullToRefreshNotificationState>();
  AnimationController? _animoteLottie;
  ScrollController _elegantController = ScrollController();
  int _selectedTabIndex = 0;
  double maxDragOffset = 100.w;
  bool isIntTab = false;
  bool networkErr = false;
  int limit = 10;
  bool isClick = false;
  int? oderId;
  int _ageTabIndex = 0;
  int _heightTabIndex = 0;
  int _cupTabIndex = 0;
  int _priceTabIndex = 0;
  bool loading = true;
  bool loadmore = true;
  bool isShow = false;
  List _banner = [];
  List _tagsList = [];
  List resourcesDataList = [
    {'data': null, 'page': 1, 'code': e, 'loading': true, 'isAll': false, 'pageLoading': false}
  ];
  List _tabs = [];
  List<String> _selectTags = [];
  List<int> _selectIndex = [];
  Map? _filterOption;
  Map _options = {'age': 0, 'height': 0, 'cup': 0, 'price': 0, 'video_valid': 0, 'rule': 1, 'postType': 1};
  int unConfirm = 0;
  int unComment = 0;
  int _typeListValue = 0;
  int _ruleListValue = 0;
  int _videoValidValue = 0;

  List typeList = [
    {"name": "高端外围", "value": 1},
    {"name": "高端男模", "value": 2},
  ];

  List ruleList = [
    {"name": "综合排序", "value": 1},
    {"name": "预约最多", "value": 2},
    {"name": "评价最高", "value": 3},
    {"name": "随机排序", "value": 5}, //5走另外的接口
    {"name": "最新", "value": 4},
  ];
  List videoValid = [
    {"name": "全部", "value": 0},
    {"name": "只看视频认证", "value": 1},
  ];

  getTagsList() async {
    if (['', null, false].contains(_tagsList) || ['', null, false].contains(_filterOption)) {
      BotToast.showLoading();
      Map? result2 = await getFilterOption();
      Map? result = await getTags();
      BotToast.closeAllLoading();
      PersistentState.saveState('isFirstUse', '1');
      setState(() {
        isShow = false;
      });
      if (result2!['status'] != 0) {
        setState(() {
          _filterOption = result2['data'];
        });
      }
      if (result!['status'] != 0 && result['data'].length != 0) {
        _tagsList = result['data'];
        setState(() {});
      }
      VerticalModalSheet.show(context: context, child: tabsContainer(), direction: VerticalModalSheetDirection.TOP);
    } else {
      VerticalModalSheet.show(context: context, child: tabsContainer(), direction: VerticalModalSheetDirection.TOP);
    }
  }

  _onInitMyAppointment() async {
    var result = await getMyAppointmentNum();
    if (result!['status'] == 1) {
      setState(() {
        unComment = result['data']['unComment'];
        unConfirm = result['data']['unConfirm'];
      });
    }
  }

  getCityList() async {
    try {
      var citylist = await getVipCityListc();
      if (citylist!['data'].length != 0 && citylist['status'] != 0) {
        // tab和列表去重
        var _set = new Set();
        var _dataList = new Set();
        citylist['data'].forEach((e) => {
              _dataList
                  .add({'data': null, 'page': 1, 'code': e, 'loading': true, 'isAll': false, 'pageLoading': false}),
              _set.add({
                'code': e,
              }),
            });
        setState(() {
          loading = true;
          _tabs = _set.toList();
          resourcesDataList = _dataList.toList();
        });
        if (resourcesDataList[_selectedTabIndex]['data'] == null) {
          intPageData();
        }
        setState(() {
          isIntTab = true;
        });
      } else {
        setState(() {
          loading = false;
        });
      }
    } catch (err) {}
  }

  initHeaderBanner() async {
    var result = await getDetail_ad(1001);
    if (result != null && result['status'] != 0) {
      _banner = result['data'];
      setState(() {});
    }
  }

  initElegantTips() {
    PersistentState.getState('isFirstUse').then((value) {
      setState(() {
        isShow = (value == null);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    initElegantTips();
    getCityList();
    _elegantController = ScrollController(initialScrollOffset: 0.0);
    _animoteLottie = AnimationController(vsync: this);
    initHeaderBanner();
    _onInitMyAppointment();
    EventBus().on('updateElegantCityList', (arg) {
      getCityList();
    });
  }

  @override
  void dispose() {
    _elegantController.dispose();
    _animoteLottie!.dispose();
    super.dispose();
  }

  Future<bool> onRefresh() async {
    _animoteLottie!.forward();
    Future.forEach(
        resourcesDataList,
        (dynamic element) => {
              element['data'] = null,
              element['page'] = 1,
              element['loading'] = true,
              element['isAll'] = false,
            });
    loading = true;
    loadmore = false;
    setState(() {});
    intPageData();
    _onInitMyAppointment();
    return await Future<bool>.delayed(Duration(seconds: 2), () {
      return true;
    });
  }

  intPageData() async {
    var vipInfo;
    String? cityCode = Provider.of<GlobalState>(context, listen: false).cityCode;

    if (_options['rule'] == 5) {
      vipInfo = await filterVipInfo(
        page: resourcesDataList.length > 0 ? resourcesDataList[_selectedTabIndex]['page'] : 1,
        limit: limit,
        postType: _options['postType'],
        cityCode: cityCode != null ? cityCode.toString() : '110100',
        age: _options['age'] == null ? "0" : _options['age'].toString(),
        height: _options['height'] == null ? "0" : _options['height'].toString(),
        cup: _options['cup'] == null ? "0" : _options['cup'].toString(),
        price: _options['price'] == null ? "0" : _options['price'].toString(),
        tags: _selectIndex,
        videoValid: _options['video_valid'] == null ? "0" : _options['video_valid'].toString(),
      );
    } else {
      vipInfo = await filterVipInfoByRule(
        page: resourcesDataList.length > 0 ? resourcesDataList[_selectedTabIndex]['page'] : 1,
        limit: limit,
        postType: _options['postType'],
        cityCode: cityCode != null ? cityCode.toString() : '110100',
        age: _options['age'] == null ? "0" : _options['age'].toString(),
        height: _options['height'] == null ? "0" : _options['height'].toString(),
        cup: _options['cup'] == null ? "0" : _options['cup'].toString(),
        price: _options['price'] == null ? "0" : _options['price'].toString(),
        tags: _selectIndex,
        videoValid: _options['video_valid'] == null ? "0" : _options['video_valid'].toString(),
        rule: _options['rule'] == null ? "1" : _options['rule'].toString(),
      );
    }
    if (vipInfo == null) {
      setState(() {
        networkErr = true;
      });
      return;
    }
    if (resourcesDataList[_selectedTabIndex]['page'] == 1) {
      List topCityList = [];
      var topVipResult = await getVipTopList(citycode: cityCode!, postType: _options['postType']);
      if (topVipResult!['status'] != 0) {
        if (topVipResult['data'] != null && topVipResult['data'] is List) {
          topCityList.addAll(topVipResult["data"]);
        }
      }
      if (vipInfo != null) {
        if (vipInfo['status'] != 0) {
          if (_tabs.length > 0) {
            Future.delayed(Duration(seconds: 1), () {
              setState(() {
                resourcesDataList[_selectedTabIndex]['loading'] = false;
              });
            });
          }
          List vipInfoList = [];
          if (vipInfo['data'] != null && vipInfo['data'] is List) {
            if (topCityList.isNotEmpty) {
              vipInfo['data'].insertAll(0, [...topCityList]);
            }
            vipInfoList = vipInfo['data'];
          }
          setState(() {
            resourcesDataList[_selectedTabIndex]['data'] = vipInfoList;
            loadmore = true;
            networkErr = false;
          });
        } else {
          BotToast.showText(
              text: vipInfo['msg'] == null || vipInfo['msg'] == "" ? "服务器异常，请稍后重试" : vipInfo['msg'],
              align: Alignment(0, 0));
        }
      }
      if (vipInfo['data'] != null && vipInfo['data'].length < limit) {
        setState(() {
          resourcesDataList[_selectedTabIndex]['isLoading'] = false;
          resourcesDataList[_selectedTabIndex]['isAll'] = true;
          loadmore = true;
          networkErr = false;
        });
      }
    } else {
      if (vipInfo['status'] != 0 && vipInfo['data'] != null && vipInfo['data'].length > 0) {
        setState(() {
          resourcesDataList[_selectedTabIndex]['data'].addAll(vipInfo['data']);
          loadmore = true;
          networkErr = false;
        });
      } else {
        setState(() {
          resourcesDataList[_selectedTabIndex]['isLoading'] = false;
          resourcesDataList[_selectedTabIndex]['isAll'] = true;
          loadmore = false;
        });
      }
    }
  }

  _onScrollNotification(ScrollNotification scrollInfo) {
    if (resourcesDataList[_selectedTabIndex] == [] || resourcesDataList[_selectedTabIndex] == null) return;
    if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
      //滑到了底部
      if (loadmore) {
        if (!resourcesDataList[_selectedTabIndex]['isAll']) {
          setState(() {
            resourcesDataList[_selectedTabIndex]['page']++;
            resourcesDataList[_selectedTabIndex]['isLoading'] = true;
          });
          intPageData();
        }
        setState(() {
          loadmore = false;
        });
      }
    }
    return false;
  }

  void showText(text) {
    BotToast.showText(text: '$text', align: Alignment(0, 0));
  }

  toLlIm(String uuid, String nickname, String thumb) {
    if (WebSocketUtility.imToken == null) {
      CommonUtils.getImPath(context, callBack: () {
        //跳转IM
        AppGlobal.chatUser =
            FormUserMsg(uuid: uuid.toString(), nickname: nickname.toString(), avatar: thumb.toString());
        AppGlobal.appRouter?.push(CommonUtils.getRealHash('llchat'));
      });
    } else {
      //跳转IM
      AppGlobal.chatUser = FormUserMsg(uuid: uuid.toString(), nickname: nickname.toString(), avatar: thumb.toString());
      AppGlobal.appRouter?.push(CommonUtils.getRealHash('llchat'));
    }
  }

  getCurrentStatus() async {
    var res = await getCurrentRequireStatus();
    if (res!['status'] != 0) {
      var curStatus = res['data']['status'];
      if (curStatus == 1) {
        //意向单
        oderId = res['data']['id'];
        AppGlobal.appRouter?.push(CommonUtils.getRealHash('teaTastingIntention/' + oderId.toString()));
      } else if (curStatus == 2 || curStatus == 3) {
        AppGlobal.chatUser = FormUserMsg(
            uuid: res['data']['uuid'].toString(),
            nickname: res['data']['nickname'].toString(),
            avatar: res['data']['thumb'].toString());
        AppGlobal.appRouter?.push(CommonUtils.getRealHash('llchat'));
        //跳转Im
      } else {
        AppGlobal.appRouter?.push(CommonUtils.getRealHash('teaTastingIntention/null'));
      }
      isClick = false;
    } else {
      showText(res['msg'] == null ? '网络错误' : res['msg']);
    }
  }

  _onChangeTabs(dynamic value) {
    var tabIndex = 0;
    var element = _tabs.firstWhere((i) => i['code'] == value['code'], orElse: () => null);
    if (element == null) {
      _tabs.add({
        'code': value['code'],
      });
      resourcesDataList
          .add({'data': null, 'page': 1, 'code': value['code'], 'loading': true, 'isAll': false, 'pageLoading': false});
      _tabs.toList();
      resourcesDataList.toList();
      var elementSec = _tabs.firstWhere((i) => i['code'] == value['code'], orElse: () => null);
      tabIndex = _tabs.indexOf(elementSec);
      // print(tabIndex);
    } else {
      tabIndex = _tabs.indexOf(element);
    }
    setState(() {
      _selectedTabIndex = tabIndex < 0 ? 0 : tabIndex;
      resourcesDataList[tabIndex]['loading'] = true; //_selectedTabIndex
      loadmore = true;
      _options = {'age': 0, 'height': 0, 'cup': 0, 'price': 0, 'video_valid': 0, 'rule': 1, 'postType': 1};
      _selectIndex = [];
      _selectTags = [];
      _typeListValue = 0;
      _ageTabIndex = 0;
      _heightTabIndex = 0;
      _cupTabIndex = 0;
      _priceTabIndex = 0;
      _videoValidValue = 0;
      _ruleListValue = 0;
    });
    if (resourcesDataList[tabIndex]['data'] == null || resourcesDataList[tabIndex]['data'] == []) {
      intPageData();
    } else {
      Future.delayed(Duration(seconds: 1), () {
        setState(() {
          resourcesDataList[tabIndex]['loading'] = false;
        });
      });
    }
  }

  void _onFilterOption(List option, int e, String key) {
    _options[key] = option[e]['value'];
  }

  void _onFilterRule(int e, String key) {
    _options[key] = e;
    if (resourcesDataList[_selectedTabIndex]['data'].isEmpty ||
        resourcesDataList[_selectedTabIndex]['data'].length > 3) {
      _elegantController.animateTo(250.w, duration: Duration(milliseconds: 400), curve: Curves.linear);
    }
    loading = true;
    loadmore = true;
    networkErr = false;
    for (var i = 0; i < resourcesDataList.length; i++) {
      resourcesDataList[i]['data'] = null;
      resourcesDataList[i]['page'] = 1;
      resourcesDataList[i]['loading'] = true;
      resourcesDataList[i]['isAll'] = false;
      resourcesDataList[i]['pageLoading'] = false;
    }
    setState(() {});
    intPageData();
  }

  void _filterOptionsSubmit() {
    _selectIndex = [];
    if (_selectTags.length > 0) {
      for (var i = 0; i < _selectTags.length; i++) {
        var element = _tagsList.firstWhere((l) => l['name'] == _selectTags[i], orElse: () => null);
        if (element != null) {
          var index = _tagsList.indexOf(element);
          _selectIndex.add(_tagsList[index]['id']);
        }
      }
    }
    loading = true;
    loadmore = true;
    networkErr = false;

    for (var i = 0; i < resourcesDataList.length; i++) {
      resourcesDataList[i]['data'] = null;
      resourcesDataList[i]['page'] = 1;
      resourcesDataList[i]['loading'] = true;
      resourcesDataList[i]['isAll'] = false;
    }
    setState(() {});
    intPageData();
  }

  showBuy(String title, String content, int type, [String? btnText]) {
    showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 280.w,
            padding: new EdgeInsets.symmetric(vertical: 15.w, horizontal: 25.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Center(
                      child: Text(
                        title,
                        style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 18.sp, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                        margin: new EdgeInsets.only(top: 20.w),
                        child: Text(
                          content,
                          style: TextStyle(fontSize: 14.w, color: StyleTheme.cTitleColor),
                        )),
                    type == 0
                        ? GestureDetector(
                            onTap: () => {
                                  context.pop(),
                                },
                            child: GestureDetector(
                              onTap: () {
                                /**[去充值会员]**/
                                Navigator.pop(context);
                                if (btnText != '知道了') {
                                  AppGlobal.appRouter?.push(CommonUtils.getRealHash('memberCardsPage'));
                                }
                              },
                              child: Container(
                                margin: new EdgeInsets.only(top: 30.w),
                                height: 50.w,
                                width: 200.w,
                                child: Stack(
                                  children: [
                                    LocalPNG(
                                      height: 50.w,
                                      width: 200.w,
                                      url: 'assets/images/mymony/money-img.png',
                                    ),
                                    Center(
                                        child: Text(
                                      btnText ?? '去开通',
                                      style: TextStyle(fontSize: 15.sp, color: Colors.white),
                                    )),
                                  ],
                                ),
                              ),
                            ))
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                                child: Container(
                                  margin: new EdgeInsets.only(top: 30.w),
                                  height: 50.w,
                                  width: 110.w,
                                  child: Stack(
                                    children: [
                                      LocalPNG(
                                        url: 'assets/images/mymony/money-img.png',
                                        height: 50.w,
                                        width: 110.w,
                                      ),
                                      Center(
                                          child: Text(
                                        '取消',
                                        style: TextStyle(fontSize: 15.w, color: Colors.white),
                                      )),
                                    ],
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pop(true);
                                },
                                child: Container(
                                  margin: new EdgeInsets.only(top: 30.w),
                                  height: 50.w,
                                  width: 110.w,
                                  child: Stack(
                                    children: [
                                      LocalPNG(
                                        height: 50.w,
                                        width: 110.w,
                                        url: 'assets/images/mymony/money-img.png',
                                      ),
                                      Center(
                                          child: Text(
                                        '确定',
                                        style: TextStyle(fontSize: 15.sp, color: Colors.white),
                                      )),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                  ],
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: LocalPNG(
                        width: 30.w,
                        height: 30.w,
                        url: 'assets/images/mymony/close.png',
                        fit: BoxFit.cover,
                      )),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  _onTapHeaderTitle() {
    _elegantController.animateTo(1.0, duration: Duration(milliseconds: 400), curve: Curves.linear);
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
    var vipClub = Provider.of<GlobalState>(context).profileData?['vip_club'] ?? 0;
    return Stack(
      children: [
        Scaffold(
          floatingActionButton: Padding(
            padding: EdgeInsets.only(bottom: kIsWeb ? AppGlobal.webBottomHeight + 20.w : 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ChaXiaoWaiButton(
                  isXiaowai: true,
                  uuid: UserInfo.serviceUuid,
                )
              ],
            ),
          ),
          appBar: PreferredSize(
              child: _tabs.length > 0
                  ? V3ElegentAppBarWidget(
                      cityList: _tabs,
                      callBack: _onChangeTabs,
                      tapFilter: getTagsList,
                      tapTitle: _onTapHeaderTitle,
                    )
                  : SizedBox(),
              preferredSize: Size.fromHeight(ScreenUtil().statusBarHeight + 50.w)),
          backgroundColor: Colors.white,
          body: NotificationListener<ScrollNotification>(
            child: PullToRefreshNotification(
              // pullBackOnRefresh: true,
              color: Colors.transparent,
              onRefresh: onRefresh,
              maxDragOffset: maxDragOffset,
              armedDragUpCancel: false,
              key: key,
              child: CustomScrollView(
                physics: ClampingScrollPhysics(),
                controller: _elegantController,
                slivers: <Widget>[
                  PullToRefreshContainer((e) {
                    return buildPulltoRefreshHeader(e);
                  }),
                  _banner.length > 0
                      ? SliverToBoxAdapter(
                          child: Container(
                            margin: EdgeInsets.only(top: 5.w, left: 15.w, right: 15.w),
                            height: 175.w,
                            child: Detail_ad(
                              radius: 18.w,
                              width: double.infinity,
                              height: double.infinity,
                              data: _banner,
                              app_layout: true,
                            ),
                          ),
                        )
                      : SliverToBoxAdapter(child: SizedBox(height: 0)),
                  SliverToBoxAdapter(
                    child: Container(
                      margin: EdgeInsets.only(
                        top: 15.w,
                        left: 15.w,
                        right: 15.w,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          NavTileCell(
                            image: "assets/images/elegantroom/nav1.png",
                            title: "品茶意向",
                            subtitle: "定制预约",
                            onTap: () {
                              var profileDatas = Provider.of<GlobalState>(context, listen: false).profileData;
                              var vipLevel = profileDatas != null ? profileDatas['vip_level'] : 0;
                              var agent = profileDatas != null ? profileDatas['agent'] : 0;
                              if (agent == 1 || agent == 2) {
                                showBuy('温馨提示', '经纪人目前暂未开放意向单发布', 0, '知道了');
                                return;
                              }
                              if (vipLevel >= 3) {
                                if (!isClick) {
                                  isClick = true;
                                  getCurrentStatus();
                                }
                              } else {
                                showBuy('开通会员',
                                    '因为部分妹子不愿意公开自己的信息，您可以使用该功能快捷发布预约意向单，入驻平台的茶老板皆可抢单，按你的要求推荐适合的妹子们，该功能只对会员及以上开放', 0);
                              }
                            },
                          ),
                          NavTileCell(
                            image: "assets/images/elegantroom/nav2.png",
                            title: "花魁阁楼",
                            subtitle: "顶级会员精选",
                            onTap: () {
                              if (CgPrivilege.getPrivilegeStatus(
                                  PrivilegeType.infoVip, PrivilegeType.privilegeAppointment)) {
                                AppGlobal.appRouter?.push(CommonUtils.getRealHash('huakuiGelou'));
                              } else {
                                CgDialog.cgShowDialog(
                                    context,
                                    '花魁阁楼',
                                    '花魁阁楼专为顶级会员打造，每一位花魁都是茶老板精心挑选，经由平台验证把关，身材颜值气质俱佳！成为顶级会员，开启阁楼风月之旅！',
                                    ['开通顶级会员'], callBack: () {
                                  AppGlobal.appRouter?.push(CommonUtils.getRealHash('memberCardsPage'));
                                });
                              }
                            },
                          ),
                          NavTileCell(
                            image: "assets/images/elegantroom/nav3.png",
                            title: "探花好片",
                            subtitle: "一探究竟",
                            onTap: () {
                              context.push(CommonUtils.getRealHash('tanhuaPage'));
                            },
                          ),
                          NavTileCell(
                            image: "assets/images/elegantroom/nav4.png",
                            title: "一元春宵",
                            subtitle: "春宵一刻仅一元",
                            onTap: () {
                              AppGlobal.appRouter?.push(CommonUtils.getRealHash('oneYuanSpring'));
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(left: 15.w, right: 15.w, top: 20.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                              onTap: () {
                                AppGlobal.appRouter?.push(CommonUtils.getRealHash('tianZiYiHaoPage/$vipClub}'));
                              },
                              child: Image.asset(
                                'assets/images/cg_320/tianziyihao.png',
                                width: 165.w,
                                fit: BoxFit.fitWidth,
                              )),
                          GestureDetector(
                            onTap: () {
                              AppGlobal.appRouter?.push(CommonUtils.getRealHash('authBeautyPage'));
                            },
                            child: Image.asset(
                              'assets/images/cg_320/yanzhengmeinv.png',
                              width: 165.w,
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                      child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12.w, horizontal: 15.w),
                          margin: EdgeInsets.only(
                            top: 15.w,
                            left: 15.w,
                            right: 15.w,
                          ),
                          decoration: BoxDecoration(color: Color(0xFFf8f6f1)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: RuleFilterTabs(
                                  tabs: typeList,
                                  selectTabIndex: _typeListValue,
                                  onTabs: (e) {
                                    if (typeList.isNotEmpty) {
                                      _onFilterRule(typeList[e]['value'], 'postType');
                                    }
                                    _typeListValue = e;
                                  },
                                ),
                              ),
                              SizedBox(height: 15.w),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: RuleFilterTabs(
                                  tabs: ruleList,
                                  selectTabIndex: _ruleListValue,
                                  onTabs: (e) {
                                    _onFilterRule(ruleList[e]['value'], 'rule');
                                    _ruleListValue = e;
                                  },
                                ),
                              ),
                              SizedBox(height: 15.w),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: RuleFilterTabs(
                                  tabs: videoValid,
                                  selectTabIndex: _videoValidValue,
                                  onTabs: (e) {
                                    _onFilterRule(videoValid[e]['value'], 'video_valid');
                                    _videoValidValue = e;
                                  },
                                ),
                              ),
                            ],
                          ))),
                  (networkErr //判断网络
                      ? SliverToBoxAdapter(
                          child: Container(
                              width: double.infinity,
                              height: 300.w,
                              child: InkWell(
                                onTap: () {
                                  getCityList();
                                },
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                      width: 150.w,
                                      height: 150.w,
                                      child: LocalPNG(url: 'assets/images/default_netword.png'),
                                    ),
                                    Text(
                                      "网络出现问题",
                                      style: TextStyle(color: StyleTheme.cBioColor, fontSize: 14.w),
                                    ),
                                    SizedBox(height: 20.w),
                                    Text(
                                      '点击重试',
                                      style: TextStyle(color: StyleTheme.cDangerColor, fontSize: 12.sp),
                                    )
                                  ],
                                ),
                              )),
                        )
                      : (resourcesDataList[_selectedTabIndex]['loading'] //加载中
                          ? SliverToBoxAdapter(
                              child: Container(
                                height: 1.sh - 100.w,
                                child: Loading(),
                              ),
                            )
                          : resourcesDataList[_selectedTabIndex]['data'] == null || //数据为空
                                  resourcesDataList[_selectedTabIndex]['data'].isEmpty
                              ? SliverToBoxAdapter(
                                  child: Container(
                                      alignment: Alignment.topCenter,
                                      height: 1.sh - 100.w,
                                      child: Container(
                                        height: 175.w,
                                        child: NoData(
                                          text: '没有数据了',
                                        ),
                                      )))
                              : SliverPadding(
                                  padding: EdgeInsets.only(
                                    top: 15.w,
                                    left: 15.w,
                                    right: 15.w,
                                    bottom: 30.w,
                                  ),
                                  sliver: SliverWaterfallFlow(
                                    gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      mainAxisSpacing: 5.w,
                                      crossAxisSpacing: 5.w,
                                    ),
                                    delegate: SliverChildBuilderDelegate(
                                      (BuildContext c, int index) {
                                        return ElegantCard(
                                          cardInfo: resourcesDataList[_selectedTabIndex]['data'][index],
                                          key: Key('keys_$index'),
                                          keys: index,
                                        );
                                      },
                                      childCount: resourcesDataList[_selectedTabIndex]['data'] == null
                                          ? 0
                                          : resourcesDataList[_selectedTabIndex]['data'].length,
                                    ),
                                  )))),
                  resourcesDataList[_selectedTabIndex]['data'] != null &&
                          !resourcesDataList[_selectedTabIndex]['loading'] &&
                          resourcesDataList[_selectedTabIndex]['data'].length > 0 &&
                          resourcesDataList[_selectedTabIndex]['isAll'] &&
                          loadmore == false
                      ? SliverToBoxAdapter(child: renderMore(false))
                      : SliverToBoxAdapter(child: SizedBox(height: 0)),
                ],
              ),
            ),
            onNotification: (ScrollNotification scrollInfo) => _onScrollNotification(scrollInfo),
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
        ),
        Positioned(
            top: 45.w + ScreenUtil().statusBarHeight + -5.w,
            right: 5.w,
            child: isShow
                ? GestureDetector(
                    onTap: () {
                      PersistentState.saveState('isFirstUse', '1');
                      setState(() {
                        isShow = false;
                      });
                    },
                    child: Padding(
                      padding: EdgeInsets.only(right: 2.5.w),
                      child: LocalPNG(
                        url: "assets/images/elegantroom/elegantTips.png",
                        width: 163.w,
                        height: 85.w,
                      ),
                    ))
                : SizedBox())
      ],
    );
  }

  String loadData = '数据加载中...';
  String noData = '没有更多数据';
  Widget renderMore(bool _loading) {
    return Container(
      height: 60.w,
      alignment: Alignment.topCenter,
      child: Text(
        _loading ? loadData : noData,
        style: TextStyle(color: StyleTheme.cBioColor),
      ),
    );
  }

  Widget tabsContainer() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(top: ScreenUtil().statusBarHeight),
      child: Container(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 15.w, horizontal: 15.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    "确认",
                    style: TextStyle(color: Colors.transparent, fontSize: 15.sp),
                  ),
                  Text(
                    '筛选类型',
                    style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 18.sp),
                  ),
                  GestureDetector(
                    onTap: () {
                      _filterOptionsSubmit();
                      Navigator.pop(context);
                    },
                    child: Text(
                      "确认",
                      style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 15.sp),
                    ),
                  ),
                ],
              ),
            ),
            _filterOption!['age'] != null && _filterOption!['age'].length > 0
                ? Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(left: 15.w),
                    height: 50.w,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: FilterTabsContainer(
                        tabs: _filterOption!['age'],
                        selectTabIndex: _ageTabIndex,
                        onTabs: (e) {
                          _onFilterOption(_filterOption!['age'], e, 'age');
                          _ageTabIndex = e;
                        },
                      ),
                    ),
                  )
                : SizedBox(height: 0),
            _filterOption!['height'] != null && _filterOption!['height'].length > 0
                ? Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.symmetric(vertical: 0, horizontal: 15.w),
                    height: 50.w,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: FilterTabsContainer(
                        tabs: _filterOption!['height'],
                        selectTabIndex: _heightTabIndex,
                        onTabs: (e) {
                          _onFilterOption(_filterOption!['height'], e, 'height');
                          _heightTabIndex = e;
                        },
                      ),
                    ),
                  )
                : SizedBox(height: 0),
            _filterOption!['cup'] != null && _filterOption!['cup'].length > 0
                ? Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.symmetric(vertical: 0, horizontal: 15.w),
                    height: 50.w,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: FilterTabsContainer(
                        tabs: _filterOption!['cup'],
                        selectTabIndex: _cupTabIndex,
                        onTabs: (e) {
                          _onFilterOption(_filterOption!['cup'], e, 'cup');
                          _cupTabIndex = e;
                        },
                      ),
                    ),
                  )
                : SizedBox(height: 0),
            _filterOption!['price'] != null && _filterOption!['price'].length > 0
                ? Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.symmetric(vertical: 0, horizontal: 15.w),
                    height: 50.w,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: FilterTabsContainer(
                        tabs: _filterOption!['price'],
                        selectTabIndex: _priceTabIndex,
                        onTabs: (e) {
                          _onFilterOption(_filterOption!['price'], e, 'price');
                          _priceTabIndex = e;
                        },
                      ),
                    ),
                  )
                : SizedBox(height: 0),
            _tagsList.length > 0
                ? Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(left: 15.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: 15.w,
                        ),
                        RichText(
                            text: TextSpan(
                                text: "服务项目 ",
                                style: TextStyle(
                                    color: StyleTheme.cTitleColor, fontWeight: FontWeight.bold, fontSize: 14.w),
                                children: <TextSpan>[
                              TextSpan(
                                  text: " (可多选)",
                                  style: TextStyle(
                                      color: StyleTheme.cBioColor, fontWeight: FontWeight.w400, fontSize: 12.sp)),
                            ])),
                        SizedBox(
                          height: 5.w,
                        ),
                        MultipleChoiceeChipWidget(
                          strings: _tagsList,
                          selectList: _selectTags,
                          onChanged: (selectTagList) {
                            setState(() {
                              _selectTags = selectTagList;
                            });
                          },
                        ),
                      ],
                    ),
                  )
                : SizedBox(height: 0)
          ],
        ),
      ),
    );
  }
}

class FilterTabsContainer extends StatefulWidget {
  final List? tabs;
  final int? selectTabIndex;
  final Function? onTabs;
  FilterTabsContainer({Key? key, this.tabs, this.selectTabIndex, this.onTabs}) : super(key: key);

  @override
  _FilterTabsContainerState createState() => _FilterTabsContainerState();
}

class _FilterTabsContainerState extends State<FilterTabsContainer> {
  int? index;

  @override
  void initState() {
    super.initState();
    index = widget.selectTabIndex;
  }

  onTapTabsItem(int e) {
    index = e;
    setState(() {});
    widget.onTabs!(e);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: widget.tabs!
            .asMap()
            .keys
            .map((e) => TabsItem(
                  title: widget.tabs![e]['name'],
                  index: index,
                  keys: e,
                  onTap: () {
                    onTapTabsItem(e);
                  },
                ))
            .toList(),
      ),
    );
  }
}

class TabsItem extends StatelessWidget {
  final String? title;
  final int? index;
  final int? keys;
  final GestureTapCallback? onTap;
  TabsItem({Key? key, this.title, this.index = 0, this.onTap, this.keys}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(right: 30.w),
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
                    ? TextStyle(color: StyleTheme.cTitleColor, fontSize: 18.sp, fontWeight: FontWeight.w700)
                    : TextStyle(color: StyleTheme.cTitleColor, fontSize: 14.w)),
          ],
        ),
      ),
    );
  }
}

class MultipleChoiceeChipWidget extends StatefulWidget {
  final List? strings;
  final List<String>? selectList;
  final void Function(List<String>)? onChanged;
  final GestureTapCallback? addItem;
  MultipleChoiceeChipWidget({this.strings, this.selectList, this.onChanged, this.addItem, Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MultipleChoiceeChipWidgetState();
  }
}

class MultipleChoiceeChipWidgetState extends State<MultipleChoiceeChipWidget> {
  Iterable<Widget> get actorWidgets sync* {
    List? list = this.widget.strings;
    List<String>? selectList = this.widget.selectList!;
    List<String> stringList = [];
    for (var i = 0; i < list!.length; i++) {
      stringList.add(list[i]['name']);
    }
    if (stringList.length == 0) {
      Container();
    } else {
      for (String stringItem in stringList) {
        yield Container(
          padding: EdgeInsets.only(top: 5.w, right: 10.w, bottom: 10.w),
          child: TagsItem(
            text: stringItem,
            selected: selectList.contains(stringItem),
            onSelected: (selected) {
              selectList.contains(stringItem) ? selectList.remove(stringItem) : selectList.add(stringItem);
              this.widget.onChanged!(selectList);
            },
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 7.5.w),
      child: Wrap(
        children: actorWidgets.toList(),
      ),
    );
  }
}

class TagsItem extends StatefulWidget {
  final String? text;
  final ValueChanged<bool>? onSelected;
  final bool? selected;
  TagsItem({Key? key, this.text, this.onSelected, this.selected}) : super(key: key);

  @override
  _TagsItemState createState() => _TagsItemState();
}

class _TagsItemState extends State<TagsItem> {
  bool? _select;
  @override
  void initState() {
    super.initState();
    _select = widget.selected;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onSelected!(!_select!);
        setState(() {
          _select = !_select!;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 5.w, horizontal: 10.5.w),
        decoration: BoxDecoration(
            color: _select! ? Color(0xFFFDF0E4) : Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(5)),
        child: Text(
          widget.text!,
          style: TextStyle(height: 1.5, color: _select! ? Color(0xFFFF4149) : StyleTheme.cTitleColor, fontSize: 12.sp),
        ),
      ),
    );
  }
}

class NavTileCell extends StatelessWidget {
  final String? image;
  final String? title;
  final String? subtitle;
  final GestureTapCallback? onTap;
  const NavTileCell({Key? key, this.image, this.title, this.subtitle, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Center(
                child: LocalPNG(
                  width: 55.w,
                  height: 55.w,
                  url: image,
                ),
              ),
              SizedBox(height: 7.5.w),
              Text(title!,
                  textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF323232), fontSize: 14.w), maxLines: 1),
              SizedBox(height: 5.w),
              Text(subtitle!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFFB4B4B4), fontSize: 11.sp),
                  maxLines: 1),
            ],
          ),
        ],
      ),
    );
  }
}

class ListTileCell extends StatelessWidget {
  final String? image;
  final String? title;
  final String? subtitle;
  final GestureTapCallback? onTap;
  const ListTileCell({Key? key, this.image, this.title, this.subtitle, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 169.w,
        height: 70.w,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5.w)),
        // child: Row(
        //   children: <Widget>[
        //     Column(
        //       mainAxisAlignment: MainAxisAlignment.center,
        //       crossAxisAlignment: CrossAxisAlignment.start,
        //       children: <Widget>[
        //         Text(title,
        //             style: TextStyle(
        //                 color: Color(0xFF1E1E1E),
        //                 fontSize: GVScreenUtil.setSp(30)),
        //             maxLines: 1),
        //         SizedBox(height: 5.w),
        //         Text(subtitle,
        //             style: TextStyle(
        //                 color: Color(0xFF1E1E1E),
        //                 fontSize: 12.sp),
        //             maxLines: 1),
        //       ],
        //     ),
        //   ],
        // ),
        child: LocalPNG(
          width: 169.w,
          height: 70.w,
          url: image,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class RuleFilterTabs extends StatefulWidget {
  final List? tabs;
  final int? selectTabIndex;
  final Function? onTabs;
  RuleFilterTabs({Key? key, this.tabs, this.selectTabIndex, this.onTabs}) : super(key: key);

  @override
  _RuleFilterTabsState createState() => _RuleFilterTabsState();
}

class _RuleFilterTabsState extends State<RuleFilterTabs> {
  int? index;

  @override
  void initState() {
    super.initState();
    index = widget.selectTabIndex;
  }

  onTapTabsItem(int e) {
    setState(() {
      index = e;
    });
    widget.onTabs!(e);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: widget.tabs!
            .asMap()
            .keys
            .map((e) => RuleTabsItem(
                  title: widget.tabs![e]["name"],
                  index: widget.selectTabIndex!,
                  keys: e,
                  onTap: () {
                    onTapTabsItem(e);
                  },
                ))
            .toList(),
      ),
    );
  }
}

class RuleTabsItem extends StatelessWidget {
  final String? title;
  final int? index;
  final int? keys;
  final GestureTapCallback? onTap;
  RuleTabsItem({Key? key, this.title, this.index = 0, this.onTap, this.keys}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(right: 30.w),
        child: Stack(
          children: <Widget>[
            Positioned(
                top: 0,
                right: 0,
                child: index == keys
                    ? Opacity(
                        opacity: 0.8,
                        child: Container(
                          width: 10.w,
                          height: 10.w,
                          decoration: BoxDecoration(color: Color(0xFFff4149), borderRadius: BorderRadius.circular(10)),
                        ),
                      )
                    : SizedBox()),
            Text("$title",
                style: index == keys
                    ? TextStyle(color: Color(0xFF646464), fontSize: 12.sp, fontWeight: FontWeight.w600)
                    : TextStyle(color: Color(0xFF646464), fontSize: 12.sp)),
          ],
        ),
      ),
    );
  }
}

class GameButton extends StatelessWidget {
  GameButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
        //悬浮按钮
        elevation: 0,
        backgroundColor: Colors.transparent,
        heroTag: 'signin',
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: NetImageTool(
            fit: BoxFit.contain,
            url: UserInfo.gameIconUrl!,
          ),
        ),
        onPressed: () {
          //跳转游戏
          // Application.router.navigateTo(context, '/games',
          //     transition: TransitionType.fadeIn,
          //     transitionDuration: new Duration(milliseconds: 200));
        });
  }
}
