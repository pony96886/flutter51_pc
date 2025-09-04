import 'package:bot_toast/bot_toast.dart';
import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/pagetitlebar.dart';
import 'package:chaguaner2023/components/starrating.dart';
import 'package:chaguaner2023/components/upload/start_upload.dart';
import 'package:chaguaner2023/components/upload/upload_resouce.dart';
import 'package:chaguaner2023/model/basic.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:chaguaner2023/utils/log_utils.dart';
import 'package:chaguaner2023/utils/netimage_tool.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VipCommentPage extends StatefulWidget {
  final Map info;
  const VipCommentPage({Key? key, required this.info}) : super(key: key);

  @override
  State<VipCommentPage> createState() => _VipCommentPageState();
}

class _VipCommentPageState extends State<VipCommentPage> {
  double faceValue = 0.0;
  double serviceQuality = 0.0;
  bool isSelect = false;
  TextEditingController inputValue = TextEditingController();
  List tags = [];
  String selecs = 'select.png';
  List<int> selectId = [];
  initTag() async {
    Basic? res = await getVipCommentTag();
    if (res?.status != 0) {
      tags = res?.data ?? [];
      setState(() {});
    }
  }

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

  // 获得优惠券
  Future<bool?> showYouHuiQUan(String time, int value) {
    return showDialog<bool?>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
              width: 300.w,
              padding: new EdgeInsets.symmetric(vertical: 25.w, horizontal: 10.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '恭喜获得一张优惠券',
                    style: TextStyle(fontWeight: FontWeight.w500, color: StyleTheme.cTitleColor, fontSize: 18.sp),
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.only(bottom: 40.w),
                    child: Text(
                      '下次雅间消费可使用',
                      style: TextStyle(color: StyleTheme.cBioColor, fontSize: 12.sp),
                    ),
                  ),
                  Container(
                    width: 250.w,
                    height: 80.w,
                    child: Stack(
                      children: [
                        LocalPNG(
                          width: 250.w,
                          height: 80.w,
                          url: 'assets/images/card/youhuiquan-cai.png',
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            right: 19.5.w,
                            left: 15.w,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '元宝优惠券',
                                    style: TextStyle(fontSize: 18.sp, color: Color(0xffffff00)),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                      top: 10.w,
                                    ),
                                    child: Text(
                                      '$time 到期',
                                      style: TextStyle(fontSize: 14.sp, color: Color(0xffdcdcdc)),
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    value.toString(),
                                    style: TextStyle(
                                        fontSize: 30.w, fontWeight: FontWeight.bold, color: Color(0xffc92630)),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.only(top: 40.w, bottom: 20.w),
                    child: Text('将为你自动放入到【卡券】中', style: TextStyle(color: StyleTheme.cDangerColor, fontSize: 12.sp)),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop(false);
                    },
                    child: SizedBox(
                      width: 225.w,
                      height: 50.w,
                      child: Stack(
                        children: [
                          LocalPNG(
                            width: 225.w,
                            height: 50.w,
                            url: 'assets/images/mymony/money-img.png',
                          ),
                          Center(
                              child: Text(
                            '朕收下了',
                            style: TextStyle(fontSize: 15.sp, color: Colors.white),
                          )),
                        ],
                      ),
                    ),
                  )
                ],
              )),
        );
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initTag();
  }

  @override
  Widget build(BuildContext context) {
    return HeaderContainer(
        child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: PreferredSize(
                child: PageTitleBar(
                  title: '评价茶女郎',
                ),
                preferredSize: Size(double.infinity, 44.w)),
            body: SingleChildScrollView(
              padding: EdgeInsetsDirectional.symmetric(horizontal: 15.w, vertical: 10.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    children: [
                      SizedBox(
                        width: 70.w,
                        height: 70.w,
                        child: NetImageTool(
                          url: widget.info['resources'][0]['url'],
                          fit: BoxFit.cover,
                        ),
                      ),
                      Expanded(
                          child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.w),
                        height: 70.w,
                        color: StyleTheme.color245,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.info['title'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: StyleTheme.color30, fontSize: 18.sp, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              "${widget.info['created_str']} 下单",
                              style: TextStyle(color: StyleTheme.color30, fontSize: 12.sp),
                            ),
                          ],
                        ),
                      ))
                    ],
                  ),
                  Container(
                    margin: new EdgeInsets.only(top: 20.w),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          margin: new EdgeInsets.only(right: 14.5.w),
                          child: Text(
                            '妹子颜值:',
                            style: TextStyle(fontSize: 15.sp, color: StyleTheme.cTitleColor),
                          ),
                        ),
                        Container(
                          width: 180.w,
                          child: StarRating(
                            spacing: 15.w,
                            rating: faceValue,
                            size: 20.w,
                            onRatingChanged: (value) {
                              (context as Element).markNeedsBuild();
                              faceValue = value;
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    margin: new EdgeInsets.only(top: 20.w),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          margin: new EdgeInsets.only(right: 14.5.w),
                          child: Text(
                            '服务质量:',
                            style: TextStyle(fontSize: 15.sp, color: StyleTheme.cTitleColor),
                          ),
                        ),
                        Container(
                          width: 180.w,
                          child: StarRating(
                            spacing: 15.w,
                            rating: serviceQuality,
                            size: 20.w,
                            onRatingChanged: (value) {
                              (context as Element).markNeedsBuild();
                              serviceQuality = value;
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      isSelect = !isSelect;
                      setState(() {});
                    },
                    behavior: HitTestBehavior.translucent,
                    child: Container(
                        margin: new EdgeInsets.only(top: 22.w),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '描述的服务项目是否属实',
                              style: TextStyle(fontSize: 14.sp, color: StyleTheme.cTitleColor),
                            ),
                            SizedBox(
                              width: 20.w,
                            ),
                            LocalPNG(
                              width: 15.w,
                              height: 15.w,
                              url: 'assets/images/card/' + (isSelect ? selecs : 'unselect.png'),
                            ),
                          ],
                        )),
                  ),
                  tags.isEmpty
                      ? SizedBox(
                          height: 15.w,
                        )
                      : Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.w),
                          child: Wrap(
                            spacing: 10.w,
                            runSpacing: 10.w,
                            children: tags.map((e) {
                              return GestureDetector(
                                onTap: () {
                                  if (selectId.indexOf(e['id']) > -1) {
                                    selectId.remove(e['id']);
                                  } else {
                                    if (selectId.length >= 3) {
                                      CommonUtils.showText("最多选择3个标签");
                                      return;
                                    }
                                    selectId.add(e['id']);
                                  }
                                  setState(() {});
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      alignment: Alignment.center,
                                      height: 25.w,
                                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                                      decoration: BoxDecoration(
                                          color: selectId.indexOf(e['id']) > -1
                                              ? StyleTheme.color253240228
                                              : StyleTheme.color245,
                                          borderRadius: BorderRadius.circular(3.w)),
                                      child: Text(
                                        e['title'],
                                        style: TextStyle(
                                            color: selectId.indexOf(e['id']) > -1
                                                ? StyleTheme.cDangerColor
                                                : StyleTheme.color30,
                                            fontSize: 12.sp),
                                      ),
                                    )
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                  _inputDetail('评论文字越多，获得优惠券的面值越大哦~', inputValue),
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
                        if (UploadFileList.allFile['pic']!.urls.length == 0) {
                          CommonUtils.showText('请上传截图照片');
                        } else {
                          StartUploadFile.upload().then((value) async {
                            if (value != null) {
                              List _img = value['pic'].map((e) {
                                return {
                                  'media_url': e['url'],
                                  'img_height': e['h'],
                                  'img_width': e['w'],
                                };
                              }).toList();
                              var state = await userEvaluation(
                                  id: widget.info['id'],
                                  girlFace: int.parse(faceValue.toString()[0]),
                                  girlService: int.parse(serviceQuality.toString()[0]),
                                  isReal: isSelect ? 1 : 2,
                                  desc: inputValue.text,
                                  tag_ids: selectId,
                                  medias: _img);
                              if (state!.status != 0) {
                                BotToast.showText(text: '评价成功～', align: Alignment(0, 0));
                                await showYouHuiQUan(state.data!.expiredAt!.split(' ')[0], state.data!.value!);
                                Navigator.of(context).pop(true);
                              } else {
                                BotToast.showText(text: state.msg! + '～', align: Alignment(0, 0));
                              }
                            } else {}
                          });
                        }
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
                              '提交评价',
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
