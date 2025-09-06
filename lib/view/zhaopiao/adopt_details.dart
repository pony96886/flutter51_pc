import 'dart:async';
import 'package:bot_toast/bot_toast.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:chaguaner2023/components/cgDialog.dart';
import 'package:chaguaner2023/components/detail_ad.dart';
import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/loading.dart';
import 'package:chaguaner2023/components/networkErr.dart';
import 'package:chaguaner2023/components/pagetitlebar.dart';
import 'package:chaguaner2023/store/homeConfig.dart';
import 'package:chaguaner2023/store/sharedPreferences.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/index.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:chaguaner2023/utils/netimage_tool.dart';
import 'package:chaguaner2023/video/shortv_player.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';

import '../../utils/cache/image_net_tool.dart';

class AdoptDetailPage extends StatefulWidget {
  final String id;

  AdoptDetailPage({Key? key, required this.id}) : super(key: key);

  @override
  State<StatefulWidget> createState() => AdoptDetailPageState();
}

class AdoptDetailPageState extends State<AdoptDetailPage> with TickerProviderStateMixin {
  ScrollController? _scrollViewController;
  // ignore: unused_field
  int _selectedTabIndex = 0;

  // userBuy 0未购买1已购买2已验证
  // favorite 0未收藏1收藏
  bool isFavorite = false;
  dynamic money; //元宝
  bool isCoin = false;
  bool loading = true;
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
  bool alreadyBuy = false;
  int limit = 10;
  int userBuyState = 0; //0 正常 1 铜钱解锁使用元宝解锁余额不足时
  GlobalKey _infoGlobalKey = GlobalKey();
  GlobalKey _cardGlobalKey = GlobalKey();
  List<double> widgetHeight = [1000, 1000, 1000];
  bool falseSwich = true;
  bool trueSwich = true;
  double cardHeight = 300;
  String beforeText = '';
  String marqueeText = '';

  int? id;
  List? _introductionList;

  //获取茶帖详情
  _getInfo() async {
    networkErr = false;
    setState(() {});
    Map? _info;
    _info = await getAdoptDetail(widget.id);
    if (_info!['data'] == null || (_info['data'] is List && _info['data'].isEmpty)) {
      String teaError = "包养状态错误～，或正在审核中";
      BotToast.showText(
          text: _info['msg'] == null || _info['msg'] == '' ? teaError : _info['msg'], align: Alignment(0, 0));
      Navigator.of(context).pop();
      return;
    }
    if (_info['status'] != 0) {
      verifyDetail = _info['data'];
      String? aff = Provider.of<HomeConfig>(context, listen: false).member.aff;
      isSelf = verifyDetail!['user'] == null ? false : verifyDetail!['user']['aff'].toString() == aff;
      beforeText = verifyDetail!['created_at'];
      isFavorite = _info['data']['is_favorited'];
      alreadyBuy = verifyDetail!['is_buy'] == null ? false : verifyDetail!['is_buy'];
      final tips = (verifyDetail?['tips'] ?? '').toString().replaceAll('\n', '').replaceAll('\r', '');
      marqueeText = tips.isEmpty ? '' : '温馨提示：$tips';
    }
    _introductionList = [
      {'title': '所在城市', 'introduction': verifyDetail!['city_name']},
      {'title': "罩杯", 'introduction': verifyDetail!['cup_str']},
      {'title': '颜值自评', 'introduction': verifyDetail!['self_assessment']},
      {'title': '职业说明', 'introduction': verifyDetail!['job']},
      {'title': '学历介绍', 'introduction': verifyDetail!['education']},
      {'title': '姨妈时间', 'introduction': verifyDetail!['aunt_time']},
      {'title': '是否整容', 'introduction': verifyDetail!['is_plastic_surgery_str']},
      {'title': '是否处女', 'introduction': verifyDetail!['virginity_str']},
      {'title': '是否过夜', 'introduction': verifyDetail!['can_stay_overnight_str']},
      {'title': '可否同居', 'introduction': verifyDetail!['can_live_together_str']},
      {'title': '可否口交', 'introduction': verifyDetail!['sex_allowed_str']},
      {'title': '可否SM', 'introduction': verifyDetail!['sm_allowed_str']},
      {'title': '可否内射', 'introduction': verifyDetail!['internal_ejaculation_allowed_str']},
      {'title': '是否纹身或吸烟', 'introduction': verifyDetail!['smoke_or_tattoo']},
      {'title': '雷点（不能接受）', 'introduction': verifyDetail!['thunder_point']},
      {'title': '月可陪伴天数', 'introduction': verifyDetail!['monthly_companion_day'].toString()},
      {'title': '最快见面时间', 'introduction': verifyDetail!['fastest_meet_time']},
      {'title': '可否飞往外省', 'introduction': verifyDetail!['fly_to_other_province']},
      {'title': '可否出国（有护照或港澳通行证）', 'introduction': verifyDetail!['can_go_abroad']},
      {'title': '妹子费用', 'introduction': verifyDetail!['girl_price']?.toString() ?? '--'},
      {
        'title': '费用分期次数',
        'last': true, //最后一条
        'introduction': verifyDetail!['number_of_payment_times']
      }
    ];
    setState(() {
      loading = false;
    });
  }

  //收藏
  _collect() async {
    String collectStr = '收藏成功';
    String cancleColStr = '取消收藏成功';
    isFavorite = !isFavorite;
    setState(() {});
    Map favorite = await onSubmitFavorite(widget.id);
    if (favorite['status'] != 0) {
      BotToast.showText(text: isFavorite ? collectStr : cancleColStr, align: Alignment(0, 0));
      verifyDetail!['favorite'] = isFavorite ? 1 : 0;
      isFavorite = verifyDetail!['favorite'] == 1;
      setState(() {});
    } else {
      isFavorite = verifyDetail!['favorite'] == 1;
      setState(() {});
      if (favorite['msg'] == 'err') {
        CgDialog.cgShowDialog(context, '温馨提示', '免费收藏已达上限，请前往开通会员', ['取消', '立即前往'], callBack: () {
          AppGlobal.appRouter?.push(CommonUtils.getRealHash('memberCardsPage'));
        });
      } else {
        CommonUtils.showText(favorite['msg']);
      }
    }
  }

  _getHeight(_) {
    if (_cardGlobalKey.currentContext != null && cardHeight != _cardGlobalKey.currentContext!.size!.height) {
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
    _getInfo();
    getAd();
  }

  @override
  void dispose() {
    _scrollViewController?.dispose();
    EventBus().off('girlStatusChange');
    super.dispose();
  }

  Future<String?> _showModalBottomSheet() {
    return showModalBottomSheet<String>(
      context: context,
      builder: (BuildContext context) {
        return Container(
            height: 280.w,
            color: Colors.white,
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15.w),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '预约妹子',
                              style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 14.sp),
                            ),
                            Text(
                              verifyDetail?['girl_name'],
                              style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 14.sp),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              '所需元宝',
                              style: TextStyle(
                                  height: 2, fontSize: 14.sp, decorationColor: Color(0xff969696), color: Colors.black),
                            ),
                            Expanded(child: SizedBox()),
                            Text(
                              '${verifyDetail?['fee']}元宝',
                              style: TextStyle(
                                  height: 2, fontSize: 14.sp, decorationColor: Color(0xff969696), color: Colors.black),
                            ),
                            SizedBox(width: 5.w),
                            LocalPNG(
                                width: 36, height: 27, url: 'assets/images/detail/yuanbao.png', fit: BoxFit.contain),
                          ],
                        ),
                        Consumer<HomeConfig>(
                          builder: (context, homeConfig, child) {
                            return Text(
                              "账户余额${homeConfig.member.money}元宝",
                              style: TextStyle(color: StyleTheme.cDangerColor, fontSize: 12.sp),
                            );
                          },
                        ),
                        GestureDetector(
                          onTap: () {
                            if (userBuyState == 1) {
                              AppGlobal.appRouter?.push(CommonUtils.getRealHash('ingotWallet'));
                            } else {
                              onSubmit();
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
                                  url: 'assets/images/mymony/money-img.png',
                                ),
                                Center(
                                  child: Text(
                                    "立即支付",
                                    style: TextStyle(color: Colors.white, fontSize: 15.sp),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
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

  onSubmit() async {
    try {
      var result = await getAdoptOrder(widget.id);
      if (result!['status'] != 0) {
        BotToast.showText(text: result['msg'] + '请联系客服进行预约', align: Alignment(0, 0));
        setState(() {
          verifyDetail?['is_buy'] = true;
          alreadyBuy = true;
          loading = true;
        });
        getProfilePage().then((val) {
          if (val!['status'] != 0) {
            Provider.of<HomeConfig>(context, listen: false).setCoins(val['data']['coin']);
            Provider.of<HomeConfig>(context, listen: false).setMoney(val['data']['money']);
          }
        });
        _getInfo();
      } else {
        BotToast.showText(text: result['msg'], align: Alignment(0, 0));
      }
    } catch (e) {
      BotToast.showText(text: "${e}", align: Alignment(0, 0));
    }
  }

  onCheckBuyStatus() {
    if (verifyDetail?['is_buy'] == false) {
      if (verifyDetail?['is_other_user_buy']) {
        CommonUtils.showText("宝贝已经被包养");
      } else {
        if (alreadyBuy) {
          CommonUtils.showText("宝贝被您包养");
        } else {
          _showModalBottomSheet();
        }
      }
    } else {
      AppGlobal.appRouter?.push(CommonUtils.getRealHash('onlineServicePage'));
    }
  }

  String checkBuyText() {
    String text = '立即预约';
    if (verifyDetail?['is_buy'] == false) {
      if (verifyDetail?['is_other_user_buy']) {
        text = '已经被包养';
      } else {
        text = '立即预约';
      }
    } else {
      text = '联系客服';
    }
    return text;
  }

  String checkBuyTextImage() {
    String images = 'assets/images/mymony/money-img.png';
    if (verifyDetail?['is_buy'] == false) {
      if (verifyDetail?['is_other_user_buy']) {
        images = 'assets/images/detail/hui-bg.png';
      } else {
        images = 'assets/images/mymony/money-img.png';
      }
    } else {
      images = 'assets/images/mymony/money-img.png';
    }
    return images;
  }

  @override
  Widget build(BuildContext context) {
    verifyDetail?['guaranty'] = verifyDetail?['guaranty'] == null ? 0 : verifyDetail?['guaranty'];
    return Consumer<HomeConfig>(
      builder: (_, value, __) {
        coins = value.member.coins;
        money = value.member.money;
        String iscolStr = 'assets/images/card/iscollect.png';
        String collectStrr = 'assets/images/mymony/collect.png';
        return HeaderContainer(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: PreferredSize(
                child: PageTitleBar(
                  title: '包养详情',
                  rightWidget: GestureDetector(
                    onTap: () {
                      if (alreadyBuy) {
                        CommonUtils.routerTo('adoptComplainpage', extra: {'id': widget.id});
                      } else {
                        CommonUtils.showText("包养后才可投诉");
                      }
                    },
                    child: Text(
                      "投诉",
                      style: TextStyle(color: StyleTheme.cDangerColor, fontSize: 15.sp),
                    ),
                  ),
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
                          marqueeText.isNotEmpty
                              ? Container(
                                  color: Color(0xFFFDF0E4),
                                  width: 1.sw,
                                  height: 25.w,
                                  child: new Marquee(
                                    text: marqueeText,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    blankSpace: 20.0,
                                    startPadding: 10.0,
                                    style: new TextStyle(color: Color(0xFFFF4149), fontSize: 12.sp),
                                    scrollAxis: Axis.horizontal,
                                  ),
                                )
                              : SizedBox(),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  Container(
                                    color: Colors.white,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        verifyDetail?['images'] != null && verifyDetail?['images'].length > 0
                                            ? Container(color: Color(0xFFE5E5E5), height: 240.w, child: _swiper())
                                            : Container(),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            _detailHeader(),
                                            SizedBox(height: 10),
                                            adData != null
                                                ? Detail_ad(app_layout: true, data: adData?["data"])
                                                : Container(),
                                            newbieSee(),
                                          ],
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 15.w),
                                          child: LocalPNG(
                                              width: 62.w,
                                              height: 21.w,
                                              url: 'assets/images/video_auth.png',
                                              fit: BoxFit.cover),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(15.w),
                                          child: Text(
                                            '基本信息',
                                            style: TextStyle(
                                                color: StyleTheme.cTitleColor,
                                                fontSize: 18.sp,
                                                fontWeight: FontWeight.w700),
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.symmetric(horizontal: 15.w),
                                          padding: EdgeInsets.symmetric(vertical: 14.5.w, horizontal: 15.w),
                                          decoration: BoxDecoration(
                                              color: Color(0xFFF8F8F8), borderRadius: BorderRadius.circular(10)),
                                          child: Container(
                                              key: _infoGlobalKey,
                                              child: Container(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    for (var item in _introductionList!)
                                                      _introductionItem(item['title'], item['introduction'],
                                                          item['last'] == null ? false : item['last'])
                                                  ],
                                                ),
                                              )),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(15.w),
                                          child: Text(
                                            '详细介绍',
                                            style: TextStyle(
                                                color: StyleTheme.cTitleColor,
                                                fontSize: 18.sp,
                                                fontWeight: FontWeight.w700),
                                          ),
                                        ),
                                        Container(
                                            margin: EdgeInsets.symmetric(horizontal: 15.w),
                                            padding: EdgeInsets.symmetric(vertical: 14.5.w, horizontal: 15.w),
                                            decoration: BoxDecoration(
                                                color: Color(0xFFF8F8F8), borderRadius: BorderRadius.circular(10)),
                                            child: Text(
                                              verifyDetail!['description'],
                                              style: TextStyle(
                                                  height: 1.3, fontSize: 14.sp, color: StyleTheme.cTitleColor),
                                            )),
                                        SizedBox(height: 30.w)
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            height: 49.w + (verifyDetail!['status'] == 4 ? 30 : 0) + ScreenUtil().bottomBarHeight,
                            padding: new EdgeInsets.only(bottom: ScreenUtil().bottomBarHeight, left: 15.w, right: 15.w),
                            color: StyleTheme.bottomappbarColor,
                            width: double.infinity,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    GestureDetector(
                                        onTap: () {
                                          _collect();
                                        },
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              margin: new EdgeInsets.only(right: 10.w),
                                              child: LocalPNG(
                                                url: isFavorite ? iscolStr : collectStrr,
                                                width: 25.w,
                                                height: 25.w,
                                              ),
                                            ),
                                            Text('收藏')
                                          ],
                                        )),
                                    GestureDetector(
                                      onTap: () {
                                        AppGlobal.appRouter?.push(CommonUtils.getRealHash('shareQRCodePage'));
                                      },
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            margin: new EdgeInsets.only(left: 20.w, right: 10.w),
                                            child: LocalPNG(
                                              url: 'assets/images/detail/share-icon.png',
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
                                    GestureDetector(
                                      onTap: () {
                                        onCheckBuyStatus();
                                      },
                                      child: SizedBox(
                                          width: 175.w,
                                          height: 40.w,
                                          child: Stack(
                                            children: [
                                              LocalPNG(
                                                url: checkBuyTextImage(),
                                                width: 175.w,
                                                height: 40.w,
                                                fit: BoxFit.fitHeight,
                                              ),
                                              Center(
                                                child: Text(
                                                  checkBuyText(),
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14.sp,
                                                      fontWeight: FontWeight.w500),
                                                ),
                                              )
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
        );
      },
    );
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

  Widget _detailHeader() {
    return Container(
      padding: new EdgeInsets.only(
        left: 15.5.w,
        top: 15.w,
        right: 15.5.w
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
              child: Text(
            verifyDetail!['girl_name'],
            style: TextStyle(fontSize: 18.sp, color: StyleTheme.cTitleColor, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // LocalPNG(
              //   url: 'assets/images/detail/yuabao2.png',
              //   width: 20.w,
              //   height: 20.w,
              // ),
              SizedBox(width: 5.w),
              Text(
                verifyDetail!['fee'] !=0 ? '预约金${verifyDetail!['fee']}元宝' : '',
                style: TextStyle(fontSize: 12.sp, color: StyleTheme.cDangerColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _introductionItem(
      //copy
      String title,
      String introduction,
      bool isLast) {
    return Container(
        padding: new EdgeInsets.only(bottom: isLast ? 0 : 15.w),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                padding: new EdgeInsets.only(right: 10.5.w),
                child: Text(
                  title + ':',
                  style: TextStyle(height: 1.3, fontSize: 14.sp, color: StyleTheme.cTitleColor),
                )),
            Flexible(
              child: Text(
                introduction == '' ? '--' : introduction,
                style: TextStyle(height: 1.3, fontSize: 14.sp, color: StyleTheme.cTitleColor),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            )
          ],
        ));
  }

  Widget _swiper() {
    List images = [];
    if (verifyDetail!['video'] != null && verifyDetail!['video'].length > 0) {
      images.add({
        'media_url': verifyDetail!['video']['media_url'],
        'cover': verifyDetail!['video']['cover'],
        'type': 'video'
      });
    }
    if (verifyDetail!['images'] != null && verifyDetail!['images'].length > 0) {
      images.addAll(verifyDetail!['images']);
    }

    return images != null && images.length > 0
        ? Swiper(
            itemBuilder: (BuildContext context, int index) {
              return images[index]['type'] == 'video'
                  ? ShortVPlayer(
                      url: images[index]['media_url'],
                      cover_url: images[index]['cover'],
                    )
                  : GestureDetector(
                      onTap: () {
                        AppGlobal.picMap = {'resources': verifyDetail!['images'], 'index': index};
                        context.push('/adoptViewPicPage');
                      },
                      child: ImageNetTool(
                        url: images[index]['media_url'],
                        fit: BoxFit.fitHeight,
                      ));
            },
            itemCount: images.length,
            autoplay: false,
            loop: true,
            layout: SwiperLayout.DEFAULT,
            duration: 400,
            itemWidth: 375.w,
            itemHeight: 240.w,
            pagination: SwiperPagination(
              alignment: Alignment.bottomRight,
              builder: new SwiperCustomPagination(builder: (BuildContext context, SwiperPluginConfig config) {
                return Container(
                    padding: new EdgeInsets.symmetric(
                      horizontal: 13.w,
                      vertical: 3.5.w,
                    ),
                    decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(10.0)),
                    child: Text(
                      (config.activeIndex + 1).toString() + '/' + config.itemCount.toString(),
                      style: TextStyle(fontSize: 14.sp, color: Colors.white),
                    ));
              }),
            ),
          )
        : Container();
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
                  style: TextStyle(height: 2, color: StyleTheme.cTitleColor, fontSize: 12.sp),
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
