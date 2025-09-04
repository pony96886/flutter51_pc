import 'dart:io';
import 'package:bot_toast/bot_toast.dart';
import 'package:chaguaner2023/store/homeConfig.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class EmploymentIntroduce extends StatefulWidget {
  final int? type;
  EmploymentIntroduce({Key? key, this.type = 1}) : super(key: key);

  @override
  _EmploymentIntroduceState createState() => _EmploymentIntroduceState();
}

class _EmploymentIntroduceState extends State<EmploymentIntroduce> {
  String applicationUrl = "";
  String contactUrl = "";

  @override
  void initState() {
    super.initState();
    initPotatoLink();
  }

  initPotatoLink() async {
    BotToast.showLoading();
    var result = await getSetting("potato_url");
    BotToast.closeAllLoading();
    if (result!['status'] == 1 && result['data'] != null) {
      applicationUrl = result['data']['potato_url'][0]['url'];
      contactUrl = result['data']['potato_url'][1]['url'];
      setState(() {});
    }
  }

  // 茶女郎认证按钮入口
  handleCertification() async {
    if (kIsWeb) {
      CommonUtils.launchURL(AppGlobal.officeSite);
      return;
    }
    if (['', null, false].contains(AppGlobal.apiToken.value)) {
      BotToast.showText(text: '您还未登录，无法进行认证', align: Alignment(0, 0));
      return;
    }
    BotToast.showLoading();
    var resule = await getPerson();
    BotToast.closeAllLoading();
    if (resule!['status'] == 1) {
      if (resule['data'] != null && resule['data']['status'] == 1) {
        AppGlobal.girlParmas = {
          'editInfoData': resule['data'],
          'editVideo': resule['data']['resources']
              .where((item) => item['type'] == 2)
              .toList(),
          'editImage': resule['data']['resources']
              .where((item) => item['type'] == 1)
              .toList()
        };
        AppGlobal.appRouter
            ?.push(CommonUtils.getRealHash('chaGirlBaseInformation'));
      } else {
        AppGlobal.appRouter
            ?.push(CommonUtils.getRealHash('chaGirlConfirmPage'));
      }
    } else {
      AppGlobal.appRouter?.push(CommonUtils.getRealHash('chaGirlConfirmPage'));
    }
  }

  double handleIntroduceContainerHeigh(int type) {
    if (type == 1) {
      return 290.w;
    } else if (type == 2) {
      return 265.w;
    } else if (type == 3) {
      return 220.w;
    } else if (type == 4) {
      return 216.w;
    } else {
      return 290.w;
    }
  }

  String handleIntroduce(int type) {
    if (type == 1) {
      return "assets/images/tea/chatboss_include.png";
    } else if (type == 2) {
      return "assets/images/tea/chaxiaoer_include.png";
    } else if (type == 3) {
      return "assets/images/tea/chagirl_include.png";
    } else if (type == 4) {
      return "assets/images/tea/jiancha_include.png";
    } else {
      return "assets/images/tea/chatboss_include.png";
    }
  }

  String handleBannderImage(int type) {
    if (type == 1) {
      return "assets/images/tea/banner_chaboss.png";
    } else if (type == 2) {
      return "assets/images/tea/banner_chaxiaoer.png";
    } else if (type == 3) {
      return "assets/images/tea/banner_chagirl.png";
    } else if (type == 4) {
      return "assets/images/tea/banner_jiancha.png";
    } else {
      return "assets/images/tea/banner_chaboss.png";
    }
  }

  String handleHowDo(int type) {
    if (type == 1) {
      return "如何申请茶老板";
    } else if (type == 2) {
      return "如何申请茶小二";
    } else if (type == 3) {
      return " ";
    } else if (type == 4) {
      return "如何申请鉴茶师";
    } else {
      return "如何申请茶老板";
    }
  }

  @override
  Widget build(BuildContext context) {
    // var imPrivilege =
    //     Provider.of<HomeConfig>(context, listen: false).data['im_privilege'];
    return Scaffold(
        backgroundColor: Color(0xFFCD3F30),
        floatingActionButton: Padding(
          padding: EdgeInsets.only(
              bottom: kIsWeb ? AppGlobal.webBottomHeight + 20.w : 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  AppGlobal.appRouter
                      ?.push(CommonUtils.getRealHash('onlineServicePage'));
                  // if (!CgPrivilege.getPrivilegeStatus(
                  //     PrivilegeType.infoSystem, PrivilegeType.privilegeIm)) {
                  //   CommonUtils.showVipDialog(
                  //       context,
                  //       PrivilegeType.infoSysteString +
                  //           PrivilegeType.privilegeImString);
                  //   return;
                  // }
                  // if (WebSocketUtility.imToken == null) {
                  //   CommonUtils.getImPath(context, callBack: () {
                  //     AppGlobal.chatUser = FormUserMsg(
                  //         isVipDetail: true,
                  //         uuid: UserInfo.manageUuid,
                  //         nickname: '茶管理',
                  //         avatar: 'chaxiaowai');
                  //     AppGlobal.appRouter
                  //         .push(CommonUtils.getRealHash('llchat'));
                  //   }, status: 1);
                  // } else {
                  //   AppGlobal.chatUser = FormUserMsg(
                  //       isVipDetail: true,
                  //       uuid: UserInfo.manageUuid,
                  //       nickname: '茶管理',
                  //       avatar: 'chaxiaowai');
                  //   AppGlobal.appRouter.push(CommonUtils.getRealHash('llchat'));
                  // }
                },
                behavior: HitTestBehavior.translucent,
                child: Container(
                  margin: EdgeInsets.only(bottom: 20.w),
                  width: 67.7.w,
                  height: 84.3.w,
                  child: Image.asset("assets/images/home/chaguanli.png",
                      width: 67.7.w,
                      height: 84.3.w,
                      alignment: Alignment.center,
                      fit: BoxFit.contain),
                ),
              )
            ],
          ),
        ),
        body: Stack(
          children: <Widget>[
            SingleChildScrollView(
              physics: ClampingScrollPhysics(),
              child: Column(
                children: <Widget>[
                  LocalPNG(
                    url: handleBannderImage(widget.type!),
                    height: 155.w,
                  ),
                  Padding(
                      padding: EdgeInsets.all(15.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          LocalPNG(
                            url: handleIntroduce(widget.type!),
                            height: handleIntroduceContainerHeigh(widget.type!),
                            width: double.infinity,
                          ),
                          SizedBox(height: 30.w),
                          Text(handleHowDo(widget.type!),
                              style: TextStyle(
                                  color: Colors.white, fontSize: 18.w)),
                          SizedBox(height: 20.w),
                          widget.type == 3
                              ? GestureDetector(
                                  onTap: handleCertification,
                                  child: Center(
                                    child: kIsWeb
                                        ? Image.asset(
                                            "assets/images/pwa/click_renzheng.png",
                                            height: 50.w,
                                            fit: BoxFit.fitHeight,
                                          )
                                        : LocalPNG(
                                            url:
                                                "assets/images/tea/click_renzheng.png",
                                            height: 50.w,
                                            fit: BoxFit.fitHeight,
                                          ),
                                  ),
                                )
                              : StepDetail(
                                  accountUrl: contactUrl,
                                  applicationUrl: applicationUrl,
                                ),
                        ],
                      )),
                  SizedBox(
                    height: 100.w,
                  )
                ],
              ),
            ),
            Positioned(
              top: ScreenUtil().statusBarHeight,
              child: Container(
                width: ScreenUtil().screenWidth,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    IconButton(
                      padding: EdgeInsets.only(left: 20.0),
                      icon: Icon(Icons.arrow_back_ios),
                      onPressed: () => Navigator.pop(context),
                      iconSize: 25.0,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}

class StepDetail extends StatelessWidget {
  final String? accountUrl;
  final String? applicationUrl;
  final String iosTipsStr = "* iOS用户请切换AppStore地区为国外即可下载";
  final String androidTipsStr = "* 安卓用户如果无法正常打开网站，请复制链接使用google浏览器打开";

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
    return SingleChildScrollView(
      child: Container(
          padding: EdgeInsets.all(15.w),
          decoration: BoxDecoration(
              color: Color(0xFFF8E2BA),
              borderRadius: BorderRadius.all(Radius.circular(5.w))),
          child: Column(
            children: <Widget>[
              Text(
                  kIsWeb
                      ? iosTipsStr
                      : (Platform.isIOS ? iosTipsStr : androidTipsStr),
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
                    decoration: BoxDecoration(
                        color: Color(0xFFBC3729), shape: BoxShape.circle),
                    child: Center(
                      child: Text('1',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold)),
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
                  ),
                  SizedBox(width: 20.w),
                  GestureDetector(
                    onTap: () {
                      handleLanchUrl(context, applicationUrl!);
                    },
                    child: LocalPNG(
                      url: "assets/images/tea/click_download.png",
                      height: 40.w,
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
                    decoration: BoxDecoration(
                        color: Color(0xFFBC3729), shape: BoxShape.circle),
                    child: Center(
                      child: Text('2',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.w,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                        '下载成功后，点击以下链接联系该账号(需要互加好友才能正常聊天，工作人员看到你的添加请求后会回加你为好友，请注意通过验证)',
                        style: TextStyle(
                          color: Color(0xFFB82424),
                          fontSize: 15.sp,
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
          )),
    );
  }
}
