import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:chaguaner2023/components/cgDialog.dart';
import 'package:chaguaner2023/components/loading.dart';
import 'package:chaguaner2023/components/updateModel.dart';
import 'package:chaguaner2023/model/homedata.dart';
import 'package:chaguaner2023/store/homeConfig.dart';
import 'package:chaguaner2023/store/sharedPreferences.dart';
import 'package:chaguaner2023/store/signInConfig.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/cgprivilege.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/index.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:chaguaner2023/utils/pageviewmixin.dart';
import 'package:chaguaner2023/utils/sp_keys.dart';
import 'package:chaguaner2023/view/homepage/minePages.dart';
import 'package:chaguaner2023/view/homepage/squarePages.dart';
import 'package:chaguaner2023/view/msg_list.dart';
import 'package:chaguaner2023/view/yajian/elegantPages.dart';
import 'package:flutter/foundation.dart';
import "package:flutter/material.dart";
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:universal_html/html.dart' as html;
import "package:universal_html/js.dart" as js;
import 'package:provider/provider.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../store/global.dart';

class Home extends StatefulWidget {
  final String? page;

  Home({Key? key, this.page}) : super(key: key);

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  BackButtonBehavior backButtonBehavior = BackButtonBehavior.none;
  PackageInfo? _packageInfo;
  bool showUpdateStatus = false;
  bool showAnnouncementStatus = false;
  bool showActivety = false;
  bool loading = true;
  bool toPage = false;
  bool showToolTip = false;
  bool showToolTip2 = false;
  bool isSquarePages = true;
  int curIndex = 0;
  ValueNotifier<bool> loadingChange = ValueNotifier<bool>(false);
  PageController? _selectedIndex;
  String toWorkBroStr = "进入工作台";
  String teaTwStr = '茶小二抢单';
  String teaGirlStr = "茶女郎工作台";
  String teaChecStr = "茶帖审核";
  String clbrzStr = "茶老板入驻";
  String cxrrzStr = "茶小二认证";
  String cnlzmStr = "牛郎织女招募";
  String toWorkAsseStr = "assets/images/nav/wordbench.png";
  String teaTwAsseStr = "assets/images/elegantroom/xiaoerqiangdan.png";
  String teaGirlAssetr = "assets/images/nav/chagirledit.png";
  String teaCheAsseString = "assets/images/nav/chashenhe.png";
  String bossruzhuStr = "assets/images/nav/bossruzhu.png";
  String cxrrzassS = "assets/images/nav/renzheng.png";
  String chagilrStra = "assets/images/nav/chagirl.png";
  bool init = false;
  List<Map> webTypeList = [
    {'w': 428, 'h': 926, 'r': 3}, // iphone13 pro max
    {'w': 390, 'h': 844, 'r': 3}, // iphone 13 and pro
    {'w': 375, 'h': 812, 'r': 3}, //iphoneX、iphoneXs
    {'w': 414, 'h': 896, 'r': 3}, //iphone Xs Max
    {'w': 414, 'h': 896, 'r': 2} //iphone XR
  ];

  List navBarItem = [
    {"title": "首页", "select": false, "activeIcon": "assets/images/nav/home.png", "tips": false},
    {"title": "雅间", "select": false, "activeIcon": "assets/images/nav/elegent.png", "tips": false},
    {"title": "消息", "select": false, "activeIcon": "assets/images/nav/megs.png", "tips": false, 'isMsg': 1},
    {"title": "发布", "select": false, "activeIcon": "assets/images/nav/more.png", "tips": false},
    {"title": "我的", "select": false, "activeIcon": "assets/images/nav/me.png", "tips": false}
  ];

  getWebType(int h, int w, double r) {
    webTypeList.forEach((item) {
      if (item['h'] == h && item['w'] == w && item['r'] == r) {
        AppGlobal.webBottomHeight = 15.w;
      }
    });
  }

  getService() {
    getCustomerService().then((res) {
      if (res?['status'] != 0) {
        CommonUtils.debugPrint(res);
        UserInfo.serviceUuid = res['data']['kf_uuid'];
        UserInfo.shenheUuid = res['data']['check_uuid'];
        UserInfo.fpznUrl = res['data']['fangpianzhinan'];
        UserInfo.wxykUrl = res['data']['unlimitedUnlock'];
        UserInfo.jcsUrl = res['data']['jianchashi'];
        UserInfo.kefuList = res['data']['agent_uuid']; //officialUuid
        UserInfo.mobileUrl = res['data']['mobile_url'];
        UserInfo.datingCS = res['data']['agent_uuid_pos']['da_ting'];
        UserInfo.yuyueCS = res['data']['agent_uuid_pos']['yu_yue'];
        String officaiCS = res['data']['agent_uuid_pos']['da_ting'];
        UserInfo.manageUuid = res['data']['agent_uuid_pos']['manage_uuid'];
        PersistentState.getState('vipkefu').then((value) {
          if (value == null || value == 'null') {
            var vipkefu =
                officaiCS.isNotEmpty ? officaiCS : UserInfo.kefuList![Random().nextInt(UserInfo.kefuList!.length)];
            PersistentState.saveState('vipkefu', json.encode(vipkefu));
            UserInfo.officialUuid = vipkefu['uuid'];
            UserInfo.officialName = vipkefu['nickname'];
          } else {
            if (officaiCS == '') {
              var kefuObj = json.decode(value);
              UserInfo.officialUuid = kefuObj['uuid'];
              UserInfo.officialName = kefuObj['nickname'];
            } else {
              var kefuObj = json.decode(officaiCS);
              PersistentState.saveState('vipkefu', json.encode(kefuObj));
              UserInfo.officialUuid = kefuObj['uuid'];
              UserInfo.officialName = kefuObj['nickname'];
            }
          }
        });
      }
    });
  }

  // int _selectedIndex = 0;
  DateTime? lastPopTime;

  //清理磁盘
  _initClearDisk() async {
    if (kIsWeb) {
      PaintingBinding.instance.imageCache.clear();
      AppGlobal.imageCacheBox!.clear();
      return;
    }
    String path = AppGlobal.imageCacheBox!.path ?? "";
    int size = await File(path).length();
    //大于500M就清理
    if (size / 1000 / 1000 > 500) await AppGlobal.imageCacheBox!.clear();
  }

  @override
  void initState() {
    super.initState();
    EventBus().on('changeHomeTap', (arg) {
      for (var i = 0; i < navBarItem.length; i++) {
        navBarItem[i]['select'] = false;
      }
      navBarItem[arg]['select'] = true;
      curIndex = arg;
      setState(() {});
      _selectedIndex!.jumpToPage(curIndex);
    });
    AppGlobal.apiToken.addListener(() {
      loadingChange.value = true;
      for (var i = 0; i < navBarItem.length; i++) {
        navBarItem[i]['select'] = false;
      }
      navBarItem[0]['select'] = true;
      curIndex = 0;
      Future.delayed(Duration(milliseconds: 300), () {
        loadingChange.value = false;
      });
    });
    if (kIsWeb) {
      int _h = html.window.screen!.height!;
      int _w = html.window.screen!.width!;
      num _ratio = html.window.devicePixelRatio;
      getWebType(_h, _w, _ratio as double);
    }
    getService();
    // 获取菜单
    _initPackageInfo();
    getMenuList().then((res) {
      if (res?['status'] != 0) {
        curIndex = widget.page != null ? int.parse(widget.page!) : (res['data']['buttonTab'][0]['id'] == 1 ? 0 : 1);
        navBarItem[curIndex]['select'] = true;
        _selectedIndex = PageController(initialPage: curIndex);
        loading = false;
        setState(() {});
      }
    });
    initShowToolTip();
    _initClearDisk();
  }

  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    _packageInfo = info;
    setState(() {});
  }

  Future initShowToolTip() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool checkinstallState = prefs.containsKey('${SpKeys.installState}');
    if (checkinstallState == false) {
      prefs.setString('${SpKeys.installState}', '0');
    } else {
      var tepNumber = prefs.getString('${SpKeys.installState}');
      var iniNumber = int.parse(tepNumber!);
      switch (iniNumber) {
        case 0:
          setState(() {
            showToolTip = true;
            showToolTip2 = true;
          });
          break;
        case 1:
          setState(() {
            showToolTip = false;
            showToolTip2 = true;
          });
          break;
        default:
          setState(() {
            showToolTip = false;
            showToolTip2 = false;
          });
      }
    }
  }

  Future setToolTipState(value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('${SpKeys.installState}', '$value');
    switch (value) {
      case 1:
        setState(() {
          showToolTip = false;
        });
        break;
      case 2:
        setState(() {
          showToolTip2 = false;
        });
        break;
      default:
    }
  }

  void _onItemTapped(int index) {
    if (index == 2) {
      CommonUtils.getUnreadMsg();
    }
    if (index == 3) {
      showPublish();
      setToolTipState(1);
    } else {
      _selectedIndex!.jumpToPage(index > 3 ? index - 1 : index);
    }
    if (index != 3) {
      for (var i = 0; i < navBarItem.length; i++) {
        navBarItem[i]['select'] = false;
      }
      navBarItem[index]['select'] = true;
      curIndex = index >= 3 ? index - 1 : index;
      setState(() {});
    }
  }

  void showBuy(String title, String content, int type, {String? btnText, Function? onTap}) {
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
                          style: TextStyle(fontSize: 14.sp, color: StyleTheme.cTitleColor),
                        )),
                    type == 0
                        ? GestureDetector(
                            onTap: () => {
                                  Navigator.of(context).pop(true),
                                },
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop();
                                onTap!.call();
                              },
                              child: Container(
                                margin: new EdgeInsets.only(top: 30.w),
                                height: 50.w,
                                width: 200.w,
                                child: Stack(
                                  children: [
                                    LocalPNG(url: 'assets/images/mymony/money-img.png', fit: BoxFit.fill),
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
                                          height: 50.w,
                                          width: 110.w,
                                          url: 'assets/images/mymony/money-img.png',
                                          fit: BoxFit.fill),
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
                                          fit: BoxFit.fill),
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
                          width: 30.w, height: 30.w, url: 'assets/images/mymony/close.png', fit: BoxFit.cover)),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void showPublish() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return RepaintBoundary(
            child: StatefulBuilder(builder: (context, state) {
              var profileDatas = Provider.of<GlobalState>(context).profileData;
              var agent = Provider.of<HomeConfig>(context).member.agent;
              int tdFatieNum = (profileDatas?['max_store_post_num'] ?? 0) - (profileDatas?['now_store_post_num'] ?? 0);
              int fatieNum = (profileDatas?['max_post_num'] ?? 0) - (profileDatas?['now_post_num'] ?? 0);
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    color: Colors.transparent,
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(
                                top: 30.w, left: 25.w, right: 25.w, bottom: ScreenUtil().bottomBarHeight + 15.w),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                GestureDetector(
                                  onTap: () {
                                    if (!CgPrivilege.getPrivilegeStatus(
                                        PrivilegeType.infoStore, PrivilegeType.privilegeCreate)) {
                                      return CommonUtils.showVipDialog(
                                          context, PrivilegeType.infoStoreString + PrivilegeType.privilegeCreateString);
                                    }
                                    AppGlobal.publishPostType = 0;
                                    if (showToolTip2) {
                                      Navigator.pop(context);
                                      AppGlobal.appRouter?.push(CommonUtils.getRealHash('publishGuide'));
                                      setToolTipState(2);
                                    } else {
                                      Navigator.pop(context);
                                      AppGlobal.appRouter?.push(CommonUtils.getRealHash('publishPage/null'));
                                    }
                                    return;
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    height: 75.w,
                                    decoration: BoxDecoration(
                                        color: Color(0xFFF5F5F5), borderRadius: BorderRadius.all(Radius.circular(5.w))),
                                    child: Row(
                                      children: <Widget>[
                                        LocalPNG(
                                          url: "assets/images/nav/chatie.png",
                                          width: 70.w,
                                          height: 70.w,
                                        ),
                                        SizedBox(width: 4.5.w),
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              "店家发布",
                                              style: TextStyle(
                                                  color: StyleTheme.cTitleColor,
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(height: 7.5.w),
                                            Text(
                                              "分享门店资源赚元宝",
                                              style: TextStyle(
                                                color: StyleTheme.cBioColor,
                                                fontSize: 12.sp,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Expanded(child: Container()),
                                        GestureDetector(
                                          child: Container(
                                            width: 80.w,
                                            height: 75.w,
                                            decoration: BoxDecoration(
                                                color: Color.fromRGBO(255, 225, 225, 1.0),
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(5.w),
                                                )),
                                            child: Stack(
                                              children: [
                                                LocalPNG(
                                                  url: "assets/images/v8/wenhao.png",
                                                  width: 25.w,
                                                  height: 25.w,
                                                ),
                                                Center(
                                                  child: CgPrivilege.getPrivilegeStatus(
                                                          PrivilegeType.infoStore, PrivilegeType.privilegeCreate)
                                                      ? Column(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Text(
                                                              (tdFatieNum < 0 ? 0 : tdFatieNum).toString(),
                                                              style: TextStyle(
                                                                  color: StyleTheme.cTitleColor,
                                                                  fontWeight: FontWeight.bold,
                                                                  fontSize: 18.sp),
                                                            ),
                                                            Text(
                                                              '剩余发帖次数',
                                                              style: TextStyle(
                                                                  color: StyleTheme.cTextColor, fontSize: 10.sp),
                                                            ),
                                                          ],
                                                        )
                                                      : Text(
                                                          '暂无发帖资格',
                                                          style:
                                                              TextStyle(color: StyleTheme.cTextColor, fontSize: 10.sp),
                                                        ),
                                                )
                                              ],
                                            ),
                                          ),
                                          onTap: () {
                                            Navigator.pop(context);
                                            AppGlobal.publishPostType = 0;
                                            AppGlobal.appRouter
                                                ?.push(CommonUtils.getRealHash('faTieCiShuShuoMingPage'));
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 15.w),
                                GestureDetector(
                                  onTap: () {
                                    if (!CgPrivilege.getPrivilegeStatus(
                                        PrivilegeType.infoPersonal, PrivilegeType.privilegeCreate)) {
                                      return CommonUtils.showVipDialog(context,
                                          PrivilegeType.infoPersonalString + PrivilegeType.privilegeCreateString);
                                    }
                                    AppGlobal.publishPostType = 1;
                                    if (showToolTip2) {
                                      Navigator.pop(context);
                                      AppGlobal.appRouter?.push(CommonUtils.getRealHash('publishGuide'));
                                      setToolTipState(2);
                                    } else {
                                      Navigator.pop(context);
                                      AppGlobal.appRouter?.push(CommonUtils.getRealHash('publishPage/null'));
                                    }
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    height: 75.w,
                                    decoration: BoxDecoration(
                                        color: Color(0xFFF5F5F5), borderRadius: BorderRadius.all(Radius.circular(5.w))),
                                    child: Row(
                                      children: <Widget>[
                                        LocalPNG(
                                          url: "assets/images/nav/geren.png",
                                          width: 70.w,
                                          height: 70.w,
                                        ),
                                        SizedBox(width: 4.5.w),
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              "个人分享",
                                              style: TextStyle(
                                                  color: StyleTheme.cTitleColor,
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(height: 7.5.w),
                                            Text(
                                              "分享资源，赚元宝",
                                              style: TextStyle(
                                                color: StyleTheme.cBioColor,
                                                fontSize: 12.sp,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Expanded(child: Container()),
                                        GestureDetector(
                                          child: Container(
                                            width: 80.w,
                                            height: 75.w,
                                            decoration: BoxDecoration(
                                                color: Color.fromRGBO(255, 225, 225, 1.0),
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(5.w),
                                                )),
                                            child: Stack(
                                              children: [
                                                LocalPNG(
                                                  url: "assets/images/v8/wenhao.png",
                                                  width: 25.w,
                                                  height: 25.w,
                                                ),
                                                Center(
                                                  child: CgPrivilege.getPrivilegeStatus(
                                                          PrivilegeType.infoPersonal, PrivilegeType.privilegeCreate)
                                                      ? Column(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Text(
                                                              (fatieNum < 0 ? 0 : fatieNum).toString(),
                                                              style: TextStyle(
                                                                  color: StyleTheme.cTitleColor,
                                                                  fontWeight: FontWeight.bold,
                                                                  fontSize: 18.sp),
                                                            ),
                                                            Text(
                                                              '剩余发帖次数',
                                                              style: TextStyle(
                                                                  color: StyleTheme.cTextColor, fontSize: 10.sp),
                                                            ),
                                                          ],
                                                        )
                                                      : Text(
                                                          '暂无发帖资格',
                                                          style:
                                                              TextStyle(color: StyleTheme.cTextColor, fontSize: 10.sp),
                                                        ),
                                                )
                                              ],
                                            ),
                                          ),
                                          onTap: () {
                                            Navigator.pop(context);
                                            AppGlobal.publishPostType = 1;
                                            AppGlobal.appRouter
                                                ?.push(CommonUtils.getRealHash('faTieCiShuShuoMingPage'));
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 15.w),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Expanded(
                                      child: PublishMenuItem(
                                        title: agent == 1 ? toWorkBroStr : clbrzStr,
                                        image: agent == 1 ? toWorkAsseStr : bossruzhuStr,
                                        onTap: () {
                                          if (agent == 1) {
                                            Navigator.pop(context);
                                            AppGlobal.appRouter?.push(CommonUtils.getRealHash('workbenchPage'));
                                          } else {
                                            Navigator.pop(context);
                                            AppGlobal.appRouter?.push(CommonUtils.getRealHash('employmentIntroduce/1'));
                                          }
                                        },
                                      ),
                                    ),
                                    SizedBox(width: 15.w),
                                    Expanded(
                                        child: PublishMenuItem(
                                      title: agent == 2 ? teaTwStr : cxrrzStr,
                                      image: agent == 2 ? teaTwAsseStr : cxrrzassS,
                                      onTap: () {
                                        Navigator.pop(context);
                                        agent == 2
                                            ? AppGlobal.appRouter?.push(CommonUtils.getRealHash('xiaoerOser'))
                                            : AppGlobal.appRouter
                                                ?.push(CommonUtils.getRealHash('employmentIntroduce/2'));
                                      },
                                    ))
                                  ],
                                ),
                                SizedBox(height: 15.w),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Expanded(
                                        child: PublishMenuItem(
                                      title: agent == 5 ? teaGirlStr : cnlzmStr,
                                      image: agent == 5 ? teaGirlAssetr : chagilrStra,
                                      onTap: () {
                                        Navigator.pop(context, true);
                                        if (agent == 5) {
                                          AppGlobal.appRouter?.push(CommonUtils.getRealHash('girlWorkbenchPage'));
                                        } else {
                                          AppGlobal.appRouter?.push(CommonUtils.getRealHash('employmentIntroduce/3'));
                                        }
                                      },
                                    )),
                                    SizedBox(width: 15.w),
                                    Expanded(
                                      child: PublishMenuItem(
                                        title: agent == 3 || agent == 4
                                            ? '发验茶报告' //teaChecStr
                                            : "成为鉴茶师",
                                        image: agent == 3 || agent == 4
                                            ? teaCheAsseString
                                            : "assets/images/nav/jianchashi.png",
                                        onTap: () {
                                          Navigator.pop(context);
                                          if (agent == 3 || agent == 4) {
                                            context.push(CommonUtils.getRealHash('myTeaPost/2'));
                                            // AppGlobal.appRouter.push(
                                            //     CommonUtils.getRealHash(
                                            //         'postReviewPage'));
                                          } else {
                                            AppGlobal.appRouter?.push(CommonUtils.getRealHash('employmentIntroduce/4'));
                                          }
                                        },
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: LocalPNG(
                                url: "assets/images/nav/closemenu.png",
                                width: 30.w,
                                height: 30.w,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }),
          );
        });
  }

  void checkUpdateAnnouncement(VersionMsg version, Config config) {
    // "mstatus": 0,    | 系统公告状态 0 没有 1通知 2禁用
    // "must": "0",     | 更新开关 0 不更新  1 强制更新 2 非强制更新
    // "tips": "",      | 更新描述
    // "message": "",   | 公告描述
    var _versionLocal = AppGlobal.appinfo!['version'];
    var targetVersion = version.version!.replaceAll('.', '');
    var currentVersion = _versionLocal.replaceAll('.', '');
    // 强制更新 线上版本大于当前版本才更新
    var needUpdate = int.parse(targetVersion) > int.parse(currentVersion);
    if (Provider.of<SignInConfig>(context, listen: false).show == false) return;
    if (version.must == 1 && needUpdate) {
      showUpdate(version.version!, version.tips!, version.apk!,
          must: version.must!, showAnnouncementDialog: false, official: config.officeSite!);
      return;
    }
    // 非强制更新 无公告 (关闭更新后弹出公告)
    if (version.must == 2 && version.mstatus == 0 && needUpdate) {
      showUpdate(version.version!, version.tips!, version.apk!,
          must: version.must!,
          message: version.message!,
          showAnnouncementDialog: version.mstatus == 0,
          official: config.officeSite!);
      return;
    }

    // 非强制更新 有公告 (关闭更新后弹出公告)
    if (version.must == 2 && version.mstatus == 1 && needUpdate) {
      showUpdate(version.version!, version.tips!, version.apk!,
          must: version.must!,
          message: version.message!,
          showAnnouncementDialog: version.mstatus == 1,
          official: config.officeSite!);
      return;
    }
    // 无更新 有公告
    if (version.mstatus == 1) {
      if (AppGlobal.popAppAds.isEmpty) {
        if (AppGlobal.popAppAds.isNotEmpty) {
          UpdateModel.showCompartmentDialog();
        }
      } else {
        if (AppGlobal.popAppAds.isNotEmpty) {
          UpdateModel.showCompartmentDialog(
            cancel: () {
              showAnnouncement(version.message!);
            },
          );
        } else {
          showAnnouncement(version.message!);
        }
      }
    }
  }

  // 更新提示
  void showUpdate(String version, String tips, String apkurl,
      {int? must, String? message, bool? showAnnouncementDialog, String? official}) {
    if (showUpdateStatus == true) return;
    UpdateModel.showUpdateDialog(backButtonBehavior, gowebsite: () {
      CommonUtils.launchURL(official!);
    }, cancel: () {
      if (showAnnouncementDialog!) {
        UpdateModel.showCompartmentDialog(
          cancel: () {
            showAnnouncement(message!);
            Provider.of<SignInConfig>(context, listen: false).setShow(false);
          },
        );
      } else {
        showAnnouncement(message!);
        Provider.of<SignInConfig>(context, listen: false).setShow(false);
      }
    }, confirm: () {
      Provider.of<SignInConfig>(context, listen: false).setShow(false);
      if (kIsWeb) {
        CommonUtils.launchURL(Provider.of<HomeConfig>(context, listen: false).config.officeSite);
      } else {
        UpdateModel.androidUpdate(backButtonBehavior, version: version, url: apkurl);
      }
    }, version: "茶馆儿v.$version", mustupdate: must == 1, text: '$tips');
    setState(() {
      showUpdateStatus = true;
    });
  }

  // 公告提示
  void showAnnouncement(String message) {
    if (showAnnouncementStatus == true) return;
    bool isSelf = false;
    String oneStr = "1";
    String twoStr = "2";
    isSelf = Provider.of<HomeConfig>(context, listen: false).data['all_agent_white'] == 0;
    UpdateModel.showAnnouncementDialog(
      backButtonBehavior,
      cancel: () {
        Provider.of<SignInConfig>(context, listen: false).setShow(false);
        _addMainScreen();
      },
      confirm: () {
        Provider.of<SignInConfig>(context, listen: false).setShow(false);
        _addMainScreen();
      },
      confirmApp: () {
        context.push(CommonUtils.getRealHash('popularize'));
        _addMainScreen();
      },
      text: "$message",
      type: isSelf ? twoStr : oneStr,
    );
    setState(() {
      showAnnouncementStatus = true;
    });
  }

  showVerifyIdentityExpired() {
    verifyIdentityExpired().then((res) {
      if (res!['status'] != 0) {
        int showLength = (res['data'] as Map).length;
        int _index = 0;
        List keys = (res['data'] as Map).keys.toList();
        showExpired(int n) {
          if (_index > showLength - 1) return;
          CgDialog.cgShowDialog(context, '温馨提示', res['data'][keys[_index]]['msg'], ['取消', '前往续费'], callBack: () {
            switch (keys[_index]) {
              case '1': //会员到期提示
                AppGlobal.appRouter?.push(CommonUtils.getRealHash('memberCardsPage'));
                break;
              case '2': //实习验茶师到期
                AppGlobal.appRouter?.push(CommonUtils.getRealHash('employmentIntroduce/4'));
                break;
              case '3': //商家认证到期
                AppGlobal.appRouter?.push(CommonUtils.getRealHash('onlineServicePage'));
                break;
              case '4': //大厅经纪人到期提示
                AppGlobal.appRouter?.push(CommonUtils.getRealHash('employmentIntroduce/2'));
                break;
              case '5': //验茶师到期提示
                AppGlobal.appRouter?.push(CommonUtils.getRealHash('employmentIntroduce/4'));
                break;
              case '6': //雅间经纪人到期提示
                AppGlobal.appRouter?.push(CommonUtils.getRealHash('employmentIntroduce/1'));
                break;
              case '7': //茶女郎到期提示
                AppGlobal.appRouter?.push(CommonUtils.getRealHash('employmentIntroduce/3'));
                break;
              default:
            }
          }, onClose: () {
            _index++;
            showExpired(_index);
          });
        }

        showExpired(_index);
      }
    });
  }

  //加载添加到主屏幕功能
  void _addMainScreen() async {
    showVerifyIdentityExpired();
    return;
    if (!kIsWeb) return;
    final bool isInstall = (js.context.callMethod("getInstallValue") as String) == "1";
    final bool isSafari = js.context.callMethod("checkSafari") as bool;
    if (!isSafari && !isInstall) {
      showModalBottomSheet(
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          context: context,
          builder: (BuildContext context) {
            return StatefulBuilder(builder: (context, setBottomSheetState) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: StyleTheme.margin),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topRight: Radius.circular(5.w), topLeft: Radius.circular(5.w)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 20.w),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(width: 20.w, height: 20.w),
                        Text(
                          "添加51品茶到主屏幕？[如已添加请忽略]",
                          style: TextStyle(color: Color.fromRGBO(30, 30, 30, 1), fontSize: 14.sp),
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Icon(
                            Icons.close,
                            size: 20.w,
                            color: Color.fromRGBO(30, 30, 30, 1),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 30.w),
                    CommonUtils.getContentSpan(
                      "如无法正常添加到主屏幕，请下载最新版本的Google浏览器https://www.google.cn/intl/zh-CN/chrome，打开Google浏览器，输入本站网址000，点击右上角的【菜单】然后选择【添加到主屏幕】即可完成WEB版APP"
                          .replaceAll("000", html.window.location.href),
                      style: TextStyle(fontSize: 12.sp, color: const Color.fromRGBO(255, 65, 73, 1)),
                      lightStyle: TextStyle(fontSize: 12.sp, color: const Color.fromRGBO(25, 103, 210, 1)),
                    ),
                    SizedBox(height: 20.w),
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        final bool isDeferredNotNull = js.context.callMethod("isDeferredNotNull") as bool;
                        if (isDeferredNotNull) {
                          js.context.callMethod("presentAddToHome");
                        } else {
                          CommonUtils.showText("当前浏览器不支持该功能，请使用Google浏览器添加到主屏幕或24小时后再操作", time: 2);
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: StyleTheme.cDangerColor, borderRadius: BorderRadius.all(Radius.circular(3.w))),
                        padding: EdgeInsets.symmetric(horizontal: StyleTheme.margin),
                        height: 32.w,
                        alignment: Alignment.center,
                        child: Text("添加到主屏幕", style: TextStyle(color: Colors.white, fontSize: 14.sp)),
                      ),
                    ),
                    SizedBox(height: 30.w),
                  ],
                ),
              );
            });
          });
    }
  }

  // 活动弹窗
  void showActivetyDialog(Config config, VersionMsg version) {
    int activeLength = AppGlobal.popAds.length - 1;
    int activeIndex = 0;
    showIndexActive(int index) {
      UpdateModel.showAvtivetysDialog(backButtonBehavior, url: AppGlobal.popAds[index]['title'], cancel: () {
        activeIndex++;
        if (activeIndex <= activeLength) {
          showIndexActive(activeIndex);
        } else {
          checkUpdateAnnouncement(version, config);
        }
      }, confirm: () {
        _onTapSwiper(AppGlobal.popAds[index]['type'], AppGlobal.popAds[index]['content']);
        popAdsChick(AppGlobal.popAds[index]['id'].toString());
        activeIndex++;
        if (activeIndex <= activeLength) {
          showIndexActive(activeIndex);
        } else {
          checkUpdateAnnouncement(version, config);
        }
      });
    }

    showIndexActive(activeIndex);
  }

  _onTapSwiper(String type, String _adsUrl) {
    var members = Provider.of<HomeConfig>(context, listen: false).member;
    var aff = members.aff;
    var chaid = members.uuid;
    var types = type;
    String urls = "$_adsUrl?aff=$aff&chaid=$chaid";
    if (['', null, false].contains(_adsUrl)) {
      BotToast.showText(text: '未配置跳转链接', align: Alignment(0, 0));
      return;
    }
    if (types == "1") {
      // 内部路由
      AppGlobal.appRouter?.push(CommonUtils.getRealHash('$_adsUrl'));
    } else if (types == "2") {
      // WebViewPage
      AppGlobal.appRouter?.push(CommonUtils.getRealHash('activityPage/${Uri.encodeComponent(urls)}'));
    } else if (types == "3") {
      // 外部浏览器
      CommonUtils.launchURL(urls);
    } else if (types == "4") {
      // 外部浏览器
      CommonUtils.launchURL("$_adsUrl");
    } else if (types == "5") {
      // WebViewPage
      AppGlobal.appRouter?.push(CommonUtils.getRealHash('activityPage/${Uri.encodeComponent(_adsUrl)}'));
    }
  }

  @override
  Widget build(BuildContext context) {
    var version = Provider.of<HomeConfig>(context).versionMsg;
    var config = Provider.of<HomeConfig>(context).config;
    if (!init) {
      init = true;
      if (AppGlobal.popAds.isNotEmpty) {
        // title 活动图片地址  content 活动跳转地址 type 跳转类型 1 路由 2 内部webview 3 外部
        showActivetyDialog(config, version);
      } else {
        if (_packageInfo != null) {
          checkUpdateAnnouncement(version, config);
        } else {
          _initPackageInfo().then((value) {
            if (version.mstatus == 1) {
              checkUpdateAnnouncement(version, config);
            }
          });
        }
      }
    }

    // 初始化适配组件
    return Scaffold(
      body: ValueListenableBuilder(
        valueListenable: loadingChange,
        builder: (BuildContext? context, bool? value, Widget? child) {
          return loading || value!
              ? Loading()
              : Stack(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(bottom: ScreenUtil().bottomBarHeight),
                      height: double.infinity,
                      child: PageView(
                        physics: NeverScrollableScrollPhysics(),
                        onPageChanged: (index) {
                          navBarItem[curIndex]['select'] = false; //清除当前按钮状态
                          navBarItem[index]['select'] = true;
                          curIndex = index;
                          (context as Element).markNeedsBuild();
                        },
                        controller: _selectedIndex,
                        children: [
                          PageViewMixin(
                            child: SquarePages(),
                          ),
                          PageViewMixin(
                            child: ElegantRoomPages(),
                          ),
                          PageViewMixin(
                            child: MsgListPage(),
                          ),
                          PageViewMixin(
                            child: MinePages(),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                        key: Key('navbar'),
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 1.sw,
                          height: 64.w + ScreenUtil().bottomBarHeight / 2 + AppGlobal.webBottomHeight,
                          child: Stack(
                            children: [
                              Positioned(
                                  left: 0,
                                  right: 0,
                                  bottom: 0,
                                  child: LocalPNG(
                                      width: double.infinity,
                                      height: 64.w + ScreenUtil().bottomBarHeight / 2 + AppGlobal.webBottomHeight,
                                      url: "assets/images/nav/navbg2.png",
                                      fit: BoxFit.cover)),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Expanded(child: SizedBox()),
                                  Container(
                                    padding: EdgeInsets.only(
                                        bottom: ScreenUtil().bottomBarHeight / 2 + 5.5.w + AppGlobal.webBottomHeight),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: navBarItem
                                          .asMap()
                                          .keys
                                          .map((key) => NavBarItem(
                                                isMsg: navBarItem[key]['isMsg'] != null,
                                                title: navBarItem[key]['title'],
                                                image: navBarItem[key]['activeIcon'],
                                                select: navBarItem[key]['select'],
                                                tips: navBarItem[key]['tips'],
                                                onTap: () {
                                                  if (!navBarItem[key]['select']) {
                                                    _onItemTapped(key);
                                                  }
                                                },
                                              ))
                                          .toList(),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ))
                  ],
                );
        },
      ),
      // floatingActionButton: loading
      //     ? SizedBox()
      //     : GestureDetector(
      //         onTap: () {
      //           showPublish();
      //           setToolTipState(1);
      //         },
      //         child: CGToolTip(
      //           tooltipTap: () {
      //             setToolTipState(1);
      //           },
      //           child: Container(
      //             transform: Matrix4.translationValues(
      //                 0,
      //                 Platform.isIOS
      //                     ? GVScreenUtil.bottomBarHeight + 8
      //                     : 10,
      //                 0),
      //             margin: EdgeInsets.only(
      //               bottom: GVScreenUtil.bottomBarHeight / 2 +
      //                   GVScreenUtil.setWidth(8),
      //             ),
      //             width: GVScreenUtil.setWidth(130),
      //             height: GVScreenUtil.setWidth(130),
      //             decoration: BoxDecoration(
      //                 image: DecorationImage(
      //                     image:
      //                         AssetImage("assets/images/nav/publish1.png"),
      //                     alignment: Alignment.bottomCenter,
      //                     fit: BoxFit.contain)),
      //           ),
      //           content: Text(
      //             "发帖可以赚取铜钱或元宝噢～",
      //             style: TextStyle(
      //               color: Color(0xFFF9F9F9),
      //               fontSize: 12,
      //               decoration: TextDecoration.none,
      //             ),
      //           ),
      //           show: showToolTip,
      //           arrowTipDistance: -10,
      //         )),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class NavBarItem extends StatelessWidget {
  final String? image;
  final String? title;
  final bool? select;
  final bool? tips;
  final bool? isMsg;
  final GestureTapCallback? onTap;

  const NavBarItem({Key? key, this.image, this.title, this.onTap, this.select, this.tips, this.isMsg = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Opacity(
            opacity: select! ? 1.0 : 0.5,
            child: Container(
              margin: EdgeInsets.only(top: 0),
              child: Column(children: <Widget>[
                LocalPNG(
                  url: image,
                  width: 30.w,
                  height: 25.w,
                ),
                Text(
                  title!,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.white,
                  ),
                )
              ]),
            ),
          ),
          Positioned(
              right: 0,
              top: 0,
              child: isMsg!
                  ? ValueListenableBuilder(
                      valueListenable: AppGlobal.unreadMessage,
                      builder: (context, value, child) {
                        return value == 0
                            ? Container()
                            : Container(
                                width: 6.w,
                                height: 6.w,
                                decoration:
                                    BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(3.w)),
                                // child: Text(
                                //   value.toString(),
                                //   style: TextStyle(
                                //       color: Colors.white, fontSize: 11.sp),
                                // ),
                              );
                      })
                  : Container())
        ],
      ),
    );
  }
}

class PublishMenuItem extends StatelessWidget {
  final String? image;
  final String? title;
  final GestureTapCallback? onTap;

  const PublishMenuItem({Key? key, this.image, this.title, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 2.5.w, horizontal: 10.w),
        decoration: BoxDecoration(color: Color(0xFFF5F5F5), borderRadius: BorderRadius.all(Radius.circular(5.w))),
        child: Row(
          children: <Widget>[
            LocalPNG(
              url: image,
              width: 45.w,
              height: 45.w,
            ),
            SizedBox(
              height: 5.w,
            ),
            Text(
              title!,
              style: TextStyle(fontSize: 14.sp, color: StyleTheme.cTitleColor, fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }
}
