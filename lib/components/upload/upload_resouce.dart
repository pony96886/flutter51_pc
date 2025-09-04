import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bot_toast/bot_toast.dart';
import 'package:chaguaner2023/components/page_status.dart';
import 'package:chaguaner2023/components/upload/start_upload.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:chaguaner2023/utils/netimage_tool.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:heif_converter_plus/heif_converter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:universal_html/html.dart' as html;
import 'ui/fake_native_widget.dart'
    if (dart.library.html) 'ui/real_web_widget.dart' as ui;
import 'package:video_compress/video_compress.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'dart:ui' as fui;

class FileInfo {
  dynamic path;
  int size;
  int type; //0 本地文件地址 1 网络图片地址
  String? parmas;
  String? fileType;
  Map? uploadUrl;
  int? width;
  int? height;
  FileInfo(this.path, this.size, this.type, this.parmas, this.fileType,
      this.uploadUrl, this.width, this.height);
}

class UploadData {
  String? type; //文件类型
  String? parmas; //文件类型
  List<FileInfo> urls; //文件上传地址
  int size; //文件上传大小
  List<FileInfo> originalUrls; //原文件地址
  UploadData(this.type, this.urls, this.size, this.originalUrls);
}

class UploadFileList {
  static Map<String, UploadData> allFile = {};
  static dispose() {
    allFile.clear();
  }
}

class UploadResouceWidget extends StatefulWidget {
  UploadResouceWidget(
      {Key? key,
      this.uploadType = 'image',
      this.initResouceList,
      this.maxLength = 32,
      this.onSelect,
      this.parmas,
      this.isIndependent = false,
      this.disabled = false,
      this.transparent = false,
      this.maxSize,
      this.noMark = false})
      : super(key: key);
  final String uploadType; // image or video
  final int maxLength;
  final List<FileInfo>? initResouceList;
  final Function? onSelect;
  final String? parmas;
  final bool isIndependent; // 是否是独立的
  final bool disabled;
  final bool transparent;
  final int? maxSize;
  final bool noMark;
  @override
  _UploadResouceWidgetState createState() => _UploadResouceWidgetState();
}

class _UploadResouceWidgetState extends State<UploadResouceWidget>
    with TickerProviderStateMixin {
  GlobalKey _key = GlobalKey();
  html.InputElement? uploadInput;
  changeResouceList(int index, {FileInfo? info}) {
    if (info != null) {
      UploadFileList.allFile[widget.parmas]?.originalUrls.add(info);
    } else {
      if (index < UploadFileList.allFile[widget.parmas]!.originalUrls.length) {
        UploadFileList.allFile[widget.parmas]?.originalUrls.removeAt(index);
      } else {
        UploadFileList.allFile[widget.parmas]?.urls.removeAt(
            index - UploadFileList.allFile[widget.parmas]!.originalUrls.length);
      }
      ;
    }
  }

  Future<fui.Image> getImageSize(path) async {
    var image = kIsWeb
        ? Image.memory(base64.decode(path.split(',')[1]))
        : Image.file(File(path));
    Completer<fui.Image> completer = new Completer<fui.Image>();
    image.image
        .resolve(new ImageConfiguration())
        .addListener(ImageStreamListener((ImageInfo info, bool _) {
      try {
        completer.complete(info.image);
      } catch (e) {}
    }));

    fui.Image info = await completer.future;
    return info;
  }

  int markIndex = 0;
  @override
  void initState() {
    // 初始化数据
    UploadFileList.allFile[widget.parmas!] =
        UploadData(widget.uploadType, [], 0, widget.initResouceList ?? []);
    super.initState();
    if (!kIsWeb) {
      WakelockPlus.enable();
    }
    if (kIsWeb) {
      ui.platformViewRegistry.registerViewFactory(
        'upload_resouce_${widget.uploadType}_${_key.hashCode}',
        (int viewId, {Object? params}) {
          // 创建一个 FileUploadInputElement
          final uploadInput = html.FileUploadInputElement();

          // 根据上传类型设置文件上传控件的属性
          uploadInput.multiple = widget.uploadType == 'image';
          uploadInput.accept =
              widget.uploadType == 'image' ? 'image/*' : 'video/*';
          uploadInput.style.width = '100%';
          uploadInput.style.height = '100%';
          uploadInput.style.opacity = '0'; // 隐藏控件

          // 文件上传后触发的事件处理
          uploadInput.onChange.listen((event) {
            if (uploadInput.files != null) {
              if ((uploadInput.files?.length ?? 0) > widget.maxLength) {
                CommonUtils.showText('最多可传${widget.maxLength}个文件');
              }
              final files = (uploadInput.files?.length ?? 0) > widget.maxLength
                  ? uploadInput.files!.sublist(0, widget.maxLength)
                  : uploadInput.files;

              // 图片类型上传处理
              if (widget.uploadType == 'image') {
                CommonUtils.debugPrint('正在标记水印');
                BotToast.showLoading();
              }

              // 延迟上传逻辑，视上传类型
              Future.delayed(
                Duration(milliseconds: widget.uploadType == 'image' ? 200 : 0),
                () {
                  for (var element in files!) {
                    final file = element;
                    final reader = html.FileReader();
                    getBase64(file, (base64) {
                      reader.onLoadEnd.listen((_event) async {
                        if (widget.uploadType == 'image') {
                          // 上传图片并处理水印
                          StartUploadFile.addMark(
                                  Uint8List.fromList(
                                      reader.result as List<int>),
                                  noMark: widget.noMark)
                              .then((value) async {
                            final info = await getImageSize(base64);
                            if (widget.maxLength == 1) {
                              UploadFileList
                                  .allFile[widget.parmas!]?.originalUrls = [];
                              UploadFileList.allFile[widget.parmas!]?.urls
                                  .clear();
                            }
                            UploadFileList.allFile[widget.parmas!]?.urls.add(
                              FileInfo(
                                base64,
                                file.size,
                                0,
                                widget.parmas!,
                                widget.uploadType,
                                {
                                  'value': value,
                                  'name': file.name,
                                  'type': file.type
                                },
                                info.width,
                                info.height,
                              ),
                            );
                            setState(() {});
                            markIndex++;
                            if (markIndex == files.length) {
                              markIndex = 0;
                              widget.onSelect?.call();
                              BotToast.closeAllLoading();
                            }
                          });
                        } else {
                          // 上传视频或其他类型文件
                          if (widget.maxLength == 1) {
                            UploadFileList
                                .allFile[widget.parmas!]?.originalUrls = [];
                            UploadFileList.allFile[widget.parmas!]?.urls
                                .clear();
                          }
                          UploadFileList.allFile[widget.parmas!]?.urls.add(
                            FileInfo(
                              base64,
                              file.size,
                              0,
                              widget.parmas!,
                              widget.uploadType,
                              {
                                'value': reader.result,
                                'name': file.name,
                                'type': file.type
                              },
                              0,
                              0,
                            ),
                          );
                          setState(() {});
                        }
                      });
                      reader.readAsArrayBuffer(file);
                    });
                  }
                },
              );
            }
          });

          // 返回 FileUploadInputElement 作为对象
          return uploadInput;
        },
      );
    }
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    super.dispose();
  }

  removeResouce(int index) {
    changeResouceList(index);
    setState(() {});
  }

  getBase64(file, Function done) {
    html.FileReader reader = html.FileReader();
    reader.readAsDataUrl(file);
    reader.onLoadEnd.listen((_event) {
      done(reader.result);
    });
  }

  Future<void> loadAssets(String type) async {
    // 检查存储权限状态
    PermissionStatus cameraStatus = await Permission.storage.status;
    // 如果存储权限被永久拒绝
    if (cameraStatus == PermissionStatus.permanentlyDenied) {
      CommonUtils.showText('你关闭了存储权限，请前往设置中打开权限');
      return;
    }

    // 如果存储权限被拒绝，则请求权限
    if (cameraStatus == PermissionStatus.denied) {
      cameraStatus = await Permission.storage.request();

      if (cameraStatus == PermissionStatus.denied ||
          cameraStatus == PermissionStatus.permanentlyDenied) {
        CommonUtils.showText('您拒绝了存储权限，请前往设置中打开权限');
        return;
      }
    }
    List<PlatformFile> _listImagePaths;
    final file = await FilePicker.platform.pickFiles(
      allowMultiple: widget.maxLength > 1,
      onFileLoading: (FilePickerStatus status) {
        switch (status) {
          case FilePickerStatus.picking:
            PageStatus.showLoading(text: '正在加载图片...');
            break;
          case FilePickerStatus.done:
            PageStatus.closeLoading();
            break;
          default:
            PageStatus.closeLoading();
        }
      },
      type: FileType.image,
    );

    _listImagePaths = file!.files;
    CommonUtils.debugPrint('正在标记水印');
    BotToast.showLoading();
    Future.delayed(Duration(milliseconds: 200), () {
      Future.forEach(_listImagePaths, (PlatformFile element) async {
        File imageFile = File(element.path!);
        var imageBates = await imageFile.readAsBytes();
        var bytes =
            await StartUploadFile.addMark(imageBates, noMark: widget.noMark);
        var imgUrlSplit = element.path?.split(".");
        var imageType = imgUrlSplit?.last;
        if ((imgUrlSplit?.length ?? 0) <= 1) {
          imageType = 'png';
        }
        var id = '${DateTime.now().millisecondsSinceEpoch}';
        var imageName = CommonUtils.gvMD5(id);
        getImageSize(element.path).then((info) async {
          if (widget.maxLength == 1) {
            UploadFileList.allFile[widget.parmas!] = UploadData(
                widget.uploadType, [], 0, widget.initResouceList ?? []);
          }
          if (widget.maxLength == 1) {
            UploadFileList.allFile[widget.parmas]?.originalUrls = [];
            UploadFileList.allFile[widget.parmas]?.urls.clear();
          }
          UploadFileList.allFile[widget.parmas]?.urls.add(FileInfo(
              element.path,
              element.size,
              0,
              widget.parmas,
              widget.uploadType,
              {
                'value': bytes,
                'name': '$imageName.$imageType',
                'type': 'image/$imageType'
              },
              info.width,
              info.height));
          var formatList = ["heic", "heif", "HEIC", "HEIF"];
          for (var i = 0;
              i < (UploadFileList.allFile[widget.parmas]?.urls.length ?? 0);
              i++) {
            for (var j = 0; j < formatList.length; j++) {
              if (UploadFileList.allFile[widget.parmas]?.urls[i].path
                  .endsWith(formatList[j])) {
                String? jpegPath = await HeifConverter.convert(
                    UploadFileList.allFile[widget.parmas]?.urls[i].path);
                UploadFileList.allFile[widget.parmas]?.urls[i].path = jpegPath;
              }
            }
          }
          if ((UploadFileList.allFile[widget.parmas]?.urls.length ?? 0) >
              widget.maxLength) {
            UploadFileList.allFile[widget.parmas]?.urls = UploadFileList
                .allFile[widget.parmas]!.urls
                .sublist(0, widget.maxLength);
            CommonUtils.showText('超出了最大文件个数限制');
          }
          widget.onSelect?.call();
          setState(() {});
        });
      }).then((value) {
        BotToast.closeAllLoading();
      });
    });
  }

  appUpload() async {
    if (widget.uploadType != 'image') {
      await FilePicker.platform
          .pickFiles(
        type: FileType.video,
        onFileLoading: (FilePickerStatus status) {
          switch (status) {
            case FilePickerStatus.picking:
              PageStatus.showLoading(text: '正在加载视频...');
              break;
            case FilePickerStatus.done:
              PageStatus.closeLoading();
              break;
            default:
              PageStatus.closeLoading();
          }
        },
      )
          .then((FilePickerResult? file) {
        Future.forEach(file!.files, (PlatformFile item) async {
          if (widget.maxLength == 1) {
            UploadFileList.allFile[widget.parmas]?.originalUrls = [];
            UploadFileList.allFile[widget.parmas]?.urls.clear();
          }
          PageStatus.showLoading(text: '正在压缩视频...');
          MediaInfo? mediaInfo = await VideoCompress.compressVideo(
            item.path!,
            quality: VideoQuality.MediumQuality,
            deleteOrigin: false, // It's false by default
          );
          PageStatus.closeLoading();
          UploadFileList.allFile[widget.parmas]!.urls.add(FileInfo(
              mediaInfo!.path,
              mediaInfo.filesize!,
              0,
              widget.parmas,
              widget.uploadType,
              null,
              0,
              0));
        }).then((value) {
          if ((UploadFileList.allFile[widget.parmas]?.urls.length ?? 0) >
              widget.maxLength) {
            UploadFileList.allFile[widget.parmas]?.urls = UploadFileList
                .allFile[widget.parmas]!.urls
                .sublist(0, widget.maxLength);

            CommonUtils.showText('超出了最大文件个数限制');
          }
          setState(() {});
          widget.onSelect?.call();
        });
      });
    } else {
      loadAssets('gallery');
    }
  }

  resouceWidget(String path, int type) {
    if (widget.uploadType == 'video') {
      return Container(
        color: Colors.black54,
        alignment: Alignment.center,
        width: double.infinity,
        height: double.infinity,
        child: Text(
          '视频资源',
          style: TextStyle(fontSize: 14.sp, color: Colors.white),
        ),
      );
    }
    return type == 0
        ? (kIsWeb
            ? GestureDetector(
                onTap: () {
                  final imageProvider =
                      Image.memory(base64.decode(path.split(',')[1])).image;
                  CommonUtils.setStatusBar(isLight: true);
                  showImageViewer(
                    context,
                    imageProvider,
                    useSafeArea: true,
                    swipeDismissible: true,
                    doubleTapZoomable: true,
                    immersive: false,
                    onViewerDismissed: () {
                      CommonUtils.setStatusBar();
                    },
                  );
                },
                child: Image.memory(
                  base64.decode(path.split(',')[1]),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              )
            : GestureDetector(
                onTap: () {
                  final imageProvider = Image.file(File(path)).image;
                  CommonUtils.setStatusBar(isLight: true);
                  showImageViewer(
                    context,
                    imageProvider,
                    useSafeArea: true,
                    swipeDismissible: true,
                    doubleTapZoomable: true,
                    immersive: false,
                    onViewerDismissed: () {
                      CommonUtils.setStatusBar();
                    },
                  );
                },
                child: Image.file(
                  File(path),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ))
        : GestureDetector(
            onTap: () {
              AppGlobal.picMap = {
                'resources': [
                  {
                    'img_url': path.indexOf('http') < 0
                        ? AppGlobal.bannerImgBase + path
                        : path
                  }
                ],
                'index': 0
              };
              context.push('/teaViewPicPage');
              // CommonUtils.setStatusBar(isLight: true);
              // showImageViewer(
              //   context,
              //   NetworkImageCRP(path.indexOf('http') < 0
              //       ? AppGlobal.bannerImgBase + path
              //       : path),
              //   useSafeArea: true,
              //   swipeDismissible: true,
              //   doubleTapZoomable: true,
              //   immersive: false,
              //   onViewerDismissed: () {
              //     CommonUtils.setStatusBar();
              //   },
              // );
            },
            child: NetImageTool(
              url: path.indexOf('http') < 0
                  ? AppGlobal.bannerImgBase + path
                  : path,
              fit: BoxFit.cover,
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isIndependent && widget.maxLength == 1) {
      List _urls = [
        ...(UploadFileList.allFile[widget.parmas]?.urls ?? []),
        ...(UploadFileList.allFile[widget.parmas]?.originalUrls ?? [])
      ];
      int _index = _urls.length > 0 ? 0 : 1;
      return IndexedStack(
        index: _index,
        children: [
          Stack(
            children: [
              Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: widget.transparent
                      ? GestureDetector(
                          onTap: widget.disabled || kIsWeb ? null : appUpload,
                          behavior: HitTestBehavior.translucent,
                          child: Container(
                            width: double.infinity,
                            height: double.infinity,
                          ))
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(10.w),
                          child: _urls.length == 1
                              ? GestureDetector(
                                  onTap: widget.disabled || kIsWeb
                                      ? null
                                      : appUpload,
                                  behavior: HitTestBehavior.translucent,
                                  child: IgnorePointer(
                                    child: resouceWidget(
                                        _urls[0].path, _urls[0].type),
                                  ),
                                )
                              : Container())),
              Positioned.fill(
                  child: widget.disabled
                      ? Container()
                      : (kIsWeb
                          ? HtmlElementView(
                              viewType:
                                  'upload_resouce_${widget.uploadType}_${_key.hashCode}')
                          : Container()))
            ],
          ),
          widget.disabled
              ? Container()
              : Stack(
                  children: [
                    GestureDetector(
                      onTap: widget.disabled || kIsWeb ? null : appUpload,
                      behavior: HitTestBehavior.translucent,
                      child: widget.transparent
                          ? Container()
                          : Container(
                              width: double.infinity,
                              height: double.infinity,
                              color: Color(0xfff5f5f5),
                              child: LocalPNG(
                                  url: "assets/images/up_image.png",
                                  fit: BoxFit.cover),
                            ),
                    ),
                    Positioned.fill(
                        child: kIsWeb
                            ? HtmlElementView(
                                viewType:
                                    'upload_resouce_${widget.uploadType}_${_key.hashCode}')
                            : Container())
                  ],
                )
        ],
      );
    }
    List<FileInfo> resouceList = [
      ...UploadFileList.allFile[widget.parmas]!.originalUrls,
      ...UploadFileList.allFile[widget.parmas]!.urls
    ];
    return GridView(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            childAspectRatio: 1,
            crossAxisCount: 3,
            mainAxisSpacing: 7.5.w,
            crossAxisSpacing: 7.5.w),
        children: [
          ...resouceList.asMap().keys.map<Widget>((e) {
            return Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.w),
                  child:
                      resouceWidget(resouceList[e].path, resouceList[e].type),
                ),
                Positioned(
                    left: 0,
                    top: 0,
                    child: widget.disabled
                        ? Container()
                        : GestureDetector(
                            onTap: () {
                              changeResouceList(e);
                              setState(() {});
                            },
                            child: LocalPNG(
                              width: 30.w,
                              height: 30.w,
                              url: "assets/images/elegantroom/del.png",
                            ),
                          ))
              ],
            );
          }),
          widget.disabled
              ? Container()
              : Stack(
                  children: [
                    GestureDetector(
                      onTap: kIsWeb ? null : appUpload,
                      behavior: HitTestBehavior.translucent,
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: Color(0xfff5f5f5),
                        child: LocalPNG(
                            url: "assets/images/up_image.png",
                            fit: BoxFit.cover),
                      ),
                    ),
                    Positioned.fill(
                        child: kIsWeb
                            ? HtmlElementView(
                                viewType:
                                    'upload_resouce_${widget.uploadType}_${_key.hashCode}')
                            : Container())
                  ],
                )
        ]);
  }
}
