import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NeedLogin extends StatelessWidget {
  const NeedLogin({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isLogin = false;
    if (['', null, false].contains(AppGlobal.apiToken.value)) {
      isLogin = false;
    } else {
      isLogin = true;
    }
    return isLogin
        ? SizedBox()
        : Container(
            height: 35.5.w,
            color: Colors.transparent,
            child: Stack(
              children: [
                LocalPNG(
                  height: 35.5.w,
                  url: "assets/images/mine/loginreg.png",
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        AppGlobal.appRouter?.push(CommonUtils.getRealHash('loginPage/2'));
                      },
                      child: Container(
                        color: Colors.transparent,
                        width: 120.w,
                        height: 35.5.w,
                      ),
                    ),
                    // GestureDetector(
                    //   onTap: () {
                    //     Navigator.push(
                    //         context,
                    //         MaterialPageRoute(
                    //             builder: (context) => LoginPage(
                    //                   type: 3,
                    //                 )));
                    //     // Application.router.navigateTo(context, "/login");
                    //   },
                    //   child: Container(
                    //     color: Colors.transparent,
                    //     width: 60.w,
                    //     height: 35.5.w,
                    //   ),
                    // )
                  ],
                ),
              ],
            ),
          );
  }
}
