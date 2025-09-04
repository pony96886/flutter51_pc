import 'package:chaguaner2023/components/loading_gif.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Loading extends StatelessWidget {
  final bool? transparent;
  Loading({Key? key, this.transparent});
  @override
  Widget build(BuildContext context) {
    return Container(
      color: transparent == null ? Colors.white : Colors.transparent,
      child: Center(
          child: SingleChildScrollView(
              physics: ClampingScrollPhysics(),
              child: Container(
                  color:
                      transparent == null ? Colors.white : Colors.transparent,
                  padding: new EdgeInsets.symmetric(vertical: 40.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      LoadingGif(
                        width: 1.sw / 5,
                      ),
                      Padding(
                        padding: new EdgeInsets.symmetric(vertical: 10.w),
                        child: Text(
                          '数据加载中...',
                          style: TextStyle(
                              decoration: TextDecoration.none,
                              fontSize: 14.sp,
                              color: StyleTheme.cBioColor),
                        ),
                      )
                    ],
                  )))),
    );
  }
}
