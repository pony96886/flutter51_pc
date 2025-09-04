import 'package:bot_toast/bot_toast.dart';
import 'package:chaguaner2023/components/page_status.dart';
import 'package:chaguaner2023/components/pagetitlebar.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:webviewx_plus/webviewx_plus.dart';

class CgWebview extends StatefulWidget {
  final String? url;
  final String? title;
  CgWebview({Key? key, this.url, this.title = ''}) : super(key: key);

  @override
  _CgWebviewState createState() => _CgWebviewState();
}

class _CgWebviewState extends State<CgWebview> {
  bool loading = false;
  String? activityUrl;
  bool isShow = false;
  WebViewXController? webViewXController;
  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      BotToast.cleanAll();
      // loading = false;
    }
    activityUrl = Uri.decodeComponent(widget.url!);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          PageTitleBar(title: widget.title!),
          Expanded(
              child: IndexedStack(
            index: loading ? 0 : 1,
            children: [
              PageStatus.loading(true),
              WebViewX(
                height: kIsWeb
                    ? 1.sh - ScreenUtil().statusBarHeight
                    : double.infinity,
                width: kIsWeb ? 1.sw : double.infinity,
                onPageStarted: (e) {},
                initialSourceType: SourceType.url,
                onPageFinished: (e) {
                  // loading = false;
                  // setState(() {});
                },
                onWebResourceError: (err) {},
                jsContent: {},
                initialContent: activityUrl!,
                onWebViewCreated: (WebViewXController controller) {
                  webViewXController = controller;
                  if (!kIsWeb) {
                    webViewXController?.clearCache();
                  }
                },
                navigationDelegate: (NavigationRequest request) {
                  if (request.content.source.startsWith('chaguan://webview')) {
                    Uri u = Uri.parse(request.content.source);
                    String? route = u.queryParameters['route'];
                    print('路由:$route');
                    if (route != null) {
                      context.push(CommonUtils.getRealHash(route));
                    }
                    return NavigationDecision.prevent;
                  }
                  CommonUtils.launchURL(request.content.source);
                  return NavigationDecision.prevent; //必须有
                },
              )
            ],
          ))
        ],
      ),
    );
  }
}
