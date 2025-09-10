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

class MallComplaint extends StatefulWidget {
  const MallComplaint({Key? key, this.id}) : super(key: key);
  final int? id;
  @override
  State<MallComplaint> createState() => _MallComplaintState();
}

class _MallComplaintState extends State<MallComplaint> {
  Map types = {};
  bool loading = true;
  String content = '';
  String tips = '';
  ValueNotifier<String> type = ValueNotifier('');
  @override
  void initState() {
    super.initState();
    preComplaint().then((res) {
      if (res!['status'] != 0) {
        types = res['data']['types'];
        type.value = types.keys.first;
        tips = res['data']['tips'];
        loading = false;
        setState(() {});
      } else {
        CommonUtils.showText(res['msg'] ?? '系统错误~');
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    UploadFileList.dispose();
    type.dispose();
  }

  _submit() {
    if (content.trim().length == 0) {
      CommonUtils.showText('请输入具体内容');
      return;
    }

    // ignore: null_aware_in_condition
    if (UploadFileList.allFile['image']!.urls.isNotEmpty) {
      StartUploadFile.upload().then((value) {
        if (value == null) {
          return CommonUtils.showText('资源上传错误,请重新上传');
        }
        List _img = value['image'].map((e) {
          return e['url'];
        }).toList();
        PageStatus.showLoading();
        productComplaint(content: content, product_id: widget.id, types: type.value, img: _img.join(',')).then((res) {
          if (res!['status'] != 0) {
            context.pop();
            CommonUtils.showText('举报成功');
          } else {
            CommonUtils.showText(res['msg'] ?? '系统错误');
          }
        }).whenComplete(() {
          PageStatus.closeLoading();
        });
      });
    } else {
      PageStatus.showLoading();
      productComplaint(content: content, product_id: widget.id, types: type.value).then((res) {
        if (res!['status'] != 0) {
          context.pop();
          CommonUtils.showText('举报成功');
        } else {
          CommonUtils.showText(res['msg'] ?? '系统错误');
        }
      }).whenComplete(() {
        PageStatus.closeLoading();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: HeaderContainer(
            child: Scaffold(
                backgroundColor: Colors.transparent,
                appBar: PreferredSize(
                    child: PageTitleBar(
                      title: '投诉',
                    ),
                    preferredSize: Size(double.infinity, 44.w)),
                body: loading
                    ? PageStatus.loading(true)
                    : ListView(
                        padding: EdgeInsets.symmetric(horizontal: 19.w, vertical: 24.w),
                        children: [
                          LayoutBuilder(builder: (context, box) {
                            return ValueListenableBuilder(
                                valueListenable: type,
                                builder: ((context, value, child) {
                                  return Wrap(
                                    spacing: 10.w,
                                    runSpacing: 17.w,
                                    children: types.keys.map((e) {
                                      return GestureDetector(
                                        onTap: () {
                                          type.value = e;
                                        },
                                        child: Container(
                                          width: box.maxWidth / 2 - 5.w,
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(top: 5.w),
                                                child: LocalPNG(
                                                  url:
                                                      'assets/images/card/${e == type.value ? 'select' : 'unselect'}.png',
                                                  width: 15.w,
                                                  fit: BoxFit.fitWidth,
                                                ),
                                              ),
                                              SizedBox(
                                                width: 7.5.w,
                                              ),
                                              Expanded(
                                                  child: Text(
                                                types[e],
                                                style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 15.sp),
                                              ))
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  );
                                }));
                          }),
                          SizedBox(
                            height: 14.w,
                          ),
                          Text(
                            tips ?? '',
                            style: TextStyle(color: Color(0xffff4149), fontSize: 13.sp, height: 1.5),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 21.w, bottom: 17.w),
                            height: 140.w,
                            padding: EdgeInsets.all(10.w),
                            decoration:
                                BoxDecoration(borderRadius: BorderRadius.circular(5.w), color: Color(0xfff5f5f5)),
                            child: TextField(
                              maxLines: 999,
                              onChanged: (e) {
                                content = e;
                              },
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.zero,
                                hintText: '请输入具体原因',
                                hintStyle: TextStyle(color: Color(0xffb4b4b4), fontSize: 15.sp),
                                labelStyle: TextStyle(color: Color(0xff1e1e1e), fontSize: 15.sp),
                                border: InputBorder.none, // Removes the default border
                              ),
                            ),
                          ),
                          Text('备注(选填)', style: TextStyle(color: Color(0xff1e1e1e), fontSize: 18.sp)),
                          SizedBox(
                            height: 17.w,
                          ),
                          Text(
                            '（请提供图片证明，越详细越好）\n为了尽快为您处理，请务必提供关键的聊天截图',
                            style: TextStyle(color: Color(0xffb4b4b4), fontSize: 14.sp),
                          ),
                          SizedBox(height: 15.w),
                          UploadResouceWidget(
                            parmas: 'image',
                            uploadType: 'image',
                            maxLength: 10,
                            initResouceList: null,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 24.w),
                            child: Center(
                              child: GestureDetector(
                                onTap: _submit,
                                child: Stack(
                                  children: [
                                    Positioned.fill(child: LocalPNG(url: 'assets/images/elegantroom/shuimo_btn.png')),
                                    Container(
                                      width: 275.w,
                                      height: 50.w,
                                      alignment: Alignment.center,
                                      child: Text(
                                        '确认提交',
                                        style: TextStyle(color: Colors.white, fontSize: 15.sp),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          )
                        ],
                      ))));
  }
}
