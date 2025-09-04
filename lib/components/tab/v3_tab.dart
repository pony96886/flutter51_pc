import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TabNavDian extends StatelessWidget {
  final List? tabs;
  final TabController? tabController; // 控制器
  final int? selectedTabIndex; // 当前选项卡下标
  final String? leftTitle;
  final bool? tabState;
  final String? rightTitle;
  final int? leftWidth;
  final int? rightWidth;
  final GestureTapCallback? leftTap;
  final GestureTapCallback? rightTap;

  TabNavDian({
    Key? key,
    this.tabs,
    this.tabController,
    this.selectedTabIndex,
    this.leftTitle,
    this.rightTitle,
    this.leftWidth,
    this.rightWidth,
    this.leftTap,
    this.rightTap,
    this.tabState,
  }) : super(key: key);

  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      height: 50.w,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          TabBar(
            controller: tabController,
            isScrollable: true,
            indicatorColor: Colors.transparent,
            indicatorPadding: EdgeInsets.all(0),
            labelPadding: EdgeInsets.all(0),
            tabs: tabs!
                .asMap()
                .keys
                .map(
                  (key) => Tab(
                    child: Container(
                      color: Colors.transparent,
                      height: 50.w,
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.only(right: 30.w),
                      child: Stack(
                        children: <Widget>[
                          Text(tabs![key]['title'],
                              style: selectedTabIndex == key
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
                              child: selectedTabIndex == key
                                  ? Opacity(
                                      opacity: 0.8,
                                      child: Container(
                                        width: 14.w,
                                        height: 12.w,
                                        decoration: BoxDecoration(
                                            color: StyleTheme.cDangerColor,
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                      ),
                                    )
                                  : Text(' ')),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
      padding: EdgeInsets.only(left: 15.w),
    );
  }
}
