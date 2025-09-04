import 'package:bot_toast/bot_toast.dart';
import 'package:chaguaner2023/components/card/V3zhaopiaoCard.dart';
import 'package:chaguaner2023/components/card/elegantCard.dart';
import 'package:chaguaner2023/components/card/reportCard.dart';
import 'package:chaguaner2023/components/list/public_list.dart';
import 'package:chaguaner2023/components/loading.dart';
import 'package:chaguaner2023/components/pagetitlebar.dart';
import 'package:chaguaner2023/components/tab/tab_nav_shuimo.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:chaguaner2023/utils/pageviewmixin.dart';
import 'package:chaguaner2023/view/yajian/collectView.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';

class BrokerHomepage extends StatefulWidget {
  final String? aff;
  final String? thumb;
  final String? brokerName;

  BrokerHomepage({
    Key? key,
    this.aff,
    this.thumb,
    this.brokerName,
  }) : super(key: key);

  @override
  _BrokerHomepageState createState() => _BrokerHomepageState();
}

class _BrokerHomepageState extends State<BrokerHomepage>
    with TickerProviderStateMixin {
  int defaultScrooller = 300;
  ScrollController? _scrollViewController;
  TabController? _tabController;
  int _selectedTabIndex = 0;
  int limit = 10;
  int dataType = 1;
  bool networkErr = false;
  List _tabs = [
    {
      'id': 0,
      'title': '雅间妹子',
      'activeWidth': 1.sw / 4,
      'inActiveWidth': 1.sw / 4,
      'row': 2,
      'isFlow': true,
      'api': '/api/v150/UserVipInfoList'
    },
    {
      'id': 1,
      'title': '发布茶帖',
      'activeWidth': 1.sw / 4,
      'inActiveWidth': 1.sw / 4,
      'row': 1,
      'isFlow': false,
      'api': '/api/v150/getUserPost'
    },
    {
      'id': 2,
      'title': '验茶报告',
      'activeWidth': 1.sw / 4,
      'inActiveWidth': 1.sw / 4,
      'row': 1,
      'isFlow': false,
      'api': '/api/v150/UserConfirmList'
    },
    {
      'id': 3,
      'title': '收藏',
      'activeWidth': 1.sw / 4,
      'inActiveWidth': 1.sw / 4,
      'row': 1,
      'isFlow': false,
      'api': ''
    }
  ];

  List resourcesDataList = [];
  bool isAgent = false;
  bool isLoading = true;
  int vipInfoNum = 0;
  int infoNum = 0;
  int confirmNum = 0;
  ValueNotifier<double> _o = ValueNotifier<double>(0);

  _getAgentData() async {
    var result = await getUserPostNum(widget.aff!);
    if (result!['status'] == 1) {
      if (result['data']['postVipInfoNum'] == 0) {
         _tabs.removeWhere((tab) => tab['id'] == 0);
      } else {
        isAgent = true;
      }
      if (isAgent) {
          _tabs.removeWhere((tab) => tab['id'] == 2);
      }
      _tabController = TabController(vsync: this, length: _tabs.length);
      _tabController!.addListener(() {
        _selectedTabIndex = _tabController!.index;
        setState(() {});
      });

      vipInfoNum = result['data']['postVipInfoNum'];
      infoNum = result['data']['postInfoNum'];
      confirmNum = result['data']['postConfirmNum'];
      isLoading = false;
      setState(() {});
    } else {
      BotToast.showText(text: result['msg'], align: Alignment.center);
      Navigator.of(context).pop();
    }
  }

  addListenerScroll() {
    _o.value = _scrollViewController!.position.pixels /
        _scrollViewController!.position.maxScrollExtent;
  }

  @override
  void initState() {
    super.initState();
    _getAgentData();
    _scrollViewController = ScrollController(initialScrollOffset: 0.0);
    _scrollViewController!.addListener(addListenerScroll);
  }

  @override
  void dispose() {
    _scrollViewController!.removeListener(addListenerScroll);
    _scrollViewController!.dispose();
    _tabController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Loading()
        : Container(
            color: Colors.white,
            child: Stack(
              children: [
                ValueListenableBuilder(
                    valueListenable: _o,
                    builder: (context, double value, child) {
                      return Opacity(
                        opacity: 1 - value,
                        child: LocalPNG(
                          url: "assets/images/home/normalbg.png",
                          alignment: Alignment.topCenter,
                        ),
                      );
                    }),
                Scaffold(
                    appBar: PreferredSize(
                        child: Stack(
                          children: [
                            PageTitleBar(
                              title: '',
                              color: Colors.white,
                            ),
                            Positioned.fill(
                              child: ValueListenableBuilder(
                                valueListenable: _o,
                                builder: (BuildContext? context, dynamic value,
                                    Widget? child) {
                                  return Opacity(
                                    opacity: value,
                                    child: PageTitleBar(
                                      title: widget.brokerName,
                                      backColor: Colors.white,
                                      color: Colors.black,
                                    ),
                                  );
                                },
                              ),
                            )
                          ],
                        ),
                        preferredSize: Size(double.infinity, 44.w)),
                    backgroundColor: Colors.transparent,
                    body: ExtendedNestedScrollView(
                        controller: _scrollViewController,
                        physics: ClampingScrollPhysics(),
                        headerSliverBuilder:
                            (BuildContext context, bool innerBoxIsScrolled) {
                          return <Widget>[
                            SliverToBoxAdapter(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _headerContent(),
                                ],
                              ),
                            ),
                          ];
                        },
                        body: Column(
                          children: [
                            PreferredSize(
                                child: TabNavShuimo(
                                  tabs: _tabs,
                                  tabController: _tabController,
                                  selectedTabIndex: _selectedTabIndex,
                                ).build(context),
                                preferredSize: Size(double.infinity, 44.w)),
                            Expanded(
                                child: TabBarView(
                                    controller: _tabController,
                                    children: _tabs.asMap().keys.map((e) {
                                      if (_tabs[e]['id'] == 3) {
                                        return CollectView(
                                          aff: widget.aff,
                                        );
                                      }
                                      return PageViewMixin(
                                        child: PublicList(
                                            noController: true,
                                            isShow: true,
                                            isFlow: _tabs[e]['isFlow'],
                                            api: _tabs[e]['api'],
                                            data: {'aff': widget.aff},
                                            row: _tabs[e]['row'],
                                            itemBuild: (context, index, data,
                                                page, limit, getListData) {
                                              if (_tabs[e]['id'] == 0) {
                                                return ElegantCard(
                                                  cardInfo: data,
                                                );
                                              } else if (_tabs[e]['id'] == 1) {
                                                return V3ZhaoPiaoCard(
                                                    isBrokerhome: true,
                                                    zpInfo: data);
                                              } else {
                                                return ReportCard(
                                                    reportInfo: data);
                                              }
                                            }),
                                      );
                                    }).toList()))
                          ],
                        ))),
              ],
            ));
  }

  Widget _headerContent() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      child: Stack(children: [
        Container(
          margin: EdgeInsets.only(top: 45.w),
          color: Colors.white,
          height: 60.w,
        ),
        Positioned(
            bottom: 7.w,
            child: Container(
              width: 1.sw,
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 8.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AvatarBox(
                        type: widget.thumb,
                      ),
                      SizedBox(height: 10.w),
                      Text(widget.brokerName!,
                          style: TextStyle(
                              color: Color(0xFF1E1E1E), fontSize: 15.w)),
                    ],
                  ),
                  Expanded(flex: 1, child: SizedBox()),
                  Row(
                    children: [
                      isAgent
                          ? Column(
                              children: [
                                Text(vipInfoNum.toString(),
                                    style: TextStyle(
                                        color: Color(0xFF1E1E1E),
                                        fontSize: 18.sp)),
                                SizedBox(height: 7.5.w),
                                Text('雅间妹子',
                                    style: TextStyle(
                                        color: Color(0xFF969696),
                                        fontSize: 12.sp)),
                              ],
                            )
                          : SizedBox(),
                      SizedBox(width: 30.w),
                      Column(
                        children: [
                          Text(infoNum.toString(),
                              style: TextStyle(
                                  color: Color(0xFF1E1E1E), fontSize: 18.sp)),
                          SizedBox(height: 7.5.w),
                          Text('发布茶帖',
                              style: TextStyle(
                                  color: Color(0xFF969696), fontSize: 12.sp)),
                        ],
                      ),
                      SizedBox(width: 30.w),
                      Column(
                        children: [
                          Text('$confirmNum',
                              style: TextStyle(
                                  color: Color(0xFF1E1E1E), fontSize: 18.sp)),
                          SizedBox(height: 7.5.w),
                          Text('验茶报告',
                              style: TextStyle(
                                  color: Color(0xFF969696), fontSize: 12.sp)),
                        ],
                      )
                    ],
                  )
                ],
              ),
            ))
      ]),
    );
  }
}

class AvatarBox extends StatelessWidget {
  final dynamic type;
  AvatarBox({Key? key, this.type}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: LocalPNG(
        width: 50.w,
        height: 50.w,
        url: 'assets/images/common/$type.png',
      ),
    );
  }
}
