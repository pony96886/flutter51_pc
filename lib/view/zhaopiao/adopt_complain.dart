import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/page_status.dart';
import 'package:chaguaner2023/components/pagetitlebar.dart';
import 'package:chaguaner2023/components/upload/start_upload.dart';
import 'package:chaguaner2023/components/upload/upload_resouce.dart';
import 'package:chaguaner2023/model/basic.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class AdoptComplainpage extends StatefulWidget {
  final Map info;
  const AdoptComplainpage({Key? key, required this.info}) : super(key: key);

  @override
  State<AdoptComplainpage> createState() => _AdoptComplainpageState();
}

class _AdoptComplainpageState extends State<AdoptComplainpage> {
  List complaint = [];
  List<int> complaintSelect = [];
  bool loading = true;
  TextEditingController inputValue = TextEditingController();

  initComplaint() async {
    Basic? res = await getAdoptPreComplaint();
    if (res?.status != 0) {
      complaint = res?.data;
      loading = false;
      setState(() {});
    } else {
      CommonUtils.showText(res?.msg ?? '系统错误');
    }
  }

  @override
  void initState() {
    super.initState();
    initComplaint();
  }

  @override
  Widget build(BuildContext context) {
    return HeaderContainer(
        child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: PreferredSize(
                child: PageTitleBar(
                  title: '包养投诉',
                ),
                preferredSize: Size(double.infinity, 44.w)),
            body: loading
                ? PageStatus.loading(true)
                : SingleChildScrollView(
                    padding: EdgeInsets.all(15.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '请选择至少一个投诉原因',
                          style: TextStyle(color: StyleTheme.color30, fontSize: 18.sp),
                        ),
                        SizedBox(
                          height: 6.w,
                        ),
                        ...(complaint.map((e) {
                          bool isSelect = complaintSelect.indexOf(e['key']) > -1;
                          return GestureDetector(
                            onTap: () {
                              if (complaintSelect.indexOf(e['key']) > -1) {
                                complaintSelect.remove(e['key']);
                              } else {
                                complaintSelect.add(e['key']);
                              }
                              setState(() {});
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 6.5.w),
                              child: Row(
                                children: [
                                  isSelect
                                      ? Icon(
                                          Icons.check_circle_outline,
                                          size: 15.w,
                                          color: StyleTheme.cDangerColor,
                                        )
                                      : Icon(
                                          Icons.circle_outlined,
                                          size: 15.w,
                                          color: StyleTheme.color102,
                                        ),
                                  SizedBox(
                                    width: 9.w,
                                  ),
                                  Expanded(
                                      child: Text(
                                    '${e['value']}',
                                    style: TextStyle(
                                        fontSize: 13.sp,
                                        color: isSelect ? StyleTheme.cDangerColor : StyleTheme.color102),
                                  ))
                                ],
                              ),
                            ),
                          );
                        })).toList(),
                        SizedBox(
                          height: 14.w,
                        ),
                        Card(
                            margin: EdgeInsets.zero,
                            shadowColor: Colors.transparent,
                            color: Color(0xFFF5F5F5),
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: TextField(
                                controller: inputValue,
                                textInputAction: TextInputAction.done,
                                autofocus: false,
                                maxLines: 8,
                                cursorColor: StyleTheme.cDangerColor,
                                style: TextStyle(fontSize: 15.sp, color: StyleTheme.cTitleColor),
                                decoration: InputDecoration.collapsed(
                                    hintStyle: TextStyle(fontSize: 15.sp, color: StyleTheme.cBioColor),
                                    hintText: "请详细描述经过和诉求,越详细越有助于平台快速解决"),
                              ),
                            )),
                        SizedBox(
                          height: 10.5.w,
                        ),
                        Text(
                          "*请务必上传1-10张有效截图或者相片，强有力的证据有助于快速解决您的问题",
                          style: TextStyle(color: StyleTheme.cDangerColor, fontSize: 12.sp),
                        ),
                        SizedBox(
                          height: 18.w,
                        ),
                        Text(
                          '上传图片',
                          style: TextStyle(color: StyleTheme.color30, fontSize: 18.sp),
                        ),
                        SizedBox(
                          height: 10.5.w,
                        ),
                        UploadResouceWidget(
                          parmas: 'pic',
                          uploadType: 'image',
                          maxLength: 10,
                          initResouceList: [],
                        ),
                        SizedBox(
                          height: 30.w,
                        ),
                        Center(
                          child: GestureDetector(
                            onTap: () async {
                              if (complaintSelect.isEmpty) {
                                CommonUtils.showText('请至少选择一项投诉原因');
                                return;
                              }
                              if (inputValue.text.trim().isEmpty) {
                                CommonUtils.showText('请详细填写经过和诉求');
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
                                  Basic? res = await adoptComplaint(
                                      keep_id: widget.info['id'],
                                      option: complaintSelect,
                                      content: inputValue.text,
                                      medias: _img);
                                  if (res?.status != 0) {
                                    CommonUtils.showText("投诉提交成功");
                                    context.pop();
                                  } else {
                                    CommonUtils.showText(res?.msg ?? '系统错误');
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
