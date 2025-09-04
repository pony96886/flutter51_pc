import 'package:bot_toast/bot_toast.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:chaguaner2023/components/citypickers/CommonCity_pickers.dart';
import 'package:chaguaner2023/components/datetime/datetimepicker.dart';
import 'package:chaguaner2023/components/datetime/src/date_format.dart';
import 'package:chaguaner2023/components/datetime/src/i18n_model.dart';
import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/loading.dart';
import 'package:chaguaner2023/components/pagetitlebar.dart';
import 'package:chaguaner2023/input/InputDailog.dart';
import 'package:chaguaner2023/store/homeConfig.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:chaguaner2023/view/yajian/slectYouhuiquan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class TeaTastingIntention extends StatefulWidget {
  // final Datum intentionData;
  final String? oderId;
  TeaTastingIntention(
      {Key? key,
      // , this.intentionData
      this.oderId})
      : super(key: key);

  @override
  _TeaTastingIntentionState createState() => _TeaTastingIntentionState();
}

class _TeaTastingIntentionState extends State<TeaTastingIntention> {
  BackButtonBehavior backButtonBehavior = BackButtonBehavior.none;
  TextEditingController _descriptionController = TextEditingController();
  int? _editId;
  Map? editData;
  int dialogIndex = 0;
  int selectValue = 0;
  int? selectId;
  dynamic myMoney;
  bool loading = true;
  bool isEdit = false;
  String _reservationfee = '200';
  SwiperController swiperController = new SwiperController();
  String? _city;
  String? _latestTime;
  String? _cityCode;
  String? _maxConsumerPrice;
  List selectPatterns = [];
  List patternsList = [
    {'title': '上门', 'id': 1},
    {'title': '到店', 'id': 2},
  ];
  List selectServes = [];
  List serveList = [
    {'title': '1P', 'id': 1},
    {'title': '2P', 'id': 2},
    {'title': '包夜', 'id': 3},
  ];
  List<String> _serviceItems = [];
  List tagItems = [];
  String submyiStr = "提交意向单";

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

  @override
  void initState() {
    super.initState();
    if (widget.oderId != null) {
      getEdit(int.parse(widget.oderId!));
    } else {
      setState(() {
        loading = false;
      });
    }
    getTags().then((tags) => {
          if (tags!['data'] != null)
            {
              setState(() {
                tagItems = tags['data'];
              })
            }
        });
  }

  editInit() {
    // print('------------------------------------------_${editData != null}');
    setState(() {
      Map intention = editData!;
      _editId = intention['id'];
      _city = intention['cityName'];
      _cityCode = intention['cityCode'].toString();
      _latestTime = intention['latestTime'].toString();
      _maxConsumerPrice = intention['highestPrice'].toString();
      selectPatterns = intention['costWay'].split(',');
      selectServes = intention['serviceType'].split(',');
      _serviceItems = intention['serviceTag'] != null
          ? intention['serviceTag'].split(',')
          : [];
      _descriptionController.text = intention['comment'];
      isEdit = true;
      loading = false;
    });
  }

  _onSubmit() async {
    if (_cityCode == null) {
      showText('请选择意向城市');
      return;
    }
    if (_latestTime == null) {
      showText('请选择最晚接受安排时间');
      return;
    }
    if (selectPatterns.isEmpty) {
      showText('请选择消费方式');
      return;
    }
    if (selectServes.isEmpty) {
      showText('请选择服务类型');
      return;
    }
    if (_maxConsumerPrice == null) {
      showText('请输入最高消费价格');
      return;
    }
    if (_serviceItems.isEmpty) {
      showText('请选择服务项目');
      return;
    }
    if (isEdit) {
      _onSendEditData();
    } else {
      showPublish(2);
      // PopupBox.showText(
      //   backButtonBehavior,
      //   title: '温馨提示',
      //   text: '是否支付$_reservationfee元宝提交意向单，超时或未成功预约，元宝将退回账户',
      //   confirm: _onSendData,
      //   confirmtext: '提交',
      //   showCancel: true,
      //   tapMaskClose: true,
      // );
    }
  }

  _onSendEditData() async {
    BotToast.showLoading();
    var result = await editRequire(
      id: _editId,
      cityName: _city,
      cityCode: _cityCode,
      latestTime: _latestTime,
      costWay: selectPatterns.join(','),
      serviceType: selectServes.join(','),
      highestPrice: _maxConsumerPrice,
      serviceTag: _serviceItems.join(','),
      comment: _descriptionController.text,
    );
    BotToast.closeAllLoading();
    if ([1, '1'].contains(result!['status'])) {
      BotToast.showText(text: '提交成功', align: Alignment(0, 0));
      Navigator.of(context).pop();
    } else {
      String neterror = '网络错误';
      showText(result['msg'] ?? neterror);
    }
  }

  _onSendData() async {
    BotToast.showLoading();
    var result = await postRequire(
        cityName: _city,
        cityCode: _cityCode,
        latestTime: _latestTime,
        costWay: selectPatterns.join(','),
        serviceType: selectServes.join(','),
        highestPrice: _maxConsumerPrice,
        serviceTag: _serviceItems.join(','),
        comment: _descriptionController.text,
        couponId: selectId);
    BotToast.closeAllLoading();
    if (result!['status'] != 0) {
      BotToast.showText(text: '提交成功', align: Alignment(0, 0));
      Navigator.of(context).pop();
      context.pop();
    } else {
      showText(result['msg'] ?? '网络错误');
    }
  }

  getEdit(int id) async {
    var resData = await getEditRequire(id);
    if (resData!['status'] != 0) {
      editData = resData['data'];
      editInit();
    } else {
      showText(resData['msg'] ?? '网络错误');
    }
  }

  @override
  Widget build(BuildContext context) {
    myMoney = Provider.of<HomeConfig>(context).member.money;
    return HeaderContainer(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
            child: PageTitleBar(
              title: '品茶意向',
            ),
            preferredSize: Size(double.infinity, 44.w)),
        body: loading
            ? Loading()
            : Stack(
                children: <Widget>[
                  SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                        vertical: CommonUtils.getWidth(120)),
                    child: Column(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: CommonUtils.getWidth(30)),
                          child: Column(
                            children: <Widget>[
                              ListTile(
                                onTap: () {
                                  _showCityPickers();
                                },
                                contentPadding:
                                    EdgeInsets.only(left: 0, right: 0),
                                title: Text('所在地',
                                    style: TextStyle(
                                        color: StyleTheme.cTitleColor,
                                        fontSize: CommonUtils.getFontSize(28))),
                                trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Text(
                                          _city == null
                                              ? '选择所在城市'
                                              : _city.toString(),
                                          style: TextStyle(
                                              fontSize:
                                                  CommonUtils.getFontSize(28),
                                              color: _city == null
                                                  ? StyleTheme.cBioColor
                                                  : StyleTheme.cTitleColor)),
                                      Icon(Icons.keyboard_arrow_right,
                                          color: StyleTheme.cBioColor),
                                    ]),
                              ),
                              BottomLine(),
                              ListTile(
                                onTap: () {
                                  DatePicker.showDatePicker(context,
                                      showTitleActions: true,
                                      minTime: DateTime.now(),
                                      maxTime: DateTime.now()
                                          .add(Duration(days: 30)),
                                      onConfirm: (date) {
                                    setState(() {
                                      _latestTime = formatDate(
                                              date,
                                              [
                                                yyyy,
                                                "-",
                                                mm,
                                                "-",
                                                dd,
                                                " ",
                                                HH,
                                                ":",
                                                nn,
                                                ":",
                                                "00"
                                              ],
                                              LocaleType.zhCN)
                                          .toString();
                                    });
                                  }, currentTime: DateTime.now());
                                },
                                contentPadding:
                                    EdgeInsets.only(left: 0, right: 0),
                                title: Text('最晚接受安排时间',
                                    style: TextStyle(
                                        color: StyleTheme.cTitleColor,
                                        fontSize: CommonUtils.getFontSize(28))),
                                trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Text(
                                          _latestTime == null
                                              ? '选择时间'
                                              : _latestTime.toString(),
                                          style: TextStyle(
                                              fontSize:
                                                  CommonUtils.getFontSize(28),
                                              color: _latestTime == null
                                                  ? StyleTheme.cBioColor
                                                  : StyleTheme.cTitleColor)),
                                      Icon(Icons.keyboard_arrow_right,
                                          color: StyleTheme.cBioColor),
                                    ]),
                              ),
                              BottomLine(),
                              Container(
                                margin: EdgeInsets.only(
                                    top: CommonUtils.getWidth(40),
                                    bottom: CommonUtils.getWidth(40)),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text('消费方式',
                                        style: TextStyle(
                                            color: StyleTheme.cTitleColor,
                                            fontSize:
                                                CommonUtils.getFontSize(28))),
                                    Row(
                                      children: <Widget>[
                                        for (var item in patternsList)
                                          checkbox(item['title'])
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              BottomLine(),
                              Container(
                                margin: EdgeInsets.only(
                                    top: CommonUtils.getWidth(40),
                                    bottom: CommonUtils.getWidth(40)),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text('服务类型',
                                        style: TextStyle(
                                            color: StyleTheme.cTitleColor,
                                            fontSize:
                                                CommonUtils.getFontSize(28))),
                                    Row(
                                      children: <Widget>[
                                        for (var item2 in serveList)
                                          checkboxServes(item2['title'])
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              BottomLine(),
                              ListTile(
                                onTap: () {
                                  InputDialog.show(context, '输入最高消费价格',
                                          limitingText: 10)
                                      .then((value) {
                                    double reservation =
                                        double.parse(value!) / 10;
                                    // print(
                                    //     '_____________________$reservation');
                                    double? showReservation;
                                    if (reservation <= 200) {
                                      showReservation = 200;
                                    }
                                    if (reservation > 200 &&
                                        reservation < 500) {
                                      showReservation = double.parse(
                                          ((reservation / 100).round() * 100)
                                              .toString());
                                    }
                                    if (reservation >= 500) {
                                      showReservation = 500;
                                    }
                                    setState(() {
                                      _maxConsumerPrice = value;
                                      _reservationfee =
                                          showReservation!.toStringAsFixed(0);
                                    });
                                  });
                                },
                                contentPadding:
                                    EdgeInsets.only(left: 0, right: 0),
                                title: Text('最高消费价格（元）',
                                    style: TextStyle(
                                        color: StyleTheme.cTitleColor,
                                        fontSize: CommonUtils.getFontSize(28))),
                                trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Text(
                                          _maxConsumerPrice == null
                                              ? '输入最高价格'
                                              : _maxConsumerPrice.toString(),
                                          style: TextStyle(
                                              fontSize:
                                                  CommonUtils.getFontSize(28),
                                              color: _maxConsumerPrice == null
                                                  ? StyleTheme.cBioColor
                                                  : StyleTheme.cTitleColor)),
                                    ]),
                              ),
                              BottomLine(),
                            ],
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.symmetric(
                              horizontal: CommonUtils.getWidth(30)),
                          width: double.infinity,
                          color: StyleTheme.bottomappbarColor,
                          height: CommonUtils.getWidth(50),
                          child: Text('*实际消费金额请自行和茶老板商议',
                              style: TextStyle(
                                  color: StyleTheme.cDangerColor,
                                  fontSize: CommonUtils.getFontSize(22))),
                        ),
                        Container(
                          padding: EdgeInsets.only(
                            left: CommonUtils.getWidth(30),
                            right: CommonUtils.getWidth(30),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.only(
                                    top: CommonUtils.getWidth(60),
                                    bottom: CommonUtils.getWidth(40),
                                  ),
                                  child: Text("服务项目",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          color: StyleTheme.cTitleColor,
                                          fontSize: CommonUtils.getFontSize(36),
                                          fontWeight: FontWeight.bold))),
                              Wrap(
                                spacing: CommonUtils.getWidth(20),
                                runSpacing: CommonUtils.getWidth(20),
                                children: <Widget>[
                                  for (var item in tagItems)
                                    tagItemWidget(item['name'])
                                ],
                              ),
                              Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.only(
                                    top: CommonUtils.getWidth(60),
                                    bottom: CommonUtils.getWidth(40),
                                  ),
                                  child: Text("备注（选填）",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          color: StyleTheme.cTitleColor,
                                          fontSize: CommonUtils.getFontSize(36),
                                          fontWeight: FontWeight.bold))),
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
                                          fontSize: CommonUtils.getFontSize(28),
                                          color: StyleTheme.cTitleColor),
                                      decoration: InputDecoration.collapsed(
                                          hintStyle: TextStyle(
                                              fontSize:
                                                  CommonUtils.getFontSize(28),
                                              color: StyleTheme.cBioColor),
                                          hintText:
                                              "简单说明一下大概地址，以及对妹儿类型的要求，不超过50字"),
                                    ),
                                  )),
                              SizedBox(
                                height: CommonUtils.getWidth(40),
                              ),
                              // 余额显示
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: <Widget>[
                                  Text('账户余额',
                                      style: TextStyle(
                                          color: StyleTheme.cDangerColor,
                                          fontSize:
                                              CommonUtils.getFontSize(28))),
                                  Text(
                                      myMoney == null
                                          ? '0元宝'
                                          : myMoney.toString() + '元宝',
                                      style: TextStyle(
                                          fontSize:
                                              CommonUtils.getFontSize(28),
                                          color: StyleTheme.cDangerColor)),
                                ],
                              ),
                              GestureDetector(
                                onTap: _onSubmit,
                                child: Container(
                                  margin: EdgeInsets.symmetric(
                                      vertical: CommonUtils.getWidth(40),
                                      horizontal: CommonUtils.getWidth(31)),
                                  height: CommonUtils.getWidth(100),
                                  child: Stack(
                                    children: [
                                      LocalPNG(
                                        height: CommonUtils.getWidth(100),
                                        url: "assets/images/pment/submit.png",
                                      ),
                                      Center(
                                        child: Text(
                                            isEdit
                                                ? submyiStr
                                                : "支付$_reservationfee元宝，提交意向单",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize:
                                                    CommonUtils.getFontSize(
                                                        30))),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            vertical: CommonUtils.getWidth(20),
                            horizontal: CommonUtils.getWidth(30)),
                        color: Color(0xFFFDF0E4),
                        alignment: Alignment.centerLeft,
                        child: Text(
                            "1、提交意向单后的24小时内，所有茶老板都可接单\n2、超时或未成功预约，元宝将退回账户",
                            style: TextStyle(
                                color: StyleTheme.cDangerColor,
                                fontSize: CommonUtils.getFontSize(24))),
                      )),
                ],
              ),
      ),
    );
  }

  Widget checkbox(String title) {
    String seleStr = 'select';
    String luesS = 'unselect';
    String selectStr = selectPatterns.indexOf(title) > -1 ? seleStr : luesS;
    return GestureDetector(
      onTap: () {
        if (selectPatterns.indexOf(title) > -1) {
          setState(() {
            selectPatterns.remove(title);
          });
        } else {
          setState(() {
            selectPatterns.add(title);
          });
        }
        // print(selectPatterns.join(','));
      },
      behavior: HitTestBehavior.translucent,
      child: Container(
        margin: EdgeInsets.only(left: CommonUtils.getWidth(60)),
        child: Row(
          children: <Widget>[
            LocalPNG(
              url: 'assets/images/card/$selectStr.png',
              width: CommonUtils.getWidth(30),
              height: CommonUtils.getWidth(30),
              fit: BoxFit.cover,
            ),
            SizedBox(
              width: CommonUtils.getWidth(11),
            ),
            Text(title)
          ],
        ),
      ),
    );
  }

  Widget checkboxServes(String title) {
    String seleStr = 'select';
    String luesS = 'unselect';
    String sercStr = selectServes.indexOf(title) > -1 ? seleStr : luesS;
    return GestureDetector(
      onTap: () {
        if (selectServes.indexOf(title) > -1) {
          setState(() {
            selectServes.remove(title);
          });
        } else {
          setState(() {
            selectServes.add(title);
          });
        }
        // print(selectServes.join(','));
      },
      child: Container(
        margin: EdgeInsets.only(left: CommonUtils.getWidth(60)),
        child: Row(
          children: <Widget>[
            Container(
              width: CommonUtils.getWidth(30),
              height: CommonUtils.getWidth(30),
              margin: EdgeInsets.only(right: CommonUtils.getWidth(11)),
              child: LocalPNG(
                width: CommonUtils.getWidth(30),
                height: CommonUtils.getWidth(30),
                url: 'assets/images/card/$sercStr.png',
                fit: BoxFit.cover,
              ),
            ),
            Text(title)
          ],
        ),
      ),
    );
  }

  Widget tagItemWidget(String title) {
    return GestureDetector(
      onTap: () {
        if (_serviceItems.indexOf(title) > -1) {
          setState(() {
            _serviceItems.remove(title);
          });
        } else {
          setState(() {
            _serviceItems.add(title);
          });
        }
      },
      child: Container(
          padding: EdgeInsets.symmetric(horizontal: CommonUtils.getWidth(24)),
          height: 25.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: _serviceItems.indexOf(title) > -1
                ? Color(0xFFFDF0E4)
                : StyleTheme.bottomappbarColor,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                title,
                style: TextStyle(
                    fontSize: CommonUtils.getFontSize(24),
                    color: _serviceItems.indexOf(title) > -1
                        ? StyleTheme.cDangerColor
                        : StyleTheme.cTitleColor),
              ),
            ],
          )),
    );
  }

  Future showPublish(int zfType) {
    String qrzfStr = "全额支付";
    String enoStr = '余额不足,去充值';
    String alisStr = '支付预约金';
    String resertStre = int.parse(_reservationfee).toString();
    return showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setBottomSheetState) {
            return Container(
              color: Colors.transparent,
              child: Container(
                height:
                    CommonUtils.getWidth(900) + ScreenUtil().bottomBarHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Container(
                        padding: EdgeInsets.only(
                            top: CommonUtils.getWidth(40),
                            left: CommonUtils.getWidth(30),
                            right: CommonUtils.getWidth(30)),
                        child: Swiper(
                          controller: swiperController,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (BuildContext context, int index) {
                            return index == 0
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        child: Center(
                                            child: Text(
                                          zfType == 1 ? qrzfStr : alisStr,
                                          style: TextStyle(
                                              fontSize:
                                                  CommonUtils.getFontSize(36),
                                              color: StyleTheme.cTitleColor,
                                              fontWeight: FontWeight.w500),
                                        )),
                                      ),
                                      Container(
                                        child: Flex(
                                          direction: Axis.horizontal,
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                                flex: 1, child: Container()),
                                            Expanded(
                                                flex: 2,
                                                child: Container(
                                                  margin: EdgeInsets.only(
                                                      top: 40.w,
                                                      bottom:
                                                          CommonUtils.getWidth(
                                                              zfType == 1
                                                                  ? 0
                                                                  : 40)),
                                                  child: Center(
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Container(
                                                            margin:
                                                                EdgeInsets.only(
                                                                    right:
                                                                        11.w),
                                                            width: 38.w,
                                                            height: 57.w,
                                                            child: LocalPNG(
                                                                width: 38.w,
                                                                height: 27.w,
                                                                url:
                                                                    'assets/images/detail/vip-yuanbao.png',
                                                                fit: BoxFit
                                                                    .contain)),
                                                        Text.rich(TextSpan(
                                                            text: (int.parse(
                                                                        _reservationfee) -
                                                                    selectValue)
                                                                .toString(),
                                                            style: TextStyle(
                                                                color: StyleTheme
                                                                    .cTitleColor,
                                                                fontSize:
                                                                    36.sp),
                                                            children: [
                                                              TextSpan(
                                                                text: '元宝',
                                                                style: TextStyle(
                                                                    color: StyleTheme
                                                                        .cTitleColor,
                                                                    fontSize:
                                                                        18.sp),
                                                              )
                                                            ])),
                                                      ],
                                                    ),
                                                  ),
                                                )),
                                            Expanded(
                                                flex: 1,
                                                child: zfType == 2 &&
                                                        selectValue != 0
                                                    ? Container(
                                                        margin: EdgeInsets.only(
                                                            top: 15.sp),
                                                        child: Text(
                                                          '$resertStre元宝',
                                                          style: TextStyle(
                                                            color: StyleTheme
                                                                .cBioColor,
                                                            fontSize: 18.sp,
                                                            decoration:
                                                                TextDecoration
                                                                    .lineThrough,
                                                            decorationColor:
                                                                StyleTheme
                                                                    .cBioColor,
                                                          ),
                                                        ),
                                                      )
                                                    : Container()),
                                          ],
                                        ),
                                      ),
                                      zfType == 1
                                          ? Container(
                                              margin: EdgeInsets.only(
                                                top: CommonUtils.getWidth(29),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  '全额支付，线下无需再给钱！',
                                                  style: TextStyle(
                                                    color: StyleTheme.cBioColor,
                                                    fontSize:
                                                        CommonUtils.getFontSize(
                                                            24),
                                                  ),
                                                ),
                                              ),
                                            )
                                          : Container(),
                                      zfType == 1
                                          ? Container(
                                              margin: EdgeInsets.only(
                                                  top: CommonUtils.getWidth(30),
                                                  bottom:
                                                      CommonUtils.getWidth(44)),
                                              child: Text(
                                                '选择消费',
                                                style: TextStyle(
                                                    color:
                                                        StyleTheme.cTitleColor,
                                                    fontSize:
                                                        CommonUtils.getFontSize(
                                                            28)),
                                              ),
                                            )
                                          : Container(),
                                      BottomLine(type: 1),
                                      rowText(
                                        '优惠券',
                                        selectValue == 0
                                            ? '选择优惠券'
                                            : selectValue.toString() + '元宝优惠券',
                                        setBottomSheetState,
                                        selectValue == 0
                                            ? StyleTheme.cBioColor
                                            : StyleTheme.cDangerColor,
                                      ),
                                      BottomLine(type: 1),
                                      rowText(
                                          '预约妹子', '意向单预约', setBottomSheetState),
                                      BottomLine(type: 1),
                                      rowText(
                                          '发布用户', '意向单预约', setBottomSheetState),
                                      BottomLine(type: 1),
                                      Expanded(
                                          child: Center(
                                        child: GestureDetector(
                                          onTap: () {
                                            if (myMoney <
                                                (int.parse(_reservationfee) -
                                                    selectValue)) {
                                              AppGlobal.appRouter?.push(
                                                  CommonUtils.getRealHash(
                                                      'ingotWallet'));
                                            } else {
                                              _onSendData();
                                            }
                                          },
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                margin: EdgeInsets.only(
                                                    bottom:
                                                        CommonUtils.getWidth(
                                                            20)),
                                                width:
                                                    CommonUtils.getWidth(550),
                                                height:
                                                    CommonUtils.getWidth(100),
                                                child: Stack(
                                                  children: [
                                                    LocalPNG(
                                                        width: 375.w,
                                                        height: 50.w,
                                                        url:
                                                            'assets/images/mymony/money-img.png',
                                                        fit: BoxFit.fill),
                                                    Center(
                                                        child: Text(
                                                      myMoney <
                                                              (int.parse(
                                                                      _reservationfee) -
                                                                  selectValue)
                                                          ? enoStr
                                                          : '立即支付',
                                                      style: TextStyle(
                                                          fontSize: 15.sp,
                                                          color: Colors.white),
                                                    )),
                                                  ],
                                                ),
                                              ),
                                              Text(
                                                '超时或未成功预约，元宝将退回账户',
                                                style: TextStyle(
                                                    color:
                                                        StyleTheme.cDangerColor,
                                                    fontSize:
                                                        CommonUtils.getFontSize(
                                                            24)),
                                              )
                                            ],
                                          ),
                                        ),
                                      ))
                                    ],
                                  )
                                : youHuiQuan(setBottomSheetState);
                          },
                          itemCount: 2,
                          layout: SwiperLayout.DEFAULT,
                          itemWidth: double.infinity,
                          itemHeight: double.infinity,
                        )),
                    dialogIndex == 1
                        ? Container()
                        : Positioned(
                            top: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: LocalPNG(
                                url: "assets/images/nav/closemenu.png",
                                width: CommonUtils.getWidth(60),
                                height: CommonUtils.getWidth(60),
                              ),
                            ),
                          )
                  ],
                ),
              ),
            );
          });
        }).then((value) => {
          if (value == null) {dialogIndex = 0, selectId = null, selectValue = 0}
        });
  }

  Widget youHuiQuan(Function setBottomSheetState) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                swiperController.move(0);
                setBottomSheetState(() {
                  dialogIndex = 0;
                  selectValue = 0;
                  selectId = null;
                });
              },
              child: Text(
                '取消',
                style: TextStyle(
                  fontSize: CommonUtils.getFontSize(30),
                  color: StyleTheme.cTitleColor,
                ),
              ),
            ),
            Expanded(
                child: Center(
              child: Text(
                '选择优惠券',
                style: TextStyle(
                    fontSize: CommonUtils.getFontSize(36),
                    color: StyleTheme.cTitleColor,
                    fontWeight: FontWeight.w500),
              ),
            )),
            GestureDetector(
              onTap: () {
                swiperController.move(0);
                setBottomSheetState(() {
                  dialogIndex = 0;
                });
              },
              child: Text('确定',
                  style: TextStyle(
                    fontSize: CommonUtils.getFontSize(30),
                    color: StyleTheme.cTitleColor,
                  )),
            )
          ],
        )),
        SlectYouHuiQuan(
            isSelect: selectId,
            setCallBack: (id, value) {
              setBottomSheetState(() {
                selectId = id;
                selectValue = value;
              });
            })
      ],
    );
  }

  Widget rowText(String title, String content, Function callBack,
      [Color? color]) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
              fontSize: CommonUtils.getFontSize(28), color: Color(0xFF969693)),
        ),
        color != null
            ? GestureDetector(
                onTap: () {
                  if (int.parse(_reservationfee.toString()) < 200) {
                    CommonUtils.showText('预约金大于200才能使用优惠券哦');
                    return;
                  }
                  swiperController.move(1);
                  callBack(() {
                    dialogIndex = 1;
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      content,
                      style: TextStyle(
                          color: color, fontSize: CommonUtils.getFontSize(28)),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: CommonUtils.getWidth(11)),
                      width: CommonUtils.getWidth(30),
                      height: CommonUtils.getWidth(30),
                      child: LocalPNG(
                          width: CommonUtils.getWidth(30),
                          height: CommonUtils.getWidth(30),
                          url: 'assets/images/detail/right-icon.png',
                          fit: BoxFit.fill),
                    )
                  ],
                ),
              )
            : Text(
                content,
                style: TextStyle(
                    fontSize: CommonUtils.getFontSize(28),
                    color: StyleTheme.cTitleColor),
              )
      ],
    );
  }
}

class BottomLine extends StatelessWidget {
  final int? type;
  const BottomLine({Key? key, this.type}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: type == 1
          ? EdgeInsets.only(
              top: CommonUtils.getWidth(20),
              bottom: CommonUtils.getWidth(20),
            )
          : null,
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
