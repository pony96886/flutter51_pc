import 'package:bot_toast/bot_toast.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

typedef WidgetFunction = Function(Function cancel);

class YyDialog extends StatefulWidget {
  final Widget? child; //子Widget
  final Function? toPageCallback; //当content为null时会触发该事件（点击直接触发，不弹框）
  final Function? callBack; //点击确认时的回调。为null时点击会关闭弹窗
  final String? title; //标题
  final Function? content; //内容
  final String? btnText; //按钮内容
  final Function? clickCallBack; //点击立即触发
  final bool? isClick; //是否开启点击立即触发；
  final Function? changeBtnText;
  final Function? cancelBack;
  final bool? clear; //关闭是否修改状态
  final bool hideClose; //关闭是否修改状态
  YyDialog(
      {Key? key,
      this.child,
      this.clear = false,
      this.callBack,
      this.title,
      this.content,
      this.btnText,
      this.toPageCallback,
      this.clickCallBack,
      this.isClick,
      this.cancelBack,
      this.changeBtnText,
      this.hideClose = false})
      : super(key: key);

  @override
  YyDialogState createState() => YyDialogState();
}

class YyDialogState extends State<YyDialog> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.isClick!) {
          widget.clickCallBack!();
          return;
        }
        if (widget.content == null) {
          widget.toPageCallback!();
        } else {
          YyShowDialog.showdialog(context,
              title: widget.title!,
              clear: widget.clear!,
              content: widget.content!,
              cancelBack: widget.cancelBack!,
              changeBtnText: widget.changeBtnText!,
              callBack: widget.callBack!,
              hideClose: widget.hideClose,
              btnText: widget.btnText!);
        }
      },
      child: widget.child,
    );
  }
}

class YyShowDialog {
  static void showSelectPublish({
    Function? onImage,
    Function? onVideo,
  }) {
    BotToast.showWidget(
      toastBuilder: (cancelFunc) => AnimationBox(build: (controller) {
        return GestureDetector(
          onTap: () {
            controller.reverse().then((value) {
              cancelFunc();
            });
          },
          child: Material(
            color: Colors.transparent,
            child: Container(
              constraints: BoxConstraints(
                maxHeight: ScreenUtil().screenHeight,
              ),
              width: ScreenUtil().screenWidth,
              padding: EdgeInsets.only(
                  top: kIsWeb ? 0 : ScreenUtil().statusBarHeight,
                  bottom: kIsWeb ? 0 : ScreenUtil().bottomBarHeight),
              decoration: BoxDecoration(color: Colors.transparent),
              child: Center(
                  child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.w),
                    color: Colors.black.withOpacity(0.7)),
                width: 335.w,
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        controller.reverse().then((value) {
                          cancelFunc();
                          onImage!();
                        });
                      },
                      child: Container(
                        alignment: Alignment.center,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            border: Border.all(width: 1.w, color: Colors.white),
                            borderRadius: BorderRadius.circular(10.w)),
                        height: 54.w,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/images/home/icon_image.png',
                              width: 18.w,
                              fit: BoxFit.fitWidth,
                            ),
                            SizedBox(
                              width: 10.w,
                            ),
                            Text(
                              '发布图片',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 16.sp),
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.w,
                    ),
                    GestureDetector(
                      onTap: () {
                        controller.reverse().then((value) {
                          cancelFunc();
                          onVideo!();
                        });
                      },
                      child: Container(
                        alignment: Alignment.center,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            border: Border.all(width: 1.w, color: Colors.white),
                            borderRadius: BorderRadius.circular(10.w)),
                        height: 54.w,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/images/home/icon_video.png',
                              width: 18.w,
                              fit: BoxFit.fitWidth,
                            ),
                            SizedBox(
                              width: 10.w,
                            ),
                            Text(
                              '发布视频',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 16.sp),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              )),
            ),
          ),
        );
      }),
    );
  }

  static Future<dynamic> showdialog(BuildContext context,
      {String? title,
      Function? content,
      bool clear = false,
      bool hideClose = false,
      Function? callBack,
      Function? cancelBack,
      Function? closeCallBack,
      String? btnText,
      String? cancelText,
      Function? changeBtnText,
      bool noCancel = false,
      bool prohibitClose = false}) {
    return showDialog<dynamic>(
      context: context,
      barrierDismissible: prohibitClose ? false : true,
      builder: (context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          if (changeBtnText != null) {
            btnText = changeBtnText();
          }
          return AnimationBox(
            onTabMask: (AnimationController controller) {
              if (!prohibitClose) {
                controller.reverse().then((value) {
                  Navigator.pop(context);
                });
              }
            },
            build: (AnimationController controller) {
              return Dialog(
                backgroundColor: Colors.transparent,
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.w)),
                      width: 300.w,
                      padding: new EdgeInsets.only(
                          left: 24.5.w,
                          right: 24.5.w,
                          top: (title == null ? 14 : 25).w,
                          bottom: 15.w),
                      child: Stack(
                        clipBehavior: Clip.hardEdge,
                        children: <Widget>[
                          SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                title == null
                                    ? Container()
                                    : Center(
                                        child: Text(
                                          title,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Color(0xff000000),
                                              fontSize: ScreenUtil().setSp(24),
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                Container(
                                    margin: new EdgeInsets.only(
                                        top: ScreenUtil().setWidth(26)),
                                    child: content!(setDialogState)),
                                SizedBox(
                                  height: 20.w,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    GestureDetector(
                                        onTap: () {
                                          if (callBack == null) {
                                            controller.reverse().then((value) {
                                              Navigator.pop(context);
                                            });
                                          } else {
                                            controller.reverse().then((value) {
                                              Navigator.pop(context);
                                              if (!noCancel) {
                                                callBack();
                                              }
                                            });
                                          }
                                        },
                                        child: Container(
                                          width: 150.w,
                                          height: 50.w,
                                          margin: EdgeInsets.only(
                                              bottom:
                                                  ScreenUtil().bottomBarHeight +
                                                      15.w),
                                          child: Stack(
                                            children: [
                                              LocalPNG(
                                                width: double.infinity,
                                                height: 50.w,
                                                url:
                                                    "assets/images/mine/black_button.png",
                                              ),
                                              Center(
                                                  child: Text(btnText ?? "我知道了",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 15.sp))),
                                            ],
                                          ),
                                        ))
                                  ],
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          );
        });
      },
    ).then((value) {
      if (closeCallBack != null) {
        closeCallBack();
      }
      return;
      // if (clear) {
      //   cancelBack();
      // }
    });
  }

  static Future<dynamic> showPopWindow(BuildContext context,
      {WidgetFunction? child,
      Alignment alignment = Alignment.bottomCenter,
      EdgeInsets pading = EdgeInsets.zero}) {
    return showDialog<dynamic>(
        context: context,
        barrierColor: Colors.transparent,
        barrierDismissible: true,
        builder: (context) {
          return AnimationBox(
            onTabMask: (AnimationController controller) {
              controller.reverse().then((value) {
                Navigator.pop(context);
              });
            },
            build: (AnimationController controller) {
              return Dialog(
                elevation: 0,
                backgroundColor: Colors.transparent,
                insetPadding: pading,
                alignment: alignment,
                child: child!(() {
                  controller.reverse().then((value) {
                    Navigator.pop(context);
                  });
                }),
              );
            },
          );
        });
  }
}

class AnimationBoxState {
  static Map<int, AnimationController> animationController = {};
  static int key = 0;
}

class AnimationBox extends StatefulWidget {
  AnimationBox({Key? key, this.child, this.onTabMask, this.build})
      : super(key: key);
  final Widget? child;
  final Function? onTabMask;
  final AnimationBoxBuider? build;
  @override
  _AnimationBoxState createState() => _AnimationBoxState();
}

typedef AnimationBoxBuider = Function(AnimationController controller);

class _AnimationBoxState extends State<AnimationBox>
    with SingleTickerProviderStateMixin {
  int? key;
  @override
  void initState() {
    super.initState();
    AnimationBoxState.key++;
    key = AnimationBoxState.key;
    AnimationBoxState.animationController[key!] =
        AnimationController(duration: Duration(milliseconds: 300), vsync: this)
          ..drive(CurveTween(curve: Curves.easeIn));
    AnimationBoxState.animationController[key]!.forward();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    AnimationBoxState.animationController[key]!.dispose();
    AnimationBoxState.animationController.remove(key);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AnimationBoxState.animationController[key]!,
      builder: (context, child) {
        return Opacity(
          opacity: AnimationBoxState.animationController[key]!.value,
          child: Stack(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  widget.onTabMask!(AnimationBoxState.animationController[key]);
                },
                child: Container(
                  color: Colors.black54,
                ),
              ),
              Transform.translate(
                offset: Offset(
                    0,
                    (0.5.sh *
                        (1 -
                            AnimationBoxState
                                .animationController[key]!.value))),
                child: Center(
                  child: Transform.scale(
                    alignment: Alignment.center,
                    scale: AnimationBoxState.animationController[key]!.value,
                    child: child,
                  ),
                ),
              )
            ],
          ),
        );
      },
      child: widget.build!(AnimationBoxState.animationController[key]!),
    );
  }
}
