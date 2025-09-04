import 'package:bot_toast/bot_toast.dart';
import 'package:chaguaner2023/components/pagetitlebar.dart';
import 'package:chaguaner2023/input/countdown.dart';
import 'package:chaguaner2023/store/global.dart';
import 'package:chaguaner2023/store/homeConfig.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class BindPhone extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => BindPhoneState();
}

class BindPhoneState extends State<BindPhone> {
  TextEditingController _phoneNumController = TextEditingController();
  TextEditingController _veriCodeController = TextEditingController();

  bool codeAvailable = false;
  bool codeSending = false;
  bool caninputInviteCode = false;
  bool senddingCodeDone = false;

  @override
  void initState() {
    super.initState();
    initInviteCode();
  }

  initInviteCode() {
    var invited =
        Provider.of<HomeConfig>(context, listen: false).member.invitedBy;
    if (['', null, false].contains(invited)) {
      setState(() {
        caninputInviteCode = true;
      });
    }
  }

  void showText(text) {
    BotToast.showText(text: '$text', align: Alignment(0, 0));
  }

  Future setCodeData(Function callBack) async {
    var data = await sendEmailCode(_phoneNumController.text);
    if (data!['status'] == 1) {
      setState(() {
        codeSending = true;
        senddingCodeDone = true;
      });
      showText('发送成功');
      callBack();
    } else {
      showText(data['msg']);
    }
  }

  void sendVeriCode(Function callBack) {
    if (!isValidEmail(_phoneNumController.text)) {
      showText("请输入正确的邮箱");
      return;
    }
    setCodeData(callBack);
  }

  _getNumInfo() async {
    var _number = await getProfilePage();
    await getHomeConfig(context);
    Provider.of<GlobalState>(context, listen: false)
        .setProfile(_number!['data']);
  }

  Future setLoginData() async {
    if (senddingCodeDone == false) {
      return showText("请先获取验证码");
    }
    BotToast.showLoading();
    var data =
        await bindEmail(_phoneNumController.text, _veriCodeController.text);
    BotToast.closeAllLoading();
    if (data!['status'] == 0) {
      if (data['msg'] == null) {
        showText('网络错误,请稍后重试');
      } else {
        showText(data['msg']);
      }
    } else {
      showText('绑定成功');
      await getHomeConfig(context);
      await _getNumInfo();
      AppGlobal.appRouter?.go('/home');
    }
  }

  void onSubmit() {
    if (_veriCodeController.text.length == 0) {
      showText("请输入验证码");
      return;
    }
    setLoginData();
  }

  bool isValidEmail(String email) {
    // 定义正则表达式模式来验证电子邮件格式
    final RegExp emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    return emailRegex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.transparent,
      child: Stack(
        children: [
          LocalPNG(
            width: double.infinity,
            height: double.infinity,
            url: "assets/images/login/loginbg.png",
            alignment: Alignment.center,
            fit: BoxFit.cover,
          ),
          Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.transparent,
            appBar: PreferredSize(
                child: PageTitleBar(
                  backColor: Colors.white,
                  title: '',
                ),
                preferredSize: Size(double.infinity, 44.w)),
            body: Container(
              width: double.infinity,
              height: double.infinity,
              padding: EdgeInsets.only(top: 62.w, left: 40.5.w, right: 40.5.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("绑定邮箱",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24.w,
                          fontWeight: FontWeight.w500)),
                  SizedBox(height: 30.w),
                  Container(
                    width: double.infinity,
                    height: 45.w,
                    padding: EdgeInsets.only(left: 20.w, right: 20.w),
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            controller: _phoneNumController,
                            onChanged: (value) {
                              if (value.length < 5) {
                                setState(() {
                                  codeAvailable = false;
                                });
                              } else {
                                setState(() {
                                  codeAvailable = true;
                                });
                              }
                            },
                            cursorColor: Colors.red,
                            keyboardType: TextInputType.emailAddress,
                            style:
                                TextStyle(color: Colors.white, fontSize: 15.sp),
                            decoration: InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.only(
                                    left: 10, right: 10, top: 5, bottom: 5),
                                border: InputBorder.none,
                                hintStyle: TextStyle(
                                    color: Color(0xFF969696), fontSize: 15.sp),
                                hintText: "输入邮箱",
                                hoverColor: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.w),
                  Container(
                    width: double.infinity,
                    height: 45.w,
                    padding: EdgeInsets.only(left: 20.w, right: 10.w),
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            controller: _veriCodeController,
                            keyboardType: TextInputType.numberWithOptions(),
                            cursorColor: Colors.red,
                            style:
                                TextStyle(color: Colors.white, fontSize: 15.sp),
                            decoration: InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.only(
                                    left: 10, right: 10, top: 5, bottom: 5),
                                border: InputBorder.none,
                                hintStyle: TextStyle(
                                    color: Color(0xFF969696), fontSize: 15.sp),
                                hintText: "输入邮箱验证码",
                                hoverColor: Colors.white),
                          ),
                        ),
                        Container(
                          width: 80.w,
                          height: 25.w,
                          decoration: BoxDecoration(
                            color:
                                codeSending ? Color(0xFF969696) : Colors.white,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Center(
                            child: CountDown(
                              available: codeAvailable,
                              unAvailable: () {
                                if (_phoneNumController.text.isEmpty) {
                                  showText("请输入邮箱");
                                  return;
                                }
                                if (!isValidEmail(_phoneNumController.text)) {
                                  showText("请输入正确的邮箱");
                                  return;
                                }
                              },
                              onTapCallback: (callBack) {
                                sendVeriCode(callBack);
                              },
                              onCountdownEnd: () {
                                setState(() {
                                  codeSending = false;
                                });
                              },
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 60.w),
                  GestureDetector(
                    onTap: () {
                      onSubmit();
                    },
                    child: Container(
                      width: double.infinity,
                      height: 50.w,
                      child: Stack(
                        children: [
                          LocalPNG(
                            width: double.infinity,
                            height: 50.w,
                            url: "assets/images/login/common.png",
                          ),
                          Center(
                              child: Text("立即绑定",
                                  style: TextStyle(
                                      color: StyleTheme.cTitleColor,
                                      fontSize: 15.sp))),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
