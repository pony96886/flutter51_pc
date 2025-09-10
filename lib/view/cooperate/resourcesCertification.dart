import 'package:bot_toast/bot_toast.dart';
import 'package:chaguaner2023/components/citypickers/CommonCity_pickers.dart';
import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/loading.dart';
import 'package:chaguaner2023/components/page_title_bar.dart';
import 'package:chaguaner2023/components/upload/start_upload.dart';
import 'package:chaguaner2023/components/upload/upload_resouce.dart';
import 'package:chaguaner2023/input/InputDailog.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ResourcesCertification extends StatefulWidget {
  ResourcesCertification({Key? key}) : super(key: key);

  @override
  _ResourcesCertificationState createState() => _ResourcesCertificationState();
}

class _ResourcesCertificationState extends State<ResourcesCertification> {
  Map<int, dynamic> images = {}; //存储上传前图片
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _castWayController = TextEditingController();
  String? _reservationfee; //缴纳预约金
  String? _city; //选择城市
  String? _girlNum; //年龄
  int pageState = 0; //0 未提交认证  1 审核中 2审核通过
  String? _girlAge; //身高
  String _businessHours = ''; //营业时间
  String? _cpName; //罩杯
  String? _price;
  String? _cityCode;
  List? resources;
  List updateList = [
    {'title': '门面照', 'parmas': 'men'},
    {'title': '室内环境照', 'parmas': 'shi'},
    {'title': '部分技师合照', 'parmas': 'bu'},
  ];
  int imageLength = 0;
  List fileArr = [];
  bool loading = true;
  int? infoId;
  String? imgHost;
  String checkSubmStr = '确认修改并提交审核';
  @override
  void dispose() {
    StartUploadFile.dispose();
    super.dispose();
  }

  List basicInfo() {
    return [
      {
        'type': 'input', //是否需要选择
        'title': '茶铺名称',
        'onTop': null,
        'isNumber': false,
        'condition': (_cpName == ''),
        'inputInfo': '输入茶铺名称',
        'prompt': '请输入茶铺名称～',
        'value': _cpName,
        'callBack': (val) {
          setState(() {
            _cpName = val;
          });
        }
      },
      {
        'type': 'input', //是否需要选择
        'title': '用户缴纳预约金',
        'onTop': null,
        'isNumber': true,
        'condition': (_reservationfee == '' || int.parse(_reservationfee!) < 200),
        'inputInfo': '输入预约金，最少200元宝',
        'prompt': '请输入预约金，最少200元宝～',
        'value': _reservationfee,
        'callBack': (val) {
          try {
            if (int.parse(val) >= 200) {
              setState(() {
                _reservationfee = val;
              });
            } else {
              return BotToast.showText(text: '用户缴纳预约金至少为200元宝～', align: Alignment(0, 0));
            }
          } catch (e) {
            return BotToast.showText(text: '请按要求输入正确的数字～', align: Alignment(0, 0));
          }
        }
      },
      {
        'type': 'input', //是否需要选择
        'title': '消费情况',
        'onTop': null,
        'isNumber': true,
        'condition': (_price == ''),
        'inputInfo': '示例：2000-5000',
        'prompt': '请输入消费情况～',
        'value': _price,
        'callBack': (val) {
          setState(() {
            _price = val;
          });
        }
      },
      {
        'type': 'select', //是否需要选择
        'title': '所在城市',
        'isNumber': false,
        'onTop': _showCityPickers,
        'condition': (_city == ''),
        'inputInfo': '选择城市',
        'prompt': '请选择城市～',
        'value': _city,
        'callBack': (val) {
          setState(() {
            _city = val;
          });
        }
      },
      {
        'type': 'input', //是否需要选择
        'title': '妹子数量',
        'isNumber': true,
        'onTop': null,
        'condition': (_girlNum == ''),
        'inputInfo': '茶铺大约有多少个妹子',
        'prompt': '请输入茶铺妹子数量～',
        'value': _girlNum,
        'callBack': (val) {
          try {
            if (int.parse(val) > 0) {
              setState(() {
                _girlNum = val;
              });
            }
          } catch (e) {
            return BotToast.showText(text: '请按要求输入正确的数字～', align: Alignment(0, 0));
          }
        }
      },
      {
        'type': 'input', //是否需要选择
        'title': '妹子年龄',
        'isNumber': true,
        'onTop': null,
        'condition': (_girlAge == ''),
        'inputInfo': '妹子年龄范围,示例：18-25',
        'prompt': '请输入茶铺妹子年龄～',
        'value': _girlAge,
        'callBack': (val) {
          try {
            if (int.parse(val) > 0) {
              setState(() {
                _girlAge = val;
              });
            }
          } catch (e) {
            return BotToast.showText(text: '请按要求输入正确的数字～', align: Alignment(0, 0));
          }
        }
      },
      {
        'type': 'input', //是否需要选择
        'title': '营业时间',
        'isNumber': false,
        'onTop': null,
        'condition': (_businessHours == ''),
        'inputInfo': '输入营业时间',
        'prompt': '请输入营业时间',
        'value': _businessHours,
        'callBack': (val) {
          setState(() {
            _businessHours = val;
          });
        }
      }
    ];
  }

  getStore() {
    getChapuStore().then((res) {
      if (res!['status'] != 0) {
        if (res['data'] != null) {
          pageState = res['data']['status'];
          infoId = res['data']['id'];
          _cpName = res['data']['title'];
          _cityCode = res['data']['cityCode'].toString();
          _city = res['data']['cityName'];
          _girlAge = res['data']['girl_age'];
          _girlNum = res['data']['girl_num'];
          _businessHours = res['data']['business_hours'];
          _descriptionController.text = res['data']['desc'];
          _reservationfee = res['data']['fee'].toString();
          _price = res['data']['price'].toString();
          _castWayController.text = res['data']['cast_way'];
          resources = res['data']['resources'];
        }
        loading = false;
        setState(() {});
      } else {
        BotToast.showText(text: res['msg']);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getStore();
  }

  _showCityPickers() async {
    dynamic resultCity =
        await Navigator.push(context, new MaterialPageRoute(builder: (context) => CommonCityPickers()));
    if (resultCity != null) {
      setState(() {
        _city = resultCity.city;
        _cityCode = resultCity.code.toString();
      });
    }
  }

  releaseChapuForm(Map imageData) {
    if (imageData == null) {
      return BotToast.showText(text: '部分资源上传错误,请重试');
    }
    List _oimag = UploadFileList.allFile['image']!.originalUrls.map((e) {
      return {'url': e.path};
    }).toList();
    List _image = (imageData['image'] ?? []).map((e) {
      return {'url': e['url']};
    }).toList();
    if (pageState == 0) {
      releaseChapu({
        'title': _cpName,
        'cityCode': _cityCode,
        'girl_age': _girlAge,
        'girl_num': _girlNum,
        'business_hours': _businessHours,
        'desc': _descriptionController.text,
        'fee': _reservationfee,
        'price': _price,
        'cast_way': _castWayController.text,
        'auth_pic': [imageData['men'][0]['url'], imageData['men'][0]['shi'], imageData['bu'][0]['url']],
        'image': [..._oimag, ..._image]
      }).then((res) {
        if (res!['status'] != 0) {
          BotToast.showText(text: '茶铺信息已发布，请耐心等待官方认证');
          Navigator.pop(context);
        } else {
          BotToast.showText(text: res['msg']);
        }
      });
    } else {
      editChapuStore({
        'info_id': infoId,
        'title': _cpName,
        'cityCode': _cityCode,
        'girl_age': _girlAge,
        'girl_num': _girlNum,
        'business_hours': _businessHours,
        'desc': _descriptionController.text,
        'fee': _reservationfee,
        'price': _price,
        'cast_way': _castWayController.text,
        'image': [..._oimag, ..._image]
      }).then((res) {
        if (res!['status'] != 0) {
          BotToast.showText(text: '茶铺信息编辑成功，请耐心等待官方认证');
          Navigator.pop(context);
        } else {
          BotToast.showText(text: res['msg']);
        }
      });
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
              title: '茶铺认证',
            ),
            preferredSize: Size(double.infinity, 44.w)),
        body: loading
            ? Loading()
            : Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  SingleChildScrollView(
                    physics: ClampingScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 20.w,
                      ),
                      child: Column(
                        children: [
                          pageState != 1
                              ? Container()
                              : Container(
                                  padding: EdgeInsets.only(bottom: 49.w),
                                  child: Column(
                                    children: [
                                      LocalPNG(
                                          url: 'assets/images/publish/waitingicon.png',
                                          width: 125.5.w,
                                          height: 125.5.w,
                                          fit: BoxFit.contain),
                                      Text(
                                        '资料审核中，请耐心等待',
                                        style: TextStyle(
                                          color: StyleTheme.cTitleColor,
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                          pageState != 0
                              ? Container()
                              : Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 15.sp),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text.rich(TextSpan(
                                          text: '认证材料',
                                          style: TextStyle(
                                              color: StyleTheme.cTitleColor,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 18.sp),
                                          children: [
                                            TextSpan(
                                              text: '（以下照片必须露出官方手势“6”手势）',
                                              style: TextStyle(color: Color(0xffb4b4b4), fontSize: 12.sp),
                                            )
                                          ])),
                                      Container(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            for (var upItem in updateList)
                                              Column(
                                                children: [
                                                  Container(
                                                    margin: EdgeInsets.only(top: 20.w, bottom: 9.5.w),
                                                    height: 110.w,
                                                    width: 110.w,
                                                    child: UploadResouceWidget(
                                                      parmas: upItem['parmas'],
                                                      uploadType: 'image',
                                                      maxLength: 1,
                                                      isIndependent: true,
                                                    ),
                                                  ),
                                                  Container(
                                                    width: 110.w,
                                                    margin: EdgeInsets.only(
                                                      bottom: 29.w,
                                                    ),
                                                    child: Center(
                                                      child: Text(upItem['title'],
                                                          style: TextStyle(
                                                              color: StyleTheme.cTitleColor,
                                                              fontSize: 15.sp,
                                                              fontWeight: FontWeight.w500)),
                                                    ),
                                                  )
                                                ],
                                              )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                          pageState != 0
                              ? Container()
                              : Container(
                                  padding: EdgeInsets.symmetric(horizontal: 15.sp),
                                  width: double.infinity,
                                  height: 30.w,
                                  color: StyleTheme.bottomappbarColor,
                                  child: Row(
                                    children: [
                                      Text(
                                        '*以上材料仅用于认证将不会对外公开',
                                        style: TextStyle(
                                            color: StyleTheme.cDangerColor,
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w500),
                                      )
                                    ],
                                  ),
                                ),
                          for (var item in basicInfo()) inputItem(item),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15.sp),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListTile(
                                  contentPadding: EdgeInsets.only(left: 0, right: 0),
                                  title: Text('茶铺介绍', style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 14.sp)),
                                ),
                                Card(
                                    margin: EdgeInsets.zero,
                                    shadowColor: Colors.transparent,
                                    color: Color(0xFFF5F5F5),
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: TextField(
                                        enabled: pageState != 1,
                                        controller: _descriptionController,
                                        textInputAction: TextInputAction.done,
                                        autofocus: false,
                                        maxLines: 8,
                                        style: TextStyle(fontSize: 14.sp, color: StyleTheme.cTitleColor),
                                        decoration: InputDecoration.collapsed(
                                            hintStyle: TextStyle(fontSize: 14.sp, color: StyleTheme.cBioColor),
                                            hintText: "输入茶铺介绍，可详细介绍门店特色服务项目及价格等"),
                                      ),
                                    )),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15.sp),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListTile(
                                  contentPadding: EdgeInsets.only(left: 0, right: 0),
                                  title: Text('服务项目', style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 14.sp)),
                                ),
                                Card(
                                    margin: EdgeInsets.zero,
                                    shadowColor: Colors.transparent,
                                    color: Color(0xFFF5F5F5),
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: TextField(
                                        enabled: pageState != 1,
                                        controller: _castWayController,
                                        textInputAction: TextInputAction.done,
                                        autofocus: false,
                                        maxLines: 8,
                                        style: TextStyle(fontSize: 14.sp, color: StyleTheme.cTitleColor),
                                        decoration: InputDecoration.collapsed(
                                            hintStyle: TextStyle(fontSize: 14.sp, color: StyleTheme.cBioColor),
                                            hintText: "请介绍茶铺的服务项目,要求服务项目真实。"),
                                      ),
                                    )),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 30.w, horizontal: 15.sp),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text.rich(TextSpan(
                                    text: '对外展示照片',
                                    style: TextStyle(
                                        color: StyleTheme.cTitleColor, fontWeight: FontWeight.w500, fontSize: 18.sp),
                                    children: [
                                      TextSpan(
                                        text: '（第一张将作为封面展示）',
                                        style: TextStyle(color: Color(0xffb4b4b4), fontSize: 12.sp),
                                      )
                                    ])),
                                Container(
                                  margin: EdgeInsets.only(top: 20.w),
                                ),
                                UploadResouceWidget(
                                  parmas: 'image',
                                  uploadType: 'image',
                                  maxLength: 10,
                                  disabled: pageState == 1,
                                  initResouceList: resources == null
                                      ? []
                                      : resources!.map((e) {
                                          return FileInfo(e['url'], 0, 1, 'image', 'image', null, 0, 0);
                                        }).toList(),
                                ),
                                pageState == 1
                                    ? Container()
                                    : Center(
                                        child: GestureDetector(
                                          onTap: () {
                                            for (var i = 0; i < basicInfo().length; i++) {
                                              if (basicInfo()[i]['condition']) {
                                                BotToast.showText(
                                                    text: basicInfo()[i]['prompt'], align: Alignment(0, 0));
                                                return;
                                              }
                                            }
                                            for (var i = 0; i < updateList.length; i++) {
                                              if (pageState == 0 &&
                                                  UploadFileList.allFile[updateList[i]['parmas']]!.urls.length == 0) {
                                                BotToast.showText(text: '请上传按要求上传认证材料', align: Alignment(0, 0));
                                                return;
                                              }
                                            }
                                            if (UploadFileList.allFile['image']!.originalUrls.length +
                                                    UploadFileList.allFile['image']!.urls.length ==
                                                0) {
                                              BotToast.showText(text: '请上传对外展示图片', align: Alignment(0, 0));
                                              return;
                                            }
                                            if (_descriptionController.text == '') {
                                              return CommonUtils.showText('请填写茶铺介绍');
                                            }
                                            if (_castWayController.text == '') {
                                              return CommonUtils.showText('请填写服务项目');
                                            }

                                            StartUploadFile.upload().then((value) {
                                              if (value == null) {
                                                return CommonUtils.showText('资源上传错误,请重新上传');
                                              }
                                              releaseChapuForm(value);
                                            });
                                          },
                                          child: Container(
                                            margin: EdgeInsets.only(top: 50.w),
                                            width: 275.w,
                                            height: 50.w,
                                            child: Stack(
                                              children: [
                                                LocalPNG(
                                                  url: 'assets/images/elegantroom/shuimo_btn.png',
                                                  fit: BoxFit.contain,
                                                  width: 275.w,
                                                  height: 50.w,
                                                ),
                                                Center(
                                                  child: Text(
                                                    pageState == 0 ? '提交审核' : checkSubmStr,
                                                    style: TextStyle(color: Colors.white, fontSize: 15.sp),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
      ),
    );
  }

  Widget inputItem(Map item) {
    String selectStr = 'select';
    String unssd23 = 'unselect';
    String selectvalue = item['type'] == 'radio' ? (item['value'] ? selectStr : unssd23) : unssd23;
    String itemValueStr = item['value'].toString();
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ListTile(
            onTap: () {
              if (pageState != 1) {
                if (item['type'] == 'select') {
                  item['onTop']();
                } else if (item['type'] == 'input') {
                  InputDialog.show(context, item['title'],
                          limitingText: 16, boardType: item['isNumber'] ? TextInputType.phone : TextInputType.text)
                      .then((value) {
                    item['callBack'](value);
                  });
                } else {
                  item['callBack']();
                }
              }
            },
            contentPadding: EdgeInsets.only(left: 0, right: 0),
            title: Text(item['title'], style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 14.sp)),
            trailing: item['type'] == 'radio'
                ? GestureDetector(
                    onTap: item['callBack'],
                    child: Container(
                      width: 15.sp,
                      height: 15.sp,
                      margin: EdgeInsets.only(right: 5.5.w),
                      child: LocalPNG(
                        url: 'assets/images/card/$selectvalue.png',
                        width: 15.sp,
                        height: 15.sp,
                      ),
                    ),
                  )
                : Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Container(
                      constraints: BoxConstraints(maxWidth: 250.w),
                      child: Text(item['value'] == null || item['value'] == '' ? item['inputInfo'] : itemValueStr,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w500,
                              color: item['value'] == null || item['value'] == ''
                                  ? StyleTheme.cBioColor
                                  : StyleTheme.cTitleColor)),
                    ),
                    item['type'] == 'select'
                        ? (itemValueStr == null
                            ? Icon(Icons.keyboard_arrow_right, color: StyleTheme.cBioColor)
                            : Container())
                        : Container()
                  ]),
          ),
          BottomLine(),
        ],
      ),
    );
  }
}

class BottomLine extends StatelessWidget {
  const BottomLine({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFEEEEEE),
        border: Border(
          top: BorderSide.none,
          left: BorderSide.none,
          right: BorderSide.none,
          bottom: BorderSide(width: 0.5, color: Color(0xFFEEEEEE)),
        ),
      ),
    );
  }
}
