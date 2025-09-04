import 'package:chaguaner2023/components/citypickers/CommonCity_pickers.dart';
import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/pagetitlebar.dart';
import 'package:chaguaner2023/components/upload/upload_resouce.dart';
import 'package:chaguaner2023/input/InputDailog.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:chaguaner2023/view/upload/elegantfinish.dart';
import 'package:flutter/material.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ElegantPublishPage extends StatefulWidget {
  final Map? cardInfo;
  ElegantPublishPage({Key? key, this.cardInfo}) : super(key: key);
  @override
  State<StatefulWidget> createState() => ElegantPublishPageState();
}

class ElegantPublishPageState extends State<ElegantPublishPage> {
  TextEditingController _descriptionController = TextEditingController();
  //第一部分 基本信息
  String? _girlName; //妹子花名
  bool isGirl = true;
  bool isVideo = false;
  bool isHuakui = false;
  String? _reservationfee; //缴纳预约金
  String? _city; //选择城市
  String? _cityCode;
  String? _girlage; //年龄
  String? _girlHeight; //身高
  String? _girlCup; //罩杯
  int? _girlCupValue;
  Map? formData;
  PageController? pageController;

  String gender() => isGirl ? '妹子' : '男子';
  String cupString() => isGirl ? '罩杯' : '腹肌';

  basicInfo() {
    return [
      {
        'type': 'input', //是否需要选择
        'title': '${gender()}花名',
        'onTop': null,
        'isNumber': false,
        'inputInfo': '输入${gender()}花名或者编号',
        'value': _girlName,
        'callBack': (val) {
          _girlName = val;
          setState(() {});
        }
      },
      {
        'type': 'radio', //是否需要选择
        'title': '是否支持视频认证',
        'onTop': null,
        'isNumber': false,
        'inputInfo': '输入${gender()}花名或者编号',
        'value': isVideo,
        'prompt': '视频认证指茶老板将${gender()}素颜视频提交官方认证，官方确认人照差距不大后才会有视频认证的标识。',
        'callBack': () {
          isVideo = !isVideo;
          setState(() {});
        }
      },
      {
        'type': 'radio', //是否需要选择
        'title': '加入花魁阁楼',
        'onTop': null,
        'isNumber': false,
        'inputInfo': '输入${gender()}花名或者编号',
        'value': isHuakui,
        'prompt': [
          '• 必须勾选“支持视频认证”',
          '• 资料必须添加视频展示',
          '• 最低消费价格5000元',
          '• 支持空降，路费实报实销'
        ],
        'callBack': () {
          isHuakui = !isHuakui;
          setState(() {});
        }
      },
      {
        'type': 'select', //是否需要选择
        'title': '选择城市',
        'isNumber': false,
        'onTop': _showCityPickers,
        'inputInfo': '选择所在城市',
        'value': _city,
        'callBack': (val) {
          _city = val;
          setState(() {});
        }
      },
      {
        'type': 'input', //是否需要选择
        'title': '年龄(岁)',
        'isNumber': true,
        'onTop': null,
        'inputInfo': '输入目前年龄',
        'value': _girlage,
        'callBack': (val) {
          setState(() {
            _girlage = val;
          });
        }
      },
      {
        'type': 'input', //是否需要选择
        'title': '身高(cm)',
        'isNumber': true,
        'onTop': null,
        'inputInfo': '输入${gender()}身高',
        'value': _girlHeight,
        'callBack': (val) {
          setState(() {
            _girlHeight = val;
          });
        }
      },
      {
        'type': isGirl ? 'select' : 'input',
        'title': cupString(),
        'isNumber': isGirl ? false : true,
        'onTop': showSelectCup,
        'inputInfo': '${isGirl ? '选择' : '输入'}${gender() + cupString()}',
        'value': _girlCup,
        'callBack': (val) {
          setState(() {
            _girlCup = val;
          });
        }
      }
    ];
  }

  //第二部分 消费情况
  String? _oPrice; //1P价格
  String? _tPrice; //2p价格
  String? _yePrice; //包夜价格
  List selectPatterns = [];
  List patternsList = [
    {'title': '上门', 'id': 1},
    {'title': '到店', 'id': 2},
    {'title': '空降', 'id': 3}
  ];
  consumptionList() {
    return [
      {
        'type': 'input', //是否需要选择
        'title': '1P价格(元)',
        'isNumber': true,
        'onTop': null,
        'inputInfo': '输入价格',
        'value': _oPrice,
        'callBack': (val) {
          double reservation = double.parse(val) / 10;
          double? showReservation;
          if (reservation <= 200) {
            showReservation = 200;
          }
          if (reservation > 200 && reservation < 500) {
            showReservation =
                double.parse(((reservation / 100).round() * 100).toString());
          }
          if (reservation >= 500) {
            showReservation = 500;
          }
          setState(() {
            _oPrice = val;
            _reservationfee = showReservation!.toStringAsFixed(0);
          });
        }
      },
      {
        'type': 'input', //是否需要选择
        'title': '2P价格(元)',
        'isNumber': true,
        'onTop': null,
        'inputInfo': '输入价格',
        'value': _tPrice,
        'callBack': (val) {
          setState(() {
            _tPrice = val;
          });
        }
      },
      {
        'type': 'input', //是否需要选择
        'title': '包夜价格(元)',
        'isNumber': true,
        'onTop': null,
        'inputInfo': '输入价格',
        'value': _yePrice,
        'callBack': (val) {
          setState(() {
            _yePrice = val;
          });
        }
      }
    ];
  }

  //第三部分 服务项目
  List tagItems = [];
  List<int> _serviceItems = [];
  //第四部分 详细描述

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: 0);
    getTags().then((tags) {
      if (tags!['data'] != null) {
        tagItems = tags['data'];
        setState(() {});
      }
    });

    List<int> cartags = [];
    widget.cardInfo?['tags'].forEach((item) {
      cartags.add(item['id']);
    });
    print(widget.cardInfo);
    _serviceItems = cartags;
    _girlName = widget.cardInfo?['title']; //花名
    isVideo = (widget.cardInfo?['video_valid'] == 1);
    isHuakui = (widget.cardInfo?['vvip'] == 1);
    _reservationfee = widget.cardInfo?['fee'].toString(); //预约金金额
    _city = widget.cardInfo?['cityName']; //城市名
    _cityCode = widget.cardInfo?['cityCode'] == null
        ? null
        : widget.cardInfo?['cityCode'].toString(); //城市code
    _girlage = widget.cardInfo?['girl_age_num'] == null
        ? null
        : widget.cardInfo?['girl_age_num'].toString(); //妹子年龄
    _girlHeight = widget.cardInfo?['girl_height'] == null
        ? null
        : widget.cardInfo?['girl_height'].toString(); //身高
    _girlCup = widget.cardInfo?['girl_cup'] == null
        ? null
        : widget.cardInfo?['post_type'] == 2
            ? widget.cardInfo!['girl_cup'].toString()
            : CommonUtils.getCup(widget.cardInfo?['girl_cup']);
    _girlCupValue = widget.cardInfo?['post_type'] == 2
        ? widget.cardInfo!['girl_cup']
        : widget.cardInfo?['girl_cup'];
    _oPrice = widget.cardInfo?['price_p'] == null
        ? null
        : widget.cardInfo?['price_p'].toString();
    _tPrice = widget.cardInfo?['price_pp'] == null
        ? null
        : widget.cardInfo?['price_pp'].toString();
    _yePrice = widget.cardInfo?['price_all_night'] == null
        ? null
        : widget.cardInfo?['price_all_night'].toString();
    selectPatterns = widget.cardInfo?['cast_way'] == null
        ? []
        : widget.cardInfo?['cast_way'].split(',');
    isGirl = widget.cardInfo?['post_type'] == null
        ? true
        : widget.cardInfo?['post_type'] == 1;
    // print(_girlCupValue);
    _descriptionController.text = widget.cardInfo?['desc'] ?? ''; //描述
    setState(() {});
  }

  @override
  void dispose() {
    AppGlobal.uploadParmas = null;
    pageController!.dispose();
    UploadFileList.dispose();
    super.dispose();
  }

  _showCityPickers() async {
    dynamic resultCity = await Navigator.push(context,
        new MaterialPageRoute(builder: (context) => CommonCityPickers()));
    if (resultCity != null) {
      setState(() {
        _city = resultCity.city;
        _cityCode = resultCity.code.toString();
      });
    }
  }

  void showText(text) {
    BotToast.showText(text: '$text', align: Alignment(0, 0));
  }

  bool isNumeric(string) => int.tryParse(string) != null;
  getReqTags() {
    return tagItems
        .where((item) => _serviceItems.indexOf(item['id']) != -1)
        .toList();
  }

  void saveParam() {
    //检查第一部分
    for (var item in basicInfo()) {
      String inputInfoS = item['inputInfo'];
      if (item['value'] == null || item['value'] == '') {
        return showText("请$inputInfoS");
      }
      if (item['isNumber']) {
        if (!isNumeric(item['value'])) {
          return showText("请正确$inputInfoS");
        }
      }
    }
//检查第二部分
    for (var item in consumptionList()) {
      // if (item['value'] == null || item['value'] == '') {
      //   return showText("请${item['inputInfo']}");
      // }
      if (item['isNumber']) {
        if (item['value'] != null &&
            item['value'] != '' &&
            !isNumeric(item['value'])) {
          String titlts = item['title'];
          return showText("请正确输入$titlts");
        }
      }
    }
    if (_oPrice == '') {
      return showText("1P价格为必填项,其他价格为选填～");
    }
    if (selectPatterns.length == 0) {
      return showText("请至少选择一项消费方式");
    }
    String ones = '1';
    formData = {
      "post_type": (isGirl == true) ? 1 : 2,
      "title": _girlName, //妹子花名
      "video_valid": isVideo ? ones : "0",
      "vvip": isHuakui ? ones : "0",
      "cityCode": _cityCode, //城市code
      "fee": _reservationfee, //预约金金额
      "girl_age_num": _girlage == null ? '' : _girlage, //妹子年龄
      "girl_height": _girlHeight == null ? '' : _girlHeight, //妹子身高
      "girl_cup": isGirl ? _girlCupValue.toString() : _girlCup, //妹子罩杯
      "cast_way": selectPatterns.join(','), //消费方式
      "price_p": _oPrice, //1p价格
      "price_pp": _tPrice, //2p价格
      "price_all_night": _yePrice, //包夜价格
      "desc": _descriptionController.text, //详细描述
      "info_id":
          widget.cardInfo == null ? "" : widget.cardInfo!['id'].toString(),
    };
    setState(() {});
    pageController!.jumpToPage(1);
  }

  cupItem(String title, int id) {
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
              _girlCup = title;
              _girlCupValue = id;
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
              for (var item in CommonUtils.getCupList())
                cupItem(item['title'], item['id'])
            ],
          );
        });
  }

  onSwitchCup(bool value) {
    setState(() {
      isGirl = value;
      _girlCup = '';
      _girlCupValue = null;
    });
    if (value) {
      showText("已重置罩杯选项，请选择");
    } else {
      showText("已重置腹肌数量，请输入");
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: pageController,
      physics: NeverScrollableScrollPhysics(),
      children: [
        HeaderContainer(
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.transparent,
            appBar: PreferredSize(
                child: PageTitleBar(
                  title: '发布',
                ),
                preferredSize: Size(double.infinity, 44.w)),
            body: Container(
              width: double.infinity,
              height: double.infinity,
              child: SingleChildScrollView(
                physics: ClampingScrollPhysics(),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 15.w),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 15.w),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          onSwitchCup(true);
                                        },
                                        child: Container(
                                          margin: EdgeInsets.only(right: 20.w),
                                          child: Row(
                                            children: [
                                              LocalPNG(
                                                width: 15.w,
                                                height: 15.w,
                                                url:
                                                    'assets/images/card/${isGirl ? "select" : "unselect"}.png',
                                              ),
                                              SizedBox(width: 5.5.w),
                                              Text("高端外围")
                                            ],
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          onSwitchCup(false);
                                        },
                                        child: Row(
                                          children: [
                                            LocalPNG(
                                              width: 15.w,
                                              height: 15.w,
                                              url:
                                                  'assets/images/card/${!isGirl ? "select" : "unselect"}.png',
                                            ),
                                            SizedBox(width: 5.5.w),
                                            Text("高端男模")
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  BottomLine(),
                                ],
                              ),
                            ),
                            SizedBox(height: 10.w),
                            Container(
                                margin: EdgeInsets.symmetric(horizontal: 15.w),
                                child: Text("基本信息",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        color: StyleTheme.cTitleColor,
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.bold))),
                            SizedBox(height: 10.w),
                            //====================================================基本信息=============================================
                            for (var item in basicInfo()) inputItem(item),
                            //=====================================================消费情况===============================================
                            Container(
                              margin: EdgeInsets.only(top: 20.w, bottom: 15.sp),
                              child: Row(
                                children: <Widget>[
                                  Container(
                                      margin: EdgeInsets.symmetric(
                                          horizontal: 15.w),
                                      child: Text("消费情况",
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              color: StyleTheme.cTitleColor,
                                              fontSize: 18.sp,
                                              fontWeight: FontWeight.bold))),
                                  Container(
                                    margin: EdgeInsets.only(left: 10.w),
                                    child: Text(
                                      '*必须输入至少一项价格',
                                      style: TextStyle(
                                          color: StyleTheme.cDangerColor,
                                          fontSize: 11.sp),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            for (var item in consumptionList()) inputItem(item),
                            Container(
                                margin: EdgeInsets.symmetric(horizontal: 15.w),
                                child: ListTile(
                                  contentPadding:
                                      EdgeInsets.only(left: 0, right: 0),
                                  title: Text("缴纳预约金(元宝)",
                                      style: TextStyle(
                                          color: StyleTheme.cTitleColor,
                                          fontSize: 14.sp)),
                                  trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Container(
                                          constraints:
                                              BoxConstraints(maxWidth: 175.w),
                                          child: Text(
                                              _reservationfee == null
                                                  ? "请先输入1P价格"
                                                  : _reservationfee!,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontSize: 15.sp,
                                                  fontWeight: FontWeight.w500,
                                                  color: _reservationfee == null
                                                      ? StyleTheme.cBioColor
                                                      : StyleTheme
                                                          .cTitleColor)),
                                        ),
                                      ]),
                                )),
                            Container(
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.symmetric(horizontal: 15.w),
                              width: double.infinity,
                              color: StyleTheme.bottomappbarColor,
                              height: 25.w,
                              child: Text('*消费方式必须勾选一项，可多选',
                                  style: TextStyle(
                                      color: StyleTheme.cDangerColor,
                                      fontSize: 11.sp)),
                            ),
                            StatefulBuilder(builder: (context, setRadio) {
                              return Container(
                                padding: EdgeInsets.symmetric(horizontal: 15.w),
                                margin:
                                    EdgeInsets.only(top: 20.w, bottom: 20.w),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text('消费方式',
                                        style: TextStyle(
                                            color: StyleTheme.cTitleColor,
                                            fontSize: 14.sp)),
                                    Row(
                                      children: <Widget>[
                                        for (var item in patternsList)
                                          checkbox(item['title'], item['id'],
                                              setRadio)
                                      ],
                                    )
                                  ],
                                ),
                              );
                            }),
                            BottomLine(),
                            //=====================================================服务项目================================================
                            Container(
                              margin: EdgeInsets.only(top: 20.w, bottom: 15.w),
                              child: Row(
                                children: <Widget>[
                                  Container(
                                      margin: EdgeInsets.symmetric(
                                          horizontal: 15.w),
                                      child: Text("服务项目",
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              color: StyleTheme.cTitleColor,
                                              fontSize: 18.sp,
                                              fontWeight: FontWeight.bold))),
                                  Container(
                                    margin: EdgeInsets.only(left: 10.w),
                                    child: Text(
                                      '*勾选的项目必须要有，可不选',
                                      style: TextStyle(
                                          color: StyleTheme.cDangerColor,
                                          fontSize: 11.sp),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            StatefulBuilder(builder: (context, setTag) {
                              return Container(
                                padding: EdgeInsets.symmetric(horizontal: 15.w),
                                child: Wrap(
                                  spacing: 10.w,
                                  runSpacing: 10.w,
                                  children: <Widget>[
                                    for (var item in tagItems)
                                      tagItemWidget(
                                          item['name'], item['id'], setTag)
                                  ],
                                ),
                              );
                            }),

                            //=====================================================详细描述================================================
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 15.w),
                              margin: EdgeInsets.only(top: 15.w),
                              child: Column(
                                children: <Widget>[
                                  ListTile(
                                    contentPadding:
                                        EdgeInsets.only(left: 0, right: 0),
                                    title: Text("详细描述（选填）",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            color: StyleTheme.cTitleColor,
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  Card(
                                      margin: EdgeInsets.zero,
                                      shadowColor: Colors.transparent,
                                      color: Color(0xFFF5F5F5),
                                      child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: TextField(
                                          controller: _descriptionController,
                                          textInputAction: TextInputAction.done,
                                          autofocus: false,
                                          maxLines: 8,
                                          style: TextStyle(
                                              fontSize: 14.sp,
                                              color: StyleTheme.cTitleColor),
                                          decoration: InputDecoration.collapsed(
                                              hintStyle: TextStyle(
                                                  fontSize: 14.sp,
                                                  color: StyleTheme.cBioColor),
                                              hintText:
                                                  "可以详细描述${gender()}的优势特征，或补充基础、消费信息等"),
                                        ),
                                      )),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 15.w,
                            ),
                            GestureDetector(
                              onTap: () {
                                saveParam();
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                    vertical: 30.w, horizontal: 15.5.w),
                                height: 50.w,
                                alignment: Alignment.center,
                                child: LocalPNG(
                                  height: 50.w,
                                  fit: BoxFit.cover,
                                  url: "assets/images/publish/next.png",
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ]),
              ),
            ),
          ),
        ),
        Container(
          child: widget.cardInfo == null
              ? ElegantFinish(
                  tags: getReqTags(),
                  elegantdata: formData,
                  pageController: pageController)
              : ElegantFinish(
                  elegantdata: formData,
                  tags: getReqTags(),
                  images: widget.cardInfo!['resources']
                      .where((item) => item['type'] == 1)
                      .toList(),
                  video: widget.cardInfo!['resources']
                      .where((item) => item['type'] == 2)
                      .toList(),
                  pageController: pageController),
        )
      ],
    );
  }

  Widget checkbox(String title, int id, Function setRadio) {
    String selectIcon = 'select';
    String noseleasidh = 'unselect';
    String selectUrl =
        selectPatterns.indexOf(title) > -1 ? selectIcon : noseleasidh;
    return GestureDetector(
      onTap: () {
        if (selectPatterns.indexOf(title) > -1) {
          selectPatterns.remove(title);
        } else {
          selectPatterns.add(title);
        }
        setRadio(() {});
      },
      behavior: HitTestBehavior.translucent,
      child: Container(
        margin: EdgeInsets.only(left: 30.w),
        child: Row(
          children: <Widget>[
            LocalPNG(
              width: 15.w,
              height: 15.w,
              url: 'assets/images/card/$selectUrl.png',
            ),
            SizedBox(
              width: 5.5.w,
            ),
            Text(title)
          ],
        ),
      ),
    );
  }

  Widget tagItemWidget(String title, int id, Function setTag) {
    return GestureDetector(
      onTap: () {
        if (_serviceItems.indexOf(id) > -1) {
          _serviceItems.remove(id);
        } else {
          _serviceItems.add(id);
        }
        setTag(() {});
      },
      child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          height: 25.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: _serviceItems.indexOf(id) > -1
                ? Color(0xFFFDF0E4)
                : StyleTheme.bottomappbarColor,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                title,
                style: TextStyle(
                    fontSize: 12.sp,
                    color: _serviceItems.indexOf(id) > -1
                        ? StyleTheme.cDangerColor
                        : StyleTheme.cTitleColor),
              ),
            ],
          )),
    );
  }

  Widget inputItem(Map item) {
    dynamic values = item['value'];
    String selectStr = 'select';
    String noseleasidh = 'unselect';
    String selectUrl = item['type'] == 'radio'
        ? (values ? selectStr : noseleasidh)
        : noseleasidh;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ListTile(
            onTap: () {
              if (item['type'] == 'select') {
                item['onTop']();
              } else if (item['type'] == 'input') {
                InputDialog.show(context, item['title'],
                        limitingText: 16,
                        boardType: item['isNumber']
                            ? TextInputType.number
                            : TextInputType.text)
                    .then((value) {
                  item['callBack'](value);
                });
              } else {
                item['callBack']();
              }
            },
            contentPadding: EdgeInsets.only(left: 0, right: 0),
            title: Text(item['title'],
                style:
                    TextStyle(color: StyleTheme.cTitleColor, fontSize: 14.sp)),
            trailing: item['type'] == 'radio'
                ? GestureDetector(
                    onTap: item['callBack'],
                    behavior: HitTestBehavior.translucent,
                    child: Container(
                      width: 15.w,
                      height: 15.w,
                      margin: EdgeInsets.only(right: 5.5.sp),
                      child: LocalPNG(
                        width: 15.w,
                        height: 15.w,
                        url: 'assets/images/card/$selectUrl.png',
                      ),
                    ),
                  )
                : Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Container(
                      constraints: BoxConstraints(maxWidth: 175.w),
                      child: Text(
                          item['value'] == null
                              ? item['inputInfo']
                              : values.toString(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w500,
                              color: item['value'] == null
                                  ? StyleTheme.cBioColor
                                  : StyleTheme.cTitleColor)),
                    ),
                    item['type'] == 'select'
                        ? (item['value'] == null
                            ? Icon(Icons.keyboard_arrow_right,
                                color: StyleTheme.cBioColor)
                            : Container())
                        : Container()
                  ]),
          ),
          item['prompt'] == null
              ? Container()
              : (item['prompt'] is List
                  ? Container(
                      margin: EdgeInsets.only(bottom: 20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (var item in item['prompt'])
                            Text(
                              item,
                              style: TextStyle(
                                  color: StyleTheme.cBioColor, fontSize: 12.sp),
                            )
                        ],
                      ),
                    )
                  : Container(
                      margin: EdgeInsets.only(bottom: 20.w),
                      child: Text(
                        item['prompt'],
                        style: TextStyle(
                            color: StyleTheme.cBioColor, fontSize: 12.sp),
                      ),
                    )),
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

class MultipleChoiceeChipWidget extends StatefulWidget {
  final List<String>? strings;
  final List<String>? selectList;
  final void Function(List<String>)? onChanged;
  final GestureTapCallback? addItem;
  MultipleChoiceeChipWidget(
      {this.strings, this.selectList, this.onChanged, this.addItem, Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MultipleChoiceeChipWidgetState();
  }
}

class MultipleChoiceeChipWidgetState extends State<MultipleChoiceeChipWidget> {
  Iterable<Widget> get actorWidgets sync* {
    List<String> list = this.widget.strings!;
    List<String> selectList = this.widget.selectList!;
    if (list.length == 0) {
      Container();
    } else {
      for (String actor in list) {
        yield Container(
          padding: EdgeInsets.only(top: 5, right: 10, bottom: 5),
          child: TagsItem(
            text: actor,
            selected: selectList.contains(actor),
            onSelected: (selected) {
              selectList.contains(actor)
                  ? selectList.remove(actor)
                  : selectList.add(actor);
              this.widget.onChanged!(selectList);
            },
          ),
        );
      }
      yield Container(
        padding: EdgeInsets.only(top: 5, right: 10, bottom: 5),
        child: GestureDetector(
          onTap: this.widget.addItem,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 4.5.w, horizontal: 10.5.w),
            color: Color(0xFFFDF0E4),
            child: Text(
              '+自定义',
              style: TextStyle(color: Color(0xFFFF4149), fontSize: 12.sp),
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Wrap(
          children: actorWidgets.toList(),
        ),
      ],
    );
  }
}

class TagsItem extends StatefulWidget {
  final String? text;
  final ValueChanged<bool>? onSelected;
  final bool? selected;
  TagsItem({Key? key, this.text, this.onSelected, this.selected})
      : super(key: key);

  @override
  _TagsItemState createState() => _TagsItemState();
}

class _TagsItemState extends State<TagsItem> {
  @override
  Widget build(BuildContext context) {
    bool _select = widget.selected!;
    return GestureDetector(
      onTap: () {
        widget.onSelected!(!_select);
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 4.5.w, horizontal: 10.5.w),
        decoration: BoxDecoration(
            color: _select ? Color(0xFFFDF0E4) : Colors.white,
            borderRadius: BorderRadius.circular(30)),
        child: Text(
          widget.text!,
          style: TextStyle(color: Color(0xFFFF4149), fontSize: 12.sp),
        ),
      ),
    );
  }
}
