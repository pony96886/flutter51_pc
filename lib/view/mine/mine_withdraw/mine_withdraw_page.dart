import 'dart:async';
import 'package:bot_toast/bot_toast.dart';
import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/page_title_bar.dart';
import 'package:chaguaner2023/store/homeConfig.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/index.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class MineWithdrawPage extends StatefulWidget {
  final int type;
  MineWithdrawPage({Key? key, this.type = 0}) : super(key: key);

  @override
  _MineWithdrawPageState createState() => _MineWithdrawPageState();
}

class _MineWithdrawPageState extends State<MineWithdrawPage> {
  double handlingFee = 0.0;
  Timer? _timer;
  bool selectUser = false;
  ValueNotifier<Map> userInfo =
      ValueNotifier<Map>({'selectId': null, 'accountId': '', 'accountName': '', 'selectUser': false});
  TextEditingController moneyController = TextEditingController();
  String tsdasdqw = r"\s+\b|\b\s";
  delSpace(String text) {
    return text.replaceAll(new RegExp(tsdasdqw), "");
  }

  @override
  void initState() {
    super.initState();
    EventBus().on('changeAcount', (arg) {
      userInfo.value = {
        'selectId': arg['selectId'],
        'accountId': arg['accountId'],
        'accountName': arg['accountName'],
        'selectUser': arg['selectUser']
      };
    });
  }

  @override
  void dispose() {
    userInfo.dispose();
    EventBus().off('changeAcount');
    super.dispose();
  }

  // 提现
  isWithdrawMoney(String account, String name, String amount) async {
    await withdrawMoney(account, name, amount, type: widget.type).then((res) {
      if (res!['status'] != 0) {
        BotToast.showText(text: '提现申请发送成功,请客官耐心等待哦～', align: Alignment(0, 0));
        getProfilePage().then((val) {
          if (val!['status'] != 0) {
            Provider.of<HomeConfig>(context, listen: false).setCoins(val['data']['coin']);
            Provider.of<HomeConfig>(context, listen: false).setMoney(val['data']['money']);
            Provider.of<HomeConfig>(context, listen: false)
                .setOriginalBloggerMoney(val['data']['original_blogger_money']);
          }
        });
      } else {
        BotToast.showText(text: res['msg'], align: Alignment(0, 0));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var money = Provider.of<HomeConfig>(context).member.money.toString();
    var originalBloggerMoney = Provider.of<HomeConfig>(context).member.originalBloggerMoney.toString();
    var wMoney = widget.type == 0 ? money : originalBloggerMoney;
    String accountIdStr = '0';
    if (userInfo.value['accountId'] != '') {
      accountIdStr = userInfo.value['accountId'].substring(userInfo.value['accountId'].length - 4);
    }
    return HeaderContainer(
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.transparent,
          appBar: PreferredSize(
              child: PageTitleBar(
                title: '提现',
                rightWidget: GestureDetector(
                    onTap: () {
                      context.push(CommonUtils.getRealHash('withdrawRecordPage/${widget.type}'));
                    },
                    child: Center(
                      child: Container(
                        margin: new EdgeInsets.only(right: 15.w),
                        child: Text(
                          '提现记录',
                          style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 15.sp, fontWeight: FontWeight.w500),
                        ),
                      ),
                    )),
              ),
              preferredSize: Size(double.infinity, 44.w)),
          body: DefaultTextStyle(
            style: TextStyle(fontSize: 15.sp, color: Color(0xFF646464)),
            child: Container(
              child: Column(
                children: <Widget>[
                  moneyCard(),
                  Container(
                    padding: new EdgeInsets.symmetric(horizontal: 15.5.w),
                    margin: new EdgeInsets.only(top: 40.w),
                    child: Column(
                      children: <Widget>[
                        Container(
                          margin: new EdgeInsets.only(bottom: 50.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text('提现账户'),
                              ValueListenableBuilder(
                                  valueListenable: userInfo,
                                  builder: (context, Map value, child) {
                                    return GestureDetector(
                                      onTap: () {
                                        AppGlobal.appRouter?.push(CommonUtils.getRealHash(
                                            'withdrawAccountPage/' + value['selectId'].toString()));
                                      },
                                      child: value['selectUser']
                                          ? Text(
                                              value['accountName'] + ' ($accountIdStr)>',
                                              style: TextStyle(color: StyleTheme.cTitleColor),
                                            )
                                          : Text(
                                              '添加账户>',
                                              style: TextStyle(color: StyleTheme.cBioColor),
                                            ),
                                    );
                                  })
                            ],
                          ),
                        ),
                        Container(
                          margin: new EdgeInsets.only(bottom: 50.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text('提现金额'),
                              Flexible(
                                  child: TextField(
                                      controller: moneyController,
                                      onChanged: (v) {
                                        if (_timer?.isActive ?? false) {
                                          _timer?.cancel();
                                        }
                                        _timer = Timer.periodic(Duration(seconds: 1), (time) {
                                          setState(() {
                                            handlingFee = v != '' ? int.parse(v) * 0.15.toDouble() : 0.0;
                                          });
                                          time.cancel();
                                        });
                                      },
                                      style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 24.sp),
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.right,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: '输入提现金额',
                                        hintStyle: TextStyle(color: StyleTheme.cBioColor, fontSize: 24.sp),
                                      ))),
                            ],
                          ),
                        ),
                        Container(
                          margin: new EdgeInsets.only(bottom: 50.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text('手续费'),
                              Text(
                                handlingFee.toStringAsFixed(2),
                                style: TextStyle(color: StyleTheme.cTitleColor),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                      child: Container(
                    child: Column(
                      children: <Widget>[
                        GestureDetector(
                          // ignore: missing_return
                          onTap: () {
                            if (userInfo.value['accountId'] == '' || userInfo.value['accountName'] == '') {
                              BotToast.showText(text: '请选择提现账户～', align: Alignment(0, 0));
                              return;
                            }
                            if (moneyController.text == '') {
                              BotToast.showText(text: '请输入提现金额～', align: Alignment(0, 0));
                              return;
                            }
                            if (double.parse(moneyController.text) + handlingFee > double.parse(wMoney)) {
                              BotToast.showText(text: '您的提现金不足～', align: Alignment(0, 0));
                              return;
                            }
                            if (int.parse(moneyController.text) % 100 == 0) {
                              isWithdrawMoney(delSpace(userInfo.value['accountId']),
                                  delSpace(userInfo.value['accountName']), delSpace(moneyController.text));
                            } else {
                              BotToast.showText(text: '必须是100或100的整数倍～', align: Alignment(0, 0));
                            }
                          },
                          child: Container(
                            margin: new EdgeInsets.only(bottom: 20.w),
                            width: 275.w,
                            height: 50.w,
                            child: Stack(
                              children: [
                                LocalPNG(
                                    width: double.infinity,
                                    height: double.infinity,
                                    url: 'assets/images/mymony/money-img.png',
                                    fit: BoxFit.cover),
                                Center(
                                  child: Text(
                                    '确认提现',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Center(
                          child: Text(
                            '*必须是100或100的整数倍',
                            style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 12.sp),
                          ),
                        )
                      ],
                    ),
                  ))
                ],
              ),
            ),
          )),
    );
  }

  Widget moneyCard() {
    var money = Provider.of<HomeConfig>(context).member.money.toString();
    var originalBloggerMoney = Provider.of<HomeConfig>(context).member.originalBloggerMoney.toString();
    var wMoney = widget.type == 0 ? money : originalBloggerMoney;
    return Container(
      width: double.infinity,
      height: 140.w,
      child: Stack(
        children: [
          LocalPNG(
            width: double.infinity,
            height: 140.w,
            url: 'assets/images/mymony/withdraw-bg.png',
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20.w, horizontal: 15.5.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '元宝余额',
                      style: TextStyle(color: Colors.white),
                    ),
                    Container(
                      margin: new EdgeInsets.only(top: 5.w),
                      child: Text(
                        wMoney,
                        style: TextStyle(color: Colors.white, fontSize: 36.sp, fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      '可提现金额：${wMoney}元',
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      '提现手续费15%',
                      style: TextStyle(color: Color(0xFFFFD0D0)),
                    )
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
