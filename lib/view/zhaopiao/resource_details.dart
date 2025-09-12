import 'dart:async';
import 'package:bot_toast/bot_toast.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:chaguaner2023/components/appBar/PullRreshAppBar.dart';
import 'package:chaguaner2023/components/avatar_widget.dart';
import 'package:chaguaner2023/components/cgDialog.dart';
import 'package:chaguaner2023/components/citypickers/modal/result.dart';
import 'package:chaguaner2023/components/citypickers/src/city_picker.dart';
import 'package:chaguaner2023/components/citypickers/src/utils/index.dart';
import 'package:chaguaner2023/components/detail_ad.dart';
import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/loading.dart';
import 'package:chaguaner2023/components/networkErr.dart';
import 'package:chaguaner2023/components/nodata.dart';
import 'package:chaguaner2023/components/page_title_bar.dart';
import 'package:chaguaner2023/components/starrating.dart';
import 'package:chaguaner2023/components/tab/v3_tab.dart';
import 'package:chaguaner2023/components/yy_dialog.dart';
import 'package:chaguaner2023/input/InputDailog.dart';
import 'package:chaguaner2023/store/global.dart';
import 'package:chaguaner2023/store/homeConfig.dart';
import 'package:chaguaner2023/store/sharedPreferences.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/cgprivilege.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/index.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:chaguaner2023/utils/log_utils.dart';
import 'package:chaguaner2023/utils/netimage_tool.dart';
import 'package:chaguaner2023/utils/sp_keys.dart';
import 'package:chaguaner2023/utils/yy_toast.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh_notification/pull_to_refresh_notification.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utils/cache/image_net_tool.dart';

class ResourcesDetailPage extends StatefulWidget {
  final String id;
  final int? type;
  final bool isBrokerhome;
  final String? buyId;
  final bool isComplaint;

  ResourcesDetailPage(
      {Key? key,
      required this.id,
      this.type = 1,
      this.isBrokerhome = false,
      this.buyId,
      this.isComplaint = true})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => ResourcesDetailState();
}

class ResourcesDetailState extends State<ResourcesDetailPage>
    with TickerProviderStateMixin {
  ScrollController? _scrollViewController;
  TabController? _tabController;
  TabController? _infoController;
  AnimationController? _lottieController;
  // ignore: unused_field
  int _selectedTabIndex = 0;

  // userBuy 0未购买1已购买2已验证
  // favorite 0未收藏1收藏
  bool isFavorite = false;
  dynamic money; //元宝
  bool isCoin = false;
  bool loading = true;
  DateTime? userCreateTime;
  Map? verifyDetail;
  List<Map> imgList = [];
  int truePage = 1;
  bool networkErr = false;
  int? coins;
  bool trueIsAll = false;
  bool trueIsLoading = false;
  int falsePage = 1;
  bool falseIsAll = false;
  bool falseIsLoading = false;
  bool isShow = false;
  double xOffset = 0;
  double yOffset = 0;
  double scaleFactor = 1;
  bool isTransparent = true;
  Map? adData; // 广告数据
  bool isSelf = false; //是否是自己的帖子
  dynamic _avg;
  int limit = 10;
  Map<int, String> servicesStatus = {1: '楼凤兼职', 2: '洗浴桑拿', 3: '路边小店'};
  Map<int, String> fakeStatus = {2: "信息虚假", 3: "骗子", 5: "其它"};
  List infoTab = [
    {
      'title': '基本信息',
    },
    {
      'title': '详情描述',
    },
    {
      'title': '发帖人评分',
    }
  ];
  int userBuyState = 0; //0 正常 1 铜钱解锁使用元宝解锁余额不足时
  GlobalKey _infoGlobalKey = GlobalKey();
  GlobalKey _descGlobalKey = GlobalKey();
  GlobalKey _startGlobalKey = GlobalKey();
  GlobalKey _cardGlobalKey = GlobalKey();
  List<double> widgetHeight = [1000, 1000, 1000];
  bool falseSwich = true;
  bool trueSwich = true;
  int _infoTabIndex = 0;
  double cardHeight = 300;
  String beforeText = '';
  _payment() async {
    Map? result = await buyResources(widget.id, isCoin ? 1 : 0);
    if (result!['status'] != 0) {
      BotToast.showText(text: '茶帖解锁成功～', align: Alignment(0, 0));
      Navigator.pop(context);
      getProfilePage().then((val) {
        if (val!['status'] != 0) {
          Provider.of<HomeConfig>(context, listen: false)
              .setCoins(val['data']['coin']);
          Provider.of<HomeConfig>(context, listen: false)
              .setMoney(val['data']['money']);
        }
      });
      _getInfo();
    } else {
      BotToast.showText(text: result['msg'], align: Alignment(0, 0));
    }
  }

  // ignore: unused_element
  _city(String code) {
    CityPickerUtil cityPickerUtils = CityPickers.utils();
    Result result = new Result();
    result = cityPickerUtils.getAreaResultByCode(code);
    if (result.provinceName != null) {
      return result.provinceName;
    } else {
      return '地址有误';
    }
  }

  int? id;
  List? _introductionList;
  List? _cardInfo;
  List _startInfo = [];

  //获取茶帖详情
  _getInfo() async {
    networkErr = false;
    setState(() {});
    Map? _info;
    if (widget.type == 2) {
      _info = await checkerGetInfoDetail(widget.id);
    } else {
      _info = await getResourcesInfo(widget.id);
    }
    LogUtilS.d('资源:$_info');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? firstDetailState = prefs.getString('${SpKeys.firstDetail}');
    if (["", null, false].contains(firstDetailState)) {
      xOffset = -1.sw * 0.5 + 15.w;
      yOffset = -1.sh * 0.4;
      scaleFactor = 2;
      isTransparent = false;
      setState(() {});
      _showPoint(firstDetailState);
    }
    if (_info!['data'] == null) {
      String teaError = "茶帖状态错误～";
      BotToast.showText(
          text: _info['msg'] == null || _info['msg'] == ''
              ? teaError
              : _info['msg'],
          align: Alignment(0, 0));
      Navigator.of(context).pop();
      return;
    }

    if (_info['status'] != 0) {
      verifyDetail = _info['data'];
      String? uid = Provider.of<HomeConfig>(context, listen: false).member.aff;
      isSelf = verifyDetail!['uid'].toString() == uid;
      var dataTimes = DateTime.fromMillisecondsSinceEpoch(
          int.parse(verifyDetail!['created_at'].toString()) * 1000);
      beforeText = RelativeDateFormat.format(dataTimes);
      isFavorite = _info['data']['favorite'] == 1;
      userCreateTime = verifyDetail!['user_created_time'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(
              verifyDetail!['user_created_time'] * 1000);
      _startInfo = [
        {
          'icon': 'assets/images/detail/icon-facevalue.png',
          'title': '妹子颜值',
          'type': true,
          'star': verifyDetail!['girl_face'].toDouble()
        },
        {
          'icon': 'assets/images/detail/icon-quality.png',
          'title': '服务质量',
          'type': true,
          'star': verifyDetail!['girl_service'].toDouble()
        },
        {
          'icon': 'assets/images/detail/icon-surroundings.png',
          'title': '环境设备',
          'type': true,
          'last': true, //最后一条
          'star': verifyDetail!['env'].toDouble()
        },
      ];
      dynamic coinNum = verifyDetail!['coin'] / 10;
      String _texta = '已隐藏，需要' + coinNum.toString() + '元宝解锁';
      _cardInfo = [
        {
          'icon': 'assets/images/detail/icon-postion.png',
          'title': '详细地址',
          'copy': true,
          'type':
              verifyDetail!['userBuy'] != 0 || verifyDetail!['address'] != null,
          'introduction': verifyDetail!['userBuy'] == 0
              ? (verifyDetail!['address'] != null
                  ? verifyDetail!['address']
                  : (verifyDetail!['authentication'] ||
                          verifyDetail!['is_money'] == 1
                      ? _texta
                      : '已隐藏，需要' + verifyDetail!['coin'].toString() + '铜钱解锁'))
              : verifyDetail!['address']
        },
        {
          'icon': 'assets/images/detail/icon-phone.png',
          'title': '联系方式',
          'copy': true,
          'type': (verifyDetail!['userBuy'] != 0 && widget.type == 1) ||
              verifyDetail!['phone'] != null,
          'introduction': widget.type == 2
              ? '审核中，不可查看'
              : (verifyDetail!['userBuy'] == 0
                  ? (verifyDetail!['phone'] != null
                      ? verifyDetail!['phone']
                      : (verifyDetail!['authentication'] ||
                              verifyDetail!['is_money'] == 1
                          ? _texta
                          : '已隐藏，需要' +
                              verifyDetail!['coin'].toString() +
                              '铜钱解锁'))
                  : verifyDetail!['phone'])
        },
        {
          'icon': 'assets/images/detail/icon-phone.png',
          'title': '备用联系方式',
          'copy': true,
          'type': (verifyDetail!['userBuy'] != 0 && widget.type == 1) ||
              verifyDetail!['contact_info'] != null,
          'introduction': widget.type == 2
              ? '审核中，不可查看'
              : (verifyDetail!['userBuy'] == 0
                  ? (verifyDetail!['contact_info'] != null
                      ? verifyDetail!['contact_info']
                      : (verifyDetail!['authentication'] ||
                              verifyDetail!['is_money'] == 1
                          ? _texta
                          : '已隐藏，需要' +
                              verifyDetail!['coin'].toString() +
                              '铜钱解锁'))
                  : (verifyDetail!['contact_info']))
        }
      ];
      _introductionList = [
        {
          'icon': 'assets/images/detail/icon-num.png',
          'title': '妹子数量',
          'type': true,
          'introduction': verifyDetail!['girl_num'] == null
              ? '--'
              : verifyDetail!['girl_num'].toString()
        },
        {
          'icon': 'assets/images/detail/icon-age.png',
          'title': '妹子年龄',
          'type': true,
          'introduction': verifyDetail!['girl_age'].toString()
        },
        {
          'icon': 'assets/images/detail/icon-type.png',
          'title': '服务项目',
          'type': true,
          'introduction': verifyDetail!['girl_service_type']
        },
        {
          'icon': 'assets/images/detail/icon-time.png',
          'title': '服务时间',
          'type': true,
          'introduction': verifyDetail!['business_hours']
        },
        {
          'icon': 'assets/images/detail/icon-money.png',
          'title': '最低价格',
          'type': true,
          'introduction': verifyDetail!['price'] == 0
              ? '--'
              : verifyDetail!['price'].toString()
        },
        {
          'icon': 'assets/images/detail/icon-project.png',
          'title': '消费情况',
          'type': true,
          'last': true, //最后一条
          'introduction': verifyDetail!['fee']
        }
      ];
    } else {
      setState(() {
        networkErr = true;
      });
      return;
    }
    if (widget.type == 1) {
      _getConfirmList();
    } else {
      loading = false;
    }
    getBuyText();
    setState(() {});
  }

  // 防骗指南动画
  _showPoint(dynamic firstDetailState) async {
    Future.delayed(Duration(seconds: 5)).then((value) {
      setState(() {
        xOffset = 0;
        yOffset = 0;
        scaleFactor = 1;
        isTransparent = true;
      });
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('${SpKeys.firstDetail}', 'OK');
  }

  _verify() {
    var agent =
        Provider.of<GlobalState>(context, listen: false).profileData?['agent'];
    AppGlobal.appRouter?.push(CommonUtils.getRealHash(
        'verificationReportPage/' +
            widget.id.toString() +
            '/' +
            agent.toString() +
            '/9/null'));
  }

  //收藏
  _collect() async {
    String collectStr = '收藏成功';
    String cancleColStr = '取消收藏成功';
    isFavorite = !isFavorite;
    setState(() {});
    Map favorite = await collectResources(widget.id);
    if (favorite['status'] != 0) {
      BotToast.showText(
          text: isFavorite ? collectStr : cancleColStr, align: Alignment(0, 0));
      verifyDetail!['favorite'] = isFavorite ? 1 : 0;
      isFavorite = verifyDetail!['favorite'] == 1;
      setState(() {});
    } else {
      isFavorite = verifyDetail!['favorite'] == 1;
      setState(() {});
      if (favorite['msg'] == 'err') {
        CgDialog.cgShowDialog(
            context, '温馨提示', '免费收藏已达上限，请前往开通会员', ['取消', '立即前往'], callBack: () {
          AppGlobal.appRouter?.push(CommonUtils.getRealHash('memberCardsPage'));
        });
      } else {
        CommonUtils.showText(favorite['msg']);
      }
    }
  }

  List _evaluationTrue = [];

//真实信息列表
  _getConfirmList() async {
    await getConfirmList(widget.id, truePage, limit).then((confirmList) {
      if (truePage == 1) {
        if (confirmList!['status'] != 0) {
          loading = false;
          trueSwich = true;
          _avg = confirmList['data']['avg'];
          _evaluationTrue = confirmList['data']['list'];
          trueIsLoading = false;
        } else {
          BotToast.showText(text: confirmList['msg'], align: Alignment(0, 0));
        }
        if (confirmList['data']['list'].length < limit) {
          trueIsLoading = false;
          trueIsAll = true;
        }
        setState(() {});
      } else {
        if (confirmList!['status'] != 0 &&
            confirmList['data']['list'].length > 0) {
          trueSwich = true;
          _evaluationTrue.addAll(confirmList['data']['list']);
        } else {
          trueIsLoading = false;
          trueIsAll = true;
        }
        setState(() {});
      }
      ;
    });
  }

  _getHeight(_) {
    if (_cardGlobalKey.currentContext != null &&
        cardHeight != _cardGlobalKey.currentContext!.size!.height) {
      setState(() {
        cardHeight = _cardGlobalKey.currentContext!.size!.height;
      });
    }
    if (_infoGlobalKey.currentContext != null && widgetHeight[0] == 1000) {
      //初始化一遍所有值
      widgetHeight[0] = _infoGlobalKey.currentContext!.size!.height;
      widgetHeight[1] = _infoGlobalKey.currentContext!.size!.height;
      widgetHeight[2] = _infoGlobalKey.currentContext!.size!.height;
      setState(() {});
    }
  }

  // 获取广告
  getAd() async {
    var data = await getDetail_ad(501);
    if (data != null) {
      this.setState(() {
        adData = data;
      });
    }
  }

  //回复评论
  replyItemComment(_id) {
    if (isSelf) {
      reqReply(_id);
      return;
    }
    if (CgPrivilege.getPrivilegeStatus(
        PrivilegeType.infoConfirm, PrivilegeType.privilegeComment)) {
      if (verifyDetail!['userBuy'] != 0) {
        reqReply(_id);
      } else {
        YyShowDialog.showdialog(context,
            title: '提示',
            btnText: '解锁茶帖',
            callBack: _payment, content: (setDialogState) {
          return Text(
            '解锁后可回复,是否解锁帖子?',
            style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 15.sp),
          );
        });
      }
    } else {
      return CommonUtils.showVipDialog(
          context, PrivilegeType.privilegeCommentString);
    }
  }

  reqReply(_id) {
    InputDialog.show(context, '回复评论', limitingText: 99, btnText: '发送',
        onSubmit: (value) {
      if (value != null) {
        replyComment(confirmId: _id, content: value).then((res) {
          if (res!['status'] != 0) {
            CommonUtils.showText(res['msg']);
          } else {
            CommonUtils.showText(res['msg']);
          }
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    EventBus().on('girlStatusChange', (arg) {
      if (arg['index'] == 9) {
        verifyDetail!['userBuy'] = 3;
      }
      if (arg['index'] == 9 && arg['isReport']) {
        verifyDetail!['userBuy'] = 2;
      }
      setState(() {});
    });
    PersistentState.getState('prompt').then((value) {
      isShow = (value == null);
      setState(() {});
    });
    Future.delayed(new Duration(seconds: 1), () {
      WidgetsBinding.instance.addPersistentFrameCallback(_getHeight);
    });
    _scrollViewController = ScrollController(initialScrollOffset: 0.0);
    _tabController = TabController(vsync: this, length: 1);
    _infoController = TabController(vsync: this, length: infoTab.length);
    _tabController!.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController!.index;
      });
    });
    _infoController?.addListener(() {
      setState(() {
        _infoTabIndex = _infoController!.index;
      });
      if (_descGlobalKey.currentContext != null &&
          widgetHeight[1] == widgetHeight[0]) {
        widgetHeight[1] = _descGlobalKey.currentContext!.size!.height;
      }
      if (_startGlobalKey.currentContext != null &&
          widgetHeight[2] == widgetHeight[0]) {
        // print(_startGlobalKey.currentContext.size.height);
        widgetHeight[2] = _startGlobalKey.currentContext!.size!.height;
      }
    });
    _lottieController = AnimationController(vsync: this);
    _getInfo();
    getAd();
  }

  @override
  void dispose() {
    _scrollViewController?.dispose();
    _tabController?.dispose();
    _infoController?.dispose();
    _lottieController?.dispose();
    EventBus().off('girlStatusChange');
    super.dispose();
  }

  _trueOnScrollNotification(ScrollNotification scrollInfo) {
    if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
      //滑到了底部
      if (trueSwich) {
        if (!trueIsAll) {
          setState(() {
            truePage++;
            trueIsLoading = true;
          });
          _getConfirmList();
        }
        setState(() {
          trueSwich = false;
        });
      }
    }
    return false;
  }

  bool _isShowConfirmPCBCount = false;

  @override
  Widget build(BuildContext context) {
    verifyDetail?['guaranty'] =
        verifyDetail?['guaranty'] == null ? 0 : verifyDetail?['guaranty'];
    return Consumer<HomeConfig>(
      builder: (_, value, __) {
        coins = value.member.coins;
        money = value.member.money;
        String jsStr = '解锁资源后才可以投诉该帖～';
        String iscolStr = 'assets/images/card/iscollect.png';
        String collectStrr = 'assets/images/mymony/collect.png';
        String delcStr = '删除该帖';
        String unlocksStr = '解锁茶帖';
        return Stack(
          fit: StackFit.expand,
          children: <Widget>[
            HeaderContainer(
              child: Scaffold(
                backgroundColor: Colors.transparent,
                appBar: PreferredSize(
                    child: PageTitleBar(
                      title: '茶帖详情',
                      rightWidget: verifyDetail == null
                          ? Container()
                          : (verifyDetail!['userBuy'] != 2 &&
                                  verifyDetail!['userBuy'] != 3 &&
                                  widget.isComplaint
                              ? GestureDetector(
                                  onTap: () {
                                    if (isShow) {
                                      PersistentState.saveState('prompt', '1');
                                      isShow = false;
                                      setState(() {});
                                    }
                                    if (verifyDetail!['userBuy'] == 1) {
                                      var agent = Provider.of<GlobalState>(
                                              context,
                                              listen: false)
                                          .profileData?['agent'];
                                      AppGlobal.appRouter?.push(
                                          CommonUtils.getRealHash(
                                              'verificationReportPage/' +
                                                  widget.id.toString() +
                                                  '/' +
                                                  agent.toString() +
                                                  '/9/true'));
                                    } else {
                                      CgDialog.cgShowDialog(context, '提示',
                                          '解锁资源后才可以投诉该帖～', ['知道了']);
                                    }
                                  },
                                  child: Center(
                                    child: Container(
                                      margin: new EdgeInsets.only(right: 15.w),
                                      child: Text(
                                        '投诉',
                                        style: TextStyle(
                                            color: StyleTheme.cDangerColor,
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ),
                                )
                              : Container()),
                    ),
                    preferredSize: Size(double.infinity, 44.w)),
                // 使用PullToRefreshNotification包裹列表
                body: networkErr //特殊布局所以需要单独判断
                    //网络错误判断
                    ? NetworkErr(
                        errorRetry: () {
                          _getInfo();
                        },
                      )
                    :
                    //Loding判断
                    (loading
                        ? Loading()
                        : Column(
                            children: <Widget>[
                              widget.type == 1
                                  ? Container(
                                      color: Color(0xFFFDF0E4),
                                      height: 30.w,
                                      child: new Marquee(
                                        text:
                                            "温馨提示：大厅茶帖的图片仅供参考，要求照片与本人差别不大的客人，请移步雅间，谢谢～",
                                        style: new TextStyle(
                                            color: Color(0xFFFF4149),
                                            fontSize: 12.sp),
                                        scrollAxis: Axis.horizontal,
                                      ),
                                    )
                                  : SizedBox(),
                              Expanded(
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: <Widget>[
                                    ExtendedNestedScrollView(
                                      controller: _scrollViewController,
                                      physics: ClampingScrollPhysics(),
                                      headerSliverBuilder:
                                          (BuildContext context,
                                              bool innerBoxIsScrolled) {
                                        return [
                                          SliverToBoxAdapter(
                                            child: Container(
                                              color: Colors.white,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  verifyDetail?['pic'] !=
                                                              null &&
                                                          verifyDetail?['pic']
                                                                  .length >
                                                              0
                                                      ? Container(
                                                          color:
                                                              Color(0xFFE5E5E5),
                                                          height: 240.w,
                                                          child: _swiper())
                                                      : Container(),
                                                  Stack(
                                                    children: <Widget>[
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: <Widget>[
                                                          _detailHeader(),
                                                          Container(
                                                            margin:
                                                                EdgeInsets.only(
                                                              top: (verifyDetail?['tran_flag'] ==
                                                                              1 ||
                                                                          verifyDetail?['guaranty'] >
                                                                              0
                                                                      ? 5
                                                                      : 0)
                                                                  .w,
                                                              bottom: 10.w,
                                                              left: 15.w,
                                                            ),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                verifyDetail?[
                                                                            'tran_flag'] ==
                                                                        1
                                                                    ? GestureDetector(
                                                                        onTap:
                                                                            () {
                                                                          CgDialog.cgShowDialog(
                                                                              context,
                                                                              '什么是品茶宝',
                                                                              '品茶宝是官方创建的安全、可靠的资金托管工具。支持品茶宝交易的茶帖，其他用户可支付元宝托管，确认服务完成后，资金才会到茶帖发布者的账户中，妈妈再也不用担心我被骗了！',
                                                                              [
                                                                                '知道了'
                                                                              ]);
                                                                        },
                                                                        child:
                                                                            LocalPNG(
                                                                          url:
                                                                              'assets/images/mine/v5/zcpcb.png',
                                                                          width:
                                                                              (55.5 * 1.2).w,
                                                                          height:
                                                                              (17.5 * 1.2).w,
                                                                        ),
                                                                      )
                                                                    : Container(),
                                                                SizedBox(
                                                                  width: 10.w,
                                                                ),
                                                                verifyDetail?[
                                                                            'guaranty'] ==
                                                                        0
                                                                    ? Container()
                                                                    : Row(
                                                                        mainAxisSize:
                                                                            MainAxisSize.min,
                                                                        children: [
                                                                          LocalPNG(
                                                                            url:
                                                                                'assets/images/detail/pei.png',
                                                                            width:
                                                                                (17.5 * 1.2).w,
                                                                            height:
                                                                                (17.5 * 1.2).w,
                                                                          ),
                                                                          Container(
                                                                              padding: EdgeInsets.symmetric(horizontal: 4.5.w),
                                                                              height: (11 * 1.2).w,
                                                                              decoration: BoxDecoration(
                                                                                  color: Color(0xff45c37d),
                                                                                  borderRadius: BorderRadius.only(
                                                                                    bottomRight: Radius.circular(10),
                                                                                    topRight: Radius.circular(10),
                                                                                  )),
                                                                              child: Center(
                                                                                child: Text(
                                                                                  '可赔付押金' + verifyDetail!['guaranty'].toString() + '元宝',
                                                                                  style: TextStyle(color: Colors.white, fontSize: 8.sp),
                                                                                ),
                                                                              ))
                                                                        ],
                                                                      )
                                                              ],
                                                            ),
                                                          ),
                                                          verifyDetail?['uid'] ==
                                                                      null ||
                                                                  verifyDetail?[
                                                                          'nickname'] ==
                                                                      null
                                                              ? Container()
                                                              : GestureDetector(
                                                                  onTap: () {
                                                                    if (widget
                                                                        .isBrokerhome)
                                                                      return;
                                                                    AppGlobal.appRouter?.push(CommonUtils.getRealHash('brokerHomepage/' +
                                                                        verifyDetail!['uid']
                                                                            .toString() +
                                                                        '/' +
                                                                        Uri.encodeComponent(verifyDetail!['thumb']
                                                                            .toString()) +
                                                                        '/' +
                                                                        verifyDetail!['nickname']
                                                                            .toString()));
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    child: Row(
                                                                      children: [
                                                                        Container(
                                                                          margin:
                                                                              EdgeInsets.only(right: 5.5.w),
                                                                          child:
                                                                              Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.center,
                                                                            mainAxisSize:
                                                                                MainAxisSize.min,
                                                                            children: [
                                                                              Container(
                                                                                margin: EdgeInsets.only(right: 5.5.w),
                                                                                width: 20.w,
                                                                                height: 20.w,
                                                                                child: Avatar(
                                                                                  type: verifyDetail?['thumb'],
                                                                                ),
                                                                              ),
                                                                              Container(
                                                                                  constraints: BoxConstraints(maxWidth: 100.w),
                                                                                  child: Text(
                                                                                    verifyDetail?['nickname'],
                                                                                    style: TextStyle(
                                                                                      color: Color(0xff5584e3),
                                                                                      fontSize: 12.sp,
                                                                                    ),
                                                                                    overflow: TextOverflow.ellipsis,
                                                                                    maxLines: 1,
                                                                                  )), // · 35帖
                                                                              Text('· ' + verifyDetail!['post_num'].toString() + '帖',
                                                                                  style: TextStyle(
                                                                                    color: Color(0xff5584e3),
                                                                                    fontSize: 12.sp,
                                                                                  ))
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        verifyDetail?['user_vip_level'] <=
                                                                                0
                                                                            ? SizedBox()
                                                                            : SizedBox(
                                                                                height: 15.w,
                                                                                child: ImageNetTool(
                                                                                  fit: BoxFit.fitHeight,
                                                                                  url: CommonUtils.getVipIcon(
                                                                                    verifyDetail?['user_vip_level'],
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                        verifyDetail?['user_created_time'] ==
                                                                                null
                                                                            ? Container()
                                                                            : Container(
                                                                                margin: EdgeInsets.only(right: 11.w, left: 11.w),
                                                                                child: Text(
                                                                                  userCreateTime == null ? '未知' : "注册于${userCreateTime?.year}/${userCreateTime?.month}/${userCreateTime?.day}",
                                                                                  style: TextStyle(color: StyleTheme.cBioColor, fontSize: 12.sp),
                                                                                ),
                                                                              ),
                                                                      ],
                                                                    ),
                                                                    margin: EdgeInsets.only(
                                                                        left: 15
                                                                            .w,
                                                                        bottom:
                                                                            10.w),
                                                                  ),
                                                                ),
                                                          Row(
                                                            children: [
                                                              widget.type == 1
                                                                  ? _timesFomat()
                                                                  : SizedBox(
                                                                      height:
                                                                          10),
                                                            ],
                                                          ),
                                                          adData != null
                                                              ? Padding(
                                                                  padding: EdgeInsets
                                                                      .symmetric(
                                                                          horizontal:
                                                                              10.w),
                                                                  child: Detail_ad(
                                                                      app_layout:
                                                                          true,
                                                                      data: adData?[
                                                                          "data"]),
                                                                )
                                                              : Container(),
                                                          newbieSee(),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  _detailCard(),
                                                  TabNavDian(
                                                      tabs: infoTab,
                                                      tabController:
                                                          _infoController,
                                                      selectedTabIndex:
                                                          _infoTabIndex),
                                                  Container(
                                                    height: widgetHeight[
                                                            _infoTabIndex] +
                                                        14.5.w * 2,
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 15.w),
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 14.5.w,
                                                            horizontal: 15.w),
                                                    decoration: BoxDecoration(
                                                        color:
                                                            Color(0xFFF8F8F8),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10)),
                                                    child: TabBarView(
                                                        controller:
                                                            _infoController,
                                                        children: [
                                                          Container(
                                                            child: ListView(
                                                              physics:
                                                                  ClampingScrollPhysics(),
                                                              children: <Widget>[
                                                                _dtailList()
                                                              ],
                                                            ),
                                                          ),
                                                          Container(
                                                              child: ListView(
                                                            physics:
                                                                ClampingScrollPhysics(),
                                                            children: <Widget>[
                                                              verifyDetail?[
                                                                          'desc'] ==
                                                                      ""
                                                                  ? Text(
                                                                      '茶帖没有描述哦～')
                                                                  : Container(
                                                                      key:
                                                                          _descGlobalKey,
                                                                      child:
                                                                          Text(
                                                                        verifyDetail?[
                                                                            'desc'],
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                14.sp,
                                                                            color: StyleTheme.cTitleColor),
                                                                      ),
                                                                    ),
                                                            ],
                                                          )),
                                                          Container(
                                                              child: ListView(
                                                            physics:
                                                                ClampingScrollPhysics(),
                                                            children: <Widget>[
                                                              Container(
                                                                key:
                                                                    _startGlobalKey,
                                                                child: Column(
                                                                  children: <Widget>[
                                                                    for (var item
                                                                        in _startInfo)
                                                                      _introductionItem(
                                                                          item[
                                                                              'icon'],
                                                                          item[
                                                                              'title'],
                                                                          item['introduction'] ??
                                                                              '--',
                                                                          item[
                                                                              'star'],
                                                                          item[
                                                                              'type'],
                                                                          item[
                                                                              'copy'],
                                                                          item['last'] == null
                                                                              ? false
                                                                              : item['last'])
                                                                  ],
                                                                ),
                                                              )
                                                            ],
                                                          ))
                                                        ]),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                          SliverToBoxAdapter(
                                            child: _totalScore(),
                                          )
                                        ];
                                      },
                                      body: TabBarView(
                                          controller: _tabController,
                                          children: [
                                            _evaluationTrue.length == 0
                                                ? ListView(
                                                    physics:
                                                        ClampingScrollPhysics(),
                                                    children: [
                                                      NoData(
                                                          text: '还没茶友有发布验茶报告哦～')
                                                    ],
                                                  )
                                                : NotificationListener<
                                                    ScrollNotification>(
                                                    onNotification:
                                                        (ScrollNotification
                                                            scrollInfo) {
                                                      return _trueOnScrollNotification(
                                                          scrollInfo);
                                                    },
                                                    child: ListView.separated(
                                                        physics:
                                                            ClampingScrollPhysics(),
                                                        itemCount:
                                                            _evaluationTrue
                                                                .length,
                                                        separatorBuilder:
                                                            (BuildContext
                                                                    context,
                                                                int index) {
                                                          return Divider(
                                                            color: Colors
                                                                .transparent,
                                                            height: 15.w,
                                                          );
                                                        },
                                                        itemBuilder:
                                                            (BuildContext
                                                                    context,
                                                                int index) {
                                                          return Column(
                                                            children: [
                                                              _scoreCard(
                                                                  _evaluationTrue[
                                                                      index]),
                                                              index ==
                                                                      _evaluationTrue
                                                                              .length -
                                                                          1
                                                                  ? renderMore(
                                                                      trueIsLoading)
                                                                  : Container()
                                                            ],
                                                          );
                                                        }),
                                                  ),
                                          ]),
                                    ),
                                    Positioned(
                                        bottom:
                                            (verifyDetail?['userBuy'] != 0 &&
                                                        verifyDetail?[
                                                                'tran_flag'] ==
                                                            1
                                                    ? 100
                                                    : 15)
                                                .w,
                                        right: 15.w,
                                        child: GuideWidget(
                                            isTransparent: isTransparent,
                                            xOffset: xOffset,
                                            yOffset: yOffset,
                                            scaleFactor: scaleFactor)),
                                    verifyDetail?['userBuy'] == 0
                                        ? Container()
                                        : Positioned(
                                            bottom: 15.w,
                                            right: 15.w,
                                            child:
                                                verifyDetail!['tran_flag'] != 1
                                                    ? Container()
                                                    : GestureDetector(
                                                        child: LocalPNG(
                                                          url:
                                                              'assets/images/mine/v5/pcbtg.png',
                                                          width: 65.w,
                                                          height: 57.w,
                                                        ),
                                                        onTap:
                                                            _onShowConfirmPCBCount,
                                                      ))
                                  ],
                                ),
                              ),
                              widget.type != 1 ||
                                      (verifyDetail!['userBuy'] == 0 &&
                                          verifyDetail!['address'] != null)
                                  ? SizedBox()
                                  : Container(
                                      height: 49.w +
                                          (verifyDetail!['status'] == 4
                                              ? 30
                                              : 0) +
                                          ScreenUtil().bottomBarHeight,
                                      padding: new EdgeInsets.only(
                                          bottom: ScreenUtil().bottomBarHeight,
                                          left: 15.w,
                                          right: 15.w),
                                      color: StyleTheme.bottomappbarColor,
                                      width: double.infinity,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              GestureDetector(
                                                  onTap: () {
                                                    _collect();
                                                  },
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Container(
                                                        margin:
                                                            new EdgeInsets.only(
                                                                right: 10.w),
                                                        child: LocalPNG(
                                                          url: isFavorite
                                                              ? iscolStr
                                                              : collectStrr,
                                                          width: 25.w,
                                                          height: 25.w,
                                                        ),
                                                      ),
                                                      Text('收藏')
                                                    ],
                                                  )),
                                              GestureDetector(
                                                onTap: () {
                                                  AppGlobal.appRouter?.push(
                                                      CommonUtils.getRealHash(
                                                          'shareQRCodePage'));
                                                }, //_showModalBottomSheet,
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Container(
                                                      margin:
                                                          new EdgeInsets.only(
                                                              left: 20.w,
                                                              right: 10.w),
                                                      child: LocalPNG(
                                                        url:
                                                            'assets/images/detail/share-icon.png',
                                                        width: 25.w,
                                                        height: 25.w,
                                                      ),
                                                    ),
                                                    Text('分享')
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                          Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              verifyDetail?['status'] == 4
                                                  ? Text(
                                                      '该帖已被平台下架',
                                                      style: TextStyle(
                                                          color: StyleTheme
                                                              .cDangerColor,
                                                          fontSize: 12.sp),
                                                    )
                                                  : Container(),
                                              GestureDetector(
                                                onTap: () {
                                                  if (verifyDetail?['status'] ==
                                                      4) {
                                                    CgDialog.cgShowDialog(
                                                        context,
                                                        '提示',
                                                        '确定从解锁列表中删除该帖吗?',
                                                        ['取消', '确定'],
                                                        callBack: () {
                                                      Navigator.of(context)
                                                          .pop('delete');
                                                      BotToast.showText(
                                                          text:
                                                              '已成功从您的解锁列表中移除～',
                                                          align:
                                                              Alignment(0, 0));
                                                    });
                                                  } else {
                                                    if (verifyDetail?[
                                                            'userBuy'] ==
                                                        0) {
                                                      showPublish();
                                                    } else if (verifyDetail?[
                                                            'userBuy'] ==
                                                        1) {
                                                      _verify();
                                                    }
                                                  }
                                                },
                                                child: SizedBox(
                                                    width: 175.w,
                                                    height: 40.w,
                                                    child: Stack(
                                                      children: [
                                                        LocalPNG(
                                                          url: getState(verifyDetail![
                                                                      'status'] ==
                                                                  4
                                                              ? 0
                                                              : verifyDetail![
                                                                  'userBuy']),
                                                          width: 175.w,
                                                          height: 40.w,
                                                          fit: BoxFit.fitHeight,
                                                        ),
                                                        Center(
                                                          child: Text(
                                                            verifyDetail![
                                                                        'status'] ==
                                                                    4
                                                                ? delcStr
                                                                : (verifyDetail![
                                                                            'userBuy'] ==
                                                                        0
                                                                    ? unlocksStr
                                                                    : verifyDetail!['userBuy'] ==
                                                                            3
                                                                        ? '验证审核中'
                                                                        : ''),
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 14.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                          ),
                                                        ),
                                                      ],
                                                    )),
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    )
                            ],
                          )),
              ),
            ),
            _isShowConfirmPCBCount ? confirmPCBCount() : Container(),
            verifyDetail?['userBuy'] != 2 &&
                    verifyDetail?['userBuy'] != 3 &&
                    widget.isComplaint
                ? Positioned(
                    top: 45.w + ScreenUtil().statusBarHeight + -5.w,
                    right: 5.w,
                    child: isShow
                        ? LocalPNG(
                            width: 130.w,
                            height: 59.w,
                            url: 'assets/images/detail/prompt.png',
                            fit: BoxFit.cover)
                        : Container())
                : Container()
          ],
        );
      },
    );
  }

  bool showExchange() {
    if (UserInfo.vipLevel! <= 0 && verifyDetail!['max_coin_rate'] == 1) {
      return false;
    } else {
      var exchange_ratio = Provider.of<HomeConfig>(context, listen: false)
              .data['exchange_ratio'] ??
          100;
      bool aba =
          (coins! <= (verifyDetail!['maxDeduction'] / 10) * exchange_ratio);
      return verifyDetail!['maxDeduction'] == null ||
          verifyDetail!['maxDeduction'] == 0 ||
          verifyDetail!['freeMoneyNum'] > 0 ||
          aba ||
          (money * 10 + (aba ? 0 : verifyDetail!['maxDeduction'])) <
              verifyDetail!['coin'];
    }
  }

  Future showPublish() {
    var exchange_ratio = Provider.of<HomeConfig>(context, listen: false)
            .data['exchange_ratio'] ??
        100;
    var moneys = Provider.of<HomeConfig>(context, listen: false).member.money;
    // print('0000000');
    // print(exchange_ratio);
    String yuanbaoStr = 'yuanbao';
    String toqStr = 'tongqian';
    String selectStr = 'select';
    String noselkjsd = 'unselect';
    String yuanbAsseStr =
        verifyDetail!['authentication'] || verifyDetail!['is_money'] == 1
            ? yuanbaoStr
            : toqStr;
    dynamic coinnss =
        verifyDetail!['authentication'] || verifyDetail!['is_money'] == 1
            ? verifyDetail!['coin'] / 10
            : verifyDetail!['coin'];
    String ybStr = '元宝';
    dynamic priceDe = verifyDetail!['discountPrice'] / 10;
    String yebzStr = '余额不足，请充值后再来解锁吧～';
    String tqbzStr = '您的铜钱不足，本次将元宝解锁哦～';
    dynamic maxDeduc = verifyDetail!['maxDeduction'] / 10;
    dynamic ratioEx = maxDeduc * exchange_ratio;
    return showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, sottomSheetSetState) {
            return Container(
              color: Colors.transparent,
              child: Container(
                height: 500.w + ScreenUtil().bottomBarHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Container(
                        padding:
                            EdgeInsets.only(top: 20.w, left: 15.w, right: 15.w),
                        child: Column(children: [
                          Container(
                            child: Center(
                              child: Text(
                                '茶帖解锁',
                                style: TextStyle(
                                    color: StyleTheme.cTitleColor,
                                    fontSize: 18.sp),
                              ),
                            ),
                          ),
                          Container(
                              margin: EdgeInsets.only(
                                top: 40.w,
                              ),
                              child: Center(
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(
                                            right: 8.w,
                                          ),
                                          width: (verifyDetail![
                                                          'authentication'] ||
                                                      verifyDetail![
                                                              'is_money'] ==
                                                          1
                                                  ? 36
                                                  : 28)
                                              .w,
                                          height: (verifyDetail![
                                                          'authentication'] ||
                                                      verifyDetail![
                                                              'is_money'] ==
                                                          1
                                                  ? 27
                                                  : 28)
                                              .w,
                                          child: LocalPNG(
                                              width: (verifyDetail![
                                                              'authentication'] ||
                                                          verifyDetail![
                                                                  'is_money'] ==
                                                              1
                                                      ? 36
                                                      : 28)
                                                  .w,
                                              height: (verifyDetail![
                                                              'authentication'] ||
                                                          verifyDetail![
                                                                  'is_money'] ==
                                                              1
                                                      ? 27
                                                      : 28)
                                                  .w,
                                              url:
                                                  'assets/images/detail/$yuanbAsseStr.png',
                                              fit: BoxFit.contain),
                                        ),
                                        Text.rich(
                                          TextSpan(
                                              text: '$coinnss',
                                              style: TextStyle(
                                                fontSize: 36.w,
                                                color: StyleTheme.cTitleColor,
                                                fontWeight: FontWeight.bold,
                                                decoration: ((verifyDetail![
                                                                'authentication'] ||
                                                            verifyDetail![
                                                                    'is_money'] ==
                                                                1)
                                                        ? verifyDetail![
                                                                'freeMoneyNum'] >
                                                            0
                                                        : verifyDetail![
                                                                'freeNum'] >
                                                            0)
                                                    ? TextDecoration.lineThrough
                                                    : null,
                                                decorationColor:
                                                    StyleTheme.cTitleColor,
                                              ),
                                              children: [
                                                TextSpan(
                                                  text: verifyDetail![
                                                              'authentication'] ||
                                                          verifyDetail![
                                                                  'is_money'] ==
                                                              1
                                                      ? ybStr
                                                      : '铜钱',
                                                  style: TextStyle(
                                                    fontSize: 18.sp,
                                                    color:
                                                        StyleTheme.cTitleColor,
                                                  ),
                                                )
                                              ]),
                                        ),
                                        ((verifyDetail!['authentication'] ||
                                                        verifyDetail![
                                                                'is_money'] ==
                                                            1)
                                                    ? verifyDetail![
                                                            'freeMoneyNum'] >
                                                        0
                                                    : verifyDetail!['freeNum'] >
                                                        0) ||
                                                !(verifyDetail![
                                                            'discountPrice'] !=
                                                        null &&
                                                    verifyDetail![
                                                            'discountPrice'] !=
                                                        0 &&
                                                    verifyDetail![
                                                            'discountPrice'] >
                                                        verifyDetail!['coin'])
                                            ? Container()
                                            : Container(
                                                margin: EdgeInsets.only(
                                                  left: 9.5.w,
                                                  // top: 10.w
                                                ),
                                                child: Text(
                                                  '$priceDe元宝',
                                                  style: TextStyle(
                                                      height: 2,
                                                      fontSize: 18.sp,
                                                      decorationColor:
                                                          Color(0xff969696),
                                                      decoration: TextDecoration
                                                          .lineThrough,
                                                      color: Color(0xff969696)),
                                                ),
                                              )
                                      ],
                                    ),
                                    ((verifyDetail!['authentication'] ||
                                                verifyDetail!['is_money'] == 1)
                                            ? verifyDetail!['freeMoneyNum'] > 0
                                            : verifyDetail!['freeNum'] > 0)
                                        ? Positioned(
                                            bottom: 5.w,
                                            right: -70.w,
                                            child: LocalPNG(
                                              width: 65.w,
                                              height: 20.w,
                                              url:
                                                  'assets/images/detail/mfjs.png',
                                              fit: BoxFit.contain,
                                            ))
                                        : Positioned(
                                            top: 0,
                                            left: 0,
                                            child: Container(),
                                          )
                                  ],
                                ),
                              )),
                          Center(
                            child: Text(
                              userBuyState == 1
                                  ? yebzStr
                                  : userBuyState == 2
                                      ? tqbzStr
                                      : '',
                              style: TextStyle(
                                  color: StyleTheme.cDangerColor,
                                  fontSize: 12.w),
                            ),
                          ),
                          ((verifyDetail!['authentication'] ||
                                      verifyDetail!['is_money'] == 1)
                                  ? verifyDetail!['freeMoneyNum'] == 0
                                  : verifyDetail!['freeNum'] == 0)
                              ? Container()
                              : BottomLine(),
                          // ((verifyDetail!['authentication'] ||
                          //             verifyDetail!['is_money'] == 1)
                          //         ? verifyDetail!['freeMoneyNum'] == 0
                          //         : verifyDetail!['freeNum'] == 0)
                          //     ? Container()
                          //     :
                          rowText(
                              '会员权益', getVipText(), StyleTheme.cDangerColor),
                          BottomLine(),
                          rowText('茶帖信息', verifyDetail!['title']),
                          showExchange() ? Container() : BottomLine(),
                          showExchange()
                              ? Container()
                              : GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: () {
                                    sottomSheetSetState(() {
                                      isCoin = !isCoin;
                                    });
                                  },
                                  child: rowText(
                                      '铜钱抵扣',
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text('使用$ratioEx铜钱抵扣$maxDeduc元宝'),
                                          SizedBox(
                                            width: 5.w,
                                          ),
                                          LocalPNG(
                                            url:
                                                'assets/images/tzyh/${isCoin ? selectStr : noselkjsd}.png',
                                            width: 14.w,
                                            fit: BoxFit.fitWidth,
                                          )
                                        ],
                                      )),
                                ),
                          BottomLine(),
                          rowText(
                              '发布用户',
                              verifyDetail!['nickname'] == null
                                  ? '茶馆用户'
                                  : verifyDetail!['nickname']),
                          BottomLine(),
                          Expanded(
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // money
                                  Text(
                                    '当前余额：${money}元宝',
                                    style: TextStyle(
                                        color: StyleTheme.cDangerColor,
                                        fontSize: 12.sp),
                                  ),
                                  verifyDetail!['freeMoneyNum'] < 500
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                AppGlobal.appRouter?.push(
                                                    CommonUtils.getRealHash(
                                                        'memberCardsPage'));
                                              },
                                              child: SizedBox(
                                                height: 50.w,
                                                width: 150.w,
                                                child: Stack(
                                                  clipBehavior: Clip.none,
                                                  children: [
                                                    LocalPNG(
                                                      height: 50.w,
                                                      width: 150.w,
                                                      url:
                                                          'assets/images/mymony/pay_bottom.png',
                                                    ),
                                                    Center(
                                                      child: Text(
                                                        '升级会员',
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 15.sp),
                                                      ),
                                                    ),
                                                    Positioned(
                                                        top: -35.w,
                                                        left:
                                                            ((150 - 104.5) / 2)
                                                                .w,
                                                        child: LocalPNG(
                                                            url:
                                                                'assets/images/detail/vip_mfjs.png',
                                                            width: 104.5,
                                                            height: 35.w,
                                                            fit: BoxFit.cover))
                                                  ],
                                                ),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                if (userBuyState == 1) {
                                                  AppGlobal.appRouter?.push(
                                                      CommonUtils.getRealHash(
                                                          'ingotWallet'));
                                                } else {
                                                  _payment();
                                                }
                                              },
                                              child: SizedBox(
                                                height: 50.w,
                                                width: 150.w,
                                                child: Stack(
                                                  children: [
                                                    LocalPNG(
                                                        height: 50.w,
                                                        width: 150.w,
                                                        url:
                                                            'assets/images/mymony/money-img.png',
                                                        fit: BoxFit.fill),
                                                    Center(
                                                      child: Text(
                                                        getBuyText(),
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 15.sp),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      : GestureDetector(
                                          onTap: () {
                                            if (userBuyState == 1) {
                                              AppGlobal.appRouter?.push(
                                                  CommonUtils.getRealHash(
                                                      'ingotWallet'));
                                            } else {
                                              _payment();
                                            }
                                          },
                                          child: SizedBox(
                                            height: 50.w,
                                            width: 275.w,
                                            child: Stack(
                                              children: [
                                                LocalPNG(
                                                  height: 50.w,
                                                  width: 275.w,
                                                  url:
                                                      'assets/images/mymony/money-img.png',
                                                ),
                                                Center(
                                                  child: Text(
                                                    getBuyText(),
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 15.sp),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                ],
                              ),
                            ),
                          )
                        ])),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: LocalPNG(
                          url: "assets/images/nav/closemenu.png",
                          width: 30.w,
                          height: 30.w,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          });
        });
  }

  Future<String?> _showModalBottomSheet() {
    return showModalBottomSheet<String>(
      context: context,
      builder: (BuildContext context) {
        return Container(
            height: 160.w,
            color: Colors.white,
            child: Stack(
              children: [
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _shareItem('微信好友', 'weixin'),
                      _shareItem('新浪微博', 'weibo'),
                      _shareItem('QQ好友', 'qq'),
                      _shareItem('twitter', 'twitter'),
                      _shareItem('facebook', 'facebook'),
                      // _shareItem('复制链接', 'link'),
                    ],
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: LocalPNG(
                      url: "assets/images/nav/closemenu.png",
                      width: 30.w,
                      height: 30.w,
                    ),
                  ),
                )
              ],
            ));
      },
    );
  }

  openApple(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      BotToast.showText(text: '分享链接已复制成功,快去粘帖分享给好友吧～', align: Alignment(0, 0));
      // 判断当前手机是否安装某app. 能否正常跳转
      await Future.delayed(Duration(milliseconds: 500), () async {
        await launchUrl(Uri.parse(url));
      });
    } else {
      BotToast.showText(text: '您还未安装该应用～', align: Alignment(0, 0));
    }
  }

  Widget _shareItem(String title, String icon) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        AppGlobal.appRouter?.push(CommonUtils.getRealHash('shareQRCodePage'));
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50.w,
            height: 50.w,
            margin: EdgeInsets.only(bottom: 10.w),
            child: LocalPNG(
                width: 50.w,
                height: 50.w,
                url: 'assets/images/detail/share-$icon.png',
                fit: BoxFit.cover),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 11.sp, color: StyleTheme.cTitleColor),
          )
        ],
      ),
    );
  }

  getVipText() {
    dynamic textVIP = CommonUtils.getVipType(UserInfo.vipLevel!);
    if (verifyDetail!['freeNum'] == 0) {
      return '升级会员可免费解锁';
    }
    if (verifyDetail!['authentication'] || verifyDetail!['is_money'] == 1) {
      if (verifyDetail!['freeMoneyNum'] > 0) {
        if (verifyDetail!['freeMoneyNum'] > 500) {
          return '【' + textVIP + '会员】元宝帖无限解锁';
        } else {
          return '【' +
              textVIP +
              '会员】还剩' +
              verifyDetail!['freeMoneyNum'].toString() +
              '次免费解锁';
        }
      }
      return '【' + textVIP + '会员】还剩0次免费解锁';
    } else {
      if (verifyDetail!['freeNum'] > 0) {
        if (verifyDetail!['freeNum'] > 500) {
          return '【' + textVIP + '会员】铜钱帖无限解锁';
        } else {
          return '【' +
              textVIP +
              '会员】还剩' +
              verifyDetail!['freeNum'].toString() +
              '次铜钱免费解锁';
        }
      }
      return '【' + textVIP + '会员】还剩0次铜钱免费解锁';
    }
  }

  getBuyText([Function? sottomSheetSetState]) {
    var exchange_ratio = Provider.of<HomeConfig>(context, listen: false)
            .data['exchange_ratio'] ??
        100;
    bool aba =
        (coins! <= (verifyDetail!['maxDeduction'] / 10) * exchange_ratio);
    if (verifyDetail!['authentication'] || verifyDetail!['is_money'] == 1) {
      //元宝解锁
      if (verifyDetail!['freeMoneyNum'] > 0) {
        //有免费次数
        return '免费解锁';
      } else {
        if (((verifyDetail!['maxDeduction'] == 0 ||
                    verifyDetail!['maxDeduction'] == null ||
                    aba) &&
                (money * 10 < verifyDetail!['coin'])) ||
            (money * 10 + (aba ? 0 : verifyDetail!['maxDeduction'])) <
                verifyDetail!['coin']) {
          //元宝不足
          userBuyState = 1;
          sottomSheetSetState?.call(() {});
          return '充值元宝';
        } else {
          return '确认支付';
        }
      }
    } else {
      //铜钱解锁
      if (verifyDetail!['freeNum'] > 0) {
        //有免费次数
        return '免费解锁';
      } else {
        if (coins! < verifyDetail!['coin']) {
          if (money * 10 < verifyDetail!['coin']) {
            //元宝不足
            userBuyState = 1;
            sottomSheetSetState?.call(() {});
            return '充值元宝';
          } else {
            //元宝不足
            userBuyState = 2;
            sottomSheetSetState?.call(() {});
            return '确认支付';
          }
        } else {
          return '确认支付';
        }
      }
    }
  }

  Widget rowText(String title, dynamic content, [Color? color]) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(
        title,
        style: TextStyle(color: Color(0xff969696), fontSize: 14.sp),
      ),
      SizedBox(
        width: 30.w,
      ),
      content is String
          ? Flexible(
              child: Text(
              content,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: color == null ? StyleTheme.cTitleColor : color,
                  fontSize: 14.sp),
            ))
          : content
    ]);
  }

  _onShowConfirmPCBCount() {
    setState(() {
      _isShowConfirmPCBCount = !_isShowConfirmPCBCount;
    });
  }

  TextEditingController _textEditingController = TextEditingController();

  Widget confirmPCBCount() {
    var transactionPriceMax = Provider.of<HomeConfig>(context, listen: false)
        .config
        .transactionPriceMax;
//    print('------------------$transactionPriceMax');
    return Material(
      child: AnimatedContainer(
        width: 1.sw,
        duration: Duration(milliseconds: 200),
        color: _isShowConfirmPCBCount
            ? Color.fromRGBO(0, 0, 0, 0.5)
            : Colors.transparent,
        child: Column(
          children: <Widget>[
            Container(
              width: 1.sw,
              color: Colors.white,
              padding: EdgeInsets.only(
                left: 10.w,
                right: 10.w,
                bottom: 10.w,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    height: 56,
                    width: 1.sw,
                    margin: EdgeInsets.only(top: ScreenUtil().statusBarHeight),
                    color: Colors.white,
                    child: Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        Center(
                          child: Text(
                            '品茶宝托管',
                            style: TextStyle(
                              fontSize: 18.sp,
                              color: StyleTheme.cTitleColor,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          bottom: 0,
                          right: 10.w,
                          child: Align(
                            child: InkWell(
                              child: GestureDetector(
                                child: Text(
                                  '取消',
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    color: StyleTheme.cTitleColor,
                                  ),
                                ),
                                onTap: _onShowConfirmPCBCount,
                              ),
                            ),
                            alignment: Alignment.center,
                          ),
                        )
                      ],
                    ),
                  ),
                  Text(
                    '托管金额(元宝)',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: StyleTheme.cTextColor,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 10.w),
                  ),
                  TextField(
                    controller: _textEditingController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: "输入元宝",
                      // 未获得焦点下划线设为灰色
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      //获得焦点下划线设为蓝色
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: StyleTheme.cTextColor),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10.w, bottom: 0),
                    child: Text(
                      '单笔最高' +
                          transactionPriceMax.toString() +
                          '，如有超过' +
                          transactionPriceMax.toString() +
                          '的情况，可以分多次托管',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: StyleTheme.cDangerColor,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 20.w, bottom: 10.w),
                    child: Center(
                      child: GestureDetector(
                        onTap: () async {
                          String id = widget.id;
                          String count = _textEditingController.text;
                          if (count.isEmpty) {
                            YyToast.errorToast('请输入元宝数量');
                            return;
                          }
                          _onShowConfirmPCBCount();
                          Map? data = await pcbManage(id, count);
                          String msg = '';
                          if (data!['status'].toString() == '1') {
                            msg = '托管成功,跳入品茶宝页面查看详情';
                            AppGlobal.appRouter?.push(
                                CommonUtils.getRealHash('pingChaBaoPage'));
                          } else {
                            msg = data['msg'] ?? '';
                          }
                          CommonUtils.showText(msg);
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            LocalPNG(
                              url: 'assets/images/mymony/money-img.png',
                              width: 250.w,
                              height: 50.w,
                            ),
                            Text(
                              '确认托管',
                              style: TextStyle(
                                fontSize: 15.sp,
                                color: Colors.white,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      '成功托管后元宝将被冻结',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: StyleTheme.cTextColor,
                      ),
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: GestureDetector(
                child: Container(
                  color: Colors.transparent,
                ),
                onTap: _onShowConfirmPCBCount,
              ),
            )
          ],
        ),
      ),
    );
  }

  getState(int state) {
    String imgurl = '';
    if (state == 0) {
      imgurl = 'assets/images/mymony/money-img.png';
    } else if (state == 1) {
      imgurl = 'assets/images/mymony/unverified.png';
    } else if (state == 2) {
      imgurl = 'assets/images/mymony/verified.png';
    } else if (state == 3) {
      imgurl = 'assets/images/detail/hui-bg.png';
    }
    return imgurl;
  }

  String loadData = '数据加载中...';
  String noData = '没有更多数据';
  Widget renderMore(bool isloading) {
    return Padding(
        padding: EdgeInsets.only(top: 15.w, bottom: 15.w),
        child: Center(
          child: Text(
            isloading ? loadData : noData,
            style: TextStyle(color: StyleTheme.cBioColor),
          ),
        ));
  }

  Widget _totalScore() {
    String zeroString = '0.0';
    String girlFaceStr = _avg['avg(girl_face)'] == null
        ? zeroString
        : _avg['avg(girl_face)'].substring(0, 3);
    String girlAvStr = _avg['avg(girl_service)'] == null
        ? zeroString
        : _avg['avg(girl_service)'].substring(0, 3);
    String avEnvStr = _avg['avg(env)'] == null
        ? zeroString
        : _avg['avg(env)'].substring(0, 3);
    return Container(
        height: 53.w,
        margin: new EdgeInsets.only(bottom: 0),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
              bottom: BorderSide(
                  color: StyleTheme.textbgColor1,
                  width: 1.w,
                  style: BorderStyle.solid)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              '颜值 $girlFaceStr',
              style: TextStyle(fontSize: 14.sp, color: StyleTheme.cTitleColor),
            ),
            Text(
              '服务 $girlAvStr',
              style: TextStyle(fontSize: 14.sp, color: StyleTheme.cTitleColor),
            ),
            Text(
              '环境 $avEnvStr',
              style: TextStyle(fontSize: 14.sp, color: StyleTheme.cTitleColor),
            ),
          ],
        ));
  }

  Widget _detailCard() {
    return Center(
      child: Container(
          key: _cardGlobalKey,
          padding: new EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.w),
          width: 345.w,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                //阴影
                BoxShadow(
                    color: Colors.black12,
                    offset: Offset(0, 0.5.w),
                    blurRadius: 2.5.w)
              ]),
          child: Stack(
            children: [
              LocalPNG(
                  url: 'assets/images/detail/card-bg.png', fit: BoxFit.cover),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    for (var item in _cardInfo!)
                      _introductionItem(
                          item['icon'],
                          item['title'] ?? '',
                          item['introduction'] ?? '',
                          item['star'] ?? null,
                          item['type'],
                          item['copy'],
                          item['last'] == null ? false : item['last']),
                    verifyDetail!['post_type'] == 1
                        ? Text(
                            '注意：请勿添加QQ群，转加的QQ及其他转加联系方式，以防被骗',
                            style: TextStyle(
                                color: StyleTheme.cDangerColor,
                                fontSize: 12.sp),
                          )
                        : SizedBox()
                  ],
                ),
              ),
            ],
          )),
    );
  }

  Widget _scoreCard(item) {
    return Container(
      padding: new EdgeInsets.only(
          left: 15.w, right: 15.w, bottom: 10.5.w, top: 19.5.w),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          margin: new EdgeInsets.only(right: 10.5.w),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
          child: GestureDetector(
            onTap: () {
              AppGlobal.appRouter?.push(CommonUtils.getRealHash(
                  'brokerHomepage/' +
                      item['uid'].toString() +
                      '/' +
                      Uri.encodeComponent(item['thumb'].toString()) +
                      '/' +
                      Uri.encodeComponent(item['nickname'].toString())));
            },
            child: Container(
              height: 40.sp,
              width: 40.sp,
              child: Avatar(type: item['thumb']),
            ),
          ),
        ),
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          item['nickname'],
                          style: TextStyle(
                            color: StyleTheme.cTitleColor,
                            fontSize: 16.sp,
                          ),
                        ),
                        item['agent'] == 4
                            ? Container(
                                margin: EdgeInsets.only(left: 6.w),
                                height: 17.w,
                                width: 48.w,
                                child: LocalPNG(
                                  height: 17.w,
                                  width: 48.w,
                                  url:
                                      'assets/images/detail/icon-jianchashi.png',
                                ),
                              )
                            : Container()
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          CommonUtils.getCgTime(
                                  int.parse(item['created_at'].toString())) +
                              ' 发布',
                          style: TextStyle(
                            color: StyleTheme.cBioColor,
                            fontSize: 12.sp,
                          ),
                        ),
                        if (item['time_str'] != null &&
                            item['time_str'].trim().isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(left: 6.w),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  alignment: Alignment.center,
                                  height: 13.w,
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 6.w),
                                  decoration: BoxDecoration(
                                      gradient: LinearGradient(colors: [
                                        Color.fromRGBO(255, 144, 0, 1),
                                        Color.fromRGBO(255, 194, 30, 1)
                                      ]),
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(6.5.w),
                                        bottomLeft: Radius.circular(6.5.w),
                                        bottomRight: Radius.circular(6.5.w),
                                      )),
                                  child: Text(
                                    "${item['time_str']}",
                                    style: TextStyle(
                                        color: Color.fromRGBO(248, 253, 255, 1),
                                        fontSize: 8.sp),
                                  ),
                                )
                              ],
                            ),
                          ),
                      ],
                    )
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    item['video']
                        ? Container(
                            margin: EdgeInsets.only(left: 10.w),
                            width: 50.w,
                            height: 20.w,
                            child: LocalPNG(
                              width: 50.w,
                              height: 20.w,
                              url: 'assets/images/detail/icon-video.png',
                            ),
                          )
                        : Container(),
                  ],
                ),
              ],
            ),
            Container(
              margin: new EdgeInsets.only(top: 16.5.w),
              child: Row(
                children: [
                  Text(
                    '妹子花名: ',
                    style: TextStyle(
                        fontSize: 14.sp, color: StyleTheme.cTitleColor),
                  ),
                  Text(
                    item['girl_name'].toString(),
                    style: TextStyle(
                        fontSize: 14.sp, color: StyleTheme.cTitleColor),
                  )
                ],
              ),
            ),
            Container(
              margin: new EdgeInsets.only(top: 15.5.w),
              child: Row(
                children: [
                  Text(
                    '品茶时间: ',
                    style: TextStyle(
                        fontSize: 14.sp, color: StyleTheme.cTitleColor),
                  ),
                  Text(
                    item['time'].toString(),
                    style: TextStyle(
                        fontSize: 14.sp, color: StyleTheme.cTitleColor),
                  )
                ],
              ),
            ),
            Container(
              margin: new EdgeInsets.only(top: 15.5.w),
              child: Row(
                children: [
                  Text(
                    '所在位置: ',
                    style: TextStyle(
                        fontSize: 14.sp, color: StyleTheme.cTitleColor),
                  ),
                  Text(
                    item['address'].toString(),
                    style: TextStyle(
                        fontSize: 14.sp, color: StyleTheme.cTitleColor),
                  )
                ],
              ),
            ),
            Container(
              height: 45.5.w,
              width: double.infinity,
              padding: new EdgeInsets.symmetric(horizontal: 15.5.w),
              color: StyleTheme.bottomappbarColor,
              margin: new EdgeInsets.only(top: 15.5.w),
              child: Row(
                children: [
                  Expanded(
                      child: Container(
                    child: Text(
                      item['girl_service_detail'].toString(),
                      style: TextStyle(
                          color: StyleTheme.cTitleColor, fontSize: 14.sp),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )),
                  GestureDetector(
                      onTap: () {
                        AppGlobal.appRouter?.push(CommonUtils.getRealHash(
                            'reportDetailPage/' +
                                item['id'].toString() +
                                '/' +
                                item['info_id'].toString() +
                                '/true'));
                      },
                      child: Container(
                        margin: new EdgeInsets.only(left: 11.5.w),
                        width: 37.5.w,
                        child: Text(
                          '更多>',
                          style: TextStyle(
                              color: StyleTheme.cDangerColor, fontSize: 14.sp),
                        ),
                      ))
                ],
              ),
            ),
            SizedBox(
              height: 11.5.w,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(),
                GestureDetector(
                  onTap: () {
                    replyItemComment(item['id']);
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      LocalPNG(
                        url: 'assets/images/elegantroom/icon_reply.png',
                        width: 15.w,
                        height: 15.w,
                      ),
                      SizedBox(
                        width: 5.w,
                      ),
                      Text(
                        '回复',
                        style: TextStyle(
                            color: StyleTheme.cTitleColor, fontSize: 12.sp),
                      )
                    ],
                  ),
                )
              ],
            ),
            //二级评论
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: (item['child'] as List).map((e) {
                print(item);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 16.w,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 25.w,
                          width: 25.w,
                          child: Avatar(
                            type: e['thumb'],
                            radius: 12.5.w,
                          ),
                        ),
                        SizedBox(
                          width: 10.w,
                        ),
                        Text(
                          e['nickname'].toString(),
                          style: TextStyle(
                            color: StyleTheme.cTitleColor,
                            fontSize: 16.sp,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: double.infinity,
                      margin: new EdgeInsets.only(
                          top: 10.w, left: 35.w, bottom: 10.w),
                      padding: EdgeInsets.symmetric(
                          horizontal: 14.w, vertical: 15.w),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: StyleTheme.bottomappbarColor),
                      child: Text(
                        e['content'].toString(),
                        style: TextStyle(
                            color: Color(0xFF646464), fontSize: 12.sp),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 35.w),
                      child: Text(
                        CommonUtils.getCgTime(
                            int.parse(e['created_at'].toString())),
                        style: TextStyle(
                          color: StyleTheme.cBioColor,
                          fontSize: 12.sp,
                        ),
                      ),
                    )
                  ],
                );
              }).toList(),
            )
          ],
        ))
      ]),
    );
  }

  Widget _detailHeader() {
    return Container(
      padding: new EdgeInsets.only(
        left: 15.5.w,
        top: 15.w,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
              child: Text(
            verifyDetail!['title'],
            style: TextStyle(
                fontSize: 18.sp,
                color: StyleTheme.cTitleColor,
                fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )),
        ],
      ),
    );
  }

  Widget _dtailList() {
    return Container(
        key: _infoGlobalKey,
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var item in _introductionList!)
                _introductionItem(
                    item['icon'],
                    item['title'],
                    item['introduction'],
                    item['star'],
                    item['type'],
                    item['copy'],
                    item['last'] == null ? false : item['last'])
            ],
          ),
        ));
  }

  bool containsText(String checktext) {
    if (checktext.startsWith('微信')) {
      return true;
    }
    if (checktext.startsWith('QQ')) {
      return true;
    }
    if (checktext.startsWith('qq')) {
      return true;
    }
    if (checktext.startsWith('手机')) {
      return true;
    }
    return false;
  }

  Widget _introductionItem(
      //copy
      String? icon,
      String title,
      String introduction,
      double? star,
      bool type,
      dynamic copy,
      bool isLast) {
    return GestureDetector(
      onTap: () {
        if (copy != null && type) {
          String titleText;
          if (containsText(introduction)) {
            titleText = introduction.substring(2);
          } else {
            titleText = introduction;
          }
          Clipboard.setData(ClipboardData(text: titleText));
          BotToast.showText(text: '$title 复制成功,快去验证吧～', align: Alignment(0, 0));
        }
      },
      child: Container(
          padding: new EdgeInsets.only(bottom: isLast ? 0 : 15.w),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  padding: new EdgeInsets.only(right: 10.5.w),
                  child: LocalPNG(
                    url: icon,
                    width: 15.w,
                    height: 15.w,
                  )),
              Container(
                  padding: new EdgeInsets.only(right: 10.5.w),
                  child: Text(
                    title + ':',
                    style: TextStyle(
                        height: 1.3,
                        fontSize: 14.sp,
                        color: type
                            ? StyleTheme.cTitleColor
                            : StyleTheme.cDangerColor),
                  )),
              star != null
                  ? StarRating(
                      rating: star,
                      disable: true,
                      size: 12.sp,
                      spacing: 5.w,
                    )
                  : Flexible(
                      child: Text(
                        introduction == '' ? '--' : introduction,
                        style: TextStyle(
                            height: 1.3,
                            fontSize: 14.sp,
                            color: type
                                ? StyleTheme.cTitleColor
                                : StyleTheme.cDangerColor),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
            ],
          )),
    );
  }

  Widget _swiper() {
    return verifyDetail!['pic'] != null && verifyDetail!['pic'].length > 0
        ? Swiper(
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                  onTap: () {
                    AppGlobal.picMap = {
                      'resources': verifyDetail!['pic'],
                      'index': index
                    };
                    context.push('/teaViewPicPage');
                  },
                  child: ImageNetTool(
                    url: verifyDetail!['pic'][index]['url'],
                    fit: BoxFit.fitHeight,
                  ));
            },
            itemCount: verifyDetail!['pic'].length,
            autoplay: false,
            loop: true,
            layout: SwiperLayout.DEFAULT,
            duration: 400,
            itemWidth: 375.w,
            itemHeight: 240.w,
            pagination: SwiperPagination(
              alignment: Alignment.bottomRight,
              builder: new SwiperCustomPagination(
                  builder: (BuildContext context, SwiperPluginConfig config) {
                return Container(
                    padding: new EdgeInsets.symmetric(
                      horizontal: 13.w,
                      vertical: 3.5.w,
                    ),
                    decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(10.0)),
                    child: Text(
                      (config.activeIndex + 1).toString() +
                          '/' +
                          config.itemCount.toString(),
                      style: TextStyle(fontSize: 14.sp, color: Colors.white),
                    ));
              }),
            ),
          )
        : Container();
  }

  Widget _timesFomat() {
    return Container(
        padding: new EdgeInsets.only(
          left: 15.w,
          top: 2.5.w,
          bottom: 10.w,
        ),
        child: Row(
          children: <Widget>[
            totalWidget("assets/images/card/unlock.png",
                verifyDetail!['buy'].toString()),
            totalWidget("assets/images/card/collect.png",
                verifyDetail!['favoriteNum'].toString()),
            totalWidget("assets/images/card/confirm.png",
                verifyDetail!['confirm'].toString()),
            Text(
              beforeText + "更新",
              style: TextStyle(color: StyleTheme.cBioColor, fontSize: 12.sp),
            )
          ],
        ));
  }

  Widget totalWidget(String icon, String total) {
    return Container(
      margin: EdgeInsets.only(
        right: 26.5.w,
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 15.w,
            height: 15.w,
            margin: EdgeInsets.only(right: 3.5.w),
            child: LocalPNG(
                width: 15.w, height: 15.w, url: icon, fit: BoxFit.cover),
          ),
          Text(
            total,
            style: TextStyle(color: StyleTheme.cBioColor, fontSize: 12.sp),
          )
        ],
      ),
    );
  }

  Widget newbieSee() {
    return Container(
      color: StyleTheme.bottomappbarColor,
      padding: new EdgeInsets.only(
        left: 12.w,
      ),
      margin: new EdgeInsets.only(bottom: 15.w),
      height: 70.w,
      child: Row(
        children: [
          Container(
              margin: new EdgeInsets.only(right: 11.5.w),
              child: LocalPNG(
                url: 'assets/images/detail/new-look.png',
                width: 43.5.w,
              )),
          Container(
            width: 1.w,
            height: 20.w,
            color: Color(0xFFE3AB78),
            margin: new EdgeInsets.only(right: 11.5.w),
          ),
          Expanded(
              child: Container(
            margin: EdgeInsets.only(
              right: 18.5.w,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text(
                  '在大厅消费,新手请先看防骗攻略，谨记“先服务后给钱”原则，先给钱被骗，平台概不负责!!!',
                  style: TextStyle(
                      height: 2,
                      color: StyleTheme.cTitleColor,
                      fontSize: 12.sp),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class GuideWidget extends StatelessWidget {
  final bool? isTransparent;
  final double? xOffset;
  final double? yOffset;
  final double? scaleFactor;

  const GuideWidget({
    Key? key,
    this.isTransparent,
    this.xOffset,
    this.yOffset,
    this.scaleFactor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
        width: isTransparent! ? 65.5.w : 1.sw,
        height: isTransparent! ? (isTransparent! ? 55 : 101).w : 1.sw,
        curve: Curves.linear,
        decoration: BoxDecoration(
          color: isTransparent! ? Colors.transparent : Colors.black38,
          borderRadius: BorderRadius.circular(isTransparent! ? 500.0 : 0),
        ),
        transform: Matrix4.translationValues(xOffset!, yOffset!, 0)
          ..scale(scaleFactor),
        duration: Duration(milliseconds: 250),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              LocalPNG(
                url: 'assets/images/detail/newtips.png',
                width: 72.w,
                height: isTransparent! ? 0 : 50.5.w,
                fit: BoxFit.fitHeight,
              ),
              GestureDetector(
                child: LocalPNG(
                  url: 'assets/images/detail/fpzn.png',
                  width: 65.w,
                  height: 55.w,
                ),
                onTap: () {
                  AppGlobal.appRouter?.push(CommonUtils.getRealHash('webview/' +
                      Uri.encodeComponent(UserInfo.fpznUrl.toString()) +
                      '/茶馆防骗指南'));
                },
              ),
            ],
          ),
        ));
  }
}

class ConfirmPCBCount extends StatefulWidget {
  @override
  _ConfirmPCBCountState createState() => _ConfirmPCBCountState();
}

class _ConfirmPCBCountState extends State<ConfirmPCBCount> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: AnimatedContainer(
        width: 1.sw,
        duration: Duration(milliseconds: 200),
        color: Color.fromRGBO(0, 0, 0, 0.5),
        child: Column(
          children: <Widget>[
            Container(
//              height: ScreenUtil().statusBarHeight,
              width: 1.sw,
              color: Colors.white,
              padding: EdgeInsets.only(
                left: 10.w,
                right: 10.w,
                bottom: 10.w,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    height: 56,
                    width: 1.sw,
                    margin: EdgeInsets.only(top: ScreenUtil().statusBarHeight),
                    color: Colors.white,
                    child: Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        Center(
                          child: Text(
                            '品茶宝托管',
                            style: TextStyle(
                              fontSize: 18.sp,
                              color: StyleTheme.cTitleColor,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          bottom: 0,
                          right: 10.w,
                          child: Align(
                            child: InkWell(
                              child: GestureDetector(
                                child: Text(
                                  '取消',
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    color: StyleTheme.cTitleColor,
                                  ),
                                ),
                              ),
                            ),
                            alignment: Alignment.center,
                          ),
                        )
                      ],
                    ),
                  ),
                  Text(
                    '托管金额(元宝)',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: StyleTheme.cTextColor,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 10.w),
                  ),
                  TextField(
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: "输入托管元宝",
                      // 未获得焦点下划线设为灰色
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      //获得焦点下划线设为蓝色
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: StyleTheme.cDangerColor),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10.w, bottom: 0),
                    child: Text(
                      '单笔最高1500，如有超过1500的情况，可以分多次托管',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: StyleTheme.cDangerColor,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 20.w, bottom: 10.w),
                    child: Center(
                      child: GestureDetector(
                        child: Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            LocalPNG(
                              url: 'assets/images/mymony/money-img.png',
                              width: 250.w,
                              height: 50.w,
                            ),
                            Text(
                              '确认托管',
                              style: TextStyle(
                                fontSize: 15.sp,
                                color: Colors.white,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      '成功托管后元宝将被冻结',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: StyleTheme.cTextColor,
                      ),
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: Container(),
            )
          ],
        ),
      ),
    );
  }
}

class BottomLine extends StatelessWidget {
  const BottomLine({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20.w),
      decoration: BoxDecoration(
        color: Color(0xFFEEEEEE),
        border: Border(
          top: BorderSide.none,
          left: BorderSide.none,
          right: BorderSide.none,
          bottom: BorderSide(width: 0.5, color: Color(0xFFEEEEEE)),
        ),
      ),
    );
  }
}
