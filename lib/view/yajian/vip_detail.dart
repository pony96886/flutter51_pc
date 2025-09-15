import 'dart:async';
import 'dart:convert';
import 'package:bot_toast/bot_toast.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:chaguaner2023/components/avatar_widget.dart';
import 'package:chaguaner2023/components/cgDialog.dart';
import 'package:chaguaner2023/components/detail_ad.dart';
import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/list/public_list.dart';
import 'package:chaguaner2023/components/loading.dart';
import 'package:chaguaner2023/components/page_title_bar.dart';
import 'package:chaguaner2023/components/starrating.dart';
import 'package:chaguaner2023/components/yy_dialog.dart';
import 'package:chaguaner2023/input/InputDailog.dart';
import 'package:chaguaner2023/store/homeConfig.dart';
import 'package:chaguaner2023/store/sharedPreferences.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/cgprivilege.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/app_global.dart';
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

import '../../utils/cache/image_net_tool.dart';

class VipDetailPage extends StatefulWidget {
  final String? id;
  final String? type;

  VipDetailPage({
    Key? key,
    this.id,
    this.type,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => VipDetailState();
}

class VipDetailState extends State<VipDetailPage> with TickerProviderStateMixin {
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
  bool fullAmount = false; //全额支付
  int truePage = 1;
  bool networkErr = false;
  bool trueIsAll = false;
  bool trueIsLoading = false;
  dynamic _avg;
  int limit = 10;
  GlobalKey _globalKey = GlobalKey();
  bool timeSwitch = true;
  int? id;
  int? selectId;
  int selectValue = 0;
  bool isSelf = false;
  List? _introductionList;
  SwiperController swiperController = new SwiperController();
  List radioList = [
    {'title': '1P 2000', 'id': 0},
    {'title': '2P 5000', 'id': 1},
    {'title': '包夜', 'id': 2}
  ];
  int dialogIndex = 0;
  int serviceType = 0;
  String _null = '';
  bool userPaid = false;
  Map? adData; // 广告数据
  _getInfo() async {
    setState(() {
      networkErr = false;
    });
    var _info = await getVipInfoDetail(widget.id!, type: widget.type == "1" ? 1 : 0);
    print(jsonEncode(_info));
    if (_info!['status'] == null) {
      setState(() {
        networkErr = true;
      });
      return;
    }
    if (_info['status'] != 0) {
      String uid = Provider.of<HomeConfig>(context, listen: false).member.aff!;
      verifyDetail = _info['data'];
      isSelf = verifyDetail!['aff'].toString() == uid;
      verifyDetail = _info['data'];
      userPaid = _info['data']['user_paid'];
      brokerUuid = _info['data']['uuid'];
      brokerAvatar = _info['data']['thumb'];
      brokerName = _info['data']['nickname'];
      isFavorite = _info['data']['userFavorite'] == 1;
      _introductionList = [
        {
          'icon': 'assets/images/detail/icon-postion.png',
          'title': '所在地区',
          'type': true,
          'introduction': verifyDetail!['cityName']
        },
        {
          'icon': 'assets/images/detail/icon-money.png',
          'title': '消费情况',
          'type': true,
          'introduction': (verifyDetail!['price_p'] != 0 ? '1P:' + verifyDetail!['price_p'].toString() + '元,' : _null) +
              (verifyDetail!['price_pp'] != 0 ? '2P:' + verifyDetail!['price_pp'].toString() + '元,' : _null) +
              (verifyDetail!['price_all_night'] != 0
                  ? '包夜:' + verifyDetail!['price_all_night'].toString() + '元'
                  : _null) //
        },
        {
          'icon': 'assets/images/detail/icon-type.png',
          'title': '消费形式',
          'type': true,
          'introduction': verifyDetail!['cast_way'].toString()
        },
        {
          'icon': 'assets/images/detail/icon-time.png',
          'title': '服务项目',
          'type': true,
          'isTag': true,
          'introduction': [for (var item in verifyDetail!['tags']) item['name']]
        }
      ];
      setState(() {});
      List _resources = verifyDetail!['resources'];
      _resources.sort((video, image) {
        return image['type'].compareTo(video['type']);
      });
      setState(() {});
      switch (verifyDetail!['status']) {
        case 4:
          CgDialog.cgShowDialog(
              context, '提示', verifyDetail!['post_type'] == 2 ? '该男模已被经纪人删除～' : '该茶女郎已被经纪人删除～', ['取消', '朕知道了'],
              callBack: () {
            context.pop();
          });

          break;
        case 5:
          CgDialog.cgShowDialog(
              context,
              '提示',
              verifyDetail!['post_type'] == 2 ? '该男模已下线,请返回并下拉刷新列表～' : '该茶女郎已下线,请返回并下拉刷新列表～',
              ['取消', '朕知道了'], callBack: () {
            context.pop();
          });
          break;
        default:
      }
    } else {
      BotToast.showText(text: _info['msg'], align: Alignment(0, 0));
      return context.pop();
    }
  }

  reservation() async {
    AppGlobal.connetGirl = connectGirl;
    await isAppointment(widget.id!, selectId).then((res) {
      if (res!['status'] != 0) {
        getProfilePage().then((val) => {
              if (val!['status'] != 0) {Provider.of<HomeConfig>(context, listen: false).setMoney(val['data']['money'])}
            });
        BotToast.showText(text: '预约成功～', align: Alignment(0, 0));
        context.pop('val');
        context.push(CommonUtils.getRealHash('yuyuesuccess/' +
            verifyDetail!['fee'].toString() +
            '/' +
            selectValue.toString() +
            '/' +
            Uri.encodeComponent(verifyDetail!['title'].toString()) +
            '/' +
            Uri.encodeComponent(verifyDetail!['nickname'].toString()) +
            '/1'));
      } else {
        BotToast.showText(text: res['msg'], align: Alignment(0, 0));
      }
    });
  }

  // 获取广告
  getAd() async {
    var data = await getDetail_ad(601);
    if (data != null) {
      this.setState(() {
        adData = data;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    AppGlobal.connetGirl = null;
    _scrollViewController = ScrollController(initialScrollOffset: 0.0);
    _lottieController = AnimationController(vsync: this);
    _getInfo();
    getAd();
  }

  //收藏
  _collect() async {
    setState(() {
      isFavorite = !isFavorite;
    });
    var favorite = await favoriteVip(widget.id!);
    if (favorite!['status'] != 0) {
      BotToast.showText(text: isFavorite ? '收藏成功' : '取消收藏成功', align: Alignment(0, 0));
      setState(() {
        verifyDetail!['userFavorite'] = isFavorite ? 1 : 0;
        isFavorite = verifyDetail!['userFavorite'] == 1;
      });
    } else {
      setState(() {
        isFavorite = verifyDetail!['userFavorite'] == 1;
      });
      if (favorite['msg'] == 'err') {
        CgDialog.cgShowDialog(context, '温馨提示', '免费收藏已达上限，请前往开通会员', ['取消', '立即前往'], callBack: () {
          AppGlobal.appRouter?.push(CommonUtils.getRealHash('memberCardsPage'));
        });
      } else {
        CommonUtils.showText(favorite['msg']);
      }
    }
  }

  toLlIm() {
    if (brokerUuid != null) {
      var image = verifyDetail!['resources'].firstWhere((v) => v['type'] == 1);
      dynamic imkeys = WebSocketUtility.uuid! + 'ImKey' + brokerUuid;
      PersistentState.saveState(
          '$imkeys',
          (json.encode({
            'type': 'vipOder',
            'image': image['url'],
            'id': verifyDetail!['id'].toString(),
            'price': verifyDetail!['fee'].toString(),
            'title': verifyDetail!['title'],
            'status': verifyDetail!['status'].toString(),
            'priceMin': verifyDetail!['price_p'].toString()
          })));
      AppGlobal.chatUser = FormUserMsg(
          isVipDetail: true,
          uuid: brokerUuid.toString(),
          nickname: brokerName.toString(),
          avatar: brokerAvatar.toString());
      AppGlobal.appRouter?.push(CommonUtils.getRealHash('llchat'));
    } else {
      BotToast.showText(text: '该茶女郎数据出现错误，无法私聊经纪人～', align: Alignment(0, 0));
    }
  }

  @override
  void dispose() {
    _scrollViewController!.dispose();
    _lottieController!.dispose();
    super.dispose();
  }

  Widget _swiper() {
    var image = verifyDetail!['resources'].where((element) => element['type'] != 2).toList();
    return verifyDetail!['resources'] != null && verifyDetail!['resources'].length > 0
        ? Container(
            color: Color(0xFFE5E5E5),
            height: 240.w,
            child: Swiper(
              itemBuilder: (BuildContext context, int index) {
                return verifyDetail!['resources'][index]['type'] == 2
                    ? ShortVPlayer(
                        url: verifyDetail!['resources'][index]['url'],
                        cover_url: image[0]['url'],
                      )
                    : GestureDetector(
                        onTap: () {
                          AppGlobal.picMap = {'resources': verifyDetail!['resources'], 'index': index};
                          context.push('/teaViewPicPage');
                        },
                        child: ImageNetTool(
                          url: verifyDetail!['resources'][index]['url'],
                          fit: BoxFit.fitHeight,
                        ),
                      );
              },
              itemCount: verifyDetail!['resources'].length,
              layout: SwiperLayout.DEFAULT,
              duration: 300,
              itemWidth: CommonUtils.getWidth(750),
              itemHeight: CommonUtils.getWidth(480),
              pagination: SwiperPagination(
                alignment: Alignment.bottomRight,
                builder: new SwiperCustomPagination(builder: (BuildContext context, SwiperPluginConfig config) {
                  return IgnorePointer(
                    child: Container(
                        padding: new EdgeInsets.symmetric(
                          horizontal: CommonUtils.getWidth(26),
                          vertical: CommonUtils.getWidth(7),
                        ),
                        decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(10.0)),
                        child: Text(
                          (config.activeIndex + 1).toString() + '/' + config.itemCount.toString(),
                          style: TextStyle(fontSize: 14.sp, color: Colors.white),
                        )),
                  );
                }),
              ),
            ))
        : Container();
  }

  Widget _detailHeader() {
    return Container(
      padding: new EdgeInsets.only(
          left: CommonUtils.getWidth(31),
          right: 15.w,
          top: 15.w,
          bottom: CommonUtils.getWidth(verifyDetail!['video_valid'] == 1 ? 0 : 30)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
              child: Text(
            verifyDetail!['title'],
            style: TextStyle(fontSize: 18.sp, color: StyleTheme.cTitleColor, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              LocalPNG(
                width: CommonUtils.getWidth(37),
                height: 15.w,
                url: 'assets/images/elegantroom/yuanbao.png',
              ),
              SizedBox(
                width: CommonUtils.getWidth(10),
              ),
              Text('预约金' + verifyDetail!['fee'].toString() + '元宝',
                  style: TextStyle(color: Color(0xFFFF4149), fontSize: 14.sp))
            ],
          ),
        ],
      ),
    );
  }

  Widget girlInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        verifyDetail!['video_valid'] == 1
            ? GestureDetector(
                onTap: () {
                  CgDialog.cgShowDialog(context, '视频认证', '视频认证指茶老板将牛郎织女素颜视频提交官方认证，官方确认人照差距不大后才会有视频认证的标识。', ['知道了']);
                },
                child: Container(
                  child: LocalPNG(
                    url: 'assets/images/card/videorenzheng.png',
                    width: 80.5.w,
                    height: 25.w,
                    fit: BoxFit.fitWidth,
                  ),
                  margin: EdgeInsets.only(
                    left: 10.w,
                    top: 5.w,
                    bottom: 5.w,
                  ),
                ),
              )
            : Container(),
        Container(
          margin: EdgeInsets.only(left: 15.w),
          child: Row(
            children: <Widget>[
              postureInfo('assets/images/detail/vip-icon-age.png',
                  verifyDetail!['girl_age_num'] == null ? '未填写年龄' : verifyDetail!['girl_age_num'].toString() + '岁'),
              postureInfo('assets/images/detail/vip-icon-height.png',
                  verifyDetail!['girl_height'] == null ? '未填写身高' : verifyDetail!['girl_height'].toString() + 'cm'),
              postureInfo(
                  'assets/images/detail/vip-icon-cup.png',
                  verifyDetail!['post_type'] == 2
                      ? verifyDetail!['girl_cup'] + '块腹肌'
                      : CommonUtils.getCup(verifyDetail!['girl_cup'] ?? 1))
            ],
          ),
        ),
        adData != null
            ? Detail_ad(
                data: adData!["data"],
                app_layout: true,
              )
            : Container(),
        newSee(),
      ],
    );
  }

  connectGirl() {
    if (!CgPrivilege.getPrivilegeStatus(PrivilegeType.infoVip, PrivilegeType.privilegeAppointment)) {
      return CgDialog.cgShowDialog(context, '开通会员', '购买会员才能在线预约雅间服务，平台担保交易，照片和人不匹配平台包赔，让你约到合乎心意的嫩模', ['取消', '去开通'],
          callBack: () {
        AppGlobal.appRouter?.push(CommonUtils.getRealHash('memberCardsPage'));
      });
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
  Widget build(BuildContext context) {
    return Consumer<HomeConfig>(
      builder: (_, value, __) {
        money = value.member.money;
        return HeaderContainer(
          child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: PreferredSize(
                  child: PageTitleBar(
                    title: '雅间详情',
                    rightWidget: GestureDetector(
                        onTap: () {
                          if (verifyDetail!['notice'] != null) {
                            String url = Uri.encodeComponent(verifyDetail!['notice']);
                            AppGlobal.appRouter?.push(CommonUtils.getRealHash('webview/' + url + '/消费须知'));
                          }
                        },
                        child: Center(
                          child: Container(
                            margin: new EdgeInsets.only(right: 15.w),
                            child: Text(
                              '消费须知',
                              style: TextStyle(
                                  color: StyleTheme.cTitleColor, fontSize: 15.sp, fontWeight: FontWeight.w500),
                            ),
                          ),
                        )),
                  ),
                  preferredSize: Size(double.infinity, 44.w)),
              // 使用PullToRefreshNotification包裹列表
              body: verifyDetail == null ? Loading() : _buildBody()),
        );
      },
    );
  }

  Widget _buildBody() {
    var agent = Provider.of<HomeConfig>(context).member.agent;
    return Column(
      children: [
        Expanded(
            child: Stack(
          clipBehavior: Clip.none,
          children: [
            PublicList(
              api: '/api/info/getVipInfoConfirm',
              data: {'info_id': widget.id},
              isShow: true,
              isSliver: true,
              noRefresh: true,
              nullText: '还没有评论哦～',
              then: (data) {
                _avg = data['avg'];
                setState(() {});
              },
              sliverHead: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [_swiper(), _detailHeader(), girlInfo(), serverInfo(), _totalScore()],
              ),
              itemBuild: (context, index, data, page, limit, getListData) {
                return _scoreCard(data);
              },
            )
          ],
        )),
        // KySocket.uuid == verifyDetail.uuid ||
        if (!(agent == 1 || widget.type == '1'))
          Container(
            height: 49.w + ScreenUtil().bottomBarHeight,
            padding: new EdgeInsets.only(bottom: ScreenUtil().bottomBarHeight, left: 15.w, right: 15.w),
            color: StyleTheme.bottomappbarColor,
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            if (CgPrivilege.getPrivilegeStatus(
                                PrivilegeType.infoVip, PrivilegeType.privilegeAppointment)) {
                              _collect();
                            } else {
                              CgDialog.cgShowDialog(
                                  context, '开通会员', '购买会员才能在线预约雅间服务，平台担保交易，照片和人不匹配平台包赔，让你约到合乎心意的嫩模', ['取消', '去开通'],
                                  callBack: () {
                                AppGlobal.appRouter?.push(CommonUtils.getRealHash('memberCardsPage'));
                              });
                            }
                          },
                          child: Container(
                            margin: EdgeInsets.only(right: (fullAmount ? 10 : 20).w),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  margin: new EdgeInsets.only(right: (fullAmount ? 0 : 10).w),
                                  child: LocalPNG(
                                    url: isFavorite
                                        ? 'assets/images/card/iscollect.png'
                                        : 'assets/images/mymony/collect.png',
                                    width: 25.w,
                                    height: 25.w,
                                  ),
                                ),
                                fullAmount ? Container() : Text('收藏')
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                            onTap: connectGirl,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  margin: new EdgeInsets.only(right: 10.w),
                                  child: LocalPNG(
                                    url: 'assets/images/detail/chat.png',
                                    width: 25.w,
                                    height: 25.w,
                                  ),
                                ),
                                fullAmount ? Container() : Text('私聊')
                              ],
                            )),
                      ],
                    )
                  ],
                ),
                if (fullAmount)
                  GestureDetector(
                    // ignore: missing_return
                    onTap: () {
                      showPublish(1);
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          width: 110.w,
                          height: 40.w,
                          margin: new EdgeInsets.only(left: 10.w),
                          child: Stack(
                            children: [
                              LocalPNG(
                                width: 110.w,
                                height: 40.w,
                                url: 'assets/images/detail/vip_qezf.png',
                              ),
                              Center(
                                child: Text(
                                  '全额支付',
                                  style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                GestureDetector(
                  // ignore: missing_return
                  onTap: () {
                    if (!CgPrivilege.getPrivilegeStatus(PrivilegeType.infoVip, PrivilegeType.privilegeAppointment)) {
                      CgDialog.cgShowDialog(
                          context, '开通会员', '购买会员才能在线预约雅间服务，平台担保交易，照片和人不匹配平台包赔，让你约到合乎心意的嫩模', ['取消', '去开通'],
                          callBack: () {
                        AppGlobal.appRouter?.push(CommonUtils.getRealHash('memberCardsPage'));
                      });
                      return;
                    }
                    if (verifyDetail!['status'] == 1) {
                      BotToast.showText(text: '该资源正在审核当中,无法下单', align: Alignment(0, 0));
                    }
                    if (verifyDetail!['status'] == 2) {
                      setState(() {
                        myMoney = money;
                      });
                      showPublish(2);
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
                          url: 'assets/images/mymony/money-img.png',
                        ),
                        Center(
                          child: Text(
                            '支付预约金',
                            style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          )
      ],
    );
  }

  Widget serverInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _dtailList(),
        verifyDetail!['desc'] == "" || verifyDetail!['desc'] == null
            ? Container(
                height: 5.w,
                color: Colors.transparent,
              )
            : Container(
                width: double.infinity,
                margin: EdgeInsets.only(
                  right: 15.w,
                  left: 15.w,
                  top: 20.w,
                ),
                color: Color(0xFFF8F8F8),
                padding: new EdgeInsets.symmetric(horizontal: 15.5.w, vertical: 15.w),
                child: Text(
                  verifyDetail!['desc'],
                  style: TextStyle(fontSize: 14.sp, color: StyleTheme.cTitleColor),
                ),
              ),
      ],
    );
  }

  Widget _totalScore() {
    if (_avg == null) return Container();
    String zeross = '0.0';
    String ljsStr = _avg['avg(girl_face)'] == null ? zeross : _avg['avg(girl_face)'].substring(0, 3);
    String avgsd = _avg['avg(girl_service)'] == null ? zeross : _avg['avg(girl_service)'].substring(0, 3);
    return Container(
        height: 53.w,
        margin: new EdgeInsets.only(bottom: 18.5.w),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: StyleTheme.textbgColor1, width: 1.w, style: BorderStyle.solid)),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
                child: Container(
              margin: EdgeInsets.only(left: 15.w),
              child: Text(
                verifyDetail!['confirm'].toString() + '人评价',
                style: TextStyle(fontSize: 18.sp, color: StyleTheme.cTitleColor, fontWeight: FontWeight.bold),
              ),
            )),
            Expanded(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      '颜值 $ljsStr',
                      style: TextStyle(fontSize: 14.sp, color: StyleTheme.cTitleColor),
                    ),
                    Text(
                      '服务 $avgsd',
                      style: TextStyle(fontSize: 14.sp, color: StyleTheme.cTitleColor),
                    ),
                  ],
                ))
          ],
        ));
  }

  Future showPublish(int zfType) {
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
                        padding: EdgeInsets.only(top: CommonUtils.getWidth(40), left: 15.w, right: 15.w),
                        child: Swiper(
                          controller: swiperController,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (BuildContext context, int index) {
                            return index == 0
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        child: Center(
                                            child: Text(
                                          zfType == 1 ? '全额支付' : '支付预约金',
                                          style: TextStyle(
                                              fontSize: 18.sp,
                                              color: StyleTheme.cTitleColor,
                                              fontWeight: FontWeight.w500),
                                        )),
                                      ),
                                      Container(
                                        child: Flex(
                                          direction: Axis.horizontal,
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Expanded(flex: 1, child: Container()),
                                            Expanded(
                                                flex: 2,
                                                child: Container(
                                                  margin: EdgeInsets.only(
                                                    top: 40.w,
                                                  ),
                                                  child: Center(
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        LocalPNG(
                                                          width: CommonUtils.getWidth(76),
                                                          height: CommonUtils.getWidth(54),
                                                          url: 'assets/images/detail/vip-yuanbao.png',
                                                          fit: BoxFit.contain,
                                                        ),
                                                        SizedBox(
                                                          width: CommonUtils.getWidth(22),
                                                        ),
                                                        Text.rich(TextSpan(
                                                            text: (verifyDetail!['fee'] - selectValue).toString(),
                                                            style: TextStyle(
                                                                color: StyleTheme.cTitleColor, fontSize: 36.sp),
                                                            children: [
                                                              TextSpan(
                                                                text: '元宝',
                                                                style: TextStyle(
                                                                    color: StyleTheme.cTitleColor, fontSize: 18.sp),
                                                              )
                                                            ])),
                                                      ],
                                                    ),
                                                  ),
                                                )),
                                            Expanded(
                                                flex: 1,
                                                child: zfType == 2 && selectValue != 0
                                                    ? Container(
                                                        margin: EdgeInsets.only(top: 15.w),
                                                        child: Text(
                                                          verifyDetail!['fee'].toString() + '元宝',
                                                          style: TextStyle(
                                                            color: StyleTheme.cBioColor,
                                                            fontSize: 18.sp,
                                                            decoration: TextDecoration.lineThrough,
                                                            decorationColor: StyleTheme.cBioColor,
                                                          ),
                                                        ),
                                                      )
                                                    : Container()),
                                          ],
                                        ),
                                      ),
                                      Center(
                                        child: Consumer<HomeConfig>(
                                          builder: (context, homeConfig, child) {
                                            return Text(
                                              "账户余额${homeConfig.member.money}元宝",
                                              style: TextStyle(color: StyleTheme.cDangerColor, fontSize: 12.sp),
                                            );
                                          },
                                        ),
                                      ),
                                      SizedBox(
                                        height: zfType == 1 ? 0 : 40.w,
                                      ),
                                      zfType == 1
                                          ? Container(
                                              margin: EdgeInsets.only(
                                                top: CommonUtils.getWidth(29),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  '全额支付，线下无需再给钱！',
                                                  style: TextStyle(
                                                    color: StyleTheme.cBioColor,
                                                    fontSize: 12.sp,
                                                  ),
                                                ),
                                              ),
                                            )
                                          : Container(),
                                      zfType == 1
                                          ? Container(
                                              margin: EdgeInsets.only(top: 15.w, bottom: CommonUtils.getWidth(44)),
                                              child: Text(
                                                '选择消费',
                                                style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 14.sp),
                                              ),
                                            )
                                          : Container(),
                                      zfType == 1
                                          ? Container(
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  for (var item in radioList)
                                                    checkbox(item['title'], item['id'], setBottomSheetState)
                                                ],
                                              ),
                                            )
                                          : Container(),
                                      zfType == 1 ? Container() : BottomLine(),
                                      zfType == 1
                                          ? Container()
                                          : rowText(
                                              '优惠券',
                                              selectValue == 0 ? '选择优惠券' : selectValue.toString() + '元宝优惠券',
                                              setBottomSheetState,
                                              selectValue == 0 ? StyleTheme.cBioColor : StyleTheme.cDangerColor,
                                            ),
                                      BottomLine(),
                                      rowText(verifyDetail!['post_type'] == 2 ? '预约男模' : '预约妹子', verifyDetail!['title'],
                                          setBottomSheetState),
                                      BottomLine(),
                                      rowText('发布用户', verifyDetail!['nickname'], setBottomSheetState),
                                      BottomLine(),
                                      Expanded(
                                          child: Center(
                                        child: GestureDetector(
                                          onTap: () {
                                            if (myMoney < (verifyDetail!['fee'] - selectValue)) {
                                              AppGlobal.appRouter?.push(CommonUtils.getRealHash('ingotWallet'));
                                            } else {
                                              if (verifyDetail!['status'] == 2) {
                                                reservation();
                                              } else {
                                                switch (verifyDetail!['status']) {
                                                  case 4:
                                                    CgDialog.cgShowDialog(
                                                        context,
                                                        '提示',
                                                        verifyDetail!['post_type'] == 2
                                                            ? '当前男模已被经纪人删除,不能支付预约金哦～'
                                                            : '当前茶女郎已被经纪人删除,不能支付预约金哦～',
                                                        ['取消', '朕知道了'],
                                                        callBack: () {});
                                                    break;
                                                  case 5:
                                                    CgDialog.cgShowDialog(
                                                        context,
                                                        '提示',
                                                        verifyDetail!['post_type'] == 2
                                                            ? '当前男模不在线,不能支付预约金,请稍后再来吧～'
                                                            : '当前妹子不在线,不能支付预约金,请稍后再来吧～',
                                                        ['取消', '朕知道了'],
                                                        callBack: () {});
                                                    break;
                                                  default:
                                                }
                                              }
                                            }
                                          },
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                margin: EdgeInsets.only(bottom: CommonUtils.getWidth(20)),
                                                width: CommonUtils.getWidth(550),
                                                height: 50.w,
                                                child: Stack(
                                                  children: [
                                                    LocalPNG(
                                                      width: CommonUtils.getWidth(550),
                                                      height: CommonUtils.getWidth(100),
                                                      url: 'assets/images/mymony/money-img.png',
                                                    ),
                                                    Center(
                                                        child: Text(
                                                      myMoney < (verifyDetail!['fee'] - selectValue)
                                                          ? '余额不足,去充值'
                                                          : _null + '立即支付',
                                                      style: TextStyle(fontSize: 15.w, color: Colors.white),
                                                    )),
                                                  ],
                                                ),
                                              ),
                                              Text(
                                                '支付预约金前，请先和茶老板沟通妹子和服务等',
                                                style: TextStyle(color: StyleTheme.cDangerColor, fontSize: 12.sp),
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
                    Positioned(
                      top: 0,
                      right: 0,
                      child: dialogIndex == 1
                          ? Container()
                          : GestureDetector(
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
                style: TextStyle(fontSize: 18.sp, color: StyleTheme.cTitleColor, fontWeight: FontWeight.w500),
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

  //回复评论
  replyItemComment(_id, String nickname) {
    if (isSelf) {
      reqReply(_id, nickname);
      return;
    }
    if (CgPrivilege.getPrivilegeStatus(PrivilegeType.infoConfirm, PrivilegeType.privilegeComment)) {
      if (userPaid) {
        reqReply(_id, nickname);
      } else {
        YyShowDialog.showdialog(context, title: '提示', btnText: '支付预约金', callBack: () {
          if (verifyDetail!['status'] == 2) {
            setState(() {
              myMoney = money;
            });
            showPublish(2);
          }
        }, content: (setDialogState) {
          return Text(
            '支付预约金并且完成服务后可回复,是否支付预约金？',
            style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 15.sp),
          );
        });
      }
    } else {
      return CommonUtils.showVipDialog(context, PrivilegeType.privilegeCommentString);
    }
  }

  reqReply(_id, String nickname) {
    InputDialog.show(context, '回复给 $nickname', limitingText: 99, btnText: '发送', onSubmit: (value) {
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

  Widget rowText(String title, String content, Function callBack, [Color? color]) {
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
                    SizedBox(
                      width: CommonUtils.getWidth(11),
                    ),
                    LocalPNG(
                      width: 15.w,
                      height: 15.w,
                      url: 'assets/images/detail/right-icon.png',
                    )
                  ],
                ),
              )
            : Text(
                content,
                style: TextStyle(fontSize: 14.sp, color: StyleTheme.cTitleColor),
              )
      ],
    );
  }

  Widget checkbox(String title, int id, Function callBack) {
    String selectStr = 'select';
    String noselectStr = 'unselect';
    String selevtValue = serviceType == id ? selectStr : noselectStr;
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
            LocalPNG(
              width: 15.w,
              height: 15.w,
              url: 'assets/images/card/$selevtValue.png',
            ),
            SizedBox(
              width: CommonUtils.getWidth(11),
            ),
            Text(title)
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
                    AppGlobal.appRouter?.push(CommonUtils.getRealHash('brokerHomepage/' +
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
                        style: TextStyle(color: StyleTheme.color153, fontSize: 11.sp),
                      ),
                      if (item['time_str'] != null && item['time_str'].trim().isNotEmpty)
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
                                    gradient: LinearGradient(
                                        colors: [Color.fromRGBO(255, 144, 0, 1), Color.fromRGBO(255, 194, 30, 1)]),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(6.5.w),
                                      bottomLeft: Radius.circular(6.5.w),
                                      bottomRight: Radius.circular(6.5.w),
                                    )),
                                child: Text(
                                  "${item['time_str']}",
                                  style: TextStyle(color: Color.fromRGBO(248, 253, 255, 1), fontSize: 8.sp),
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
                                borderRadius: BorderRadius.circular(7.5.w), color: StyleTheme.color253240228),
                            padding: EdgeInsets.symmetric(horizontal: 6.5.w),
                            child: Text(
                              e,
                              style: TextStyle(fontSize: 10.w, color: StyleTheme.cDangerColor),
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
                  crossAxisCount: 3, mainAxisSpacing: 7.5.w, crossAxisSpacing: 7.5.w, childAspectRatio: 1),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    AppGlobal.picMap = {'resources': item['media'], 'index': index};
                    context.push('/teaViewPicPage');
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5.w),
                    child: ImageNetTool(
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
                      style: TextStyle(fontSize: 14.sp, color: StyleTheme.cTitleColor),
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
                        style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 12.sp),
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
                  style: TextStyle(fontSize: 14.sp, color: StyleTheme.cTitleColor),
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
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: StyleTheme.bottomappbarColor),
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
                            TextSpan(text: "${e['desc']}", style: TextStyle(color: StyleTheme.color102))
                          ]),
                          style: TextStyle(fontSize: 15.sp, color: StyleTheme.color34),
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

  Widget _dtailList() {
    return Container(
        padding: new EdgeInsets.only(
          left: 15.w,
          right: 15.w,
        ),
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var item in _introductionList!)
                _introductionItem(item['icon'], item['title'], item['introduction'], item['star'], item['type'],
                    item['copy'], item['isTag'])
            ],
          ),
        ));
  }

  Widget _introductionItem(
      //copy
      String icon,
      String title,
      dynamic introduction,
      double? star,
      bool type,
      dynamic copy,
      bool? isTag) {
    return GestureDetector(
      onTap: () {
        if (copy != null && type) {
          Clipboard.setData(ClipboardData(text: introduction));
          BotToast.showText(text: '$title 复制成功,快去验证吧～', align: Alignment(0, 0));
        }
      },
      child: Container(
          padding: new EdgeInsets.only(top: CommonUtils.getWidth(33)),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  padding: new EdgeInsets.only(right: CommonUtils.getWidth(21)),
                  child: LocalPNG(
                    url: icon,
                    width: 15.w,
                    height: 15.w,
                  )),
              Container(
                  padding: new EdgeInsets.only(right: CommonUtils.getWidth(21)),
                  child: Text(
                    title + ':',
                    style: TextStyle(
                        height: 1.3, fontSize: 14.sp, color: type ? StyleTheme.cTitleColor : StyleTheme.cDangerColor),
                  )),
              star != null
                  ? StarRating(
                      rating: star,
                      disable: true,
                      size: 12.sp,
                      spacing: 5.sp,
                    )
                  : (isTag != null
                      ? Expanded(
                          child: Container(
                          margin: EdgeInsets.only(top: CommonUtils.getWidth(2)),
                          child: introduction.length > 0
                              ? Wrap(
                                  spacing: CommonUtils.getWidth(20),
                                  runSpacing: CommonUtils.getWidth(20),
                                  children: <Widget>[for (var item in introduction) yjTag(item)],
                                )
                              : Text('--'),
                        ))
                      : Flexible(
                          child: Text(
                            introduction == '' ? '--' : introduction,
                            style: TextStyle(
                                height: 1.3,
                                fontSize: 14.sp,
                                color: type ? StyleTheme.cTitleColor : StyleTheme.cDangerColor),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ))
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
          padding: new EdgeInsets.symmetric(horizontal: CommonUtils.getWidth(13)),
          decoration:
              BoxDecoration(color: Color(0xFFFDF0E4), borderRadius: BorderRadius.circular(CommonUtils.getWidth(15))),
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

  Widget postureInfo(String icon, String title) {
    return Container(
      margin: EdgeInsets.only(right: CommonUtils.getWidth(40), bottom: CommonUtils.getWidth(37)),
      child: Row(
        children: <Widget>[
          LocalPNG(
            width: 15.w,
            height: 15.w,
            url: icon,
            fit: BoxFit.contain,
          ),
          SizedBox(
            width: CommonUtils.getWidth(7),
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
    dynamic numberSS = title.length > 4 ? 4 : (title.length < 2 ? 2 : title.length);
    return Container(
      margin: EdgeInsets.only(right: CommonUtils.getWidth(10)),
      height: 15.w,
      child: Stack(
        children: [
          LocalPNG(
            height: 15.w,
            url: 'assets/images/card/tag-bg-' + numberSS.toString() + '.png',
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: CommonUtils.getWidth(14)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(fontSize: 10.sp, color: StyleTheme.cDangerColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget newSee() {
    return Container(
      color: StyleTheme.bottomappbarColor,
      padding: new EdgeInsets.only(left: CommonUtils.getWidth(24), right: CommonUtils.getWidth(37)),
      // margin: new EdgeInsets.only(bottom: 15.w),
      height: CommonUtils.getWidth(140),
      child: Row(
        children: [
          Container(
              margin: new EdgeInsets.only(right: CommonUtils.getWidth(23)),
              child: LocalPNG(
                url: 'assets/images/detail/new-look.png',
                width: CommonUtils.getWidth(87),
              )),
          Container(
            width: CommonUtils.getWidth(2),
            height: CommonUtils.getWidth(40),
            color: Color(0xFFE3AB78),
            margin: new EdgeInsets.only(right: CommonUtils.getWidth(23)),
          ),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text(
                  '如果不满意可以联系茶老板退预约金，消费金额包含预约金，点击右上角“消费须知”了解更多',
                  style: TextStyle(height: 2, color: StyleTheme.cDangerColor, fontSize: 12.sp),
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
        top: CommonUtils.getWidth(20),
        bottom: CommonUtils.getWidth(20),
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
