import 'package:bot_toast/bot_toast.dart';
import 'package:chaguaner2023/components/imageCode.dart';
import 'package:chaguaner2023/components/pagetitlebar.dart';
import 'package:chaguaner2023/store/global.dart';
import 'package:chaguaner2023/store/homeConfig.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:chaguaner2023/utils/yy_toast.dart';
import 'package:chaguaner2023/view/homepage/online_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class RechargePage extends StatefulWidget {
  RechargePage({Key? key}) : super(key: key);

  @override
  _RechargePageState createState() => _RechargePageState();
}

class _RechargePageState extends State<RechargePage> {
  TextEditingController _codeController = TextEditingController();
  List? coinList;
  dynamic money;
  List payType = [];
  String changeNumber = '0';
  bool isChange = false;
  int isShowWechat = 0;
  String? vipWechat;
  List<String> questions = [];
  Map? pageData;
  List agentList = [
    {'name': '在线充值', 'agent': 1},
    {'name': '代理充值', 'agent': 2}
  ];
  intpage() {
    rechargeValue().then((res) {
      if (res == null) {
        CommonUtils.showText('请检查网络后重试');
        return;
      }
      if (res['status'] != 0) {
        pageData = res['data'];
        coinList = res['data']['charge'];
        isShowWechat = res['data']['vip'];
        vipWechat = res['data']['wechat'];
        if (res['data']['question'].isNotEmpty) {
          questions = res['data']['question'].split("#");
        }
        setState(() {});
      } else {
        CommonUtils.showText(res['msg']);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    // SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    intpage();
    getCoinNum();
  }

  getCoinNum() {
    getBalance().then((res) {
      if (res!['status'] != 0) {
        Provider.of<HomeConfig>(context, listen: false)
            .setGameCoin(res['data']);
        setState(() {});
      } else {
        CommonUtils.showText(res['msg']);
      }
    });
    getProfilePage().then((val) {
      if (val!['status'] != 0) {
        Provider.of<HomeConfig>(context, listen: false)
            .setMoney(val['data']['money']);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    money = Provider.of<HomeConfig>(context).member.money;
    return Scaffold(
      floatingActionButton: GestureDetector(
        onTap: () {
          ServiceParmas.type = 'game';
          AppGlobal.appRouter
              ?.push(CommonUtils.getRealHash('onlineServicePage'));
        },
        child: LocalPNG(
          url: 'assets/images/games/kefu.png',
          height: 58.w,
        ),
      ),
      appBar: PreferredSize(
          child: PageTitleBar(
            title: '充值',
          ),
          preferredSize: Size(double.infinity, 44.w)),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 15.w, horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            pageData!['ableTransferAmount'] == null
                ? Container()
                : Center(
                    child: SizedBox(
                      height: 133.5.w,
                      child: Stack(
                        children: [
                          LocalPNG(
                            height: 133.5,
                            url: 'assets/images/games/coin_banner.png',
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 29.5.w),
                            child: Center(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  gameRow(
                                      title: '游戏余额',
                                      number: pageData!['balance']['balance'],
                                      status: pageData!['gameToApp'],
                                      type: 1),
                                  gameRow(
                                      title: '可划转余额',
                                      number:
                                          pageData!['ableTransferAmount'] ?? 0,
                                      status: pageData!['appToGame'],
                                      type: 2),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            Padding(
              padding: EdgeInsets.only(top: 25.w, bottom: 44.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '游戏余额充值',
                    style: TextStyle(color: Colors.black, fontSize: 16.sp),
                  ),
                  GestureDetector(
                    onTap: () {
                      AppGlobal.appRouter
                          ?.push(CommonUtils.getRealHash('recordingPage/0'));
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('充值记录',
                            style: TextStyle(
                              color: Color(0xff999999),
                              fontSize: 13.sp,
                            )),
                        SizedBox(
                          width: 5.w,
                        ),
                        LocalPNG(
                          url: 'assets/images/games/right_icon.png',
                          width: 6.w,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            coinList == null
                ? Container()
                : Wrap(
                    spacing: 10.w,
                    runSpacing: 12.w,
                    children: coinList!.asMap().keys.map((e) {
                      return coinCard(
                          value: coinList![e]['value'],
                          text: coinList![e]['desc'],
                          type: coinList![e]['type']);
                    }).toList()),
            Padding(
              padding: EdgeInsets.only(top: 38.5.w, bottom: 11.5.w),
              child: Text(
                '常见问题',
                style: TextStyle(color: Color(0xff666666), fontSize: 13.sp),
              ),
            ),
            Container(
              color: Color(0xfff2f2f5),
              padding: EdgeInsets.symmetric(horizontal: 12.5.w, vertical: 13.w),
              child: Column(
                children: [
                  isShowWechat == 0
                      ? Container()
                      : textWidget(
                          text: '您的充值已到达VIP资格,请加$vipWechat',
                          color: Color(0xffff3e3e)),
                  isShowWechat == 0
                      ? Container()
                      : SizedBox(
                          height: 15.w,
                        ),
                  questions.length > 0
                      ? Column(
                          children: questions
                              .asMap()
                              .keys
                              .map((e) => Column(
                                    children: [
                                      textWidget(text: questions[e]),
                                      e < questions.length - 1
                                          ? SizedBox(
                                              height: 15.w,
                                            )
                                          : Container(),
                                    ],
                                  ))
                              .toList(),
                        )
                      : Container(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget gameRow({String? title, dynamic number, int? status, int? type}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title!,
              style: TextStyle(fontSize: 16.sp, color: Color(0xffd9d9d9)),
            ),
            SizedBox(
              width: 15.5.w,
            ),
            Text(
              "$number",
              style: TextStyle(color: Colors.white, fontSize: 16.sp),
            )
          ],
        ),
        status == 0
            ? Container()
            : GestureDetector(
                onTap: () {
                  isChange = type == 1;
                  showChange(status: type!);
                },
                child: LocalPNG(
                  url: 'assets/images/games/huazhuan.png',
                  width: 73.w,
                  fit: BoxFit.fitWidth,
                ),
              )
      ],
    );
  }

  Widget textWidget({String? text, Color? color}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 5.w, right: 6.w),
          child: LocalPNG(
            url: 'assets/images/games/title_icon.png',
            width: 10.w,
          ),
        ),
        Flexible(
            child: Text(text!,
                style: TextStyle(
                    color: color == null ? Color(0xff666666) : color,
                    fontSize: 13.w)))
      ],
    );
  }

  Widget coinCard({int? value, String? text, Map? type}) {
    return GestureDetector(
      onTap: () {
        payType.clear();
        type!.forEach((key, value) {
          if (value != null) {
            payType.add({
              'type': key,
              'name': value['name'],
              'discount': value['discount']
            });
          }
        });
        setState(() {});
        showBuy(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '选择支付方式',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600),
            ),
            SizedBox(
              height: 10.w,
            ),
            for (var item in payType)
              payItem(
                  value: value!,
                  icon: item['type'],
                  title: item['name'],
                  tips: item['discount'])
          ],
        ));
      },
      child: Container(
        padding: EdgeInsets.only(top: 2.5.w),
        width: 107.5.w,
        height: 80.w,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.w),
            gradient: LinearGradient(
              colors: [Color(0xffffefd7), Color(0xfffdda93)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            )),
        child: Column(
          children: [
            Container(
              width: 102.w,
              height: 49.5.w,
              color: Color(0xfffef5e8),
              child: Center(
                child: Text.rich(TextSpan(children: [
                  TextSpan(
                      text: value.toString(),
                      style: TextStyle(fontSize: 21.sp)),
                  TextSpan(text: '元', style: TextStyle(fontSize: 10.sp))
                ], style: TextStyle(color: Color(0xfff4aa00)))),
              ),
            ),
            Expanded(
                child: Center(
              child: Text(
                text!,
                style: TextStyle(color: Color(0xfff34751), fontSize: 11.sp),
              ),
            ))
          ],
        ),
      ),
    );
  }

  payMoney({int? value, int? type}) {
    BotToast.showLoading();
    payGame(value.toString(), type!, UserInfo.imageCode!).then((res) {
      if (res == null) {
        BotToast.closeAllLoading();
        BotToast.showText(text: '网络错误,请重试~', align: Alignment(0, 0));
        return;
      }
      if (res['status'] != 0) {
        UserInfo.imageCode = null;
        BotToast.closeAllLoading();
        showPaySuccess();
        CommonUtils.launchURL(res['data']['payUrl']);
        // Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //         builder: (context) => WebViewPage(
        //               title: '充值',
        //               url: res.data['payUrl'],
        //             )));
      } else {
        UserInfo.imageCode = null;
        BotToast.closeAllLoading();
        BotToast.showText(text: res['msg'], align: Alignment(0, 0));
      }
    });
  }

  Future<String?> showImgCode() {
    return showDialog<String>(
      context: context,
      barrierDismissible: true,
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
                        '图形码验证',
                        style: TextStyle(
                            color: StyleTheme.cTitleColor,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      height: 21.5.w,
                    ),
                    ImageCode(),
                    SizedBox(
                      height: 17.w,
                    ),
                    Container(
                      height: 44.w,
                      decoration: BoxDecoration(
                          color: Color(0xfff5f5f5),
                          border: Border.all(
                              width: 0.5.w, color: Color(0xffe6e6e6))),
                      child: Center(
                        child: TextField(
                          controller: _codeController,
                          onChanged: (value) {},
                          keyboardType: TextInputType.text,
                          style: TextStyle(
                              color: Color(0xff808080), fontSize: 15.sp),
                          decoration: InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.only(
                                  left: 10, right: 10, top: 5, bottom: 5),
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                  color: Color(0xFF969696), fontSize: 15.sp),
                              hintText: "请输入图形验证码",
                              hoverColor: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.w,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop(_codeController.text);
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
                            '确定',
                            style: TextStyle(
                                color: Color(0xff903600), fontSize: 14.sp),
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
                          width: 30.w,
                          height: 30.w,
                          url: 'assets/images/mymony/close.png',
                          fit: BoxFit.cover)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  payItem({String? icon, String? title, String? tips, int? value}) {
    int payType;
    Color _color;
    if (icon == 'agent') {
      payType = 2;
      _color = Color(0xfff7956e);
    } else if (icon == 'wechat') {
      payType = 4;
      _color = Color(0xff69c928);
    } else if (icon == 'alipay') {
      payType = 3;
      _color = Color(0xff3ba9f2);
    } else {
      payType = 1;
      _color = Color(0xff2d90a3);
    }
    return GestureDetector(
      onTap: () {
        BotToast.showLoading();
        isCaptcha(99).then((res) {
          BotToast.closeAllLoading();
          if (res!['status'] == 1) {
            if (res['data']['is_captcha'] == 1) {
              showImgCode().then((code) {
                if (code != '') {
                  UserInfo.imageCode = code;
                  Navigator.pop(context);
                  payMoney(value: value, type: payType);
                }
                _codeController.clear();
              });
            } else {
              Navigator.pop(context);
              payMoney(value: value, type: payType);
            }
          } else {
            CommonUtils.showText(res['msg']);
          }
        });
      },
      child: Container(
        width: 231.w,
        height: 40.w,
        margin: EdgeInsets.only(top: 15.w),
        decoration: BoxDecoration(
            color: _color, borderRadius: BorderRadius.circular(20.w)),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              LocalPNG(
                url: 'assets/images/games/$icon.png',
                width: 25.w,
                fit: BoxFit.fitWidth,
              ),
              SizedBox(
                width: 9.5.w,
              ),
              Text(
                title!,
                style: TextStyle(fontSize: 14.w, color: Colors.white),
              ),
              tips == null
                  ? Container()
                  : Container(
                      margin: EdgeInsets.only(left: 6.5.w),
                      child: Text(
                        tips,
                        style: TextStyle(
                            color: Color(0xfffaf32a), fontSize: 11.sp),
                      ),
                    )
            ],
          ),
        ),
      ),
    );
  }

  showChange({int? status}) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
                width: 300.w,
                padding: new EdgeInsets.symmetric(vertical: 25.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '余额划转',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600),
                    ),
                    SizedBox(
                      height: 17.w,
                    ),
                    Container(
                      width: 232.w,
                      child: Text(
                        '元宝充值不能划转游戏,收益(包含代理,茶帖,经纪人等等)才可以划转',
                        style: TextStyle(
                            color: Color(0xff808080), fontSize: 14.sp),
                      ),
                    ),
                    SizedBox(
                      height: 20.5.w,
                    ),
                    Container(
                      height: 170.w,
                      width: 232.w,
                      child: Stack(
                        children: [
                          Center(
                            // child: GestureDetector(
                            //   onTap: () {
                            //     if (status != 2) {
                            //       setDialogState(() {
                            //         changeNumber = '0';
                            //         numController.clear();
                            //         isChange = !isChange;
                            //       });
                            //     } else {
                            //       CommonUtils.showText('代理余额只能单项划转至游戏余额～');
                            //     }
                            //   },
                            child: LocalPNG(
                              url: 'assets/images/games/change.png',
                              width: 30.w,
                              fit: BoxFit.fitWidth,
                            ),
                            // ),
                          ),
                          AnimatedPositioned(
                              top: isChange ? 110.w : 0,
                              left: 0,
                              right: 0,
                              child: changeWidget(setDialogState,
                                  value: pageData!['ableTransferAmount']
                                      .toString(),
                                  title: '可划转余额',
                                  isNumber: isChange ? true : null),
                              duration: Duration(milliseconds: 300)),
                          AnimatedPositioned(
                              bottom: isChange ? 110.w : 0,
                              left: 0,
                              right: 0,
                              child: changeWidget(setDialogState,
                                  value:
                                      Provider.of<HomeConfig>(context).gameCoin,
                                  title: '游戏余额',
                                  isNumber: isChange ? null : true),
                              duration: Duration(milliseconds: 300))
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20.5.w,
                    ),
                    btnWidget(
                        onTap: () {
                          if (numController.text == '') {
                            CommonUtils.showText('请输入划转金额~');
                            return;
                          }
                          if (double.parse(numController.text) <= 0) {
                            CommonUtils.showText('划转金额必须大于0～');
                            return;
                          }
                          transfer(
                              value: numController.text, isTransfer: isChange);
                          Navigator.pop(context);
                        },
                        text: '确定')
                  ],
                )),
          );
        });
      },
    ).then((value) {
      changeNumber = '0';
      isChange = false;
      numController.clear();
    });
  }

  transfer({String? value, bool? isTransfer}) async {
    await transferPay(amount: value, direction: isTransfer! ? 2 : 1)
        .then((res) {
      if (res == null) {
        CommonUtils.showText('请您检查网络后重试～');
        return;
      }
      if (res['status'] != 0) {
        getCoinNum();
        intpage();
        YyToast.successToast('余额划转成功～');
      } else {
        CommonUtils.showText(res['msg']);
      }
    });
  }

  TextEditingController numController = TextEditingController();
  changeWidget(Function changeState,
      {bool? isNumber, String? title, String? value}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 17.w),
      height: 60.w,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5.w),
          border: Border.all(width: 0.5.w, color: Color(0xffe5e5e5))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
              child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                isNumber == null
                    ? Container(
                        width: 100.w,
                        alignment: Alignment.center,
                        child: TextField(
                          onSubmitted: (e) {},
                          onChanged: (ev) {
                            try {
                              if (double.parse(ev == '' ? '1' : ev) > 0) {
                                if (double.parse(ev) > double.parse(value!)) {
                                  changeState(() {
                                    changeNumber = value;
                                    numController.text = value;
                                  });
                                } else {
                                  changeNumber = ev == '' ? '0' : ev;
                                }

                                changeState(() {});
                              } else {
                                changeState(() {
                                  changeNumber = '0';
                                  numController.text = '0';
                                });
                              }
                            } catch (e) {
                              changeState(() {
                                changeNumber = '0';
                                numController.text = '0';
                              });
                              CommonUtils.showText('请输入正确的数字～');
                            }
                          },
                          keyboardType: TextInputType.phone,
                          scrollPadding: EdgeInsets.all(0),
                          textInputAction: TextInputAction.send,
                          autofocus: true,
                          controller: numController,
                          decoration: InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.only(
                                  left: 10, right: 10, top: 5, bottom: 5),
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                  color: StyleTheme.cBioColor, fontSize: 16.w),
                              hintText: "0.0"),
                        ),
                      )
                    : Text(
                        changeNumber,
                        style: TextStyle(color: Colors.black, fontSize: 16.sp),
                      ),
                SizedBox(),
                Text('余额：$value',
                    style: TextStyle(color: Color(0xff5cd08b), fontSize: 10.sp))
              ],
            ),
          )),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              isNumber == null
                  ? GestureDetector(
                      onTap: () {
                        changeState(() {
                          numController.text = value!;
                          changeNumber = value;
                        });
                      },
                      child: LocalPNG(
                        url: 'assets/images/games/max_icon.png',
                        width: 34.w,
                        fit: BoxFit.fitWidth,
                      ),
                    )
                  : Container(),
              SizedBox(
                width: 5.5.w,
              ),
              Text(title!,
                  style: TextStyle(color: Colors.black, fontSize: 14.sp))
            ],
          )
        ],
      ),
    );
  }

  showPaySuccess() {
    return showBuy(
        child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LocalPNG(
          url: 'assets/images/games/pay_success.png',
          width: 166.w,
          fit: BoxFit.fitWidth,
        ),
        SizedBox(
          height: 11.w,
        ),
        Text(
          '支付确认中...',
          style: TextStyle(
              color: Colors.black,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600),
        ),
        SizedBox(
          height: 21.w,
        ),
        Text(
          '付款后1-5分钟内到账,请稍后确认,',
          style: TextStyle(color: Color(0xff808080), fontSize: 14.sp),
        ),
        Text(
          '超时未到账，请联系客服。',
          style: TextStyle(color: Color(0xff808080), fontSize: 14.sp),
        ),
        isShowWechat == 0
            ? Container()
            : Text.rich(
                TextSpan(text: "或者添加微信 ", children: [
                  TextSpan(
                      text: vipWechat,
                      style: TextStyle(color: StyleTheme.cDangerColor)),
                  TextSpan(
                    text: ' 专属客服',
                  )
                ]),
                style: TextStyle(color: Color(0xff808080), fontSize: 14.sp),
              ),
        SizedBox(
          height: 20.w,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                width: 130.w,
                height: 40.w,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.w),
                    gradient: LinearGradient(
                      colors: [Color(0xffcccccc), Color(0xffe6e6e6)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    )),
                child: Center(
                  child: Text(
                    '知道了',
                    style: TextStyle(color: Color(0xff808080), fontSize: 14.sp),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                context.pop();
                ServiceParmas.type = 'game';
                AppGlobal.appRouter
                    ?.push(CommonUtils.getRealHash('onlineServicePage'));
                ;
              },
              child: Container(
                width: 130.w,
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
                    '联系客服',
                    style: TextStyle(color: Color(0xff903600), fontSize: 14.sp),
                  ),
                ),
              ),
            )
          ],
        )
      ],
    ));
  }

  btnWidget({Function()? onTap, String? text}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 231.w,
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
            text!,
            style: TextStyle(color: Color(0xff903600), fontSize: 14.sp),
          ),
        ),
      ),
    );
  }

  Future<bool?> showBuy({Widget? child}) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
                width: 300.w,
                padding: new EdgeInsets.symmetric(vertical: 25.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: child),
          );
        });
      },
    );
  }
}
