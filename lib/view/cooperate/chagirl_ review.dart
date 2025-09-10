import 'dart:io';

import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/loading.dart';
import 'package:chaguaner2023/components/page_title_bar.dart';
import 'package:chaguaner2023/model/homedata.dart';
import 'package:chaguaner2023/store/global.dart';
import 'package:chaguaner2023/store/homeConfig.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:chaguaner2023/view/im/im_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ChagirlReview extends StatefulWidget {
  ChagirlReview({Key? key}) : super(key: key);

  @override
  _ChagirlReviewState createState() => _ChagirlReviewState();
}

class _ChagirlReviewState extends State<ChagirlReview> {
  String applicationUrl = "";
  String contactUrl = "";
  String wechatQr = "";
  bool loading = true;
  @override
  void initState() {
    super.initState();
    initPotatoLink();
  }

  initPotatoLink() async {
    var result = await getSetting("potato_url");
    if (result!['status'] == 1 && result['data'] != null) {
      loading = false;
      applicationUrl = result['data']['potato_url'][0]['url'];
      contactUrl = result['data']['potato_url'][1]['url'];
      wechatQr = result['data']['potato_url'][1]['url'] != null ? result['data']['potato_url'][1]['url'] : null;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return HeaderContainer(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
            child: PageTitleBar(
              onback: () {
                AppGlobal.appRouter?.go('/home');
              },
              title: '茶女郎认证',
            ),
            preferredSize: Size(double.infinity, 44.w)),
        body: loading
            ? Loading()
            : SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(15.w),
                  child: Column(
                    children: <Widget>[
                      Center(
                        child: LocalPNG(
                          width: 170.w,
                          height: 170.w,
                          url: "assets/images/publish/waitingicon.png",
                        ),
                      ),
                      SizedBox(
                        height: 5.w,
                      ),
                      Center(
                          child: Text('已提交审核',
                              style: TextStyle(
                                  color: StyleTheme.cTitleColor, fontSize: 18.sp, fontWeight: FontWeight.w700))),
                      SizedBox(
                        height: 20.w,
                      ),
                      Center(
                          child: Text("请按照以下步骤操作，联系运营人员审核",
                              style: TextStyle(
                                  color: StyleTheme.cTitleColor, fontSize: 18.sp, fontWeight: FontWeight.w700))),
                      SizedBox(
                        height: 18.5.w,
                      ),
                      WechatQrcode(
                        wechatUrl: wechatQr,
                      ),
                      SizedBox(
                        height: 18.5.w,
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class TitleTile extends StatelessWidget {
  final String? title;
  const TitleTile({
    Key? key,
    this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(title!,
        textAlign: TextAlign.left,
        style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 18.sp, fontWeight: FontWeight.bold));
  }
}

class WechatQrcode extends StatefulWidget {
  final String? wechatUrl;
  WechatQrcode({Key? key, this.wechatUrl}) : super(key: key);

  @override
  _WechatQrcodeState createState() => _WechatQrcodeState();
}

class _WechatQrcodeState extends State<WechatQrcode> {
  GlobalKey rootWidgetKey = GlobalKey();

  _qrCode(int size, int padding, qrurl) {
    return QrImage(
      padding: EdgeInsets.all(
        padding.w,
      ),
      backgroundColor: Colors.white,
      data: qrurl,
      version: QrVersions.auto,
      size: size.w,
      gapless: false,
      // embeddedImage: AssetImage('assets/images/home/ic_launcher.png'),
      embeddedImageStyle: QrEmbeddedImageStyle(
        size: Size(30.w, 30.w),
      ),
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

  @override
  Widget build(BuildContext context) {
    Member member = Provider.of<HomeConfig>(context, listen: false).member;
    return Container(
        padding: EdgeInsets.all(15.w),
        decoration: BoxDecoration(color: Color(0xFFF8E2BA), borderRadius: BorderRadius.all(Radius.circular(5.w))),
        child: Column(children: <Widget>[
          Row(
            children: [
              Container(
                margin: EdgeInsets.only(right: 10.w),
                width: 30.w,
                height: 30.w,
                decoration: BoxDecoration(color: Color(0xffbc3729), borderRadius: BorderRadius.circular(30)),
                child: Center(
                  child: Text(
                    '1',
                    style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              Text(
                '聊天窗内联系运营人员审核',
                style: TextStyle(fontSize: 15.sp, color: Color(0xffb82424)),
              )
            ],
          ),
          Row(
            children: [
              Container(
                margin: EdgeInsets.only(
                  right: 10.w,
                  top: 5.w,
                  bottom: 5.w,
                ),
                width: 30.w,
                child: LocalPNG(
                  width: 10.w,
                  height: 60.w,
                  fit: BoxFit.contain,
                  url: "assets/images/xu.png",
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (member.vipLevel == 0) {
                    CommonUtils.showText('此功能只对会员开放');
                    return;
                  }
                  CommonUtils.getImPath(context, callBack: () {
                    AppGlobal.chatUser =
                        FormUserMsg(uuid: UserInfo.shenheUuid!, nickname: '茶女郎管理', avatar: 'chaxiaowai');
                    AppGlobal.appRouter?.push(CommonUtils.getRealHash('llchat'));
                  });
                },
                child: Container(
                  decoration: BoxDecoration(color: StyleTheme.cDangerColor, borderRadius: BorderRadius.circular(10)),
                  width: 265.w,
                  height: 40.w,
                  child: Center(
                    child: Text(
                      '点击前往',
                      style: TextStyle(color: Colors.white, fontSize: 18.w, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              )
            ],
          ),
          Row(
            children: [
              Container(
                margin: EdgeInsets.only(right: 10.w),
                width: 30.w,
                height: 30.w,
                decoration: BoxDecoration(color: Color(0xffbc3729), borderRadius: BorderRadius.circular(30)),
                child: Center(
                  child: Text(
                    '2',
                    style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              Flexible(
                  child: Text(
                '扫描以下二维码，下载Telegram并添加该好友联系认证',
                style: TextStyle(fontSize: 15.sp, color: Color(0xffb82424)),
              ))
            ],
          ),
          // Text("保存二维码到相册后使用微信 [ 扫一扫 ] 功能选择该二维码进行识别",
          //     textAlign: TextAlign.center,
          //     style: TextStyle(
          //       color: Color(0xFFB82424),
          //       fontSize: 15.sp,
          //     )),
          SizedBox(height: 10.w),
          RepaintBoundary(
              key: rootWidgetKey,
              child: Container(
                  margin: new EdgeInsets.only(top: 10.w, bottom: 20.w),
                  padding: new EdgeInsets.all(10),
                  width: 175.w,
                  height: 175.w,
                  child: _qrCode(150, 0, widget.wechatUrl),
                  decoration: new BoxDecoration(
                    //背景
                    color: Colors.white,
                    //设置四周圆角 角度
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ))),
        ]));
  }
}

class StepDetail extends StatelessWidget {
  final String? accountUrl;
  final String? applicationUrl;

  const StepDetail({
    Key? key,
    this.accountUrl,
    this.applicationUrl,
  }) : super(key: key);

  void handleLanchUrl(BuildContext context, String url) {
    var members = Provider.of<HomeConfig>(context, listen: false).member;
    var aff = members.aff;
    var chaid = members.uuid;
    // 外部浏览器
    CommonUtils.launchURL("$url?aff=$aff&chaid=$chaid");
  }

  @override
  Widget build(BuildContext context) {
    String iosTipsStr = "* iOS用户请切换AppStore地区为国外即可下载";
    String androidTIpsStr = "* 安卓用户如果无法正常打开网站，请复制链接使用google浏览器打开";
    return Container(
        padding: EdgeInsets.all(15.w),
        decoration: BoxDecoration(color: Color(0xFFF8E2BA), borderRadius: BorderRadius.all(Radius.circular(5.w))),
        child: Column(
          children: <Widget>[
            Text(kIsWeb ? iosTipsStr : (Platform.isAndroid ? androidTIpsStr : iosTipsStr),
                style: TextStyle(
                  color: Color(0xFFB82424),
                  fontSize: 12.sp,
                )),
            SizedBox(height: 10.w),
            Row(
              children: <Widget>[
                Container(
                  width: 30.w,
                  height: 30.w,
                  decoration: BoxDecoration(color: Color(0xFFBC3729), shape: BoxShape.circle),
                  child: Center(
                    child:
                        Text('1', style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold)),
                  ),
                ),
                SizedBox(width: 10.w),
                Text('请下载Telegram(飞机)app',
                    style: TextStyle(
                      color: Color(0xFFB82424),
                      fontSize: 15.sp,
                    ))
              ],
            ),
            SizedBox(height: 5.w),
            Row(
              children: <Widget>[
                SizedBox(width: 10.w),
                LocalPNG(
                  url: "assets/images/tea/down_arrow.png",
                  height: 60.w,
                  width: 60.w,
                ),
                SizedBox(width: 20.w),
                GestureDetector(
                  onTap: () {
                    handleLanchUrl(context, applicationUrl!);
                  },
                  child: LocalPNG(
                    url: "assets/images/tea/click_download.png",
                    height: 40.w,
                    width: 40.w,
                  ),
                )
              ],
            ),
            SizedBox(height: 5.w),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 30.w,
                  height: 30.w,
                  decoration: BoxDecoration(color: Color(0xFFBC3729), shape: BoxShape.circle),
                  child: Center(
                    child:
                        Text('2', style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold)),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text('下载成功后，点击以下链接联系该账号(需要互加好友才能正常聊天，工作人员看到你的添加请求后会回加你为好友，请注意通过验证)',
                      style: TextStyle(
                        color: Color(0xFFB82424),
                        fontSize: 14.sp,
                      )),
                )
              ],
            ),
            Row(
              children: <Widget>[
                SizedBox(width: 40.w),
                GestureDetector(
                  onTap: () {
                    handleLanchUrl(context, accountUrl!);
                  },
                  child: Text(accountUrl!,
                      style: TextStyle(
                        color: Color(0xFFB82424),
                        fontSize: 15.sp,
                      )),
                )
              ],
            ),
          ],
        ));
  }
}
