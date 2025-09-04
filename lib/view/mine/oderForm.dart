import 'package:chaguaner2023/components/card/orderCard.dart';
import 'package:chaguaner2023/components/list/public_list.dart';
import 'package:chaguaner2023/components/tab/tab_nav_shuimo.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/index.dart';
import 'package:chaguaner2023/utils/pageviewmixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class OderFromPage extends StatefulWidget {
  final int userType; //预约单类型 1 我的预约单 2 用户预约单
  OderFromPage({Key? key, this.userType = 1}) : super(key: key);

  @override
  _OderFromPageState createState() => _OderFromPageState();
}

class _OderFromPageState extends State<OderFromPage>
    with TickerProviderStateMixin {
  Map<String, RefreshController> _refreshController = {};
  int _selectedTabIndex = 0;
  TabController? _tabController;
  int limit = 10;
  bool networkErr = false;
  List _tabs = [
    {
      'id': 0,
      'key': 'all',
      'emit': 'yuyuedan_all',
      'title': '全部',
      'activeWidth': 75.w,
      'inActiveWidth': 75.w,
    },
    {
      'id': 1,
      'key': 'unconfirm',
      'emit': 'yuyuedan_unconfirm',
      'title': '待确认',
      'activeWidth': 75.w,
      'inActiveWidth': 75.w,
    },
    {
      'id': 2,
      'key': 'confirm',
      'emit': 'yuyuedan_confirm',
      'title': '已确认',
      'activeWidth': 75.w,
      'inActiveWidth': 75.w,
    }
  ];
  getCount() async {
    var getCountFc = widget.userType == 0 ? getOderCount : getUserOderCount;
    var count = await getCountFc();
    if (count!.status != 0) {
      dynamic unconfirmS =
          count.data!.unconfirm == 0 ? '' : count.data!.unconfirm;
      dynamic confirmS = count.data!.confirm == 0 ? '' : count.data!.confirm;
      setState(() {
        _tabs[1]['title'] = '待确认$unconfirmS';
        _tabs[2]['title'] = '已确认$confirmS';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _tabs.forEach((item) {
      _refreshController[item['key']] =
          RefreshController(initialRefresh: false);
    });
    getCount();
    _tabController = TabController(vsync: this, length: _tabs.length);
    //点击tab
    _tabController!.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController!.index;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _tabController!.dispose();
  }

  String userApi = '/api/user/clientAppointment';
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          TabNavShuimo(
            tabWidth: (1.sw - 15.w) / _tabs.length,
            tabStyle: BoxDecoration(
                color: StyleTheme.cDangerColor,
                borderRadius: BorderRadius.circular(12.5)),
            tabs: _tabs,
            tabController: _tabController,
            selectedTabIndex: _selectedTabIndex,
          ),
          Expanded(
              child: TabBarView(
                  physics: ClampingScrollPhysics(),
                  controller: _tabController,
                  children: _tabs.asMap().keys.map((e) {
                    return PageViewMixin(
                      child: PublicList(
                          emitName: _tabs[e]['emit'],
                          isShow: true,
                          limit: 30,
                          isFlow: false,
                          isSliver: false,
                          api: widget.userType == 0
                              ? '/api/user/myAppointment'
                              : userApi,
                          data: {'type': _tabs[e]['id']},
                          row: 1,
                          itemBuild:
                              (context, index, data, page, limit, getListData) {
                            return OderCard(
                              index: index,
                              oderType: widget.userType,
                              setCallBack: (status) {
                                EventBus().emit(_tabs[e]['emit']);
                              },
                              oderInfo: data,
                              status: 1,
                              orderStatus: 1,
                            );
                          }),
                    );
                  }).toList()
                  // [_buildListView("aaa:", 0),]
                  ))
        ],
      ),
    );
  }
}
