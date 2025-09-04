import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/netimage_tool.dart';
import 'package:chaguaner2023/video/shortv_player.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class AdoptPicViewPage extends StatefulWidget {
  AdoptPicViewPage({Key? key, this.pramas}) : super(key: key);
  final Map? pramas;

  @override
  _AdoptPicViewPageState createState() => _AdoptPicViewPageState();
}

class _AdoptPicViewPageState extends State<AdoptPicViewPage> {
  int currentIndex = 0;
  PageController? _controller;
  List<GlobalKey> keyList = [];
  List<TransformationController> transformationControllerList = [];
  int _selectedIndex = 0;
  bool _scroolEnabled = true;
  PhotoViewScaleState scaleState = PhotoViewScaleState.initial;
  bool hasPop = false;

  void setupData() {
    CommonUtils.debugPrint(widget.pramas);
    widget.pramas!['resources'].forEach((item) {
      GlobalKey _key = GlobalKey();
      TransformationController transformationController =
          TransformationController();
      transformationControllerList.add(transformationController);
      keyList.add(_key);
    });
    _controller = PageController(initialPage: widget.pramas!['index']);
    _controller!.addListener(() {
      if (_controller!.page == _controller!.page) {
        _selectedIndex = _controller!.page!.toInt();
        setState(() {});
      }
    });
    _selectedIndex = currentIndex = widget.pramas!['index'];
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    CommonUtils.setStatusBar(isLight: true);
    setupData();
  }

  @override
  void dispose() {
    CommonUtils.setStatusBar();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Stack(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragUpdate: (e) {},
                onTap: () {
                  if (scaleState == PhotoViewScaleState.initial) {
                    context.pop();
                  }
                },
                onVerticalDragUpdate: (e) {
                  if (scaleState == PhotoViewScaleState.initial) {
                    if (e.delta.dy > 5 && hasPop == false) {
                      hasPop = true;
                      context.pop();
                    }
                  }
                },
                child: PhotoViewGallery.builder(
                  scrollPhysics: const BouncingScrollPhysics(),
                  pageController: _controller,
                  itemCount: widget.pramas!['resources'].length,
                  onPageChanged: (index) {},
                  scaleStateChangedCallback: (value) {
                    scaleState = value;
                  },
                  builder: (context, index) {
                    var e = widget.pramas!['resources'][index];
                    return PhotoViewGalleryPageOptions.customChild(
                      initialScale: 1.0,
                      minScale: 1.0,
                      maxScale: 10.0,
                      child: '${e['media_url'] ?? e['media_url_full']}'
                              .contains('m3u8')
                          ? ShortVPlayer(
                              url: e['media_url'] ?? e['media_url_full'],
                              cover_url: '',
                              isSimple: true,
                            )
                          : NetImageTool(
                              fit: BoxFit.contain,
                              url: e['media_url'] ?? CommonUtils.getThumb(e),
                              isLoad: true,
                            ),
                    );
                  },
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: IgnorePointer(
                  child: Container(
                    height: 80.w,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color.fromRGBO(0, 0, 0, 0.6),
                          Color.fromRGBO(0, 0, 0, 0.0)
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                  child: Column(
                children: [
                  Container(
                      height:
                          kIsWeb ? 10.w : MediaQuery.of(context).padding.top),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: StyleTheme.margin),
                    height: StyleTheme.headTabHeight,
                    child: Stack(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              child: SizedBox(
                                height: double.infinity,
                                child: Icon(Icons.close,
                                    size: 24.w, color: Colors.white),
                              ),
                              onTap: () {
                                context.pop();
                              },
                            ),
                            Text(
                              '${_selectedIndex + 1} / ${widget.pramas!['resources'].length}',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 16.sp),
                            )
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ))
            ],
          ),
        ],
      ),
    );
  }
}
