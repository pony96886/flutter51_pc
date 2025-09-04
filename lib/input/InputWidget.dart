import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// 返回的内容去除所有空格

class InputWidget extends StatefulWidget {
  final String? tips;
  final int? limitingText;
  final TextInputType? boardType;
  final String? btnText;
  final Widget? btnWidget;
  final Function? onChange;
  final Function? onSubmit;
  InputWidget(
      {Key? key,
      this.tips,
      this.limitingText = 9999,
      this.boardType = TextInputType.text,
      this.btnText,
      this.btnWidget,
      this.onChange,
      this.onSubmit})
      : super(key: key);

  @override
  _InputWidgetState createState() => _InputWidgetState();
}

class _InputWidgetState extends State<InputWidget> with WidgetsBindingObserver {
  TextEditingController editingController = TextEditingController();
  FocusNode focusNode = new FocusNode();
  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      WidgetsBinding.instance.addObserver(this);
      // WidgetsBinding.instance.addPostFrameCallback((_) {
      ///获取输入框焦点
      // Future.delayed(Duration(milliseconds: 300), () {
      //   FocusScope.of(context).requestFocus(focusNode);
      // });
      // });
    }
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    if (kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (MediaQuery.of(context).viewInsets.bottom == 0) {
          focusNode.unfocus();
        }
      });
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    if (kIsWeb) {
      WidgetsBinding.instance.removeObserver(this);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
          onTap: () {
            focusNode.unfocus();
          },
          child: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Expanded(
                  child: GestureDetector(
                      onTapDown: (_) {
                        focusNode.unfocus();
                        Navigator.pop(context);
                      },
                      child: Container(
                        color: Colors.black45,
                      )),
                ),
                Container(
                  decoration: BoxDecoration(color: Color(0xffffffff)),
                  height: 50.w,
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(left: 10.w, right: 10.w),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                    width: 0.5.w, color: Color(0xff282828)),
                                borderRadius:
                                    BorderRadiusDirectional.circular(18.w)),
                            // padding: EdgeInsets.only(right: 10.w, left: 10.w),
                            height: ScreenUtil().setWidth(36),
                            alignment: Alignment.center,
                            child: Row(
                              children: [
                                Flexible(
                                    child: RepaintBoundary(
                                  child: TextField(
                                    focusNode: focusNode,
                                    inputFormatters: [
                                      LengthLimitingTextInputFormatter(
                                          widget.limitingText), // 限制输入最多10个字符
                                    ],
                                    onChanged: (e) {
                                      widget.onChange?.call(e);
                                    },
                                    onSubmitted: (value) {
                                      if (value.isNotEmpty) {
                                        if (widget.onSubmit != null) {
                                          widget.onSubmit!(value);
                                          Navigator.pop(context);
                                        } else {
                                          Navigator.pop(context);
                                        }
                                      } else {
                                        BotToast.showText(
                                            text: widget.tips!,
                                            align: Alignment(0, 0));
                                      }
                                    },
                                    style: TextStyle(
                                        color: Color(0xff000000),
                                        fontSize: 14.sp),
                                    keyboardType: widget.boardType,
                                    textInputAction: TextInputAction.send,
                                    autofocus: !kIsWeb,
                                    maxLengthEnforcement:
                                        MaxLengthEnforcement.none,
                                    controller: editingController,
                                    decoration: InputDecoration(
                                        isDense: true,
                                        contentPadding: EdgeInsets.only(
                                            left: 10,
                                            right: 10,
                                            top: 5,
                                            bottom: 5),
                                        border: InputBorder.none,
                                        hintStyle: TextStyle(
                                            color: Color(0xff999999),
                                            fontSize: 14.sp),
                                        hintText: widget.tips),
                                  ),
                                )),
                              ],
                            )),
                      ),
                      widget.btnWidget != null
                          ? widget.btnWidget!
                          : GestureDetector(
                              onTap: () {
                                widget.onSubmit?.call(editingController.text);
                                Navigator.of(context)
                                    .pop(editingController.text);
                              },
                              child: Container(
                                height: 30.w,
                                width: 80.w,
                                alignment: Alignment.center,
                                margin: EdgeInsets.only(left: 10.w),
                                decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(15)),
                                child: Text(
                                  widget.btnText ?? '提交',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 14.sp),
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
                // emojiH == 0
                //     ? Container()
                //     : Container(
                //         height: emojiH,
                //         child: EmojiPicker(
                //           onEmojiSelected: (category, emoji) {
                //             editingController.text += emoji.emoji;
                //           },
                //           onBackspacePressed: () {
                //             editingController
                //               ..text = editingController.text.characters
                //                   .skipLast(1)
                //                   .toString()
                //               ..selection = TextSelection.fromPosition(TextPosition(
                //                   offset: editingController.text.length));
                //           },
                //           config: Config(),
                //         ),
                //       )
              ],
            ),
          )),
    );
  }
}
