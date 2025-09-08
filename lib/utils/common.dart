import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:bot_toast/bot_toast.dart';
import 'package:chaguaner2023/model/homedata.dart';
import 'package:chaguaner2023/store/homeConfig.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/encdecrypt.dart';
import 'package:chaguaner2023/utils/http.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:chaguaner2023/utils/log_utils.dart' as chaguaner_log;
import 'package:chaguaner2023/utils/network_http.dart';
import 'package:chaguaner2023/view/im/im.dart';
import 'package:common_utils/common_utils.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive/hive.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:convert/src/hex.dart';
import 'package:universal_html/html.dart' as html;

class CommonUtils {
  static String getVipType(int level) {
    List vipItem = AppGlobal.VipList.where((item) => item['vip_level'] == level).toList();
    if (vipItem.isEmpty) {
      return '非会员';
    } else {
      return vipItem[0]['name'];
    }
  }

  static String getVipIcon(int level) {
    List vipItem = AppGlobal.VipList.where((item) => item['vip_level'] == level).toList();
    if (vipItem.isEmpty) {
      return '';
    } else {
      return vipItem[0]['icon_url'];
    }
  }

  static showVipDialog(BuildContext context, String content, {bool isFull = false}) {
    bool isLogin = false;
    if (['', null, false].contains(AppGlobal.apiToken.value)) {
      isLogin = false;
    } else {
      isLogin = true;
    }
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
                        '温馨提示',
                        style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 18.sp, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                        margin: new EdgeInsets.only(top: 20.w),
                        child: isLogin
                            ? Text(
                                isFull ? content : '当前无${content}权限,请前往升级会员',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 14.w, color: StyleTheme.cTitleColor),
                              )
                            : Text(
                                '请登录使用该功能～',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 14.w, color: StyleTheme.cTitleColor),
                              )),
                    GestureDetector(
                      onTap: () {
                        /**[去充值会员]**/
                        Navigator.pop(context);
                        if (isLogin) {
                          AppGlobal.appRouter?.push(CommonUtils.getRealHash('memberCardsPage'));
                        } else {
                          AppGlobal.appRouter?.push(CommonUtils.getRealHash('loginPage/2'));
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
                              isLogin ? '去开通' : '去登录',
                              style: TextStyle(fontSize: 15.sp, color: Colors.white),
                            )),
                          ],
                        ),
                      ),
                    )
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

  //特殊字符处理
  static Widget getContentSpan(
    String text, {
    bool isCopy = false,
    TextStyle? style,
    TextStyle? lightStyle,
  }) {
    style = style ?? TextStyle(color: Color.fromRGBO(30, 30, 30, 1), fontSize: 14.sp);
    lightStyle = lightStyle ?? TextStyle(fontSize: 14.sp, color: const Color.fromRGBO(25, 103, 210, 1));
    List<InlineSpan> _contentList = [];
    RegExp exp = RegExp(r'(http|ftp|https)://([\w_-]+(?:(?:\.[\w_-]+)+))([\w.,@?^=%&:/~+#-]*[\w@?^=%&/~+#-])?');
    Iterable<RegExpMatch> matches = exp.allMatches(text);

    int index = 0;
    for (var match in matches) {
      /// start 0  end 8
      /// start 10 end 12
      String c = text.substring(match.start, match.end);
      if (match.start == index) {
        index = match.end;
      }
      if (index < match.start) {
        String a = text.substring(index, match.start);
        index = match.end;
        _contentList.add(
          TextSpan(text: a, style: style),
        );
      }
      if (RegexUtil.isURL(c)) {
        _contentList.add(TextSpan(
            text: c,
            style: lightStyle,
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                CommonUtils.launchURL(text.substring(match.start, match.end));
              }));
      } else {
        _contentList.add(
          TextSpan(text: c, style: style),
        );
      }
    }
    if (index < text.length) {
      String a = text.substring(index, text.length);
      _contentList.add(
        TextSpan(text: a, style: style),
      );
    }
    if (isCopy) {
      return SelectableText.rich(
        TextSpan(children: _contentList),
        strutStyle: const StrutStyle(forceStrutHeight: true, height: 1, leading: 0.5),
      );
    }
    return RichText(
        textAlign: TextAlign.left,
        text: TextSpan(children: _contentList),
        strutStyle: const StrutStyle(forceStrutHeight: true, height: 1, leading: 0.5));
  }

  static get dio => null;
  static dismissKeyboard(BuildContext context) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      /// 取消焦点，相当于关闭键盘
      FocusManager.instance.primaryFocus!.unfocus();
    }
  }

  static getImPath(BuildContext context, {Function? callBack, bool isHomeconfig = false, int status = 0}) {
    getIm(status).then((res) {
      if (res!['data'] != null) {
        AppGlobal.imUrl = res['data']['im_url'] ?? [];
        WebSocketUtility.imToken = res['data']['chat_token'];
        WebSocketUtility().closeSocket();
        WebSocketUtility.uuid = res['data']['uuid'];
        AppGlobal.bannerImgBase = res['data']['image_url'];
        WebSocketUtility.avatar = res['data']['thumb'].toString();
        WebSocketUtility.nickname = res['data']['nickname'].toString();
        WebSocketUtility().initWebSocket(context, onOpen: () {
          WebSocketUtility().initHeartBeat();
          callBack?.call();
        }, onMessage: (data) {}, onError: (e) {});
      }
    });
  }

  static showNotification({String? title, String? des}) async {
    if (kIsWeb) return;
    var android = new AndroidNotificationDetails('channel id', 'channel NAME',
        priority: Priority.high, importance: Importance.max);
    var platform = new NotificationDetails(android: android);
    await AppGlobal.flnp!.show(0, title, des, platform);
    FlutterRingtonePlayer().play(
      android: AndroidSounds.notification,
      ios: IosSounds.glass,
      looping: false, // Android only - API >= 28
      asAlarm: false, // Android only - all APIs
    );
  }

  static linkToUrl(BuildContext context, String url, int type, {String? title}) {
    title = title == '' ? 'null' : title;
    Member member = Provider.of<HomeConfig>(context, listen: false).member;
    String aff = member.aff!;
    String uuid = member.uuid!;
    String parmas = '?aff=$aff&osid=$uuid';
    switch (type) {
      case 1: //内部跳转
        AppGlobal.appRouter?.push(getRealHash(url));
        break;
      case 2:
        AppGlobal.appRouter?.push(getRealHash('webview/' + Uri.encodeComponent(url + parmas) + '/' + title.toString()));
        break;
      case 3: //外部跳转带参数
        launchURL(url + parmas);
        break;
      case 4: //webview跳转
        launchURL(url);
        break;
      default:
        AppGlobal.appRouter?.push(getRealHash('webview/' + Uri.encodeComponent(url) + '/' + title.toString()));
    }
  }

  static Future getUnreadMsg() {
    return getSystemNotice().then((nres) {
      if (nres['status'] != 0) {
        AppGlobal.systemMessage = (nres['data']['systemNoticeCount'] ?? 0) +
            (nres['data']['feedCount'] ?? 0) +
            (nres['data']['messageCount'] ?? 0) +
            (nres['data']['groupMessageCount'] ?? 0);
        AppGlobal.appDb!.gelUnreadLength(WebSocketUtility.uuid!).then((_v) {
          AppGlobal.unreadMessage.value = (_v ?? 0) + AppGlobal.systemMessage;
        });
        if (nres['data']['message'] != null && nres['data']['message']['nickname'] != null) {
          nres['data']['message']['content'] = [
            {'color': '0xFFFF4149', 'value': nres['data']['message']['nickname'] ?? ''},
            ...nres['data']['message']['content']
          ];
        }
        List _newnoticeList = [
          {
            'title': '系统通知',
            'content': nres['data']['systemNotice'] == null ? null : nres['data']['systemNotice']['content'],
            'time': nres['data']['systemNotice'] == null ? null : nres['data']['systemNotice']['created_at'],
            'router': 'systemNoticePage',
            'readCount': nres['data']['systemNoticeCount'],
            'icon': 'assets/images/system.png',
            'type': '1'
          },
          {
            'title': '解锁和验证',
            'content': nres['data']['message'] == null ? null : nres['data']['message']['content'],
            'time': nres['data']['message'] == null ? '' : nres['data']['message']['created_at'],
            'router': 'unlockPage',
            'readCount': nres['data']['messageCount'],
            'icon': 'assets/images/unlockmsg.png',
            'type': '2'
          },
          {
            'title': '在线客服',
            'content': nres['data']['feed'] == null
                ? null
                : (nres['data']['feed']['message_type'] == 1 ? nres['data']['feed']['question'] : '[图片]'),
            'time': nres['data']['feed'] == null ? null : nres['data']['feed']['created_at'],
            'router': 'onlineServicePage',
            'readCount': nres['data']['feedCount'],
            'icon': 'assets/images/service.png',
            'type': '3'
          },
          {
            'title': '官方通知',
            'content': nres['data']['groupMessage'] == null ? null : nres['data']['groupMessage']['content'],
            'time': nres['data']['groupMessage'] == null ? null : nres['data']['groupMessage']['created_at'],
            'router': 'officeMessage',
            'readCount': nres['data']['groupMessageCount'] ?? 0,
            'icon': 'assets/images/office_msg.png',
            'type': '4'
          }
        ];
        AppGlobal.noticeList.value = [..._newnoticeList];
      } else {
        CommonUtils.showText(nres['msg']);
      }
    });
  }

  static String? getTimeDay(String date) {
    DateTime start = DateTime.parse(date);
    DateTime now = DateTime.now();
    int diffDays = now.difference(start).inDays;
    if (diffDays <= 7) {
      return "最近一周";
    }
    if (diffDays <= 30) {
      return "最近30天";
    }
    if (diffDays <= 180) {
      return "最近180天";
    }
    return null;
  }

  static Widget authorWidget() {
    return Container(
      width: 28.w,
      height: 15.w,
      margin: EdgeInsets.symmetric(horizontal: 7.w),
      alignment: Alignment.center,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2.5.w),
          gradient: LinearGradient(colors: [Color.fromRGBO(255, 56, 103, 1), Color.fromRGBO(255, 107, 159, 1)])),
      child: Text(
        "作者",
        style: TextStyle(color: Colors.white, fontSize: 11.5.sp),
      ),
    );
  }

  /// 秒转为 00:00:00
  static String secondsToString(int seconds) {
    if (seconds <= 0) return '00:00';
    String twoDigits(int n) {
      if (n >= 10) return "$n";
      return "0$n";
    }

    var hours = 0;
    var minutes = 0;
    String strTime = '';
    if (seconds >= 3600) {
      hours = seconds ~/ 3600;
    }
    strTime = twoDigits(hours);
    int time2 = seconds - hours * 3600;
    if (time2 >= 60) {
      minutes = time2 ~/ 60;
    }
    strTime = hours <= 0 ? '${twoDigits(minutes)}' : '$strTime:${twoDigits(minutes)}';
    int time3 = time2 - minutes * 60;
    strTime = '$strTime:${twoDigits(time3)}';
    return strTime;
  }

  static updateUserMoney(BuildContext context, dynamic value) {
    Provider.of<HomeConfig>(context, listen: false).setConsumeMoney(int.parse("${value}"));
  }

  static getCupList() {
    return [
      {'title': 'A罩杯', 'id': 1},
      {'title': 'B罩杯', 'id': 2},
      {'title': 'C罩杯', 'id': 3},
      {'title': 'D罩杯', 'id': 4},
      {'title': 'E罩杯', 'id': 5},
      {'title': 'F+', 'id': 6}
    ];
  }

  static getCup(int id) {
    if (id == null) return '未填写罩杯';
    List cupList = getCupList();
    var cupItem = cupList.where((item) => item['id'] == id).toList();
    return cupItem[0]['title'];
  }

  static getWidth(double _w) {
    return (_w / 2).w;
  }

  static getFontSize(double _sp) {
    return (_sp / 2).sp;
  }

  static getCgTime(int time) {
    getTime(int _num) {
      return _num < 10 ? '0' + _num.toString() : _num;
    }

    var times = new DateTime.fromMillisecondsSinceEpoch(time * 1000);
    dynamic month = getTime(times.month);
    dynamic day = getTime(times.day);
    dynamic hour = getTime(times.hour);
    dynamic minute = getTime(times.minute);
    String cTime = '$month-$day $hour:$minute';
    return '$cTime';
  }

  static getPrintSize(limit) {
    String size = "";
    //内存转换
    if (limit < 0.1 * 1024) {
      //小于0.1KB，则转化成B
      size = limit.toStringAsFixed(3);
      ;
      size = size.substring(0, size.indexOf(".") + 3) + "  B";
    } else if (limit < 0.1 * 1024 * 1024) {
      //小于0.1MB，则转化成KB
      size = (limit / 1024).toStringAsFixed(3);
      size = size.substring(0, size.indexOf(".") + 3) + "  KB";
    } else if (limit < 0.1 * 1024 * 1024 * 1024) {
      //小于0.1GB，转转化成MB
      size = (limit / (1024 * 1024)).toStringAsFixed(3);
      ;
      print(size.indexOf("."));
      size = size.substring(0, size.indexOf(".") + 3) + "  MB";
    } else {
      //其他转化成GB
      size = (limit / (1024 * 1024 * 1024)).toStringAsFixed(3);
      ;
      size = size.substring(0, size.indexOf(".") + 3) + "  GB";
    }
    return size;
  }

  static bool getTextLine(
      {String textContent = '',
      double remainingSpace = 0, //文字左右的空间
      TextSpan? textSpan,
      int maxLines = 1,
      TextStyle? style}) {
    var text = textContent;
    if (textSpan == null) {
      final span = TextSpan(text: text, style: style);
      final tp = TextPainter(text: span, maxLines: maxLines, textDirection: TextDirection.ltr);
      tp.layout(maxWidth: 1.sw - remainingSpace);
      return tp.didExceedMaxLines;
    } else {
      final tp = TextPainter(text: textSpan, maxLines: maxLines, textDirection: TextDirection.ltr);
      tp.layout(maxWidth: 1.sw - remainingSpace);
      return tp.didExceedMaxLines;
    }
  }

  static Future<Size> calculateImageDimension(dynamic url) {
    Completer<Size> completer = Completer();
    Image image = Image.file(File(url));
    image.image.resolve(ImageConfiguration()).addListener(
      ImageStreamListener(
        (ImageInfo image, bool synchronousCall) {
          var myImage = image.image;
          Size size = Size(myImage.width.toDouble(), myImage.height.toDouble());
          completer.complete(size);
        },
      ),
    );
    return completer.future;
  }

  static bool isAndroidWeb() {
    return kIsWeb &&
        (html.window.navigator.userAgent.indexOf('Android') > -1 ||
            html.window.navigator.userAgent.indexOf('Linux') > -1);
  }

  // static updateSystemNotice(context) async {
  //   SystemNotice sysResult = await getSystemNotice();
  //   CommonUtils.debugPrint(sysResult.toJson());
  //   if (sysResult.status == 1) {
  //     Provider.of<HomeConfig>(context, listen: false)
  //         .setSystemNotice(sysResult);
  //   }
  // }

  static showText(String text, {int? time}) {
    return BotToast.showText(
        text: text,
        textStyle: TextStyle(
            color: Color.fromRGBO(255, 255, 255, 1), fontSize: ScreenUtil().setSp(15), decoration: TextDecoration.none),
        align: Alignment(0, 0),
        duration: Duration(seconds: time ?? 3));
  }

  static getHMTime(int time) {
    getTime(int _num) {
      return _num < 10 ? '0' + _num.toString() : _num;
    }

    var times = new DateTime.fromMillisecondsSinceEpoch(time * 1000);
    String cTime = getTime(times.hour).toString() + ':' + getTime(times.minute).toString();
    return '$cTime';
  }

  // 检查安装未知安装包
  static checkRequestInstallPackages() async {
    if (kIsWeb) return;
    if (Platform.isAndroid) {
      PermissionStatus _status = await Permission.requestInstallPackages.status;
      if (_status == PermissionStatus.granted) {
        return true;
      } else if (_status == PermissionStatus.permanentlyDenied) {
        CommonUtils.showText('您拒绝了安装未知应用权限，所以无法安装，请前往官网下载。');
        return false;
      } else {
        await Permission.requestInstallPackages.request();
        return true;
      }
    }
  }

  ///检查是否有权限
  static checkStoragePermission() async {
    if (kIsWeb) return;
    //检查是否已有读写内存权限
    if (Platform.isAndroid) {
      PermissionStatus storageStatus = await Permission.storage.status;
      if (storageStatus == PermissionStatus.granted) {
        return true;
      } else if (storageStatus == PermissionStatus.permanentlyDenied) {
        CommonUtils.showText('您拒绝了存储权限，未避免账号丢失，请前往设置中打开存储权限');
        return false;
      } else {
        await Permission.storage.request();
        return true;
      }
    }
  }

  static renderFixedNumber(num value) {
    var tips;
    if (value >= 10000) {
      var newvalue = (value / 1000) / 10.round();
      tips = newvalue.toStringAsFixed(2) + "W";
    } else if (value >= 1000) {
      var newvalue = (value / 100) / 10.round();
      tips = newvalue.toStringAsFixed(2) + "K";
    } else {
      tips = value.toString().split('.')[0];
    }
    return tips;
  }

  static formatNum(double number, int postion) {
    if ((number.toString().length - number.toString().lastIndexOf(".") - 1) < postion) {
      //小数点后有几位小数
      return number.toStringAsFixed(postion).substring(0, number.toString().lastIndexOf(".") + postion + 1).toString();
    } else {
      return number.toString().substring(0, number.toString().lastIndexOf(".") + postion + 1).toString();
    }
  }

  static launchURL(String? url) async {
    try {
      // ignore: deprecated_member_use
      await launch(url!, forceSafariVC: false);
    } catch (e) {
      BotToast.showText(text: '网址错误');
    }
  }

  static String getRealHash(String value) {
    return '/' + value;
  }

  static void debugPrint(value) {
    const bool inProduction = const bool.fromEnvironment("dart.vm.product");
    if (!inProduction) {
      chaguaner_log.LogUtilS.d(value);
    }
  }

  static String randomId(int range) {
    String str = "";
    List<String> arr = [
      "0",
      "1",
      "2",
      "3",
      "4",
      "5",
      "6",
      "7",
      "8",
      "9",
      "a",
      "b",
      "c",
      "d",
      "e",
      "f",
      "g",
      "h",
      "i",
      "j",
      "k",
      "l",
      "m",
      "n",
      "o",
      "p",
      "q",
      "r",
      "s",
      "t",
      "u",
      "v",
      "w",
      "x",
      "y",
      "z",
      "A",
      "B",
      "C",
      "D",
      "E",
      "F",
      "G",
      "H",
      "I",
      "J",
      "K",
      "L",
      "M",
      "N",
      "O",
      "P",
      "Q",
      "R",
      "S",
      "T",
      "U",
      "V",
      "W",
      "X",
      "Y",
      "Z"
    ];
    for (int i = 0; i < range; i++) {
      int pos = new Random().nextInt(arr.length - 1);
      str += arr[pos];
    }
    return str;
  }

  static String gvMD5(String data) {
    var content = Utf8Encoder().convert(data);
    var digest = md5.convert(content);
    var text = hex.encode(digest.bytes);
    return text;
  }

  static String getRandomThumb() {
    int random = new Random().nextInt(29);
    return 'assets/images/random/${random + 1}.jpg';
  }

  static String gvSha256(String data) {
    var content = Utf8Encoder().convert(data);
    var digest = sha256.convert(content);
    var text = hex.encode(digest.bytes);
    return text;
  }

  static String getYYYYMMDD(DateTime dateTime, String space) {
    String year = dateTime.year.toString();
    String month = dateTime.month.toString().length == 1 ? "0${dateTime.month}" : dateTime.month.toString();
    String day = dateTime.day.toString().length == 1 ? "0${dateTime.day}" : dateTime.day.toString();
    return "${year}${space}${month}${space}${day}";
  }

  static String getDays(int days) {
    if (days / 30 >= 12) {
      return '${((days / 30) / 12).round()}年';
    } else if (days / 30 >= 1) {
      return '${(days / 30).round()}个月';
    } else {
      return '$days天';
    }
  }

  static String getTomorrowDayYYYYMMDD(DateTime dateTime, int day) {
    DateTime yesterDay =
        new DateTime.fromMillisecondsSinceEpoch(dateTime.millisecondsSinceEpoch + ((day * 24) * 60 * 60 * 1000));
    return getYYYYMMDD(yesterDay, "-");
  }

  static void checkline({Function? onSuccess, Function? onFailed}) async {
    Box box = AppGlobal.appBox!;
    String? lineS = box.get('api_lines');
    List<String> unChecklines = [];
    if (lineS == null) {
      unChecklines = AppGlobal.apiLines;
    } else {
      String lineL = await EncDecrypt.decryptLine(lineS);
      unChecklines = lineL.split(',');
    }
    List<Map> errorLines = [];
    // int errorCount = 0;
    Function checkGit;
    Function doCheck;
    Function handleResult;

    Function reportErrorLines = () async {
      // 上报错误线路&保存服务端推荐线路到本地
      if (errorLines.isEmpty) return;
      Response res = await NetworkHttp.instance.post('/api/home/domainCheckReport', data: {'list': errorLines});
      CommonUtils.debugPrint("============reportErrorLines============");
      CommonUtils.debugPrint(res.data['data']);
    };

    handleResult = (String line) async {
      if (line.isNotEmpty) {
        AppGlobal.apiBaseURL = line;
        await reportErrorLines();
        onSuccess!.call();
      } else {
        onFailed!.call();
      }
    };

    checkGit = () async {
      String git = box.get("github_url") == null ? AppGlobal.gitLine : box.get("github_url").toString();
      dynamic result;
      if (kIsWeb) {
        result = await html.HttpRequest.request(git ?? "", method: "GET")
            .then((value) => value.response)
            .timeout(const Duration(milliseconds: 5 * 1000));
      } else {
        result = await Dio(BaseOptions(connectTimeout: Duration(seconds: 5), receiveTimeout: Duration(seconds: 5)))
            .get(git ?? "");
      }

      handleResult(result.toString().trim());
    };

    doCheck = ({String line = ""}) async {
      if (line.isEmpty) return;
      if (!kIsWeb) {
        try {
          Response<dynamic> resp = await Dio(BaseOptions(
            connectTimeout: Duration(seconds: 5),
            receiveTimeout: Duration(seconds: 5),
          )).get("https://wvseee.jsbacjr.com/cg.txt");
          if (resp.statusCode == 200) {
            AppGlobal.appBox!.put("fds_key", resp.data.toString().replaceAll("\n", "") ?? "");
          }
        } catch (_) {
          try {
            Response<dynamic> resp =
                await Dio(BaseOptions(connectTimeout: Duration(seconds: 5), receiveTimeout: Duration(seconds: 5)))
                    .get("https://gitee.com/fdsaw/ffewelmcxww/raw/master/cg.txt");
            if (resp.statusCode == 200) {
              AppGlobal.appBox!.put("fds_key", resp.data.toString().replaceAll("\n", "") ?? "");
            }
          } catch (_) {}
        }
      }
      dynamic result;
      try {
        if (kIsWeb) {
          result = await html.HttpRequest.request('$line/api/callback/checkLine', method: "POST")
              .then((value) => value.response)
              .timeout(const Duration(milliseconds: 5 * 1000));
        } else {
          result = await Dio(BaseOptions(
                  headers: {'Cf-Ray-Xf': await EncDecrypt.secretValue()},
                  connectTimeout: Duration(seconds: 5),
                  receiveTimeout: Duration(seconds: 5)))
              .post('$line/api/callback/checkLine');
        }
      } catch (err) {
        result = 'error';
      }
      if (result == 'error') {
        // errorCount++;
        errorLines.add({'url': line});
        //启用备用github线路
        if (errorLines.length == unChecklines.length && unChecklines.length > 1) {
          checkGit();
        }
      } else if (result.toString() == '200') {
        handleResult(line);
      }
    };

    final List<ConnectivityResult> connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.none)) {
      onFailed!.call();
    } else {
      for (var i = 0; i < unChecklines.length; i++) {
        if (AppGlobal.apiBaseURL.isEmpty) {
          await doCheck(line: unChecklines[i]);
        } else {
          break;
        }
      }
    }
  }

  //设置状态栏颜色
  static setStatusBar({bool isLight = false}) {
    if (kIsWeb) {
      return SystemChrome.setSystemUIOverlayStyle(isLight ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark);
    } else if (Platform.isAndroid) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, //全局设置透明
        statusBarIconBrightness: isLight ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: isLight ? Colors.black : Colors.white,
      );
      SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
    } else if (Platform.isIOS) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      //导航栏状态栏文字颜色
      SystemChrome.setSystemUIOverlayStyle(isLight ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark);
    }
  }

  //设置状态栏颜色
  static setStatusBarShow({bool isHide = false}) {
    if (kIsWeb) {
      return;
    } else if (isHide) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top]);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    }
  }

  static getThumb(dynamic data) {
    if (data['img_url'] != null && data['img_url'] != '') {
      return data['img_url'];
    } else if (data['url_str'] != null && data['url_str'] != '') {
      return data['url_str'];
    } else if (data['url'] != null && data['url'] != '') {
      return data['url'];
    } else if (data['resource_url'] != null && data['resource_url'] != '') {
      return data['resource_url'];
    } else if (data['thumb_horizontal'] != null && data['thumb_horizontal'] != '') {
      return data['thumb_horizontal'];
    } else if (data['thumb_vertical'] != null && data['thumb_vertical'] != '') {
      return data['thumb_vertical'];
    } else if (data['cover_thumb_horizontal'] != null && data['cover_thumb_horizontal'] != '') {
      return data['cover_thumb_horizontal'];
    } else if (data['cover_thumb_vertical'] != null && data['cover_thumb_vertical'] != '') {
      return data['cover_thumb_vertical'];
    } else if (data['cover_horizontal'] != null && data['cover_horizontal'] != '') {
      return data['cover_horizontal'];
    } else if (data['cover_vertical'] != null && data['cover_vertical'] != '') {
      return data['cover_vertical'];
    } else if (data['thumb_horizontal_url'] != null && data['thumb_horizontal_url'] != '') {
      return data['thumb_horizontal_url'];
    } else if (data['cover'] != null && data['cover'] != '') {
      return data['cover'];
    } else if (data['thumb'] != null && data['thumb'] != '') {
      return data['thumb'];
    } else if (data['media_url_full'] != null && data['media_url_full'] != '') {
      return data['media_url_full'];
    } else if (data['media_full_url'] != null && data['media_full_url'] != '') {
      return data['media_full_url'];
    } else {
      return data['thumb_vertical_url'] ?? "";
    }
  }

  static Future<T?> routerTo<T>(String router, {Object? extra, bool replace = false}) async {
    var res;
    if (replace) {
      res = await AppGlobal.appRouter?.replace('/$router', extra: extra);
    } else {
      res = await AppGlobal.appRouter?.push('/$router', extra: extra);
    }
    return res;
  }

  static List<List<dynamic>> chunkList(List<dynamic> list, int chunkSize) {
    List<List<dynamic>> chunks = [];
    for (var i = 0; i < list.length; i += chunkSize) {
      int end = (i + chunkSize < list.length) ? i + chunkSize : list.length;
      chunks.add(list.sublist(i, end));
    }
    return chunks;
  }
}

class RelativeDateFormat {
  static final num oneMinute = 60000;
  static final num oneHour = 3600000;
  static final num oneDay = 86400000;
  static final num oneWeek = 604800000;

  static final String oneSecondAgo = "秒前";
  static final String oneMinuteAgo = "分钟前";
  static final String oneHourAgo = "小时前";
  static final String oneDayAgo = "天前";
  static final String oneMonthAgo = "月前";
  static final String oneYearAgo = "年前";

//时间转换
  static String format(DateTime date) {
    num delta = DateTime.now().millisecondsSinceEpoch - date.millisecondsSinceEpoch;

    if (delta < 1 * oneMinute) {
      num seconds = toSeconds(delta);
      return (seconds <= 0 ? 1 : seconds).toInt().toString() + oneSecondAgo;
    }
    if (delta < 60 * oneMinute) {
      num minutes = toMinutes(delta);
      return (minutes <= 0 ? 1 : minutes).toInt().toString() + oneMinuteAgo;
    }
    if (delta < 24 * oneHour) {
      num hours = toHours(delta);
      return (hours <= 0 ? 1 : hours).toInt().toString() + oneHourAgo;
    }
    if (delta < 48 * oneHour) {
      return "昨天";
    }
    if (delta < 30 * oneDay) {
      num days = toDays(delta);
      return (days <= 0 ? 1 : days).toInt().toString() + oneDayAgo;
    }
    if (delta < 12 * 4 * oneWeek) {
      num months = toMonths(delta);
      return (months <= 0 ? 1 : months).toInt().toString() + oneMonthAgo;
    } else {
      num years = toYears(delta);
      return (years <= 0 ? 1 : years).toInt().toString() + oneYearAgo;
    }
  }

  static num toSeconds(num date) {
    return date / 1000;
  }

  static num toMinutes(num date) {
    return toSeconds(date) / 60;
  }

  static num toHours(num date) {
    return toMinutes(date) / 60;
  }

  static num toDays(num date) {
    return toHours(date) / 24;
  }

  static num toMonths(num date) {
    return toDays(date) / 30;
  }

  static num toYears(num date) {
    return toMonths(date) / 12;
  }
}

extension SetTimeNum on num {
  String get toTime => this == null ? '00' : (this < 10 ? '0$this' : this.toString());
}
