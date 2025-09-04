import 'package:bot_toast/bot_toast.dart';
import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/store/homeConfig.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class GameWithdrawPage extends StatefulWidget {
  GameWithdrawPage({Key? key}) : super(key: key);

  @override
  _GameWithdrawPageState createState() => _GameWithdrawPageState();
}

class _GameWithdrawPageState extends State<GameWithdrawPage> {
  TextEditingController numController = TextEditingController();
  TextEditingController bankController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  String _coin = '0';
  int isShowWechat = 0;
  String? vipWechat;
  tixianFuc() {
    if (double.parse(_coin) < 100) {
      showPrompt();
      return;
    }
    if (numController.text == '') {
      BotToast.showText(text: '请输入提现金额', align: Alignment(0, 0));
      return;
    }
    if (bankController.text == '') {
      BotToast.showText(text: '请输入银行卡号', align: Alignment(0, 0));
      return;
    }
    if (nameController.text == '') {
      BotToast.showText(text: '请输入开户名', align: Alignment(0, 0));
      return;
    }
    try {
      if (double.parse(numController.text) > double.parse(_coin)) {
        BotToast.showText(text: '提现金额不足～', align: Alignment(0, 0));
        return;
      }
    } catch (e) {
      BotToast.showText(text: '请按要求输入金额和卡号～', align: Alignment(0, 0));
      return;
    }
    BotToast.showLoading();
    drawGame(bankController.text, nameController.text, numController.text)
        .then((res) {
      if (res == null) {
        BotToast.showText(text: '网络错误,请重试', align: Alignment(0, 0));
        BotToast.closeAllLoading();
        return;
      }
      if (res['status'] != 0) {
        BotToast.closeAllLoading();
        getMoney();
        CommonUtils.showText('提现申请发起成功,请您耐心等待～');
      } else {
        BotToast.showText(text: res['msg'], align: Alignment(0, 0));
        BotToast.closeAllLoading();
      }
    });
  }

  getMoney() {
    getBalance().then((res) {
      if (res == null) {
        CommonUtils.showText('网络错误,请重试～');
        Navigator.pop(context);
        return;
      }
      if (res['status'] != 0) {
        _coin = res['data'];
        Provider.of<HomeConfig>(context, listen: false)
            .setGameCoin(res['data']);
        setState(() {});
      } else {
        _coin = '获取错误';
        setState(() {});
        CommonUtils.showText(res['msg']);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getMoney();
    rechargeValue().then((res) {
      if (res == null) {
        CommonUtils.showText('请检查网络后重试');
        return;
      }
      if (res['status'] != 0) {
        isShowWechat = res['data']['vip'];
        vipWechat = res['data']['wechat'];
        setState(() {});
      } else {
        CommonUtils.showText(res['msg']);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return HeaderContainer(
      child: Scaffold(
        appBar: AppBar(
            actions: [
              Center(
                child: Padding(
                  padding: EdgeInsets.only(right: 15.w),
                  child: GestureDetector(
                    onTap: () {
                      AppGlobal.appRouter?.push('/gameRecordingPage/1');
                    },
                    child: Text(
                      '提现记录',
                      style: TextStyle(color: Colors.black, fontSize: 13.w),
                    ),
                  ),
                ),
              )
            ],
            iconTheme: IconThemeData(
              color: StyleTheme.cTitleColor,
            ),
            title: Text(
              '提现',
              style: TextStyle(
                  color: StyleTheme.cTitleColor,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w500),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            systemOverlayStyle: SystemUiOverlayStyle.dark),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 15.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 15.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(TextSpan(children: [
                      TextSpan(
                          text: '账户余额：', style: TextStyle(fontSize: 14.sp)),
                      TextSpan(text: _coin, style: TextStyle(fontSize: 18.sp)),
                      TextSpan(text: '元', style: TextStyle(fontSize: 14.sp))
                    ], style: TextStyle(color: Color(0xff333333)))),
                    SizedBox(
                      height: 42.5.w,
                    ),
                    inputWidget(
                        onChange: (value) {
                          setState(() {});
                        },
                        controller: numController,
                        type: TextInputType.number,
                        hintText: '提现金额'),
                    SizedBox(
                      height: 18.5.w,
                    ),
                    Text.rich(TextSpan(children: [
                      TextSpan(
                          text: '到账合计：', style: TextStyle(fontSize: 13.sp)),
                      TextSpan(
                          text: numController.text == ''
                              ? '0'
                              : numController.text,
                          style: TextStyle(
                              fontSize: 13.sp, color: Color(0xfff34751))),
                      TextSpan(text: '元', style: TextStyle(fontSize: 13.sp))
                    ], style: TextStyle(color: Color(0xff333333)))),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 17.5.w),
                color: Color(0xfff2f2f5),
                height: 8.w,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 15.w),
                child: Container(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('填写收款人信息',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                            fontSize: 16.sp)),
                    SizedBox(
                      height: 26.5.w,
                    ),
                    Container(
                      padding: EdgeInsets.only(bottom: 18.5.w),
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  width: 0.5.w, color: Color(0xffe6e6e6)))),
                      child: Row(
                        children: [
                          Text('银行卡'),
                          SizedBox(
                            width: 36.w,
                          ),
                          Expanded(
                            child: inputWidget(
                                border: false,
                                controller: bankController,
                                type: TextInputType.number,
                                hintText: '银行卡号'),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 27.5.w,
                    ),
                    Container(
                      padding: EdgeInsets.only(bottom: 18.5.w),
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  width: 0.5.w, color: Color(0xffe6e6e6)))),
                      child: Row(
                        children: [
                          Text('收款人'),
                          SizedBox(
                            width: 36.w,
                          ),
                          Expanded(
                            child: inputWidget(
                                border: false,
                                controller: nameController,
                                type: TextInputType.text,
                                hintText: '收款人姓名'),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 52.w, bottom: 11.5.w),
                      child: Text('提现规则',
                          style: TextStyle(
                              color: Color(0xff666666), fontSize: 13.sp)),
                    ),
                    Container(
                      color: Color(0xfff2f2f5),
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.25.w, vertical: 13.w),
                      child: Column(
                        children: [
                          isShowWechat == 0
                              ? Container()
                              : textWidget(
                                  text:
                                      '您的充值已到达VIP资格,请加$vipWechat ,有问题反馈立马解决,提现30分钟秒到账',
                                  color: Color(0xffff3e3e)),
                          isShowWechat == 0
                              ? Container()
                              : SizedBox(
                                  height: 15.w,
                                ),
                          textWidget(text: '每次提现金额大于100，且为100的整数'),
                          SizedBox(
                            height: 15.w,
                          ),
                          textWidget(text: '仅支持银行卡提现，收款账户卡号和姓名必须一致，否则将提现失败'),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: tixianFuc,
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 33.w),
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.red,
                                Color(0xffff0000),
                                Color(0xffff006c)
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(25.w)),
                        height: 50.w,
                        child: Center(
                          child: Text(
                            '确认提现',
                            style:
                                TextStyle(color: Colors.white, fontSize: 18.sp),
                          ),
                        ),
                      ),
                    )
                  ],
                )),
              )
            ],
          ),
        ),
      ),
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
            fit: BoxFit.fitWidth,
          ),
        ),
        Flexible(
            child: Text(text!,
                style: TextStyle(
                    color: color == null ? Color(0xff666666) : color,
                    fontSize: 13.sp)))
      ],
    );
  }

  Widget inputWidget(
      {Function(String _)? onChange,
      TextInputType? type,
      String? hintText,
      TextEditingController? controller,
      bool border = true}) {
    return Container(
      padding: EdgeInsets.only(bottom: border ? 18.5.w : 0),
      decoration: BoxDecoration(
          border: border
              ? Border(
                  bottom: BorderSide(width: 0.5.w, color: Color(0xffe6e6e6)))
              : null),
      alignment: Alignment.center,
      child: TextField(
        onSubmitted: (value) {},
        onChanged: (String value) {
          onChange!(value);
        },
        keyboardType: type,
        scrollPadding: EdgeInsets.all(0),
        textInputAction: TextInputAction.send,
        autofocus: true,
        controller: controller,
        decoration: InputDecoration(
            isDense: true,
            contentPadding:
                EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
            border: InputBorder.none,
            hintStyle: TextStyle(color: StyleTheme.cBioColor, fontSize: 16.sp),
            hintText: "请输入$hintText"),
      ),
    );
  }

  Future<bool?> showPrompt({Widget? child}) {
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
                child: Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                              top: -50.w,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 76.w,
                                child: Center(
                                  child: LocalPNG(
                                    url: 'assets/images/games/prompt.png',
                                    height: 76.w,
                                    fit: BoxFit.fitHeight,
                                  ),
                                ),
                              )),
                          Container(
                            height: 37.5.w,
                          )
                        ],
                      ),
                      Text(
                        '温馨提示',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        height: 16.w,
                      ),
                      Text(
                        '当前可提现的余额不足100元',
                        style: TextStyle(
                            color: Color(0xff808080), fontSize: 14.sp),
                      ),
                      Text(
                        '无法提现',
                        style: TextStyle(
                            color: Color(0xff808080), fontSize: 14.sp),
                      ),
                      SizedBox(
                        height: 21.5.w,
                      ),
                      btnWidget(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          text: '确定')
                    ],
                  ),
                )),
          );
        });
      },
    );
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
}
