import 'dart:io';
import 'package:bot_toast/bot_toast.dart';
import 'package:chaguaner2023/components/card/tzyh.dart';
import 'package:chaguaner2023/store/global.dart';
import 'package:chaguaner2023/store/homeConfig.dart';
import 'package:chaguaner2023/store/sharedPreferences.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:chaguaner2023/utils/netimage_tool.dart';
import 'package:chaguaner2023/utils/yy_toast.dart';
import 'package:chaguaner2023/view/mine/widget/info_nickname.dart';
import 'package:chaguaner2023/view/mine/widget/need_login.dart';
import 'package:flutter/foundation.dart';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh_notification/pull_to_refresh_notification.dart';

import '../../utils/cache/image_net_tool.dart';

class MinePage extends StatefulWidget {
  MinePage({Key? key}) : super(key: key);

  @override
  _MinePagesState createState() => _MinePagesState();
}

class _MinePagesState extends State<MinePage> with TickerProviderStateMixin {
  final GlobalKey<PullToRefreshNotificationState> key = GlobalKey<PullToRefreshNotificationState>();
  ScrollController _minePagesController = ScrollController();
  AnimationController? _animoteLottie;
  double maxDragOffset = 100.w;
  bool _privacy = false;
  double _headeropacity = 0.0;
  GlobalKey rootWidgetKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    PersistentState.getState('filstApp').then((vel) {
      //第一次使用App
      if (vel == null) {
        showUserInfo();
        PersistentState.saveState('filstApp', 'YES');
      }
    });
    _animoteLottie = AnimationController(vsync: this);
    PersistentState.getState('isPrivacy').then((val) => {
          setState(() {
            _privacy = val == '1';
          }),
        });
    _minePagesController = ScrollController(initialScrollOffset: 0.0);
    _minePagesController.addListener(() {
      double offsetvalue = _minePagesController.offset / 100.w;
      if (offsetvalue < 0.0) {
        offsetvalue = 0.0;
      } else if (offsetvalue > 1.0) {
        offsetvalue = 1.0;
      }
      setState(() {
        _headeropacity = offsetvalue;
      });
    });
    Future.delayed(Duration(milliseconds: 200), () {
      _onInitMyAppointment();
    });
  }

  Future<String?> showUserInfo() {
    return showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        var _member = Provider.of<HomeConfig>(context).member;
        var _config = Provider.of<HomeConfig>(context).config;
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 300.w,
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
                        '重要提示！！！',
                        style: TextStyle(color: StyleTheme.cDangerColor, fontSize: 18.sp, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      height: 14.w,
                    ),
                    Text(
                      '首次安装APP请先保存此信息,可大大提高账号找回概率,如果账号丢失,请直接联系在线客服反馈。',
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 14.sp),
                    ),
                    SizedBox(
                      height: 10.w,
                    ),
                    Text(
                      '如果您已有账号请及时登录绑定,以免出现账号丢失无法找回的情况。',
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 14.sp),
                    ),
                    SizedBox(
                      height: 14.w,
                    ),
                    RepaintBoundary(
                        key: rootWidgetKey,
                        child: Container(
                          width: double.infinity,
                          color: Color.fromRGBO(255, 225, 225, 1.0),
                          padding: EdgeInsets.symmetric(horizontal: 15.w),
                          height: 80.w,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text.rich(TextSpan(children: [
                                TextSpan(text: '茶馆ID:  ', style: TextStyle(color: Colors.black, fontSize: 14.sp)),
                                TextSpan(
                                    text: _member.aff,
                                    style: TextStyle(color: StyleTheme.cDangerColor, fontSize: 21.sp))
                              ])),
                              Text.rich(TextSpan(children: [
                                TextSpan(text: '您的邀请码:  ', style: TextStyle(color: Colors.black, fontSize: 14.sp)),
                                TextSpan(
                                    text: _config.share!.affCode,
                                    style: TextStyle(color: StyleTheme.cDangerColor, fontSize: 21.sp))
                              ]))
                            ],
                          ),
                        )),
                    SizedBox(
                      height: 10.w,
                    ),
                    Text(
                      '切勿将此信息泄漏给他人,否则平台概不负责。',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: StyleTheme.cDangerColor, fontSize: 11.sp),
                    ),
                    Text(
                      '邀请好友须前往设置绑定邮箱，才能获得推广奖励',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: StyleTheme.cDangerColor, fontSize: 11.sp),
                    ),
                    SizedBox(
                      height: 20.w,
                    ),
                    GestureDetector(
                      onTap: () {
                        _saveImgShare('茶馆ID:  ${_member.aff}\n您的邀请码:  ${_config.share!.affCode}');
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: double.infinity,
                        height: 40.w,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.w),
                            gradient: LinearGradient(
                              colors: [Color(0xfffbad3e), Color(0xffffedb5)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            )),
                        child: Center(
                          child: Text(
                            '立即保存',
                            style: TextStyle(color: Color(0xff903600), fontSize: 14.sp),
                          ),
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
                          width: 30.w, height: 30.w, url: 'assets/images/mymony/close.png', fit: BoxFit.cover)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _copyLinkShare(String text, String tips) {
    Clipboard.setData(ClipboardData(text: text));
    CommonUtils.showText(tips);
  }

  //保存图片分享
  _saveImgShare(String text) async {
    if (kIsWeb) {
      CommonUtils.showText('轻量版请自行截图保存');
      return;
    }
    BotToast.showLoading();
    PermissionStatus storageStatus = await Permission.storage.status;
    if (storageStatus == PermissionStatus.denied) {
      storageStatus = await Permission.storage.request();
      if (storageStatus == PermissionStatus.denied || storageStatus == PermissionStatus.permanentlyDenied) {
        _copyLinkShare(text, '您拒绝了储存权限,已为您复制至粘帖板，请您及时保存～');
      } else {
        localStorageImage();
      }
      BotToast.closeAllLoading();
      return;
    } else if (storageStatus == PermissionStatus.permanentlyDenied) {
      BotToast.closeAllLoading();
      _copyLinkShare(text, '无法保存到相册中，你关闭了存储权限，请前往设置中打开权限,已为您复制至粘帖板，请您及时保存～');
      return;
    }
    localStorageImage();
    BotToast.closeAllLoading();
  }

  localStorageImage() async {
    RenderRepaintBoundary? boundary = rootWidgetKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary!.toImage(pixelRatio: 3.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();
    final result = await ImageGallerySaverPlus.saveImage(pngBytes); //这个是核心的保存图片的插件
    if (Platform.isIOS) {
      if (result) {
        YyToast.successToast('信息保存成功,请勿丢失～');
      }
    } else if (Platform.isAndroid) {
      if (result.length > 0) {
        YyToast.successToast('信息保存成功,请勿丢失～');
      }
    }
  }

  _getNumInfo() async {
    var _number = await getProfilePage();
    // print('用户信息');
    // print(_number);
    await getHomeConfig(context);
    Provider.of<GlobalState>(context, listen: false).setProfile(_number!['data']);
    Provider.of<GlobalState>(context, listen: false).setOltime(_number['data']['oltime']);
  }

  _unreadCount() async {
    var msg = await getSystemNotice();
    if (msg != null && msg['status'] != 0) {
      Provider.of<GlobalState>(context, listen: false).setMsgList(msg['data']);
      var tipsnum = (msg['data']['systemNoticeCount'] ?? 0) +
          (msg['data']['feedCount'] ?? 0) +
          (msg['data']['messageCount'] ?? 0) +
          (msg['data']['groupMessageCount'] ?? 0);
      Provider.of<GlobalState>(context, listen: false).setMsgLength(tipsnum);
      // EventBus().emit(KyGlobal.updateBottomMsgCount, tipsnum > 0);
    }
  }

  Future<bool> onRefresh() async {
    _getNumInfo();
    _unreadCount();
    _onInitMyAppointment();
    _animoteLottie!.forward();
    return await Future.delayed(const Duration(milliseconds: 2000), () {
      _animoteLottie!.reset();
      return true;
    });
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
                        _animoteLottie?.duration = duration;
                        _animoteLottie?.stop();
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
                      _animoteLottie?.duration = composition.duration;
                      _animoteLottie?.stop();
                    },
                  ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: Stack(
          children: [
            LocalPNG(
              width: double.infinity,
              url: "assets/images/container-bg-1.png",
              alignment: Alignment.topLeft,
            ),
            Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: Colors.transparent,
              appBar:
                  PreferredSize(child: TitleBar(opacityvalue: _headeropacity), preferredSize: Size.fromHeight(45.w)),
              body: PullToRefreshNotification(
                // pullBackOnRefresh: true,
                color: Colors.transparent,
                onRefresh: onRefresh,
                maxDragOffset: maxDragOffset,
                armedDragUpCancel: false,
                key: key,
                child: CustomScrollView(
                  physics: ClampingScrollPhysics(),
                  controller: _minePagesController,
                  slivers: <Widget>[
                    PullToRefreshContainer((e) {
                      return buildPulltoRefreshHeader(e);
                    }),
                    SliverToBoxAdapter(
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.only(top: 15.w, left: 15.w, right: 15.w),
                        child: GestureDetector(
                          onTap: showUserInfo,
                          child: _headerContent(),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 15.w),
                        margin: EdgeInsets.only(top: 5.w, bottom: 0.w),
                        child: tianzi(),
                      ),
                    ),
                    _vipWidget(),
                    SliverToBoxAdapter(
                      child: Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 10.w,
                        ),
                        padding: EdgeInsets.all(13.5.w),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10.w)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            MenuCard(
                              image: "assets/images/mine/v5/pcb.png",
                              title: "品茶宝",
                              onTap: () {
                                AppGlobal.appRouter?.push(CommonUtils.getRealHash('pingChaBaoPage'));
                              },
                            ),
                            MenuCard(
                              image: "assets/images/mine/yuanbaoicon.png",
                              title: "元宝钱包",
                              onTap: () {
                                AppGlobal.appRouter?.push(CommonUtils.getRealHash('ingotWallet'));
                              },
                            ),
                            MenuCard(
                              image: "assets/images/mine/quanminicon.png",
                              title: "推广赚钱",
                              onTap: () {
                                if (Provider.of<HomeConfig>(context, listen: false).data['all_agent_white'] == 1) {
                                  CommonUtils.showText('暂未开通该功能');
                                } else {
                                  AppGlobal.appRouter?.push(CommonUtils.getRealHash('popularize'));
                                }
                              },
                            ),
                            MenuCard(
                              image: "assets/images/mine/tuiguangicon.png",
                              title: "我的推广码",
                              onTap: () {
                                AppGlobal.appRouter?.push(CommonUtils.getRealHash('shareQRCodePage'));
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Column(
                        children: <Widget>[
                          ListTileItem(
                            image: "assets/images/mine/cz_center.png",
                            title: "创作中心",
                            onTap: () {
                              context.push(CommonUtils.getRealHash('videoWork'));
                            },
                          ),
                          ListTileItem(
                            image: "assets/images/mine/quan.png",
                            title: "我的卡券包",
                            onTap: () {
                              AppGlobal.appRouter?.push(CommonUtils.getRealHash('youhuiquanCard'));
                            },
                            trailing: Container(
                              padding: EdgeInsets.only(right: 5.5.w),
                              child: Text(
                                availableCouponText,
                                style: TextStyle(color: StyleTheme.cBioColor, fontSize: 14.sp),
                              ),
                            ),
                          ),
                          ListTileItem(
                            image: "assets/images/mine/mall_order.png",
                            title: "我的订单",
                            onTap: () {
                              context.push(CommonUtils.getRealHash('userMallOrder'));
                            },
                          ),
                          ListTileItem(
                            image: "assets/images/mine/wodechatie.png",
                            title: "我的茶帖",
                            onTap: () {
                              context.push(CommonUtils.getRealHash('myTeaPost/0'));
                            },
                            trailing: Container(
                              padding: EdgeInsets.only(right: 5.5.w),
                              child: Text(
                                '发布/收藏/解锁',
                                style: TextStyle(color: StyleTheme.cBioColor, fontSize: 14.sp),
                              ),
                            ),
                          ),
                          // ListTileItem(
                          //   image: "assets/images/mine/pintuan.png",
                          //   title: "拼团订单",
                          //   onTap: () {
                          //     Navigator.push(
                          //         context,
                          //         MaterialPageRoute(
                          //           builder: (context) => MypintuanOder(),
                          //         ));
                          //   },
                          //   trailing: Container(
                          //     padding: EdgeInsets.only(
                          //         right: 5.5.w),
                          //   ),
                          // ),
                          ListTileItem(
                            image: "assets/images/mine/v5/wdyy.png",
                            title: "我的预约",
                            onTap: () {
                              AppGlobal.appRouter?.push(CommonUtils.getRealHash('reservationPage'));
                            },
                            trailing: Container(
                              padding: EdgeInsets.only(right: 5.5.w),
                              child: Text(
                                _yyCount,
                                style: TextStyle(color: StyleTheme.cBioColor, fontSize: 14.sp),
                              ),
                            ),
                          ),
                          ListTileItem(
                            image: "assets/images/mine/yajianshoucang.png",
                            title: "我的收藏",
                            onTap: () {
                              AppGlobal.appRouter?.push(CommonUtils.getRealHash('elegantCollect'));
                            },
                          ),
                          ListTileItem(
                            image: "assets/images/mine/wodetongqian.png",
                            title: "我的铜钱",
                            onTap: () {
                              AppGlobal.appRouter?.push(CommonUtils.getRealHash('myMonyPage'));
                            },
                            trailing: Container(
                              padding: EdgeInsets.only(right: 5.5.w),
                              child: Text(
                                CommonUtils.renderFixedNumber(
                                    double.parse(Provider.of<HomeConfig>(context).member.coins.toString())),
                                style: TextStyle(color: StyleTheme.cBioColor, fontSize: 14.sp),
                              ),
                            ),
                          ),
                          ListTileItem(
                            image: "assets/images/mine/yinsibaohu.png",
                            title: "隐私保护",
                            onTap: () {
                              PersistentState.getState('initApp').then((initapp) {
                                //第一次使用App
                                if (initapp == null) {
                                  AppGlobal.appRouter?.push(CommonUtils.getRealHash('tealist'));
                                } else {
                                  String oneStr = '1';
                                  String zeroStr = '0';
                                  PersistentState.saveState('isPrivacy', !_privacy ? oneStr : zeroStr);
                                  setState(() {
                                    _privacy = !_privacy;
                                  });
                                }
                              });
                            },
                            trailing: Container(
                              padding: EdgeInsets.only(right: 5.5.w),
                              child: Switch(
                                value: _privacy,
                                activeColor: Color(0xFFE32C33),
                                onChanged: (bool value) {
                                  PersistentState.getState('initApp').then((initapp) {
                                    //第一次使用App
                                    if (initapp == null) {
                                      AppGlobal.appRouter?.push(CommonUtils.getRealHash('tealist'));
                                      // Application.router
                                      //     .navigateTo(context, '/tealist',
                                      //         transition:
                                      //             TransitionType.fadeIn,
                                      //         transitionDuration:
                                      //             new Duration(
                                      //                 milliseconds: 200))
                                      //     .whenComplete(() {
                                      //   PersistentState.getState('isPrivacy')
                                      //       .then((val) {
                                      //     if (val == '1') {
                                      //       setState(() {
                                      //         _privacy = true;
                                      //       });
                                      //     }
                                      //   });
                                      // });
                                    } else {
                                      String oneStr = '1';
                                      String zeroStr = '0';
                                      PersistentState.saveState('isPrivacy', value ? oneStr : zeroStr);
                                      setState(() {
                                        _privacy = value;
                                      });
                                    }
                                  });
                                },
                              ),
                            ),
                            isShowArrow: false,
                          ),
                          ListTileItem(
                            image: "assets/images/mine/kaichequn.png",
                            title: "官方开车群",
                            onTap: () {
                              var groupUrl = Provider.of<HomeConfig>(context, listen: false).config.officialGroup;
                              if (groupUrl == "") {
                                BotToast.showText(text: '(URL NULL)', align: Alignment(0, 0));
                              } else {
                                CommonUtils.launchURL(groupUrl!);
                              }
                            },
                          ),
                          ListTileItem(
                            image: "assets/images/mine/settingicon.png",
                            title: "设置",
                            onTap: () {
                              context.push(CommonUtils.getRealHash('setting'));
                            },
                          ),
                          // ListTileItem(
                          //   image: "assets/images/mine/icon_game.png",
                          //   title: "游戏大厅",
                          //   onTap: () {
                          //     context
                          //         .push(CommonUtils.getRealHash('gamePage'));
                          //   },
                          // ),
                          Provider.of<HomeConfig>(context, listen: false).data['app_center_white'] == 1
                              ? SizedBox()
                              : ListTileItem(
                                  image: "assets/images/mine/app_store.png",
                                  title: "应用中心",
                                  onTap: () {
                                    context.push(CommonUtils.getRealHash('applicationCenter'));
                                  },
                                  trailing: Container(
                                    padding: EdgeInsets.only(right: 5.5.w),
                                    child: Text(
                                      '宅男福利APP推荐',
                                      style: TextStyle(color: StyleTheme.cBioColor, fontSize: 14.sp),
                                    ),
                                  ),
                                ),
                          SizedBox(
                            height: ScreenUtil().bottomBarHeight + 250.w,
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget tianzi() {
    var vipClub = Provider.of<GlobalState>(context).profileData?['vip_club'] ?? 0;
    return TianZiYiHao(vipClub: vipClub);
  }

  String _yyCount = '';
  String availableCouponText = '';

  _onInitMyAppointment() async {
    var result = await getMyAppointmentNum();
    if (result!['status'] == 1) {
      setState(() {
        int unComment = result['data']['unComment']; //待评价
        int unConfirm = result['data']['unConfirm']; //待确认
        int unCoffice = result['data']['unConfirmOfficialAppointment'] ?? 0;
        int availableCoupon = result['data']['availableCoupon'];
        _yyCount = '待确认${unConfirm + unCoffice}、待评价$unComment';
        availableCouponText = '$availableCoupon张优惠券可用';
      });
    }
  }

  Widget _headerContent() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 60.5.w,
          height: 65.5.w,
          margin: EdgeInsets.only(right: 5.w),
          child: Stack(children: <Widget>[
            Container(
              width: 50.w,
              height: 50.w,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
              child: AvatarBox(),
            ),
            Positioned(
                bottom: 3,
                left: 0.0,
                child: Container(
                  width: 60.5.w,
                  height: 32.5.w,
                  color: Colors.transparent,
                  child: LocalPNG(
                    width: 60.5.w,
                    height: 32.5.w,
                    url: "assets/images/mine/avatar-makeup.png",
                    alignment: Alignment.bottomCenter,
                    fit: BoxFit.cover,
                  ),
                )),
          ]),
        ),
        Expanded(
            child: Container(
          height: 50.w,
          child: InfoNickname(),
        )),
        NeedLogin()
      ],
    );
  }

  _vipWidget() {
    var vipValue;
    var profile = Provider.of<GlobalState>(context).profileData;
    var members = Provider.of<HomeConfig>(context).member;
    if (["", null, false, 0].contains(profile)) {
      vipValue = 0;
    } else {
      vipValue = profile?['vip_level'];
    }
    String vipTag = '开通会员';
    var texts = "";
    if (profile?['old_vip'] == 1) {
      texts = "永久会员";
    } else {
      if (profile?['expired_at'] == 0) {
        texts = "您还未开通茶馆会员";
      } else {
        vipTag = '立即续费';
        var times = new DateTime.fromMillisecondsSinceEpoch(profile?['expired_at'] * 1000);
        texts = ' ${times.year}-${times.month}-${times.day} 到期';
      }
    }
    return SliverToBoxAdapter(
      child: Container(
        width: double.infinity,
        height: 60.w,
        margin: EdgeInsets.only(top: 10.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(255, 255, 255, 1.0),
              Color.fromRGBO(200, 200, 200, 1.0),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
//                        image: AssetImage()
        ),
        alignment: Alignment.center,
        child: GestureDetector(
          onTap: () {
            AppGlobal.appRouter?.push(CommonUtils.getRealHash('memberCardsPage'));
          },
          behavior: HitTestBehavior.translucent,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              ImageNetTool(
                url:
                    members.vipInfo!['img_url'].isEmpty ? AppGlobal.VipList[0]['img_url'] : members.vipInfo!['img_url'],
                fit: BoxFit.fill,
              ),
              Positioned(
                left: 10.w,
                right: 10.w,
                child: Container(
                  child: Row(
                    children: <Widget>[
                      SizedBox(width: 43.w, height: 35.w),
                      Padding(
                        padding: EdgeInsets.only(left: 10.w),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              members.vipInfo!['pname'].toString(),
                              textAlign: TextAlign.left,
                              style: TextStyle(color: Colors.white, fontSize: 18.sp),
                            ),
                            Text(
                              texts,
                              textAlign: TextAlign.left,
                              style: TextStyle(color: Colors.white, fontSize: 12.sp),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 80.w,
                        height: 28.w,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28.w),
                        ),
                        child: Center(
                          child: Text(
                            vipTag,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: StyleTheme.cTitleColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TitleBar extends StatelessWidget {
  final double opacityvalue;

  const TitleBar({Key? key, this.opacityvalue = 0.0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 16.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: 23.w,
            height: 23.w,
          ),
          Expanded(
              child: Center(
            child: Opacity(
              opacity: opacityvalue,
              child: AppbarNickname(),
            ),
          )),
          GestureDetector(
            onTap: () {
              AppGlobal.appRouter?.push(CommonUtils.getRealHash('setting'));
            },
            child: LocalPNG(
              width: 23.w,
              height: 23.w,
              url: "assets/images/mine/icon-settings.png",
              alignment: Alignment.center,
            ),
          ),
        ],
      ),
    );
  }
}

class AppbarNickname extends StatelessWidget {
  AppbarNickname({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeConfig>(
      builder: (ctx, state, child) => Text("${state.member.nickname}",
          style: TextStyle(color: StyleTheme.cTitleColor, fontWeight: FontWeight.w500, fontSize: 18.sp)),
    );
  }
}

class AvatarBox extends StatelessWidget {
  AvatarBox({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeConfig>(
        builder: (ctx, state, child) => Container(
            width: double.infinity,
            height: double.infinity,
            child: Stack(
              children: [
                LocalPNG(
                  width: double.infinity,
                  height: double.infinity,
                  url: 'assets/images/common/${state.member.thumb}.png',
                ),
                state.member.vipLevel == 4 ? LocalPNG(url: 'assets/images/common/vip5.png') : SizedBox(),
              ],
            )));
  }
}

class UserVip extends StatelessWidget {
  const UserVip({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var vipValue;
    var profile = Provider.of<GlobalState>(context).profileData;
    if (["", null, false, 0].contains(profile)) {
      vipValue = 0;
    } else {
      vipValue = profile?['vip_level'];
    }
    Widget vipIcon;
    switch (vipValue) {
      case 0:
        vipIcon = SizedBox(
          height: 0,
        );
        break;
      case 1:
        vipIcon = LocalPNG(url: 'assets/images/mine/level1.png');
        break;
      case 2:
        vipIcon = LocalPNG(url: 'assets/images/mine/level2.png');
        break;
      case 3:
        vipIcon = LocalPNG(url: 'assets/images/mine/level3.png');
        break;
      case 4:
        vipIcon = LocalPNG(url: 'assets/images/mine/level4.png');
        break;
      default:
        vipIcon = SizedBox(
          width: 0,
          height: 0,
        );
        break;
    }
    return Container(
      width: vipValue == 0 ? 0 : 47.w,
      height: 23.w,
      padding: vipValue == 0 ? EdgeInsets.only(bottom: 10) : EdgeInsets.only(right: 10),
      child: vipIcon,
    );
  }
}

class UserVipDate extends StatelessWidget {
  const UserVipDate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var members = Provider.of<HomeConfig>(context).member;
    var texts = "";
    if (members.oldVip == 1) {
      texts = "永久会员";
    } else {
      if (members.expiredAt == 0) {
        texts = "";
      } else {
        var times = new DateTime.fromMillisecondsSinceEpoch(members.expiredAt! * 1000);
        texts = ' ${times.year}-${times.month}-${times.day} 到期';
      }
    }
    return Text(
      texts,
      textAlign: TextAlign.left,
      style: TextStyle(color: StyleTheme.cBioColor, fontSize: 12.sp),
    );
  }
}

class MenuCard extends StatelessWidget {
  final String? image;
  final String? title;
  final GestureTapCallback? onTap;

  const MenuCard({Key? key, this.image, this.title, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
        ),
        child: Column(children: <Widget>[
          LocalPNG(
            url: image,
            width: 45.w,
            height: 45.w,
          ),
          SizedBox(height: 10.w),
          Text(
            title!,
            style: TextStyle(
              fontSize: 12.sp,
              color: StyleTheme.cTitleColor,
            ),
          )
        ]),
      ),
    );
  }
}

class ListTileItem extends StatelessWidget {
  final String? image;
  final String? title;
  final Widget? trailing;
  final GestureTapCallback? onTap;
  final bool? isShowArrow;

  const ListTileItem({Key? key, this.image, this.title, this.trailing, this.onTap, this.isShowArrow = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.translucent,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.w),
        child: Row(
          children: <Widget>[
            LocalPNG(
              url: image,
              width: 30.w,
              height: 30.w,
            ),
            SizedBox(
              width: 10.w,
            ),
            Expanded(
              child: Text(
                title!,
                style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 15.sp),
              ),
            ),
            trailing ?? SizedBox(),
            isShowArrow!
                ? LocalPNG(
                    url: "assets/images/mine/arow.png",
                    width: 20.w,
                    height: 20.w,
                  )
                : SizedBox(),
          ],
        ),
      ),
    );
  }
}
