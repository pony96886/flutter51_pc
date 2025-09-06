import 'dart:async';

import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:chaguaner2023/utils/netimage_tool.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../utils/cache/image_net_tool.dart';

class HuakuiCard extends StatefulWidget {
  final ValueNotifier<int>? currentIndex;
  final int? loaddingIndex;
  final Map? gelouInfo;

  const HuakuiCard(
      {Key? key, this.loaddingIndex, this.gelouInfo, this.currentIndex})
      : super(key: key);

  @override
  _HuakuiCardState createState() => _HuakuiCardState();
}

class _HuakuiCardState extends State<HuakuiCard> {
  VideoPlayerController? _controller;
  bool _videoInit = false; //视频是否加载完成
  String? videoUrl;
  String imageUrl = '';
  Timer? _timer;
  @override
  void initState() {
    videoUrl =
        widget.gelouInfo!['resources'].firstWhere((v) => v['type'] == 2)['url'];
    imageUrl =
        widget.gelouInfo!['resources'].firstWhere((v) => v['type'] == 1)['url'];
    super.initState();
  }

  initVideo() {
    if (widget.currentIndex!.value != widget.loaddingIndex) return;
    _controller = VideoPlayerController.network(videoUrl!)
      ..initialize().then((_) {
        _controller!.setLooping(true);
        _videoInit = true;
        setState(() {});
        _controller!.play();
      });
  }

  setVideoStatus() {
    if (widget.currentIndex!.value == widget.loaddingIndex) {
      this._controller!.play();
    } else {
      this._controller!.pause();
    }
  }

  @override
  void dispose() {
    if (!kIsWeb) {
      _controller?.dispose();
      _controller = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      _timer?.cancel();
      _timer = Timer(Duration(milliseconds: 1000), () {
        if (!_videoInit) {
          initVideo();
        }
        _timer!.cancel();
      });
    }
    return VisibilityDetector(
      key: Key('huakuicard-${widget.loaddingIndex}'),
      onVisibilityChanged: (visibilityInfo) {
        if (!kIsWeb) {
          if (visibilityInfo.visibleFraction == 0) {
            _controller!.pause();
          } else {
            if (widget.currentIndex!.value == widget.loaddingIndex)
              _controller!.play();
          }
        }
      },
      child: GestureDetector(
        onTap: () {
          String _id = widget.gelouInfo!['info_id'] == null
              ? widget.gelouInfo!['id'].toString()
              : widget.gelouInfo!['info_id'].toString();
          AppGlobal.appRouter
              ?.push(CommonUtils.getRealHash('vipDetailPage/' + _id + '/null/'));
        },
        child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 325.w,
              height: 490.w,
              decoration: BoxDecoration(color: Color(0xddeeeeee)),
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: <Widget>[
                  Container(
                      decoration: BoxDecoration(color: Colors.black),
                      width: 325.w,
                      height: double.infinity,
                      child: _videoInit &&
                              widget.currentIndex!.value ==
                                  widget.loaddingIndex &&
                              !kIsWeb
                          ? Center(
                              child: AspectRatio(
                                aspectRatio: _controller!.value.aspectRatio,
                                child: VideoPlayer(_controller!),
                              ),
                            )
                          : Container()),
                  Positioned.fill(
                      child: AnimatedOpacity(
                    opacity: !_videoInit ||
                            widget.currentIndex!.value != widget.loaddingIndex
                        ? 1
                        : 0,
                    duration: Duration(milliseconds: 300),
                    child: ImageNetTool(url: imageUrl, fit: BoxFit.cover),
                  )),
                  Positioned(
                      bottom: 0,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 15.w, vertical: 18.w),
                        width: 325.w,
                        height: 120.w,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                          colors: [Colors.black54, Colors.transparent],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        )),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(
                                bottom: 16.w,
                              ),
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    width: 175.w,
                                    child: Text(
                                      widget.gelouInfo!['title'],
                                      style: TextStyle(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(left: 18.5.w),
                                    child: Row(
                                      children: <Widget>[
                                        Container(
                                          width: CommonUtils.getWidth(30),
                                          height: CommonUtils.getWidth(30),
                                          margin: EdgeInsets.only(
                                              right: CommonUtils.getWidth(3)),
                                          child: LocalPNG(
                                              width: CommonUtils.getWidth(30),
                                              height: CommonUtils.getWidth(30),
                                              url:
                                                  'assets/images/card/gelou-position.png',
                                              fit: BoxFit.cover),
                                        ),
                                        Text(
                                          widget.gelouInfo!['cityName'],
                                          style: TextStyle(
                                              color: Color(0xffffc925),
                                              fontSize: 15.sp),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Row(
                              children: <Widget>[
                                _meiziDetail(
                                    'assets/images/card/gelou-age.png',
                                    widget.gelouInfo!['girl_age_num']
                                            .toString() +
                                        '岁'),
                                _meiziDetail(
                                    'assets/images/card/gelou-height.png',
                                    widget.gelouInfo!['girl_height']
                                            .toString() +
                                        'CM'),
                                widget.gelouInfo!['girl_cup'] != null
                                    ? _meiziDetail(
                                        'assets/images/card/gelou-cup.png',
                                        CommonUtils.getCup(
                                            widget.gelouInfo!['girl_cup']))
                                    : SizedBox(),
                                _videoInit
                                    ? Container()
                                    : Container(
                                        width: CommonUtils.getWidth(40),
                                        height: CommonUtils.getWidth(40),
                                        child: CircularProgressIndicator(
                                          // backgroundColor: cDangerColor,
                                          valueColor: AlwaysStoppedAnimation(
                                              Colors.white),
                                        ),
                                      )
                              ],
                            )
                          ],
                        ),
                      ))
                ],
              ),
            )),
      ),
    );
  }

  Widget _meiziDetail(String img, String text) {
    return Container(
      margin: EdgeInsets.only(right: CommonUtils.getWidth(40)),
      child: Row(
        children: <Widget>[
          Container(
            width: CommonUtils.getWidth(30),
            height: CommonUtils.getWidth(30),
            margin: EdgeInsets.only(right: CommonUtils.getWidth(7)),
            child: LocalPNG(
                width: CommonUtils.getWidth(30),
                height: CommonUtils.getWidth(30),
                url: img,
                fit: BoxFit.cover),
          ),
          Text(
            text,
            style: TextStyle(color: Colors.white, fontSize: 12.sp),
          )
        ],
      ),
    );
  }
}
