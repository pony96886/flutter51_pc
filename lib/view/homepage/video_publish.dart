import 'package:bot_toast/bot_toast.dart';
import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/page_status.dart';
import 'package:chaguaner2023/components/page_title_bar.dart';
import 'package:chaguaner2023/components/popupbox.dart';
import 'package:chaguaner2023/components/upload/start_upload.dart';
import 'package:chaguaner2023/components/upload/upload_resouce.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class VideoPublish extends StatefulWidget {
  const VideoPublish({Key? key}) : super(key: key);

  @override
  State<VideoPublish> createState() => _VideoPublishState();
}

class _VideoPublishState extends State<VideoPublish> {
  ValueNotifier<List> videoTag = ValueNotifier([]);
  ValueNotifier<Map> itemType = ValueNotifier({});
  TextEditingController title = TextEditingController();
  TextEditingController price = TextEditingController();
  List itemTypeList = [];
  List tags = [];
  List selectTags = [];
  bool loading = true;
  bool isTap = false;
  Map releseInfo = {};
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    videpPreRelease().then((res) {
      if (res!['status'] != 0) {
        loading = false;
        releseInfo = res['data'];
        itemTypeList = releseInfo['category'];
        tags = releseInfo['tags'];
        setState(() {});
      } else {
        CommonUtils.showText(res['msg']);
      }
    });
  }

  @override
  void dispose() {
    UploadFileList.dispose();
    super.dispose();
    videoTag.dispose();
    itemType.dispose();
    title.dispose();
    price.dispose();
  }

  _submit() {
    if (itemType.value.isEmpty) {
      CommonUtils.showText('请选择物品类型类型');
      return;
    }
    if (title.text.trim().isEmpty) {
      CommonUtils.showText('请输入标题');
      return;
    }
    if (price.text.trim().isEmpty) {
      CommonUtils.showText('请输入价格');
      return;
    }
    if (price.text.trim().isEmpty) {
      try {
        int _n = int.parse(price.text);
      } catch (e) {
        CommonUtils.showText('请输入正确价格');
        return;
      }
    }
    if (UploadFileList.allFile['image_cover']!.urls.isEmpty) {
      CommonUtils.showText('请按要求上传图片资源');
      return;
    }
    if (isTap) return;
    isTap = true;
    StartUploadFile.upload().then((value) {
      if (value == null) {
        return CommonUtils.showText('资源上传错误,请重新上传');
      }
      PageStatus.showLoading();
      bool _isEmpty = value['videos'] == null;
      mvRelease(
              title: title.text,
              coins: int.parse(price.text),
              tagIds: selectTags,
              categoryIds: [itemType.value['id']],
              video: _isEmpty ? [] : value['videos'].map((e) => e['url']).toList()[0],
              cover: value['image_cover'].map((e) => e['url']).toList()[0])
          .then((res) {
        if (res!['status'] != 0) {
          context.pop();
          CommonUtils.showText('发布成功,请耐心等待审核');
        } else {
          CommonUtils.debugPrint(res);
          CommonUtils.showText(res['msg'] ?? '系统错误');
        }
      }).whenComplete(() {
        PageStatus.closeLoading();
      });
    }).whenComplete(() {
      isTap = false;
    });
  }

  _rowIitem(Widget left, {bool isRight = false}) {
    return Container(
      height: 56.5.w,
      decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 1.w, color: Color(0XFFeeeeee)))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          left,
          SizedBox(
            width: 15.w,
          ),
          isRight ? LocalPNG(width: 18.w, fit: BoxFit.fitWidth, url: 'assets/images/detail/right_.png') : SizedBox()
        ],
      ),
    );
  }

  showSelectTag() {
    return showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setBottomSheetState) {
            return SizedBox(
              height: 400.w + ScreenUtil().bottomBarHeight,
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 9.5.w, vertical: 20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '编辑标签',
                              style: TextStyle(
                                  color: StyleTheme.cTitleColor, fontSize: 18.sp, fontWeight: FontWeight.w500),
                            ),
                            SizedBox(
                              width: 6.w,
                            ),
                            Text(
                              '最多选择4个',
                              style: TextStyle(color: StyleTheme.cDangerColor, fontSize: 11.sp),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 15.w,
                        ),
                        Expanded(
                            child: tags.isEmpty
                                ? Center(
                                    child: Text(
                                      '视频类型暂无标签',
                                      style: TextStyle(color: StyleTheme.cBioColor, fontSize: 14.sp),
                                    ),
                                  )
                                : SingleChildScrollView(
                                    child: Wrap(
                                      runSpacing: 10.w,
                                      spacing: 10.w,
                                      children: tags.asMap().keys.map((e) {
                                        bool isSelect = selectTags.indexOf(tags[e]['id']) >= 0;
                                        return GestureDetector(
                                          onTap: () {
                                            if (isSelect) {
                                              selectTags.removeWhere((item) => item == tags[e]['id']);
                                            } else {
                                              if (selectTags.length >= 4) {
                                                CommonUtils.showText('最多选择4个标签');
                                                return;
                                              } else {
                                                selectTags.add(tags[e]['id']);
                                              }
                                            }
                                            List selectTagList =
                                                tags.where((item) => selectTags.indexOf(item['id']) >= 0).toList();
                                            videoTag.value = selectTagList;
                                            setBottomSheetState(() {});
                                          },
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(3.w),
                                                    color: isSelect
                                                        ? Color.fromRGBO(253, 240, 228, 1)
                                                        : Color.fromRGBO(245, 245, 245, 1)),
                                                padding: EdgeInsets.symmetric(horizontal: 11.5.w),
                                                alignment: Alignment.center,
                                                child: Text(
                                                  tags[e]['title'].toString(),
                                                  style: TextStyle(
                                                      color:
                                                          isSelect ? StyleTheme.cDangerColor : StyleTheme.cTitleColor,
                                                      fontSize: 12.sp),
                                                ),
                                                height: 25.w,
                                              )
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  )),
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              width: 275.w,
                              height: 50.w,
                              margin: EdgeInsets.only(bottom: ScreenUtil().bottomBarHeight + 15.w),
                              child: Stack(
                                children: [
                                  LocalPNG(
                                    width: double.infinity,
                                    height: 50.w,
                                    url: "assets/images/mine/black_button.png",
                                  ),
                                  Center(child: Text("保存", style: TextStyle(color: Colors.white, fontSize: 15.sp))),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: ScreenUtil().bottomBarHeight + 15.w,
                        )
                      ],
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: LocalPNG(
                        url: "assets/images/nav/closemenu.png",
                        width: 30.w,
                        height: 30.w,
                      ),
                    ),
                  )
                ],
              ),
            );
          });
        });
  }

  showSelectItemType() {
    return showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setBottomSheetState) {
            return SizedBox(
              height: 400.w + ScreenUtil().bottomBarHeight,
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 9.5.w, vertical: 20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 15.w,
                        ),
                        Expanded(
                            child: SingleChildScrollView(
                          child: Wrap(
                            runSpacing: 10.w,
                            spacing: 10.w,
                            children: itemTypeList.asMap().keys.map((e) {
                              bool isSelect = itemType.value['id'] == itemTypeList[e]['id'];
                              return GestureDetector(
                                onTap: () {
                                  itemType.value = itemTypeList[e];
                                  setBottomSheetState(() {});
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(3.w),
                                          color: isSelect
                                              ? Color.fromRGBO(253, 240, 228, 1)
                                              : Color.fromRGBO(245, 245, 245, 1)),
                                      padding: EdgeInsets.symmetric(horizontal: 11.5.w),
                                      alignment: Alignment.center,
                                      child: Text(
                                        itemTypeList[e]['title'].toString(),
                                        style: TextStyle(
                                            color: isSelect ? StyleTheme.cDangerColor : StyleTheme.cTitleColor,
                                            fontSize: 12.sp),
                                      ),
                                      height: 25.w,
                                    )
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        )),
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              width: 275.w,
                              height: 50.w,
                              margin: EdgeInsets.only(bottom: ScreenUtil().bottomBarHeight + 15.w),
                              child: Stack(
                                children: [
                                  LocalPNG(
                                    width: double.infinity,
                                    height: 50.w,
                                    url: "assets/images/mine/black_button.png",
                                  ),
                                  Center(child: Text("保存", style: TextStyle(color: Colors.white, fontSize: 15.sp))),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: ScreenUtil().bottomBarHeight + 15.w,
                        )
                      ],
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: LocalPNG(
                        url: "assets/images/nav/closemenu.png",
                        width: 30.w,
                        height: 30.w,
                      ),
                    ),
                  )
                ],
              ),
            );
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return HeaderContainer(
        child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: PreferredSize(
                child: PageTitleBar(
                  title: '发布帖子',
                  rightWidget: loading
                      ? SizedBox()
                      : GestureDetector(
                          onTap: () {
                            PopupBox.showText(BackButtonBehavior.none,
                                title: '规则',
                                text: (releseInfo['rules'] as String).replaceAll('\n', '\n'),
                                confirmtext: '确认',
                                tapMaskClose: true);
                          },
                          child: Text(
                            '发布规则',
                            style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 14.sp),
                          ),
                        ),
                ),
                preferredSize: Size(double.infinity, 44.w)),
            body: loading
                ? PageStatus.loading(true)
                : ListView(
                    padding: EdgeInsets.symmetric(horizontal: 14.5.w, vertical: 15.w),
                    cacheExtent: 5.sh,
                    children: [
                      InkWell(
                        onTap: () {
                          showSelectItemType();
                        },
                        child: ValueListenableBuilder(
                            valueListenable: itemType,
                            builder: (context, Map value, child) {
                              return _rowIitem(
                                  Text(
                                    value.isEmpty ? '选择类别' : value['title'],
                                    style: TextStyle(color: Color(0xff1e1e1e), fontSize: 14.sp),
                                  ),
                                  isRight: true);
                            }),
                      ),
                      InkWell(
                        onTap: () {
                          showSelectTag();
                        },
                        child: ValueListenableBuilder(
                            valueListenable: videoTag,
                            builder: (context, List value, child) {
                              List _t = value.map((e) => e['title']).toList();
                              String _title = '#${_t.join(' #')}';
                              return _rowIitem(
                                  Text(
                                    value.isEmpty ? '#选择视频标签' : _title,
                                    style: TextStyle(color: Color(0xff1e1e1e), fontSize: 14.sp),
                                  ),
                                  isRight: true);
                            }),
                      ),
                      _rowIitem(Expanded(
                          child: TextField(
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                        ],
                        controller: price,
                        decoration: InputDecoration(
                          hintText: '请输入产品价格',
                          hintStyle: TextStyle(color: Color(0xffb4b4b4), fontSize: 14.sp),
                          labelStyle: TextStyle(color: Color(0xff1e1e1e), fontSize: 47.sp),
                          border: InputBorder.none, // Removes the default border
                        ),
                      ))),
                      SizedBox(
                        height: 17.w,
                      ),
                      Container(
                        margin: EdgeInsets.only(bottom: 17.w),
                        height: 140.w,
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(5.w), color: Color(0xfff5f5f5)),
                        child: TextField(
                          maxLines: 999,
                          maxLength: 50,
                          controller: title,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.zero,
                            hintText: '请输入视频标题',
                            counterStyle: TextStyle(color: Color(0xffb4b4b4), fontSize: 15.sp),
                            hintStyle: TextStyle(color: Color(0xffb4b4b4), fontSize: 15.sp),
                            labelStyle: TextStyle(color: Color(0xff1e1e1e), fontSize: 15.sp),
                            border: InputBorder.none, // Removes the default border
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 17.w,
                      ),
                      Text.rich(
                        TextSpan(text: '上传封面', children: [
                          TextSpan(
                              text: '（封面不得超过1M）', style: TextStyle(color: StyleTheme.cDangerColor, fontSize: 12.sp))
                        ]),
                        style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 18.sp),
                      ),
                      SizedBox(height: 15.w),
                      UploadResouceWidget(
                        parmas: 'image_cover',
                        uploadType: 'image',
                        maxLength: 5,
                        initResouceList: null,
                      ),
                      SizedBox(
                        height: 17.w,
                      ),
                      Text.rich(
                        TextSpan(text: '上传视频', children: [
                          TextSpan(
                              text: ' 最大不得超过500M', style: TextStyle(color: StyleTheme.cDangerColor, fontSize: 12.sp))
                        ]),
                        style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 18.sp),
                      ),
                      SizedBox(height: 15.w),
                      UploadResouceWidget(
                        parmas: 'videos',
                        uploadType: 'video',
                        maxLength: 1,
                        initResouceList: null,
                      ),
                      SizedBox(
                        height: 17.w,
                      ),
                      SizedBox(height: 15.w),
                      Center(
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
                                  '发布',
                                  style: TextStyle(color: Colors.white, fontSize: 15.sp),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  )));
  }
}
