import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/list/public_list.dart';
import 'package:chaguaner2023/components/nodata.dart';
import 'package:chaguaner2023/components/page_status.dart';
import 'package:chaguaner2023/components/pagetitlebar.dart';
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

class MallPublish extends StatefulWidget {
  const MallPublish({Key? key}) : super(key: key);

  @override
  State<MallPublish> createState() => _MallPublishState();
}

class _MallPublishState extends State<MallPublish> {
  ValueNotifier<Map> goodsType = ValueNotifier({});
  ValueNotifier<List> goodsTag = ValueNotifier([]);
  ValueNotifier<Map> itemType = ValueNotifier({});
  TextEditingController title = TextEditingController();
  TextEditingController price = TextEditingController();
  TextEditingController content = TextEditingController();
  List itemTypeList = [
    {'id': 1, 'name': '商品'},
    {'id': 2, 'name': '虚拟'}
  ];
  List tags = [];
  List selectTags = [];
  bool loading = true;
  @override
  void dispose() {
    UploadFileList.dispose();
    super.dispose();
    goodsType.dispose();
    goodsTag.dispose();
    itemType.dispose();
    title.dispose();
    price.dispose();
    content.dispose();
  }

  _submit() {
    if (goodsType.value['name'] == null) {
      CommonUtils.showText('请选择商品类型');
      return;
    }
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
    if (content.text.trim().isEmpty) {
      CommonUtils.showText('请输入详情描述');
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
    if (UploadFileList.allFile['image_cover']!.urls.isEmpty ||
        UploadFileList.allFile['image_detail']!.urls.isEmpty) {
      CommonUtils.showText('请按要求上传图片资源');
      return;
    }
    if (goodsType.value['name'] == null) {
      CommonUtils.showText('请选择商品类型');
      return;
    }
    StartUploadFile.upload().then((value) {
      if (value == null) {
        return CommonUtils.showText('资源上传错误,请重新上传');
      }
      PageStatus.showLoading();
      bool _isEmpty = value['videos'] == null;
      publishMall(
              goods_type_id: goodsType.value['id'],
              title: title.text,
              price: int.parse(price.text),
              content: content.text,
              tags: selectTags,
              itemType: itemType.value['id'],
              videos: _isEmpty
                  ? []
                  : value['videos']
                      .map((e) => {
                            'cover': '',
                            'img_height': 0,
                            'img_width': 0,
                            'media_url': e['url']
                          })
                      .toList(),
              image_cover: value['image_cover']
                  .map((e) => {
                        'img_height': e['h'],
                        'img_width': e['w'],
                        'media_url': e['url']
                      })
                  .toList(),
              image_detail: value['image_detail']
                  .map((e) => {
                        'img_height': e['h'],
                        'img_width': e['w'],
                        'media_url': e['url']
                      })
                  .toList())
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
    });
  }

  _rowIitem(Widget left, {bool isRight = false}) {
    return Container(
      height: 56.5.w,
      decoration: BoxDecoration(
          border:
              Border(bottom: BorderSide(width: 1.w, color: Color(0XFFeeeeee)))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          left,
          SizedBox(
            width: 15.w,
          ),
          isRight
              ? LocalPNG(
                  width: 18.w,
                  fit: BoxFit.fitWidth,
                  url: 'assets/images/detail/right_.png')
              : SizedBox()
        ],
      ),
    );
  }

  showSelectTag() {
    tags = goodsType.value['tags'];
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
                    padding:
                        EdgeInsets.symmetric(horizontal: 9.5.w, vertical: 20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '编辑标签',
                              style: TextStyle(
                                  color: StyleTheme.cTitleColor,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w500),
                            ),
                            SizedBox(
                              width: 6.w,
                            ),
                            Text(
                              '最多选择3个',
                              style: TextStyle(
                                  color: StyleTheme.cDangerColor,
                                  fontSize: 11.sp),
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
                                      '商品类型暂无标签',
                                      style: TextStyle(
                                          color: StyleTheme.cBioColor,
                                          fontSize: 14.sp),
                                    ),
                                  )
                                : SingleChildScrollView(
                                    child: Wrap(
                                      runSpacing: 10.w,
                                      spacing: 10.w,
                                      children: tags.asMap().keys.map((e) {
                                        bool isSelect =
                                            selectTags.indexOf(tags[e]['id']) >=
                                                0;
                                        return GestureDetector(
                                          onTap: () {
                                            if (isSelect) {
                                              selectTags.removeWhere((item) =>
                                                  item == tags[e]['id']);
                                            } else {
                                              if (selectTags.length >= 3) {
                                                CommonUtils.showText(
                                                    '最多选择3个标签');
                                                return;
                                              } else {
                                                selectTags.add(tags[e]['id']);
                                              }
                                            }
                                            List selectTagList = tags
                                                .where((item) =>
                                                    selectTags
                                                        .indexOf(item['id']) >=
                                                    0)
                                                .toList();
                                            goodsTag.value = selectTagList;
                                            setBottomSheetState(() {});
                                          },
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            3.w),
                                                    color: isSelect
                                                        ? Color.fromRGBO(
                                                            253, 240, 228, 1)
                                                        : Color.fromRGBO(
                                                            245, 245, 245, 1)),
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 11.5.w),
                                                alignment: Alignment.center,
                                                child: Text(
                                                  tags[e]['name'].toString(),
                                                  style: TextStyle(
                                                      color: isSelect
                                                          ? StyleTheme
                                                              .cDangerColor
                                                          : StyleTheme
                                                              .cTitleColor,
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
                              margin: EdgeInsets.only(
                                  bottom: ScreenUtil().bottomBarHeight + 15.w),
                              child: Stack(
                                children: [
                                  LocalPNG(
                                    width: double.infinity,
                                    height: 50.w,
                                    url: "assets/images/mine/black_button.png",
                                  ),
                                  Center(
                                      child: Text("保存",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15.sp))),
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
                    padding:
                        EdgeInsets.symmetric(horizontal: 9.5.w, vertical: 20.w),
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
                              bool isSelect =
                                  itemType.value['id'] == itemTypeList[e]['id'];
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
                                          borderRadius:
                                              BorderRadius.circular(3.w),
                                          color: isSelect
                                              ? Color.fromRGBO(253, 240, 228, 1)
                                              : Color.fromRGBO(
                                                  245, 245, 245, 1)),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 11.5.w),
                                      alignment: Alignment.center,
                                      child: Text(
                                        itemTypeList[e]['name'].toString(),
                                        style: TextStyle(
                                            color: isSelect
                                                ? StyleTheme.cDangerColor
                                                : StyleTheme.cTitleColor,
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
                              margin: EdgeInsets.only(
                                  bottom: ScreenUtil().bottomBarHeight + 15.w),
                              child: Stack(
                                children: [
                                  LocalPNG(
                                    width: double.infinity,
                                    height: 50.w,
                                    url: "assets/images/mine/black_button.png",
                                  ),
                                  Center(
                                      child: Text("保存",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15.sp))),
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

  showSelectCategories() {
    return showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setBottomSheetState) {
            return SizedBox(
              height: 400.w + ScreenUtil().bottomBarHeight,
              child: Stack(
                children: [
                  Column(
                    children: [
                      Container(
                        height: 44.w,
                        alignment: Alignment.center,
                        child: Text(
                          '商品类型',
                          style: TextStyle(
                              color: StyleTheme.cTitleColor, fontSize: 15.sp),
                        ),
                      ),
                      Expanded(
                          child: PublicList(
                              row: 2,
                              aspectRatio: 167 / 68.5,
                              api: '/api/product/types_list',
                              noController: true,
                              mainAxisSpacing: 11.w,
                              crossAxisSpacing: 11.w,
                              data: {},
                              isShow: true,
                              noData: NoData(
                                text: '还没有分类哦～',
                              ),
                              itemBuild: (context, index, data, page, limit,
                                  getListData) {
                                return GestureDetector(
                                  onTap: () {
                                    selectTags = [];
                                    goodsTag.value = [];
                                    goodsType.value = data;
                                    Navigator.of(context).pop();
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Color.fromRGBO(239, 239, 239, 1),
                                      borderRadius: BorderRadius.circular(5.w),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '#${data['name']}',
                                          style: TextStyle(
                                              color: StyleTheme.cTitleColor,
                                              fontSize: 18.sp),
                                        ),
                                        SizedBox(
                                          height: 5.w,
                                        ),
                                        Text('${data['product_num']}个商品',
                                            style: TextStyle(
                                                color: Color(0xff595959),
                                                fontSize: 15.sp)),
                                      ],
                                    ),
                                  ),
                                );
                              }))
                    ],
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
                  ),
                  SizedBox(
                    height: ScreenUtil().bottomBarHeight,
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
                  title: '发布商品',
                ),
                preferredSize: Size(double.infinity, 44.w)),
            body: ListView(
              padding: EdgeInsets.symmetric(horizontal: 14.5.w, vertical: 15.w),
              cacheExtent: 5.sh,
              children: [
                InkWell(
                  onTap: showSelectCategories,
                  child: ValueListenableBuilder(
                      valueListenable: goodsType,
                      builder: (context, Map<dynamic, dynamic> value, child) {
                        return _rowIitem(
                            Text(
                              '#${value['name'] ?? '选择商品类型'}',
                              style: TextStyle(
                                  color: Color(0xff1e1e1e), fontSize: 14.sp),
                            ),
                            isRight: true);
                      }),
                ),
                InkWell(
                  onTap: () {
                    if (goodsType.value.isEmpty) {
                      return CommonUtils.showText('请先选择商品类型');
                    }
                    showSelectTag();
                  },
                  child: ValueListenableBuilder(
                      valueListenable: goodsTag,
                      builder: (context, List value, child) {
                        List _t = value.map((e) => e['name']).toList();
                        String _title = '#${_t.join(' #')}';
                        return _rowIitem(
                            Text(
                              value.isEmpty ? '#选择商品标签' : _title,
                              style: TextStyle(
                                  color: Color(0xff1e1e1e), fontSize: 14.sp),
                            ),
                            isRight: true);
                      }),
                ),
                InkWell(
                  onTap: () {
                    showSelectItemType();
                  },
                  child: ValueListenableBuilder(
                      valueListenable: itemType,
                      builder: (context, Map value, child) {
                        return _rowIitem(
                            Text(
                              value.isEmpty ? '选择物品类型' : value['name'],
                              style: TextStyle(
                                  color: Color(0xff1e1e1e), fontSize: 14.sp),
                            ),
                            isRight: true);
                      }),
                ),
                _rowIitem(Expanded(
                    child: TextField(
                  textInputAction: TextInputAction.done,
                  controller: title,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    hintText: '请填写标题',
                    hintStyle:
                        TextStyle(color: Color(0xffb4b4b4), fontSize: 14.sp),
                    labelStyle:
                        TextStyle(color: Color(0xff1e1e1e), fontSize: 14.sp),
                    border: InputBorder.none, // Removes the default border
                  ),
                ))),
                _rowIitem(Expanded(
                    child: TextField(
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                  ],
                  controller: price,
                  decoration: InputDecoration(
                    hintText: '请输入商品价格',
                    hintStyle:
                        TextStyle(color: Color(0xffb4b4b4), fontSize: 14.sp),
                    labelStyle:
                        TextStyle(color: Color(0xff1e1e1e), fontSize: 47.sp),
                    border: InputBorder.none, // Removes the default border
                  ),
                ))),
                SizedBox(
                  height: 17.w,
                ),
                Text(
                  '详情描述',
                  style:
                      TextStyle(color: StyleTheme.cTitleColor, fontSize: 18.sp),
                ),
                SizedBox(
                  height: 17.w,
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 17.w),
                  height: 140.w,
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
                      hintText: '请输入备注信息',
                      counterStyle:
                          TextStyle(color: Color(0xffb4b4b4), fontSize: 15.sp),
                      hintStyle:
                          TextStyle(color: Color(0xffb4b4b4), fontSize: 15.sp),
                      labelStyle:
                          TextStyle(color: Color(0xff1e1e1e), fontSize: 15.sp),
                      border: InputBorder.none, // Removes the default border
                    ),
                  ),
                ),
                SizedBox(
                  height: 17.w,
                ),
                Text(
                  '上传封面视频',
                  style:
                      TextStyle(color: StyleTheme.cTitleColor, fontSize: 18.sp),
                ),
                Text(
                  '视频仅能上传一个，且不超过100M',
                  style:
                      TextStyle(color: StyleTheme.cBioColor, fontSize: 14.sp),
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
                Text(
                  '上传封面图片',
                  style:
                      TextStyle(color: StyleTheme.cTitleColor, fontSize: 18.sp),
                ),
                Text(
                  '封面最多5张，最大每张800Kb，默认第一张为商品展示图',
                  style:
                      TextStyle(color: StyleTheme.cBioColor, fontSize: 14.sp),
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
                Text(
                  '上传商品详情图',
                  style:
                      TextStyle(color: StyleTheme.cTitleColor, fontSize: 18.sp),
                ),
                Text(
                  '最多上传9张，最大每张800Kb',
                  style:
                      TextStyle(color: StyleTheme.cBioColor, fontSize: 14.sp),
                ),
                SizedBox(height: 15.w),
                UploadResouceWidget(
                  parmas: 'image_detail',
                  uploadType: 'image',
                  maxLength: 9,
                  initResouceList: null,
                ),
                SizedBox(height: 15.w),
                Center(
                  child: GestureDetector(
                    onTap: _submit,
                    child: Stack(
                      children: [
                        Positioned.fill(
                            child: LocalPNG(
                                url:
                                    'assets/images/elegantroom/shuimo_btn.png')),
                        Container(
                          width: 275.w,
                          height: 50.w,
                          alignment: Alignment.center,
                          child: Text(
                            '发布',
                            style:
                                TextStyle(color: Colors.white, fontSize: 15.sp),
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
