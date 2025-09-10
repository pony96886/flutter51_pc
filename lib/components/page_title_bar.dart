/*
 * @Author: Tom
 * @Date: 2021-12-27 16:56:56
 * @LastEditTime: 2021-12-27 17:00:56
 * @LastEditors: Tom
 * @Description: 
 * @FilePath: /flutter2021/lib/components/common/page_title_bar.dart
 */
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/widget_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

// ignore: must_be_immutable
class PageTitleBar extends StatefulWidget {
  PageTitleBar(
      {Key? key,
      this.title,
      this.rightWidget,
      this.centerWidget,
      this.height,
      this.isIm = false,
      this.isNoback = false,
      this.bgColor = Colors.transparent,
      this.backColor,
      this.color,
      this.onback,
      this.onlineText})
      : super(key: key);
  final String? title;
  final Widget? rightWidget;
  final Widget? centerWidget;
  final double? height;
  final bool isIm;
  final bool isNoback;
  final Color? bgColor;
  final Color? backColor;
  final Color? color;
  final Function? onback;
  final String? onlineText;
  @override
  _PageTitleBarState createState() => _PageTitleBarState();
}

class _PageTitleBarState extends State<PageTitleBar> {
  bool inOnline = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
            color: widget.bgColor,
            alignment: Alignment.center,
            width: ScreenUtil().screenWidth,
            padding: EdgeInsets.only(top: ScreenUtil().statusBarHeight),
            height: 47.w + ScreenUtil().statusBarHeight,
            child: Container(
              alignment: Alignment.center,
              width: ScreenUtil().screenWidth * 0.8,
              child: widget.isIm
                  ? Column(children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                              child: Text(
                            widget.title ?? '标题',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(color: widget.color ?? Color(0xff282828), fontSize: 18.sp),
                          ).toEmoji()),
                          SizedBox(
                            width: 5.w,
                          ),
                          widget.isIm
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(4.w),
                                  child: Container(
                                    color: widget.onlineText == '对方在线' ? Color(0xff35c435) : Color(0xff999999),
                                    width: 8.w,
                                    height: 8.w,
                                  ),
                                )
                              : Container()
                        ],
                      ),
                      widget.isIm
                          ? Text(
                              widget.onlineText!,
                              style: TextStyle(
                                  color: widget.onlineText == '对方在线' ? Colors.red : Colors.black.withOpacity(0.6),
                                  fontSize: 11.sp),
                            )
                          : Container()
                    ])
                  : (widget.centerWidget ??
                      Text(
                        widget.title ?? '标题',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(color: widget.color ?? Color(0xff282828), fontSize: 20.sp),
                      ).toEmoji()),
            )),
        Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            top: ScreenUtil().statusBarHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                widget.isNoback
                    ? Container()
                    : Padding(
                        padding: EdgeInsets.only(right: 10.w, top: 5.w, bottom: 5.w),
                        child: GestureDetector(
                          onTap: () {
                            if (widget.onback == null) {
                              context.pop();
                            } else {
                              widget.onback?.call();
                            }
                            return;
                            // if (AppGlobal.isFull) {
                            //   AppGlobal.isFull = false;
                            //   SystemChrome.setPreferredOrientations([
                            //     DeviceOrientation.portraitUp,
                            //   ]);
                            // } else {
                            //   Navigator.pop(context);
                            // }
                          },
                          behavior: HitTestBehavior.translucent,
                          child: Container(
                            alignment: Alignment.center,
                            height: double.infinity,
                            padding: EdgeInsets.symmetric(horizontal: 10.w),
                            child: IgnorePointer(
                              child: Padding(
                                padding: EdgeInsets.only(right: 20.0),
                                child: Icon(
                                  Icons.arrow_back_ios,
                                  size: 25.w,
                                  color: widget.color ?? widget.backColor ?? Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: widget.rightWidget ?? Container(),
                )
              ],
            ))
      ],
    );
  }
}
