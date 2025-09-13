import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CgDialog {
  static Future<dynamic> cgShowDialog(BuildContext context, String title, String content, List btnText,
      {Function? callBack, num width = 280, Widget? contentWidget, Function? onClose}) {
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
                    if (title.isNotEmpty)
                      Center(
                        child: Text(
                          title,
                          style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 18.sp, fontWeight: FontWeight.bold),
                        ),
                      ),
                    contentWidget ??
                        Container(
                            margin: new EdgeInsets.only(top: 20.w),
                            child: Text(
                              content,
                              style: TextStyle(fontSize: 14.sp, color: StyleTheme.cTitleColor),
                            )),
                    _buildButtonArea(context, btnText, callBack: callBack, width: width),
                  ],
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: LocalPNG(
                          width: 30.w, height: 30.w, url: 'assets/images/mymony/close.png', fit: BoxFit.cover)),
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

  static Widget _buildButton(String text, double width, double topMargin, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(top: topMargin),
        width: width,
        height: 50.w,
        child: Stack(
          children: [
            LocalPNG(
              width: width,
              height: 50.w,
              url: 'assets/images/mymony/money-img.png',
              fit: BoxFit.fill,
            ),
            Center(
              child: Text(
                text,
                style: TextStyle(fontSize: 15.sp, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildButtonArea(BuildContext context, List btnText, {Function? callBack, num width = 280}) {
    if (btnText.isEmpty) return Container();

    if (btnText.length == 1) {
      return Center(
        child: _buildButton(
          btnText[0],
          200.w,
          20.w,
          () {
            Navigator.of(context).pop();
            callBack?.call();
          },
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildButton(
          btnText[0],
          110.w,
          30.w,
          () => Navigator.of(context).pop(),
        ),
        _buildButton(
          btnText[1],
          110.w,
          30.w,
          () {
            Navigator.of(context).pop();
            callBack?.call();
          },
        ),
      ],
    );
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
