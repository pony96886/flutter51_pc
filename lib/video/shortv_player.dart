// ignore_for_file: non_constant_identifier_names
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/netimage_tool.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:universal_html/html.dart' as html;

class ShortVPlayer extends StatefulWidget {
  const ShortVPlayer(
      {Key? key,
      this.cover_url = "",
      this.url = "",
      this.isSimple = false,
      this.isPlayer = false,
      this.onVideoEnd})
      : super(key: key);
  final String url;
  final String cover_url;
  final bool isSimple;
  final bool isPlayer;
  final Function? onVideoEnd;

  @override
  State<ShortVPlayer> createState() => _ShortVPlayerState();
}

class _ShortVPlayerState extends State<ShortVPlayer> {
  FlickManager? flickManager;
  bool isShow = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initURL();
  }

  initURL() async {
    VideoPlayerController? cr =
        VideoPlayerController.networkUrl(Uri.parse(widget.url));
    flickManager = FlickManager(videoPlayerController: cr, autoPlay: !kIsWeb);
    cr.addListener(() {
      if (cr.value.position == cr.value.duration && !isShow) {
        if (widget.onVideoEnd != null) {
          widget.onVideoEnd!.call();
        }
        isShow = true;
      }
    });
    setState(() {});
  }

  @override
  void dispose() {
    flickManager!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return flickManager == null
        ? Container()
        : VisibilityDetector(
            key: ObjectKey(flickManager),
            onVisibilityChanged: (visibility) {
              if (visibility.visibleFraction == 0 && mounted) {
                flickManager!.flickControlManager?.autoPause();
              } else if (visibility.visibleFraction == 1) {
                flickManager!.flickControlManager?.autoResume();
              }
            },
            child: widget.isSimple
                ? FlickVideoPlayer(
                    flickManager: flickManager!,
                    flickVideoWithControls: FlickVideoWithControls(
                      videoFit: BoxFit.contain,
                      playerErrorFallback: Container(),
                      playerLoadingFallback: Stack(
                        children: [
                          Positioned.fill(
                            child: NetImageTool(
                              url: widget.cover_url,
                              fit: BoxFit.contain,
                              isLoad: true,
                            ),
                          ),
                          Center(
                            child: SizedBox(
                              height: 35,
                              width: 35,
                              child: CircularProgressIndicator(
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation(
                                  StyleTheme.cBioColor,
                                ),
                                strokeWidth: 1.0,
                              ),
                            ),
                          )
                        ],
                      ),
                      controls: FlickShowControlsAction(
                        child: Center(
                          child: FlickAutoHideChild(
                            showIfVideoNotInitialized: false,
                            child: FlickPlayToggle(
                              replayChild: Icon(
                                Icons.replay_circle_filled_sharp,
                                size: 45,
                                color: Colors.white70,
                              ),
                              playChild: Icon(
                                Icons.play_circle_filled_sharp,
                                size: 45,
                                color: Colors.white70,
                              ),
                              pauseChild: Icon(
                                Icons.pause_circle_filled_sharp,
                                size: 45,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    flickVideoWithControlsFullscreen: FlickVideoWithControls(
                      playerErrorFallback: Container(),
                      videoFit: BoxFit.contain,
                      controls: Container(),
                    ),
                  )
                : FlickVideoPlayer(
                    flickManager: flickManager!,
                    flickVideoWithControls: FlickVideoWithControls(
                      videoFit: BoxFit.contain,
                      playerErrorFallback: Container(),
                      playerLoadingFallback: Stack(
                        children: [
                          Positioned.fill(
                            child: NetImageTool(
                                url: widget.cover_url, fit: BoxFit.contain),
                          ),
                          Center(
                            child: SizedBox(
                              height: 35,
                              width: 35,
                              child: CircularProgressIndicator(
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation(
                                  StyleTheme.cBioColor,
                                ),
                                strokeWidth: 1.0,
                              ),
                            ),
                          )
                        ],
                      ),
                      controls: FlickVideoPcontrols(isPlayer: widget.isPlayer),
                    ),
                    flickVideoWithControlsFullscreen: FlickVideoWithControls(
                      playerErrorFallback: Container(),
                      videoFit: BoxFit.contain,
                      controls: FlickVideoPcontrols(isFullScreen: true),
                    ),
                  ),
          );
  }
}

class FlickVideoPcontrols extends StatelessWidget {
  const FlickVideoPcontrols(
      {Key? key, this.isFullScreen = false, this.isPlayer})
      : super(key: key);
  final bool isFullScreen;
  final bool? isPlayer;

  @override
  Widget build(BuildContext context) {
    FlickControlManager controlManager =
        Provider.of<FlickControlManager>(context);
    return FlickShowControlsAction(
      child: FlickAutoHideChild(
        showIfVideoNotInitialized: false,
        child: Stack(children: [
          isFullScreen || isPlayer!
              ? Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromRGBO(0, 0, 0, 0.0),
                        Color.fromRGBO(0, 0, 0, 0.5),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                                color: Color.fromRGBO(0, 0, 0, 0.1),
                                offset: Offset(0, 0),
                                blurRadius: 22)
                          ],
                        ),
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          child: Icon(
                            Icons.arrow_back_ios,
                            size: 22,
                            color: Colors.white70,
                          ),
                          onTap: () {
                            if (!isFullScreen) {
                              context.pop();
                            } else {
                              controlManager.toggleFullscreen();
                            }
                          },
                        ),
                      ),
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  FlickCurrentPosition(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    ' / ',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 14),
                                  ),
                                  FlickTotalDuration(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                              FlickFullScreenToggle(
                                enterFullScreenChild: Icon(
                                  Icons.fullscreen,
                                  size: 30,
                                  color: Colors.white70,
                                ),
                                exitFullScreenChild: Icon(
                                  Icons.fullscreen_exit,
                                  size: 30,
                                  color: Colors.white70,
                                ),
                                toggleFullscreen: () {
                                  if (kIsWeb) {
                                    html.VideoElement video =
                                        html.document.querySelector('video')
                                            as html.VideoElement;
                                    video.muted = false;
                                    video.volume = 1;
                                    video.setAttribute('playsinline', 'true');
                                    video.setAttribute('autoplay', 'true');
                                    if (html.document.fullscreenElement ==
                                        null) {
                                      video.enterFullscreen();
                                    } else {
                                      html.document.exitFullscreen();
                                    }
                                  } else {
                                    controlManager.toggleFullscreen();
                                  }
                                },
                              )
                            ],
                          ),
                          FlickVideoProgressBar(
                            flickProgressBarSettings: FlickProgressBarSettings(
                              height: 3,
                              handleRadius: 3,
                              backgroundColor: Colors.white24,
                              bufferedColor: Colors.white38,
                              playedColor: Colors.white,
                              handleColor: Colors.white,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                )
              : Positioned(
                  top: 10,
                  right: 10,
                  child: FlickFullScreenToggle(
                    enterFullScreenChild: Icon(
                      Icons.fullscreen,
                      size: 30,
                      color: Colors.white70,
                    ),
                    exitFullScreenChild: Icon(
                      Icons.fullscreen_exit,
                      size: 30,
                      color: Colors.white70,
                    ),
                    toggleFullscreen: () {
                      if (kIsWeb) {
                        html.VideoElement video = html.document
                            .querySelector('video') as html.VideoElement;
                        video.muted = false;
                        video.volume = 1;
                        video.setAttribute('playsinline', 'true');
                        video.setAttribute('autoplay', 'true');
                        if (html.document.fullscreenElement == null) {
                          video.enterFullscreen();
                        } else {
                          html.document.exitFullscreen();
                        }
                      } else {
                        controlManager.toggleFullscreen();
                      }
                    },
                  ),
                ),
          Center(
            child: FlickPlayToggle(
              replayChild: Icon(
                Icons.replay_circle_filled_sharp,
                size: 45,
                color: Colors.white70,
              ),
              playChild: Icon(
                Icons.play_circle_filled_sharp,
                size: 45,
                color: Colors.white70,
              ),
              pauseChild: Icon(
                Icons.pause_circle_filled_sharp,
                size: 45,
                color: Colors.white70,
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
