import 'package:bot_toast/bot_toast.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:chaguaner2023/components/avatar_widget.dart';
import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/loading.dart';
import 'package:chaguaner2023/components/page_title_bar.dart';
import 'package:chaguaner2023/components/starrating.dart';
import 'package:chaguaner2023/store/homeConfig.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:chaguaner2023/utils/netimage_tool.dart';
import 'package:chaguaner2023/video/shortv_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../utils/cache/image_net_tool.dart';

class ReportDetailPage extends StatefulWidget {
  final int? id;
  final String? infoId;
  final bool? isDetail;
  ReportDetailPage({Key? key, this.id, this.infoId, this.isDetail = false})
      : super(key: key);
  @override
  State<StatefulWidget> createState() => ReportDetailPageState();
}

class ReportDetailPageState extends State<ReportDetailPage> {
  List _itemList = [];
  List _starList = [];
  bool loading = true;
  bool? isBuy; //是否购买
  int? priceNum; //报告价格
  int freeUnlockNum = 0;
  List? photoAlbum;
  String selectStr = 'select';
  String noselkjsd = 'unselect';
  bool isAgent = false; //是否是鉴茶师
  bool isVideo = false; //是否有视频
  int buyNum = 0;
  bool isCoin = false;
  int resourcesNum = 1;
  dynamic money;
  dynamic coins;
  dynamic max_coin_rate = 0.0;
  dynamic coinsValue = 0;
  Map reportInfo = {
    "nickname": '茶老板',
    "title": '老司机带你飞车',
    "thumb": '',
    "creatTime": '',
    "aff": ''
  };

// 初始化数据
  _getInfo() async {
    var confirmDetail = await getConfirmDetail(widget.id!);
    CommonUtils.debugPrint(confirmDetail);
    if (confirmDetail!['status'] != 0) {
      if (confirmDetail['data']['status'] == 4) {
        Navigator.of(context).pop();
        return BotToast.showText(text: '客官,该报告已被删除～', align: Alignment(0, 0));
      }
      Map data = confirmDetail['data'];
      if (data['userBuy'] == 1 ||
          data['price'] == null ||
          data['price'] == 0 ||
          data['userBuy'] == null) {
        _itemList
          ..add({'title': '妹子花名', 'introduction': data['girl_name']})
          ..add({'title': '品茶时间', 'introduction': data['time']})
          ..add({'title': '所在位置', 'introduction': data['address']})
          ..add({'title': '身高身材', 'introduction': data['girl_body']})
          ..add({'title': '颜值水平', 'introduction': data['girl_face_like']})
          ..add({'title': '胸器罩杯', 'introduction': data['girl_cup']})
          ..add({'title': '服务详情', 'introduction': data['girl_service_detail']});
        _starList
          ..add({'title': '妹子颜值: ', 'star': data['girl_face'].toDouble()})
          ..add({'title': '服务质量: ', 'star': data['girl_service'].toDouble()})
          ..add({'title': '环境设备: ', 'star': data['env'].toDouble()});
      } else {
        //未购买
        _itemList
          ..add({'title': '妹子花名', 'introduction': data['girl_name']})
          ..add({'title': '品茶时间', 'introduction': data['time']})
          ..add({'title': '所在位置', 'introduction': data['address']})
          ..add({'title': '身高身材', 'introduction': data['girl_body']});
      }
      resourcesNum = data['resourcesNum'];
      freeUnlockNum = data['freeUnlockNum'] ?? 0;
      isAgent = (data['agent'] == 4);
      isBuy = (data['userBuy'] == 1 ||
          data['price'] == null ||
          data['price'] == 0 ||
          data['userBuy'] == null);
      photoAlbum = data['photo_album'];
      isVideo = data['video'];
      max_coin_rate = data['max_coin_rate'];
      buyNum = data['buy'] == null ? 0 : data['buy'];
      priceNum = data['price'] ?? 0;
      var exchange_ratio = Provider.of<HomeConfig>(context, listen: false)
              .data['exchange_ratio'] ??
          100;
      coinsValue = (data['price'] ?? 0) * exchange_ratio;
      reportInfo = {
        "nickname": data['nickname'],
        "title": data['title'],
        "thumb": data['thumb'],
        "creatTime": data['created_at'],
        "aff": data['uid']
      };

      loading = false;
      if (photoAlbum != null && photoAlbum!.length > 0) {
        photoAlbum!.sort((e, d) => d['type'] - e['type']);
      }
      setState(() {});
    } else {
      BotToast.showText(text: confirmDetail['msg'], align: Alignment(0, 0));
    }
  }

  //购买
  _buy() {
    if (money < priceNum) {
      showBuy('提示', '您的元宝余额不足,是否去充值?', 1);
    } else {
      _payment();
    }
  }

  _payment() async {
    var result = await userBuyConfirm(
        id: widget.id.toString(),
        useCoin: isCoin && freeUnlockNum == 0 ? 1 : 0);
    if (result!['status'] != 0) {
      BotToast.showText(text: '支持茶友成功～', align: Alignment(0, 0));
      getProfilePage().then((val) {
        if (val!['status'] != 0) {
          Provider.of<HomeConfig>(context, listen: false)
              .setMoney(val['data']['money']);
        }
      });
      _getInfo();
    } else {
      BotToast.showText(text: result['msg'], align: Alignment(0, 0));
    }
  }

  void initState() {
    super.initState();
    _getInfo();
  }

  @override
  Widget build(BuildContext context) {
    money = Provider.of<HomeConfig>(context).member.money;
    coins = Provider.of<HomeConfig>(context).member.coins;
    return HeaderContainer(
        child: Scaffold(
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
          child: PageTitleBar(
            title: '报告详情',
          ),
          preferredSize: Size(double.infinity, 44.w)),
      body: loading
          ? Loading()
          : Container(
              width: double.infinity,
              height: double.infinity,
              child: Column(
                children: [
                  Expanded(
                      child: Stack(
                    children: <Widget>[
                      SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            isBuy!
                                ? photoAlbum!.length != 0
                                    ? Container(
                                        width: double.infinity,
                                        height: 210.w,
                                        color: Color(0xFF646464),
                                        child: _swiper(),
                                      )
                                    : Container()
                                : Container(
                                    width: double.infinity,
                                    height: 210.w,
                                    color: Color(0xFF646464),
                                    child: Stack(
                                      children: <Widget>[
                                        Center(
                                          child: Text(
                                            '付费后可查看图片和视频>',
                                            style: TextStyle(
                                                fontSize: 15.sp,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                        Positioned(
                                            right: 10.w,
                                            bottom: 10.w,
                                            child: Container(
                                              width: 45.w,
                                              height: 20.w,
                                              decoration: BoxDecoration(
                                                  color: Colors.black54,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              child: Center(
                                                child: Text(
                                                  '1/$resourcesNum',
                                                  style: TextStyle(
                                                      fontSize: 14.sp,
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ))
                                      ],
                                    ),
                                  ),
                            Container(
                              padding:
                                  new EdgeInsets.symmetric(horizontal: 15.w),
                              child: Stack(
                                children: <Widget>[
                                  Column(
                                    children: <Widget>[
                                      _header(),
                                      Container(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            for (var item in _itemList)
                                              _detaiItem(item['title'],
                                                  item['introduction']),
                                            for (var star in _starList)
                                              _starItem(
                                                  star['title'], star['star'])
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                  isBuy!
                                      ? Container()
                                      : Positioned(
                                          bottom: 0,
                                          left: 0,
                                          child: Container(
                                            height: 50.w,
                                            width: 1.sw,
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.white,
                                                    Colors.white10
                                                  ],
                                                  begin: Alignment.bottomCenter,
                                                  end: Alignment.topCenter,
                                                )),
                                          ))
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      isBuy!
                          ? Container()
                          : Positioned(
                              top: 0,
                              left: 0,
                              bottom: 0,
                              right: 0,
                              child: Container(
                                color: Colors.transparent,
                              ))
                    ],
                  )),
                  isBuy!
                      ? Container()
                      : Container(
                          height: 150.w,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  '验证不易，支持' + priceNum.toString() + '元宝查看全部',
                                  style: TextStyle(
                                      fontSize: 15.sp,
                                      color: Color(0xff5584e3)),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    if (freeUnlockNum > 0) {
                                      showBuy(
                                          '免费解锁',
                                          Text.rich(
                                            TextSpan(
                                              text: '剩余',
                                              children: [
                                                TextSpan(
                                                  text: '$freeUnlockNum次',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: StyleTheme
                                                          .cDangerColor),
                                                ),
                                                TextSpan(text: '免费解锁,是否使用?')
                                              ],
                                            ),
                                            style: TextStyle(
                                                fontSize: 14.sp,
                                                color: StyleTheme.cTitleColor),
                                          ),
                                          0);
                                      return;
                                    }
                                    ;
                                    showBuy(
                                        '确认打赏',
                                        Column(
                                          children: [
                                            Text.rich(TextSpan(
                                              text: '支持茶友需要支付',
                                              children: [
                                                TextSpan(
                                                  text: priceNum.toString(),
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14.sp,
                                                      color: StyleTheme
                                                          .cDangerColor),
                                                ),
                                                TextSpan(
                                                    text: '元宝,是否确认打赏',
                                                    style: TextStyle(
                                                        fontSize: 14.sp,
                                                        color: StyleTheme
                                                            .cTitleColor))
                                              ],
                                              style: TextStyle(
                                                  fontSize: 14.sp,
                                                  color:
                                                      StyleTheme.cTitleColor),
                                            )),
                                            Visibility(
                                                visible: max_coin_rate == 1,
                                                child: StatefulBuilder(builder:
                                                    (context, sheetSetState) {
                                                  return GestureDetector(
                                                      behavior: HitTestBehavior
                                                          .translucent,
                                                      onTap: () {
                                                        sheetSetState(() {
                                                          isCoin = !isCoin;
                                                        });
                                                      },
                                                      child: Center(
                                                          child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Text(
                                                            '使用$coinsValue铜钱抵扣$priceNum元宝',
                                                            style: TextStyle(
                                                                fontSize:
                                                                    14.sp),
                                                          ),
                                                          SizedBox(
                                                            width: 5.w,
                                                          ),
                                                          LocalPNG(
                                                            url:
                                                                'assets/images/tzyh/${isCoin ? selectStr : noselkjsd}.png',
                                                            width: 14.w,
                                                            fit:
                                                                BoxFit.fitWidth,
                                                          )
                                                        ],
                                                      )));
                                                }))
                                          ],
                                        ),
                                        // '预约妹子需要支付${verifyDetail.fee}元宝，未确认前可全额退款支付前请联系经纪人确认见面细节',
                                        0);
                                    return;
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(top: 20.w),
                                    width: 275.w,
                                    height: 50.w,
                                    child: Stack(
                                      children: [
                                        LocalPNG(
                                            url:
                                                'assets/images/mymony/money-img.png',
                                            width: 275.w,
                                            height: 50.w,
                                            fit: BoxFit.fill),
                                        Center(
                                          child: Text(
                                            freeUnlockNum > 0
                                                ? '免费解锁($freeUnlockNum)'
                                                : '支持茶友',
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
                        ),
                  widget.isDetail!
                      ? Container()
                      : Container(
                          color: StyleTheme.bottomappbarColor,
                          height: ScreenUtil().bottomBarHeight + 49.w,
                          padding: new EdgeInsets.only(
                            bottom: ScreenUtil().bottomBarHeight,
                            left: 15.w,
                            right: 15.w,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  isBuy! ? reportInfo['title'] : '解锁报告后可查看对应资源',
                                  style: TextStyle(
                                      fontSize: 18.sp,
                                      color: StyleTheme.cTitleColor,
                                      fontWeight: FontWeight.w500),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              GestureDetector(
                                  onTap: () {
                                    if (isBuy!) {
                                      AppGlobal.appRouter?.push(
                                          CommonUtils.getRealHash(
                                              'resourcesDetailPage/null/' +
                                                  widget.infoId.toString() +
                                                  '/null/null/null'));
                                    } else {
                                      BotToast.showText(
                                          text: '解锁后才可查看哦～',
                                          align: Alignment(0, 0));
                                    }
                                  },
                                  child: Row(
                                    children: [
                                      Container(
                                          margin:
                                              new EdgeInsets.only(right: 10.w),
                                          child: Text(
                                            '查看茶帖',
                                            style: TextStyle(
                                                fontSize: 15.sp,
                                                color: StyleTheme.cBioColor),
                                          )),
                                      LocalPNG(
                                        url: 'assets/images/detail/right_.png',
                                        height: 15.w,
                                        width: 15.w,
                                      )
                                    ],
                                  ))
                            ],
                          ),
                        )
                ],
              ),
            ),
    ));
  }

  Widget _swiper() {
    var image = photoAlbum!.where((element) => element['type'] != 5).toList();
    return photoAlbum!.length > 0
        ? Swiper(
            itemBuilder: (BuildContext context, int index) {
              return photoAlbum![index]['type'] == 5
                  ? ShortVPlayer(
                      url: photoAlbum![index]['img_url'],
                      cover_url: image[0]['img_url'],
                    )
                  : GestureDetector(
                      onTap: () {
                        AppGlobal.picMap = {
                          'resources': photoAlbum!
                              .map((e) => {'url': e['img_url']})
                              .toList(),
                          'index': index
                        };
                        context.push('/teaViewPicPage');
                      },
                      child: ImageNetTool(
                        url: photoAlbum![index]['img_url'],
                        fit: BoxFit.fitHeight,
                      ),
                    );
            },
            itemCount: photoAlbum!.length,
            layout: SwiperLayout.DEFAULT,
            duration: 300,
            itemWidth: double.infinity,
            itemHeight: 210.w,
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

  // 购买茶帖弹框
  Future<bool?> showBuy(String title, dynamic content, int type) {
    String toPayStr = '确认支付';
    String toChargess = '去充值';
    String ikonwss = '朕知道了';
    String tipss = type == 1 ? toChargess : toPayStr;
    if (freeUnlockNum > 0) {
      tipss = '免费解锁';
    }
    return showDialog<bool>(
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
                                      url: 'assets/images/mymony/money-img.png',
                                      height: 50.w,
                                      width: 110.w,
                                      fit: BoxFit.fill),
                                  Center(
                                      child: Text(
                                    '取消',
                                    style: TextStyle(
                                        fontSize: 15.sp, color: Colors.white),
                                  )),
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            // ignore: missing_return
                            onTap: () {
                              switch (type) {
                                case 0:
                                  Navigator.of(context).pop();
                                  _payment();
                                  break;
                                case 1:
                                  Navigator.of(context).pop();
                                  AppGlobal.appRouter?.push(
                                      CommonUtils.getRealHash('ingotWallet'));
                                  break;
                                case 2:
                                  Navigator.of(context).pop();
                                  break;
                                default:
                              }
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
                                    type != 2 ? tipss : ikonwss,
                                    style: TextStyle(
                                        fontSize: 15.sp, color: Colors.white),
                                  )),
                                ],
                              ),
                            ),
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
                          url: 'assets/images/mymony/close.png',
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

  _header() {
    return Container(
      padding: new EdgeInsets.symmetric(vertical: 15.sp),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: new EdgeInsets.only(right: 10.w),
                height: 30.w,
                width: 30.w,
                child: Avatar(
                  type: reportInfo['thumb'],
                  onPress: () {
                    AppGlobal.appRouter?.push(CommonUtils.getRealHash(
                        'brokerHomepage/' +
                            reportInfo['aff'].toString() +
                            '/' +
                            Uri.encodeComponent(
                                reportInfo['thumb'].toString()) +
                            '/' +
                            Uri.encodeComponent(
                                reportInfo['nickname'].toString())));
                  },
                ),
              ),
              Column(
                mainAxisAlignment: buyNum == 0
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        constraints: BoxConstraints(maxWidth: 150.w),
                        child: Text(
                          reportInfo['nickname'],
                          style: TextStyle(
                              fontSize: 15.sp,
                              color: StyleTheme.cTitleColor,
                              fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      isAgent
                          ? Container(
                              margin: EdgeInsets.only(left: 6.w),
                              height: 17.w,
                              width: 48.w,
                              child: LocalPNG(
                                  height: 17.w,
                                  width: 48.w,
                                  url:
                                      'assets/images/detail/icon-jianchashi.png',
                                  fit: BoxFit.fill),
                            )
                          : Container()
                    ],
                  ),
                  buyNum == 0
                      ? Container()
                      : Text(
                          '$buyNum人支持',
                          style: TextStyle(
                              fontSize: 12.sp, color: StyleTheme.cBioColor),
                        )
                ],
              )
            ],
          ),
          isVideo
              ? Container(
                  child: Container(
                    margin: EdgeInsets.only(left: 7.5.w),
                    alignment: Alignment.center,
                    width: 50.w,
                    height: 20.w,
                    child: LocalPNG(
                      url: 'assets/images/detail/icon-video.png',
                      width: 50.w,
                      height: 20.w,
                    ),
                  ),
                )
              : Container()
        ],
      ),
    );
  }

  _starItem(String title, double star) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
              fontSize: 15.sp, color: StyleTheme.cTitleColor, height: 1.75.w),
        ),
        StarRating(
          rating: star,
          disable: true,
          size: 12.sp,
          spacing: 5.w,
        )
      ],
    );
  }

  _detaiItem(String title, String introduction) {
    return Row(
      children: [
        Expanded(
            child: Text(
          '【' + title + '】:  $introduction',
          style: TextStyle(
              fontSize: 14.sp, color: StyleTheme.cTitleColor, height: 1.75.w),
        ))
      ],
    );
  }
}
