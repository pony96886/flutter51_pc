import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class WaitingAudit extends StatefulWidget {
  final int type;
  WaitingAudit({Key? key, this.type = 1}) : super(key: key);

  @override
  _WaitingAuditState createState() => _WaitingAuditState();
}

class _WaitingAuditState extends State<WaitingAudit> {
  @override
  Widget build(BuildContext context) {
    return HeaderContainer(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(40.w),
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 80.w,
                ),
                Center(
                  child: LocalPNG(
                    width: 170.w,
                    height: 170.w,
                    url: "assets/images/publish/waitingicon.png",
                  ),
                ),
                Center(
                    child: Text('等待审核',
                        style: TextStyle(
                            color: StyleTheme.cTitleColor,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w500))),
                SizedBox(
                  height: 10.w,
                ),
                Center(
                    child: Text(
                  "平台将对茶帖审核定价，通过后即可\n被其他用户发现，解锁收益平台与发帖者平分",
                  style:
                      TextStyle(color: StyleTheme.cBioColor, fontSize: 12.sp),
                  textAlign: TextAlign.center,
                )),
                SizedBox(
                  height: 60.w,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        context.go('/home');
                      },
                      child: LocalPNG(
                        width: 134.5.w,
                        height: 50.w,
                        url: 'assets/images/publish/backhome.png',
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        AppGlobal.uploadParmas = null;
                        Future.delayed(Duration(milliseconds: 200), () {
                          if (widget.type == 1) {
                            context.pop();
                            context.push('/elegantPublishPage');
                          } else {
                            context.go('/home');
                            context.push('/publishPage/null');
                          }
                        });
                      },
                      child: LocalPNG(
                        width: 134.5.w,
                        height: 50.w,
                        url: 'assets/images/publish/publishcontinue.png',
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
