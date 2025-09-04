import 'package:bot_toast/bot_toast.dart';
import 'package:chaguaner2023/components/page_status.dart';
import 'package:chaguaner2023/components/pagetitlebar.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:webviewx_plus/webviewx_plus.dart';

class GameWebView extends StatefulWidget {
  final String? url;
  final String? title;
  GameWebView({Key? key, this.url, this.title}) : super(key: key);

  @override
  _GameWebViewState createState() => _GameWebViewState();
}

class _GameWebViewState extends State<GameWebView> {
  bool loading = true;
  String? activityUrl;
  bool isShow = false;
  WebViewXController? webViewXController;
  double _top = 1.sw / 2 - 21.w; //距顶部的偏移
  double _left = ScreenUtil().bottomBarHeight + 25.w; //距左边的偏移
  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      BotToast.cleanAll();
      loading = false;
    }

    activityUrl = Uri.decodeComponent(widget.url!);
  }

  @override
  void dispose() {
    super.dispose();
  }

  btnItem({String? title, String? icon, Function()? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LocalPNG(
              url: 'assets/images/games/$icon.png',
              width: 28.w,
              height: 28.w,
              fit: BoxFit.contain,
            ),
            Text(
              title!,
              style: TextStyle(color: Colors.white, fontSize: 10.sp),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.title == ''
          ? null
          : PreferredSize(
              child: PageTitleBar(
                title: widget.title.toString(),
              ),
              preferredSize: Size(double.infinity, 44.w)),
      body: Column(
        children: [
          Expanded(
              child: Stack(
            children: [
              IndexedStack(
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
                      loading = false;
                      setState(() {});
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
                      if (request.content.source
                          .startsWith('chaguan://webview')) {
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
              Positioned(
                  top: _top,
                  right: _left,
                  child: widget.title != ''
                      ? Container()
                      : GestureDetector(
                          onPanUpdate: (DragUpdateDetails e) {
                            //用户手指滑动时，更新偏移，重新构建
                            _left -= e.delta.dx;
                            _top += e.delta.dy;
                            if (_left < ScreenUtil().bottomBarHeight) {
                              _left = ScreenUtil().bottomBarHeight;
                            }
                            if (_left >
                                1.sh -
                                    ((!isShow ? 42 : 195).w +
                                        ScreenUtil().statusBarHeight)) {
                              _left = 1.sh -
                                  ((!isShow ? 42 : 195).w +
                                      ScreenUtil().statusBarHeight);
                            }
                            if (_top < 0) {
                              _top = 0;
                            }
                            if (_top > 1.sh - 42.w) {
                              _top = 1.sh - 42.w;
                            }

                            setState(() {});
                          },
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            width: (!isShow ? 42 : 195).w,
                            height: (!isShow ? 42 : 50).w,
                            decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(47)),
                            child: PointerInterceptor(
                              child: GestureDetector(
                                onTap: () {
                                  isShow = !isShow;
                                  setState(() {});
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    LocalPNG(
                                      url: 'assets/images/games/center_btn.png',
                                      width: 42.w,
                                      height: 42.w,
                                      fit: BoxFit.contain,
                                    ),
                                    Flexible(
                                        child: FittedBox(
                                      fit: BoxFit.fitWidth,
                                      child: Container(
                                        width: 149.w,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 14.5.w),
                                        child: Row(
                                          // mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            btnItem(
                                                title: '退出',
                                                icon: 'btn3',
                                                onTap: () {
                                                  if (isShow) {
                                                    context.pop();
                                                  }
                                                }),
                                            btnItem(
                                                title: '刷新',
                                                icon: 'btn2',
                                                onTap: () {
                                                  if (isShow) {
                                                    webViewXController
                                                        ?.reload();
                                                  }
                                                }),
                                            btnItem(
                                                title: '充值',
                                                icon: 'btn1',
                                                onTap: () {
                                                  if (isShow) {
                                                    AppGlobal.appRouter?.push(
                                                        CommonUtils.getRealHash(
                                                            'rechargePage'));
                                                  }
                                                }),
                                          ],
                                        ),
                                      ),
                                    ))
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ))
            ],
          ))
        ],
      ),
    );
  }
}
