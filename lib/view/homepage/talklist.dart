import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:chaguaner2023/components/tab/nav_tab_bar_mixin.dart';
import 'package:chaguaner2023/view/homepage/talk_list_page.dart';
import 'package:extended_tabs/extended_tabs.dart';
import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/loading.dart';
import 'package:chaguaner2023/components/page_title_bar.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/common.dart';

class TalkListPage extends StatefulWidget {
  const TalkListPage({Key? key}) : super(key: key);

  @override
  State<TalkListPage> createState() => _TalkListState();
}

class _TalkListState extends State<TalkListPage> with SingleTickerProviderStateMixin {
  List<Map> tabs = [];
  ValueNotifier<List> categoryList = ValueNotifier([]);
  TabController? tabController;
  bool loading = true;
  Map selectTab = {};

  @override
  void initState() {
    super.initState();
    getPrelist().then((res) {
      if (res!['status'] != 0 && res['data'] != null) {
        tabs = (res['data'] as List)
            .map((e) => {
                  ...e as Map,
                  'name': e['title'],
                }..remove('title'))
            .toList();
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
      appBar: PreferredSize(child: PageTitleBar(title: '茶老板日常尬谈'), preferredSize: Size(double.infinity, 44.w)),
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
                  norTextStyle: TextStyle(color: StyleTheme.cTitleColor, fontSize: 15.sp),
                  selTextStyle: TextStyle(color: StyleTheme.cTitleColor, fontSize: 16.sp),
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
                        body: TalkDataListPage(id: item['id']));
                  }).toList(),
                ))
              ],
            ),
    ));
  }
}
