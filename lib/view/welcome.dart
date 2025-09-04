import 'dart:async';
import 'package:bot_toast/bot_toast.dart';
import 'package:chaguaner2023/store/global.dart';
import 'package:chaguaner2023/store/sharedPreferences.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/index.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:chaguaner2023/utils/netimage_tool.dart';
import 'package:chaguaner2023/utils/sp_keys.dart';
import 'package:chaguaner2023/view/home.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import "package:universal_html/html.dart" as html;

//显示逻辑 是否显示简介幻灯片-》检测线路-》获取基础配置数据-》是否设置了私密锁-》是否显示广告-》进入主页
class WelComePage extends StatefulWidget {
  const WelComePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => WelComePageState();
}

class WelComePageState extends State<WelComePage> {
  Timer? _timer;
  String loadingText = '正在检测线路';
  bool isPrivacy = true;
  bool inited = false;
  bool isHud = true;
  int curTime = 6;
  bool _isShow = false;
  DateTime? lastPopTime;
  String adsUrl = '';
  String? adsLinkUrl;
  String val = '0';
  List _banner = [
    {
      "url": "assets/images/welcome/banner1.jpg",
      "content": "assets/images/welcome/content5.png"
    },
    {
      "url": "assets/images/welcome/banner2.jpg",
      "content": "assets/images/welcome/content4.png"
    },
    {
      "url": "assets/images/welcome/banner3.jpg",
      "content": "assets/images/welcome/content3.png"
    },
  ];

  Widget getButton(BuildContext context) {
    if (loadingText == '检测线路失败') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              //兼容处理
            },
            child: LocalPNG(
              url: 'assets/images/welcome/checksetting.png',
              height: 50.w,
              fit: BoxFit.fitHeight,
            ),
          ),
          SizedBox(
            width: 25.w,
          ),
          GestureDetector(
            onTap: () {
              _checkline(context);
              loadingText = '正在检测线路';
              this.setState(() {});
            },
            child: LocalPNG(
              url: 'assets/images/welcome/reconnection.png',
              height: 50.w,
              fit: BoxFit.fitHeight,
            ),
          )
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
              width: 30.w,
              height: 30.w,
              child: CircularProgressIndicator(
                backgroundColor: Colors.white,
                strokeWidth: 2.w,
                valueColor: AlwaysStoppedAnimation(StyleTheme.cBioColor),
              )),
          Padding(
            child: Text(
              loadingText,
              style: TextStyle(
                  color: StyleTheme.cBioColor,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.normal,
                  decoration: TextDecoration.none),
            ),
            padding: EdgeInsets.only(top: 10.w),
          )
        ],
      );
    }
  }

  @override
  void initState() {
    super.initState();
    AppGlobal.appContext = context;
    openGuide();
    EventBus().on('checkLine', (arg) {
      _checkline(context);
      isHud = false;
      setState(() {});
    });

    getVipTimestamp();
  }

  void adsCountDown() {
    _isShow = true;
    setState(() {});
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      if (curTime <= 0) {
        setState(() {
          _timer!.cancel();
          _isShow = false;
        });
        return;
      }
      setState(() {
        curTime--;
      });
    });
  }

  Future getVipTimestamp() async {
    try {
      String installTime = SpKeys.installTime;
      String installState = SpKeys.installState;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool checkValue = prefs.containsKey(installTime);
      bool checkinstallState = prefs.containsKey(installState);
      if (checkValue == false) {
        String timestamp = new DateTime.now().millisecondsSinceEpoch.toString();
        prefs.setString(installTime, timestamp);
      }
      if (checkinstallState == false) {
        prefs.setString(installState, '0');
      }
    } catch (e) {}
  }

  void openGuide() {
    PersistentState.getState('isPrivacy').then((val) {
      if (val == '1') {
        AppGlobal.appRouter?.push(CommonUtils.getRealHash('tealist'));
        return;
      } else {
        _checkline(context);
      }
      isHud = false;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer!.cancel();
    EventBus().off('checkLine');
    super.dispose();
  }

  Future<void> sendCodeInvitation(value) async {
    if (value.text == null) return;
    List cliptextList = value.text.split(":").toList();
    if (cliptextList.length > 1) {
      if (cliptextList[0] == 'lcg_aff') {
        if (cliptextList[1] != '') {
          onInvitation(cliptextList[1]);
        }
      }
    }
  }

  void getClipboardText() {
    if (kIsWeb) {
      Uri u = Uri.parse(html.window.location.href);
      String? aff = u.queryParameters['lcg_aff'];
      onInvitation(aff);
    } else {
      Clipboard.getData(Clipboard.kTextPlain).then((value) {
        if (value != null) {
          sendCodeInvitation(value);
        }
      });
    }
  }

  void _checkline(BuildContext context) {
    CommonUtils.checkline(onFailed: () {
      // 所有线路均失败
      loadingText = '检测线路失败';
      _isShow = false;
      this.setState(() {});
    }, onSuccess: () async {
      var result = await getHomeConfig(context);
      print(result);
      adsCountDown();
      adsUrl = result['data']['ads']['img_url'] ?? '';
      adsLinkUrl = result['data']['ads']['url'] ?? '';
      _isShow = true;
      setState(() {});
      var getData1 = getTabList().then((tabres) {
        List tabInfoType = [];
        if (tabres['status'] == 1) {
          if (tabres['data'].length > 0) {
            tabres['data'].forEach((e) => {
                  tabInfoType.add(
                      {'id': e['id'], 'title': e['name'], 'type': e['type']})
                });
            context.read<GlobalState>().setInfoType(tabInfoType);
          }
        }
      });
      // 更新profile信息
      var getData2 = getProfilePage().then((val) {
        if (val!['status'] != 0) {
          context.read<GlobalState>().setProfile(val['data']);
        }
      });
      // 获取粘贴板信息
      getClipboardText();
      // 获取所有城市列表
      var cityResult = getAbroadCity().then((value) {
        if (value != null && value['status'] != 0) {
          context.read<GlobalState>().setCityList(value);
        }
      });
      Future.wait({getData1, getData2, cityResult}).then((value) {
        loadingText = 'OK';
        isHud = false;
        setState(() {});
      });
    });
  }

  bool closeOnConfirm() {
    // 点击返回键的操作
    if (lastPopTime == null ||
        DateTime.now().difference(lastPopTime!) > Duration(seconds: 2)) {
      lastPopTime = DateTime.now();
      BotToast.showText(text: '再按一下退出茶馆～', align: Alignment(0, 0));
      return false;
    } else {
      lastPopTime = DateTime.now();
      // 退出app
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        onPopInvoked: (_) async {
          if (_) {
            return;
          }
          if (closeOnConfirm()) {
            // 系统级别导航栈 退出程序
            await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
          }
        },
        child: Scaffold(
            body: isHud
                ? Center(
                    child: SizedBox(
                        width: 30.w,
                        height: 30.w,
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.white,
                          strokeWidth: 2.w,
                          valueColor:
                              AlwaysStoppedAnimation(StyleTheme.cBioColor),
                        )),
                  )
                : loadingText == '正在检测线路'
                    ? Center(child: getButton(context))
                    : loadingText == 'OK' && _isShow
                        ? Stack(
                            children: [
                              GestureDetector(
                                  onTap: () {
                                    if (adsLinkUrl == '') return;
                                    CommonUtils.launchURL(adsLinkUrl);
                                  },
                                  child: NetImageTool(
                                    url: adsUrl,
                                    fit: BoxFit.cover,
                                  )),
                              Positioned(
                                top: ScreenUtil().statusBarHeight + 10.w,
                                right: 15.w,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 5.w, horizontal: 15.w),
                                  height: 35.w,
                                  decoration: BoxDecoration(
                                    color: Color.fromRGBO(0, 0, 0, .5),
                                    borderRadius: BorderRadius.circular(35.w),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '广告倒计时: $curTime',
                                      style: TextStyle(
                                          decoration: TextDecoration.none,
                                          fontSize: 15.sp,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                        : Home()));
  }
}
