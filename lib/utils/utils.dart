import 'dart:convert';
import 'dart:math';

import 'package:bot_toast/bot_toast.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/style_theme.dart';
import 'cache/cache_manager.dart';
import 'encdecrypt.dart';

class Utils {
  static Map _cacheJSON = {}; //全局使用

  //随机字符串
  static String randomId(int range) {
    String str = "";
    List<String> arr = [
      "0",
      "1",
      "2",
      "3",
      "4",
      "5",
      "6",
      "7",
      "8",
      "9",
      "a",
      "b",
      "c",
      "d",
      "e",
      "f",
      "g",
      "h",
      "i",
      "j",
      "k",
      "l",
      "m",
      "n",
      "o",
      "p",
      "q",
      "r",
      "s",
      "t",
      "u",
      "v",
      "w",
      "x",
      "y",
      "z",
      "A",
      "B",
      "C",
      "D",
      "E",
      "F",
      "G",
      "H",
      "I",
      "J",
      "K",
      "L",
      "M",
      "N",
      "O",
      "P",
      "Q",
      "R",
      "S",
      "T",
      "U",
      "V",
      "W",
      "X",
      "Y",
      "Z"
    ];
    for (int i = 0; i < range; i++) {
      int pos = Random().nextInt(arr.length - 1);
      str += arr[pos];
    }
    return str;
  }

  //自定义对话框
  static showDialog({
    String? cancelTxt,
    String? confirmTxt = "确定",
    VoidCallback? cancel,
    VoidCallback? confirm,
    VoidCallback? backgroundReturn,
    Function? setContent,
  }) {
    return BotToast.showAnimationWidget(
      clickClose: false,
      allowClick: false,
      onlyOne: false,
      crossPage: true,
      backButtonBehavior: BackButtonBehavior.none,
      wrapToastAnimation: (controller, cancel, child) => Stack(
        children: [
          GestureDetector(
            onTap: () {
              backgroundReturn?.call();
            },
            //The DecoratedBox here is very important,he will fill the entire parent component
            child: AnimatedBuilder(
              builder: (_, child) => Opacity(
                opacity: controller.value,
                child: child,
              ),
              child: const DecoratedBox(
                decoration: BoxDecoration(color: Colors.black38),
                child: SizedBox.expand(),
              ),
              animation: controller,
            ),
          ),
          AnimatedBuilder(
            child: child,
            animation: controller,
            builder: (context, child) {
              Tween<Offset> tweenOffset = Tween<Offset>(
                begin: const Offset(0.0, 0.8),
                end: Offset.zero,
              );
              Tween<double> tweenScale = Tween<double>(begin: 0.3, end: 1.0);
              Animation<double> animation = CurvedAnimation(parent: controller, curve: Curves.decelerate);
              return FractionalTranslation(
                translation: tweenOffset.evaluate(animation),
                child: ClipRect(
                  child: Transform.scale(
                    scale: tweenScale.evaluate(animation),
                    child: Opacity(
                      child: child,
                      opacity: animation.value,
                    ),
                  ),
                ),
              );
            },
          )
        ],
      ),
      toastBuilder: (cancelFunc) {
        return Center(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 40.w),
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
                color: const Color.fromRGBO(44, 43, 61, 1), borderRadius: BorderRadius.all(Radius.circular(5.w))),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RichText(
                  text: TextSpan(text: "温馨提示", style: StyleTheme.font_white_08_15),
                  maxLines: 1,
                ),
                SizedBox(height: 15.w),
                if (setContent != null) setContent.call(),
                SizedBox(height: 15.w),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    cancelTxt == null
                        ? Container()
                        : GestureDetector(
                            onTap: () {
                              cancelFunc();
                              cancel?.call();
                            },
                            child: Container(
                              height: 32.w,
                              padding: EdgeInsets.symmetric(horizontal: 20.w),
                              decoration: BoxDecoration(
                                color: StyleTheme.gray102Color,
                                borderRadius: BorderRadius.all(Radius.circular(3.w)),
                              ),
                              child: Center(
                                  child: RichText(
                                text: TextSpan(children: [
                                  TextSpan(
                                    text: cancelTxt,
                                    style: StyleTheme.font(size: 14),
                                  ),
                                ]),
                              )),
                            ),
                          ),
                    SizedBox(width: cancelTxt == null ? 0 : 30.w),
                    confirmTxt == null
                        ? Container()
                        : GestureDetector(
                            onTap: () {
                              cancelFunc();
                              confirm?.call();
                            },
                            child: Container(
                              height: 32.w,
                              padding: EdgeInsets.symmetric(horizontal: 20.w),
                              decoration: BoxDecoration(
                                  gradient: StyleTheme.gradYellow,
                                  borderRadius: BorderRadius.all(Radius.circular(3.w))),
                              alignment: Alignment.center,
                              child: Center(
                                  child: RichText(
                                      text: TextSpan(children: [
                                TextSpan(
                                  text: confirmTxt,
                                  style: StyleTheme.font_white_08_14,
                                )
                              ]))),
                            ),
                          )
                  ],
                ),
              ],
            ),
          ),
        );
      },
      animationDuration: const Duration(milliseconds: 300),
    );
  }
}
