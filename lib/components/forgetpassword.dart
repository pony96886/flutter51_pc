import 'package:bot_toast/bot_toast.dart';
import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/page_title_bar.dart';
import 'package:chaguaner2023/input/countdown.dart';
import 'package:chaguaner2023/store/global.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ForgetPassword extends StatefulWidget {
  ForgetPassword({Key? key}) : super(key: key);

  @override
  _ForgetPasswordState createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _phoneNumController = TextEditingController();
  TextEditingController _veriCodeController = TextEditingController();
  TextEditingController _newpassword = TextEditingController();
  TextEditingController _repeatpassword = TextEditingController();

  int currentStep = 1;
  String phonePrefix = '+86';
  bool codeAvailable = false;
  bool codeSending = false;

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

  void showText(text) {
    BotToast.showText(text: '$text');
  }

  void sendVeriCode(Function callBack) {
    if (_phoneNumController.text.length < 5) {
      showText("请输入正确的手机号码");
      return;
    }
    setCodeData(callBack);
  }

  Future setCodeData(Function callBack) async {
    var data = await getCaptcha(_phoneNumController.text, phonePrefix, 3, UserInfo.imageCode!);
    if (data!['status'] == 1) {
      showText('发送成功');
      setState(() {
        codeSending = true;
      });
      callBack();
    } else {
      showText(data['msg']);
    }
  }

  void checkUserName() async {
    var data = await validateUsername(_usernameController.text);
    BotToast.closeAllLoading();
    if (data!['status'] == 0) {
      setState(() {
        currentStep = 2;
      });
    } else {
      showText('不存在该账号');
    }
  }

  void handleSubmit() async {
    var data = await forgetPassword(_usernameController.text, _newpassword.text, _repeatpassword.text,
        _phoneNumController.text, phonePrefix.replaceAll("+", ""), _veriCodeController.text);
    BotToast.closeAllLoading();
    if (data!['status'] == 0) {
      if (data['msg'] == null) {
        showText('网络错误,请稍后重试');
      } else {
        showText(data['msg']);
      }
    } else {
      showText('密码重设成功');
      AppGlobal.appRouter?.push(CommonUtils.getRealHash('login'));
    }
  }

  void submitData() {
    if (currentStep == 1) {
      if (_usernameController.text.isEmpty) {
        showText("请输入需要找回的账号");
        return;
      }
      if (RegExp(r"^[-_a-zA-Z0-9]+$").hasMatch(_usernameController.text) == false) {
        showText("账号只能输入英文、数字和下划线");
        return;
      }
      BotToast.showLoading();
      checkUserName();
    }
    if (currentStep == 2) {
      if (_phoneNumController.text.isEmpty) {
        showText("请输入手机号码");
        return;
      }
      if (_phoneNumController.text.length < 5) {
        showText("请输入正确的手机号码");
        return;
      }
      if (_veriCodeController.text.length == 0) {
        showText("请输入验证码");
        return;
      }
      if (_newpassword.text.isEmpty) {
        showText("请输入新密码");
        return;
      }
      if (_repeatpassword.text.isEmpty) {
        showText("请再次输入新密码");
        return;
      }
      BotToast.showLoading();
      handleSubmit();
    }
  }

  @override
  Widget build(BuildContext context) {
    return HeaderContainer(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
            child: PageTitleBar(
              title: '',
            ),
            preferredSize: Size(double.infinity, 44.w)),
        body: Padding(
          padding: EdgeInsets.all(40.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              currentStep == 1
                  ? Text("找回密码",
                      style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 24.sp, fontWeight: FontWeight.w500))
                  : SizedBox(),
              currentStep == 2
                  ? RichText(
                      text: TextSpan(
                          text: "找回密码",
                          style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 24.sp, fontWeight: FontWeight.w500),
                          children: <TextSpan>[
                            TextSpan(
                                text: ' (您可以使用验证码直接登录)',
                                style: TextStyle(
                                    color: StyleTheme.cTitleColor, fontSize: 14.sp, fontWeight: FontWeight.w400))
                          ]),
                    )
                  : SizedBox(),
              SizedBox(height: 30.w),
              currentStep == 1
                  ? EditTextField(
                      editingController: _usernameController,
                      hintText: "请输入需要找回的账号",
                    )
                  : SizedBox(),
              currentStep == 2
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          width: double.infinity,
                          height: 45.w,
                          padding: EdgeInsets.only(right: 20.w),
                          decoration: BoxDecoration(
                            color: Color(0xFFEEEEEE),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              CountryPickerDropdown(
                                  initialValue: 'CN',
                                  itemBuilder: _buildDropdownItem,
                                  dropdownColor: Colors.black87,
                                  sortComparator: (Country a, Country b) => a.isoCode.compareTo(b.isoCode),
                                  onValuePicked: (Country country) {
                                    phonePrefix = country.phoneCode;
                                  },
                                  iconSize: 20.w,
                                  iconDisabledColor: Colors.white,
                                  iconEnabledColor: Colors.white),
                              LocalPNG(
                                width: 7.5.w,
                                height: 7.5.w,
                                url: "assets/images/login/down_arrow_black.png",
                                alignment: Alignment.centerLeft,
                              ),
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
                                  keyboardType: TextInputType.numberWithOptions(),
                                  inputFormatters: <TextInputFormatter>[
                                    LengthLimitingTextInputFormatter(20),
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 15.sp),
                                  decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                                      border: InputBorder.none,
                                      hintStyle: TextStyle(color: Color(0xFFB4B4B4), fontSize: 15.sp),
                                      hintText: "输入手机号",
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
                            color: Color(0xFFEEEEEE),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Expanded(
                                child: TextField(
                                  controller: _veriCodeController,
                                  keyboardType: TextInputType.numberWithOptions(),
                                  inputFormatters: <TextInputFormatter>[
                                    LengthLimitingTextInputFormatter(6),
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 15.sp),
                                  decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                                      border: InputBorder.none,
                                      hintStyle: TextStyle(color: Color(0xFFB4B4B4), fontSize: 15.sp),
                                      hintText: "输入短信验证码",
                                      hoverColor: Colors.white),
                                ),
                              ),
                              Container(
                                width: 80.w,
                                height: 25.w,
                                decoration: BoxDecoration(
                                  color: codeSending ? Color(0xFF969696) : Colors.white,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Center(
                                  child: CountDown(
                                    available: codeAvailable,
                                    unAvailable: () {
                                      if (_phoneNumController.text.isEmpty) {
                                        showText("请输入手机号码");
                                        return;
                                      }
                                      if (_phoneNumController.text.length < 5) {
                                        showText("请输入正确的手机号码");
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
                        SizedBox(height: 20.w),
                        EditTextField(
                            editingController: _newpassword,
                            hintText: "请输入新密码 (至少6位)",
                            obscureText: true,
                            enableSuggestions: true),
                        SizedBox(height: 20.w),
                        EditTextField(
                            editingController: _repeatpassword,
                            hintText: "请再次输入新密码 (至少6位)",
                            obscureText: true,
                            enableSuggestions: true),
                      ],
                    )
                  : SizedBox(),
              SizedBox(height: 60.w),
              GestureDetector(
                  onTap: submitData,
                  child: Container(
                      width: double.infinity,
                      height: 55.w,
                      margin: EdgeInsets.only(
                        top: 40.w,
                      ),
                      child: Stack(
                        children: [
                          LocalPNG(
                            width: double.infinity,
                            height: 55.w,
                            url: "assets/images/mymony/money-img.png",
                            alignment: Alignment.center,
                            fit: BoxFit.contain,
                          ),
                          Center(
                            child: Text(currentStep == 1 ? "下一步" : "重设密码",
                                style: TextStyle(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.w500)),
                          ),
                        ],
                      )))
            ],
          ),
        ),
      ),
    );
  }
}

class EditTextField extends StatelessWidget {
  final String? hintText;
  final TextInputType? keyboardType;
  final bool enableSuggestions;
  final bool obscureText;
  final TextEditingController? _editingController;

  const EditTextField({
    Key? key,
    @required TextEditingController? editingController,
    this.hintText,
    this.keyboardType,
    this.enableSuggestions = true,
    this.obscureText = false,
  })  : _editingController = editingController,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 45.w,
      padding: EdgeInsets.only(left: 20.w, right: 20.w),
      decoration: BoxDecoration(
        color: Color(0xFFEEEEEE),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _editingController,
              keyboardType: keyboardType,
              autocorrect: false,
              obscureText: obscureText,
              enableSuggestions: enableSuggestions,
              inputFormatters: <TextInputFormatter>[
                LengthLimitingTextInputFormatter(20),
              ],
              style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 15.sp),
              decoration: InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Color(0xFF969696), fontSize: 15.sp),
                  hintText: hintText,
                  hoverColor: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
