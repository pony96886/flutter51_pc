import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:android_id/android_id.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:chaguaner2023/routers.dart';
import 'package:chaguaner2023/store/global.dart';
import 'package:chaguaner2023/store/homeConfig.dart';
import 'package:chaguaner2023/store/sharedPreferences.dart';
import 'package:chaguaner2023/store/signInConfig.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/index.dart';
import 'package:chaguaner2023/view/im/im.dart';
import 'package:chaguaner2023/view/im/shared.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:isolated_worker/js_isolated_worker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:worker_manager/worker_manager.dart';

void main() async {
  GoRouter.optionURLReflectsImperativeAPIs = true;
  // 初始化数据库，必须放在最前面
  await Hive.initFlutter();
  AppGlobal.appBox = await Hive.openBox('HiveBox'); // 用于存储一些简单的键值对
  AppGlobal.appDb = constructDb();
  AppGlobal.imageCacheBox = await Hive.openBox('HiveBox_ImageCache'); //图片缓存
  //注册图片线程
  await Executor().warmUp();
  if (kIsWeb) {
    AppGlobal.isRegisterJs = await JsIsolatedWorker().importScripts(['js/aware.js?v=2', 'js/crypto-js.min.js?v=3']);
  }
  // 初始化APP基础信息
  AppGlobal.apiToken.value = AppGlobal.appBox!.get('apiToken') ?? '';
  String? authoId = AppGlobal.appBox!.get('oauth_id');
  authoId = authoId == null
      ? CommonUtils.randomId(16).toString() + '_' + DateTime.now().millisecondsSinceEpoch.toString()
      : authoId;
  AppGlobal.appinfo = {
    "oauth_id": authoId,
    "bundleId": "com.pwa.Chaguaner",
    "version": "5.5.1",
    "oauth_type": 'web',
    "language": 'zh',
    "via": 'pwa',
  };
  if (!kIsWeb) {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      const androidIdPlugin = AndroidId();
      final unique = await androidIdPlugin.getId();
      AppGlobal.appinfo = {
        "oauth_id": unique ?? authoId,
        "bundleId": packageInfo.packageName,
        "version": packageInfo.version,
        "oauth_type": "android",
      };
    } else {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      final unique = iosInfo.identifierForVendor;
      AppGlobal.appinfo = {
        "oauth_id": unique ?? authoId,
        "bundleId": packageInfo.packageName,
        "version": "5.5.1",
        "oauth_type": "ios",
        "system_version": iosInfo.systemVersion,
      };
    }
  } else {
    AppGlobal.appBox!.put('oauth_id', AppGlobal.appinfo!['oauth_id']);
  }
  WebSocketUtility.oauthId = AppGlobal.appinfo!['oauth_id'];
  WebSocketUtility.oauthType = AppGlobal.appinfo!['oauth_type'];
  WebSocketUtility.oauthAdsId = AppGlobal.appinfo!['oauth_id'];
  await initializeDateFormatting();
  // GoRouter.setUrlPathStrategy(UrlPathStrategy.path);
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => HomeConfig(),
      ),
      ChangeNotifierProvider(create: (_) => GlobalState()),
      ChangeNotifierProvider(create: (_) => SignInConfig())
    ],
    child: Chaguaner(),
  ));
  CommonUtils.setStatusBar();
}

final _router = AppGlobal.appRouter = Routes.init();

class Chaguaner extends StatefulWidget {
  Chaguaner({Key? key}) : super(key: key);
  @override
  _ChaguanerState createState() => _ChaguanerState();
}

class _ChaguanerState extends State<Chaguaner> with WidgetsBindingObserver {
  bool needUpdate = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    VisibilityDetectorController.instance.updateInterval = Duration(milliseconds: 100);
    if (!kIsWeb) {
      FlutterLocalNotificationsPlugin flnp = FlutterLocalNotificationsPlugin();
      String mip = '@mipmap/ic_launcher';
      flnp.initialize(new InitializationSettings(android: new AndroidInitializationSettings(mip)));
      AppGlobal.flnp = flnp;
    }
  }

  void onUpdate() async {
    if (needUpdate) {
      Map result = await getHomeConfig(context);
      Provider.of<HomeConfig>(context, listen: false).setConfig(result['data']);
      needUpdate = false;
      EventBus().emit('updateElegantCityList');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (Provider.of<HomeConfig>(context, listen: false).member == null) return;
    AppGlobal.appState = state;
    switch (state) {
      case AppLifecycleState.inactive: // 处于这种状态的应用程序应该假设它们可能在任何时候暂停。
        break;
      case AppLifecycleState.resumed: // 应用程序可见，前台
        getCustomerService().then((res) {
          if (res['status'] != 0) {
            UserInfo.kefuList = res['data']['agent_uuid'];
            PersistentState.getState('vipkefu').then((value) {
              if (value != null && value != 'null') {
                var kefuObj = json.decode(value);
                var currenKf = UserInfo.kefuList!.where((item) => item['uuid'] == kefuObj['uuid']).toList();
                if (currenKf.length == 0) {
                  var newKefu = UserInfo.kefuList![Random().nextInt(UserInfo.kefuList!.length)];
                  UserInfo.officialUuid = newKefu['uuid'];
                  UserInfo.officialName = newKefu['nickname'];
                }
              }
            });
          }
        });
        getSystemNotice().then((msg) {
          CommonUtils.debugPrint(msg);
          if (msg != null && msg['status'] != 0) {
            Provider.of<GlobalState>(context, listen: false).setMsgLength(
                msg['data']['systemNoticeCount'] + msg['data']['feedCount'] + msg['data']['groupMessageCount']);
          }
        });
        onUpdate();
        break;
      case AppLifecycleState.paused: // 应用程序不可见，后台
        //关闭IM
        break;
      case AppLifecycleState.detached: // 申请将暂时暂停
        break;
    }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    final botToastBuilder = BotToastInit();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return ScreenUtilInit(
      designSize: Size(375, 667),
      builder: (context, widget) => MaterialApp.router(
        routeInformationProvider: _router.routeInformationProvider,
        routerDelegate: _router.routerDelegate,
        routeInformationParser: _router.routeInformationParser,
        title: '51品茶',
        builder: (context, widget) {
          widget = botToastBuilder(context, widget);
          widget = MediaQuery(
            //设置文字大小不随系统设置改变
            data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.0)),
            child: widget,
          );
          return GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: widget,
          );
        },
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: false,
          scaffoldBackgroundColor: Colors.white,
          primarySwatch: const MaterialColor(
            0xFF000000, //
            <int, Color>{
              50: Color(0xFF000000),
              100: Color(0xFF000000),
              200: Color(0xFF000000),
              300: Color(0xFF000000),
              400: Color(0xFF000000),
              500: Color(0xFF000000),
              600: Color(0xFF000000),
              700: Color(0xFF000000),
              800: Color(0xFF000000),
              900: Color(0xFF000000),
            },
          ),
        ),
      ),
    );
  }
}
