import 'package:bot_toast/bot_toast.dart';
import 'package:chaguaner2023/components/pagetitlebar.dart';
import 'package:chaguaner2023/input/countdown.dart';
import 'package:chaguaner2023/store/global.dart';
import 'package:chaguaner2023/store/homeConfig.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  final int? type;

  const LoginPage({Key? key, this.type}) : super(key: key);
  @override
  State<StatefulWidget> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _veriCodeController = TextEditingController();
  TextEditingController _invitationCodeController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _regusernameController = TextEditingController();
  TextEditingController _regpasswordController = TextEditingController();
  TextEditingController _regrepectpasswordController = TextEditingController();

  TextEditingController passwordA = TextEditingController();
  TextEditingController passwordB = TextEditingController();
  // type: 1 登录 2 账号密码登录 3 手机注册 4 账号密码注册
  int type = 2;
  String phonePrefix = '+86';
  bool codeAvailable = false;
  bool codeSending = false;
  bool caninputInviteCode = false;
  bool needreg = false;
  bool senddingCodeDone = false;
  String loginStr = "茶馆登录";
  String nowLoginStr = "立即登录";
  String quickRegs = "快速注册";
  String _regExpWeChat = r"^[a-zA-Z]([-_a-zA-Z0-9]{5,19})+$";

  @override
  void initState() {
    super.initState();
    initInviteCode();
  }

  @override
  void dispose() {
    BotToast.closeAllLoading();
    super.dispose();
  }

  showSetPassword() {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
              width: 280.w,
              padding:
                  new EdgeInsets.symmetric(vertical: 15.w, horizontal: 25.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    '安全提醒',
                    style: TextStyle(
                        color: StyleTheme.cTitleColor,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 20.w,
                  ),
                  Text(
                    '您还未设置登录密码\n请设置您的登录密码以保护账号安全',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red, fontSize: 24.sp),
                  ),
                  SizedBox(
                    height: 20.w,
                  ),
                  CommonTextField(
                      invitationCodeController: passwordA,
                      hintText: "请输入登录密码",
                      obscureText: true,
                      hintColor: Colors.white70),
                  SizedBox(
                    height: 10.w,
                  ),
                  CommonTextField(
                      invitationCodeController: passwordB,
                      hintText: "请再次输入登录密码",
                      obscureText: true,
                      hintColor: Colors.white70),
                  SizedBox(
                    height: 20.w,
                  ),
                  GestureDetector(
                    onTap: () {
                      if (passwordA.text == '' || passwordA.text.length < 6) {
                        showText("请输入至少6位数密码");
                        return;
                      }
                      if (passwordA.text != passwordB.text) {
                        showText("两次输入的密码不一致");
                        return;
                      }
                      setPassword(passwordA.text, passwordB.text).then((res) {
                        if (res!['status'] != 0) {
                          showText('密码设置成功～');
                          Navigator.of(context).pop();
                        } else {
                          showText(res['msg']);
                        }
                      });
                    },
                    child: Container(
                      margin: new EdgeInsets.only(top: 30.w),
                      height: 50.w,
                      width: 200.w,
                      child: Stack(
                        children: [
                          LocalPNG(
                              height: 50.w,
                              width: 200.w,
                              url: "assets/images/mymony/money-img.png",
                              fit: BoxFit.fill),
                          Center(
                              child: Text(
                            '保存密码',
                            style:
                                TextStyle(fontSize: 15.sp, color: Colors.white),
                          )),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15.w,
                  ),
                  Text(
                    '请务必牢记您设置的密码并不要透露给他人\n设置后可使用登录密码进行登录',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red, fontSize: 24.sp),
                  )
                ],
              )),
        );
      },
    );
  }

  initInviteCode() {
    var invited =
        Provider.of<HomeConfig>(context, listen: false).member.invitedBy;
    if (['', null, false].contains(invited)) {
      setState(() {
        caninputInviteCode = true;
        type = (widget.type != null ? widget.type : 2)!;
      });
    }
  }

  void showText(text) {
    BotToast.showText(text: '$text', align: Alignment(0, 0));
  }

  Future setCodeData(Function callBack) async {
    var data = await sendEmailCode(_emailController.text);
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
    if (!isValidEmail(_emailController.text)) {
      showText("请输入正确的邮箱");
      return;
    }
    setCodeData(callBack);
  }

  _getNumInfo() async {
    BotToast.showLoading();
    var _number = await getProfilePage();
    var result = await getHomeConfig(context);
    BotToast.closeAllLoading();
    try {
      Provider.of<GlobalState>(context, listen: false)
          .setProfile(_number!['data']);
      context.pop();
      if (result['data']['member']['phone'] != null &&
          result['data']['member']['is_set_password'] == 0) {
        showSetPassword();
      }
    } catch (e) {}
  }

  Future setLoginData() async {
    BotToast.showLoading();
    var data;
    if (type == 1) {
      if (senddingCodeDone == false) {
        BotToast.closeAllLoading();
        return showText("请先获取验证码");
      }
      data = await loginByPhone(
        _emailController.text,
        phonePrefix.replaceAll("+", ""),
        _veriCodeController.text,
      );
    }
    if (type == 2) {
      data = await loginByPassword(
        _usernameController.text,
        _passwordController.text,
      );
    }
    if (type == 3) {
      if (senddingCodeDone == false) {
        BotToast.closeAllLoading();
        return showText("");
      }
      data = await registerByPhone(
        _emailController.text,
        phonePrefix.replaceAll("+", ""),
        _veriCodeController.text,
        _invitationCodeController.text,
      );
    }
    if (type == 4) {
      data = await registerByPassword(
          _regusernameController.text,
          _regpasswordController.text,
          _regrepectpasswordController.text,
          _invitationCodeController.text,
          _emailController.text,
          _veriCodeController.text);
      if (data != null && data['status'] == 1) {
        showText('正在登录');
        registerByPasswords();
        return;
      } else {
        if (data['msg'] == null) {
          showText('网络错误,请稍后重试');
        }
        BotToast.closeAllLoading();
        return showText(data['msg']);
      }
    }
    BotToast.closeAllLoading();
    if (data != null && data['status'] == 0) {
      if (data['msg'] == null) {
        showText('网络错误,请稍后重试');
      } else {
        showText(data['msg']);
      }
    }
    if (data != null && data['status'] == 1) {
      showText('登录成功');
      Box box = AppGlobal.appBox!;
      box.put('apiToken', data['data']);
      AppGlobal.apiToken.value = data['data'];
      Provider.of<HomeConfig>(context, listen: false).setLoginStatus(1);
      await _getNumInfo();
    }
  }

  registerByPasswords() async {
    BotToast.showLoading();
    var data = await loginByPassword(
      _regusernameController.text,
      _regpasswordController.text,
    );
    BotToast.closeAllLoading();
    Box box = AppGlobal.appBox!;
    box.put('apiToken', data!['data']);
    AppGlobal.apiToken.value = data['data'];
    Provider.of<HomeConfig>(context, listen: false).setLoginStatus(1);
    await _getNumInfo();
  }

  void onSubmit() {
    if (type == 1 || type == 3) {
      if (_veriCodeController.text.length == 0) {
        showText("请输入验证码");
        return;
      }
    }
    if (type == 2) {
      if (_usernameController.text.isEmpty) {
        showText("请输入用户名");
        return;
      }
      if (_usernameController.text.length < 5) {
        showText("用户名太短（6～19位）");
        return;
      }
      if (_passwordController.text.isEmpty) {
        showText("请输入密码");
        return;
      }
    }
    setLoginData();
  }

  void onSubmitUsername() {
    if (type == 4) {
      if (_regusernameController.text.isEmpty) {
        showText("请输入包含字母、数字或下划线的用户名");
        return;
      }
      if (_regusernameController.text.length < 6) {
        showText("用户名太短（6～20位）");
        return;
      }
      if (RegExp(_regExpWeChat).hasMatch(_regusernameController.text) ==
          false) {
        showText("请输入包含字母、数字或下划线的用户名");
        return;
      }
      if (_regpasswordController.text.isEmpty) {
        showText("请输入密码");
        return;
      }
      if (_regrepectpasswordController.text.isEmpty) {
        showText("请再次输入密码");
        return;
      }
      if (_regpasswordController.text != _regrepectpasswordController.text) {
        showText("两次输入的密码不一致，请核对");
        return;
      }
      setLoginData();
    }
  }

  String hanldeSwitchText(int type, String value) {
    if (value == "reg") {
      switch (type) {
        case 1:
          return "账号密码登录>";
          break;
        case 2:
          return "手机验证登录>";
          break;
        case 3:
          return "账号密码注册>";
          break;
        case 4:
          return ""; //原手机号注册
          break;
        default:
          return "手机验证登录>";
      }
    }
    if (value == "login") {
      switch (type) {
        case 1:
          return "快速注册>";
          break;
        case 2:
          return "快速注册>";
          break;
        case 3:
          return "去登录>";
          break;
        case 4:
          return "已有账号,去登录>";
          break;
        default:
          return "快速注册>";
      }
    }
    return "";
  }

  handleSwitchLoginType() {
    switch (type) {
      case 1:
        setState(() {
          type = 2;
        });
        break;
      case 2:
        setState(() {
          type = 1;
        });
        break;
      case 3:
        setState(() {
          type = 4;
        });
        break;
      case 4: //原点击手机号注册
        // setState(() {
        //   type = 3;
        // });
        break;
    }
  }

  bool isValidEmail(String email) {
    // 定义正则表达式模式来验证电子邮件格式
    final RegExp emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    return emailRegex.hasMatch(email);
  }

  handleSwitchTegType() {
    switch (type) {
      case 1:
        setState(() {
          type = 4;
        });
        break;
      case 2:
        setState(() {
          type = 4;
        });
        break;
      case 3:
        setState(() {
          type = 1;
        });
        break;
      case 4:
        setState(() {
          type = 2;
        });
        break;
    }
  }

  Widget _buildDropdownItem(Country country) => Container(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CountryPickerUtils.getDefaultFlagImage(country),
            SizedBox(
              width: 8.w,
            ),
            Text(
              "+${country.phoneCode}",
              style: TextStyle(color: Colors.white, fontSize: 15.sp),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
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
            // resizeToAvoidBottomInset: false,
            backgroundColor: Colors.transparent,
            appBar: PreferredSize(
                child: PageTitleBar(
                  backColor: Colors.white,
                  title: '',
                ),
                preferredSize: Size(double.infinity, 44.w)),
            body: ListView(
              padding: EdgeInsets.only(top: 45.w, left: 40.5.w, right: 40.5.w),
              children: <Widget>[
                Text(type <= 2 ? loginStr : quickRegs,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22.5.sp,
                        fontWeight: FontWeight.w500)),
                SizedBox(height: 30.w),
                type == 2
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          CommonTextField(
                            invitationCodeController: _usernameController,
                            hintText: "请输入用户名",
                          ),
                          SizedBox(height: 20.w),
                          CommonTextField(
                              invitationCodeController: _passwordController,
                              hintText: "请输入密码",
                              obscureText: true,
                              enableSuggestions: true),
                          SizedBox(height: 20.w),
                        ],
                      )
                    : SizedBox(),
                type == 4
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          CommonTextField(
                            invitationCodeController: _regusernameController,
                            hintText: "请输入包含字母的用户名",
                          ),
                          SizedBox(height: 20.w),
                          CommonTextField(
                              invitationCodeController: _regpasswordController,
                              hintText: "请输入密码",
                              obscureText: true,
                              enableSuggestions: true),
                          SizedBox(height: 20.w),
                          CommonTextField(
                              invitationCodeController:
                                  _regrepectpasswordController,
                              hintText: "请再次输入密码",
                              obscureText: true,
                              enableSuggestions: true),
                          SizedBox(height: 20.w),
                          CommonTextField(
                            invitationCodeController: _invitationCodeController,
                            hintText: "输入邀请码（选填）",
                          ),
                          SizedBox(
                            height: 20.w,
                          ),
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
                                    controller: _emailController,
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
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 15.sp),
                                    decoration: InputDecoration(
                                        isDense: true,
                                        contentPadding: EdgeInsets.only(
                                            left: 10,
                                            right: 10,
                                            top: 5,
                                            bottom: 5),
                                        border: InputBorder.none,
                                        hintStyle: TextStyle(
                                            color: Color(0xFF969696),
                                            fontSize: 15.sp),
                                        hintText: "输入邮箱(选填)",
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
                                    keyboardType:
                                        TextInputType.numberWithOptions(),
                                    cursorColor: Colors.red,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 15.sp),
                                    decoration: InputDecoration(
                                        isDense: true,
                                        contentPadding: EdgeInsets.only(
                                            left: 10,
                                            right: 10,
                                            top: 5,
                                            bottom: 5),
                                        border: InputBorder.none,
                                        hintStyle: TextStyle(
                                            color: Color(0xFF969696),
                                            fontSize: 15.sp),
                                        hintText: "输入邮箱验证码",
                                        hoverColor: Colors.white),
                                  ),
                                ),
                                Container(
                                  width: 80.w,
                                  height: 25.w,
                                  decoration: BoxDecoration(
                                    color: codeSending
                                        ? Color(0xFF969696)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: Center(
                                    child: CountDown(
                                      available: codeAvailable,
                                      unAvailable: () {
                                        if (_emailController.text.isEmpty) {
                                          showText("请输入邮箱");
                                          return;
                                        }
                                        if (!isValidEmail(
                                            _emailController.text)) {
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
                        ],
                      )
                    : SizedBox(),
                SizedBox(height: 40.w),
                GestureDetector(
                  onTap: () {
                    if (type == 4) {
                      onSubmitUsername();
                    } else {
                      onSubmit();
                    }
                  },
                  child: SizedBox(
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
                          child: Text(
                            type <= 2 ? nowLoginStr : "立即注册",
                            style: TextStyle(
                                color: StyleTheme.cTitleColor,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 30.w),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // GestureDetector(
                    //   onTap: handleSwitchLoginType,
                    //   child: Text(
                    //     hanldeSwitchText(type, "reg"),
                    //     style:
                    //         TextStyle(color: Colors.white, fontSize: 15.sp),
                    //   ),
                    // ),
                    GestureDetector(
                      onTap: handleSwitchTegType,
                      child: Text(
                        hanldeSwitchText(type, "login"),
                        style: TextStyle(color: Colors.white, fontSize: 15.sp),
                      ),
                    ),
                  ],
                ),
                // SizedBox(height: 40.w),
                // type == 1
                //     ? Center(
                //         child: Text.rich(
                //             TextSpan(text: '短信验证码收取失败时，可使用', children: [
                //               TextSpan(
                //                   text: '账号密码',
                //                   style: TextStyle(
                //                       color: Colors.red,
                //                       decoration: TextDecoration.underline),
                //                   recognizer: TapGestureRecognizer()
                //                     ..onTap = () {
                //                       setState(() {
                //                         type = 2;
                //                       });
                //                     }),
                //               TextSpan(text: '登录'),
                //             ]),
                //             style: TextStyle(
                //                 color: StyleTheme.cBioColor,
                //                 fontSize: 12.sp)),
                //       )
                //     : SizedBox(),
                SizedBox(
                  height: 20.w,
                ),
                Text(
                  '温馨提醒：',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 15.w,
                ),
                Text('1.请务必记住自己的账号和密码，以免丢失',
                    style: TextStyle(
                        color: Colors.white, fontSize: 12.sp, height: 1.5)),
                Text('2.绑定邮箱完成注册后，自动给该邮箱发送一份账号和密码',
                    style: TextStyle(
                        color: Colors.white, fontSize: 12.sp, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CommonTextField extends StatelessWidget {
  final String? hintText;
  final TextInputType? keyboardType;
  final bool enableSuggestions;
  final bool obscureText;
  final Color inputColor;
  final Color? hintColor;
  const CommonTextField({
    Key? key,
    required TextEditingController invitationCodeController,
    this.hintText,
    this.keyboardType,
    this.enableSuggestions = true,
    this.obscureText = false,
    this.inputColor = Colors.black38,
    this.hintColor,
  })  : _invitationCodeController = invitationCodeController,
        super(key: key);

  final TextEditingController _invitationCodeController;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 45.w,
      padding: EdgeInsets.only(left: 20.w, right: 20.w),
      decoration: BoxDecoration(
        color: inputColor,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _invitationCodeController,
              keyboardType: keyboardType,
              autocorrect: false,
              obscureText: obscureText,
              enableSuggestions: enableSuggestions,
              inputFormatters: <TextInputFormatter>[
                LengthLimitingTextInputFormatter(20),
              ],
              style: TextStyle(color: Colors.white, fontSize: 15.sp),
              decoration: InputDecoration(
                  isDense: true,
                  contentPadding:
                      EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                      color: hintColor ?? Color(0xFF969696), fontSize: 15.sp),
                  hintText: hintText,
                  hoverColor: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
