import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CgDialog {
  static Future<dynamic> cgShowDialog(
      BuildContext context, String title, String content, List btnText,
      {Function? callBack,
      num width = 280,
      Widget? contentWidget,
      Function? onClose}) {
    return showDialog<dynamic>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: width.w,
            padding: new EdgeInsets.symmetric(vertical: 15.w, horizontal: 25.w),
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
                        title,
                        style: TextStyle(
                            color: StyleTheme.cTitleColor,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    contentWidget != null
                        ? contentWidget
                        : Container(
                            margin: new EdgeInsets.only(top: 20.w),
                            child: Text(
                              content,
                              style: TextStyle(
                                  fontSize: 14.sp,
                                  color: StyleTheme.cTitleColor),
                            )),
                    btnText.length == 1
                        ? Center(
                            child: GestureDetector(
                              onTap: () {
                                if (callBack == null) {
                                  Navigator.of(context).pop();
                                } else {
                                  Navigator.of(context).pop();
                                  callBack();
                                }
                              },
                              child: Container(
                                  margin: EdgeInsets.only(top: 20.w),
                                  width: 200.w,
                                  height: 50.w,
                                  child: Stack(
                                    children: [
                                      LocalPNG(
                                          width: 200.w,
                                          height: 50.w,
                                          url:
                                              'assets/images/mymony/money-img.png',
                                          fit: BoxFit.fill),
                                      Center(
                                        child: Text(
                                          btnText[0],
                                          style: TextStyle(
                                              fontSize: 15.sp,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  )),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                                child: Container(
                                    margin: new EdgeInsets.only(top: 30.w),
                                    height: 50.w,
                                    width: 110.w,
                                    child: Stack(
                                      children: [
                                        LocalPNG(
                                            height: 50.w,
                                            width: 110.w,
                                            url:
                                                'assets/images/mymony/money-img.png',
                                            fit: BoxFit.fill),
                                        Center(
                                            child: Text(
                                          btnText[0],
                                          style: TextStyle(
                                              fontSize: 15.sp,
                                              color: Colors.white),
                                        )),
                                      ],
                                    )),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pop();
                                  callBack!();
                                },
                                child: Container(
                                    margin: new EdgeInsets.only(top: 30.w),
                                    height: 50.w,
                                    width: 110.w,
                                    child: Stack(
                                      children: [
                                        LocalPNG(
                                            height: 50.w,
                                            width: 110.w,
                                            url:
                                                'assets/images/mymony/money-img.png',
                                            fit: BoxFit.fill),
                                        Center(
                                            child: Text(
                                          btnText[1],
                                          style: TextStyle(
                                              fontSize: 15.sp,
                                              color: Colors.white),
                                        )),
                                      ],
                                    )),
                              )
                            ],
                          ),
                  ],
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: LocalPNG(
                          width: 30.w,
                          height: 30.w,
                          url: 'assets/images/mymony/close.png',
                          fit: BoxFit.cover)),
                )
              ],
            ),
          ),
        );
      },
    ).then((value) {
      onClose?.call();
    });
  }
}

class ChaguanDialog {
  static void showDialog({
    @required BuildContext? context,
    @required Widget? child,
  }) {
    showGeneralDialog(
      barrierColor: Colors.black.withOpacity(0.42),
      barrierLabel: 'OnlySexDialog',
      context: context!,
      barrierDismissible: true,
      transitionBuilder: (context, a1, _, child) {
        var curve = Curves.easeInOut.transform(a1.value);
        return Transform.translate(
          offset: Offset(0, 0.5.sh * (1 - curve)),
          child: Transform.scale(
            scale: curve,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) {
        return child!;
      },
    );
  }
}
