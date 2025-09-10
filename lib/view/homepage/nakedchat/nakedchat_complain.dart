import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/page_status.dart';
import 'package:chaguaner2023/components/page_title_bar.dart';
import 'package:chaguaner2023/components/upload/start_upload.dart';
import 'package:chaguaner2023/components/upload/upload_resouce.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class NakedchatComplain extends StatefulWidget {
  final dynamic data;
  const NakedchatComplain({Key? key, this.data}) : super(key: key);

  @override
  State<NakedchatComplain> createState() => _NakedchatComplainState();
}

class _NakedchatComplainState extends State<NakedchatComplain> {
  TextEditingController content = TextEditingController();
  Map? optionsList;
  List tips = [];
  bool loading = true;
  List selectServes = [];

  submitComplaint() {
    if (content.text.isEmpty) {
      CommonUtils.showText('请描述举报详细内容');
      return;
    }
    if (selectServes.isEmpty) {
      CommonUtils.showText('请选择举报类型');
      return;
    }
    if (UploadFileList.allFile['pic']!.urls.length == 0) {
      CommonUtils.showText("请上传至少一张图片");
      return;
    }
    StartUploadFile.upload().then((value) {
      if (value != null) {
        List _img = value['pic'].map((e) {
          return e['url'];
        }).toList();
        girlchatComplaint(
                id: widget.data['id'],
                types: selectServes,
                content: content.text,
                img: _img)
            .then((res) {
          if (res!['status'] != 0) {
            context.pop();
            CommonUtils.showText('举报成功');
          } else {
            CommonUtils.showText(res['msg']);
          }
        });
      } else {}
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getGirlchatComplaint().then((res) {
      if (res!['status'] != 0) {
        loading = false;
        optionsList = res['data']['option'];
        tips = (res['data']['tips'] as String)
            .split('\n')
            .where((value) => value.isNotEmpty)
            .toList();
        setState(() {});
      } else {
        CommonUtils.showText(res['msg']);
      }
    });
  }

  Widget checkboxServes(String title, String key) {
    String seleStr = 'select';
    String luesS = 'unselect';
    String sercStr = selectServes.indexOf(key) > -1 ? seleStr : luesS;
    return GestureDetector(
      onTap: () {
        if (selectServes.indexOf(key) > -1) {
          selectServes.remove(key);
          setState(() {});
        } else {
          selectServes.add(key);
          setState(() {});
        }
      },
      behavior: HitTestBehavior.translucent,
      child: Container(
        margin: EdgeInsets.only(right: 15.5.w),
        child: Row(
          children: <Widget>[
            Text(title),
            Container(
              width: 15.w,
              height: 15.w,
              margin: EdgeInsets.only(left: 5.5.w),
              child: LocalPNG(
                width: 15.w,
                height: 15.w,
                url: 'assets/images/card/$sercStr.png',
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return HeaderContainer(
        child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Column(
              children: [
                PageTitleBar(
                  title: '投诉',
                ),
                Expanded(
                    child: loading
                        ? PageStatus.loading(true)
                        : ListView(
                            padding: EdgeInsets.symmetric(
                                vertical: 15.w, horizontal: 15.w),
                            children: [
                              Wrap(
                                spacing: 31.w,
                                runSpacing: 20.w,
                                children: <Widget>[
                                  for (var key in optionsList!.keys)
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        checkboxServes(optionsList![key], key)
                                      ],
                                    )
                                ],
                              ),
                              DefaultTextStyle(
                                  style: TextStyle(
                                      color: StyleTheme.cDangerColor,
                                      fontSize: 12.sp),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: tips.map((e) {
                                        return Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 7.5.w),
                                          child: Text(e),
                                        );
                                      }).toList())),
                              Container(
                                margin:
                                    EdgeInsets.only(bottom: 20.w, top: 15.w),
                                height: 151.w,
                                padding: EdgeInsets.all(10.w),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5.w),
                                    color: Color(0xfff5f5f5)),
                                child: TextField(
                                  maxLines: 999,
                                  maxLength: 300,
                                  controller: content,
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.zero,
                                    hintText: '说说你对本次体验的想法吧',
                                    counterStyle: TextStyle(
                                        color: Color(0xffb4b4b4),
                                        fontSize: 15.sp),
                                    hintStyle: TextStyle(
                                        color: Color(0xffb4b4b4),
                                        fontSize: 15.sp),
                                    labelStyle: TextStyle(
                                        color: Color(0xff1e1e1e),
                                        fontSize: 15.sp),
                                    border: InputBorder
                                        .none, // Removes the default border
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 29.5.w,
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '照片',
                                    style: TextStyle(
                                      color: StyleTheme.cTitleColor,
                                      fontSize: 16.sp,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 5.w,
                                  ),
                                  Text(
                                    '请提供图片证明，越详细越好）',
                                    style: TextStyle(
                                      color: StyleTheme.cDangerColor,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '为了尽快为您处理，请务必提供关键的聊天截图',
                                style: TextStyle(
                                  color: StyleTheme.cDangerColor,
                                  fontSize: 12.sp,
                                ),
                              ),
                              SizedBox(
                                height: 21.w,
                              ),
                              UploadResouceWidget(
                                parmas: 'pic',
                                uploadType: 'image',
                                maxLength: 10,
                                initResouceList: [],
                              ),
                            ],
                          )),
                SizedBox(
                  height: 10.w,
                ),
                GestureDetector(
                  onTap: submitComplaint,
                  behavior: HitTestBehavior.translucent,
                  child: Stack(
                    children: [
                      LocalPNG(
                        width: 275.w,
                        height: 50.w,
                        url: 'assets/images/mymony/money-img.png',
                      ),
                      Positioned.fill(
                          child: Center(
                              child: Text(
                        '确认提交',
                        style: TextStyle(fontSize: 15.w, color: Colors.white),
                      ))),
                    ],
                  ),
                ),
                SizedBox(
                  height: ScreenUtil().bottomBarHeight + 19.5.w,
                )
              ],
            )));
  }
}
