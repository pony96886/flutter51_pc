import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/page_status.dart';
import 'package:chaguaner2023/components/page_title_bar.dart';
import 'package:chaguaner2023/components/upload/start_upload.dart';
import 'package:chaguaner2023/components/upload/upload_resouce.dart';
import 'package:chaguaner2023/input/InputDailog.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:chaguaner2023/view/upload/publishPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class NakechatPublish extends StatefulWidget {
  const NakechatPublish({Key? key}) : super(key: key);

  @override
  State<NakechatPublish> createState() => _NakechatPublishState();
}

class _NakechatPublishState extends State<NakechatPublish> {
  bool loading = true;
  String girlName = '';
  String age = '';
  String height = '';
  String weight = '';
  String price = '';
  String cup = '';
  String cupValue = '';
  List additionItemIds = [];
  List selectServesProject = [];
  bool isFace = false; //是否露脸
  List selectTags = []; //标签
  ValueNotifier<List> tagsValues = ValueNotifier([]);
  Map? releaseInfo;
  List additionList = [];
  final myController = TextEditingController();
  String selectConnect = '手机';

  submitRlease() {
    if (girlName.isEmpty ||
        height.isEmpty ||
        weight.isEmpty ||
        price.isEmpty ||
        myController.text.isEmpty ||
        cupValue.isEmpty ||
        age.isEmpty ||
        selectTags.isEmpty) {
      CommonUtils.showText('请完整填写裸聊信息');
      return;
    }
    if (UploadFileList.allFile['pic']!.urls.length == 0) {
      CommonUtils.showText("请上传至少一张图片");
      return;
    }
    StartUploadFile.upload().then((value) {
      List _img = value!['pic'].map((e) {
        return {
          'url': e['url'],
          'width': e['w'],
          'height': e['h'],
        };
      }).toList();
      girlchatRlease(
              title: girlName,
              girlHeight: double.parse(height),
              girlWeight: double.parse(weight),
              pricePerMinute: double.parse(price),
              phone: '($selectConnect)${myController.text}',
              girlCup: cupValue,
              serviceItemIds: selectServesProject,
              additionItemIds: additionItemIds,
              photo: _img,
              girlAge: double.parse(age),
              girlTagIds: selectTags,
              showFace: isFace ? 1 : 0)
          .then((res) {
        if (res!['status'] != 0) {
          context.pop();
          CommonUtils.showText('发布成功,请耐心等待审核');
        } else {
          CommonUtils.showText(res['msg']);
        }
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    girlchatPreRlease().then((res) {
      if (res!['status'] != 0) {
        releaseInfo = res['data'];
        loading = false;
        setState(() {});
      } else {
        CommonUtils.showText(res['msg']);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    tagsValues.dispose();
    super.dispose();
  }

  Widget titleWidget(String title, {String? subtitle}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.w, top: 20.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 18.sp),
          ),
          SizedBox(
            width: 5.w,
          ),
          subtitle == null
              ? SizedBox()
              : Text(
                  subtitle,
                  style: TextStyle(
                      color: StyleTheme.cDangerColor, fontSize: 12.sp),
                ),
        ],
      ),
    );
  }

  Widget inputWidget(
      {String? value,
      String? title,
      String? hintText,
      Function(String)? onValueChanged,
      TextInputType boardType = TextInputType.text}) {
    return ListTile(
      onTap: () {
        InputDialog.show(context, title!,
                limitingText: 16, boardType: boardType)
            .then((e) {
          onValueChanged!(e!);
        });
      },
      contentPadding: EdgeInsets.only(left: 0, right: 0),
      title: Text(title!,
          style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 14.sp)),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
        Text(value!.isEmpty ? hintText! : value.toString(),
            style: TextStyle(
                fontSize: 14.sp,
                color: value.isEmpty
                    ? StyleTheme.cBioColor
                    : StyleTheme.cTitleColor)),
      ]),
    );
  }

  serversItem(Map item) {
    String seleStr = 'select';
    String luesS = 'unselect';
    String sercStr = additionItemIds.indexOf(item['id']) > -1 ? seleStr : luesS;
    return Padding(
      padding: EdgeInsets.only(bottom: 10.w),
      child: GestureDetector(
        onTap: () {
          if (additionItemIds.indexOf(item['id']) > -1) {
            additionItemIds.remove(item['id']);
            setState(() {});
          } else {
            additionItemIds.add(item['id']);
            setState(() {});
          }
          // pri
        },
        child: Container(
          height: 45.w,
          padding: EdgeInsets.symmetric(horizontal: 9.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.w),
            color: Color.fromRGBO(245, 245, 245, 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item['name'],
                style:
                    TextStyle(color: StyleTheme.cTitleColor, fontSize: 14.sp),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${item['coin']}元宝',
                    style: TextStyle(
                        color: StyleTheme.cTitleColor, fontSize: 14.sp),
                  ),
                  SizedBox(
                    width: 10.5.w,
                  ),
                  LocalPNG(
                    width: 15.w,
                    height: 15.w,
                    url: 'assets/images/card/$sercStr.png',
                    fit: BoxFit.cover,
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  cupItem(String title, String value) {
    return Container(
      child: Column(
        children: <Widget>[
          SimpleDialogOption(
            child: Center(
              child: Text(title,
                  style: TextStyle(
                      color: StyleTheme.cTitleColor, fontSize: 14.sp)),
            ),
            onPressed: () {
              Navigator.pop(context);
              cup = title;
              cupValue = value;
              setState(() {});
            },
          ),
          BottomLine(),
        ],
      ),
    );
  }

  showSelectCup() {
    showDialog(
        context: context,
        builder: (context) {
          return new SimpleDialog(
            shape: RoundedRectangleBorder(
                side: BorderSide(
                  style: BorderStyle.none,
                ),
                borderRadius: BorderRadius.circular(10)),
            contentPadding:
                EdgeInsets.symmetric(vertical: 15.w, horizontal: 15.w),
            children: <Widget>[
              for (var item in (releaseInfo!['girl_cup'] as Map).keys)
                cupItem(releaseInfo!['girl_cup'][item], item)
            ],
          );
        });
  }

  Widget selectWidget(
      {List? value,
      String? title,
      String? hintText,
      Function(List)? onValueChanged}) {
    return ListTile(
      onTap: () {
        showSelect();
        // onValueChanged([]);
      },
      contentPadding: EdgeInsets.only(left: 0, right: 0),
      title: Text(title!,
          style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 14.sp)),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
        Text(value!.isEmpty ? hintText! : value!.join(','),
            style: TextStyle(
                fontSize: 14.sp,
                color: value.isEmpty
                    ? StyleTheme.cBioColor
                    : StyleTheme.cTitleColor)),
        Icon(Icons.keyboard_arrow_right, color: StyleTheme.cBioColor),
      ]),
    );
  }

  Widget tagItemWidget(Map item, bool isActive) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: CommonUtils.getWidth(24)),
        height: 25.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3),
          color: isActive ? Color(0xFFFDF0E4) : StyleTheme.bottomappbarColor,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              item['title'] ?? item['name'],
              style: TextStyle(
                  fontSize: 12.w,
                  color: isActive
                      ? StyleTheme.cDangerColor
                      : StyleTheme.cTitleColor),
            ),
          ],
        ));
  }

  Widget checkboxServes(String title, {Function? onTap, bool? value}) {
    String seleStr = 'select';
    String luesS = 'unselect';
    String sercStr =
        (onTap != null ? value! : selectConnect == title) ? seleStr : luesS;
    return GestureDetector(
      onTap: () {
        onTap!();
        return;
        // if (selectConnect != title) {
        //   setState(() {
        //     selectConnect = title;
        //   });
        // }
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

  Future showSelect() {
    return showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setBottomSheetState) {
            return Container(
              height: 295.5 + ScreenUtil().bottomBarHeight,
              padding: EdgeInsets.only(
                  top: 20.w,
                  bottom: ScreenUtil().bottomBarHeight + 24.w,
                  left: 15.w,
                  right: 15.w),
              color: Colors.white,
              child: Column(
                children: [
                  Expanded(
                    child: SizedBox(
                        width: double.infinity,
                        child: Wrap(
                          spacing: 15.w,
                          runSpacing: 10.w,
                          children: <Widget>[
                            for (var item in releaseInfo!['girl_tags'])
                              GestureDetector(
                                  onTap: () {
                                    if (selectTags.indexOf(item['id']) > -1) {
                                      selectTags.remove(item['id']);
                                    } else {
                                      selectTags.add(item['id']);
                                    }
                                    setBottomSheetState(() {});
                                  },
                                  child: tagItemWidget(item,
                                      selectTags.indexOf(item['id']) > -1))
                          ],
                        )),
                  ),
                  SizedBox(
                    height: 10.w,
                  ),
                  GestureDetector(
                    onTap: () {
                      List tags = [];
                      releaseInfo!['girl_tags'].forEach((element) {
                        if (selectTags.indexOf(element['id']) > -1) {
                          tags.add(element['title']);
                        }
                      });
                      tagsValues.value = tags;
                      Navigator.pop(context);
                    },
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
                          '确认',
                          style: TextStyle(fontSize: 15.w, color: Colors.white),
                        ))),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 7.5.w,
                  ),
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
            body: Column(
              children: [
                PageTitleBar(
                  title: '发布裸聊',
                ),
                Expanded(
                    child: loading
                        ? PageStatus.loading(true)
                        : ListView(
                            cacheExtent: 5.sh,
                            padding: EdgeInsets.symmetric(
                                horizontal: 15.w, vertical: 10.w),
                            children: [
                              titleWidget('基本信息'),
                              ValueListenableBuilder(
                                  valueListenable: tagsValues,
                                  builder: (context, List value, child) {
                                    return selectWidget(
                                        value: value,
                                        hintText: '选择符合的分类标签',
                                        title: '标签');
                                  }),
                              BottomLine(),
                              inputWidget(
                                  value: girlName,
                                  hintText: '输入妹子花名或者编号',
                                  title: '妹子花名',
                                  onValueChanged: (e) {
                                    girlName = e;
                                    setState(() {});
                                  }),
                              BottomLine(),
                              inputWidget(
                                  value: age,
                                  hintText: '输入年龄，如:18',
                                  boardType: TextInputType.number,
                                  title: '年龄(岁)',
                                  onValueChanged: (e) {
                                    if (num.tryParse(e) != null) {
                                      age = e;
                                      setState(() {});
                                    } else {
                                      CommonUtils.showText('请输入纯数字');
                                    }
                                  }),
                              BottomLine(),
                              inputWidget(
                                  value: height,
                                  hintText: '输入身高cm，如:168',
                                  boardType: TextInputType.number,
                                  title: '身高(cm)',
                                  onValueChanged: (e) {
                                    height = e;
                                    setState(() {});
                                  }),
                              BottomLine(),
                              ListTile(
                                onTap: showSelectCup,
                                contentPadding:
                                    EdgeInsets.only(left: 0, right: 0),
                                title: Text('罩杯',
                                    style: TextStyle(
                                        color: StyleTheme.cTitleColor,
                                        fontSize: 14.sp)),
                                trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Text(cup.isEmpty ? '选择罩杯大小' : cup,
                                          style: TextStyle(
                                              fontSize: 14.sp,
                                              color: cup.isEmpty
                                                  ? StyleTheme.cBioColor
                                                  : StyleTheme.cTitleColor)),
                                      Icon(Icons.keyboard_arrow_right,
                                          color: StyleTheme.cBioColor),
                                    ]),
                              ),
                              BottomLine(),
                              inputWidget(
                                  value: weight,
                                  hintText: '输入体重kg，如:48',
                                  boardType: TextInputType.number,
                                  title: '体重(kg)',
                                  onValueChanged: (e) {
                                    if (num.tryParse(e) != null) {
                                      weight = e;
                                      setState(() {});
                                    } else {
                                      CommonUtils.showText('请输入纯数字');
                                    }
                                  }),
                              BottomLine(),
                              titleWidget('消费情况'),
                              inputWidget(
                                  value: price,
                                  hintText: '请设置每分钟元宝价格，如:100',
                                  title: '套餐(元宝)',
                                  boardType: TextInputType.number,
                                  onValueChanged: (e) {
                                    if (num.tryParse(e) != null) {
                                      price = e;
                                      setState(() {});
                                    } else {
                                      CommonUtils.showText('请输入纯数字');
                                    }
                                  }),
                              BottomLine(),
                              titleWidget('联系方式'),
                              Row(
                                children: [
                                  checkboxServes('手机'),
                                  checkboxServes('微信'),
                                  checkboxServes('QQ'),
                                  Expanded(
                                      child: SizedBox(
                                    height: 15.w,
                                    child: TextField(
                                      scrollPadding: EdgeInsets.zero,
                                      controller: myController,
                                      inputFormatters: <TextInputFormatter>[
                                        LengthLimitingTextInputFormatter(18),
                                        FilteringTextInputFormatter.deny(
                                            RegExp('[ ]'))
                                      ],
                                      onEditingComplete: () {
                                        FocusScope.of(context).unfocus();
                                      },
                                      decoration: InputDecoration(
                                        hintText: '输入联系$selectConnect',
                                        hintStyle: TextStyle(
                                            color: StyleTheme.cBioColor),
                                        contentPadding: EdgeInsets.zero,
                                        fillColor: StyleTheme.textbgColor1,
                                        disabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(30.0),
                                            borderSide: BorderSide(
                                                color: Colors.transparent,
                                                width: 0)),
                                        focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(30.0),
                                            borderSide: BorderSide(
                                                color: Colors.transparent,
                                                width: 0)),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(30.0),
                                            borderSide: BorderSide(
                                                color: Colors.transparent,
                                                width: 0)),
                                        enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(30.0),
                                            borderSide: BorderSide(
                                                color: Colors.transparent,
                                                width: 0)),
                                      ),
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  ))
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 20.w),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '露脸',
                                      style: TextStyle(
                                          color: StyleTheme.cTitleColor,
                                          fontSize: 14.sp),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        checkboxServes('是', onTap: () {
                                          isFace = true;
                                          setState(() {});
                                        }, value: isFace),
                                        checkboxServes('否', onTap: () {
                                          isFace = false;
                                          setState(() {});
                                        }, value: !isFace),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              BottomLine(),
                              titleWidget('服务项目', subtitle: '*可多选'),
                              SizedBox(
                                width: double.infinity,
                                child: Wrap(
                                  spacing: 15.w,
                                  runSpacing: 10.w,
                                  children: <Widget>[
                                    for (var item in releaseInfo!['services'])
                                      GestureDetector(
                                          onTap: () {
                                            if (selectServesProject
                                                    .indexOf(item['id']) >
                                                -1) {
                                              selectServesProject
                                                  .remove(item['id']);
                                            } else {
                                              selectServesProject
                                                  .add(item['id']);
                                            }
                                            setState(() {});
                                          },
                                          child: tagItemWidget(
                                              item,
                                              selectServesProject
                                                      .indexOf(item['id']) >
                                                  -1))
                                  ],
                                ),
                              ),
                              titleWidget('选择是否开通附加项目', subtitle: '*可多选'),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  for (var item
                                      in releaseInfo!['addition_items'])
                                    serversItem(item)
                                ],
                              ),
                              titleWidget('照片'),
                              UploadResouceWidget(
                                parmas: 'pic',
                                uploadType: 'image',
                                maxLength: 10,
                                initResouceList: [],
                              ),
                              SizedBox(
                                height: 45.w,
                              ),
                              Center(
                                child: GestureDetector(
                                  onTap: submitRlease,
                                  behavior: HitTestBehavior.translucent,
                                  child: Stack(
                                    children: [
                                      LocalPNG(
                                        width: 275.w,
                                        height: 50.w,
                                        url:
                                            'assets/images/mymony/money-img.png',
                                      ),
                                      Positioned.fill(
                                          child: Center(
                                              child: Text(
                                        '发布',
                                        style: TextStyle(
                                            fontSize: 15.w,
                                            color: Colors.white),
                                      ))),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: ScreenUtil().bottomBarHeight + 24.w,
                              )
                            ],
                          ))
              ],
            )));
  }
}
