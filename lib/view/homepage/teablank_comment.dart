import 'package:bot_toast/bot_toast.dart';
import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/page_title_bar.dart';
import 'package:chaguaner2023/components/upload/start_upload.dart';
import 'package:chaguaner2023/components/upload/upload_resouce.dart';
import 'package:chaguaner2023/model/basic.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:chaguaner2023/utils/log_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TeablankCommentPage extends StatefulWidget {
  final Map info;
  const TeablankCommentPage({Key? key, required this.info}) : super(key: key);

  @override
  State<TeablankCommentPage> createState() => _TeablankCommentPageState();
}

class _TeablankCommentPageState extends State<TeablankCommentPage> {
  double faceValue = 0.0;
  double serviceQuality = 0.0;
  bool isSelect = false;
  TextEditingController inputValue = TextEditingController();

  Widget _inputDetail(String topic, dynamic value) {
    return Card(
        margin: EdgeInsets.zero,
        shadowColor: Colors.transparent,
        color: Color(0xFFF5F5F5),
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: TextField(
            controller: value,
            textInputAction: TextInputAction.done,
            autofocus: false,
            maxLines: 8,
            style: TextStyle(fontSize: 15.sp, color: StyleTheme.cTitleColor),
            decoration: InputDecoration.collapsed(
                hintStyle: TextStyle(fontSize: 15.sp, color: StyleTheme.cBioColor), hintText: topic),
          ),
        ));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    LogUtilS.d(widget.info);
    return HeaderContainer(
        child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: PreferredSize(
                child: PageTitleBar(
                  title: '评论曝光',
                ),
                preferredSize: Size(double.infinity, 44.w)),
            body: SingleChildScrollView(
              padding: EdgeInsetsDirectional.symmetric(horizontal: 15.w, vertical: 10.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _inputDetail('讲讲你的评论～', inputValue),
                  SizedBox(
                    height: 14.sp,
                  ),
                  Text(
                    "上传图片",
                    style: TextStyle(color: StyleTheme.color30, fontSize: 18.sp),
                  ),
                  SizedBox(
                    height: 14.sp,
                  ),
                  UploadResouceWidget(
                    parmas: 'pic',
                    uploadType: 'image',
                    maxLength: 3,
                    initResouceList: [],
                  ),
                  SizedBox(
                    height: 16.w,
                  ),
                  Text(
                    '*请上传至少1张相片让报告更丰富',
                    style: TextStyle(color: StyleTheme.cDangerColor, fontSize: 12.sp),
                  ),
                  Center(
                    child: GestureDetector(
                      onTap: () async {
                        if (inputValue.text.trim().isEmpty) {
                          CommonUtils.showText('请输入评论内容');
                          return;
                        }
                        if (UploadFileList.allFile['pic']!.urls.length == 0) {
                          CommonUtils.showText('请上传截图照片');
                          return;
                        }

                        StartUploadFile.upload().then((value) async {
                          if (value != null) {
                            List _img = value['pic'].map((e) {
                              return {
                                'media_url': e['url'],
                                'img_height': e['h'],
                                'img_width': e['w'],
                              };
                            }).toList();
                            var state = await blackCreateComment(
                                black_id: widget.info['id'], content: inputValue.text, medias: _img);
                            if (state!.status != 0) {
                              BotToast.showText(text: '评价成功～', align: Alignment(0, 0));
                              Navigator.of(context).pop(true);
                            } else {
                              BotToast.showText(text: state.msg! + '～', align: Alignment(0, 0));
                            }
                          } else {}
                        });
                      },
                      child: Container(
                        margin: new EdgeInsets.only(top: 30.w),
                        height: 50.w,
                        width: 275.w,
                        child: Stack(
                          children: [
                            LocalPNG(
                              height: 50.w,
                              width: 275.w,
                              url: 'assets/images/mymony/money-img.png',
                              fit: BoxFit.contain,
                            ),
                            Center(
                                child: Text(
                              '发布',
                              style: TextStyle(fontSize: 15.sp, color: Colors.white),
                            )),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )));
  }
}
