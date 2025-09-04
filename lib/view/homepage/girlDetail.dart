import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:bot_toast/bot_toast.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:chaguaner2023/components/avatar_widget.dart';
import 'package:chaguaner2023/components/cgDialog.dart';
import 'package:chaguaner2023/components/detail_ad.dart';
import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/loading.dart';
import 'package:chaguaner2023/components/networkErr.dart';
import 'package:chaguaner2023/components/nodata.dart';
import 'package:chaguaner2023/components/pagetitlebar.dart';
import 'package:chaguaner2023/components/starrating.dart';
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
import 'package:chaguaner2023/utils/netimage_tool.dart';
import 'package:chaguaner2023/video/shortv_player.dart';
import 'package:chaguaner2023/view/im/im.dart';
import 'package:chaguaner2023/view/im/im_page.dart';
import 'package:chaguaner2023/view/yajian/slectYouhuiquan.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class GilrDrtailPage extends StatefulWidget {
  final String? id;
  final int? type;

  GilrDrtailPage({
    Key? key,
    this.id,
    this.type,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => GilrDrtailState();
}

class GilrDrtailState extends State<GilrDrtailPage>
    with TickerProviderStateMixin {
  ScrollController? _scrollViewController;
  AnimationController? _lottieController;

  // userBuy 0未购买1已购买2已验证
  // favorite 0未收藏1收藏
  bool isFavorite = false;

  //经纪人信息---------------------------
  dynamic brokerUuid;
  String? brokerName;
  String? brokerAvatar;

  //-----------------------------------
  dynamic money; //元宝
  dynamic myMoney;
  bool loading = true;
  Map? verifyDetail;
  List<Map> imgList = [];
  int truePage = 1;
  bool networkErr = false;
  bool trueIsAll = false;
  bool trueIsLoading = false;
  dynamic _avg;
  int limit = 10;
  GlobalKey _globalKey = GlobalKey();
  double widgetHeight = 2000;
  bool timeSwitch = true;
  List<dynamic> _evaluationTrue = [];
  int? id;
  bool userPaid = false;
  int? selectId;
  int selectValue = 0;
  List? _introductionList;
  SwiperController swiperController = new SwiperController();
  List radioList = [
    {'title': '1P 2000', 'id': 0},
    {'title': '2P 5000', 'id': 1},
    {'title': '包夜', 'id': 2}
  ];
  int dialogIndex = 0;
  int serviceType = 0;
  Map? adData; // 广告数据
  String teaGirlStr = '茶女郎';
  String teaBoss = '茶老板';
  String contactTeaBoss = '联系茶老板';
  String contactTeaGirl = '联系茶女郎';
  String teaStorys = '茶铺';
  bool isSelf = false;
  String getType() {
    return widget.type == 3 ? teaStorys : teaGirlStr;
  }

  _getInfo() async {
    setState(() {
      networkErr = false;
    });
    var resFunc = widget.type == 3 ? getChapuDetail : getChaGirlDetail;
    var _info = await resFunc(int.parse(widget.id!));
    if (_info!['status'] == null) {
      setState(() {
        networkErr = true;
      });
      return;
    }
    if (_info['status'] != 0) {
      String? uid = Provider.of<HomeConfig>(context, listen: false).member.aff;
      print(_info['data']);
      verifyDetail = _info['data'];
      isSelf = verifyDetail!['aff'].toString() == uid;
      userPaid = _info['data']['user_paid'];
      brokerUuid = _info['data']['uuid'];
      isFavorite =
          _info['data']['favorite'] == null ? false : _info['data']['favorite'];
      brokerAvatar = _info['data']['thumb'];
      brokerName = _info['data']['nickname'];
      _introductionList = (widget.type == 3
          ? [
              {
                'icon': 'assets/images/detail/icon-num.png',
                'title': '妹子数量',
                'type': true,
                'introduction': verifyDetail!['girl_num'] == null
                    ? 1
                    : verifyDetail!['girl_num'].toString()
              },
              {
                'icon': 'assets/images/detail/icon-age.png',
                'title': '妹子年龄',
                'type': true,
                'introduction': verifyDetail!['girl_age'].toString()
              },
              {
                'icon': 'assets/images/detail/icon-money.png',
                'title': '消费情况',
                'type': true,
                'introduction': verifyDetail!['price'].toString()
              },
              {
                'icon': 'assets/images/detail/icon-project.png',
                'title': '服务项目',
                'type': true,
                'introduction': verifyDetail!['cast_way'] == null
                    ? '未填写'
                    : verifyDetail!['cast_way'].toString()
              },
              {
                'icon': 'assets/images/detail/icon-time.png',
                'title': '营业时间',
                'type': true,
                'introduction': verifyDetail!['business_hours'].toString()
              },
              {
                'icon': 'assets/images/detail/icon-postion.png',
                'title': '所在地区',
                'type': true,
                'introduction': verifyDetail!['cityName'].toString()
              }
            ]
          : [
              {
                'icon': 'assets/images/detail/icon-remarks.png',
                'title': '基本信息',
                'type': true,
                'introduction': verifyDetail!['girl_age_num'].toString() +
                    '岁  ' +
                    verifyDetail!['girl_height'].toString() +
                    'cm  ' +
                    verifyDetail!['girl_cup_str'].toString()
              },
              {
                'icon': 'assets/images/detail/icon-postion.png',
                'title': '所在地区',
                'type': true,
                'introduction': verifyDetail!['cityName'].toString()
              },
              {
                'icon': 'assets/images/detail/icon-money.png',
                'title': '消费情况',
                'type': true,
                'introduction': verifyDetail!['price'].toString()
              },
              {
                'icon': 'assets/images/detail/icon-time.png',
                'title': '服务项目',
                'type': true,
                'introduction': verifyDetail!['girl_service_type'].toString()
              }
            ]);
      setState(() {});

      List _resouce = verifyDetail!['resources'];
      _resouce.sort((video, image) => image['type'].compareTo(video['type']));
      verifyDetail!['resources'] = _resouce;
      setState(() {});
      if (verifyDetail!['status'] == 4) {
        showBuy('提示', '该' + getType().toString() + '已被删除～', 2).then((val) => {
              if (val == true) {Navigator.of(context).pop(true)}
            });
      }
      if (verifyDetail!['status'] == 5) {
        showBuy('提示', '该' + getType().toString() + '已下线,请返回并下拉刷新列表～', 2)
            .then((val) => {
                  if (val == true) {Navigator.of(context).pop(true)}
                });
      }
    } else {
      BotToast.showText(text: _info['msg'], align: Alignment(0, 0));
      return context.pop();
    }
    _getConfirmList();
  }

  reservation() async {
    AppGlobal.connetGirl = connectGirl;
    await isAppointment(widget.id!, selectId).then((res) {
      if (res!['status'] != 0) {
        getProfilePage().then((val) {
          if (val!['status'] != 0) {
            Provider.of<HomeConfig>(context, listen: false)
                .setMoney(val['data']['money']);
          }
        });
        BotToast.showText(text: '预约成功～', align: Alignment(0, 0));
        Navigator.of(context).pop('val');
        AppGlobal.appRouter?.push(CommonUtils.getRealHash('yuyuesuccess/' +
            verifyDetail!['fee'].toString() +
            '/' +
            selectValue.toString() +
            '/' +
            Uri.encodeComponent(verifyDetail!['title'].toString()) +
            '/' +
            Uri.encodeComponent(verifyDetail!['nickname'].toString()) +
            '/2'));
      } else {
        BotToast.showText(text: res['msg'], align: Alignment(0, 0));
      }
    });
  }

//真实信息列表
  _getConfirmList() async {
    await getVipInfoConfirm(truePage, limit, widget.id!).then((confirmList) {
      print(confirmList);
      if (truePage == 1) {
        if (confirmList!['status'] != 0) {
          timeSwitch = true;
          loading = false;
          _avg = confirmList['data']['avg'];
          _evaluationTrue = confirmList['data']['list'];
          trueIsLoading = false;
          setState(() {});
        } else {
          BotToast.showText(text: confirmList['msg'], align: Alignment(0, 0));
        }

        if (confirmList['data']['list'].length < limit) {
          setState(() {
            trueIsLoading = false;
            trueIsAll = true;
          });
        }
      } else {
        if (confirmList!['status'] != 0 &&
            confirmList['data']['list'].length > 0) {
          setState(() {
            timeSwitch = true;
            _evaluationTrue.addAll(confirmList['data']['list']);
          });
        } else {
          setState(() {
            trueIsLoading = false;
            trueIsAll = true;
          });
        }
      }
    });
  }

  _getHeight(_) {
    if (_globalKey.currentContext != null &&
        _globalKey.currentContext!.size!.height != widgetHeight) {
      widgetHeight = _globalKey.currentContext!.size!.height;
      setState(() {});
    }
  }

  // 获取广告
  getAd() async {
    var data = await getDetail_ad(701);
    if (data != null) {
      this.setState(() {
        adData = data;
      });
    }
  }

  //回复评论
  replyItemComment(_id, String nickname) {
    if (isSelf) {
      reqReply(_id, nickname);
      return;
    }
    if (CgPrivilege.getPrivilegeStatus(
        PrivilegeType.infoConfirm, PrivilegeType.privilegeComment)) {
      if (userPaid) {
        reqReply(_id, nickname);
      } else {
        YyShowDialog.showdialog(context, title: '提示', btnText: '支付预约金',
            callBack: () {
          if (verifyDetail!['status'] == 2) {
            setState(() {
              myMoney = money;
            });
            showPublish();
          }
        }, content: (setDialogState) {
          return Text(
            '支付预约金并且完成服务后可回复,是否支付预约金？',
            style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 15.sp),
          );
        });
      }
    } else {
      return CommonUtils.showVipDialog(
          context, PrivilegeType.privilegeCommentString);
    }
  }

  reqReply(_id, String nickname) {
    InputDialog.show(context, '回复给 $nickname', limitingText: 99, btnText: '发送',
        onSubmit: (value) {
      if (value != null) {
        replyVipComment(confirmId: _id, content: value).then((res) {
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
    AppGlobal.connetGirl = null;
    getCustomerService().then((res) {
      if (res['status'] != 0) {
        UserInfo.kefuList = res['data']['agent_uuid'];
      }
    });
    Future.delayed(new Duration(seconds: 1), () {
      WidgetsBinding.instance.addPersistentFrameCallback(_getHeight);
    });
    _scrollViewController = ScrollController(initialScrollOffset: 0.0);
    _lottieController = AnimationController(vsync: this);
    _getInfo();
    getAd();
    EventBus().on('SWICH_SERVICE', (arg) {
      var agent = Provider.of<GlobalState>(context, listen: false)
          .profileData?['agent'];
      // Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //         builder: (context) => KyImChatPage(
      //             isVipDetail: true,
      //             isAgent: agent == 1,
      //             isGirl: true,
      //             receiveUuid: UserInfo.officialUuid,
      //             title: UserInfo.officialName,
      //             avatar: 'chaxiaowai')));
    });
  }

  _onScrollNotification(ScrollNotification scrollInfo) {
    if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
      //滑到了底部
      if (timeSwitch) {
        if (!trueIsAll) {
          setState(() {
            truePage++;
            trueIsLoading = true;
          });
          _getConfirmList();
        }
        setState(() {
          timeSwitch = false;
        });
      }
    }
    return false;
  }

  toLlIm() {
    AppGlobal.connetGirl = connectGirl;
    if (verifyDetail!['price_pp'] == 0 || verifyDetail!['price_pp'] == '0') {
      //茶女郎代聊状态关闭
      AppGlobal.chatUser = FormUserMsg(
          isVipDetail: true,
          isGirl: true,
          uuid: verifyDetail!['uuid'].toString(),
          nickname: verifyDetail!['nickname'].toString(),
          avatar: verifyDetail!['thumb'].toString());
      AppGlobal.appRouter?.push(CommonUtils.getRealHash('llchat'));
    } else {
      if (widget.type == 2) {
        // print('**************客服列表:${UserInfo.kefuList}***************');
        // ====================================给用户找到合适的客服====================================
        PersistentState.getState('vipkefu').then((value) {
          if (value == null || value == 'null') {
            //还没有给用户分配过客服
            var vipkefu;
            var onlineArr;
            onlineArr =
                UserInfo.kefuList!.where((item) => item['work'] == 1).toList();
            if (onlineArr.length > 0) {
              //随机分配在线客服
              vipkefu = onlineArr[Random().nextInt(onlineArr.length)];
            } else {
              //随机分配不在线客服
              vipkefu = UserInfo
                  .kefuList![Random().nextInt(UserInfo.kefuList!.length)];
            }
            PersistentState.saveState('vipkefu', json.encode(vipkefu));
            UserInfo.officialUuid = vipkefu['uuid'];
            UserInfo.officialName = vipkefu['nickname'];
          } else {
            //用户有客服
            var kefuObj = json.decode(value);
            var onlineArr = UserInfo.kefuList!
                .where((item) =>
                    item['uuid'] == kefuObj['uuid'] && item['work'] == 1)
                .toList();
            if (onlineArr.length == 1) {
              //给用户分配的客服在线
              UserInfo.officialUuid = kefuObj['uuid'];
              UserInfo.officialName = kefuObj['nickname'];
            } else {
              //给用户分配的客服不在线
              var vipkefu;
              var allOnline;
              allOnline = UserInfo.kefuList!
                  .where((item) => item['work'] == 1)
                  .toList();
              if (allOnline.length > 0) {
                //还有在线客服随机找一个
                vipkefu = allOnline[Random().nextInt(allOnline.length)];
              } else {
                //没有在线客服就随机找一个
                vipkefu = UserInfo
                    .kefuList![Random().nextInt(UserInfo.kefuList!.length)];
              }
              PersistentState.saveState('vipkefu', json.encode(vipkefu));
              UserInfo.officialUuid = vipkefu['uuid'];
              UserInfo.officialName = vipkefu['nickname'];
            }
          }
          // ==================================================================================================
          var image =
              verifyDetail!['resources'].firstWhere((v) => v['type'] == 1);
          dynamic officialUuids =
              WebSocketUtility.uuid! + 'ImKey' + UserInfo.officialUuid!;
          PersistentState.saveState(
              '$officialUuids',
              (json.encode({
                'type': 'chanvlang',
                'image': image['url'],
                'id': verifyDetail!['id'].toString(),
                'price': verifyDetail!['fee'].toString(),
                'title': verifyDetail!['title'] +
                    '  id:' +
                    verifyDetail!['id'].toString(),
                'status': verifyDetail!['status'].toString(),
                'priceMin': verifyDetail!['price'].toString()
              })));
          AppGlobal.chatUser = FormUserMsg(
              isVipDetail: true,
              isGirl: true,
              uuid: UserInfo.officialUuid!,
              nickname: UserInfo.officialName!,
              avatar: 'chaxiaowai');
          AppGlobal.appRouter?.push(CommonUtils.getRealHash('llchat'));
        });
      } else {
        if (brokerUuid != null) {
          AppGlobal.chatUser = FormUserMsg(
              isVipDetail: true,
              uuid: brokerUuid.toString(),
              nickname: brokerName!,
              avatar: brokerAvatar!);
          AppGlobal.appRouter?.push(CommonUtils.getRealHash('llchat'));
        } else {
          BotToast.showText(
              text: '该' + getType() + '数据出现错误，无法私聊经纪人～',
              align: Alignment(0, 0));
        }
      }
    }
  }

  //收藏
  _collect() async {
    setState(() {
      isFavorite = !isFavorite;
    });
    var favorite = await favoriteGilr(widget.id!);
    if (favorite!['status'] != 0) {
      BotToast.showText(
          text: isFavorite ? '收藏成功' : '取消收藏成功', align: Alignment(0, 0));
      setState(() {
        verifyDetail!['userFavorite'] = isFavorite ? 1 : 0;
        isFavorite = verifyDetail!['userFavorite'] == 1;
      });
    } else {
      setState(() {
        isFavorite = verifyDetail!['userFavorite'] == 1;
      });
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

  connectGirl() {
    if (!CgPrivilege.getPrivilegeStatus(
        PrivilegeType.infoSystem, PrivilegeType.privilegeIm)) {
      CommonUtils.showVipDialog(context,
          PrivilegeType.infoSysteString + PrivilegeType.privilegeImString);
      return;
    }
    if (WebSocketUtility.imToken == null) {
      CommonUtils.getImPath(context, callBack: () {
        //跳转IM
        toLlIm();
      });
    } else {
      //跳转IM
      toLlIm();
    }
  }

  @override
  void dispose() {
    EventBus().off('SWICH_SERVICE');
    _scrollViewController!.dispose();
    _lottieController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeConfig>(
      builder: (_, value, __) {
        money = value.member.money;
        return HeaderContainer(
          child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: PreferredSize(
                  child: PageTitleBar(
                    title: '${getType()}详情',
                  ),
                  preferredSize: Size(double.infinity, 44.w)),
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
                          children: [
                            Expanded(
                                child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                NotificationListener<ScrollNotification>(
                                    onNotification:
                                        (ScrollNotification scrollInfo) =>
                                            _onScrollNotification(scrollInfo),
                                    child: ListView(
                                      physics: ClampingScrollPhysics(),
                                      children: <Widget>[
                                        Column(
                                          children: <Widget>[
                                            Container(
                                              color: Colors.white,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  verifyDetail!['resources'] !=
                                                              null &&
                                                          verifyDetail![
                                                                      'resources']
                                                                  .length >
                                                              0
                                                      ? Container(
                                                          color:
                                                              Color(0xFFE5E5E5),
                                                          height: 240.w,
                                                          child: _swiper())
                                                      : Container(),
                                                  Stack(
                                                    children: [
                                                      Column(
                                                        children: [
                                                          _detailHeader(),
                                                          widget.type == 2
                                                              ? faceCard()
                                                              : Container(),
                                                          adData != null
                                                              ? Container(
                                                                  padding: EdgeInsets
                                                                      .symmetric(
                                                                          horizontal:
                                                                              10.w),
                                                                  child: Detail_ad(
                                                                      app_layout:
                                                                          true,
                                                                      data: adData![
                                                                          "data"]),
                                                                )
                                                              : Container(),
                                                          Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      top: 15
                                                                          .w)),
                                                          Container(
                                                            key: _globalKey,
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: <Widget>[
                                                                Container(
                                                                    width: double
                                                                        .infinity,
                                                                    margin: EdgeInsets.symmetric(
                                                                        horizontal: 15
                                                                            .w),
                                                                    color: Color(
                                                                        0xFFF8F8F8),
                                                                    padding: new EdgeInsets
                                                                        .symmetric(
                                                                        horizontal:
                                                                            15.5
                                                                                .w,
                                                                        vertical: 15
                                                                            .w),
                                                                    child:
                                                                        Column(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .min,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        _dtailList(),
                                                                        Container(
                                                                          height:
                                                                              1.w,
                                                                          color:
                                                                              StyleTheme.textbgColor1,
                                                                          margin:
                                                                              EdgeInsets.only(bottom: 15.w),
                                                                        ),
                                                                        Text(
                                                                          verifyDetail![
                                                                              'desc'],
                                                                          style: TextStyle(
                                                                              fontSize: 14.sp,
                                                                              color: StyleTheme.cTitleColor),
                                                                        ),
                                                                      ],
                                                                    )),
                                                              ],
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 15.w,
                                                          )
                                                        ],
                                                      ),
                                                      Positioned(
                                                          top: 0,
                                                          right: 15.w,
                                                          child: Container(
                                                            width: 30.w,
                                                            height: 85.w,
                                                            child: LocalPNG(
                                                                url:
                                                                    'assets/images/card/renzheng.png',
                                                                fit: BoxFit
                                                                    .cover),
                                                          ))
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                            _totalScore(),
                                            Container(
                                                child: _evaluationTrue.length ==
                                                        0
                                                    ? Container(
                                                        padding:
                                                            EdgeInsets.only(
                                                                bottom: 100.w),
                                                        child: NoData(
                                                            text:
                                                                '还没有人发布真实信息哦～'),
                                                      )
                                                    : Column(children: [
                                                        for (var item
                                                            in _evaluationTrue)
                                                          _scoreCard(item)
                                                      ])),
                                            _evaluationTrue.length > 0
                                                ? renderMore(trueIsLoading)
                                                : Container()
                                          ],
                                        ),
                                      ],
                                    )),
                              ],
                            )),
                            Container(
                              height: 49.w + ScreenUtil().bottomBarHeight,
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
                                    children: <Widget>[
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          GestureDetector(
                                              onTap: connectGirl,
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Container(
                                                    margin: new EdgeInsets.only(
                                                        right: 10.w),
                                                    child: LocalPNG(
                                                      url:
                                                          'assets/images/detail/chat.png',
                                                      width: 25.w,
                                                      height: 25.w,
                                                    ),
                                                  ),
                                                  Text(
                                                    widget.type == 3
                                                        ? contactTeaBoss
                                                        : contactTeaGirl,
                                                    style: TextStyle(
                                                        fontSize: 14.sp,
                                                        color: StyleTheme
                                                            .cTitleColor,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  )
                                                ],
                                              )),
                                          widget.type == 3
                                              ? Container()
                                              : GestureDetector(
                                                  onTap: () {
                                                    if (CgPrivilege
                                                        .getPrivilegeStatus(
                                                            PrivilegeType
                                                                .infoVip,
                                                            PrivilegeType
                                                                .privilegeAppointment)) {
                                                      _collect();
                                                    } else {
                                                      CommonUtils.showVipDialog(
                                                          context,
                                                          '购买会员才能在线预约雅间妹子，平台担保交易，照片和人不匹配平台包赔，让你约到合乎心意的妹子',
                                                          isFull: true);
                                                    }
                                                  },
                                                  child: Container(
                                                    margin: EdgeInsets.only(
                                                        left: 20.w),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Container(
                                                          margin: new EdgeInsets
                                                              .only(
                                                              right: 10.w),
                                                          child: LocalPNG(
                                                            url: isFavorite
                                                                ? 'assets/images/card/iscollect.png'
                                                                : 'assets/images/mymony/collect.png',
                                                            width: 25.w,
                                                            height: 25.w,
                                                          ),
                                                        ),
                                                        Text('收藏',
                                                            style: TextStyle(
                                                                fontSize: 14.sp,
                                                                color: StyleTheme
                                                                    .cTitleColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500))
                                                      ],
                                                    ),
                                                  ),
                                                )
                                        ],
                                      )
                                    ],
                                  ),
                                  GestureDetector(
                                    // ignore: missing_return
                                    onTap: () {
                                      if (verifyDetail!['type'] == 2 &&
                                          verifyDetail!['girl_age'] == "0") {
                                        BotToast.showText(
                                            text: '休息中、无法预约！',
                                            align: Alignment(0, 0));
                                        return;
                                      }
                                      if (verifyDetail!['status'] == 2) {
                                        setState(() {
                                          myMoney = money;
                                        });
                                        showPublish();
                                      }
                                    },
                                    child: Container(
                                      width: 110.w,
                                      height: 40.w,
                                      margin: new EdgeInsets.only(left: 10.w),
                                      child: Stack(
                                        children: [
                                          LocalPNG(
                                              width: 110.w,
                                              height: 40.w,
                                              url:
                                                  'assets/images/mymony/money-img.png',
                                              fit: BoxFit.fill),
                                          Center(
                                              child: Text(
                                            verifyDetail!['type'] == 2 &&
                                                    verifyDetail!['girl_age'] ==
                                                        "0"
                                                ? '休息中'
                                                : '支付预约金',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14.w,
                                                fontWeight: FontWeight.w500),
                                          ))
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ))),
        );
      },
    );
  }

  // 购买茶女郎弹框
  Future<bool?> showBuy(String title, dynamic content, int type) {
    String comfStr = '确认支付';
    String sdkj = '去充值';
    String asdkj = type == 1 ? sdkj : comfStr;
    return showDialog<bool?>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
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
                        title,
                        style: TextStyle(
                            color: StyleTheme.cTitleColor,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                        margin: new EdgeInsets.only(top: 20.w),
                        child: (content is String)
                            ? Text(
                                content,
                                style: TextStyle(
                                    fontSize: 14.sp,
                                    color: StyleTheme.cTitleColor),
                              )
                            : content),
                    GestureDetector(
                      onTap: () => {
                        Navigator.of(context).pop(true),
                      },
                      child: Container(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              margin: new EdgeInsets.only(top: 30.w),
                              height: 50.w,
                              width: 110.w,
                              child: Stack(
                                children: [
                                  LocalPNG(
                                      height: 50.w,
                                      width: 110.w,
                                      url: 'assets/images/mymony/money-img.png',
                                      fit: BoxFit.fill),
                                  Center(
                                      child: Text(
                                    '取消',
                                    style: TextStyle(
                                        fontSize: 15.w, color: Colors.white),
                                  ))
                                ],
                              ),
                            ),
                          ),
                          type == 3
                              ? GestureDetector(
                                  onTap: () => {
                                        Navigator.of(context).pop(true),
                                      },
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      AppGlobal.appRouter?.push(
                                          CommonUtils.getRealHash(
                                              'memberCardsPage'));
                                    },
                                    child: Container(
                                        margin: new EdgeInsets.only(top: 30.w),
                                        height: 50.w,
                                        width: 110.w,
                                        child: Stack(
                                          children: [
                                            LocalPNG(
                                                url:
                                                    "assets/images/mymony/money-img.png",
                                                height: 50.w,
                                                width: 110.w,
                                                fit: BoxFit.fill),
                                            Center(
                                                child: Text(
                                              '去开通',
                                              style: TextStyle(
                                                  fontSize: 15.sp,
                                                  color: Colors.white),
                                            )),
                                          ],
                                        )),
                                  ))
                              : GestureDetector(
                                  // ignore: missing_return
                                  onTap: () {
                                    if (type == 0) {
                                      Navigator.of(context).pop();
                                      if (double.parse(
                                              verifyDetail!['fee'].toString()) >
                                          double.parse(myMoney.toString())) {
                                        showBuy(
                                            '确认下单',
                                            '需要支付预约金' +
                                                verifyDetail!['fee']
                                                    .toString() +
                                                '元宝。',
                                            1);
                                        return;
                                      } else {
                                        reservation();
                                      }
                                    }
                                    if (type == 1) {
                                      Navigator.of(context).pop();
                                      AppGlobal.appRouter?.push(
                                          CommonUtils.getRealHash(
                                              'ingotWallet'));
                                    }
                                    if (type == 2) {
                                      Navigator.of(context).pop();
                                    }
                                  },
                                  child: Container(
                                      margin: new EdgeInsets.only(top: 30.w),
                                      height: 50.w,
                                      width: 110.w,
                                      child: Stack(
                                        children: [
                                          LocalPNG(
                                              url:
                                                  "assets/images/mymony/money-img.png",
                                              height: 50.w,
                                              width: 110.w,
                                              fit: BoxFit.fill),
                                          Center(
                                              child: Text(
                                            type != 2 ? asdkj : '朕知道了',
                                            style: TextStyle(
                                                fontSize: 15.sp,
                                                color: Colors.white),
                                          )),
                                        ],
                                      )),
                                )
                        ],
                      )),
                    )
                  ],
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: LocalPNG(
                          url: "assets/images/mymony/close.png",
                          width: 30.w,
                          height: 30.w,
                          fit: BoxFit.cover)),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  String loadData = '数据加载中...';
  String noData = '没有更多数据';
  Widget renderMore(bool isloading) {
    return Padding(
        padding: EdgeInsets.only(bottom: 30.w),
        child: Center(
          child: Text(
            isloading ? loadData : noData,
            style: TextStyle(color: StyleTheme.cBioColor),
          ),
        ));
  }

  Widget _totalScore() {
    String zeroSt = '0.0';
    String girlSer = _avg["avg(girl_service)"] == null
        ? zeroSt
        : _avg["avg(girl_service)"].substring(0, 3);
    return Container(
        height: 53.w,
        margin: new EdgeInsets.only(bottom: 19.5.w),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
              bottom: BorderSide(
                  color: StyleTheme.textbgColor1,
                  width: 1.w,
                  style: BorderStyle.solid)),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
                child: Container(
              margin: EdgeInsets.only(left: 15.w),
              child: Text(
                verifyDetail!['confirm'].toString() + '人评价',
                style: TextStyle(
                    fontSize: 18.sp,
                    color: StyleTheme.cTitleColor,
                    fontWeight: FontWeight.bold),
              ),
            )),
            Expanded(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      '服务质量 ' + girlSer.toString(),
                      style: TextStyle(
                          fontSize: 14.sp, color: StyleTheme.cTitleColor),
                    ),
                  ],
                ))
          ],
        ));
  }

  String nowPay = '立即支付';
  Future showPublish() {
    String userCheckStr = widget.type == 3 ? teaBoss : teaGirlStr;
    return showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setBottomSheetState) {
            return Container(
              color: Colors.transparent,
              child: Container(
                height: 450.w + ScreenUtil().bottomBarHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Container(
                        padding:
                            EdgeInsets.only(top: 20.w, left: 15.w, right: 15.w),
                        child: Swiper(
                          controller: swiperController,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (BuildContext context, int index) {
                            return index == 0
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        child: Center(
                                            child: Text(
                                          '支付预约金',
                                          style: TextStyle(
                                              fontSize: 18.sp,
                                              color: StyleTheme.cTitleColor,
                                              fontWeight: FontWeight.w500),
                                        )),
                                      ),
                                      Container(
                                        child: Flex(
                                          direction: Axis.horizontal,
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                                flex: 1, child: Container()),
                                            Expanded(
                                                flex: 2,
                                                child: Container(
                                                  margin: EdgeInsets.only(
                                                      top: 40.w, bottom: 40.w),
                                                  child: Center(
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                  right: 11.w),
                                                          width: 38.w,
                                                          height: 27.w,
                                                          child: LocalPNG(
                                                              url:
                                                                  'assets/images/detail/vip-yuanbao.png',
                                                              width: 38.w,
                                                              height: 27.w,
                                                              fit: BoxFit
                                                                  .contain),
                                                        ),
                                                        Text.rich(TextSpan(
                                                            text: (verifyDetail![
                                                                        'fee'] -
                                                                    selectValue)
                                                                .toString(),
                                                            style: TextStyle(
                                                                color: StyleTheme
                                                                    .cTitleColor,
                                                                fontSize:
                                                                    36.sp),
                                                            children: [
                                                              TextSpan(
                                                                text: '元宝',
                                                                style: TextStyle(
                                                                    color: StyleTheme
                                                                        .cTitleColor,
                                                                    fontSize:
                                                                        18.sp),
                                                              )
                                                            ])),
                                                      ],
                                                    ),
                                                  ),
                                                )),
                                            Expanded(
                                                flex: 1,
                                                child: selectValue != 0
                                                    ? Container(
                                                        margin: EdgeInsets.only(
                                                            top: 15.w),
                                                        child: Text(
                                                          verifyDetail!['fee']
                                                                  .toString() +
                                                              '元宝',
                                                          style: TextStyle(
                                                            color: StyleTheme
                                                                .cBioColor,
                                                            fontSize: 18.sp,
                                                            decoration:
                                                                TextDecoration
                                                                    .lineThrough,
                                                            decorationColor:
                                                                StyleTheme
                                                                    .cBioColor,
                                                          ),
                                                        ),
                                                      )
                                                    : Container()),
                                          ],
                                        ),
                                      ),
                                      BottomLine(),
                                      rowText(
                                        '优惠券',
                                        selectValue == 0
                                            ? '选择优惠券'
                                            : selectValue.toString() + '元宝优惠券',
                                        setBottomSheetState,
                                        selectValue == 0
                                            ? StyleTheme.cBioColor
                                            : StyleTheme.cDangerColor,
                                      ),
                                      BottomLine(),
                                      rowText(
                                          '预约妹子',
                                          verifyDetail!['title'].toString(),
                                          setBottomSheetState),
                                      BottomLine(),
                                      rowText(
                                          '发布用户',
                                          verifyDetail!['nickname'].toString(),
                                          setBottomSheetState),
                                      BottomLine(),
                                      Center(
                                        child: Text(
                                          '账户余额：' + myMoney.toString() + '元宝',
                                          style: TextStyle(
                                              color: StyleTheme.cDangerColor,
                                              fontSize: 12.sp),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Expanded(
                                          child: Center(
                                        child: GestureDetector(
                                          onTap: () {
                                            if (myMoney <
                                                (verifyDetail!['fee'] -
                                                    selectValue)) {
                                              AppGlobal.appRouter?.push(
                                                  CommonUtils.getRealHash(
                                                      'ingotWallet'));
                                            } else {
                                              if (verifyDetail!['status'] ==
                                                  2) {
                                                reservation();
                                              } else {
                                                if (verifyDetail!['status'] ==
                                                    4) {
                                                  showBuy(
                                                      '提示',
                                                      '当前' +
                                                          getType().toString() +
                                                          '已被删除,不能支付预约金哦～',
                                                      2);
                                                }
                                                if (verifyDetail!['status'] ==
                                                    5) {
                                                  showBuy(
                                                      '提示',
                                                      '当前' +
                                                          userCheckStr +
                                                          '不在线,不能支付预约金,请稍后再来吧～',
                                                      2);
                                                }
                                              }
                                            }
                                          },
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                margin: EdgeInsets.only(
                                                    bottom: 10.w),
                                                width: 275.w,
                                                height: 50.w,
                                                child: Stack(
                                                  children: [
                                                    LocalPNG(
                                                        width: 275.w,
                                                        height: 50.w,
                                                        url:
                                                            'assets/images/mymony/money-img.png',
                                                        alignment:
                                                            Alignment.center,
                                                        fit: BoxFit.fill),
                                                    Center(
                                                        child: Text(
                                                      myMoney <
                                                              (verifyDetail![
                                                                      'fee'] -
                                                                  selectValue)
                                                          ? '余额不足,去充值'
                                                          : nowPay,
                                                      style: TextStyle(
                                                          fontSize: 15.sp,
                                                          color: Colors.white),
                                                    ))
                                                  ],
                                                ),
                                              ),
                                              Text(
                                                '支付预约金前，请先沟通价格、服务等信息，未服务请勿点确认',
                                                style: TextStyle(
                                                    color:
                                                        StyleTheme.cDangerColor,
                                                    fontSize: 12.sp),
                                              )
                                            ],
                                          ),
                                        ),
                                      ))
                                    ],
                                  )
                                : youHuiQuan(setBottomSheetState);
                          },
                          itemCount: 2,
                          layout: SwiperLayout.DEFAULT,
                          itemWidth: double.infinity,
                          itemHeight: double.infinity,
                        )),
                    dialogIndex == 1
                        ? Container()
                        : Positioned(
                            top: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop();
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
        }).then((value) => {
          if (value == null) {dialogIndex = 0, selectId = null, selectValue = 0}
        });
  }

  Widget youHuiQuan(Function setBottomSheetState) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                swiperController.move(0);
                setBottomSheetState(() {
                  dialogIndex = 0;
                  selectValue = 0;
                  selectId = null;
                });
              },
              child: Text(
                '取消',
                style: TextStyle(
                  fontSize: 15.sp,
                  color: StyleTheme.cTitleColor,
                ),
              ),
            ),
            Expanded(
                child: Center(
              child: Text(
                '选择优惠券',
                style: TextStyle(
                    fontSize: 18.sp,
                    color: StyleTheme.cTitleColor,
                    fontWeight: FontWeight.w500),
              ),
            )),
            GestureDetector(
              onTap: () {
                swiperController.move(0);
                setBottomSheetState(() {
                  dialogIndex = 0;
                });
              },
              child: Text('确定',
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: StyleTheme.cTitleColor,
                  )),
            )
          ],
        )),
        SlectYouHuiQuan(
            isSelect: selectId,
            setCallBack: (id, value) {
              setBottomSheetState(() {
                selectId = id;
                selectValue = value;
              });
            })
      ],
    );
  }

  Widget rowText(String title, String content, Function callBack,
      [Color? color]) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 14.sp, color: Color(0xFF969693)),
        ),
        color != null
            ? GestureDetector(
                onTap: () {
                  if (int.parse(verifyDetail!['fee'].toString()) < 200) {
                    CommonUtils.showText('预约金大于200才能使用优惠券哦');
                    return;
                  }
                  swiperController.move(1);
                  callBack(() {
                    dialogIndex = 1;
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      content,
                      style: TextStyle(color: color, fontSize: 14.sp),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 5.5.w),
                      width: 15.w,
                      height: 15.w,
                      child: LocalPNG(
                          url: 'assets/images/detail/right-icon.png',
                          width: 15.w,
                          height: 15.w,
                          fit: BoxFit.fill),
                    )
                  ],
                ),
              )
            : Text(
                content,
                style:
                    TextStyle(fontSize: 14.sp, color: StyleTheme.cTitleColor),
              )
      ],
    );
  }

  Widget checkbox(String title, int id, Function callBack) {
    String sleasd = 'select';
    String unn = 'unselect';
    String selectValue = serviceType == id ? sleasd : unn;
    return GestureDetector(
      onTap: () {
        callBack(() {
          serviceType = id;
        });
      },
      child: Container(
        margin: EdgeInsets.only(right: 30.w),
        child: Row(
          children: <Widget>[
            Container(
              width: 15.w,
              height: 15.w,
              margin: EdgeInsets.only(right: 5.5.w),
              child: LocalPNG(
                url: 'assets/images/card/' + selectValue.toString() + '.png',
                width: 15.w,
                height: 15.w,
              ),
            ),
            Text(title)
          ],
        ),
      ),
    );
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

  Widget faceCard() {
    return Container(
      width: 345.w,
      height: 100.w,
      margin: EdgeInsets.only(bottom: 20.w),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Row(
          children: [
            Container(
                width: 95.w,
                height: double.infinity,
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Color(0xffee8589),
                      child: LocalPNG(
                          url: 'assets/images/card/gilr_face.png',
                          width: 90.w,
                          height: double.infinity,
                          fit: BoxFit.fill),
                    ),
                    Center(
                      child: Padding(
                        padding: EdgeInsets.all(10.5.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '小编打分',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 12.sp),
                            ),
                            Text(
                              verifyDetail!['girl_face'].toString(),
                              style: TextStyle(
                                  color: Color(0xffffff96),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 36.sp),
                            ),
                            Text(
                              '女郎颜值',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 12.sp),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                )),
            Expanded(
                child: Container(
              color: Color(0xffee8589),
              width: double.infinity,
              height: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 15.w),
              child: Center(
                child: Container(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '地址：' + verifyDetail!['address'].toString(),
                          style:
                              TextStyle(color: Colors.white, fontSize: 14.sp),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    )),
              ),
            ))
          ],
        ),
      ),
    );
  }

  Widget _scoreCard(item) {
    return Container(
      padding: new EdgeInsets.only(
        left: 15.w,
        right: 15.w,
        bottom: 20.w,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                margin: new EdgeInsets.only(right: 9.5.w),
                child: GestureDetector(
                  onTap: () {
                    AppGlobal.appRouter?.push(CommonUtils.getRealHash(
                        'brokerHomepage/' +
                            item['aff'].toString() +
                            '/' +
                            Uri.encodeComponent(item['thumb'].toString()) +
                            '/' +
                            Uri.encodeComponent(item['nickname'].toString())));
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15.w),
                    child: Container(
                      height: 30.w,
                      width: 30.w,
                      child: Avatar(type: item['thumb'].toString()),
                    ),
                  ),
                ),
              ),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['nickname'].toString(),
                    style: TextStyle(
                      color: StyleTheme.color31,
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(
                    height: 5.5.w,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "${DateUtil.formatDateStr(item['created_str'].toString(), format: DateFormats.y_mo_d)}",
                        style: TextStyle(
                            color: StyleTheme.color153, fontSize: 11.sp),
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
                                padding: EdgeInsets.symmetric(horizontal: 6.w),
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
                      if (item['is_real'] == 1)
                        Padding(
                          padding: EdgeInsets.only(left: 6.w),
                          child: LocalPNG(
                            width: CommonUtils.getWidth(109),
                            height: CommonUtils.getWidth(26),
                            url: 'assets/images/detail/tag-true.png',
                          ),
                        ),
                    ],
                  )
                ],
              ))
            ],
          ),
          if (item['tags'] != null && item['tags'] != '')
            Padding(
              padding: EdgeInsets.only(top: 12.5.w),
              child: Builder(
                builder: (context) {
                  List<String> tags = item['tags'].split(',');
                  return Wrap(
                    spacing: 5.w,
                    runSpacing: 5.w,
                    children: tags.map((e) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: 15.w,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(7.5.w),
                                color: StyleTheme.color253240228),
                            padding: EdgeInsets.symmetric(horizontal: 6.5.w),
                            child: Text(
                              e,
                              style: TextStyle(
                                  fontSize: 10.w,
                                  color: StyleTheme.cDangerColor),
                            ),
                          )
                        ],
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          if (item['desc'] != null && item['desc'] != '')
            Padding(
              padding: EdgeInsets.only(top: 12.w),
              child: Text(
                item['desc'],
                style: TextStyle(color: StyleTheme.color102, fontSize: 14.sp),
              ),
            ),
          if (item['media'] != null && item['media'].isNotEmpty)
            GridView.builder(
              shrinkWrap: true,
              itemCount: item['media'].length,
              padding: EdgeInsets.symmetric(vertical: 11.w),
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 7.5.w,
                  crossAxisSpacing: 7.5.w,
                  childAspectRatio: 1),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    AppGlobal.picMap = {
                      'resources': item['media'],
                      'index': index
                    };
                    context.push('/teaViewPicPage');
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5.w),
                    child: NetImageTool(
                      url: item['media'][index]['media_full_url'],
                    ),
                  ),
                );
              },
            ),
          Padding(
            padding: EdgeInsets.only(top: 9.5.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      verifyDetail!['post_type'] == 2 ? '男模颜值:' : '妹子颜值:',
                      style: TextStyle(
                          fontSize: 14.sp, color: StyleTheme.cTitleColor),
                    ),
                    StarRating(
                      rating: item['girl_face'].toDouble(),
                      disable: true,
                      size: 12.w,
                      spacing: 5.w,
                    )
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    replyItemComment(item['id'], item['nickname']);
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
          ),

          Container(
            margin: new EdgeInsets.only(top: 16.sp),
            child: Row(
              children: [
                Text(
                  '服务质量:',
                  style:
                      TextStyle(fontSize: 14.sp, color: StyleTheme.cTitleColor),
                ),
                StarRating(
                  rating: item['girl_service'].toDouble(),
                  disable: true,
                  size: 12.sp,
                  spacing: 5.sp,
                )
              ],
            ),
          ),
          //二级评论
          if (item['child'] != null && item['child'].isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 2.w),
              margin: EdgeInsets.only(top: 11.5.w),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: StyleTheme.bottomappbarColor),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: (item['child'] as List).map((e) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 7.w),
                    child: Row(
                      children: [
                        Text.rich(
                          TextSpan(text: "${e['nickname']} : ", children: [
                            if (verifyDetail!['aff'] == item['aff'])
                              WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: Align(
                                  alignment: Alignment.center,
                                  widthFactor: 1,
                                  heightFactor: 1,
                                  child: CommonUtils.authorWidget(),
                                ),
                              ),
                            TextSpan(
                                text: "${e['desc']}",
                                style: TextStyle(color: StyleTheme.color102))
                          ]),
                          style: TextStyle(
                              fontSize: 15.sp, color: StyleTheme.color34),
                        )
                      ],
                    ),
                  );

                  // Column(
                  //   crossAxisAlignment: CrossAxisAlignment.start,
                  //   mainAxisSize: MainAxisSize.min,
                  //   children: [
                  //     SizedBox(
                  //       height: 16.w,
                  //     ),
                  //     Row(
                  //       mainAxisSize: MainAxisSize.min,
                  //       children: [
                  //         Container(
                  //           height: 25.w,
                  //           width: 25.w,
                  //           child: Avatar(
                  //             type: e['thumb'],
                  //             radius: 12.5.w,
                  //           ),
                  //         ),
                  //         SizedBox(
                  //           width: 10.w,
                  //         ),
                  //         Text(
                  //           e['nickname'].toString(),
                  //           style: TextStyle(
                  //             color: StyleTheme.cTitleColor,
                  //             fontSize: 16.sp,
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //     Container(
                  //       width: double.infinity,
                  //       margin: new EdgeInsets.only(top: 10.w, left: 35.w, bottom: 10.w),
                  //       padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 15.w),
                  //       decoration:
                  //           BoxDecoration(borderRadius: BorderRadius.circular(5), color: StyleTheme.bottomappbarColor),
                  //       child: Text(
                  //         e['desc'].toString(),
                  //         style: TextStyle(color: Color(0xFF646464), fontSize: 12.sp),
                  //       ),
                  //     ),
                  //     Padding(
                  //       padding: EdgeInsets.only(left: 35.w),
                  //       child: Text(
                  //         CommonUtils.getCgTime(int.parse(e['created_at'].toString())),
                  //         style: TextStyle(
                  //           color: StyleTheme.cBioColor,
                  //           fontSize: 12.sp,
                  //         ),
                  //       ),
                  //     )
                  //   ],
                  // );
                }).toList(),
              ),
            )
        ],
      ),
    );
  }

  Widget _detailHeader() {
    return Container(
      padding: new EdgeInsets.only(
          left: 15.5.w,
          right: 15.w,
          top: 15.w,
          bottom: (verifyDetail!['video_valid'] == 1 ? 0 : 15).w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
              child: Text(
            verifyDetail!['title'].toString(),
            style: TextStyle(
                fontSize: 18.sp,
                color: StyleTheme.cTitleColor,
                fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )),
          GestureDetector(
            onTap: () {
              AppGlobal.appRouter?.push(CommonUtils.getRealHash(
                  'brokerHomepage/' +
                      verifyDetail!['aff'].toString() +
                      '/' +
                      Uri.encodeComponent(verifyDetail!['thumb'].toString()) +
                      '/' +
                      Uri.encodeComponent(
                          verifyDetail!['nickname'].toString())));
            },
            child: Padding(
              padding: EdgeInsets.only(
                top: 7.5.w,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(7.5),
                    child: Container(
                      width: 15.w,
                      height: 15.w,
                      child: Avatar(
                        type: verifyDetail!['thumb'],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 5.5.w,
                  ),
                  Text(
                    verifyDetail!['nickname'].toString(),
                    style: TextStyle(color: Color(0xff646464), fontSize: 12.sp),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 7.5.w),
            child: Row(
              children: [
                verifyDetail!['appointment'] == 0
                    ? Container()
                    : Container(
                        height: 16.w,
                        padding: EdgeInsets.symmetric(horizontal: 7.5.w),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            color: Color(0xffdbc1a0)),
                        child: Center(
                          child: Text(
                            '成交' +
                                verifyDetail!['appointment'].toString() +
                                '单',
                            style:
                                TextStyle(color: Colors.white, fontSize: 11.sp),
                          ),
                        ),
                      ),
                SizedBox(
                  width: 10.w,
                ),
                Container(
                  height: 16.w,
                  padding: EdgeInsets.symmetric(horizontal: 7.5.w),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: Color(0xffdbc1a0)),
                  child: Center(
                    child: Text(
                      '预约金' + verifyDetail!['fee'].toString(),
                      style: TextStyle(color: Colors.white, fontSize: 11.sp),
                    ),
                  ),
                ),
                SizedBox(
                  width: 10.w,
                ),
                verifyDetail!['guaranty'] == null ||
                        verifyDetail!['guaranty'] == 0
                    ? Container()
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          LocalPNG(
                            width: (17.5 * 1.2).w,
                            url: 'assets/images/detail/pei.png',
                            height: (17.5 * 1.2).w,
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
                                  '可赔付押金' +
                                      verifyDetail!['guaranty'].toString() +
                                      '元宝',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 8.sp),
                                ),
                              ))
                        ],
                      )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _dtailList() {
    return Container(
        padding: new EdgeInsets.only(
          right: 15.w,
        ),
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var item in _introductionList!)
                _introductionItem(
                    item['icon'],
                    item['title'],
                    item['introduction'],
                    item['star'] ?? 0,
                    item['type'] ?? false,
                    item['copy'],
                    item['isTag'] ?? false)
            ],
          ),
        ));
  }

  Widget _introductionItem(
      //copy
      String icon,
      String title,
      dynamic introduction,
      double star,
      bool type,
      dynamic copy,
      bool isTag) {
    return GestureDetector(
      onTap: () {
        if (copy != null && type) {
          Clipboard.setData(ClipboardData(text: introduction));
          BotToast.showText(text: '$title 复制成功,快去验证吧～', align: Alignment(0, 0));
        }
      },
      child: Container(
          padding: new EdgeInsets.only(bottom: 16.5.w),
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
              star != 0
                  ? StarRating(
                      rating: star,
                      disable: true,
                      size: 12.sp,
                      spacing: 5.sp,
                    )
                  : Flexible(
                      child: Text(
                        introduction == '' ? '--' : introduction.toString(),
                        style: TextStyle(
                            height: 1.3,
                            fontSize: 14.sp,
                            color: type
                                ? StyleTheme.cTitleColor
                                : StyleTheme.cDangerColor),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
            ],
          )),
    );
  }

  // ignore: unused_element
  Widget _tag(String tag) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          height: 15.w,
          padding: new EdgeInsets.symmetric(horizontal: 6.5.w),
          decoration: BoxDecoration(
              color: Color(0xFFFDF0E4),
              borderRadius: BorderRadius.circular(7.5.w)),
          child: Center(
            child: Text(
              tag,
              style: TextStyle(fontSize: 10.sp, color: StyleTheme.cDangerColor),
            ),
          ),
        )
      ],
    );
  }

  Widget _swiper() {
    var image = verifyDetail!['resources']
        .where((element) => element['type'] != 2)
        .toList();
    return verifyDetail!['resources'] != null &&
            verifyDetail!['resources'].length > 0
        ? Swiper(
            itemBuilder: (BuildContext context, int index) {
              return verifyDetail!['resources'][index]['type'] == 2
                  ? ShortVPlayer(
                      url: verifyDetail!['resources'][index]['url'],
                      cover_url: image[0]['url'],
                    )
                  : GestureDetector(
                      onTap: () {
                        AppGlobal.picMap = {
                          'resources': verifyDetail!['resources'],
                          'index': index
                        };
                        context.push('/teaViewPicPage');
                        // CommonUtils.setStatusBar(isLight: true);
                        // showImageViewer(
                        //   context,
                        //   NetworkImageCRP(
                        //       verifyDetail['resources'][index]['url']),
                        //   useSafeArea: true,
                        //   swipeDismissible: true,
                        //   doubleTapZoomable: true,
                        //   immersive: false,
                        //   onViewerDismissed: () {
                        //     CommonUtils.setStatusBar();
                        //   },
                        // );
                      },
                      child: NetImageTool(
                        url: verifyDetail!['resources'][index]['url'],
                        fit: BoxFit.fitHeight,
                      ),
                    );
            },
            itemCount: verifyDetail!['resources'].length,
            layout: SwiperLayout.DEFAULT,
            duration: 300,
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

  Widget postureInfo(String icon, String title) {
    return Container(
      margin: EdgeInsets.only(right: 20.w, bottom: 18.5.w),
      child: Row(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(right: 3.5.w),
            width: 15.w,
            height: 15.w,
            child: LocalPNG(
                url: icon, width: 15.w, height: 15.w, fit: BoxFit.contain),
          ),
          Text(
            title,
            style: TextStyle(color: Color(0xFF969696), fontSize: 12.sp),
          )
        ],
      ),
    );
  }

  Widget yjTag(String title) {
    int tagValue = title.length > 4 ? 4 : (title.length < 2 ? 2 : title.length);
    return Container(
        margin: EdgeInsets.only(right: 5.w),
        height: 15.w,
        padding: EdgeInsets.symmetric(horizontal: 7.w),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                LocalPNG(
                    url: 'assets/images/card/tag-bg-$tagValue.png',
                    height: 15.w,
                    fit: BoxFit.fill),
                Text(
                  title,
                  style: TextStyle(
                      fontSize: 10.sp, color: StyleTheme.cDangerColor),
                ),
              ],
            ),
          ],
        ));
  }

  Widget newSee() {
    return Container(
      color: StyleTheme.bottomappbarColor,
      padding: new EdgeInsets.only(left: 12.w, right: 18.5.w),
      // margin: new EdgeInsets.only(bottom: 15.w),
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
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text(
                  '如果不满意妹子可以联系茶老板退预约金，消费金额包含预约金，点击右上角“消费须知”了解更多',
                  style: TextStyle(
                      height: 2,
                      color: StyleTheme.cDangerColor,
                      fontSize: 12.sp),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BottomLine extends StatelessWidget {
  const BottomLine({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(
        top: 10.w,
        bottom: 10.w,
      ),
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
