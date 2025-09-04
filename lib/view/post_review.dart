import 'package:chaguaner2023/components/card/V4CheckerCard.dart';
import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/list/public_list.dart';
import 'package:chaguaner2023/components/nodata.dart';
import 'package:chaguaner2023/components/pagetitlebar.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/index.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:chaguaner2023/utils/pageviewmixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class PostReviewPage extends StatefulWidget {
  PostReviewPage({Key? key}) : super(key: key);

  @override
  _PostReviewPageState createState() => _PostReviewPageState();
}

class _PostReviewPageState extends State<PostReviewPage>
    with TickerProviderStateMixin {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  TabController? _tabController;
  ScrollController? scrollController;
  int activeIndex = 0;
  int limit = 10;
  bool loadmore = true;
  bool networkErr = false;
  List _tabs = [
    {'title': '待领取', 'status': 1, 'emit': 'changeStatea'},
    {'title': '待审核', 'status': 2, 'emit': 'changeStateb'},
    {'title': '已审核', 'status': 3, 'emit': 'changeStatec'}
  ];

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(vsync: this, length: 3);
    _tabController!.addListener(() {
      setState(() {
        activeIndex = _tabController!.index;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    scrollController?.dispose();
    _tabController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HeaderContainer(
      child: Scaffold(
          body: Column(
        children: [
          PageTitleBar(
            title: '茶帖审核',
          ),
          TabBar(
            controller: _tabController,
            indicatorColor: Colors.transparent,
            indicatorPadding: EdgeInsets.zero,
            labelPadding: EdgeInsets.zero,
            tabs: _tabs
                .asMap()
                .keys
                .map(
                  (e) => CustomTab(
                      tabIndex: activeIndex,
                      keyIndex: e,
                      title: _tabs[e]['title']),
                )
                .toList(),
          ),
          Expanded(
              child: CustomScrollView(
            slivers: <Widget>[
              SliverFillRemaining(
                  child: TabBarView(
                controller: _tabController,
                children: _tabs.asMap().keys.map((e) {
                  return PageViewMixin(
                    child: PublicList(
                        emitName: _tabs[e]['emit'],
                        noData: NoData(
                          text: '还没有帖子哦～',
                        ),
                        isShow: true,
                        limit: 30,
                        isFlow: false,
                        isSliver: false,
                        api: '/api/user/checkerList',
                        data: {'status': _tabs[e]['status']},
                        row: 1,
                        itemBuild:
                            (context, index, data, page, limit, getListData) {
                          return V4CheckerCard(
                              type: _tabs[e]['status'],
                              zpInfo: data,
                              reqCallBack: () {
                                EventBus().emit(_tabs[e]['emit']);
                                if (e + 1 < _tabs.length) {
                                  EventBus().emit(_tabs[e + 1]['emit']);
                                }
                              });
                        }),
                  );
                }).toList(),
              ))
            ],
          ))
        ],
      )),
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
                url: 'assets/images/tab-underline.png',
                alignment: Alignment.center,
                fit: BoxFit.fitHeight,
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
