import 'package:chaguaner2023/components/page_title_bar.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ErrorScreen extends StatelessWidget {
  final String? path;
  ErrorScreen({Key? key, this.path}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          PageTitleBar(
            title: '404',
          ),
          Expanded(
              child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LocalPNG(
                url: 'assets/images/default_netword.png',
                width: 0.7.sw,
                height: 0.7.sw,
              ),
              SizedBox(
                height: 9.w,
              ),
              Text(
                '页面路径发生错误:' + path!,
                // style: StyleTheme.gray15,
              ),
              SizedBox(
                height: ScreenUtil().setWidth(20),
              )
            ],
          ))
        ],
      ),
    );
  }
}
