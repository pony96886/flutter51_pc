import 'dart:async';
import 'dart:io';
import 'package:chaguaner2023/components/VerticalModalSheet.dart';
import 'package:chaguaner2023/components/cgDialog.dart';
import 'package:chaguaner2023/components/page_title_bar.dart';
import 'package:chaguaner2023/components/popupbox.dart';
import 'package:chaguaner2023/mixins/pay_mixin.dart';
import 'package:chaguaner2023/store/global.dart';
import 'package:chaguaner2023/store/sharedPreferences.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:chaguaner2023/utils/sp_keys.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MemberCardsPage extends StatefulWidget {
  @override
  State<MemberCardsPage> createState() => MemberCardsPageState();
}

class MemberCardsPageState extends State<MemberCardsPage> with PayMixin {
  BackButtonBehavior backButtonBehavior = BackButtonBehavior.none;
  Timer? _timer;
  int _countdownTime = 86400;
  String _countdownTips = "00:00:00";
  List products = [];
  List channels = [];
  List libaoProducts = [];
  Function? closeShow;
  int currentVipValue = 0;
  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      PersistentState.getState('ZhiFu').then((value) => {
            if (Platform.isAndroid && value == null)
              {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  VerticalModalSheet.show(
                    context: context,
                    isBtnClose: false,
                    closeShow: (e) {
                      closeShow = e;
                    },
                    child: Container(
                      color: Colors.white,
                      padding: EdgeInsets.only(bottom: 15.w),
                      child: Column(
                        children: <Widget>[
                          LocalPNG(
                            width: double.infinity,
                            url: 'assets/images/android-zhifu.png',
                          ),
                          Container(
                            child: GestureDetector(
                              onTap: () {
                                closeShow!();
                                PersistentState.saveState('ZhiFu', '1');
                              },
                              child: Container(
                                margin: new EdgeInsets.only(top: 15.w),
                                height: 50.w,
                                width: 200.w,
                                child: Stack(
                                  children: [
                                    LocalPNG(
                                      height: 50.w,
                                      width: 200.w,
                                      url: 'assets/images/mymony/money-img.png',
                                      fit: BoxFit.fill,
                                    ),
                                    Center(
                                        child: Text(
                                      '我知道了',
                                      style: TextStyle(fontSize: 15.sp, color: Colors.white),
                                    )),
                                  ],
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    direction: VerticalModalSheetDirection.TOP,
                  );
                })
              }
          });
    }

    getProductListOfCard(1).then((res) {
      products = res!['data']['product'];
      channels = res['data']['channel'];
      currentVipValue = res['data']['vip_value'];
      setState(() {});
    });
    initShared();
    startCountdownTimer();
  }

  @override
  void dispose() {
    _timer!.cancel();
    super.dispose();
  }

  initShared() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String insTi = SpKeys.installTime;
    bool checkValue = prefs.containsKey('$insTi');
    if (checkValue) {
      getCountDown();
    } else {
      String timestamp = new DateTime.now().millisecondsSinceEpoch.toString();
      prefs.setString('${SpKeys.installTime}', timestamp);
    }
  }

  getCountDown() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var installtimestamp =
        new DateTime.fromMillisecondsSinceEpoch(int.parse(prefs.getString('${SpKeys.installTime}')!));
    var current = new DateTime.now().difference(installtimestamp);
    if (['', null, false].contains(installtimestamp)) {
    } else {
      setState(() {
        _countdownTime = _countdownTime - current.inSeconds;
      });
    }
  }

  void startCountdownTimer() async {
    const oneSec = const Duration(seconds: 1);
    checktime(i) {
      if (i < 10) {
        i = "0" + i.toString();
      }
      return i.toString();
    }

    var callback = (timer) => {
          setState(() {
            if (_countdownTime < 1) {
              _timer!.cancel();
              _countdownTime = 0;
              _countdownTips = "00:00:00";
            } else {
              num hours = num.parse((_countdownTime ~/ 3600).toStringAsFixed(0));
              num minutes = num.parse((_countdownTime ~/ 60 % 60).toStringAsFixed(0));
              num seconds = num.parse((_countdownTime % 60).toStringAsFixed(0));
              String tipscount = checktime(hours) + ":" + checktime(minutes) + ":" + checktime(seconds);
              _countdownTips = tipscount;
              --_countdownTime;
            }
          })
        };

    _timer = Timer.periodic(oneSec, callback);
  }

  Map getImageSet(int vipLevel, int temp) {
    if (vipLevel == 1 && temp == 0) {
      //白银
      return {'bg': 'assets/images/member/silvernew.png', 'logo': 'assets/images/member/silver-logo.png', 'text': '月卡'};
    } else if (vipLevel == 2 && temp == 0) {
      //黄金
      return {'bg': 'assets/images/member/goldnew.png', 'logo': 'assets/images/member/gold-logo.png', 'text': '季卡'};
    } else if (vipLevel == 3 && temp == 0) {
      //钻石
      return {
        'bg': 'assets/images/member/diamondnew.png',
        'logo': 'assets/images/member/diamond-logo.png',
        'text': '年卡'
      };
    } else if (vipLevel == 3 && temp == 1) {
      //钻石体验
      return {
        'bg': 'assets/images/member/zuanshi-tiyan.png',
        'logo': 'assets/images/member/diamond-logo.png',
        'text': '周卡'
      };
    } else if (vipLevel == 4 && temp == 0) {
      //璀璨
      return {'bg': 'assets/images/member/cuican.png', 'logo': 'assets/images/member/diamond-logo.png', 'text': '永久'};
    } else if (vipLevel == 5 && temp == 0) {
      //至尊
      return {'bg': 'assets/images/member/zhizun.png', 'logo': 'assets/images/member/zhizun-logo.png', 'text': '永久'};
    } else {
      return {'bg': 'assets/images/member/cuican.png', 'logo': 'assets/images/member/diamond-logo.png', 'text': '永久'};
    }
  }

  void _showDialogCommon(String text) {
    PopupBox.showText(backButtonBehavior, title: '权益明细', text: '$text', confirmtext: '知道了', tapMaskClose: true);
  }

  List<Widget> renderRights(Map product) {
    Map _imageset = getImageSet(product['vip_level'], product['temp']);
    String textStr = _imageset['text'];
    List<Widget> rights = [
      Container(
        margin: EdgeInsets.only(bottom: 2.5.w),
        child: RichText(
            text: TextSpan(
                text: product['pname'],
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17.w),
                children: <TextSpan>[
              TextSpan(text: " ($textStr)", style: TextStyle(color: Colors.white, fontSize: 12.sp)),
            ])),
      )
    ];
    if (product['right'] != null && product['right'].length > 0) {
      List rightlist = product['right'].toList();
      rightlist.forEach((r) {
        String name = r['name'];
        rights.add(Container(
            margin: EdgeInsets.only(bottom: 2.5.w),
            child: Text(
              "◆ $name",
              style: TextStyle(color: Colors.white, fontSize: 12.sp),
            )));
      });
    }
    return rights;
  }

  List<Widget> renderCards() {
    var vipLevel = Provider.of<GlobalState>(context).profileData?['vip_level'];
    List<Widget> cards = [];
    if (products.length > 0) {
      var newProducts = products.reversed.toList();
      newProducts.asMap().forEach((key, product) {
        Map _imageset = getImageSet(product['vip_level'], product['temp']);
        String textS = _imageset['text'];
        String promoPrice = double.parse(product['promo_price']).toStringAsFixed(0);
        String price = double.parse(product['price']).toStringAsFixed(0);
        StringBuffer rightText = StringBuffer();
        List rightlist = product['right'].toList();
        String isVipStr = '您已经是此会员，无需再次购买。';
        String vipCheck = '此会员卡等级在您当前会员卡等级以下，所以无法购买当前会员卡。';
        rightlist.forEach((element) {
          String name = element['name'];
          rightText..write("$name\n");
        });

        cards.add(Container(
          child: Column(
            children: <Widget>[
              Container(
                width: 310.w,
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.only(left: 10.w),
                height: 160.w,
                child: Stack(
                  children: [
                    LocalPNG(
                      width: 310.w,
                      height: 160.w,
                      url: _imageset['bg'],
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 20.w),
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                  padding: EdgeInsets.only(right: 11.w),
                                  child: LocalPNG(
                                    url: _imageset['logo'],
                                    height: 50.w,
                                  )),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      child: RichText(
                                          text: TextSpan(
                                              text: product['pname'],
                                              style: TextStyle(
                                                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17.sp),
                                              children: <TextSpan>[
                                            TextSpan(
                                                text: " ($textS)",
                                                style: TextStyle(
                                                    color: Colors.white, fontWeight: FontWeight.w400, fontSize: 12.sp)),
                                          ])),
                                    ),
                                    SizedBox(height: 6.w),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        RichText(
                                            text: TextSpan(
                                                text: '$promoPrice元 ',
                                                style: TextStyle(
                                                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.w),
                                                children: <TextSpan>[
                                              TextSpan(
                                                  text: '原价$price元',
                                                  style: TextStyle(
                                                      decoration: TextDecoration.lineThrough,
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.w400,
                                                      fontSize: 12.sp)),
                                            ])),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Expanded(child: SizedBox(height: 0)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  _showDialogCommon(rightText.toString());
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 5.w),
                                  width: 110.w,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '查看权益',
                                      style: TextStyle(height: 1, color: Color(0xFFBE2D2C), fontSize: 14.sp),
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  if (vipLevel <= product['vip_level']) {
                                    if (vipLevel == product['vip_level'] && product['temp'] != 1) {
                                      CgDialog.cgShowDialog(context, '提示', '您已经是此会员，无需再次购买。', ['知道了']);
                                    } else {
                                      showPay(product);
                                    }
                                  } else {
                                    CgDialog.cgShowDialog(context, '提示', '此会员卡等级在您当前会员卡等级以下，所以无法购买当前会员卡。', ['知道了']);
                                  }
                                },
                                behavior: HitTestBehavior.translucent,
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 5.w),
                                  width: 110.w,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '立即购买',
                                      style: TextStyle(height: 1, color: Color(0xFFBE2D2C), fontSize: 14.sp),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 10.w),
                child: LocalPNG(
                  width: 310.w,
                  height: 40.w,
                  url: "assets/images/member/cardshadow.png",
                ),
              )
            ],
          ),
        ));
      });
    }
    return cards;
  }

  getLiBao(int id) {
    switch (id) {
      case 33: //"璀璨联名大礼包"
        return 'assets/images/card/cclb.png';
      case 32: //"紫金联名大礼包"
        return 'assets/images/card/zjlb.png';
      case 31: //"至尊联名大礼包"
        return 'assets/images/card/zzlb.png';
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: Stack(
          children: [
            LocalPNG(
              width: double.infinity,
              height: double.infinity,
              url: "assets/images/member/memberbg1.jpg",
              alignment: Alignment.topCenter,
            ),
            Scaffold(
                appBar: PreferredSize(
                    child: PageTitleBar(
                      title: 'VIP充值',
                      rightWidget: GestureDetector(
                        onTap: () {
                          AppGlobal.appRouter?.push(CommonUtils.getRealHash('rechargeRecord/1'));
                        },
                        child: Center(
                          child: Container(
                              margin: new EdgeInsets.only(left: 3.w, right: 15.w),
                              child: Text(
                                '订单记录',
                                style: TextStyle(
                                    color: StyleTheme.cTitleColor, fontSize: 15.sp, fontWeight: FontWeight.w500),
                              )),
                        ),
                      ),
                    ),
                    preferredSize: Size(double.infinity, 44.w)),
                backgroundColor: Colors.transparent,
                body: SafeArea(
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        SizedBox(height: 15.w),
                        LocalPNG(
                          width: 262.w,
                          height: 103.w,
                          url: "assets/images/member/offtips.png",
                          alignment: Alignment.topCenter,
                          fit: BoxFit.fill,
                        ),
                        SizedBox(height: 15.w),
                        Visibility(
                          visible: _countdownTips != "00:00:00",
                          child: Container(
                            alignment: Alignment.topCenter,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                LocalPNG(
                                  width: 116.w,
                                  height: 23.5.w,
                                  url: "assets/images/member/countdown.png",
                                  fit: BoxFit.cover,
                                ),
                                SizedBox(width: 10.w),
                                Container(
                                  width: 160.w,
                                  height: 50.w,
                                  child: Stack(
                                    children: [
                                      LocalPNG(
                                        width: 160.w,
                                        height: 50.w,
                                        url: "assets/images/member/tipstext.png",
                                        fit: BoxFit.cover,
                                      ),
                                      Center(
                                        child: Text(_countdownTips,
                                            style: TextStyle(
                                                color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18.w)),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 30.w,
                        ),
                        Container(
                            child: Column(
                          children: <Widget>[
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: renderCards(),
                              ),
                            ),
                            libaoProducts.length == 0
                                ? Container()
                                : Container(
                                    margin: EdgeInsets.only(top: 30.w, bottom: 30.w),
                                    child: Center(
                                      child: Container(
                                        width: 345.w,
                                        height: 150.w,
                                        child: Stack(
                                          clipBehavior: Clip.none,
                                          children: <Widget>[
                                            Positioned(
                                                top: -34.w,
                                                child: LocalPNG(
                                                  width: 345.w,
                                                  height: 187.w,
                                                  url: 'assets/images/card/lb-bg.png',
                                                )),
                                            Center(
                                              child: Container(
                                                width: 345.w,
                                                child: Row(
                                                  // mainAxisSize: MainAxisSize.min,
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  children: <Widget>[
                                                    for (var item in libaoProducts) _liCard(getLiBao(item.id), item)
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                          ],
                        )),
                      ],
                    ),
                  ),
                )),
          ],
        ));
  }

  _liCard(String img, dynamic item) {
    return GestureDetector(
      onTap: () {
        showPay(item);
      },
      child: LocalPNG(
        width: 105.w,
        height: 133.w,
        url: img,
      ),
    );
  }
}
