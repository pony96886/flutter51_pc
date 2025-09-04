import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/pagetitlebar.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PublishRule extends StatefulWidget {
  const PublishRule({Key? key}) : super(key: key);

  @override
  State<PublishRule> createState() => _PublishRuleState();
}

class _PublishRuleState extends State<PublishRule> {
  @override
  Widget build(BuildContext context) {
    return HeaderContainer(
      child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageTitleBar(title: '发帖规则'),
              Expanded(
                  child: ListView(
                padding: EdgeInsets.only(
                    left: 15.w,
                    right: 15.w,
                    bottom: ScreenUtil().bottomBarHeight + 15.w),
                children: [
                  Text(
                    AppGlobal.publishRule['title'] ?? '标题',
                    style: TextStyle(
                        color: StyleTheme.cTitleColor,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 15.w,
                  ),
                  Text(
                    AppGlobal.publishRule['content'] ?? '规则',
                    style: TextStyle(
                        height: 1.8,
                        color: StyleTheme.cTitleColor,
                        fontSize: 14.sp),
                  ),
                ],
              ))
            ],
          )),
    );
  }
}
