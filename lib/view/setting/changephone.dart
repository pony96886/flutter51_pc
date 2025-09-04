import 'package:bot_toast/bot_toast.dart';
import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/pagetitlebar.dart';
import 'package:chaguaner2023/input/countdown.dart';
import 'package:chaguaner2023/store/global.dart';
import 'package:chaguaner2023/store/homeConfig.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ChangePhone extends StatefulWidget {
  final String? phone;
  final String? phonePrefix;
  final String? showPhone;

  const ChangePhone({Key? key, this.phone, this.phonePrefix, this.showPhone})
      : super(key: key);
  @override
  State<StatefulWidget> createState() => ChangePhoneState();
}

class ChangePhoneState extends State<ChangePhone> {
  TextEditingController _phoneNumController = TextEditingController();
  TextEditingController _veriCodeController = TextEditingController();
  TextEditingController _newphoneNumController = TextEditingController();
  TextEditingController _newveriCodeController = TextEditingController();

  String phonePrefix = '+86';
  String newphonePrefix = '+86';
  bool codeAvailable = false;
  bool codeSending = false;
  bool newcodeAvailable = false;
  bool newcodeSending = false;

  @override
  void initState() {
    super.initState();
    _phoneNumController.text = widget.phone!;
    phonePrefix = widget.phonePrefix!;
    codeAvailable = true;
  }

  void showText(text) {
    BotToast.showText(text: '$text', align: Alignment(0, 0));
  }

  Future setCodeData(int? type, Function? callBack) async {
    if (type == 1) {
      var data = await getCaptcha(_phoneNumController.text,
          phonePrefix.replaceAll("+", ""), 4, UserInfo.imageCode!);
      if (data!['status'] == 1) {
        setState(() {
          codeSending = true;
        });
        showText('发送成功');
        callBack!();
      } else {
        showText(data['msg']);
      }
    } else {
      var data = await getCaptcha(_newphoneNumController.text,
          newphonePrefix.replaceAll("+", ""), 4, UserInfo.imageCode!);
      if (data!['status'] == 1) {
        setState(() {
          newcodeSending = true;
        });
        showText('发送成功');
        callBack!();
      } else {
        showText(data['msg']);
      }
    }
  }

  void sendVeriCode(int? type, Function? callBack) {
    if (type == 1) {
      if (_phoneNumController.text.length < 5) {
        showText("请输入正确的手机号码");
        return;
      }
    }
    if (type == 2) {
      if (_newphoneNumController.text.length < 5) {
        showText("请输入正确的手机号码");
        return;
      }
    }

    setCodeData(type, callBack);
  }

  _getNumInfo() async {
    var _number = await getProfilePage();
    await getHomeConfig(context);
    try {
      Provider.of<GlobalState>(context, listen: false)
          .setProfile(_number!['data']);
      context.pop();
    } catch (e) {}
  }

  Future setChangeData() async {
    BotToast.showLoading();
    var data = await changePhone(
      _phoneNumController.text,
      phonePrefix.replaceAll("+", ""),
      _veriCodeController.text,
      _newphoneNumController.text,
      newphonePrefix.replaceAll("+", ""),
      _newveriCodeController.text,
    );
    BotToast.closeAllLoading();
    if (data!['status'] == 0) {
      if (data['msg'] == null) {
        showText('网络错误,请稍后重试');
      } else {
        showText(data['msg']);
      }
    } else {
      showText('更换成功');
      Provider.of<HomeConfig>(context, listen: false).setLoginStatus(1);
      _getNumInfo();
    }
  }

  void onSubmit() {
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
    if (_newphoneNumController.text.isEmpty) {
      showText("请输入新手机号码");
      return;
    }
    if (_newphoneNumController.text.length < 5) {
      showText("请输入正确的新手机号码");
      return;
    }
    if (_newveriCodeController.text.length == 0) {
      showText("请输入新手机接收的验证码");
      return;
    }
    setChangeData();
  }

  void onChangeCountryCode(String countryCode) {
    phonePrefix = countryCode.toString().replaceAll('+', '');
  }

  void onChangeCountryCodeNew(String countryCode) {
    newphonePrefix = countryCode.toString().replaceAll('+', '');
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
              Text("更换手机",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      color: StyleTheme.cTitleColor,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w500)),
              SizedBox(height: 20.w),
              Text("当前手机号：+$phonePrefix ${widget.showPhone}",
                  style: TextStyle(
                      color: StyleTheme.cTitleColor, fontSize: 15.sp)),
              SizedBox(height: 20.w),
              SendCodeTextField(
                textEditingController: _veriCodeController,
                isAvailable: true,
                codeSending: codeSending,
                phonevalue: _phoneNumController.text,
                onTapCallback: (Function? callBack) {
                  sendVeriCode(1, callBack);
                },
                onCountdownEnd: () {
                  setState(() {
                    codeSending = false;
                  });
                },
              ),
              SizedBox(height: 20.w),
              PhoneAndPrefix(
                title: "输入新手机号",
                textEditingController: _newphoneNumController,
                onChanged: onChangeCountryCodeNew,
                onChangedTextField: (value) {
                  if (value.length < 5) {
                    setState(() {
                      newcodeAvailable = false;
                    });
                  } else {
                    setState(() {
                      newcodeAvailable = true;
                    });
                  }
                },
              ),
              SizedBox(height: 20.w),
              SendCodeTextField(
                textEditingController: _newveriCodeController,
                isAvailable: newcodeAvailable,
                codeSending: newcodeSending,
                phonevalue: _newphoneNumController.text,
                onTapCallback: (callBack) {
                  sendVeriCode(2, callBack);
                },
                onCountdownEnd: () {
                  setState(() {
                    newcodeSending = false;
                  });
                },
              ),
              SizedBox(height: 70.w),
              GestureDetector(
                onTap: () {
                  onSubmit();
                },
                child: SizedBox(
                  width: double.infinity,
                  height: 50.w,
                  child: Stack(
                    children: [
                      LocalPNG(
                        url: "assets/images/mine/black_button.png",
                        width: double.infinity,
                        height: 50.w,
                      ),
                      Center(
                          child: Text("确认更换",
                              style: TextStyle(
                                  color: Colors.white, fontSize: 15.sp))),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20.w),
              Center(
                  child: Text("更换后原手机号将不能用于登录",
                      style: TextStyle(
                          color: StyleTheme.cDangerColor, fontSize: 12.sp))),
            ],
          ),
        ),
      ),
    );
  }
}

class SendCodeTextField extends StatefulWidget {
  final TextEditingController? textEditingController;
  final bool? isAvailable;
  final bool? codeSending;
  final String? phonevalue;
  final Function? onTapCallback;
  final Function? onCountdownEnd;
  SendCodeTextField(
      {Key? key,
      this.textEditingController,
      this.phonevalue,
      this.isAvailable,
      this.onTapCallback,
      this.codeSending = false,
      this.onCountdownEnd})
      : super(key: key);

  @override
  _SendCodeTextFieldState createState() => _SendCodeTextFieldState();
}

class _SendCodeTextFieldState extends State<SendCodeTextField> {
  void showText(text) {
    BotToast.showText(text: '$text', align: Alignment(0, 0));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
              controller: widget.textEditingController,
              keyboardType: TextInputType.numberWithOptions(),
              maxLengthEnforcement: MaxLengthEnforcement.none,
              style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 15.w),
              decoration: InputDecoration(
                  isDense: true,
                  contentPadding:
                      EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                  border: InputBorder.none,
                  hintStyle:
                      TextStyle(color: Color(0xFFB4B4B4), fontSize: 15.sp),
                  hintText: "请输入验证码",
                  hoverColor: Colors.white),
            ),
          ),
          Container(
            width: 80.w,
            height: 25.w,
            decoration: BoxDecoration(
              color: widget.codeSending! ? Color(0xFF969696) : Colors.white,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Center(
              child: CountDown(
                available: widget.isAvailable!,
                unAvailable: () {
                  if (['', null].contains(widget.phonevalue)) {
                    showText("请输入手机号码");
                    return;
                  }
                  if (widget.phonevalue!.length < 5) {
                    showText("请输入正确的手机号码");
                    return;
                  }
                },
                onTapCallback: widget.onTapCallback,
                onCountdownEnd: widget.onCountdownEnd,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class PhoneAndPrefix extends StatefulWidget {
  final String? title;
  final Function? onChanged;
  final TextEditingController? textEditingController;
  final Function(String _)? onChangedTextField;
  PhoneAndPrefix({
    Key? key,
    this.onChanged,
    this.textEditingController,
    this.title,
    this.onChangedTextField,
  }) : super(key: key);

  @override
  _PhoneAndPrefixState createState() => _PhoneAndPrefixState();
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
            style: TextStyle(color: Colors.black, fontSize: 15.sp),
          ),
        ],
      ),
    );

class _PhoneAndPrefixState extends State<PhoneAndPrefix> {
  @override
  Widget build(BuildContext context) {
    return Container(
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
          Padding(
            padding: EdgeInsets.only(left: 10.w),
            child: CountryPickerDropdown(
                initialValue: 'CN',
                itemBuilder: _buildDropdownItem,
                dropdownColor: Colors.white,
                sortComparator: (Country a, Country b) =>
                    a.isoCode.compareTo(b.isoCode),
                onValuePicked: (Country country) {
                  widget.onChanged!(country.phoneCode);
                },
                iconSize: 20.w,
                iconDisabledColor: Colors.black,
                iconEnabledColor: Colors.black),
          ),
          Expanded(
            child: TextField(
              controller: widget.textEditingController,
              onChanged: widget.onChangedTextField,
              keyboardType: TextInputType.numberWithOptions(),
              style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 15.sp),
              decoration: InputDecoration(
                  isDense: true,
                  contentPadding:
                      EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                  border: InputBorder.none,
                  hintStyle:
                      TextStyle(color: Color(0xFFB4B4B4), fontSize: 15.sp),
                  hintText: widget.title,
                  hoverColor: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
