import 'package:bot_toast/bot_toast.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PopupBox {
  static void showText(
    BackButtonBehavior backButtonBehavior, {
    VoidCallback? cancel,
    VoidCallback? confirm,
    String? title,
    String? text,
    String? canceltext,
    String? confirmtext,
    bool showCancel = false,
    bool tapMaskClose = false,
  }) {
    BotToast.showWidget(
        toastBuilder: (cancelFunc) => GestureDetector(
              onTap: () {
                if (tapMaskClose) {
                  cancelFunc();
                }
              },
              child: Container(
                width: double.infinity,
                height: double.infinity,
                padding: EdgeInsets.all(57.5.w),
                decoration: BoxDecoration(color: Colors.black38),
                child: Center(
                    child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 1.sw / 1.5,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.w),
                    ),
                    child: Stack(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(
                              top: ScreenUtil().statusBarHeight),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Container(
                                  padding: EdgeInsets.only(top: 15.w),
                                  child: Center(
                                    child: Text(
                                      title!.isEmpty ? '温馨提示' : title,
                                      style: TextStyle(
                                          decoration: TextDecoration.none,
                                          color: StyleTheme.cTitleColor,
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20.w),
                                Container(
                                    padding: EdgeInsets.only(
                                        bottom: 25.w, left: 20.w, right: 20.w),
                                    child: Text(
                                      text!,
                                      style: TextStyle(
                                          decoration: TextDecoration.none,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 14.sp,
                                          color: StyleTheme.cTitleColor),
                                    )),
                                Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 15.w, horizontal: 10.w),
                                    child: Row(
                                      mainAxisAlignment: showCancel
                                          ? MainAxisAlignment.spaceBetween
                                          : MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        showCancel
                                            ? Expanded(
                                                child: GestureDetector(
                                                onTap: () {
                                                  cancel!.call();
                                                  cancelFunc();
                                                },
                                                child: SizedBox(
                                                  height: 50.w,
                                                  child: Stack(
                                                    children: [
                                                      LocalPNG(
                                                          width:
                                                              double.infinity,
                                                          height:
                                                              double.infinity,
                                                          url:
                                                              'assets/images/elegantroom/button-flex.png',
                                                          fit: BoxFit.fill),
                                                      Padding(
                                                        padding: EdgeInsets.all(
                                                            10.w),
                                                        child: Center(
                                                            child: Text(
                                                          canceltext!.isEmpty
                                                              ? '取消'
                                                              : canceltext,
                                                          style: TextStyle(
                                                              decoration:
                                                                  TextDecoration
                                                                      .none,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              fontSize: 14.sp,
                                                              color:
                                                                  Colors.white),
                                                        )),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ))
                                            : SizedBox(),
                                        showCancel
                                            ? SizedBox(width: 20.w)
                                            : SizedBox(),
                                        Expanded(
                                            child: GestureDetector(
                                          onTap: () {
                                            confirm?.call();
                                            cancelFunc();
                                          },
                                          child: SizedBox(
                                            height: 50.w,
                                            child: Stack(
                                              children: [
                                                LocalPNG(
                                                    width: double.infinity,
                                                    height: 50.w,
                                                    url:
                                                        'assets/images/elegantroom/button-flex.png',
                                                    fit: BoxFit.fill),
                                                Padding(
                                                  padding: EdgeInsets.all(10.w),
                                                  child: Center(
                                                      child: Text(
                                                    confirmtext!.isEmpty
                                                        ? '确定'
                                                        : confirmtext,
                                                    style: TextStyle(
                                                        decoration:
                                                            TextDecoration.none,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 14.sp,
                                                        color: Colors.white),
                                                  )),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ))
                                      ],
                                    ))
                              ]),
                        ),
                        Positioned(
                          right: 10.w,
                          top: 10.w,
                          child: GestureDetector(
                              onTap: () => cancelFunc(),
                              child: LocalPNG(
                                  width: 25.w,
                                  height: 25.w,
                                  url: 'assets/images/closeicon.png',
                                  fit: BoxFit.cover)),
                        )
                      ],
                    ),
                  ),
                )),
              ),
            ));
  }
}
