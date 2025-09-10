import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/loading.dart';
import 'package:chaguaner2023/components/page_title_bar.dart';
import 'package:chaguaner2023/components/tab/nav_tab_bar_mixin.dart';
import 'package:chaguaner2023/store/global.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:chaguaner2023/view/homepage/cgmall_list.dart';
import 'package:chaguaner2023/view/homepage/cgrank_list.dart';
import 'package:extended_tabs/extended_tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class CgRankPage extends StatefulWidget {
  const CgRankPage({Key? key}) : super(key: key);

  @override
  State<CgRankPage> createState() => _CgRankPageState();
}

class _CgRankPageState extends State<CgRankPage>
    with SingleTickerProviderStateMixin {
  List<Map> tabs = [];
  ValueNotifier<List> categoryList = ValueNotifier([]);
  TabController? tabController;
  bool loading = true;
  Map selectTab = {};

  @override
  void initState() {
    super.initState();
    rankList().then((res) {
      print(res);
      print('_________');
      if (res!['status'] != 0 && res['data'] != null) {
        tabs = (res['data'] as List).map((e) => e as Map).toList();
        tabController = TabController(length: tabs.length, vsync: this);
        loading = false;
        setState(() {});
      } else {
        CommonUtils.showText('系统错误～');
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    categoryList.dispose();
    tabController!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HeaderContainer(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: PreferredSize(
              child: PageTitleBar(title: '排行榜'),
              preferredSize: Size(double.infinity, 44.w)),
          body: loading
              ? Loading()
              : Column(
                  children: [
                    NavTabBarWidget(
                      tabBarHeight: 44.0.w,
                      tabVc: tabController,
                      tabs: tabs.map((e) => e['name'] as String).toList(),
                      textPadding: EdgeInsets.symmetric(horizontal: 12.5.w),
                      selectedIndex: tabController!.index,
                      norTextStyle: TextStyle(
                          color: StyleTheme.cTitleColor, fontSize: 15.sp),
                      selTextStyle: TextStyle(
                          color: StyleTheme.cTitleColor, fontSize: 16.sp),
                      indicatorStyle: NavIndicatorStyle.sys_fixed,
                    ),
                    Expanded(
                        child: ExtendedTabBarView(
                      controller: tabController,
                      children: tabs.map((item) {
                        return NestedScrollView(
                            headerSliverBuilder: (context, _v) {
                              return [
                                SliverToBoxAdapter(
                                  child: SizedBox(height: 0),
                                ),
                              ];
                            },
                            body: CGRankList(
                                tab: item['tab'], type: item['type']));
                      }).toList(),
                    ))
                  ],
                ),
        ));
  }
}
