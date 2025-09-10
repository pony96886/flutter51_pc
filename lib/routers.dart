import 'package:bot_toast/bot_toast.dart';
import 'package:chaguaner2023/components/cg_webview.dart';
import 'package:chaguaner2023/components/forgetpassword.dart';
import 'package:chaguaner2023/error_screen.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/widget_utils.dart';
import 'package:chaguaner2023/view/cooperate/boss_connect.dart';
import 'package:chaguaner2023/view/cooperate/cha_girl_confirm.dart';
import 'package:chaguaner2023/view/cooperate/chagirl_%20review.dart';
import 'package:chaguaner2023/view/cooperate/chagirlbaseinformation.dart';
import 'package:chaguaner2023/view/cooperate/employmentintroduce.dart';
import 'package:chaguaner2023/view/cooperate/fatiecishushuoming.dart';
import 'package:chaguaner2023/view/cooperate/girlWorkbench.dart';
import 'package:chaguaner2023/view/cooperate/resourcesCertification.dart';
import 'package:chaguaner2023/view/cooperate/workbench.dart';
import 'package:chaguaner2023/view/home.dart';
import 'package:chaguaner2023/view/homepage/activity_page.dart';
import 'package:chaguaner2023/view/homepage/adopt.dart';
import 'package:chaguaner2023/view/homepage/adopt_release.dart';
import 'package:chaguaner2023/view/homepage/applicationcenter.dart';
import 'package:chaguaner2023/view/homepage/authentication_list.dart';
import 'package:chaguaner2023/view/homepage/browser.dart';
import 'package:chaguaner2023/view/homepage/cgmall.dart';
import 'package:chaguaner2023/view/homepage/cgrank.dart';
import 'package:chaguaner2023/view/homepage/gamepage.dart';
import 'package:chaguaner2023/view/homepage/games/recharge.dart';
import 'package:chaguaner2023/view/homepage/games/recording.dart';
import 'package:chaguaner2023/view/homepage/games/withdraw.dart';
import 'package:chaguaner2023/view/homepage/girlDetail.dart';
import 'package:chaguaner2023/view/homepage/nakedchat/index.dart';
import 'package:chaguaner2023/view/homepage/nakedchat/nackdchat_mark.dart';
import 'package:chaguaner2023/view/homepage/nakedchat/nakedchat_complain.dart';
import 'package:chaguaner2023/view/homepage/nakedchat/nakedchat_detail.dart';
import 'package:chaguaner2023/view/homepage/nakedchat/nakedchat_manage.dart';
import 'package:chaguaner2023/view/homepage/nakedchat/nakedchat_pay.dart';
import 'package:chaguaner2023/view/homepage/nakedchat/nakedchat_publish.dart';
import 'package:chaguaner2023/view/homepage/nakedchat/nakedchat_success.dart';
import 'package:chaguaner2023/view/homepage/office_message.dart';
import 'package:chaguaner2023/view/homepage/online_service.dart';
import 'package:chaguaner2023/view/homepage/payout_list.dart';
import 'package:chaguaner2023/view/homepage/report.dart';
import 'package:chaguaner2023/view/homepage/search_result.dart';
import 'package:chaguaner2023/view/homepage/talk_detail.dart';
import 'package:chaguaner2023/view/homepage/talklist.dart';
import 'package:chaguaner2023/view/homepage/teaAppreciator.dart';
import 'package:chaguaner2023/view/homepage/teablack_detail.dart';
import 'package:chaguaner2023/view/homepage/teablacklist.dart';
import 'package:chaguaner2023/view/homepage/teablank_comment.dart';
import 'package:chaguaner2023/view/homepage/to_be_verified.dart';
import 'package:chaguaner2023/view/homepage/up_auth.dart';
import 'package:chaguaner2023/view/homepage/video_publish.dart';
import 'package:chaguaner2023/view/mine/mine_game/game_webview.dart';
import 'package:chaguaner2023/view/mine/mine_game/recharge.dart';
import 'package:chaguaner2023/view/mine/mine_game/recording.dart';
import 'package:chaguaner2023/view/mine/mine_ingot/mine_ingot_wallet_page.dart';
import 'package:chaguaner2023/view/mine/mine_ingot/mine_ingots_detail_page.dart';
import 'package:chaguaner2023/view/mine/mine_reservation/mine_reservation_page.dart';
import 'package:chaguaner2023/view/mine/mine_video_work/mine_video_work_page.dart';
import 'package:chaguaner2023/view/im/im_page.dart';
import 'package:chaguaner2023/view/im/share_meizi.dart';
import 'package:chaguaner2023/view/mine/mine_recharge_record/mine_recharge_record_page.dart';
import 'package:chaguaner2023/view/loginPage.dart';
import 'package:chaguaner2023/view/mall/buy_commodity.dart';
import 'package:chaguaner2023/view/mall/commodity_categories.dart';
import 'package:chaguaner2023/view/mall/commodity_detail.dart';
import 'package:chaguaner2023/view/mall/commodity_evaluate.dart';
import 'package:chaguaner2023/view/mall/mall_complaint.dart';
import 'package:chaguaner2023/view/mall/mall_publish.dart';
import 'package:chaguaner2023/view/mall/merchant_home.dart';
import 'package:chaguaner2023/view/mine/mine_user_mall_order/mine_user_mall_order_page.dart';
import 'package:chaguaner2023/view/mine/mine_pin_cha_bao/mine_ping_cha_bao_page.dart';
import 'package:chaguaner2023/view/mine/mine_adopt_manege_screen/mine_adopt_manage_page.dart';
import 'package:chaguaner2023/view/mine/mine_cardpack/mine_cardpack_page.dart';
import 'package:chaguaner2023/view/mine/mine_setting/mine_setting_change_password_page.dart';
import 'package:chaguaner2023/view/mine/mine_elegantcollect/mine_elegantcollect_page.dart';
import 'package:chaguaner2023/view/mine/mine_cardpack/mine_cardpack_exchange_coupon_page.dart';
import 'package:chaguaner2023/view/mine/mine_ingot/mine_ingot_exchange_member_page.dart';
import 'package:chaguaner2023/view/mine/mine_merchant_center/mine_merchant_center_page.dart';
import 'package:chaguaner2023/view/mine/mine_mony/mine_mony_detail_page.dart';
import 'package:chaguaner2023/view/mine/mine_mony/mine_mony_page.dart';
import 'package:chaguaner2023/view/mine/mine_tea_post/mine_tea_post_page.dart';
import 'package:chaguaner2023/view/mine/mine_popularize/mine_popularize_page.dart';
import 'package:chaguaner2023/view/mine/mine_withdraw/mine_withdraw_record_page.dart';
import 'package:chaguaner2023/view/mine/mine_promotion_record/mine_promotion_record_page.dart';
import 'package:chaguaner2023/view/mine/mine_share/mine_share_method_page.dart';
import 'package:chaguaner2023/view/mine/mine_share_qrcode/mine_share_qrcode_page.dart';
import 'package:chaguaner2023/view/mine/mine_withdraw/mine_withdraw_page.dart';
import 'package:chaguaner2023/view/mine/mine_withdraw/mine_withdraw_account.dart';
import 'package:chaguaner2023/view/mine/mine_member/mine_member_page.dart';
import 'package:chaguaner2023/view/post_review.dart';
import 'package:chaguaner2023/view/preview/adopt_pic_view_page.dart';
import 'package:chaguaner2023/view/preview/tea_pic_view_page.dart';
import 'package:chaguaner2023/view/report_details.dart';
import 'package:chaguaner2023/view/mine/mine_setting/mine_setting_bind_phone_page.dart';
import 'package:chaguaner2023/view/mine/mine_setting/mine_setting_change_phone_page.dart';
import 'package:chaguaner2023/view/mine/mine_setting/mine_setting.dart';
import 'package:chaguaner2023/view/system_notice.dart';
import 'package:chaguaner2023/view/tea/tea_list.dart';
import 'package:chaguaner2023/view/teablackpublish.dart';
import 'package:chaguaner2023/view/tianziyihao/tianziyihao.dart';
import 'package:chaguaner2023/view/unlockmsg.dart';
import 'package:chaguaner2023/view/upload/elegantpublish.dart';
import 'package:chaguaner2023/view/upload/publishPage.dart';
import 'package:chaguaner2023/view/upload/publish_rule.dart';
import 'package:chaguaner2023/view/upload/publishguide.dart';
import 'package:chaguaner2023/view/upload/xiaoerOder.dart';
import 'package:chaguaner2023/view/waitingaudit.dart';
import 'package:chaguaner2023/view/welcome.dart';
import 'package:chaguaner2023/view/yajian/auth_beauty.dart';
import 'package:chaguaner2023/view/yajian/brokerHomepage.dart';
import 'package:chaguaner2023/view/yajian/huakuiPage.dart';
import 'package:chaguaner2023/view/yajian/intention_detail.dart';
import 'package:chaguaner2023/view/yajian/self_winning_record.dart';
import 'package:chaguaner2023/view/yajian/taihua_detail.dart';
import 'package:chaguaner2023/view/yajian/tanhua.dart';
import 'package:chaguaner2023/view/yajian/tanhua_list.dart';
import 'package:chaguaner2023/view/yajian/teaTastingIntention.dart';
import 'package:chaguaner2023/view/yajian/vip_comment.dart';
import 'package:chaguaner2023/view/yajian/vip_detail.dart';
import 'package:chaguaner2023/view/yajian/winningrecord.dart';
import 'package:chaguaner2023/view/yajian/yiyuanchunxiao.dart';
import 'package:chaguaner2023/view/yajian/yuyueSuccess.dart';
import 'package:chaguaner2023/view/zhaopiao/adopt_complain.dart';
import 'package:chaguaner2023/view/zhaopiao/adopt_details.dart';
import 'package:chaguaner2023/view/zhaopiao/resource_details.dart';
import 'package:chaguaner2023/view/zhaopiao/verification_report.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GoRouterModel {
  GoRouterModel({this.key, this.builder, this.pageBuilder});
  String? key;
  Widget Function(BuildContext, GoRouterState)? builder;
  Page<void> Function(BuildContext, GoRouterState)? pageBuilder;
}

extension GetGoRouter on GoRouterModel {
  GoRoute toGoRouter({List<GoRoute>? routes}) {
    return this.pageBuilder != null
        ? GoRoute(path: this.key!, pageBuilder: this.pageBuilder, routes: routes ?? [])
        : GoRoute(path: this.key!, builder: this.builder!, routes: routes ?? []);
  }
}

class Routes {
  //首页
  static GoRouterModel home = GoRouterModel(key: 'home', builder: (context, state) => Home());
  //虚拟茶叶列表
  static GoRouterModel tealist = GoRouterModel(
      key: 'tealist',
      pageBuilder: (context, state) =>
          TeaListPage().addTransitionPage(state.pageKey, transitionDuration: 50, isAnimation: false));
//活动webView
  static GoRouterModel activityPage = GoRouterModel(
      key: 'activityPage/:activityUrl',
      builder: (context, state) => ActivityPage(
            url: Uri.decodeComponent(state.pathParameters['activityUrl']!),
          ));
//应用中心
  static GoRouterModel applicationCenter =
      GoRouterModel(key: 'applicationCenter', builder: (context, state) => ApplicationCenter());
  //兑换会员
  static GoRouterModel exchangeMember =
      GoRouterModel(key: 'exchangemember', builder: (context, state) => MineIngotExchangeMemberPage());
//兑换优惠券
  static GoRouterModel exchangeCoupon =
      GoRouterModel(key: 'exchangecoupon', builder: (context, state) => MineCardpackExchangeCouponPage());
//每日茶谈
  static GoRouterModel talkListPage = GoRouterModel(key: 'talkListPage', builder: (context, state) => TalkListPage());
  static GoRouterModel authenticationList =
      GoRouterModel(key: 'authenticationList', builder: (context, state) => AuthenticationList());
  // PayoutList
  static GoRouterModel payoutList = GoRouterModel(key: 'payoutList', builder: (context, state) => PayoutList());
  //茶谈详情
  static GoRouterModel tackDetailPage = GoRouterModel(
      key: 'tackDetailPage/:tackId',
      builder: (context, state) => TackDetailPage(
            id: state.pathParameters['tackId'],
          ));
  //茶谈外部链接
  static GoRouterModel browser = GoRouterModel(
      key: 'browser/:browserUrl/:browserTitle',
      builder: (context, state) => Browser(
            url: state.pathParameters['browserUrl'],
            title: state.pathParameters['browserTitle'],
          ));
  //验茶报告
  static GoRouterModel reportPage = GoRouterModel(key: 'reportPage', builder: (context, state) => ReportPage());
  //鉴察师认证
  static GoRouterModel teaAppreciator =
      GoRouterModel(key: 'teaAppreciator', builder: (context, state) => TeaAppreciator());

  //茶馆黑榜
  static GoRouterModel teaBlackList = GoRouterModel(key: 'teaBlackList', builder: (context, state) => TeaBlackList());

//茶馆黑榜曝光
  static GoRouterModel teaBlackPublish =
      GoRouterModel(key: 'teaBlackPublish', builder: (context, state) => TeaBlackPublish());

  //茶馆黑榜发布待审核
  static GoRouterModel waittingStatusPage =
      GoRouterModel(key: 'waittingStatusPage', builder: (context, state) => WaittingStatusPage());

  //待验证茶帖
  static GoRouterModel toBeVerifiedPage =
      GoRouterModel(key: 'toBeVerifiedPage', builder: (context, state) => ToBeVerifiedPage());

  //登录注册
  static GoRouterModel loginPage = GoRouterModel(
      key: 'loginPage/:logType',
      builder: (context, state) => LoginPage(
            type: int.parse(state.pathParameters['logType']!),
          ));
  //忘记密码
  static GoRouterModel forgetPassword =
      GoRouterModel(key: 'forgetPassword', builder: (context, state) => ForgetPassword());
  //设置
  static GoRouterModel setting = GoRouterModel(key: 'setting', builder: (context, state) => MineSettingPage());
  //修改手机号
  static GoRouterModel changePhone = GoRouterModel(
      key: 'changePhone/:cphone/:cshowPhone/:cphonePrefix',
      builder: (context, state) => MineSettingChangePhone(
            phone: state.pathParameters['cphone'],
            showPhone: state.pathParameters['cshowPhone'],
            phonePrefix: state.pathParameters['cphonePrefix'],
          ));
  //会员卡充值
  static GoRouterModel memberCardsPage =
      GoRouterModel(key: 'memberCardsPage', builder: (context, state) => MineMemberPage());
  //绑定手机号
  static GoRouterModel bindphone =
      GoRouterModel(key: 'bindphone', builder: (context, state) => MineSettingBindPhonePage());
  //绑定手机号
  static GoRouterModel tianZiYiHaoPage = GoRouterModel(
      key: 'tianZiYiHaoPage/:vipClub',
      builder: (context, state) => TianZiYiHaoPage(
            vipClub: state.pathParameters['vipClub'],
          ));
//订单记录
  static GoRouterModel rechargeRecord = GoRouterModel(
      key: 'rechargeRecord/:rechargtype',
      builder: (context, state) => MineRechargeRecordPage(
            type: state.pathParameters['rechargtype'],
          ));

//在线客服
  static GoRouterModel onlineServicePage =
      GoRouterModel(key: 'onlineServicePage', builder: (context, state) => OnlineServicePage());

  //包养管理
  static GoRouterModel adoptManageScreen =
      GoRouterModel(key: 'adoptManageScreen', builder: (context, state) => MineAdoptManegeScreenPage());

  //官方消息
  static GoRouterModel officeMessage =
      GoRouterModel(key: 'officeMessage', builder: (context, state) => OfficeMessagePage());

//品茶宝
  static GoRouterModel pingChaBaoPage =
      GoRouterModel(key: 'pingChaBaoPage', builder: (context, state) => MinePingChaBaoPage());

//元宝充值
  static GoRouterModel ingotWallet =
      GoRouterModel(key: 'ingotWallet', builder: (context, state) => MineIngotWalletPage());

//元宝提现
  static GoRouterModel withdrawPage = GoRouterModel(
      key: 'withdrawPage/:type',
      builder: (context, state) => MineWithdrawPage(type: int.parse(state.pathParameters['type']!)));

//提现记录
  static GoRouterModel withdrawRecordPage = GoRouterModel(
      key: 'withdrawRecordPage/:t',
      builder: (context, state) => MineWithdrawRecordPage(type: int.parse(state.pathParameters['t']!)));
//选择提现账号
  static GoRouterModel withdrawAccountPage = GoRouterModel(
      key: 'withdrawAccountPage/:withdrawId',
      builder: (context, state) => MineWithdrawAccountPage(
            selectId: state.pathParameters['withdrawId']!,
          ));

  //选择提现账号
  static GoRouterModel ingotsDetailPage =
      GoRouterModel(key: 'ingotsDetailPage', builder: (context, state) => MineIngotsDetailPage());

  //推广赚钱
  static GoRouterModel popularize = GoRouterModel(key: 'popularize', builder: (context, state) => MinePopularizePage());

  //推广记录
  static GoRouterModel promotionRecordPage =
      GoRouterModel(key: 'promotionRecordPage', builder: (context, state) => MinePromotionRecordPage());

  //二维码分享
  static GoRouterModel shareQRCodePage =
      GoRouterModel(key: 'shareQRCodePage', builder: (context, state) => MineShareQRCodePage());

  //图片预览
  static GoRouterModel teaViewPicPage = GoRouterModel(
      key: 'teaViewPicPage',
      builder: (context, state) => TeaPicViewPage(
            pramas: AppGlobal.picMap,
          ));

  // AdoptPicViewPage
  static GoRouterModel adoptViewPicPage = GoRouterModel(
      key: 'adoptViewPicPage',
      builder: (context, state) => AdoptPicViewPage(
            pramas: AppGlobal.picMap,
          ));

  //邀请方法
  static GoRouterModel shareMethodPage =
      GoRouterModel(key: 'shareMethodPage', builder: (context, state) => MineShareMethodPage());

  //邀请方法
  static GoRouterModel gamePage = GoRouterModel(key: 'gamePage', builder: (context, state) => GamePage());
//游戏充值
  static GoRouterModel rechargePage = GoRouterModel(key: 'rechargePage', builder: (context, state) => RechargePage());

//游戏充值记录
  static GoRouterModel recordingPage = GoRouterModel(
      key: 'recordingPage/:recordingType',
      builder: (context, state) => RecordingPage(
            type: int.parse(state.pathParameters['recordingType']!),
          ));
//活动webView
  static GoRouterModel gameWebView = GoRouterModel(
      key: 'gameWebView/:gameUrl/:gameTitle',
      builder: (context, state) => GameWebView(
            url: state.pathParameters['gameUrl'],
            title: state.pathParameters['gameTitle'] == '0' ? '' : state.pathParameters['gameTitle'],
          ));
//活动webView
  static GoRouterModel youhuiquanCard =
      GoRouterModel(key: 'youhuiquanCard', builder: (context, state) => MineCardpackPage());
//我的茶帖
  static GoRouterModel myTeaPost = GoRouterModel(
      key: 'myTeaPost/:tab',
      builder: (context, state) => MineMyTeaPostPage(
            initTab: int.parse(state.pathParameters['tab']!),
          ));

  //茶帖详情
  static GoRouterModel resourcesDetailPage = GoRouterModel(
      key: 'resourcesDetailPage/:isBrokerhome/:id/:isComplaint/:buyId/:rtype',
      builder: (context, state) => ResourcesDetailPage(
            type: state.pathParameters['rtype'] == 'null' ? 1 : int.parse(state.pathParameters['rtype']!),
            id: state.pathParameters['id']!,
            buyId: state.pathParameters['buyId'] == 'null' ? null : state.pathParameters['buyId'],
            isBrokerhome: state.pathParameters['isBrokerhome'] == 'null'
                ? false
                : (state.pathParameters['isBrokerhome'] == 'false' ? false : true),
            isComplaint: state.pathParameters['isComplaint'] == 'null'
                ? true
                : (state.pathParameters['isComplaint'] == 'false' ? false : true),
          ));

  static GoRouterModel adoptDetailPage = GoRouterModel(
      key: 'adoptDetailPage/:id',
      builder: (context, state) => AdoptDetailPage(
            id: state.pathParameters['id']!,
          ));

  //验证茶帖
  static GoRouterModel verificationReportPage = GoRouterModel(
      key: 'verificationReportPage/:vrid/:vragent/:vrindex/:vrisReport',
      builder: (context, state) => VerificationReportPage(
            id: state.pathParameters['vrid'] == 'null' ? null : state.pathParameters['vrid'],
            agent: state.pathParameters['vragent'] == 'null' ? null : int.parse(state.pathParameters['vragent']!),
            index: state.pathParameters['vrindex'] == 'null' ? null : int.parse(state.pathParameters['vrindex']!),
            isReport: state.pathParameters['vrisReport'] == 'null'
                ? false
                : (state.pathParameters['vrisReport'] == 'false' ? false : true),
          ));
  //意向单
  static GoRouterModel teaTastingIntention = GoRouterModel(
      key: 'teaTastingIntention/:orderid',
      builder: (context, state) => TeaTastingIntention(
            oderId: state.pathParameters['orderid'] == 'null' ? null : state.pathParameters['orderid'].toString(),
          ));
  //雅间详情
  static GoRouterModel vipDetailPage = GoRouterModel(
    key: 'vipDetailPage/:gid/:type',
    builder: (context, state) => VipDetailPage(
      id: state.pathParameters['gid'],
      type: state.pathParameters['type'] == 'null' ? "0" : "1",
    ),
  );
  //花魁阁楼
  static GoRouterModel huakuiGelou = GoRouterModel(key: 'huakuiGelou', builder: (context, state) => HuakuiGelou());
  //Webview
  static GoRouterModel webview = GoRouterModel(
      key: 'webview/:webviewUrl/:webviewTitle',
      builder: (context, state) {
        return CgWebview(
            url: state.pathParameters['webviewUrl'],
            title: state.pathParameters['webviewTitle'] == 'null' ? '' : state.pathParameters['webviewTitle']);
      });
  //品茶探花
  static GoRouterModel tanhuaPage = GoRouterModel(
      key: 'tanhuaPage',
      builder: (context, state) {
        return TanhuaPage();
      });

  //探花列表
  static GoRouterModel tanhuaListPage = GoRouterModel(
      key: 'tanhuaListPage',
      builder: (context, state) {
        return TanhuaListPage();
      });

  //探花详情
  static GoRouterModel tanhuaDetailPage = GoRouterModel(
      key: 'tanhuaDetailPage/:tanhuaId',
      builder: (context, state) {
        return TanhuaDetailPage(
          id: state.pathParameters['tanhuaId'],
        );
      });
  //一夜春宵
  static GoRouterModel oneYuanSpring = GoRouterModel(
      key: 'OneYuanSpring',
      builder: (context, state) {
        return OneYuanSpring();
      });

  //中奖记录
  static GoRouterModel winningRecord = GoRouterModel(
      key: 'WinningRecord',
      builder: (context, state) {
        return WinningRecord();
      });

  //中奖记录
  static GoRouterModel selfWinningRecord = GoRouterModel(
      key: 'selfWinningRecord',
      builder: (context, state) {
        return SelfWinningRecord();
      });
  //认证美女
  static GoRouterModel authBeautyPage = GoRouterModel(
      key: 'authBeautyPage',
      builder: (context, state) {
        return AuthBeautyPage();
      });
  //预约和意向单
  static GoRouterModel reservationPage = GoRouterModel(
      key: 'reservationPage',
      builder: (context, state) {
        return MineReservationPage();
      });
  //雅间收藏
  static GoRouterModel elegantCollect = GoRouterModel(
      key: 'elegantCollect',
      builder: (context, state) {
        return MineElegantCollect();
      });
  //我的铜钱
  static GoRouterModel myMonyPage = GoRouterModel(
      key: 'myMonyPage',
      builder: (context, state) {
        return MineMonyPage();
      });

  //铜钱明细
  static GoRouterModel monyDtailPage = GoRouterModel(
      key: 'monyDtailPage',
      builder: (context, state) {
        return MineMonyDtailPage();
      });

  //搜索
  static GoRouterModel searchResult = GoRouterModel(
      key: 'searchResult',
      builder: (context, state) {
        return SearchResult(
          parmas: state.extra,
        );
      });
  // 包养发布
  static GoRouterModel adoptReleasePage = GoRouterModel(
      key: 'adoptReleasePage',
      builder: (context, state) {
        return AdoptReleasePage();
      });
  //搜索结果
  static GoRouterModel searchSuggestionList = GoRouterModel(
      key: 'searchSuggestionList/:searchTitle',
      builder: (context, state) {
        return SearchSuggestionList(
            title: state.pathParameters['searchTitle'], extra: state.extra as Map<dynamic, dynamic>?);
      });
  //认证合作页面
  static GoRouterModel employmentIntroduce = GoRouterModel(
      key: 'employmentIntroduce/:etype',
      builder: (context, state) {
        return EmploymentIntroduce(
          type: int.parse(state.pathParameters['etype']!),
        );
      });
  //茶女郎视频认证
  static GoRouterModel chaGirlConfirmPage = GoRouterModel(
      key: 'chaGirlConfirmPage',
      builder: (context, state) {
        return ChaGirlConfirmPage();
      });

  //雅间老板工作台
  static GoRouterModel workbenchPage = GoRouterModel(
      key: 'workbenchPage',
      builder: (context, state) {
        return WorkbenchPage();
      });

//雅间妹子上传
  static GoRouterModel elegantPublishPage = GoRouterModel(
      key: 'elegantPublishPage',
      builder: (context, state) {
        return ElegantPublishPage(
          cardInfo: AppGlobal.uploadParmas,
        );
      });

  //雅间妹子上传成功
  static GoRouterModel waitingaudit = GoRouterModel(
      key: 'waitingaudit/:wtype',
      builder: (context, state) {
        return WaitingAudit(
          type: int.parse(state.pathParameters['wtype'] ?? '1'),
        );
      });

  //大厅妹子上传
  static GoRouterModel publishPage = GoRouterModel(
      key: 'publishPage/:pid',
      builder: (context, state) {
        return PublishPage(
          id: state.pathParameters['pid'] == 'null' ? null : state.pathParameters['pid'],
        );
      });

  //发帖赚钱
  static GoRouterModel publishGuide = GoRouterModel(
      key: 'publishGuide',
      builder: (context, state) {
        return PublishGuide();
      });

  //发帖规则
  static GoRouterModel faTieCiShuShuoMingPage = GoRouterModel(
      key: 'faTieCiShuShuoMingPage',
      builder: (context, state) {
        return FaTieCiShuShuoMingPage();
      });

  //茶铺认证
  static GoRouterModel resourcesCertification = GoRouterModel(
      key: 'resourcesCertification',
      builder: (context, state) {
        return ResourcesCertification();
      });

  //茶小二抢单
  static GoRouterModel xiaoerOser = GoRouterModel(
      key: 'xiaoerOser',
      builder: (context, state) {
        return XiaoerOser();
      });
  //茶女郎申请
  static GoRouterModel chaGirlBaseInformation = GoRouterModel(
      key: 'chaGirlBaseInformation',
      builder: (context, state) {
        return ChaGirlBaseInformation(
          editImage: AppGlobal.girlParmas['editImage'],
          editVideo: AppGlobal.girlParmas['editVideo'],
          editInfoData: AppGlobal.girlParmas['editInfoData'],
          authvideo: AppGlobal.girlParmas['authvideo'],
          voicenumber: AppGlobal.girlParmas['voicenumber'],
        );
      });
  //茶女郎审核
  static GoRouterModel chagirlReview = GoRouterModel(
      key: 'chagirlReview',
      builder: (context, state) {
        return ChagirlReview();
      });
  //茶女郎工作台
  static GoRouterModel girlWorkbenchPage = GoRouterModel(
      key: 'girlWorkbenchPage',
      builder: (context, state) {
        return GirlWorkbenchPage();
      });
//预约成功
  static GoRouterModel yuyuesuccess = GoRouterModel(
      key: 'yuyuesuccess/:yfee/:yyouhui/:ytitle/:ynickname/:ytype',
      builder: (context, state) {
        return Yuyuesuccess(
          youhui: int.parse(state.pathParameters['yyouhui'] ?? '0'),
          fee: int.parse(state.pathParameters['yfee'] ?? '0'),
          title: state.pathParameters['ytitle'],
          nickname: state.pathParameters['ynickname'],
          type: int.parse(state.pathParameters['ytype']!),
        );
      });
  //茶铺 茶女郎 详情
  static GoRouterModel gilrDrtailPage = GoRouterModel(
      key: 'gilrDrtailPage/:gid/:gtype',
      builder: (context, state) {
        return GilrDrtailPage(
          id: state.pathParameters['gid'],
          type: int.parse(state.pathParameters['gtype']!),
        );
      });

  //验茶报告详情
  static GoRouterModel reportDetailPage = GoRouterModel(
      key: 'reportDetailPage/:rid/:rinfoId/:risDetail',
      builder: (context, state) {
        return ReportDetailPage(
            id: int.parse(state.pathParameters['rid']!),
            infoId: state.pathParameters['rinfoId'],
            isDetail: state.pathParameters['risDetail'] == 'false' ? false : true);
      });

  //个人主页
  static GoRouterModel brokerHomepage = GoRouterModel(
      key: 'brokerHomepage/:bhaff/:bhthumb/:bhname',
      builder: (context, state) {
        return BrokerHomepage(
          aff: state.pathParameters['bhaff'],
          brokerName: state.pathParameters['bhname'],
          thumb: state.pathParameters['bhthumb'],
        );
      });

  //系统通知
  static GoRouterModel systemNoticePage = GoRouterModel(
      key: 'systemNoticePage',
      builder: (context, state) {
        return SystemNoticePage();
      });
  //解锁和验证
  static GoRouterModel unlockPage = GoRouterModel(
      key: 'unlockPage',
      builder: (context, state) {
        return UnlockPage();
      });
  //im
  static GoRouterModel llchat = GoRouterModel(
      key: 'llchat',
      builder: (context, state) {
        return LLchat();
      });

  //意向单详情
  static GoRouterModel intentionDetailPage = GoRouterModel(
      key: 'intentionDetailPage/:intentionId',
      builder: (context, state) {
        return IntentionDetailPage(
          id: state.pathParameters['intentionId'],
        );
      });
  //妹子分享
  static GoRouterModel shareMeiziPage = GoRouterModel(
      key: 'shareMeiziPage',
      builder: (context, state) {
        return ShareMeiziPage();
      });
  //游戏充值提现记录
  static GoRouterModel gameRecordingPage = GoRouterModel(
      key: 'gameRecordingPage/:gametype',
      builder: (context, state) {
        return GameRecordingPage(
          type: int.parse(state.pathParameters['gametype']!),
        );
      });

  //游戏提现
  static GoRouterModel gameWithdrawPage = GoRouterModel(
      key: 'gameWithdrawPage',
      builder: (context, state) {
        return GameWithdrawPage();
      });

  //游戏提现
  static GoRouterModel gameRechargePage = GoRouterModel(
      key: 'gameRechargePage',
      builder: (context, state) {
        return GameRechargePage();
      });
  //修改密码
  static GoRouterModel changePassword = GoRouterModel(
      key: 'changePassword/:issetting',
      builder: (context, state) {
        return MineSettingChangePasswordPage(
          isSetting: state.pathParameters['issetting'] == 'true',
        );
      });
//茶帖审核
  static GoRouterModel postReviewPage = GoRouterModel(
      key: 'postReviewPage',
      builder: (context, state) {
        return PostReviewPage();
      });

//茶馆商城
  static GoRouterModel cgmallPage = GoRouterModel(
      key: 'cgmallPage',
      builder: (context, state) {
        return CgmallPage();
      });

  static GoRouterModel cgRankPage = GoRouterModel(
      key: 'cgrankPage',
      builder: (context, state) {
        return CgRankPage();
      });
  //包养
  static GoRouterModel adoptPage = GoRouterModel(
      key: 'adoptPage',
      builder: (context, state) {
        return AdoptScreen();
      });
  //商家中心
  static GoRouterModel merchantCenter = GoRouterModel(
      key: 'merchantCenter',
      builder: (context, state) {
        return MineMerchantCenterPage();
      });
  //商家中心
  static GoRouterModel commodityDetail = GoRouterModel(
      key: 'commodityDetail/:id',
      builder: (context, state) {
        return CommodityDetail(
          id: int.parse(state.pathParameters['id']!),
        );
      });
  //商家中心
  static GoRouterModel buyCommodityPage = GoRouterModel(
      key: 'buyCommodityPage/:bid',
      builder: (context, state) {
        return BuyCommodityPage(
          id: int.parse(state.pathParameters['bid']!),
        );
      });

  //商品分类
  static GoRouterModel commodityCategories = GoRouterModel(
      key: 'commodityCategories/:cid',
      builder: (context, state) {
        return CommodityCategories(
          id: int.parse(state.pathParameters['cid']!),
        );
      });
//商家中心
  static GoRouterModel merchantHome = GoRouterModel(
      key: 'merchantHome/:muid',
      builder: (context, state) {
        return MerchantHome(
          uuid: state.pathParameters['muid'],
        );
      });
//用户商城订单
  static GoRouterModel userMallOrder = GoRouterModel(
      key: 'userMallOrder',
      builder: (context, state) {
        return MineUserMallOrderPage();
      });
  //用户商城订单
  static GoRouterModel mallComplaint = GoRouterModel(
      key: 'mallComplaint/:mid',
      builder: (context, state) {
        return MallComplaint(
          id: int.parse(state.pathParameters['mid']!),
        );
      });
  //用户商城评价
  static GoRouterModel commodityEvaluate = GoRouterModel(
      key: 'commodityEvaluate/:cid',
      builder: (context, state) {
        return CommodityEvaluate(
          id: int.parse(state.pathParameters['cid']!),
        );
      });
  //商城发布
  static GoRouterModel mallPublish = GoRouterModel(
      key: 'mallPublish',
      builder: (context, state) {
        return MallPublish();
      });
//发帖规则
  static GoRouterModel publishRule = GoRouterModel(
      key: 'publishRule',
      builder: (context, state) {
        return PublishRule();
      });
//茶老板填写联系方式
  static GoRouterModel chabossconnect = GoRouterModel(
      key: 'chabossconnect',
      builder: (context, state) {
        return BossConnect();
      });

//裸聊首页
  static GoRouterModel nakedChat = GoRouterModel(
      key: 'nakedChat',
      builder: (context, state) {
        return NakedChatPage();
      });
//裸聊详情
  static GoRouterModel nakedchatDetail = GoRouterModel(
      key: 'nakedchatDetail/:nid',
      builder: (context, state) {
        return NakedchatDetail(
          id: int.parse(state.pathParameters['nid']!),
        );
      });
//裸聊支付
  static GoRouterModel nakedChatpay = GoRouterModel(
      key: 'nakedChatpay',
      builder: (context, state) {
        return NakedChatPay(
          data: state.extra as Map,
        );
      });

//裸聊支付成功
  static GoRouterModel nakedChatSuccess = GoRouterModel(
      key: 'nakedChatSuccess',
      builder: (context, state) {
        return NakedChatSuccess(data: state.extra as Map);
      });
//裸聊管理
  static GoRouterModel naledChatManage = GoRouterModel(
      key: 'naledChatManage',
      builder: (context, state) {
        return NaledChatManage();
      });
//裸聊发布
  static GoRouterModel nakechatPublish = GoRouterModel(
      key: 'nakechatPublish',
      builder: (context, state) {
        return NakechatPublish();
      });

//裸聊评价
  static GoRouterModel nackdChatMark = GoRouterModel(
      key: 'nackdChatMark',
      builder: (context, state) {
        return NackdChatMark(
          data: state.extra as Map,
        );
      });

//裸聊投诉
  static GoRouterModel nakedchatComplain = GoRouterModel(
      key: 'nakedchatComplain',
      builder: (context, state) {
        return NakedchatComplain(
          data: state.extra,
        );
      });

  //视频发布
  static GoRouterModel videoPublish = GoRouterModel(
      key: 'videoPublish',
      builder: (context, state) {
        return VideoPublish();
      });

  //创作中心
  static GoRouterModel videoWork = GoRouterModel(
      key: 'videoWork',
      builder: (context, state) {
        return MineVideoWorkPage();
      });

  //创作中心
  static GoRouterModel upAUth = GoRouterModel(
      key: 'upAUth',
      builder: (context, state) {
        return UpAuthPage();
      });

  // 雅间评价页面
  static GoRouterModel vipComment = GoRouterModel(
      key: 'vipComment',
      builder: (context, state) {
        return VipCommentPage(
          info: state.extra as Map,
        );
      });

  // 雅间评价页面
  static GoRouterModel adoptComplainpage = GoRouterModel(
      key: 'adoptComplainpage',
      builder: (context, state) {
        return AdoptComplainpage(
          info: state.extra as Map,
        );
      });

  // 雅间评价页面
  static GoRouterModel teablackDetailPage = GoRouterModel(
      key: 'teablackDetailPage/:id',
      builder: (context, state) {
        return TeablackDetailPage(
          id: state.pathParameters['id'] ?? '',
        );
      });

  // 黑榜评价页面
  static GoRouterModel teablankCommentPage = GoRouterModel(
      key: 'teablankCommentPage',
      builder: (context, state) {
        return TeablankCommentPage(
          info: state.extra as Map,
        );
      });

  static GoRouter init() {
    List<GoRoute> pages = [
      teaViewPicPage.toGoRouter(),
      adoptViewPicPage.toGoRouter(),
      shareQRCodePage.toGoRouter(),
      tealist.toGoRouter(),
      activityPage.toGoRouter(),
      applicationCenter.toGoRouter(),
      exchangeMember.toGoRouter(),
      exchangeCoupon.toGoRouter(),
      talkListPage.toGoRouter(),
      authenticationList.toGoRouter(),
      payoutList.toGoRouter(),
      tackDetailPage.toGoRouter(),
      browser.toGoRouter(),
      reportPage.toGoRouter(),
      teaAppreciator.toGoRouter(),
      teaBlackList.toGoRouter(),
      teaBlackPublish.toGoRouter(),
      waittingStatusPage.toGoRouter(),
      toBeVerifiedPage.toGoRouter(),
      loginPage.toGoRouter(),
      forgetPassword.toGoRouter(),
      setting.toGoRouter(),
      changePhone.toGoRouter(),
      memberCardsPage.toGoRouter(),
      bindphone.toGoRouter(),
      tianZiYiHaoPage.toGoRouter(),
      rechargeRecord.toGoRouter(),
      onlineServicePage.toGoRouter(),
      adoptManageScreen.toGoRouter(),
      officeMessage.toGoRouter(),
      pingChaBaoPage.toGoRouter(),
      ingotWallet.toGoRouter(),
      withdrawPage.toGoRouter(),
      withdrawRecordPage.toGoRouter(),
      withdrawAccountPage.toGoRouter(),
      ingotsDetailPage.toGoRouter(),
      popularize.toGoRouter(),
      promotionRecordPage.toGoRouter(),
      gamePage.toGoRouter(),
      rechargePage.toGoRouter(),
      recordingPage.toGoRouter(),
      gameWebView.toGoRouter(),
      youhuiquanCard.toGoRouter(),
      myTeaPost.toGoRouter(),
      resourcesDetailPage.toGoRouter(),
      adoptDetailPage.toGoRouter(),
      verificationReportPage.toGoRouter(),
      teaTastingIntention.toGoRouter(),
      vipDetailPage.toGoRouter(),
      huakuiGelou.toGoRouter(),
      webview.toGoRouter(),
      tanhuaPage.toGoRouter(),
      tanhuaListPage.toGoRouter(),
      tanhuaDetailPage.toGoRouter(),
      oneYuanSpring.toGoRouter(),
      winningRecord.toGoRouter(),
      selfWinningRecord.toGoRouter(),
      authBeautyPage.toGoRouter(),
      reservationPage.toGoRouter(),
      elegantCollect.toGoRouter(),
      myMonyPage.toGoRouter(),
      monyDtailPage.toGoRouter(),
      searchResult.toGoRouter(),
      searchSuggestionList.toGoRouter(),
      employmentIntroduce.toGoRouter(),
      chaGirlConfirmPage.toGoRouter(),
      workbenchPage.toGoRouter(),
      elegantPublishPage.toGoRouter(),
      waitingaudit.toGoRouter(),
      publishPage.toGoRouter(),
      faTieCiShuShuoMingPage.toGoRouter(),
      resourcesCertification.toGoRouter(),
      xiaoerOser.toGoRouter(),
      chaGirlBaseInformation.toGoRouter(),
      chagirlReview.toGoRouter(),
      girlWorkbenchPage.toGoRouter(),
      yuyuesuccess.toGoRouter(),
      gilrDrtailPage.toGoRouter(),
      reportDetailPage.toGoRouter(),
      brokerHomepage.toGoRouter(),
      systemNoticePage.toGoRouter(),
      unlockPage.toGoRouter(),
      llchat.toGoRouter(),
      intentionDetailPage.toGoRouter(),
      shareMeiziPage.toGoRouter(),
      home.toGoRouter(),
      shareMethodPage.toGoRouter(),
      publishGuide.toGoRouter(),
      gameWithdrawPage.toGoRouter(),
      gameRecordingPage.toGoRouter(),
      gameRechargePage.toGoRouter(),
      changePassword.toGoRouter(),
      postReviewPage.toGoRouter(),
      cgmallPage.toGoRouter(),
      cgRankPage.toGoRouter(),
      adoptPage.toGoRouter(),
      merchantCenter.toGoRouter(),
      commodityDetail.toGoRouter(),
      buyCommodityPage.toGoRouter(),
      commodityCategories.toGoRouter(),
      merchantHome.toGoRouter(),
      userMallOrder.toGoRouter(),
      mallComplaint.toGoRouter(),
      commodityEvaluate.toGoRouter(),
      mallPublish.toGoRouter(),
      publishRule.toGoRouter(),
      chabossconnect.toGoRouter(),
      nakedChat.toGoRouter(),
      nakedchatDetail.toGoRouter(),
      nakedChatpay.toGoRouter(),
      nakedChatSuccess.toGoRouter(),
      naledChatManage.toGoRouter(),
      nakechatPublish.toGoRouter(),
      nackdChatMark.toGoRouter(),
      nakedchatComplain.toGoRouter(),
      videoPublish.toGoRouter(),
      videoWork.toGoRouter(),
      adoptReleasePage.toGoRouter(),
      upAUth.toGoRouter(),
      vipComment.toGoRouter(),
      adoptComplainpage.toGoRouter(),
      teablackDetailPage.toGoRouter(),
      teablankCommentPage.toGoRouter()
    ];
    return GoRouter(
      errorBuilder: (context, state) => ErrorScreen(path: state.uri.toString()),
      debugLogDiagnostics: true,
      initialLocation: "/",
      routerNeglect: true,
      routes: [GoRoute(path: '/', builder: (context, state) => WelComePage(), routes: pages)],
      observers: [BotToastNavigatorObserver(), MyNavObserver()],
    );
  }
}

changeRouter() {
  GoRouter(
      routerNeglect: true,
      routes: [GoRoute(path: '/', builder: (context, state) => WelComePage(), routes: [])],
      observers: [BotToastNavigatorObserver(), MyNavObserver()]);
}

class MyNavObserver extends NavigatorObserver {
  MyNavObserver() {
    //
  }

  @override
  void didPush(Route<dynamic>? route, Route<dynamic>? previousRoute) {
    changeRouter();
    CommonUtils.debugPrint('didPush: 当前路由=${route?.settings.name}, previousRoute= ${previousRoute?.settings.name}');
  }

  @override
  void didPop(Route<dynamic>? route, Route<dynamic>? previousRoute) {
    CommonUtils.debugPrint(
        'didPop: ${route?.str} result: ${route?.settings.name}, 当前路由= ${previousRoute?.settings.name}');
  }

  @override
  void didRemove(Route<dynamic>? route, Route<dynamic>? previousRoute) =>
      CommonUtils.debugPrint('didRemove: ${route!.str}, previousRoute= ${previousRoute!.str}');

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) =>
      CommonUtils.debugPrint('didReplace: new= ${newRoute!.str}, old= ${oldRoute!.str}');

  @override
  void didStartUserGesture(
    Route<dynamic>? route,
    Route<dynamic>? previousRoute,
  ) =>
      CommonUtils.debugPrint('didStartUserGesture: ${route!.str}, '
          'previousRoute= ${previousRoute!.str}');

  @override
  void didStopUserGesture() => CommonUtils.debugPrint('didStopUserGesture');
}

extension on Route<dynamic> {
  String get str => 'route(${settings.name}: ${settings.arguments})';
}
