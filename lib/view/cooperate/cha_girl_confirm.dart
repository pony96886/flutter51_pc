import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/page_title_bar.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class ChaGirlConfirmPage extends StatefulWidget {
  @override
  _ChaGirlConfirmPageState createState() => _ChaGirlConfirmPageState();
}

class _ChaGirlConfirmPageState extends State<ChaGirlConfirmPage> {
  List<CameraDescription>? cameras;

  CameraController? controller;
  String? imagePath; //图片保存路径
  String? videoPath; //视频保存路径
  VideoPlayerController? videoController;
  VoidCallback? videoPlayerListener;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Timer? _timer;
  int _curRecordSecond = 0;
  int _endRecordTime = 30;

  int _curPlayTime = 0;
  int _endPlayTime = 1;

  bool _isFinal = false; // 提交审核
  String videoNumber = '7772';

  @override
  void initState() {
    super.initState();

    // WidgetsBinding.instance.addObserver(this);
    initCamera();

    int number1 = Random().nextInt(10);
    int number2 = Random().nextInt(10);
    int number3 = Random().nextInt(10);
    int number4 = Random().nextInt(10);
    videoNumber = '$number1$number2$number3$number4';
    recordTime();
  }

  recordTime() {
    _timer = Timer.periodic(Duration(seconds: 1), (time) {
      if (_isClickRecord) {
        setState(() {
          _curRecordSecond++;
          if (_endRecordTime <= _curRecordSecond) {
            // stopRecordTime();
            stopVideoRecording();
          }
        });
      }
    });
  }

  stopRecordTime() {
    _timer!.cancel();
  }

  initCamera() async {
    cameras = await availableCameras();
    controller = CameraController(cameras![1], ResolutionPreset.medium);
    controller!.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
    controller!.addListener(() {
      CameraValue value = controller!.value;
    });
  }

  void showInSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showCameraException(CameraException e) {
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  captureCameraWidget() {
    bool isRecording = false;
    if (controller != null) {
      isRecording = controller!.value.isRecordingVideo;
    }
    String playAssStr = "assets/images/v8/play.png";
    String pauseAssStr = 'assets/images/v8/pause.png';
    return GestureDetector(
      child: Center(
        child: LocalPNG(
          url: isRecording ? playAssStr : pauseAssStr,
          width: 60.w,
          height: 60.w,
        ),
      ),
      onTap: () {
        if (isRecording) {
          stopVideoRecording();
        } else {
          startVideoRecording();
        }
      },
    );
  }

  overCaptureCameraWidget() {
    return Container(
      // height: GVScreenUtil.setWidth(90),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GestureDetector(
            child: Column(
              children: [
                LocalPNG(
                  url: 'assets/images/v8/reset.png',
                  width: 60.w,
                  height: 60.w,
                ),
                Container(
                  height: 10.w,
                ),
                Text(
                  '重新录制',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: StyleTheme.cTitleColor,
                  ),
                )
              ],
            ),
            onTap: () async {
              videoController!.removeListener(videoPlayerListener!);
              videoController!.pause();
              setState(() {
                _isClickStop = false;
                _isClickRecord = false;
                _curRecordSecond = 0;
                recordTime();
              });
              // Future.delayed(Duration(microseconds: 800), () {
              //   videoController?.dispose();
              // });
            },
          ),
          GestureDetector(
            child: Column(
              children: [
                LocalPNG(
                  url: 'assets/images/v8/next.png',
                  width: 60.w,
                  height: 60.w,
                ),
                Container(
                  height: 10.w,
                ),
                Text(
                  '下一步',
                  style: TextStyle(
                    fontSize: 12.w,
                    color: StyleTheme.cTitleColor,
                  ),
                )
              ],
            ),
            onTap: () {
              videoController!.pause();
              setState(() {
                _isFinal = true;
              });
              AppGlobal.girlParmas = {'voicenumber': videoNumber, 'authvideo': videoPath};
              AppGlobal.appRouter?.push(CommonUtils.getRealHash('chaGirlBaseInformation'));
            },
          ),
        ],
      ),
    );
  }

  bool _isClickRecord = false;

  Future<String?> startVideoRecording() async {
    if (!controller!.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }
    getFilePath() async {
      var documents;
      if (Platform.isAndroid) {
        documents = await getExternalStorageDirectory();
      } else {
        documents = await getApplicationDocumentsDirectory();
      }
      String _getApplicationDocumentsDirectory = documents.path;
      Directory directory = Directory('$_getApplicationDocumentsDirectory/cg/');
      bool isExists = await directory.exists();
      if (!isExists) {
        await directory.create(recursive: true);
      }
      return '$_getApplicationDocumentsDirectory/cg/';
    }

    String cachePathStr = await getFilePath();
    final String filePath = cachePathStr + 'cg${timestamp()}.mp4';

    if (controller!.value.isRecordingVideo) {
      return null;
    }

    try {
      videoPath = filePath;
      await controller!.startVideoRecording();
      setState(() {
        _isClickRecord = true;
        _curPlayTime = 0;
        _curRecordSecond = 0;
      });
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
    return filePath;
  }

  bool _isClickStop = false;

  Future<void> stopVideoRecording() async {
    XFile file = await controller!.stopVideoRecording();
    file.saveTo(videoPath!);
    setState(() {
      _isClickRecord = false;
      _isClickStop = true;
      stopRecordTime();
      _startVideoPlayer();
    });
  }

  timeDesWidget() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 25.w,
        vertical: 20.w,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${_isClickStop ? _curPlayTime : _curRecordSecond}s',
            style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 14.w),
          ),
          Text(
            '${_isClickStop ? _endPlayTime : _endRecordTime}s',
            style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 14.w),
          ),
        ],
      ),
    );
  }

  controllerDesWidget() {
    String recoStr = '再次点击录制完毕';
    String beginRecoStr = '点击开始录视频';
    String des = "";
    if (controller != null) {
      des = controller!.value.isRecordingVideo ? recoStr : beginRecoStr;
    }
    return Center(
      child: Padding(
        padding: EdgeInsets.only(top: 25.w),
        child: Text(
          des,
          style: TextStyle(
            fontSize: 12.sp,
            color: StyleTheme.cTitleColor,
          ),
        ),
      ),
    );
  }

  progressWidget() {
    return ClipRRect(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 25.w,
          // vertical: GVScreenUtil.setWidth(50),
        ),
        height: 5.w,
        child: ClipRRect(
          child: LinearProgressIndicator(
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation(Color.fromRGBO(220, 76, 61, 1.0)),
            value: _isClickStop ? _curPlayTime / _endPlayTime : _curRecordSecond / _endRecordTime,
          ),
          borderRadius: BorderRadius.circular(10.w),
        ),
      ),
    );
  }

  cameraWidget() {
    bool isInit = controller?.value.isInitialized ?? false;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 25.w,
        // vertical: GVScreenUtil.setWidth(50),
      ),
      margin: EdgeInsets.symmetric(vertical: 25.w),
      height: 390.w,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Container(
            width: 325.w,
            height: 390.w,
            decoration: BoxDecoration(
                // color: Colors.black26,
                ),
            child: !isInit
                ? Container()
                : ClipRRect(
                    child: AspectRatio(
                        aspectRatio: _isClickStop
                            ? videoController!.value.aspectRatio ?? 650 / 780
                            : controller!.value.aspectRatio,
                        child: _isClickStop ? VideoPlayer(videoController!) : CameraPreview(controller!)),
                    borderRadius: BorderRadius.circular(5.w),
                  ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 20.w,
            child: Center(
              child: Text(
                '请录制并读出数字',
                style: TextStyle(
                  fontSize: 15.sp,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 50.w,
            child: Center(
              child: Text(
                '$videoNumber',
                style: TextStyle(
                  fontSize: 30.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 20.w,
            child: Center(
              child: LocalPNG(
                url: 'assets/images/v8/renzheng.png',
                width: 171.w,
                height: 75.w,
              ),
            ),
          ),
        ],
      ),
    );
  }

  topDesWidget() {
    return Container(
      height: 35.w,
      width: double.infinity,
      color: Color.fromRGBO(245, 245, 245, 1.0),
      padding: EdgeInsets.only(left: 20.w),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          '*录制的视频不会对外公开，若涉嫌诈骗平台将予以追究',
          style: TextStyle(
            fontSize: 14.sp,
            color: StyleTheme.cDangerColor,
          ),
        ),
      ),
    );
  }

  Future<void> _startVideoPlayer() async {
    videoController = VideoPlayerController.file(File(videoPath!));
    videoPlayerListener = () {
      if (mounted)
        setState(() {
          _endPlayTime = videoController!.value.duration.inSeconds;
          _curPlayTime = videoController!.value.position.inSeconds;
        });
    };
    videoController!.addListener(videoPlayerListener!);
    await videoController!.setLooping(true);
    videoController!.initialize().then((value) {
      setState(() {
        videoController!.play();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return HeaderContainer(
      child: Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
            child: PageTitleBar(
              title: '茶女郎认证',
            ),
            preferredSize: Size(double.infinity, 44.w)),
        body: firstWidget(),
      ),
    );
  }

  firstWidget() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          topDesWidget(),
          cameraWidget(),
          Container(
            margin: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.w),
            child: Text(
              '温馨提示：淡妆出镜，展示一下身材，会获得平台小编较高的颜值评分哦～',
              style: TextStyle(color: StyleTheme.cDangerColor, fontSize: 12.sp),
            ),
          ),
          progressWidget(),
          timeDesWidget(),
          _isClickStop ? overCaptureCameraWidget() : captureCameraWidget(),
          _isClickStop ? Container() : controllerDesWidget(),
        ],
      ),
    );
  }

  finalWidget() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.w, horizontal: 10.w),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 10.w),
              child: Center(
                child: LocalPNG(
                  url: 'assets/images/v8/tijiaoshenhe.png',
                  width: 125.w,
                  height: 125.w,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 0),
              child: Center(
                child: Text(
                  '已提交审核，请关注“消息”-“在线客服”中平台的通知',
                  style: TextStyle(
                    fontSize: 18.sp,
                    color: StyleTheme.cTitleColor,
                    // fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 50.w),
              child: Text(
                '请按照以下步骤操作，联系运营人员审核',
                style: TextStyle(
                  fontSize: 18.sp,
                  color: StyleTheme.cTitleColor,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(20.w),
              margin: EdgeInsets.only(top: 15.w),
              decoration: BoxDecoration(
                color: Color.fromRGBO(248, 226, 186, 1.0),
                borderRadius: BorderRadius.circular(10.w),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(188, 55, 41, 1.0),
                              borderRadius: BorderRadius.all(Radius.circular(30.w)),
                            ),
                            width: 30.w,
                            height: 30.w,
                            child: Center(
                              child: Text(
                                '1',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          LocalPNG(
                            url: 'assets/images/v8/xuxian.png',
                            width: 10.w,
                            height: 60.w,
                          )
                        ],
                      ),
                      Container(
                        width: 10.w,
                      ),
                      Container(
                        // color: Colors.blue,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              // width: GVScreenUtil.setWidth(60),
                              // color: Colors.white,
                              height: 30.w,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '请下载Telegram(飞机)app',
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    color: Color.fromRGBO(184, 36, 36, 1.0),
                                    // fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              height: 10.w,
                            ),
                            LocalPNG(
                              url: 'assets/images/v8/downloadtudou.png',
                              width: 265.w,
                              height: 40.w,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(188, 55, 41, 1.0),
                              borderRadius: BorderRadius.all(Radius.circular(30.w)),
                            ),
                            width: 30.w,
                            height: 30.w,
                            child: Center(
                              child: Text(
                                '2',
                                style: TextStyle(
                                  fontSize: 18.w,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 10.w,
                      ),
                      Expanded(
                        child: Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    '下载成功后，点击以下链接，联系该账号',
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      color: Color.fromRGBO(184, 36, 36, 1.0),
                                      // fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                height: 10.w,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    if (videoController != null && videoPlayerListener != null) {
      videoController!.removeListener(videoPlayerListener!);
      videoController!.dispose();
    }
    super.dispose();
  }
}
