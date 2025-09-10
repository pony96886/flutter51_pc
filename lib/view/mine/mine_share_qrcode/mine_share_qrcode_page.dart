import 'dart:ui' as ui;
import 'package:bot_toast/bot_toast.dart';
import 'package:chaguaner2023/model/homedata.dart';
import 'package:chaguaner2023/store/homeConfig.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:chaguaner2023/utils/yy_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:io';

class MineShareQRCodePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SharePageState();
}

class SharePageState extends State<MineShareQRCodePage> {
  Config? _config;
  int addCoinInvition = 0;
  @override
  void initState() {
    super.initState();
    getProfilePage().then((val) {
      if (val!['status'] != 0) {
        if (!mounted) return;
        setState(() {
          addCoinInvition = val['data']['add_coin_invition'];
        });
      }
    });
  }

  GlobalKey rootWidgetKey = GlobalKey();
  _showPage() {
    return Stack(
      children: [
        LocalPNG(
          width: double.infinity,
          height: double.infinity,
          url: 'assets/images/share/share-bg-1.png',
          fit: BoxFit.cover,
        ),
        Container(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            children: [
              //头部
              Container(
                width: double.infinity,
                height: 49.w + ScreenUtil().statusBarHeight,
                alignment: Alignment.bottomCenter,
                child: Container(
                    width: double.infinity,
                    height: 49.w,
                    child: Container(
                      padding: new EdgeInsets.only(left: 15.w, right: 15.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: _toBack,
                            child: LocalPNG(url: 'assets/images/icon-back.png', height: 25.w),
                          ),
                          GestureDetector(
                            onTap: _promotionRecord,
                            child: Text(
                              '推广记录',
                              style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 15.sp),
                            ),
                          )
                        ],
                      ),
                    )),
              ),
              Expanded(
                  child: Center(
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      width: 257.w,
                      height: 105.w,
                      child: LocalPNG(
                        width: 257.w,
                        height: 105.w,
                        url: 'assets/images/share/share-title.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    Center(
                      child: Text(
                        '每成功邀请1名手机注册用户，获得 ' + addCoinInvition.toString() + ' 铜钱',
                        style: TextStyle(color: Color(0xFFF9DC7A), fontSize: 14.sp),
                      ),
                    ),
                    Container(
                        margin: new EdgeInsets.only(top: 10.w, bottom: 20.w),
                        padding: new EdgeInsets.all(10),
                        width: 175.w,
                        height: 175.w,
                        child: _qrCode(300, 0),
                        decoration: new BoxDecoration(
                          //背景
                          color: Colors.white,
                          //设置四周圆角 角度
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        )),
                    Text(
                      '您的推广码:${_config!.share!.affCode}',
                      style: TextStyle(fontSize: 18.sp, color: Colors.white),
                    ),
                    Container(
                      padding: new EdgeInsets.only(top: 30.w, left: 20.w, right: 20.w),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                        GestureDetector(
                          onTap: _saveImgShare,
                          child: LocalPNG(url: 'assets/images/share/share-botton-save.png', height: 50.w),
                        ),
                        GestureDetector(
                          onTap: _copyLinkShare,
                          child: LocalPNG(url: 'assets/images/share/share-botton-copy.png', height: 50.w),
                        ),
                      ]),
                    )
                  ],
                ),
              )),
              //底部
              Column(children: [
                SizedBox(
                    width: double.infinity,
                    height: 49.w,
                    child: Stack(
                      children: [
                        LocalPNG(
                          url: 'assets/images/share/share-bg-footer.png',
                          fit: BoxFit.contain,
                        ),
                        Center(
                          child: GestureDetector(
                              onTap: _goPromotion,
                              behavior: HitTestBehavior.translucent,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '不会推广？快点我  ',
                                    style: TextStyle(color: Color(0xFFB8C1CC), fontSize: 12.sp),
                                  ),
                                  LocalPNG(url: 'assets/images/share/share-entr.png', height: 10.w),
                                ],
                              )),
                        ),
                      ],
                    )),
                Container(
                  width: double.infinity,
                  height: ScreenUtil().bottomBarHeight,
                  color: Color(0xFF11131A),
                )
              ])
            ],
          ),
        ),
      ],
    );
  }

  _savePage() {
    return RepaintBoundary(
        key: rootWidgetKey,
        child: Container(
            width: double.infinity,
            child: Stack(
              children: [
                LocalPNG(
                  url: 'assets/images/share/share-save-bg.png',
                  width: double.infinity,
                ),
                Positioned(
                    bottom: 60.w,
                    child: Container(
                      width: ScreenUtil().screenWidth,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                              margin: new EdgeInsets.only(bottom: 30.w),
                              padding: new EdgeInsets.all(7.5.w),
                              width: 180.w,
                              height: 180.w,
                              child: _qrCode(330, 0),
                              decoration: new BoxDecoration(
                                //背景
                                color: Colors.white,
                                //设置四周圆角 角度
                                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                              )),
                          Container(
                            height: 110.w,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _qrText('扫描二维码下载', 18),
                                _qrText('本人亲自玩过，给狼友们分享一下', 16),
                                _qrText('报毒不用搭理，链接失效自行翻墙访问', 16),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ))
              ],
            )));
  }

  _qrText(String text, int size) {
    return Text(
      text,
      style: TextStyle(
        fontSize: size.sp,
        color: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      _config = Provider.of<HomeConfig>(context).config;
    });
    return Scaffold(
        body: Stack(
      children: [Positioned(child: _savePage()), _showPage()],
    ));
  }

  void _toBack() {
    Navigator.pop(context);
  }

  void _promotionRecord() {
    AppGlobal.appRouter?.push(CommonUtils.getRealHash('promotionRecordPage'));
  }

  void _goPromotion() {
    AppGlobal.appRouter?.push(CommonUtils.getRealHash('shareMethodPage'));
  }

  //复制链接分享
  void _copyLinkShare() {
    Clipboard.setData(ClipboardData(text: '请使用google浏览器或UC浏览器，如无法访问请翻墙|${_config!.share!.affUrlCopy!.url}'));
    YyToast.successToast('复制成功,快去分享吧！');
  }

  _qrCode(int size, int padding) {
    return QrImage(
      padding: EdgeInsets.all(
        padding.w,
      ),
      backgroundColor: Colors.white,
      data: _config!.share!.affUrl!,
      version: QrVersions.auto,
      size: size.w,
      gapless: false,
      errorStateBuilder: (cxt, err) {
        return Container(
          child: Center(
            child: Text(
              '请检查查网络',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15.sp),
            ),
          ),
        );
      },
    );
  }

  //保存图片分享
  _saveImgShare() async {
    if (kIsWeb) {
      CommonUtils.showText('轻量版请自行截图保存');
      return;
    }
    BotToast.showLoading();
    PermissionStatus storageStatus = await Permission.storage.status;
    if (storageStatus == PermissionStatus.denied) {
      storageStatus = await Permission.storage.request();
      if (storageStatus == PermissionStatus.denied || storageStatus == PermissionStatus.permanentlyDenied) {
        YyToast.errorToast(
          '您拒绝了存储权限，请前往设置中打开权限',
        );
      } else {
        localStorageImage();
      }
      BotToast.closeAllLoading();
      return;
    } else if (storageStatus == PermissionStatus.permanentlyDenied) {
      //  await openAppSettings();
      BotToast.closeAllLoading();
      YyToast.errorToast(
        '无法保存到相册中，你关闭了存储权限，请前往设置中打开权限',
      );
      return;
    }
    localStorageImage();
    BotToast.closeAllLoading();
  }

  localStorageImage() async {
    RenderRepaintBoundary boundary = rootWidgetKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();
    final result = await ImageGallerySaverPlus.saveImage(pngBytes); //这个是核心的保存图片的插件
    if (Platform.isIOS) {
      if (result['isSuccess']) {
        YyToast.successToast('信息保存成功,请勿丢失～');
      }
    } else if (Platform.isAndroid) {
      if (result.length > 0 || result['isSuccess']) {
        YyToast.successToast('信息保存成功,请勿丢失～');
      }
    }
  }
}
