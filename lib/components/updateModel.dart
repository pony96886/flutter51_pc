import 'dart:io';

import 'package:app_installer/app_installer.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/http.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:chaguaner2023/utils/netimage_tool.dart';
import 'package:flutter/material.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:path_provider/path_provider.dart';

import '../utils/cache/image_net_tool.dart';
import '../utils/network_http.dart';

class UpdateModel {
  static void showAnnouncementDialog(BackButtonBehavior backButtonBehavior,
      {VoidCallback? cancel, VoidCallback? confirm, VoidCallback? confirmApp, String? text, String? type}) {
    var tipSplit = text!.split('#');
    String iknow = '朕知道了';
    tipWidget(String value) {
      return Text(
        value,
        style: TextStyle(
          color: Color(0xFF902426),
          fontSize: 14.sp,
          decoration: TextDecoration.none,
          fontWeight: FontWeight.normal,
        ),
      );
    }

    HtmlUnescape unescape = HtmlUnescape();
    String decodedString = unescape.convert(text);
    Widget content = Html(
      shrinkWrap: true,
      data: decodedString,
      style: {
        "*": Style(
          color: Color(0xFF902426),
          lineHeight: LineHeight.rem(1.5),
          margin: Margins.zero,
        ),
        "a": Style(
          color: Colors.red,
          textDecoration: TextDecoration.underline,
        )
      },
      onLinkTap: (url, context, attributes, element) {
        CommonUtils.launchURL(url ?? "");
      },
    );
    tipsWidget() {
      return tipSplit.map((value) {
        Widget widget = tipWidget(value);
        return widget;
      }).toList();
    }

    List<Widget> newTipsWidget = tipsWidget();
    newTipsWidget.add(Container(
      width: double.infinity,
    ));
    BotToast.showWidget(
        toastBuilder: (cancelFunc) => Container(
              padding: EdgeInsets.all(57.5.w),
              decoration: BoxDecoration(color: Colors.black38),
              child: Material(
                  color: Colors.transparent,
                  child: Center(
                    child: Stack(
                      children: <Widget>[
                        Container(
                          width: 260.w,
                          height: 285.w,
                          child: Stack(
                            children: [
                              LocalPNG(
                                width: 260.w,
                                height: 285.w,
                                url: "assets/images/announcement.png",
                                alignment: Alignment.center,
                              ),
                              Container(
                                width: double.infinity,
                                height: double.infinity,
                                padding: EdgeInsets.only(top: 66.5.w, left: 28.w, right: 28.w, bottom: 20.w),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    SizedBox(
                                      height: 142.5.w,
                                      child: ListView(
                                        children: [content],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                            left: 42.5.w,
                            bottom: 25.w,
                            child: GestureDetector(
                              onTap: () {
                                cancelFunc();
                                type == "1" ? confirm!.call() : confirmApp!.call();
                              },
                              child: Container(
                                width: 175.w,
                                height: 41.w,
                                child: Stack(
                                  children: [
                                    LocalPNG(
                                      width: 175.w,
                                      height: 41.w,
                                      url: "assets/images/updatebutton.png",
                                      alignment: Alignment.center,
                                      fit: BoxFit.cover,
                                    ),
                                    Center(
                                        child: Text(type == "1" ? iknow : '我要赚钱',
                                            style: TextStyle(
                                                color: Color(0xFFB0292B),
                                                fontSize: 15.sp,
                                                decoration: TextDecoration.none,
                                                fontWeight: FontWeight.w500))),
                                  ],
                                ),
                              ),
                            )),
                        Positioned(
                          top: 15.w,
                          right: 15.w,
                          child: GestureDetector(
                              onTap: () {
                                cancelFunc();
                                cancel?.call();
                              },
                              child: LocalPNG(
                                  url: "assets/images/closeicon.png",
                                  width: 25.w,
                                  height: 25.w,
                                  alignment: Alignment.center,
                                  fit: BoxFit.cover)),
                        ),
                      ],
                    ),
                  )),
            ));
  }

  static void showUpdateDialog(BackButtonBehavior backButtonBehavior,
      {VoidCallback? cancel,
      VoidCallback? confirm,
      VoidCallback? gowebsite,
      String? version,
      String? text,
      bool? mustupdate}) {
    var tipSplit = text!.split('#');
    tipWidget(String value) {
      return Text.rich(
        TextSpan(children: [TextSpan(text: value)]),
        style: TextStyle(
          color: Color(0xFFFFCD69),
          fontSize: 14.w,
          decoration: TextDecoration.none,
          fontWeight: FontWeight.normal,
        ),
      );
    }

    tipsWidget() {
      return tipSplit.map((value) {
        Widget widget = tipWidget(value);
        return widget;
      }).toList();
    }

    List<Widget> newTipsWidget = tipsWidget();
    newTipsWidget.add(Container(
      width: double.infinity,
    ));

    BotToast.showWidget(
        toastBuilder: (cancelFunc) => Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(color: Colors.black38),
              child: Center(
                child: Stack(
                  children: <Widget>[
                    Container(
                      width: 335.w,
                      height: 495.w,
                      child: Stack(
                        children: [
                          LocalPNG(
                            width: 335.w,
                            height: 495.w,
                            url: "assets/images/updateapp.png",
                            alignment: Alignment.center,
                          ),
                          Container(
                            width: double.infinity,
                            height: double.infinity,
                            padding: EdgeInsets.only(top: 180.w, left: 75.w, right: 70.w, bottom: 24.5.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  "$version",
                                  style: TextStyle(
                                      color: Color(0xFFFFCD69),
                                      fontSize: 15.w,
                                      decoration: TextDecoration.none,
                                      fontWeight: FontWeight.w500),
                                  textAlign: TextAlign.left,
                                ),
                                SizedBox(
                                  height: 20.w,
                                ),
                                SizedBox(
                                  height: 142.5.w,
                                  child: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: newTipsWidget,
                                    ),
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.center,
                                  child: GestureDetector(
                                    onTap: () {
                                      gowebsite!.call();
                                    },
                                    child: Text(
                                      '无法更新，点击前往官网下载',
                                      style: TextStyle(
                                          color: Color(0xFFFFCD69),
                                          decoration: TextDecoration.underline,
                                          decorationColor: Color(0xFFFFCD69),
                                          decorationStyle: TextDecorationStyle.solid,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 11.sp),
                                    ),
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 3.w),
                                  margin: EdgeInsets.only(top: 57.w),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                        left: 80.w,
                        bottom: 74.5.w,
                        child: GestureDetector(
                          onTap: () {
                            if (!mustupdate!) {
                              cancelFunc();
                            } else if (mustupdate && Platform.isAndroid) {
                              cancelFunc();
                            }
                            confirm!.call();
                          },
                          child: Container(
                            width: 175.w,
                            height: 41.w,
                            child: Stack(
                              children: [
                                LocalPNG(
                                  width: 175.w,
                                  height: 41.w,
                                  url: "assets/images/updatebutton.png",
                                  alignment: Alignment.center,
                                  fit: BoxFit.cover,
                                ),
                                Center(
                                    child: Text('立即更新',
                                        style: TextStyle(
                                            color: Color(0xFFB0292B),
                                            fontSize: 15.w,
                                            decoration: TextDecoration.none,
                                            fontWeight: FontWeight.w500))),
                              ],
                            ),
                          ),
                        )),
                    mustupdate!
                        ? SizedBox()
                        : Positioned(
                            top: 44.w,
                            right: 20.w,
                            child: GestureDetector(
                              onTap: () {
                                cancelFunc();
                                cancel?.call();
                              },
                              child: LocalPNG(
                                  width: 25.w,
                                  height: 25.w,
                                  url: "assets/images/closeicon.png",
                                  alignment: Alignment.center,
                                  fit: BoxFit.cover),
                            ),
                          ),
                  ],
                ),
              ),
            ));
  }

  static void androidUpdate(BackButtonBehavior backButtonBehavior,
      {VoidCallback? cancel, String? url, String? version}) {
    BotToast.showWidget(
      toastBuilder: (cancelFunc) => DownloadApk(
        url: url!,
        version: version!,
        onTap: () {
          cancelFunc();
          cancel?.call();
        },
      ),
    );
  }

  static void showAvtivetysDialog(BackButtonBehavior backButtonBehavior,
      {VoidCallback? cancel, VoidCallback? confirm, String? url}) {
    BotToast.showWidget(
      toastBuilder: (cancelFunc) => GestureDetector(
        onTap: () {
          cancelFunc();
          cancel?.call();
        },
        child: Container(
          constraints: BoxConstraints(
            maxHeight: 1.sh,
          ),
          width: 1.sw,
          padding: EdgeInsets.only(top: ScreenUtil().statusBarHeight, bottom: ScreenUtil().bottomBarHeight),
          decoration: BoxDecoration(color: Colors.black38),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                    onTap: () {
                      cancelFunc();
                      cancel?.call();
                    },
                    child: LocalPNG(
                        width: 32.5.w,
                        height: 32.5.w,
                        url: "assets/images/home/accloseicon.png",
                        alignment: Alignment.center,
                        fit: BoxFit.cover)),
                SizedBox(height: 10.w),
                Container(
                  constraints: BoxConstraints(
                      minHeight: 90.w,
                      maxHeight: 1.sh - ScreenUtil().bottomBarHeight - ScreenUtil().statusBarHeight - 150.w),
                  child: GestureDetector(
                    onTap: () {
                      cancelFunc();
                      confirm?.call();
                    },
                    child: SizedBox(
                      height: 1.sw / 3 * 2,
                      width: 1.sw / 3 * 2,
                      child: ImageNetTool(
                        url: url!.contains('http') ? url : AppGlobal.bannerImgBase + url,
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void showCompartmentDialog({VoidCallback? cancel, String? url}) {
    BotToast.showWidget(
      toastBuilder: (cancelFunc) => Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: () {
            cancelFunc();
            cancel?.call();
          },
          child: Container(
            color: Colors.black45,
            child: Center(
              child: Container(
                width: 315.w,
                height: 380.w,
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 10.w),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(8.w),
                ),
                child: SingleChildScrollView(
                  physics: ClampingScrollPhysics(),
                  child: GridView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: AppGlobal.popAppAds.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          childAspectRatio: 0.75, crossAxisCount: 4, mainAxisSpacing: 15.w, crossAxisSpacing: 15.w),
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            CommonUtils.launchURL(AppGlobal.popAppAds[index]['link_url']);
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 60.w,
                                height: 60.w,
                                child: ImageNetTool(
                                  url: AppGlobal.popAppAds[index]['img_url'],
                                  radius: BorderRadius.circular(5.w),
                                ),
                              ),
                              SizedBox(
                                height: 5.w,
                              ),
                              Text(
                                AppGlobal.popAppAds[index]['title'],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: Colors.white, fontSize: 12.sp),
                              )
                            ],
                          ),
                        );
                      }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DownloadApk extends StatefulWidget {
  final GestureTapCallback? onTap;
  final String? url;
  final String? version;

  DownloadApk({Key? key, this.onTap, this.url, this.version}) : super(key: key);

  @override
  _DownloadApkState createState() => _DownloadApkState();
}

class _DownloadApkState extends State<DownloadApk> {
  int progress = 0;
  Future<Null> _installApk(savePath) async {
    try {
      await CommonUtils.checkRequestInstallPackages();
      await CommonUtils.checkStoragePermission();
      AppInstaller.installApk(savePath).then((result) {}).catchError((error) {});
    } on Exception catch (_) {}
  }

  @override
  void initState() {
    super.initState();
    getExternalStorageDirectory().then((documents) {
      String savePath = '${documents!.path}/chaguan.${DateTime.now().millisecondsSinceEpoch}.apk';
      NetworkHttp.instance.download(widget.url!, savePath, onReceiveProgress: (int count, int total) {
        var tmp = (count / total * 100).toInt();
        if (tmp % 1 == 0) {
          setState(() {
            progress = tmp;
          });
        }
        if (count >= total) {
          _installApk(savePath);
        }
      }).catchError((err) {
        BotToast.cleanAll();
        BotToast.showText(text: '网络不好，新版本下载失败，请稍后重试');
        CommonUtils.debugPrint('下载地址:${widget.url};错误:$err');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(color: Colors.black38),
        child: Center(
          child: Stack(
            children: <Widget>[
              Container(
                width: 335.w,
                height: 308.w,
                child: Stack(
                  children: [
                    LocalPNG(
                      width: 335.w,
                      height: 308.w,
                      url: "assets/images/updatepackge.png",
                      alignment: Alignment.center,
                    ),
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      padding: EdgeInsets.only(top: 180.w, left: 75.w, right: 70.w, bottom: 50.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "正在更新 v.${widget.version}",
                            style: TextStyle(
                                color: Color(0xFFFFCD69),
                                fontSize: 15.w,
                                decoration: TextDecoration.none,
                                fontWeight: FontWeight.w500),
                            textAlign: TextAlign.left,
                          ),
                          SizedBox(
                            height: 20.w,
                          ),
                          SizedBox(
                            width: 335.w,
                            height: 4.w,
                            child: Stack(
                              children: <Widget>[
                                ClipRRect(
                                  borderRadius: BorderRadius.all(Radius.circular(2.w)),
                                  child: Stack(
                                    children: <Widget>[
                                      Container(
                                        width: 185.w,
                                        height: 4.w,
                                        decoration: BoxDecoration(color: Color(0xFFB84244)),
                                      ),
                                      Positioned(
                                        left: 0,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.all(Radius.circular(2.w)),
                                          child: Container(
                                            width: progress / 100 * 185.w,
                                            height: 4.w,
                                            decoration: BoxDecoration(color: Color(0xFFFFCD69)),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 12.w,
                          ),
                          Center(
                            child: Text('$progress%',
                                style: TextStyle(
                                    color: Color(0xFFFFCD69),
                                    fontSize: 15.sp,
                                    decoration: TextDecoration.none,
                                    fontWeight: FontWeight.w500)),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Positioned(
              //         top: GVScreenUtil.setWidth(88),
              //         right: GVScreenUtil.setWidth(40),
              //         child: GestureDetector(
              //           onTap: () {
              //             widget.onTap();
              //             Navigator.pop(context);
              //           },
              //           child: Container(
              //             width: GVScreenUtil.setWidth(50),
              //             height: GVScreenUtil.setWidth(50),
              //             decoration: BoxDecoration(
              //               image: DecorationImage(
              //                   image: AssetImage(
              //                       "assets/images/closeicon.png"),
              //                   alignment: Alignment.center,
              //                   fit: BoxFit.cover),
              //             ),
              //           ),
              //         ),
              //       ),
            ],
          ),
        ));
  }
}
