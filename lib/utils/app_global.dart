/*
 * @Author: Tom
 * @Date: 2021-12-29 16:03:08
 * @LastEditTime: 2021-12-29 16:03:28
 * @LastEditors: Tom
 * @Description: 
 * @FilePath: /flutter2021/lib/global.dart
 */
// 应用级全局变量
import 'package:chaguaner2023/view/im/im_page.dart';
import 'package:chaguaner2023/view/im/imdb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:flutter_emoji/flutter_emoji.dart';

class AppGlobal {
  // 全局路由实例
  static String? comicThumb; //避免传参，用来记录漫画封面
  static Map? appinfo;
  static String apiBaseURL = "";
  static FlutterLocalNotificationsPlugin? flnp;
  static AppLifecycleState appState = AppLifecycleState.resumed;
  static List<String> apiLines = kIsWeb
      ? [
          "https://vbwtbv.ekmdgwv.top",
          "https://api.eltvbda.top",
        ]
      : [
          "https://vbwtbv.ellvqfsd.top",
          "https://v2.eltvbda.top",
          "https://v2.ellvqfsd.top",
        ];
  static String gitLine =
      'https://raw.githubusercontent.com/ailiu258099-blip/master/main/lcg.txt';
  // 测试服"https://squid.yesebo.net/api.php"
  static String uploadImgUrl = '';
  static int publishPostType = 0; //0: 店家分享, 1: 个人分享
  static String uploadImgKey = '';
  static String bannerImgBase = '';
  static ValueNotifier<String> apiToken = ValueNotifier<String>('');
  static Box? appBox;
  static int decryptProcessLimit = 20;
  static Box? imageCacheBox;
  static List helpList = [];
  static int isSetPassword = 0;
  static String officeSite = '';
  static int vipLevel = 0;
  static bool isNewVersion = true;
  static BuildContext? appContext;
  static GoRouter? appRouter;
  static bool routerReplace = false;
  static String m3u8_encrypt = '';
  static bool shouApp = false;
  static bool apInit = false;
  static double webBottomHeight = 0.0;
  static bool isFull = false; //是否全屏
  static EmojiParser emoji = EmojiParser();
  static int aff = 0;
  static String uuid = '0';
  // static AppDb appDb;
  static bool isSelf = false;
  static List<dynamic> imUrl = [];
  static int overlayEntryIndex = 0;
  static Map<int, OverlayEntry> overlayEntry = {};
  static String socketUrl = '';
  static String uploadVideoKey = '';
  static String uploadVideoUrl = '';
  static String uploadBigVideoKey = '';
  static String uploadBigVideoUrl = '';
  static bool cgShow = true;
  static bool showActivity = true;
  static Map imMessageNumber = {};
  static Map mallOrder = {};
  static ValueNotifier<int> unreadMessage = ValueNotifier<int>(0);
  static ValueNotifier<List> noticeList = ValueNotifier<List>([
    {
      'title': '系统通知',
      'content': '',
      'time': '',
      'router': '',
      'readCount': 0,
      'icon': 'assets/images/system.png',
      'type': '1'
    },
    {
      'title': '解锁和验证',
      'content': '',
      'time': '',
      'router': '',
      'readCount': 0,
      'icon': 'assets/images/unlockmsg.png',
      'type': '2'
    },
    {
      'title': '在线客服',
      'content': '',
      'time': '',
      'router': '',
      'readCount': 0,
      'icon': 'assets/images/service.png',
      'type': '3'
    },
    {
      'title': '官方消息',
      'content': '',
      'time': '',
      'router': '',
      'readCount': 0,
      'icon': 'assets/images/office_msg.png',
      'type': '4'
    }
  ]);
  static int systemMessage = 0;
  static AppDb? appDb;
  static ValueNotifier<String> userCity = ValueNotifier<String>('北京市');
  static ValueNotifier<bool> isPrivacy = ValueNotifier<bool>(false);
  static Map? uploadParmas = {}; //上传参数 传值
  static Map girlParmas = {}; //茶女郎上传参数
  static Map blackList = {}; //黑榜类型
  static ValueNotifier<List<ContaictData>> accountContact =
      ValueNotifier<List<ContaictData>>([]);
  static FormUserMsg? chatUser;

  static Map picMap = {};

  static bool isRegisterJs = false;
  static List popAds = [];
  static Map publishRule = {}; //发布规则
  static Map useCopperCoinsTips = {}; //铜钱用途
  static List VipList = []; //会员列表
  static Map userPrivilege = {}; //权限
  static Function()? connetGirl; // 跳转联系方式
  static int enableGirlChat = 1;
  static List popAppAds = [];
  static int switchFavoriteTab = 1; // 切换收藏tab
}
