import 'package:bot_toast/bot_toast.dart';
import 'package:chaguaner2023/model/signuplist.dart';
import 'package:chaguaner2023/store/homeConfig.dart';
import 'package:chaguaner2023/store/signInConfig.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/http.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class SignInPage extends StatefulWidget {
  SignInPage({Key? key}) : super(key: key);

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  Widget buildSignInBox(context) {
    var signinlist = Provider.of<SignInConfig>(context).datas;
    List? _signInList = signinlist.rewardInfo;
    int? _days = Provider.of<SignInConfig>(context).days;
    List<Widget> boxs = [];
    Widget content;
    if (_days == 0) {
      boxs.add(SignInbox(
        item: _signInList![0],
        status: 2,
        last: 1 == _signInList.length - 1,
      ));
      for (int j = 1; j < _signInList.length; j++) {
        boxs.add(SignInbox(
          item: _signInList[j],
          status: 3,
          last: j == _signInList.length - 1,
        ));
      }
    }
    if (_days == 14) {
      for (int j = 0; j < _days!; j++) {
        boxs.add(SignInbox(
          item: _signInList![j],
          status: 1,
          last: j == _signInList.length - 1,
        ));
      }
      boxs.add(SignInbox(
        item: _signInList![14],
        status: 2,
        last: true,
      ));
    }
    if (_days! > 0 && _days < 14) {
      for (int j = 0; j < _days; j++) {
        boxs.add(SignInbox(
          item: _signInList![j],
          status: 1,
          last: j == _signInList.length - 1,
        ));
      }
      boxs.add(SignInbox(
        item: _signInList![_days],
        status: 2,
        last: false,
      ));
      for (int p = _days + 1; p < _signInList.length; p++) {
        boxs.add(SignInbox(
          item: _signInList[p],
          status: 3,
          last: p == _signInList.length - 1,
        ));
      }
    }
    if (_days >= 15) {
      for (int p = 0; p < _signInList!.length; p++) {
        boxs.add(SignInbox(
          item: _signInList[p],
          status: 1,
          last: p == _signInList.length - 1,
        ));
      }
    }

    content = new Wrap(
      spacing: 5.w,
      runSpacing: 5.w,
      children: boxs,
    );

    return content;
  }

  @override
  Widget build(BuildContext context) {
    int? _days = Provider.of<SignInConfig>(context).days;
    String? tips = Provider.of<SignInConfig>(context).datas.tips;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(10.w)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(4.5.w),
            child: Text('已签到$_days天',
                style: TextStyle(
                    color: StyleTheme.cTitleColor,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w500)),
          ),
          tips!.isNotEmpty
              ? Text(
                  tips,
                  style: TextStyle(
                      color: Colors.black.withOpacity(0.4), fontSize: 10.sp),
                )
              : SizedBox(),
          SizedBox(height: 15.w),
          buildSignInBox(context),
          SizedBox(height: 25.w),
          SignInActionButton()
        ],
      ),
    );
  }
}

class SignInActionButton extends StatefulWidget {
  SignInActionButton({Key? key}) : super(key: key);

  @override
  _SignInActionButtonState createState() => _SignInActionButtonState();
}

class _SignInActionButtonState extends State<SignInActionButton> {
  int? _isSign;

  void onSign(context) async {
    var result = await onSignUpSubmit();
    if (result!.status == 1) {
      Response listResult = await PlatformAwareHttp.post("/api/user/getSignUp");
      Provider.of<SignInConfig>(context, listen: false)
          .setData(listResult.data["data"]);
      getProfilePage().then((val) => {
            if (val!['status'] != 0)
              {
                Provider.of<HomeConfig>(context, listen: false)
                    .setCoins(val['data']['coin']),
                Provider.of<HomeConfig>(context, listen: false)
                    .setMoney(val['data']['money'])
              }
          });
      BotToast.showText(
          text: '签到成功, 明天继续',
          duration: Duration(seconds: 3),
          onClose: () {
            try {
              Navigator.pop(context);
            } catch (e) {
              //
            }
          });
    } else {
      Provider.of<SignInConfig>(context, listen: false).setSign(1);
      BotToast.showText(text: '${result.msg}');
    }
  }

  @override
  Widget build(BuildContext context) {
    _isSign = Provider.of<SignInConfig>(context).datas.isSign;
    if (_isSign == null) _isSign = 1;
    var homeData = Provider.of<HomeConfig>(context).data;
    var phoneNum = homeData['member']['phone'];
    if (phoneNum == null) {
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          Navigator.pop(context);
          AppGlobal.appRouter?.push(CommonUtils.getRealHash('loginPage/2'));
        },
        child: Container(
          width: double.infinity,
          height: 50.w,
          margin: EdgeInsets.only(top: 10.w),
          child: Stack(
            children: [
              Center(
                child: LocalPNG(
                    width: 256.w,
                    height: 50.w,
                    url: "assets/images/pment/submit.png",
                    alignment: Alignment.center,
                    fit: BoxFit.contain),
              ),
              Center(
                child: Text(
                  '注册登录后开启',
                  style: TextStyle(color: Colors.white, fontSize: 15.sp),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      if (_isSign == 1) {
        return Center(
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: LocalPNG(
              url: "assets/images/sign/button-close.png",
              width: 265.w,
              height: 50.w,
            ),
          ),
        );
      }
      if (_isSign == 0) {
        return Center(
          child: GestureDetector(
            onTap: () {
              onSign(context);
            },
            child: LocalPNG(
              url: "assets/images/sign/button-sign.png",
              width: 263.w,
              height: 50.w,
            ),
          ),
        );
      }
    }
    return SizedBox();
  }
}

class SignInbox extends StatelessWidget {
  final RewardInfo? item;
  final int? status;
  final bool? last;

  const SignInbox({Key? key, this.status, this.last, this.item})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color textColor = status == 1 ? Colors.white : StyleTheme.cTitleColor;
    return Container(
      width: last! ? 165.w : 80.w,
      height: 80.w,
      decoration: BoxDecoration(
          border: Border.all(
              color: status == 2 ? Color(0xFFFF4149) : Colors.transparent,
              width: 2),
          color: status == 1 ? Color(0xFFFF4149) : Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(5.w)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          status == 1
              ? Text('已签到',
                  style: TextStyle(color: Colors.white, fontSize: 11.sp))
              : Text('第' + '${item!.days}' + '天',
                  style: TextStyle(
                      color: StyleTheme.cTitleColor, fontSize: 11.sp)),
          item!.rewardType == 3
              ? Padding(
                  padding: EdgeInsets.symmetric(vertical: 5.w),
                  child: Text(
                    item!.title!,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 10.w.sp,
                    ),
                  ),
                )
              : SizedBox(height: 13.5.w),
          item!.rewardType == 1
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    LocalPNG(
                        url: "assets/images/sign/coin.png",
                        width: 20.w,
                        height: 20.w,
                        alignment: Alignment.center,
                        fit: BoxFit.cover),
                    Padding(
                        padding: EdgeInsets.only(left: 3.w, right: 3.w),
                        child: Text(
                          'x',
                          style: TextStyle(
                              color: textColor,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w500),
                        )),
                    Text('${item!.coin}',
                        style: TextStyle(
                            color: textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w500))
                  ],
                )
              : SizedBox(),
          item!.rewardType == 2
              ? Text.rich(TextSpan(children: [
                  TextSpan(
                      text: '${item!.title}',
                      style: TextStyle(color: textColor, fontSize: 12.w)),
                  TextSpan(
                      text: '${item!.coin}',
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: textColor,
                          fontSize: 18.w)),
                ]))
              : SizedBox(),
          item!.rewardType == 3
              ? Text('${item!.days}天',
                  style: TextStyle(
                      color: textColor,
                      fontSize: 18.w,
                      fontWeight: FontWeight.w500))
              : SizedBox()
        ],
      ),
    );
  }
}
