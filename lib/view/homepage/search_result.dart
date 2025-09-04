import 'package:chaguaner2023/components/avatar_widget.dart';
import 'package:chaguaner2023/components/card/V3zhaopiaoCard.dart';
import 'package:chaguaner2023/components/card/adoptCard.dart';
import 'package:chaguaner2023/components/card/elegantCard.dart';
import 'package:chaguaner2023/components/card/mallCard.dart';
import 'package:chaguaner2023/components/card/rezhengCard.dart';
import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/list/public_list.dart';
import 'package:chaguaner2023/components/nodata.dart';
import 'package:chaguaner2023/components/pagetitlebar.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:chaguaner2023/utils/netimage_tool.dart';
import 'package:chaguaner2023/utils/pageviewmixin.dart';
import 'package:chaguaner2023/utils/sp_keys.dart';
import 'package:chaguaner2023/view/homepage/nakedchat/nakedchat_card.dart';
import 'package:chaguaner2023/view/im/im.dart';
import 'package:chaguaner2023/view/im/im_page.dart';
import 'package:chaguaner2023/view/yajian/tanhua.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bot_toast/bot_toast.dart';

class SearchResult extends StatefulWidget {
  SearchResult({Key? key, this.parmas}) : super(key: key);
  final Object? parmas;
  @override
  _SearchResultState createState() => _SearchResultState();
}

class _SearchResultState extends State<SearchResult> {
  final myController = TextEditingController();

  List<dynamic> _history = [];

  @override
  void initState() {
    super.initState();
    initShared();
  }

  initShared() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool checkValue = prefs.containsKey('${SpKeys.searchHistory}');
    if (checkValue) {
      getHistory();
    } else {
      prefs.setString('${SpKeys.searchHistory}', '#');
    }
  }

  getHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? stringValue = prefs.getString('${SpKeys.searchHistory}');
    if (['', null, false].contains(stringValue)) {
      setState(() {
        _history = [];
      });
    } else {
      List<String> historyValue = stringValue!.split('#');
      Set<dynamic> setFun = new Set();
      setFun.addAll(historyValue);
      List<dynamic> newlist = setFun.toList();
      setState(() {
        _history = newlist;
      });
    }
  }

  addHistory(String value) async {
    if (value.isEmpty) return;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? stringValue = prefs.getString('${SpKeys.searchHistory}');
    String newValue = '$stringValue#$value';
    prefs.setString('${SpKeys.searchHistory}', newValue);
    initShared();
  }

  clearHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('${SpKeys.searchHistory}', '#').then(
        (value) => BotToast.showText(text: '清除成功', align: Alignment(0, 0)));
    getHistory();
  }

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  _onSubmit(String value) async {
    String ceksss = r"\s+\b|\b\s";
    RegExp clearReg = RegExp(ceksss);
    var clearValue = value.replaceAll(clearReg, '');
    if (['', null, false].contains(clearValue)) {
      BotToast.showText(text: '请输入关键词搜索', align: Alignment(0, 0));
      return;
    }
    addHistory(clearValue);
    AppGlobal.appRouter?.push(
        CommonUtils.getRealHash(
            'searchSuggestionList/' + Uri.encodeComponent(clearValue)),
        extra: widget.parmas);
  }

  Widget buildHistory(BuildContext context) {
    List<Widget> tiles = [];
    Widget container;
    for (var i = 0; i < _history.length; i++) {
      if (_history[i] == '') {
      } else {
        tiles.add(new GestureDetector(
          onTap: () {
            _onSubmit(_history[i]);
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 5.w, horizontal: 15.w),
            decoration: BoxDecoration(
                color: Color(0xFFEEEEEE),
                borderRadius: BorderRadius.circular(30.0)),
            child: Text(
              _history[i],
              style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 14.sp),
            ),
          ),
        ));
      }
    }
    container = new Wrap(spacing: 10, runSpacing: 10, children: tiles);
    return container;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
          child: PageTitleBar(
              centerWidget: Container(
                width: 260.w,
                height: 30.w,
                decoration: BoxDecoration(
                  color: Color(0xFFEEEEEE),
                  borderRadius: BorderRadius.circular(30.0),
                ),
                child: TextField(
                  autofocus: true,
                  onSubmitted: _onSubmit,
                  controller: myController,
                  inputFormatters: <TextInputFormatter>[
                    LengthLimitingTextInputFormatter(18),
                    FilteringTextInputFormatter.deny(RegExp('[ ]'))
                  ],
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    hintText: '输入关键词搜索',
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
                ),
              ),
              rightWidget: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  _onSubmit(myController.text);
                },
                child: Padding(
                    padding: EdgeInsets.all(10.w),
                    child: Text(
                      '搜索',
                      style: TextStyle(
                        color: StyleTheme.cTitleColor,
                        fontSize: 14.sp,
                      ),
                      softWrap: false,
                    )),
              )),
          preferredSize: Size(double.infinity, 44.w)),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(15.w),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      '历史记录',
                      style: TextStyle(
                          color: StyleTheme.cTitleColor, fontSize: 15.sp),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      clearHistory();
                    },
                    child: LocalPNG(
                      url: 'assets/images/delete_icon.png',
                      width: 25.w,
                      height: 25.w,
                    ),
                  )
                ],
              ),
            ),
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.w),
                child: buildHistory(context))
          ],
        ),
      ),
    );
  }
}

class SearchSuggestionList extends StatefulWidget {
  final String? title;
  final Map? extra;
  SearchSuggestionList({Key? key, this.title, this.extra}) : super(key: key);

  @override
  _SearchSuggestionListState createState() => _SearchSuggestionListState();
}

class _SearchSuggestionListState extends State<SearchSuggestionList>
    with TickerProviderStateMixin {
  TabController? _tabController;
  List _tabs = [
    {
      'id': 0,
      'key': 'chatie',
      'title': '茶友分享',
      'data': null,
      'page': 1,
      'limit': 15,
      'readmore': true,
    },
    {
      'id': 0,
      'key': 'peifu',
      'title': '赔付专区',
      'data': null,
      'page': 1,
      'limit': 15,
      'readmore': true,
    },
    {
      'id': 0,
      'key': 'renzheng',
      'title': '认证专区',
      'data': null,
      'page': 1,
      'limit': 15,
      'readmore': true,
    },
    {
      'id': 0,
      'key': 'yajian',
      'title': '雅间',
      'data': null,
      'page': 1,
      'limit': 15,
      'readmore': true,
    },
    {
      'id': 1,
      'key': 'chalaoban',
      'title': '茶老板',
      'data': null,
      'page': 1,
      'limit': 15,
      'readmore': true,
    },
    {
      'id': 2,
      'key': 'chit',
      'title': '裸聊',
      'data': null,
      'page': 1,
      'limit': 20,
      'readmore': true,
    },
    {
      'id': 2,
      'key': 'video',
      'title': '探花好片',
      'data': null,
      'page': 1,
      'limit': 20,
      'readmore': true,
    },
    {
      'id': 2,
      'key': 'product',
      'title': '商品',
      'data': null,
      'page': 1,
      'limit': 20,
      'readmore': true,
    },
    {
      'id': 2,
      'key': 'adopt',
      'title': '包养',
      'data': null,
      'page': 1,
      'limit': 20,
      'readmore': true,
    }
  ];
  int _selectedTabIndex = 0;
  @override
  void initState() {
    super.initState();
    if (widget.extra?['index'] != null) {
      _selectedTabIndex = (widget.extra as Map)['index'];
    }
    _tabController = TabController(
        vsync: this, length: _tabs.length, initialIndex: _selectedTabIndex);
    //点击tab
    _tabController!.addListener(() {
      _selectedTabIndex = _tabController!.index;

      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    _tabController!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HeaderContainer(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
            child: PageTitleBar(
              title: widget.title,
            ),
            preferredSize: Size(double.infinity, 44.w)),
        body: Column(
          children: [
            Theme(
                data: ThemeData(
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  useMaterial3: false,
                ),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  indicator: BoxDecoration(),
                  indicatorColor: Colors.transparent,
                  indicatorPadding: EdgeInsets.all(0),
                  labelPadding: EdgeInsets.all(0),
                  tabs: _tabs
                      .asMap()
                      .keys
                      .map(
                        (key) => Tab(
                          child: Container(
                            color: Colors.transparent,
                            height: 50.w,
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.symmetric(horizontal: 15.w),
                            child: Stack(
                              children: <Widget>[
                                Text(_tabs[key]['title'],
                                    style: _selectedTabIndex == key
                                        ? TextStyle(
                                            color: StyleTheme.cTitleColor,
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.w700)
                                        : TextStyle(
                                            color: StyleTheme.cTitleColor,
                                            fontSize: 14.sp)),
                                Positioned(
                                    top: 0,
                                    right: 0,
                                    child: _selectedTabIndex == key
                                        ? Opacity(
                                            opacity: 0.8,
                                            child: Container(
                                              width: 14.w,
                                              height: 12.w,
                                              decoration: BoxDecoration(
                                                  color: Color(0xffffb295)
                                                      .withOpacity(0.8),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                            ),
                                          )
                                        : Text(' ')),
                              ],
                            ),
                          ),
                        ),
                      )
                      .toList(),
                )),
            Expanded(
                child: TabBarView(controller: _tabController, children: [
              PageViewMixin(
                child: PublicList(
                    noData: NoData(
                      text: '没有搜索到关于"${widget.title}"的结果',
                    ),
                    isShow: true,
                    limit: 30,
                    isFlow: false,
                    isSliver: false,
                    api: '/api/info/search',
                    data: {'word': widget.title},
                    row: 1,
                    itemBuild:
                        (context, index, data, page, limit, getListData) {
                      return V3ZhaoPiaoCard(zpInfo: data);
                    }),
              ),
              PageViewMixin(
                child: PublicList(
                    noData: NoData(
                      text: '没有搜索到关于"${widget.title}"的结果',
                    ),
                    isShow: true,
                    limit: 30,
                    isFlow: false,
                    isSliver: false,
                    api: '/api/info/search',
                    data: {'word': widget.title, 'search_type': 2},
                    row: 1,
                    itemBuild:
                        (context, index, data, page, limit, getListData) {
                      return V3ZhaoPiaoCard(isPeifu: true, zpInfo: data);
                    }),
              ),
              PageViewMixin(
                child: PublicList(
                    noData: NoData(
                      text: '没有搜索到关于"${widget.title}"的结果',
                    ),
                    isShow: true,
                    limit: 30,
                    isFlow: false,
                    isSliver: false,
                    api: '/api/info/search',
                    data: {'word': widget.title, 'search_type': 3},
                    row: 2,
                    aspectRatio: 0.7,
                    mainAxisSpacing: 5.w,
                    crossAxisSpacing: 5.w,
                    itemBuild:
                        (context, index, data, page, limit, getListData) {
                      return RenZhengCard(
                        chapuData: data,
                      );
                    }),
              ),
              PageViewMixin(
                child: PublicList(
                    noData: NoData(
                      text: '没有搜索到关于"${widget.title}"的结果',
                    ),
                    isShow: true,
                    limit: 30,
                    isFlow: true,
                    isSliver: false,
                    api: '/api/info/search',
                    data: {'word': widget.title, 'search_type': 4},
                    row: 2,
                    itemBuild:
                        (context, index, data, page, limit, getListData) {
                      return ElegantCard(cardInfo: data);
                    }),
              ),
              PageViewMixin(
                child: PublicList(
                    noData: NoData(
                      text: '没有搜索到关于"${widget.title}"的结果',
                    ),
                    isShow: true,
                    limit: 12,
                    isFlow: false,
                    isSliver: false,
                    api: '/api/info/searchAgent',
                    data: {'word': widget.title},
                    row: 1,
                    itemBuild:
                        (context, index, data, page, limit, getListData) {
                      return chaBossCard(data);
                    }),
              ),
              PageViewMixin(
                child: PublicList(
                    noData: NoData(
                      text: '没有搜索到关于"${widget.title}"的结果',
                    ),
                    isShow: true,
                    limit: 12,
                    isFlow: false,
                    isSliver: false,
                    api: '/api/girlchat/search',
                    data: {'word': widget.title},
                    row: 2,
                    aspectRatio: 0.74,
                    mainAxisSpacing: 10.w,
                    crossAxisSpacing: 5.w,
                    itemBuild:
                        (context, index, data, page, limit, getListData) {
                      return NakedchtCard(data: data);
                    }),
              ),
              PageViewMixin(
                  child: PublicList(
                      isShow: true,
                      limit: 20,
                      isSliver: false,
                      aspectRatio: 1.3,
                      crossAxisSpacing: 10.w,
                      mainAxisSpacing: 10.w,
                      api: '/api/mv/search',
                      data: {'word': widget.title},
                      row: 2,
                      itemBuild:
                          (context, index, data, page, limit, getListData) {
                        return TanhuaCard(
                          item: data,
                        );
                      })),
              PageViewMixin(
                  child: PublicList(
                      isShow: true,
                      limit: 20,
                      isSliver: false,
                      aspectRatio: 170.5 / 275.5,
                      crossAxisSpacing: 6.w,
                      mainAxisSpacing: 10.w,
                      api: '/api/product/search',
                      data: {'word': widget.title},
                      row: 2,
                      noData: NoData(
                        text: '还没有商品哦～',
                      ),
                      itemBuild:
                          (context, index, data, page, limit, getListData) {
                        return MallGirlCard(
                          data: data,
                        );
                      })),
              PageViewMixin(
                  child: PublicList(
                      isShow: true,
                      limit: 20,
                      isSliver: false,
                      mainAxisSpacing: 7.w,
                      crossAxisSpacing: 7.w,
                      aspectRatio: 0.7,
                      api: '/api/keep/search',
                      data: {'keyword': widget.title},
                      row: 2,
                      noData: NoData(
                        text: '还没有包养哦～',
                      ),
                      itemBuild:
                          (context, index, data, page, limit, getListData) {
                        return AdoptCard(
                          adoptData: data,
                        );
                      })),
            ]))
          ],
        ),
      ),
    );
  }

  toLlIm({uuid, nickname, thumb}) {
    AppGlobal.chatUser = FormUserMsg(
        isVipDetail: true,
        isGirl: true,
        uuid: uuid.toString(),
        nickname: nickname.toString(),
        avatar: thumb.toString());
    AppGlobal.appRouter?.push(CommonUtils.getRealHash('llchat'));
  }

  Widget chaBossCard(Map faqiData) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      child: GestureDetector(
        onTap: () {
          AppGlobal.appRouter?.push(CommonUtils.getRealHash('brokerHomepage/' +
              faqiData['aff'].toString() +
              '/' +
              Uri.encodeComponent(faqiData['thumb'].toString()) +
              '/' +
              Uri.encodeComponent(faqiData['nickname'].toString())));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      margin: EdgeInsets.only(right: 10.w),
                      height: 40.w,
                      width: 40.w,
                      child: Avatar(
                        type: faqiData['thumb'],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          faqiData['nickname'],
                          style: TextStyle(
                              color: StyleTheme.cTitleColor,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700),
                        ),
                        Text(
                            '发布 ' +
                                faqiData['postGirlNum'].toString() +
                                ' 妹子，成交 ' +
                                faqiData['orderNum'].toString() +
                                ' 单',
                            style: TextStyle(
                              color: Color(0xff969696),
                              fontSize: 12.sp,
                            ))
                      ],
                    )
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    if (WebSocketUtility.vipLevel! < 3) {
                      CommonUtils.showText('此功能仅对会员用户开放');
                      return;
                    }

                    if (WebSocketUtility.imToken == null) {
                      CommonUtils.getImPath(context, callBack: () {
                        //跳转IM
                        toLlIm(
                            uuid: faqiData['uuid'],
                            nickname: faqiData['nickname'],
                            thumb: faqiData['thumb']);
                      });
                    } else {
                      //跳转IM
                      toLlIm(
                          uuid: faqiData['uuid'],
                          nickname: faqiData['nickname'],
                          thumb: faqiData['thumb']);
                    }
                  },
                  child: Container(
                    width: 85.w,
                    height: 30.w,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: StyleTheme.cDangerColor),
                    child: Center(
                      child: Text('联系茶老板',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13.sp,
                          )),
                    ),
                  ),
                )
              ],
            ),
            faqiData['girls'] != null
                ? Padding(
                    padding: EdgeInsets.only(
                      top: 20.w,
                    ),
                    child: GridView.builder(
                        itemCount: faqiData['girls'].length > 3
                            ? 3
                            : faqiData['girls'].length,
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            childAspectRatio: 0.85,
                            crossAxisCount: 3,
                            mainAxisSpacing: 5.w,
                            crossAxisSpacing: 5.w),
                        itemBuilder: (context, index) {
                          return meiziItem(
                              faqiData['girls'][index]['title'],
                              faqiData['girls'][index]['resources'].length > 0
                                  ? faqiData['girls'][index]['resources'][0]
                                      ['url']
                                  : null);
                        }))
                : SizedBox()
          ],
        ),
      ),
    );
  }

  Widget meiziItem(String meiziName, String url) {
    return url == null
        ? Container()
        : Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 10.w),
                height: 100.w,
                width: 100.w,
                child: NetImageTool(
                  url: url,
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                width: 100.w,
                child: Text(
                  meiziName,
                  style: TextStyle(
                    color: StyleTheme.cTitleColor,
                    fontSize: 11.5.w,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            ],
          );
  }
}
