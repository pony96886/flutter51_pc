import 'dart:async';
// import 'package:country_code_picker/country_code_picker.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class YyInput extends StatefulWidget {
  YyInput(
      {Key? key,
      this.type,
      this.isPassword = false,
      this.onSubmit,
      this.hintText,
      this.autofocus = false,
      this.onChangeCountryCode,
      this.isGetCode = false,
      this.controller,
      this.onSendCode,
      this.initTime,
      this.onChange,
      this.margin = 28})
      : super(key: key);
  TextInputType? type;
  Function? onSubmit;
  String? hintText;
  bool? autofocus;
  Function? onChangeCountryCode;
  bool? isGetCode;
  String? phone;
  String? phonePrefix;
  int? sendType; //2 绑定  3 找回账号 1登录账号 4交换手机账号 5手机注册 6手机注册登录
  Function? onChange;
  TextEditingController? controller;
  Function? onSendCode;
  Function? initTime;
  bool? isPassword;
  double? margin;
  @override
  _YyInputState createState() => _YyInputState();
}

class _YyInputState extends State<YyInput> {
  final inputController = TextEditingController();
  FocusNode _commentFocus = FocusNode();
  int codeStatus = 0; //0 获取验证码   1 正在倒计时  2 重新获取验证码
  int timers = 60;
  String codeText = '获取验证码';
  Timer? timefc;
  bool isPassword = true;
  @override
  void dispose() {
    super.dispose();
    timefc!.cancel();
  }

  @override
  void initState() {
    super.initState();
    isPassword = widget.isPassword!;
  }

  Function? _startTime() {
    timefc = Timer.periodic(Duration(seconds: 1), (Timer? timer) {
      timers--;
      if (timers <= 0) {
        //取消定时器，避免无限回调
        codeStatus = 2;
        codeText = '重新获取';
        timers = 60;
        timer!.cancel();
        timer = null;
      } else {
        codeStatus = 1;
        codeText = '${timers}S';
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        FocusScope.of(context).requestFocus(_commentFocus);
      },
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(top: ScreenUtil().setWidth(widget.margin!)),
        padding: EdgeInsets.symmetric(
            // vertical: ScreenUtil().setWidth(10),
            horizontal: ScreenUtil().setWidth(9.5)),
        height: ScreenUtil().setWidth(50),
        decoration: BoxDecoration(
            border: Border.all(
                width: ScreenUtil().setWidth(0.5), color: Colors.white54)),
        child: Row(
          children: [
            widget.onChangeCountryCode == null
                ? Container()
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: ScreenUtil().setWidth(40),
                        // child: CountryCodePicker(
                        //   textStyle: TextStyle(
                        //       color: Color(0xff282828), fontSize: 14.sp),
                        //   onChanged: widget.onChangeCountryCode,
                        //   padding: EdgeInsets.symmetric(horizontal: 0),
                        //   initialSelection: 'CN',
                        //   favorite: ['+86', 'CN'],
                        //   showFlag: false,
                        //   enabled: true,
                        //   showFlagDialog: true,
                        //   showCountryOnly: false,
                        //   showOnlyCountryWhenClosed: false,
                        //   alignLeft: false,
                        // ),
                      ),
                      Container(
                        width: ScreenUtil().setWidth(0.5),
                        height: ScreenUtil().setWidth(15),
                        color: Color(0xffffffff),
                      )
                    ],
                  ),
            Expanded(
                child: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(10)),
              child: RepaintBoundary(
                child: TextField(
                    obscureText: isPassword,
                    focusNode: _commentFocus,
                    keyboardType: widget.type,
                    autofocus: widget.autofocus!,
                    onChanged: (e) {
                      widget.onChange!(e);
                    },
                    onSubmitted: (e) {
                      widget.onSubmit!(e);
                    },
                    controller: widget.controller != null
                        ? widget.controller
                        : inputController,
                    style: TextStyle(
                        fontSize: ScreenUtil().setSp(13),
                        color: Color(0XFFffffff)),
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                        hintText: widget.hintText ?? '请输入内容',
                        hintStyle: TextStyle(color: Color(0xffd7d7d7)),
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                        disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide(
                                color: Colors.transparent, width: 0)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide(
                                color: Colors.transparent, width: 0)),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide(
                                color: Colors.transparent, width: 0)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide(
                                color: Colors.transparent, width: 0)))),
              ),
            )),
            widget.isPassword!
                ? GestureDetector(
                    onTap: () {
                      isPassword = !isPassword;
                      setState(() {});
                    },
                    child: Container(
                      padding: EdgeInsets.only(left: ScreenUtil().setWidth(15)),
                      child: LocalPNG(
                        url:
                            'assets/pengke/ps_${isPassword ? 'on' : 'off'}.png',
                        width: ScreenUtil().setWidth(20.7),
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  )
                : Container(
                    width: ScreenUtil().setWidth(20.7),
                    height: ScreenUtil().setWidth(20),
                    color: Colors.transparent,
                  ),
            widget.isGetCode!
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: ScreenUtil().setWidth(0.5),
                        height: ScreenUtil().setWidth(15),
                        color: Color(0xffededed),
                      ),
                      SizedBox(
                        width: ScreenUtil().setWidth(10),
                      ),
                      GestureDetector(
                        onTap: () {
                          widget.initTime!(_startTime);
                          widget.onSendCode!();
                        },
                        child: Container(
                          width: ScreenUtil().setWidth(75),
                          height: ScreenUtil().setWidth(24.5),
                          decoration: BoxDecoration(
                              border: Border.all(
                                  width: ScreenUtil().setWidth(0.5),
                                  color: Color(0xff7bf7ff)),
                              borderRadius: BorderRadius.circular(
                                  ScreenUtil().setWidth(12.25))),
                          child: Center(
                            child: Text(
                              codeText,
                              style: TextStyle(
                                  color: Color(0xff7bf7ff),
                                  fontSize: ScreenUtil().setSp(11)),
                            ),
                          ),
                        ),
                      )
                    ],
                  )
                : Container()
          ],
        ),
      ),
    );
  }
}
