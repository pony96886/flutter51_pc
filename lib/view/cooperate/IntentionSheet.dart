import 'package:chaguaner2023/components/card/grabOrder.dart';
import 'package:chaguaner2023/components/card/intentionCard.dart';
import 'package:chaguaner2023/components/list/public_list.dart';
import 'package:chaguaner2023/components/nodata.dart';
import 'package:chaguaner2023/components/tab/tab_nav_shuimo.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/index.dart';
import 'package:chaguaner2023/utils/pageviewmixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class IntentionSheetPage extends StatefulWidget {
  IntentionSheetPage({Key? key}) : super(key: key);

  @override
  _IntentionSheeteState createState() => _IntentionSheeteState();
}

class _IntentionSheeteState extends State<IntentionSheetPage>
    with TickerProviderStateMixin {
  int _selectedTabIndex = 0;
  bool loadmore = true;
  TabController? _tabController;
  int limit = 10;
  bool networkErr = false;
  List _tabs = [
    {
      'id': 0,
      'key': 'hall',
      'title': '抢单大厅',
      'emit': 'hall_refresh',
      'api': '/api/info/pickList'
    },
    {
      'id': 2,
      'key': 'talk',
      'emit': 'talk_refresh',
      'title': '洽谈中',
      'api': '/api/user/clientRequireList'
    },
    {
      'id': 3,
      'key': 'unconfirm',
      'emit': 'unconfirm_refresh',
      'title': '待确认',
      'api': '/api/user/clientRequireList'
    },
    {
      'id': 5,
      'key': 'confirm',
      'emit': 'confirm_refresh',
      'title': '已确认',
      'api': '/api/user/clientRequireList'
    }
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: _tabs.length);
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
    return Container(
      child: Column(
        children: <Widget>[
          Stack(
            children: <Widget>[
              TabNavShuimo(
                tabWidth: (1.sw - 15.w) / _tabs.length,
                tabStyle: BoxDecoration(
                    color: StyleTheme.cDangerColor,
                    borderRadius: BorderRadius.circular(12.5)),
                tabs: _tabs,
                tabController: _tabController,
                selectedTabIndex: _selectedTabIndex,
              ).build(context),
            ],
          ),
          Expanded(
            child: TabBarView(
                physics: ClampingScrollPhysics(),
                controller: _tabController,
                children: _tabs.asMap().keys.map((e) {
                  return PageViewMixin(
                    child: PublicList(
                        emitName: _tabs[e]['emit'],
                        noData: NoData(
                          text: '还没有意向单哦～',
                        ),
                        isShow: true,
                        limit: 30,
                        isFlow: false,
                        isSliver: false,
                        api: _tabs[e]['api'],
                        data: _tabs[e]['id'] == 0
                            ? {}
                            : {'status': _tabs[e]['id']},
                        row: 1,
                        itemBuild:
                            (context, index, data, page, limit, getListData) {
                          return _tabs[e]['key'] == 'hall'
                              ? GrabOrderCard(
                                  orderData: data,
                                  callBack: (_agm) {
                                    EventBus().emit(_tabs[e]['emit']);
                                    if (_agm) {
                                      if (e + 1 < _tabs.length) {
                                        EventBus().emit(_tabs[e + 1]['emit']);
                                      }
                                    } else {
                                      if (e - 1 >= 0) {
                                        EventBus().emit(_tabs[e - 1]['emit']);
                                      }
                                    }
                                  },
                                )
                              : IntentionCard(
                                  requireData: data,
                                  closeTime: _tabs[e]['key'] == 'confirm',
                                  type: 1,
                                  callBack: (_agm) {
                                    EventBus().emit(_tabs[e]['emit']);
                                    if (_agm) {
                                      if (e + 1 < _tabs.length) {
                                        EventBus().emit(_tabs[e + 1]['emit']);
                                      }
                                    } else {
                                      if (e - 1 >= 0) {
                                        EventBus().emit(_tabs[e - 1]['emit']);
                                      }
                                    }
                                  },
                                );
                        }),
                  );
                }).toList()),
          )
        ],
      ),
    );
  }
}
