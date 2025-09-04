import 'dart:async';
import 'package:chaguaner2023/components/imageCode.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:flutter/material.dart';

/// 墨水瓶（`InkWell`）可用时使用的字体样式。
final TextStyle _availableStyle = TextStyle(
  fontSize: CommonUtils.getFontSize(24),
  color: StyleTheme.cTitleColor,
);

/// 墨水瓶（`InkWell`）不可用时使用的样式。
final TextStyle _unavailableStyle = TextStyle(
  fontSize: CommonUtils.getFontSize(24),
  color: const Color(0xFFFFFFFF),
);

class CountDown extends StatefulWidget {
  // 倒计时的秒数，默认60秒。
  final int countdown;
  // 用户点击时的回调函数。
  final Function? onTapCallback;
  // 倒计时结束的回调函数
  final Function? onCountdownEnd;
  // 是否可以获取验证码，默认为`false`。
  final bool available;
  // 无法获取验证码点击的回调函数
  final Function? unAvailable;

  CountDown({
    Key? key,
    this.countdown = 60,
    this.onTapCallback,
    this.onCountdownEnd,
    this.available = false,
    this.unAvailable,
  }) : super(key: key);

  @override
  _CountDownState createState() => _CountDownState();
}

class _CountDownState extends State<CountDown> {
  TextEditingController _codeController = TextEditingController();

  /// 倒计时的计时器。
  Timer? _timer;

  /// 当前倒计时的秒数。
  int _seconds = 0;

  /// 当前墨水瓶（`InkWell`）的字体样式。
  TextStyle inkWellStyle = _availableStyle;

  /// 当前墨水瓶（`InkWell`）的文本。
  String _verifyStr = '发送验证码';

  @override
  void initState() {
    super.initState();
    _seconds = widget.countdown;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// 启动倒计时的计时器。
  void _startTimer() {
    // 计时器（`Timer`）组件的定期（`periodic`）构造函数，创建一个新的重复计时器。
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_seconds == 0) {
        _cancelTimer();
        _seconds = widget.countdown;
        inkWellStyle = _availableStyle;
        widget.onCountdownEnd!();
        return;
      }
      _seconds--;
      _verifyStr = '$_seconds' + 's';
      setState(() {});
      if (_seconds == 0) {
        _verifyStr = '重新发送';
      }
    });
  }

  /// 取消倒计时的计时器。
  void _cancelTimer() {
    // 计时器（`Timer`）组件的取消（`cancel`）方法，取消计时器。
    _timer!.cancel();
  }

  Future<String?> showImgCode() {
    return showDialog<String?>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: CommonUtils.getWidth(600),
            padding: new EdgeInsets.symmetric(
                vertical: CommonUtils.getWidth(30),
                horizontal: CommonUtils.getWidth(50)),
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
                            fontSize: CommonUtils.getFontSize(36),
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      height: CommonUtils.getWidth(43),
                    ),
                    ImageCode(),
                    SizedBox(
                      height: CommonUtils.getWidth(34),
                    ),
                    Container(
                      height: CommonUtils.getWidth(88),
                      decoration: BoxDecoration(
                          color: Color(0xfff5f5f5),
                          border: Border.all(
                              width: CommonUtils.getWidth(1),
                              color: Color(0xffe6e6e6))),
                      child: Center(
                        child: TextField(
                          controller: _codeController,
                          onChanged: (value) {},
                          keyboardType: TextInputType.text,
                          style: TextStyle(
                              color: Color(0xff808080),
                              fontSize: CommonUtils.getFontSize(30)),
                          decoration: InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.only(
                                  left: 10, right: 10, top: 5, bottom: 5),
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                  color: Color(0xFF969696),
                                  fontSize: CommonUtils.getFontSize(30)),
                              hintText: "请输入图形验证码",
                              hoverColor: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: CommonUtils.getWidth(40),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop(_codeController.text);
                      },
                      child: Container(
                        width: double.infinity,
                        height: CommonUtils.getWidth(80),
                        decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(CommonUtils.getWidth(40)),
                            gradient: LinearGradient(
                              colors: [Color(0xfffbad3e), Color(0xffffedb5)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            )),
                        child: Center(
                          child: Text(
                            '确定',
                            style: TextStyle(
                                color: Color(0xff903600),
                                fontSize: CommonUtils.getFontSize(28)),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                Positioned(
                  right: CommonUtils.getWidth(0),
                  top: CommonUtils.getWidth(0),
                  child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: LocalPNG(
                          url: 'assets/images/mymony/close.png',
                          width: CommonUtils.getWidth(60),
                          height: CommonUtils.getWidth(60),
                          fit: BoxFit.cover)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // 墨水瓶（`InkWell`）组件，响应触摸的矩形区域。
    return widget.available
        ? InkWell(
            child: Text(
              '  $_verifyStr  ',
              style: inkWellStyle,
            ),
            onTap: (_seconds == widget.countdown)
                ? () {
                    // showImgCode().then((value) {
                    //   UserInfo.imageCode = value;
                    //   _codeController.clear();
                    widget.onTapCallback!(() {
                      _startTimer();
                      inkWellStyle = _unavailableStyle;
                      _verifyStr = '$_seconds' + 's';
                      // UserInfo.imageCode = null;
                      setState(() {});
                      // });
                    });
                  }
                : null,
          )
        : InkWell(
            child: Text(
              '发送验证码',
              style: _availableStyle,
            ),
            onTap: () {
              // showImgCode().then((value) {
              // UserInfo.imageCode = value;
              // _codeController.clear();
              widget.unAvailable!();
              // UserInfo.imageCode = null;
              // });
            },
          );
  }
}
