import 'package:bot_toast/bot_toast.dart';
import 'package:chaguaner2023/components/page_status.dart';
import 'package:chaguaner2023/components/pagetitlebar.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:webviewx_plus/webviewx_plus.dart';
import "package:universal_html/html.dart" as html;
import 'fake_native_widget.dart' if (dart.library.html) 'real_web_widget.dart'
    as ui;

class platformViewRegistry {
  static registerViewFactory(String viewId, dynamic cb) {
    // ignore:undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(viewId, cb);
  }
}

class ActivityPage extends StatefulWidget {
  final String? url;
  ActivityPage({Key? key, this.url}) : super(key: key);

  @override
  _ActivityPageState createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  bool loading = true;
  String? activityUrl;
  WebViewXController? webViewXController;

  String getIsWeb() {
    if (Uri.decodeComponent(widget.url!).contains('?')) {
      return '&isWeb=${kIsWeb ? 1 : 0}';
    } else {
      return '?isWeb=${kIsWeb ? 1 : 0}';
    }
  }

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      BotToast.cleanAll();
      loading = false;
    }

    activityUrl = Uri.decodeComponent(widget.url!) + getIsWeb();
  }

  Widget _buildHtmlWidget() {
    final html.IFrameElement element = html.IFrameElement();
    element.src = Uri.decodeComponent(widget.url!);
    element.style.border = 'none';
    element.style.width = '100%';
    element.style.height = '100%';
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      'iframeElement',
      (int viewId) => element,
    );
    Widget current = HtmlElementView(
      viewType: 'iframeElement',
      key: UniqueKey(),
    );
    return Stack(children: [
      IgnorePointer(
        ignoring: true,
        child: Center(child: current),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(children: [
      PageTitleBar(title: "详情"),
      Expanded(
        child: IndexedStack(
          index: loading ? 0 : 1,
          children: [
            PageStatus.loading(true),
            WebViewX(
              height: kIsWeb
                  ? 1.sh - ScreenUtil().statusBarHeight
                  : MediaQuery.of(context).size.height,
              width: kIsWeb ? 1.sw : double.infinity,
              onPageStarted: (e) {},
              initialSourceType: SourceType.url,
              onPageFinished: (e) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() {
                      loading = false;
                    });
                  }
                });
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
        ),
      )
    ]));
  }
}
