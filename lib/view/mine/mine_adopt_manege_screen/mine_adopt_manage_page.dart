import 'package:chaguaner2023/view/mine/mine_adopt_manege_screen/mine_adopt_my_order.dart';
import 'package:chaguaner2023/view/mine/mine_adopt_manege_screen/mine_adopt_order_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/page_title_bar.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/common.dart';

class MineAdoptManegeScreenPage extends StatefulWidget {
  MineAdoptManegeScreenPage({Key? key}) : super(key: key);

  @override
  _MineAdoptManegeScreenPageState createState() => _MineAdoptManegeScreenPageState();
}

class _MineAdoptManegeScreenPageState extends State<MineAdoptManegeScreenPage> with TickerProviderStateMixin {
  TabController? _tabController;
  List _tabs = [
    {'title': '信息管理'},
    {'title': '订单列表'}
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: _tabs.length);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController!.dispose();
  }

  Widget _buildTab(String text, bool selected) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: selected ? Colors.black : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: selected ? Colors.white : Colors.black,
          fontSize: 14.sp,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return HeaderContainer(
        child: Scaffold(
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        child: PageTitleBar(
          title: '包养',
          rightWidget: GestureDetector(
            onTap: () {
              AppGlobal.appRouter?.push(CommonUtils.getRealHash('adoptReleasePage'));
            },
            child: Text(
              '发布',
              style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 14.sp),
            ),
          ),
        ),
        preferredSize: Size(double.infinity, 44.w),
      ),
      body: Column(
        children: [
          Center(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: const BoxDecoration(),
                tabAlignment: TabAlignment.center,
                labelPadding: EdgeInsets.zero,
                tabs: List.generate(_tabs.length, (index) {
                  bool isSelected = _tabController!.index == index;
                  return _buildTab(_tabs[index]['title'], isSelected);
                }),
                onTap: (index) {
                  setState(() {});
                },
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [MineAdoptMyOrder(), MineAdoptOrderList()],
            ),
          )
        ],
      ),
    ));
  }
}
