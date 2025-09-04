import 'package:bot_toast/bot_toast.dart';
import 'package:chaguaner2023/components/card/workbenchCard.dart';
import 'package:chaguaner2023/components/citypickers/CommonCity_pickers.dart';
import 'package:chaguaner2023/components/loading.dart';
import 'package:chaguaner2023/components/networkErr.dart';
import 'package:chaguaner2023/components/nodata.dart';
import 'package:chaguaner2023/components/tab/tab_nav_shuimo.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:chaguaner2023/utils/pageviewmixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MeiziManage extends StatefulWidget {
  final bool isShare;
  MeiziManage({Key? key, this.isShare = false}) : super(key: key);

  @override
  _MeiziManageState createState() => _MeiziManageState();
}

class _MeiziManageState extends State<MeiziManage>
    with TickerProviderStateMixin {
  int limit = 30;
  final myController = TextEditingController();
  bool isShow = false;
  TabController? _tabController;
  Map<int, RefreshController> _refreshController = {
    0: RefreshController(initialRefresh: false),
    1: RefreshController(initialRefresh: false),
    2: RefreshController(initialRefresh: false)
  };
  int page = 1;
  int _selectedTabIndex = 0;
  bool loading = true;
  bool isLoading = false;
  bool isAll = false;
  String infoCount = '';
  String? cityName;
  int meiziNum = 0;
  int? selectCity;
  List cityList = [];
  bool networkErr = false;
  FocusNode focusNode = new FocusNode();
  ScrollController scrollController = ScrollController();
  List _tabs = [
    {
      'id': 0,
      'key': 'all',
      'title': '全部',
      'num': 0,
      'activeWidth': 75.w,
      'inActiveWidth': 75.w,
    },
    {
      'id': 1,
      'key': 'jobs',
      'title': '工作中',
      'num': 0,
      'activeWidth': 75.w,
      'inActiveWidth': 75.w,
    },
    {
      'id': 2,
      'key': 'rest',
      'title': '休息中',
      'num': 0,
      'activeWidth': 75.w,
      'inActiveWidth': 75.w,
    }
  ];
  void _onRefresh() async {
    myOder[_selectedTabIndex]!['page'] = 1;
    myOder[_selectedTabIndex]!['data'] = null;
    myOder[_selectedTabIndex]!['loading'] = true;
    myOder[_selectedTabIndex]!['isLoading'] = true;
    myOder[_selectedTabIndex]!['isAll'] = false;
    intCount();
    setState(() {});
    getInfoList();
    _refreshController[_selectedTabIndex]!.refreshCompleted();
  }

  //int 对应的是上面_tabs的id
  Map<int, Map> myOder = {
    0: {
      'page': 1,
      'data': null,
      'status': null,
      'loading': true,
      'isLoading': true,
      'isAll': false
    },
    1: {
      'page': 1,
      'data': null,
      'status': 2,
      'loading': true,
      'isLoading': true,
      'isAll': false
    },
    2: {
      'page': 1,
      'data': null,
      'status': 5,
      'loading': true,
      'isLoading': true,
      'isAll': false
    }
  };

  _onSubmit(String value, [bool isClear = false]) async {
    if ((value == '') && !isClear) {
      return BotToast.showText(text: '请输入关键词搜索', align: Alignment(0, 0));
    }
    BotToast.showLoading();
    refreshInfo();
    BotToast.closeAllLoading();
  }

  refreshInfo() {
    myOder.forEach((key, value) {
      myOder[key]!['page'] = 1;
      myOder[key]!['data'] = null;
      myOder[key]!['loading'] = true;
      myOder[key]!['isLoading'] = true;
      myOder[key]!['isAll'] = false;
      intCount();
    });
    intCount();
    getInfoList();
  }

  intCount() async {
    var countext = await getVipInfoCount(selectCity);
    if (countext!['status'] != 0) {
      setState(() {
        meiziNum = countext['data']['work'];
        _tabs[1]['num'] = countext['data']['work'];
        _tabs[2]['num'] = countext['data']['rest'];
      });
    }
    print(_tabs);
  }

  getInfoList() async {
    setState(() {
      networkErr = false;
    });
    var coinList = await myVipInfo(myOder[_selectedTabIndex]!['page'], limit,
        myOder[_selectedTabIndex]?['status'], selectCity, myController.text);
    if (myOder[_selectedTabIndex]?['page'] == 1) {
      if (coinList!['status'] != 0) {
        setState(() {
          myOder[_selectedTabIndex]!['data'] =
              coinList['data'] == null ? [] : coinList['data'];
          myOder[_selectedTabIndex]!['loading'] = false;
        });
      } else {
        BotToast.showText(
            text: coinList['msg'] ?? '网络错误', align: Alignment(0, 0));
        setState(() {
          networkErr = true;
        });
        return;
      }
      if (myOder[_selectedTabIndex]!['data'] != null &&
          coinList['data'] != null &&
          coinList['data'].length < limit) {
        setState(() {
          myOder[_selectedTabIndex]!['isAll'] = true;
          myOder[_selectedTabIndex]!['isLoading'] = false;
        });
      }
    } else {
      if (coinList!['status'] != 0 &&
          coinList['data'] != null &&
          coinList['data'].length > 0) {
        setState(() {
          myOder[_selectedTabIndex]!['data']
              .addAll(coinList['data'] == null ? [] : coinList['data']);
        });
      } else {
        setState(() {
          myOder[_selectedTabIndex]!['isLoading'] = false;
          myOder[_selectedTabIndex]!['isAll'] = true;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    intCount();
    // getCityCodebyAff().then((city) => {
    //       if (city.status != 0)
    //         {
    //           city.data.forEach((item) {
    //             setState(() {
    //               cityList
    //                   .add({'code': item });
    //             });
    //           })
    //         }
    //       else
    //         {BotToast.showText(text: city.msg, align: Alignment(0, 0))}
    //     });
    _tabController = TabController(vsync: this, length: _tabs.length);
    focusNode.addListener(() {
      if (!focusNode.hasFocus) {
        _onSubmit(myController.text);
      }
    });
    scrollController.addListener(() {
      if (scrollController.hasClients &&
          scrollController.position.pixels ==
              scrollController.position.maxScrollExtent) {
        if (!myOder[_selectedTabIndex]!['isAll']) {
          setState(() {
            myOder[_selectedTabIndex]!['page']++;
            myOder[_selectedTabIndex]!['isLoading'] = true;
          });
          getInfoList();
        }
      }
    });
    //点击tab
    _tabController!.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController!.index;
      });
      if (!_tabController!.indexIsChanging) {
        //切换tab时有数据不请求，无数据时请求列表
        if (myOder[_selectedTabIndex]!['data'] == null) {
          myOder[_selectedTabIndex]!['loading'] = true;
          getInfoList();
        }
      }
    });
    getInfoList();
  }

  @override
  void dispose() {
    super.dispose();
    myController.dispose();
    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: //妹子管理
          Column(
        children: <Widget>[
          Container(
            width: 345.w,
            height: 30.w,
            margin: EdgeInsets.only(bottom: 10.w),
            decoration: BoxDecoration(
              color: Color(0xFFEEEEEE),
              borderRadius: BorderRadius.circular(30.0),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                    child: TextField(
                  onChanged: (e) {
                    if (e.length > 0 && !isShow) {
                      setState(() {
                        isShow = true;
                      });
                    } else if (e.length == 0) {
                      setState(() {
                        isShow = false;
                      });
                    }
                  },
                  // onSubmitted: _onSubmit,
                  controller: myController,
                  inputFormatters: <TextInputFormatter>[
                    LengthLimitingTextInputFormatter(18),
                    FilteringTextInputFormatter.deny(RegExp('[ ]'))
                  ],
                  textInputAction: TextInputAction.search,
                  onEditingComplete: () {
                    FocusScope.of(context).unfocus();
                  },
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    hintText: '输入关键词搜索妹子',
                    hintStyle: TextStyle(color: StyleTheme.cBioColor),
                    contentPadding: EdgeInsets.zero,
                    fillColor: StyleTheme.textbgColor1,
                    prefixIcon: Padding(
                      child: LocalPNG(
                        url: 'assets/images/home/icon-search.png',
                      ),
                      padding: EdgeInsets.only(left: 10.w, right: 10.w),
                    ),
                    prefixIconConstraints: BoxConstraints(
                      maxHeight: 35.w,
                      maxWidth: 35.w,
                    ),
                    disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide:
                            BorderSide(color: Colors.transparent, width: 0)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide:
                            BorderSide(color: Colors.transparent, width: 0)),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide:
                            BorderSide(color: Colors.transparent, width: 0)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide:
                            BorderSide(color: Colors.transparent, width: 0)),
                  ),
                  style: TextStyle(
                    fontSize: 15.sp,
                  ),
                )),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      myController.text = '';
                      isShow = false;
                    });
                    _onSubmit(myController.text, true);
                  },
                  child: isShow
                      ? Container(
                          margin: EdgeInsets.only(right: 5.w),
                          width: 20.w,
                          height: 20.w,
                          child: LocalPNG(
                            url: 'assets/images/card/clear.png',
                            fit: BoxFit.fill,
                            width: 20.w,
                            height: 20.w,
                          ),
                        )
                      : Container(),
                )
              ],
            ),
          ),
          Container(
            width: widget.isShare ? 0 : null,
            height: widget.isShare ? 0 : null,
            child: Stack(
              children: <Widget>[
                Container(
                  child: TabNavShuimo(
                    tabWidth: (1.sw - 100.w) / _tabs.length,
                    tabStyle: BoxDecoration(
                        color: StyleTheme.cDangerColor,
                        borderRadius: BorderRadius.circular(12.5)),
                    tabs: _tabs,
                    tabController: _tabController,
                    selectedTabIndex: _selectedTabIndex,
                  ),
                ),
                Positioned(
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        _showCityPickers(context);
                      },
                      child: Container(
                        alignment: Alignment.centerRight,
                        height: 47.5.w,
                        margin: EdgeInsets.only(right: 15.w),
                        child: Text(
                          cityName ?? '全部城市>',
                          style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: StyleTheme.cTitleColor),
                        ),
                      ),
                    ))
              ],
            ),
          ),
          Container(
            width: widget.isShare ? null : 0,
            height: widget.isShare ? null : 0,
            padding: EdgeInsets.symmetric(horizontal: 15.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  meiziNum.toString() + '位妹子正在工作',
                  style:
                      TextStyle(fontSize: 12.sp, color: StyleTheme.cTitleColor),
                ),
                GestureDetector(
                    onTap: () {
                      _showCityPickers(context);
                    },
                    child: Container(
                      alignment: Alignment.centerRight,
                      height: 47.5.w,
                      child: Text(
                        cityName ?? '全部城市>',
                        style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: StyleTheme.cTitleColor),
                      ),
                    )),
              ],
            ),
          ),
          Expanded(
              child: TabBarView(
                  physics: ClampingScrollPhysics(),
                  controller: _tabController,
                  children: [
                PageViewMixin(
                  child: monyListView(_tabs[0]['key'], myOder[0]!['data'], 0),
                ),
                PageViewMixin(
                  child: monyListView(_tabs[1]['key'], myOder[1]!['data'], 1),
                ),
                PageViewMixin(
                  child: monyListView(_tabs[2]['key'], myOder[2]!['data'], 2),
                ),
              ]
                  // [_buildListView("aaa:", 0),]
                  ))
        ],
      ),
    );
  }

  Widget monyListView(String key, dynamic _data, int index) {
    return Column(
      children: [
        Expanded(
          child: Container(
            padding: new EdgeInsets.only(
              top: 0,
              bottom: ScreenUtil().bottomBarHeight,
            ),
            child: (myOder[_selectedTabIndex]!['loading'] || _data == null
                ? Loading()
                : networkErr
                    ? NetworkErr(
                        errorRetry: _onRefresh,
                      )
                    : SmartRefresher(
                        controller: _refreshController[index]!,
                        enablePullUp: false,
                        enablePullDown: true,
                        physics: ClampingScrollPhysics(),
                        onRefresh: _onRefresh,
                        header: WaterDropMaterialHeader(
                          backgroundColor: StyleTheme.cDangerColor,
                        ),
                        child: ListView.builder(
                          controller: scrollController,
                          padding: EdgeInsets.all(15.w),
                          key: PageStorageKey(key),
                          physics: ClampingScrollPhysics(),
                          itemCount: _data.length + 1,
                          itemBuilder: (BuildContext context, int index) {
                            if (_data.length == 0) {
                              return NoData(
                                text: '没有数据',
                              );
                            } else {
                              return index != _data.length
                                  ? WorkBenchCard(
                                      isShare: widget.isShare,
                                      cardInfo: _data[index],
                                      key: Key('meizi_$index'),
                                      keys: index,
                                      edit: true,
                                      editCallBack: () {
                                        setState(() {
                                          myOder[_selectedTabIndex]!['data']
                                              .removeAt(index);
                                        });
                                      },
                                    )
                                  : renderMore(
                                      myOder[_selectedTabIndex]!['isLoading']);
                            }
                          },
                        ))),
          ),
        )
      ],
    );
  }

  String loadData = '数据加载中...';
  String noData = '没有更多数据';
  Widget renderMore(bool _loading) {
    return Padding(
      padding: EdgeInsets.only(top: 15.w, bottom: 15.w),
      child: Center(
        child: Text(
          _loading ? loadData : noData,
          style: TextStyle(color: StyleTheme.cBioColor),
        ),
      ),
    );
  }

  _showCityPickers(BuildContext context) async {
    dynamic resultCity = await Navigator.push(context,
        new MaterialPageRoute(builder: (context) => CommonCityPickers()));
    if (resultCity != null) {
      setState(() {
        cityName = resultCity.city;
        selectCity = resultCity.code;
      });
    }
    refreshInfo();
  }
}
