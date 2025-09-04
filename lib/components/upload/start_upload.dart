import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:bot_toast/bot_toast.dart';
import 'package:chaguaner2023/components/upload/upload_resouce.dart';
import 'package:chaguaner2023/utils/assets_image_base.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/http.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image/image.dart' as img;

class StartUploadFile {
  static dispose() {
    UploadFileList.dispose();
  }

  static ValueNotifier<double> uploadProgress = ValueNotifier<double>(0);
  static ValueNotifier<int> fileIndex = ValueNotifier<int>(0);
  static int fileTotal = 0;
  static bool isCancel = false;
  static Future<Uint8List> addMark(Uint8List bytes,
      {bool noMark = false}) async {
    final image1 = img.decodeImage(bytes);
    final image2 = img.decodeImage(base64.decode(AssetsImageBase.shuiyin));

    if (image1 == null || image2 == null) return bytes;

    int targetWidth = (image1.width / 4).round();
    int targetHeight = (image2.height * (targetWidth / image2.width)).round();

    final watermarkResized =
        img.copyResize(image2, width: targetWidth, height: targetHeight);

    int padding = 10;
    List<Map<String, int>> positions = [
      {'x': padding, 'y': padding},
      {'x': padding, 'y': image1.height - targetHeight - padding},
      {'x': image1.width - targetWidth - padding, 'y': padding},
      {
        'x': image1.width - targetWidth - padding,
        'y': image1.height - targetHeight - padding
      },
    ];
    final pos = positions[Random().nextInt(positions.length)];

    final composite = img.Image.from(image1);
    img.compositeImage(
      composite,
      watermarkResized,
      dstX: pos['x']!,
      dstY: pos['y']!,
      blend: img.BlendMode.alpha, // 保留透明度（关键！）
    );

    // 编码为 PNG
    final result = img.encodePng(composite);
    return Uint8List.fromList(result);
  }

  static showSchedule() {
    return BotToast.showWidget(toastBuilder: (cancel) {
      return Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: () {
            // cancel();
          },
          child: Container(
            color: Colors.black54,
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15.w)),
                  padding:
                      EdgeInsets.symmetric(horizontal: 35.w, vertical: 15.w),
                  width: 350.w,
                  child: Column(
                    children: [
                      Text(
                        '资源上传',
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                            fontSize: 18.sp),
                      ),
                      SizedBox(
                        height: 15.w,
                      ),
                      LayoutBuilder(builder: (context, box) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(7.5.w),
                          child: Stack(
                            children: [
                              Container(
                                height: 15.w,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(7.5.w),
                                    border: Border.all(
                                        width: 1.w, color: Color(0xffe43234))),
                              ),
                              ValueListenableBuilder(
                                  valueListenable: uploadProgress,
                                  builder: (context, num value, child) {
                                    return Container(
                                      height: 15.w,
                                      width: (value > 1 ? 1 : value) *
                                          box.maxWidth,
                                      decoration: BoxDecoration(
                                          color: Color(0xffe43234),
                                          borderRadius:
                                              BorderRadius.circular(7.5.w)),
                                    );
                                  }),
                            ],
                          ),
                        );
                      }),
                      SizedBox(
                        height: 15.w,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Text('当前上传至: ',
                                      style: TextStyle(
                                          fontSize: 12.sp,
                                          color: Colors.black)),
                                  ValueListenableBuilder(
                                      valueListenable: fileIndex,
                                      builder: (contex, value, child) {
                                        return Text(
                                          value.toString() +
                                              '/' +
                                              fileTotal.toString(),
                                          style: TextStyle(
                                              fontSize: 12.sp,
                                              color: Color(0xffe43234)),
                                        );
                                      }),
                                ],
                              ),
                              SizedBox(
                                width: 15.w,
                              ),
                              Row(
                                children: [
                                  Text('当前进度: ',
                                      style: TextStyle(
                                          fontSize: 12.sp,
                                          color: Colors.black)),
                                  ValueListenableBuilder(
                                      valueListenable: uploadProgress,
                                      builder: (contex, num value, child) {
                                        return Text(
                                          ((value > 1 ? 1 : value) * 100)
                                                  .toStringAsFixed(0) +
                                              '%',
                                          style: TextStyle(
                                              fontSize: 12.sp,
                                              color: Color(0xffe43234)),
                                        );
                                      }),
                                ],
                              )
                            ],
                          ),
                          SizedBox(
                            height: 10.w,
                          ),
                          Text('(图片水印会增加内存,请以左侧为准,图片不算入百分比进度)',
                              style: TextStyle(
                                  fontSize: 12.sp, color: Colors.red)),
                          SizedBox(
                            height: 10.w,
                          ),
                          Text('长时间未响应可以尝试换个资源试试哦～',
                              style:
                                  TextStyle(fontSize: 12.sp, color: Colors.red))
                        ],
                      ),
                      SizedBox(
                        height: 15.w,
                      ),
                      RepaintBoundary(
                        child: ElevatedButton(
                          onPressed: () {
                            try {
                              if (PlatformAwareHttp.cancelToken == null) return;
                              if (!PlatformAwareHttp.cancelToken!.isCancelled) {
                                PlatformAwareHttp.cancelToken!.cancel();
                                isCancel = true;
                                cancel();
                              }
                            } catch (e) {
                              cancel();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(135.w, 44.w),
                            backgroundColor: Color.fromRGBO(228, 50, 52, 1),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22.w),
                            ),
                          ),
                          child: Text(
                            '取消上传',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      );
    });
  }

  static Future<Map?> upload() async {
    List<FileInfo> fileList = [];
    Map<String, List> parmas = {};
    isCancel = false;
    bool videoErr = false;
    bool imageErr = false;
    uploadProgress.value = 0;
    fileIndex.value = 0;
    fileTotal = 0;
    int fileSize = 0;
    List<int> fileSzeList = [];
    UploadFileList.allFile.forEach((key, value) {
      UploadFileList.allFile[key]!.urls.forEach((element) {
        if (element.fileType == 'image') {
          fileTotal++;
        }
        fileSize += (element.fileType == 'image' ? 0 : element.size);
        fileSzeList.add(element.fileType == 'image' ? 0 : element.size);
        fileList.add(element);
      });
    });
    int getSize(int index, int count) {
      if (index == 0) return count;
      int schedule = fileSzeList
          .sublist(0, index)
          .reduce((value, current) => value + current);
      return schedule + count;
    }

    showSchedule();
    await Future.forEach(fileList, (FileInfo element) {
      if (isCancel) return false;
      if (element.fileType == 'image') {
        return PlatformAwareHttp.uploadImage(
                imageUrl: element.uploadUrl!,
                progressCallback: (count, total) {
                  // uploadProgress.value = getSize(fileIndex.value, count) / fileSize;
                })
            .then((res) {
          if (res != null) {
            Map data = json.decode(res.data);
            if (data['code'] != 0) {
              fileIndex.value++;
              if (parmas[element.parmas] == null) {
                parmas[element.parmas!] = [
                  {
                    'url': data['msg'],
                    'w': element.width,
                    'h': element.height,
                  }
                ];
              } else {
                parmas[element.parmas]!.add({
                  'url': data['msg'],
                  'w': element.width,
                  'h': element.height,
                });
              }
            } else {
              CommonUtils.showText(res.data['msg']);
            }
          } else {
            CommonUtils.showText('一张图片上传失败,请检查文件');
          }
        });
      } else {
        return PlatformAwareHttp.uploadVideo(
            videoUrl: kIsWeb ? element.uploadUrl : element.path,
            progressCallback: (count, total) {
              uploadProgress.value = getSize(fileIndex.value, count) / fileSize;
            }).then((res) {
          if (res != null) {
            Map data = json.decode(res.data);
            if (data['code'] != 0) {
              fileIndex.value++;
              if (parmas[element.parmas] == null) {
                parmas[element.parmas!] = [
                  {
                    'url': data['msg'],
                    'w': element.width,
                    'h': element.height,
                  }
                ];
              } else {
                parmas[element.parmas]!.add({
                  'url': data['msg'],
                  'w': element.width,
                  'h': element.height,
                });
              }
            }
          } else {
            videoErr = true;
          }
        }).catchError((e) {
          videoErr = true;
        }).onError((error, stackTrace) {
          videoErr = true;
        });
      }
    });
    BotToast.cleanAll();
    CommonUtils.debugPrint('参数集合:$parmas');
    return isCancel || videoErr ? null : parmas;
  }
}
