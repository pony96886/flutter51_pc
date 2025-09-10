import 'package:chaguaner2023/components/page_title_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:webviewx_plus/webviewx_plus.dart';

class Browser extends StatelessWidget {
  const Browser({Key? key, this.url, this.title}) : super(key: key);

  final String? url;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          child: PageTitleBar(
            title: '茶老板日常尬谈',
          ),
          preferredSize: Size(double.infinity, 44.w)),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: WebViewX(
          height:
              kIsWeb ? 1.sh - ScreenUtil().statusBarHeight : double.infinity,
          width: kIsWeb ? 1.sw : double.infinity,
          onPageStarted: (e) {},
          initialSourceType: SourceType.url,
          onWebResourceError: (err) {},
          jsContent: {},
          initialContent: url!,
          navigationDelegate: (NavigationRequest request) {
            return NavigationDecision.prevent; //必须有
          },
        ),
      ),
    );
  }
}
