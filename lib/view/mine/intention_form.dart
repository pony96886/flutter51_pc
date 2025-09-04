import 'package:chaguaner2023/components/card/intentionCard.dart';
import 'package:chaguaner2023/components/list/public_list.dart';
import 'package:chaguaner2023/components/tab/tab_nav_shuimo.dart';
import 'package:chaguaner2023/store/homeConfig.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/index.dart';
import 'package:chaguaner2023/utils/pageviewmixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class IntentionFormPage extends StatefulWidget {
  IntentionFormPage({Key? key}) : super(key: key);

  @override
  _IntentionFormPageState createState() => _IntentionFormPageState();
}

class _IntentionFormPageState extends State<IntentionFormPage>
    with TickerProviderStateMixin {
  ScrollController scrollController = ScrollController();
  ValueNotifier<int> _selectedTabIndex = ValueNotifier<int>(0);
  Map<String, RefreshController> _refreshController = {};

  TabController? _tabController;
  int limit = 10;
  bool networkErr = false;
  List _tabs = [
    {
      'id': null,
      'key': 'all',
      'emit': 'all_refresh',
      'title': '全部',
      'activeWidth': 75.w,
      'inActiveWidth': 75.w,
    },
    {
      'id': 2,
      'key': 'talk',
      'emit': 'talk_refresh',
      'title': '洽谈中',
    },
    {
      'id': 3,
      'key': 'unconfirm',
      'emit': 'unconfirm_refresh',
      'title': '待确认',
      'activeWidth': 75.w,
      'inActiveWidth': 75.w,
    },
    {
      'id': 5,
      'key': 'confirm',
      'emit': 'confirm_refresh',
      'title': '已确认',
      'activeWidth': 75.w,
      'inActiveWidth': 75.w,
    }
  ];

  @override
  void initState() {
    super.initState();
    _tabs.forEach((item) {
      _refreshController[item['key']] =
          RefreshController(initialRefresh: false);
    });
    _tabController = TabController(vsync: this, length: _tabs.length);
    //点击tab
    _tabController!.addListener(() {
      _selectedTabIndex.value = _tabController!.index;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _tabController!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var _money = Provider.of<HomeConfig>(context).member.money;
    return Container(
      child: Column(
        children: <Widget>[
          ValueListenableBuilder(
              valueListenable: _selectedTabIndex,
              builder: (context, int value, child) {
                return TabNavShuimo(
                  tabWidth: (1.sw - 20.w) / _tabs.length,
                  tabStyle: BoxDecoration(
                      color: StyleTheme.cDangerColor,
                      borderRadius: BorderRadius.circular(12.5)),
                  tabs: _tabs,
                  tabController: _tabController,
                  selectedTabIndex: value,
                ).build(context);
              }),
          Expanded(
              child: TabBarView(
            controller: _tabController,
            children: _tabs.asMap().keys.map((e) {
              return PageViewMixin(
                child: PublicList(
                    emitName: _tabs[e]['emit'],
                    isShow: true,
                    limit: 30,
                    isFlow: false,
                    isSliver: false,
                    api: '/api/user/myRequireList',
                    data: {'status': _tabs[e]['id']},
                    row: 1,
                    itemBuild:
                        (context, index, data, page, limit, getListData) {
                      return IntentionCard(
                        requireData: data,
                        type: 2,
                        myMoney: _money,
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
            }).toList(),
          ))
        ],
      ),
    );
  }
}
