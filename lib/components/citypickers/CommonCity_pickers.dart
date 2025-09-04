import 'dart:async';
import 'dart:convert';
import 'package:bot_toast/bot_toast.dart';
import 'package:chaguaner2023/components/citypickers/modal/InternationalCity.dart';
import 'package:chaguaner2023/store/global.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:provider/provider.dart';

typedef void AlphaChanged(String alpha);
typedef void OnTouchStart();
typedef void OnTouchMove();
typedef void OnTouchEnd();

class CommonCityPickers extends StatefulWidget {
  final bool showAll;
  const CommonCityPickers({Key? key, this.showAll = false}) : super(key: key);

  @override
  State<StatefulWidget> createState() => CommonCityPickersState();
}

class CommonCityPickersState extends State<CommonCityPickers>
    with SingleTickerProviderStateMixin {
  TabController? tabController;
  int tabsIndex = 0;
  List<Abroad> abroadList = [];
  List<Internal> internalList = [];

  @override
  void initState() {
    super.initState();

    tabController = new TabController(vsync: this, length: 2, initialIndex: 0);
    tabController!.addListener(() {
      setState(() {
        tabsIndex = tabController!.index;
      });
    });
    onSplitCityData();
  }

  // 拆分国内和国际城市并进行数据处理
  onSplitCityData() {
    var allCity = Provider.of<GlobalState>(context, listen: false).cityList;
    if (allCity['data'] != null) {
      allCity['data']['abroad'].forEach((element) {
        abroadList.add(Abroad.fromJson(element));
      });
      allCity['data']['internal'].forEach((element) {
        internalList.add(Internal.fromJson(element));
      });
      setState(() {});
    } else {
      BotToast.showText(text: "获取城市数据失败，请重启APP进行获取", align: Alignment(0, 0));
      Navigator.of(context).pop();
    }
  }

  List tabs = [
    {'title': '国内城市'},
    {'title': '海外城市'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: PreferredSize(
          child: TabBar(
              controller: tabController,
              indicatorPadding: EdgeInsets.all(0),
              labelPadding: EdgeInsets.all(0),
              indicatorColor: Colors.transparent,
              tabs: tabs
                  .asMap()
                  .keys
                  .map((key) => CustomTab(
                      tabIndex: tabsIndex,
                      keyIndex: key,
                      title: tabs[key]['title']))
                  .toList()),
          preferredSize: Size.fromHeight(ScreenUtil().statusBarHeight),
        ),
        iconTheme: IconThemeData(
          color: StyleTheme.cTitleColor,
        ),
        actions: <Widget>[
          IconButton(
            padding: EdgeInsets.only(right: 20.0),
            icon: Icon(Icons.arrow_left),
            onPressed: () {},
            iconSize: 30.0,
            color: Colors.transparent,
          )
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          ChinaCity(
            cityList: internalList,
            showAll: widget.showAll,
          ),
          AbroadCity(
            cityList: abroadList,
            showAll: widget.showAll,
          ),
        ],
      ),
    );
  }
}

class CustomTab extends StatelessWidget {
  final int? tabIndex;
  final int? keyIndex;
  final String? title;

  const CustomTab({Key? key, this.tabIndex, this.keyIndex, this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Positioned(
              bottom: 0,
              child: LocalPNG(
                url: 'assets/images/tabsitem.png',
                alignment: Alignment.center,
                fit: BoxFit.fitWidth,
                width: 70.w,
                height: tabIndex == keyIndex ? 9.w : 0,
              )),
          Text(
            '$title',
            style: TextStyle(
              color: StyleTheme.cTitleColor,
              fontSize: tabIndex == keyIndex ? 18.sp : 14.sp,
            ),
          )
        ],
      ),
    );
  }
}

class ChinaCity extends StatefulWidget {
  final List<Internal>? cityList;
  final bool showAll;

  const ChinaCity({Key? key, this.cityList, this.showAll = true})
      : super(key: key);

  @override
  _ChinaCityState createState() => _ChinaCityState();
}

class _ChinaCityState extends State<ChinaCity> {
  List<String> letters = [];
  List<DatumCity> data = [];
  Timer? _changeTimer;
  bool _isTouchTagBar = false;
  double letterItemSize = 15.sp;
  String? _tagName;
  ScrollController _scrollController = ScrollController();
  Map<String, dynamic> hotCitiesData = {
    "data": [
      {"code": 110100, "city": "北京"},
      {"code": 310100, "city": "上海"},
      {"code": 440100, "city": "广州"},
      {"code": 440300, "city": "深圳"},
      {"code": 510100, "city": "成都"},
      {"code": 500100, "city": "重庆"}
    ]
  };
  TabController? tabController;
  int tabsIndex = 0;

  @override
  void initState() {
    super.initState();
    getLettersDataList();
  }

  Future<List<dynamic>> onOrderData({List<Internal>? slipcityList}) async {
    List<Internal>? cityList = slipcityList;
    var allCityCodeList = [];

    // 是否显示[全部]
    if (widget.showAll) {
      allCityCodeList.add({"code": null, "city": "全部", "letter": "*"});
    }

    // 获取城市首字母
    for (var i = 0; i < cityList!.length; i++) {
      if (["", false, null].contains(cityList[i].areaname)) {
      } else {
        allCityCodeList.add({
          "code": cityList[i].id,
          "city": cityList[i].areaname,
          "letter": PinyinHelper.getFirstWordPinyin(cityList[i].areaname!)
              .substring(0, 1)
        });
      }
    }
    var baseAllCityCode = allCityCodeList.toList();
    var allCityList = [];
    var mapBaseCityList = {};
    // 排序相同首字母城市放入同一数组 处理成多维数组
    for (var j = 0; j < baseAllCityCode.length; j++) {
      var sameLetter = baseAllCityCode[j];
      if (!mapBaseCityList.containsKey(sameLetter['letter'])) {
        allCityList.add({
          "listData": [sameLetter],
          "letter": sameLetter['letter']
        });
        mapBaseCityList[sameLetter['letter']] = sameLetter;
      } else {
        for (var k = 0; k < allCityList.length; k++) {
          var sameLetterData = allCityList[k];
          if (sameLetterData['letter'] == sameLetter['letter']) {
            sameLetterData['listData'].add(sameLetter);
            break;
          }
        }
      }
    }
    // 首字母排序
    allCityList.sort((a, b) {
      return a['letter'].toLowerCase().compareTo(b['letter'].toLowerCase());
    });
    return allCityList;
  }

  getLettersDataList() async {
    if (widget.cityList!.length == 0) return;
    var result = await onOrderData(slipcityList: widget.cityList);
    var resultString = {"data": result};
    var resultEntity = new CityListData.fromJson(resultString);

    data = resultEntity.data ?? [];
    for (int i = 0; i < data.length; i++) {
      letters.add(data[i].letter!.toUpperCase());
    }
    setState(() {});
  }

  _onTagChange(String alpha) {
    if (_changeTimer?.isActive ?? false) {
      _changeTimer!.cancel();
    }
    _changeTimer = new Timer(Duration(milliseconds: 100), () {
      int index = letters.indexOf(alpha);
      var height = index * 45.0;
      for (int i = 0; i < index; i++) {
        height += data[i].listData!.length * 46.0;
      }
      _scrollController.jumpTo(height);
    });
  }

  Widget renderHotCity() {
    List<Widget> tiles = [];
    Widget content;
    var formaterCity = new HotcityCustom.fromJson(hotCitiesData);
    for (int i = 0; i < formaterCity.data!.length; i++) {
      tiles.add(
        GestureDetector(
          onTap: () {
            Navigator.of(context).pop(formaterCity.data![i]);
          },
          child: Container(
            width: 100.w,
            padding: EdgeInsets.all(5.w),
            alignment: Alignment.center,
            color: Colors.white,
            child: Text(formaterCity.data![i].city!,
                style: TextStyle(color: Color(0xFF1E1E1E), fontSize: 14.sp)),
          ),
        ),
      );
    }

    content = Wrap(
      alignment: WrapAlignment.spaceBetween,
      spacing: 15.w,
      runSpacing: 7.w,
      children: tiles,
    );
    return content;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(15.w),
          decoration: BoxDecoration(color: StyleTheme.bottomappbarColor),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text("热门城市", style: TextStyle(color: Color(0xFF969696))),
              SizedBox(height: 9.5.w),
              Container(
                width: double.infinity,
                child: renderHotCity(),
              )
            ],
          ),
        ),
        Expanded(
          child: Stack(
            children: <Widget>[
              data.length == 0
                  ? Text("")
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: data.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            ElegantCityIndexName(
                                data[index].letter!.toUpperCase()),
                            ListView.builder(
                                itemBuilder:
                                    (BuildContext context, int index2) {
                                  dynamic citys =
                                      data[index].listData![index2].city;
                                  return Container(
                                    height: 46,
                                    color: Colors.white,
                                    child: GestureDetector(
                                      child: Padding(
                                        padding: EdgeInsets.all(10),
                                        child: Text("$citys",
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Color(0xff434343))),
                                      ),
                                      onTap: () {
                                        Navigator.of(context)
                                            .pop(data[index].listData![index2]);
                                      },
                                    ),
                                  );
                                },
                                itemCount: data[index].listData == null
                                    ? 0
                                    : data[index].listData!.length,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics())
                          ],
                        );
                      }),
              _isTouchTagBar
                  ? Center(
                      child: Card(
                        color: Colors.black38,
                        child: Container(
                          alignment: Alignment.center,
                          width: 80.0,
                          height: 80.0,
                          child: Text(
                            _tagName ?? '',
                            style: TextStyle(
                              fontSize: 32.0,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    )
                  : SizedBox(),
              Positioned(
                top: 0,
                right: 5.w,
                bottom: 0,
                child: Alpha(
                    alphas: letters,
                    alphaItemSize: letterItemSize,
                    onTouchStart: () {
                      this.setState(() {
                        _isTouchTagBar = true;
                      });
                    },
                    onTouchEnd: () {
                      this.setState(() {
                        _isTouchTagBar = false;
                      });
                    },
                    onAlphaChange: (String alpha) {
                      this.setState(() {
                        if (!_isTouchTagBar) {
                          _isTouchTagBar = true;
                        }
                        _tagName = alpha;
                      });
                      _onTagChange(alpha);
                    }),
              ),
            ],
          ),
        )
      ],
    );
  }
}

class AbroadCity extends StatefulWidget {
  final List<Abroad>? cityList;
  final bool? showAll;

  const AbroadCity({Key? key, this.cityList, this.showAll = false})
      : super(key: key);

  @override
  _AbroadCityState createState() => _AbroadCityState();
}

class _AbroadCityState extends State<AbroadCity> {
  List<String> letters = [];
  List<DatumCity> data = [];
  Timer? _changeTimer;
  bool _isTouchTagBar = false;
  double letterItemSize = 15.w;
  String? _tagName;
  ScrollController _scrollController = ScrollController();
  Map<String, dynamic> hotCitiesData = {
    "data": [
      {"code": 110100, "city": "北京"},
      {"code": 310100, "city": "上海"},
      {"code": 440100, "city": "广州"},
      {"code": 440300, "city": "深圳"},
      {"code": 510100, "city": "成都"},
      {"code": 500100, "city": "重庆"}
    ]
  };
  TabController? tabController;
  int tabsIndex = 0;

  @override
  void initState() {
    super.initState();
    getLettersDataList();
  }

  Future<List<dynamic>> onOrderData({List<Abroad>? slipcityList}) async {
    List<Abroad> cityList = slipcityList!;
    var allCityCodeList = [];

    // 是否显示[全部]
    if (widget.showAll!) {
      allCityCodeList.add({"code": null, "city": "全部", "letter": "*"});
    }

    // 获取城市首字母
    for (var i = 0; i < cityList.length; i++) {
      if (["", false, null].contains(cityList[i].name)) {
      } else {
        allCityCodeList.add({
          "code": cityList[i].cityCode,
          "city": cityList[i].name,
          "letter":
              PinyinHelper.getFirstWordPinyin(cityList[i].name!).substring(0, 1)
        });
      }
    }
    var baseAllCityCode = allCityCodeList.toList();
    var allCityList = [];
    var mapBaseCityList = {};
    // 排序相同首字母城市放入同一数组 处理成多维数组
    for (var j = 0; j < baseAllCityCode.length; j++) {
      var sameLetter = baseAllCityCode[j];
      if (!mapBaseCityList.containsKey(sameLetter['letter'])) {
        allCityList.add({
          "listData": [sameLetter],
          "letter": sameLetter['letter']
        });
        mapBaseCityList[sameLetter['letter']] = sameLetter;
      } else {
        for (var k = 0; k < allCityList.length; k++) {
          var sameLetterData = allCityList[k];
          if (sameLetterData['letter'] == sameLetter['letter']) {
            sameLetterData['listData'].add(sameLetter);
            break;
          }
        }
      }
    }
    // 首字母排序
    allCityList.sort((a, b) {
      return a['letter'].toLowerCase().compareTo(b['letter'].toLowerCase());
    });
    return allCityList;
  }

  getLettersDataList() async {
    if (widget.cityList!.length == 0) return;
    var result = await onOrderData(slipcityList: widget.cityList);
    var resultString = {"data": result};
    var resultEntity = new CityListData.fromJson(resultString);

    setState(() {
      data = resultEntity.data!;
      for (int i = 0; i < data.length; i++) {
        letters.add(data[i].letter!.toUpperCase());
      }
    });
  }

  _onTagChange(String alpha) {
    if (_changeTimer != null && _changeTimer!.isActive) {
      _changeTimer!.cancel();
    }
    _changeTimer = new Timer(Duration(milliseconds: 100), () {
      int index = letters.indexOf(alpha);
      var height = index * 45.0;
      for (int i = 0; i < index; i++) {
        height += data[i].listData!.length * 46.0;
      }
      _scrollController.jumpTo(height);
    });
  }

  Widget renderHotCity() {
    List<Widget> tiles = [];
    Widget content;
    var formaterCity = new HotcityCustom.fromJson(hotCitiesData);
    for (int i = 0; i < formaterCity.data!.length; i++) {
      tiles.add(
        GestureDetector(
          onTap: () {
            Navigator.of(context).pop(formaterCity.data![i]);
          },
          child: Container(
            width: 100.w,
            padding: EdgeInsets.all(5.w),
            alignment: Alignment.center,
            color: Colors.white,
            child: Text(formaterCity.data![i].city!,
                style: TextStyle(color: Color(0xFF1E1E1E), fontSize: 14.w)),
          ),
        ),
      );
    }

    content = Wrap(
      alignment: WrapAlignment.spaceBetween,
      spacing: 15.w,
      runSpacing: 7.w,
      children: tiles,
    );
    return content;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: Stack(
            children: <Widget>[
              data.length == 0
                  ? Text("")
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: data.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            ElegantCityIndexName(
                                data[index].letter!.toUpperCase()),
                            ListView.builder(
                                itemBuilder:
                                    (BuildContext context, int index2) {
                                  dynamic citys =
                                      data[index].listData![index2].city;
                                  return Container(
                                    height: 46,
                                    color: Colors.white,
                                    child: GestureDetector(
                                      child: Padding(
                                        padding: EdgeInsets.all(10),
                                        child: Text("$citys",
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Color(0xff434343))),
                                      ),
                                      onTap: () {
                                        Navigator.of(context)
                                            .pop(data[index].listData![index2]);
                                      },
                                    ),
                                  );
                                },
                                itemCount: data[index].listData == null
                                    ? 0
                                    : data[index].listData!.length,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics())
                          ],
                        );
                      }),
              _isTouchTagBar
                  ? Center(
                      child: Card(
                        color: Colors.black38,
                        child: Container(
                          alignment: Alignment.center,
                          width: 80.0,
                          height: 80.0,
                          child: Text(
                            _tagName ?? '',
                            style: TextStyle(
                              fontSize: 32.0,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    )
                  : SizedBox(),
              Positioned(
                top: 0,
                right: 5.w,
                bottom: 0,
                child: Alpha(
                    alphas: letters,
                    alphaItemSize: letterItemSize,
                    onTouchStart: () {
                      this.setState(() {
                        _isTouchTagBar = true;
                      });
                    },
                    onTouchEnd: () {
                      this.setState(() {
                        _isTouchTagBar = false;
                      });
                    },
                    onAlphaChange: (String alpha) {
                      this.setState(() {
                        if (!_isTouchTagBar) {
                          _isTouchTagBar = true;
                        }
                        _tagName = alpha;
                      });
                      _onTagChange(alpha);
                    }),
              ),
            ],
          ),
        )
      ],
    );
  }
}

class Alpha extends StatefulWidget {
  final List? alphas;
  final double? alphaItemSize;

  /// 当选中的字母发生改变
  final AlphaChanged? onAlphaChange;

  final OnTouchStart? onTouchStart;
  final OnTouchMove? onTouchMove;
  final OnTouchEnd? onTouchEnd;

  Alpha(
      {Key? key,
      this.alphaItemSize,
      this.alphas,
      this.onAlphaChange,
      this.onTouchStart,
      this.onTouchMove,
      this.onTouchEnd})
      : super(key: key);

  @override
  _AlphaState createState() => _AlphaState();
}

class _AlphaState extends State<Alpha> {
  bool isTouched = false;
  String? _lastTag;
  double? _distance2Top;

  _buildAlpha() {
    List<Widget> result = [];
    for (var alpha in widget.alphas!) {
      result.add(new SizedBox(
        key: Key(alpha),
        height: widget.alphaItemSize,
        child: new Text(alpha,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: widget.alphaItemSize, color: StyleTheme.cTitleColor)),
      ));
    }
    return Align(
        alignment: Alignment.centerRight,
        child: Container(
          alignment: Alignment.center,
          // color: isTouched ? widget.activeBgColor : widget.bgColor,
          padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
          child: Column(mainAxisSize: MainAxisSize.min, children: result),
        ));
  }

  String? _getHitAlpha(offset) {
    int hit = (offset / widget.alphaItemSize).toInt();
    if (hit < 0) {
      return null;
    }
    if (hit >= widget.alphas!.length) {
      return null;
    }
    return widget.alphas![hit];
  }

  _onAlphaChange([String? tag]) {
    if (tag != _lastTag) {
      _lastTag = tag;
      widget.onAlphaChange!(tag!);
    }
  }

  _touchStartEvent(String tag) {
    this.setState(() {
      isTouched = true;
    });
    _onAlphaChange(tag);

    widget.onTouchStart!();
  }

  _touchMoveEvent(String tag) {
    _onAlphaChange(tag);
    widget.onTouchMove?.call();
  }

  _touchEndEvent() {
    this.setState(() {
      isTouched = false;
    });

    _onAlphaChange(_lastTag);
    widget.onTouchEnd!();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onVerticalDragCancel: () {
          _touchEndEvent();
        },
        onVerticalDragDown: (DragDownDetails details) {
          if (_distance2Top == null) {
            RenderBox renderBox = context.findRenderObject() as RenderBox;
            _distance2Top = renderBox.localToGlobal(Offset.zero).dy.toInt() +
                (renderBox.size.height -
                        widget.alphaItemSize! * widget.alphas!.length) /
                    2;
          }

          int touchOffset2Begin =
              details.globalPosition.dy.toInt() - _distance2Top!.toInt();
          String? tag = _getHitAlpha(touchOffset2Begin);
          _touchStartEvent(tag!);
        },
        onVerticalDragUpdate: (DragUpdateDetails details) {
          int touchOffset2Begin =
              details.globalPosition.dy.toInt() - _distance2Top!.toInt();
          String? tag = _getHitAlpha(touchOffset2Begin);
          _touchMoveEvent(tag!);
        },
        onVerticalDragEnd: (DragEndDetails details) {
          _touchEndEvent();
        },
        child: _buildAlpha());
  }
}

// 城市数据Modal
// ignore: must_be_immutable
class ElegantCityIndexName extends StatelessWidget {
  String indexName;

  ElegantCityIndexName(this.indexName);

  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      color: Color.fromRGBO(245, 245, 245, 1.0),
      height: 45,
      child: Padding(
        child: Text(indexName,
            style: TextStyle(fontSize: 18, color: Color(0xFF969696))),
        padding: EdgeInsets.all(10),
      ),
    );
  }
}

CityListData cityListDataFromJson(String str) =>
    CityListData.fromJson(json.decode(str));

String cityListDataToJson(CityListData data) => json.encode(data.toJson());

class CityListData {
  CityListData({
    this.data,
  });

  List<DatumCity>? data;

  factory CityListData.fromJson(Map<String, dynamic> json) => CityListData(
        data: json["data"] == null
            ? null
            : List<DatumCity>.from(
                json["data"].map((x) => DatumCity.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "data": data == null
            ? null
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class DatumCity {
  DatumCity({
    this.listData,
    this.letter,
  });

  List<ListDatum>? listData;
  String? letter;

  factory DatumCity.fromJson(Map<String, dynamic> json) => DatumCity(
        listData: json["listData"] == null
            ? null
            : List<ListDatum>.from(
                json["listData"].map((x) => ListDatum.fromJson(x))),
        letter: json["letter"] == null ? null : json["letter"],
      );

  Map<String, dynamic> toJson() => {
        "listData": listData == null
            ? null
            : List<dynamic>.from(listData!.map((x) => x.toJson())),
        "letter": letter == null ? null : letter,
      };
}

class ListDatum {
  ListDatum({
    this.letter,
    this.code,
    this.city,
  });

  String? letter;
  int? code;
  String? city;

  factory ListDatum.fromJson(Map<String, dynamic> json) => ListDatum(
        letter: json["letter"] == null ? null : json["letter"],
        code: json["code"] == null ? null : json["code"],
        city: json["city"] == null ? null : json["city"],
      );

  Map<String, dynamic> toJson() => {
        "letter": letter == null ? null : letter,
        "code": code == null ? null : code,
        "city": city == null ? null : city,
      };
}

HotcityCustom hotcityCustomFromJson(String str) =>
    HotcityCustom.fromJson(json.decode(str));

String hotcityCustomToJson(HotcityCustom data) => json.encode(data.toJson());

class HotcityCustom {
  HotcityCustom({
    this.data,
  });

  List<HotDatum>? data;

  factory HotcityCustom.fromJson(Map<String, dynamic> json) => HotcityCustom(
        data: json["data"] == null
            ? null
            : List<HotDatum>.from(
                json["data"].map((x) => HotDatum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "data": data == null
            ? null
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class HotDatum {
  HotDatum({
    this.code,
    this.city,
  });

  int? code;
  String? city;

  factory HotDatum.fromJson(Map<String, dynamic> json) => HotDatum(
        code: json["code"] == null ? null : json["code"],
        city: json["city"] == null ? null : json["city"],
      );

  Map<String, dynamic> toJson() => {
        "code": code == null ? null : code,
        "city": city == null ? null : city,
      };
}
