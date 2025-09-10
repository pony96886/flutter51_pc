import 'package:chaguaner2023/components/citypickers/CommonCity_pickers.dart';
import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/loading.dart';
import 'package:chaguaner2023/components/page_title_bar.dart';
import 'package:chaguaner2023/components/starrating.dart';
import 'package:chaguaner2023/input/InputDailog.dart';
import 'package:chaguaner2023/store/global.dart';
import 'package:chaguaner2023/store/homeConfig.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:chaguaner2023/utils/pageviewmixin.dart';
import 'package:chaguaner2023/view/upload/finishpublish.dart';
import 'package:flutter/material.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class PublishPage extends StatefulWidget {
  final String? id;
  PublishPage({Key? key, this.id}) : super(key: key);
  @override
  State<StatefulWidget> createState() => PublishPageState();
}

class PublishPageState extends State<PublishPage> {
  bool loading = false;
  String? _informationtitle;
  String? _type;
  int? _typeValue;
  String? _city;
  String? _cityCode;
  String? _girlnumber;
  String? _girlage;
  double _quality = 0.0;
  double _service = 0.0;
  int isHosting = 1;
  int resourceunlock = 0;
  String? _serviceitems;
  Map? editInfoData;
  List _typeValueList = [];
  List? patternsList;
  Map<String, String>? formData;
  PageController? controller;

  @override
  void initState() {
    super.initState();
    controller = PageController(initialPage: 0);

    if (widget.id != null) {
      loading = true;
      geteditInfo(int.tryParse(widget.id ?? '')).then((res) {
        if (res!['status'] != 0) {
          editInfoData = res['data'];
          _informationtitle = editInfoData?['title'];
          _girlnumber = editInfoData?['girl_num'];
          _girlage = editInfoData?['girl_age'];
          isHosting = editInfoData?['tran_flag'];
          _quality = editInfoData?['girl_face'].toDouble();
          _service = editInfoData?['girl_service'].toDouble();
          _serviceitems = editInfoData?['girl_service_type'];
          loading = false;
          setState(() {});
        }
      });
    }
    checkAgent();
    intTabList();
  }

  @override
  void dispose() {
    AppGlobal.uploadParmas = null;
    controller!.dispose();
    super.dispose();
  }

  checkAgent() {
    var providerData =
        Provider.of<HomeConfig>(context, listen: false).member.agent;
    if ([1, 2, 5].contains(providerData)) {
      patternsList = [
        {'title': '支持', 'id': 1},
        {'title': '不支持', 'id': 0}
      ];
    } else {
      patternsList = [];
      isHosting = 0;
    }
    setState(() {});
  }

  intTabList() async {
    var tabLists = Provider.of<GlobalState>(context, listen: false).infotype;
    if (tabLists.length > 0) {
      _typeValueList = tabLists
          .where((element) => element['type'] == AppGlobal.publishPostType)
          .toList();
    }
    if (UserInfo.agent == 2) {
      resourceunlock = 1;
    }
    setState(() {});
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

  void saveParam() {
    if (_informationtitle == null && widget.id == null) {
      showText("请输入信息标题");
      return;
    }
    if (_type == null && widget.id == null) {
      showText("请选择类型");
      return;
    }
    if (_city == null && widget.id == null) {
      showText("请选择城市");
      return;
    }
    if (_girlnumber == null) {
      showText("请输入妹子数量");
      return;
    }
    if (_girlage == null) {
      showText("请输入妹子年龄");
      return;
    }
    if (_quality == 0.0) {
      showText("请评级妹子颜值");
      return;
    }
    if (_service == 0.0) {
      showText("请评级服务质量");
      return;
    }
    if (_serviceitems == null) {
      showText("请输入服务项目");
      return;
    }

    formData = {
      "title": _informationtitle ?? '',
      "type": _typeValue.toString(),
      "city": _cityCode ?? '',
      "girlnumber": _girlnumber ?? '',
      "girlage": _girlage ?? '',
      "tranFlag": isHosting.toString(),
      "quality": _quality.toString(),
      "service": _service.toString(),
      "serviceitems": _serviceitems!,
      // "resourceunlock": resourceunlock.toString(),
    };
    setState(() {});
    controller!.jumpToPage(1);
  }

  Widget checkLockBox(String title, int id) {
    String seleS = 'select';
    String uusa = 'unselect';
    String selectS = resourceunlock == id ? seleS : uusa;
    return GestureDetector(
        onTap: () {
          if (UserInfo.agent == 2) {
            BotToast.showText(text: '茶小二发帖仅支持元宝解锁');
            return;
          } else {
            setState(() {
              resourceunlock = resourceunlock == 1 ? 0 : 1;
            });
          }
        },
        child: Container(
          margin: EdgeInsets.only(left: 30.w),
          child: Row(
            children: <Widget>[
              LocalPNG(
                width: 15.w,
                height: 15.w,
                url: 'assets/images/card/$selectS.png',
              ),
              SizedBox(width: 5.5.w),
              Text(title)
            ],
          ),
        ));
  }

  Widget checkbox(String title, int id) {
    String selectss = 'select';
    String uusa = 'unselect';
    String cardS = isHosting == id ? selectss : uusa;
    return GestureDetector(
      onTap: () {
        isHosting = isHosting == 1 ? 0 : 1;
        setState(() {});
      },
      child: Container(
        margin: EdgeInsets.only(left: 30.w),
        child: Row(
          children: <Widget>[
            LocalPNG(
              width: 15.w,
              height: 15.w,
              url: 'assets/images/card/$cardS.png',
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

  Widget simpleTypeOption() {
    List<Widget> tiles = [];
    Widget content;
    for (int i = 0; i < _typeValueList.length; i++) {
      tiles.add(SimpleDialogOption(
          child: Center(
            child: Text(_typeValueList[i]['title'],
                style:
                    TextStyle(color: StyleTheme.cTitleColor, fontSize: 14.sp)),
          ),
          onPressed: () {
            Navigator.pop(context);
            setState(() {
              _type = _typeValueList[i]['title'];
              _typeValue = _typeValueList[i]['id'];
            });
          }));
      if (i + 1 != _typeValueList.length) {
        tiles.add(BottomLine());
      }
    }

    content = new SimpleDialog(
        shape: RoundedRectangleBorder(
            side: BorderSide(
              style: BorderStyle.none,
            ),
            borderRadius: BorderRadius.circular(10)),
        contentPadding: EdgeInsets.symmetric(vertical: 15.w, horizontal: 15.w),
        children: tiles);

    return content;
  }

  @override
  Widget build(BuildContext context) {
    return PageView(controller: controller, children: [
      PageViewMixin(
        child: HeaderContainer(
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.transparent,
            appBar: PreferredSize(
                child: PageTitleBar(
                  title: AppGlobal.publishPostType == 0 ? '店家发布' : '个人分享',
                  rightWidget: GestureDetector(
                      onTap: () {
                        AppGlobal.appRouter
                            ?.push(CommonUtils.getRealHash('publishRule'));
                      },
                      child: Center(
                        child: Container(
                          margin: new EdgeInsets.only(right: 7.5.w),
                          child: Text(
                            '发帖规则',
                            style: TextStyle(
                                color: StyleTheme.cTitleColor,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      )),
                ),
                preferredSize: Size(double.infinity, 44.w)),
            body: loading
                ? Loading()
                : Container(
                    width: double.infinity,
                    height: double.infinity,
                    child: SingleChildScrollView(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                  top: 15.5.w, left: 15.5.w, right: 15.5.w),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text("基本信息",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          color: StyleTheme.cTitleColor,
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.w500)),
                                  SizedBox(height: 10.w),
                                  widget.id == null
                                      ? ListTile(
                                          onTap: () {
                                            InputDialog.show(context, '信息标题',
                                                    limitingText: 16)
                                                .then((value) {
                                              setState(() {
                                                _informationtitle = value;
                                              });
                                            });
                                          },
                                          contentPadding: EdgeInsets.only(
                                              left: 0, right: 0),
                                          title: Text('信息标题',
                                              style: TextStyle(
                                                  color: StyleTheme.cTitleColor,
                                                  fontSize: 14.sp)),
                                          trailing: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                Text(
                                                    _informationtitle == null
                                                        ? '输入信息标题'
                                                        : _informationtitle
                                                            .toString(),
                                                    style: TextStyle(
                                                        fontSize: 14.sp,
                                                        color: _informationtitle ==
                                                                null
                                                            ? StyleTheme
                                                                .cBioColor
                                                            : StyleTheme
                                                                .cTitleColor)),
                                              ]),
                                        )
                                      : Container(),
                                  widget.id == null
                                      ? BottomLine()
                                      : Container(),
                                  widget.id == null
                                      ? ListTile(
                                          onTap: () {
                                            showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return simpleTypeOption();
                                                });
                                          },
                                          contentPadding: EdgeInsets.only(
                                              left: 0, right: 0),
                                          title: Text('资源类型',
                                              style: TextStyle(
                                                  color: StyleTheme.cTitleColor,
                                                  fontSize: 14.sp)),
                                          trailing: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                Text(
                                                    _type == null
                                                        ? '请选择'
                                                        : _type.toString(),
                                                    style: TextStyle(
                                                        fontSize: 14.sp,
                                                        color: _type == null
                                                            ? StyleTheme
                                                                .cBioColor
                                                            : StyleTheme
                                                                .cTitleColor)),
                                                Icon(Icons.keyboard_arrow_right,
                                                    color:
                                                        StyleTheme.cBioColor),
                                              ]),
                                        )
                                      : Container(),
                                  BottomLine()
                                ],
                              ),
                            ),
                            patternsList!.length == 0
                                ? SizedBox()
                                : Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 15.5.w),
                                    child: ListTile(
                                      contentPadding:
                                          EdgeInsets.only(left: 0, right: 0),
                                      title: Text('品茶宝交易',
                                          style: TextStyle(
                                              color: StyleTheme.cTitleColor,
                                              fontSize: 14.sp)),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          for (var item in patternsList!)
                                            checkbox(item['title'], item['id'])
                                        ],
                                      ),
                                    ),
                                  ),
                            patternsList!.length == 0
                                ? SizedBox()
                                : Container(
                                    color: StyleTheme.bottomappbarColor,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 15.w, vertical: 9.9.w),
                                    child: Text(
                                      '品茶宝是官方创建的安全、可靠的资金托管工具。支持品茶宝交易的茶帖，其他用户可支付元宝托管，确认服务完成后，资金才会到茶帖发布者的账户中，妈妈再也不用担心我被骗了！收款(手续费20%)',
                                      style: TextStyle(
                                          fontSize: 11.sp,
                                          color: StyleTheme.cBioColor),
                                    ),
                                  ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 15.5.w),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  widget.id == null
                                      ? ListTile(
                                          onTap: () {
                                            _showCityPickers();
                                          },
                                          contentPadding: EdgeInsets.only(
                                              left: 0, right: 0),
                                          title: Text('选择城市',
                                              style: TextStyle(
                                                  color: StyleTheme.cTitleColor,
                                                  fontSize: 14.sp)),
                                          trailing: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                Text(
                                                    _city == null
                                                        ? '选择所在城市'
                                                        : _city.toString(),
                                                    style: TextStyle(
                                                        fontSize: 14.sp,
                                                        color: _city == null
                                                            ? StyleTheme
                                                                .cBioColor
                                                            : StyleTheme
                                                                .cTitleColor)),
                                                Icon(Icons.keyboard_arrow_right,
                                                    color:
                                                        StyleTheme.cBioColor),
                                              ]),
                                        )
                                      : Container(),
                                  widget.id == null
                                      ? BottomLine()
                                      : Container(),
                                  ListTile(
                                    onTap: () {
                                      InputDialog.show(context, '妹子数量',
                                              limitingText: 10)
                                          .then((value) {
                                        setState(() {
                                          _girlnumber = value;
                                        });
                                      });
                                    },
                                    contentPadding:
                                        EdgeInsets.only(left: 0, right: 0),
                                    title: Text('妹子数量',
                                        style: TextStyle(
                                            color: StyleTheme.cTitleColor,
                                            fontSize: 14.sp)),
                                    trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Text(
                                              _girlnumber == null
                                                  ? '3～7人'
                                                  : _girlnumber.toString(),
                                              style: TextStyle(
                                                  fontSize: 14.sp,
                                                  color: _girlnumber == null
                                                      ? StyleTheme.cBioColor
                                                      : StyleTheme
                                                          .cTitleColor)),
                                        ]),
                                  ),
                                  BottomLine(),
                                  ListTile(
                                    onTap: () {
                                      InputDialog.show(context, '妹子年龄',
                                              limitingText: 10)
                                          .then((value) {
                                        setState(() {
                                          _girlage = value;
                                        });
                                      });
                                    },
                                    contentPadding:
                                        EdgeInsets.only(left: 0, right: 0),
                                    title: Text('妹子年龄',
                                        style: TextStyle(
                                            color: StyleTheme.cTitleColor,
                                            fontSize: 14.sp)),
                                    trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Text(
                                              _girlage == null
                                                  ? '20-24岁'
                                                  : _girlage.toString(),
                                              style: TextStyle(
                                                  fontSize: 14.sp,
                                                  color: _girlage == null
                                                      ? StyleTheme.cBioColor
                                                      : StyleTheme
                                                          .cTitleColor)),
                                        ]),
                                  ),
                                  BottomLine(),
                                  ListTile(
                                    contentPadding:
                                        EdgeInsets.only(left: 0, right: 0),
                                    title: Text('妹子颜值',
                                        style: TextStyle(
                                            color: StyleTheme.cTitleColor,
                                            fontSize: 14.sp)),
                                    trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          StarRating(
                                            rating: _quality,
                                            onRatingChanged: (value) {
                                              setState(() {
                                                _quality = value;
                                              });
                                            },
                                          ),
                                        ]),
                                  ),
                                  BottomLine(),
                                  ListTile(
                                    contentPadding:
                                        EdgeInsets.only(left: 0, right: 0),
                                    title: Text('服务质量',
                                        style: TextStyle(
                                            color: StyleTheme.cTitleColor,
                                            fontSize: 14.sp)),
                                    trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          StarRating(
                                            rating: _service,
                                            onRatingChanged: (value) {
                                              setState(() {
                                                _service = value;
                                              });
                                            },
                                          ),
                                        ]),
                                  ),
                                  BottomLine(),
                                  ListTile(
                                    onTap: () {
                                      InputDialog.show(context, '服务项目',
                                              limitingText: 18)
                                          .then((value) {
                                        setState(() {
                                          _serviceitems = value;
                                        });
                                      });
                                    },
                                    contentPadding:
                                        EdgeInsets.only(left: 0, right: 0),
                                    title: Text('服务项目',
                                        style: TextStyle(
                                            color: StyleTheme.cTitleColor,
                                            fontSize: 14.sp)),
                                    trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Text(
                                              _serviceitems == null
                                                  ? '舌吻、毒龙、胸推'
                                                  : _serviceitems.toString(),
                                              style: TextStyle(
                                                  fontSize: 14.sp,
                                                  color: _serviceitems == null
                                                      ? StyleTheme.cBioColor
                                                      : StyleTheme
                                                          .cTitleColor)),
                                        ]),
                                  ),
                                  BottomLine(),
                                  GestureDetector(
                                    onTap: () {
                                      saveParam();
                                    },
                                    child: Container(
                                      margin: EdgeInsets.symmetric(
                                          vertical: 30.w, horizontal: 15.w),
                                      height: 50.w,
                                      child: LocalPNG(
                                        height: 50.w,
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
      ),
      PageViewMixin(
        child: FinishPublish(
          publishdata: formData,
          controller: controller,
          editInfoData: editInfoData,
        ),
      )
    ]);
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
