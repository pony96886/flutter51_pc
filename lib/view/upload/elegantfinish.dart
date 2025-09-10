import 'dart:math';

import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/page_status.dart';
import 'package:chaguaner2023/components/page_title_bar.dart';
import 'package:chaguaner2023/components/upload/start_upload.dart';
import 'package:chaguaner2023/components/upload/upload_resouce.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ElegantFinish extends StatefulWidget {
  final Map? elegantdata;
  final List? images;
  final List? video;
  final List? tags;
  final PageController? pageController;
  ElegantFinish({Key? key, this.elegantdata, this.images, this.video, this.tags, this.pageController});

  @override
  State<StatefulWidget> createState() => ElegantFinishState();
}

class ElegantFinishState extends State<ElegantFinish> {
  final List<String> _authNum = Random().nextInt(10000).toString().padLeft(4, '0').split('');
  Future onSendData(Map fileData) async {
    //原图片列表（包括编辑过）
    List _image = (UploadFileList.allFile['image']?.originalUrls ?? []).map((e) {
      return {'url': Uri.parse(e.path).path, 'cover': "${e.width},${e.height}"};
    }).toList();
    //新增的图片列表
    List _newImage = (fileData['image'] ?? []).map((e) {
      return {'url': e['url'], 'cover': e['w'].toString() + "," + e['h'].toString()};
    }).toList();
    //原视频列表（包括编辑过）
    List _video = (UploadFileList.allFile['video']?.originalUrls ?? []).map((e) {
      return Uri.parse(e.path).path;
    }).toList();
    //新增的视频列表
    List _newVideo = (fileData['video'] ?? []).map((e) {
      return e['url'];
    }).toList();
    //认证视频
    List authVideo = (fileData['authVideo'] ?? []).map((e) {
      return e['url'];
    }).toList();

    var submitFc = widget.images == null ? publishVipInfo : editVipInfo;
    List video = [..._video, ..._newVideo];
    PageStatus.showLoading();
    Map pramas = {
      "tags": widget.tags!.map((item) {
        return {'id': item['id'], 'name': item['name']};
      }).toList(),
      "image": [..._image, ..._newImage],
      "video": video.isEmpty ? null : video[0],
      "authVideo": widget.images != null ? null : (authVideo.isEmpty ? null : authVideo[0]),
      "authNum": widget.images != null ? null : _authNum.join(''),
    };
    pramas.addAll(widget.elegantdata!);
    print(pramas);
    print('finish_________________');
    try {
      var result = await submitFc(pramas).whenComplete(() {
        PageStatus.closeLoading();
      });
      if (result!['status'] != 0) {
        AppGlobal.appRouter?.push(CommonUtils.getRealHash('waitingaudit/1'));
      } else {
        CommonUtils.showText(result['msg']);
      }
    } catch (e) {
      PageStatus.closeLoading();
    }
  }

  @override
  Widget build(BuildContext context) {
    return HeaderContainer(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
            child: PageTitleBar(
              onback: () {
                widget.pageController!.jumpToPage(0);
              },
              title: '验证',
            ),
            preferredSize: Size(double.infinity, 44.w)),
        body: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 15.w, horizontal: 15.5.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("照片",
                      textAlign: TextAlign.left,
                      style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 18.sp, fontWeight: FontWeight.w500)),
                  SizedBox(height: 5.w),
                  UploadResouceWidget(
                    parmas: 'image',
                    maxLength: 10,
                    initResouceList: (widget.images ?? []).map((e) {
                      var _size = e['cover'].split(',');
                      return FileInfo(e['url'], 0, 1, 'image', 'image', null, double.parse(_size[0]).toInt(),
                          double.parse(_size[1]).toInt());
                    }).toList(),
                  ),
                  SizedBox(
                    height: 15.w,
                  ),
                  RichText(
                      text: TextSpan(
                          text: "视频 ",
                          style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 18.sp, fontWeight: FontWeight.w500),
                          children: <TextSpan>[
                        TextSpan(text: ' (选填)', style: TextStyle(color: Color(0xFFB4B4B4), fontSize: 14.sp))
                      ])),
                  SizedBox(
                    height: 5.w,
                  ),
                  UploadResouceWidget(
                    parmas: 'video',
                    uploadType: 'video',
                    maxLength: 1,
                    initResouceList: (widget.video ?? []).map((e) {
                      return FileInfo(e['url'], 0, 1, 'video', 'video', null, 0, 0);
                    }).toList(),
                  ),
                  (widget.elegantdata!['video_valid'] == '1' || widget.elegantdata!['vvip'] == '1') &&
                          widget.images == null
                      ? Padding(
                          padding: EdgeInsets.only(bottom: 10.w, top: 30.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                  text: TextSpan(
                                      text: "认证视频 ",
                                      style: TextStyle(
                                          color: StyleTheme.cTitleColor, fontSize: 18.sp, fontWeight: FontWeight.w500),
                                      children: <TextSpan>[
                                    TextSpan(text: ' (必填)', style: TextStyle(color: Color(0xFFB4B4B4), fontSize: 14.sp))
                                  ])),
                              SizedBox(
                                height: 15.w,
                              ),
                              Row(
                                children: [
                                  Text('随机验证数字 :',
                                      style: TextStyle(
                                          color: Color(0xff1e1e1e), fontSize: 15.sp, fontWeight: FontWeight.bold)),
                                  Container(
                                      height: 42.w,
                                      margin: EdgeInsets.only(left: 15.w),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5.w), color: Color(0xfff5f5f5)),
                                      alignment: Alignment.center,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: _authNum.asMap().keys.map((e) {
                                          return Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 5.w),
                                            child: Text(_authNum[e],
                                                style: TextStyle(color: Color(0xff1e1e1e), fontSize: 15.sp)),
                                          );
                                        }).toList(),
                                      ))
                                ],
                              )
                            ],
                          ))
                      : Container(),
                  (widget.elegantdata!['video_valid'] == '1' || widget.elegantdata!['vvip'] == '1') &&
                          widget.images == null
                      ? UploadResouceWidget(
                          parmas: 'authVideo',
                          uploadType: 'video',
                          maxLength: 1,
                        )
                      : Container(),
                  SizedBox(
                    height: 30.w,
                  ),
                  widget.elegantdata!['video_valid'] == '1' || widget.elegantdata!['vvip'] == '1'
                      ? DefaultTextStyle(
                          style: TextStyle(height: 1.5, color: Color(0xff1e1e1e), fontSize: 12.sp),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('认证视频必须包含以下内容'),
                              Text('• 妹子须说出随机验证数字'),
                              Text('• 妹子须说出当前所在城市，当前日期及时间'),
                              Text('• 妹子须说出“51茶馆认证视频”'),
                              Text('• 妹子拍摄时务必素颜或淡妆，禁止美颜'),
                              SizedBox(
                                height: 30.w,
                              ),
                              Text('认证视频请尽快提交，时间过久可能作废；'),
                              Text('认证视频仅供运营认证时使用，不会对用户及其他人展示，敬请放心'),
                            ],
                          ))
                      : Container(),
                  widget.elegantdata!['video_valid'] == '1' || widget.elegantdata!['vvip'] == '1'
                      ? SizedBox(
                          height: 30.w,
                        )
                      : Container(),
                  GestureDetector(
                    onTap: () {
                      if (((UploadFileList.allFile['image']?.originalUrls ?? []).length +
                              (UploadFileList.allFile['image']?.urls ?? []).length) ==
                          0) {
                        CommonUtils.showText('请上传最新茶女郎照片');
                        return;
                      }
                      if ((widget.elegantdata!['video_valid'] == '1' || widget.elegantdata!['vvip'] == '1') &&
                          (UploadFileList.allFile['authVideo']?.urls ?? []).length == 0 &&
                          widget.images == null) {
                        CommonUtils.showText('请上传认证视频');
                        return;
                      }
                      StartUploadFile.upload().then((value) {
                        if (value == null) {
                          return CommonUtils.showText('资源上传错误,请重新上传');
                        } else {
                          PageStatus.showLoading();
                        }
                        onSendData(value);
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 15.5.w),
                      height: 50.w,
                      child: LocalPNG(
                        height: 50.w,
                        url: "assets/images/publish/publish.png",
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 30.w,
                  ),
                  Center(
                    child: Text(
                      '发布虚假信息被他人投诉，将被封禁发布功能',
                      style: TextStyle(color: StyleTheme.cDangerColor, fontSize: 14.sp),
                    ),
                  ),
                  SizedBox(
                    height: 30.w,
                  )
                ],
              ),
            )
          ]),
        ),
      ),
    );
  }
}
