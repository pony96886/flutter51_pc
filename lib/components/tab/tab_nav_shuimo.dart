import 'package:chaguaner2023/store/global.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class TabNavShuimo extends StatelessWidget {
  /* 选项卡设置
  List _tabs = [
    {
      'title': '最新',
      'activeWidth': GVScreenUtil.setWidth(110),
      'inActiveWidth': GVScreenUtil.setWidth(80),
    }
  ]; 
  */
  final Decoration? tabStyle;
  final List? tabs;
  final bool? bgColor;
  final double? tabWidth;
  final TabController? tabController; // 控制器
  final int? selectedTabIndex; // 当前选项卡下标
  final String? leftTitle;
  final bool? tabState;
  final bool? isWidget;
  final String? rightTitle;
  final int? leftWidth;
  final int? rightWidth;
  final GestureTapCallback? leftTap;
  final GestureTapCallback? rightTap;
  final bool isFilter;
  final bool? isBetween;

  TabNavShuimo({
    Key? key,
    this.tabStyle,
    this.tabs,
    this.tabController,
    this.selectedTabIndex,
    this.leftTitle,
    this.rightTitle,
    this.leftWidth,
    this.rightWidth,
    this.leftTap,
    this.rightTap,
    this.isWidget,
    this.tabState,
    this.isFilter = false,
    this.isBetween,
    this.tabWidth,
    this.bgColor,
  }) : super(key: key);

  double getTabWidth(key) {
    // 控制激活与非激活的宽度
    if (selectedTabIndex == key) {
      return tabs![key]['activeWidth'];
    } else {
      return tabs![key]['inActiveWidth'];
    }
  }

  Widget build(BuildContext context) {
    var isVip;
    var profileData = Provider.of<GlobalState>(context).profileData;
    if (["", null, false, 0].contains(profileData)) {
      isVip = 0;
    } else {
      isVip = profileData?['vip_level'];
    }

    String underlines = 'assets/images/tab-underline.png';
    String underlineLong = 'assets/images/tab-underline-long.png';

    String filters = 'assets/images/publish/filter.png';
    String unfilterS = 'assets/images/publish/unfilter.png';

    return PreferredSize(
        child: Container(
          height: 50.w,
          child: Row(
            mainAxisAlignment: isBetween != null
                ? MainAxisAlignment.spaceBetween
                : (isWidget == true
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start),
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Theme(
                data: ThemeData(
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  useMaterial3: false,
                ),
                child: Container(
                  alignment: Alignment.center,
                  child: TabBar(
                    controller: tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    padding: EdgeInsets.only(left: 15.w),
                    indicator: BoxDecoration(),
                    indicatorPadding: EdgeInsets.zero,
                    indicatorColor: Colors.transparent,
                    labelPadding: EdgeInsets.all(0),
                    tabs: isWidget == true
                        ? [
                            Tab(
                                child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  child: Center(
                                      child: Container(
                                    color: StyleTheme.bottomappbarColor,
                                    width: (leftWidth! + rightWidth! - 9).w,
                                    height: 35,
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          child: GestureDetector(
                                            onTap: () => {
                                              leftTap!(),
                                            },
                                            child: Container(
                                              width: leftWidth?.w,
                                              height: 35.w,
                                              child: Stack(
                                                children: [
                                                  tabState!
                                                      ? LocalPNG(
                                                          url:
                                                              'assets/images/mymony/money_tab_left.png',
                                                          width: leftWidth!.w,
                                                          height: 35.w,
                                                          fit: BoxFit.fitWidth,
                                                        )
                                                      : SizedBox(),
                                                  Center(
                                                    child: Text(
                                                      leftTitle!,
                                                      style: TextStyle(
                                                          color: tabState!
                                                              ? Colors.white
                                                              : StyleTheme
                                                                  .cTitleColor),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left: (leftWidth! - 9).w,
                                          child: GestureDetector(
                                            onTap: () => {
                                              rightTap!(),
                                            },
                                            child: Container(
                                              width: rightWidth!.w,
                                              height: 35.w,
                                              child: Stack(
                                                children: [
                                                  !tabState!
                                                      ? LocalPNG(
                                                          url:
                                                              'assets/images/mymony/money_tab_right.png',
                                                          width: rightWidth!.w,
                                                          height: 35.w,
                                                          fit: BoxFit.fitWidth,
                                                        )
                                                      : new SizedBox(),
                                                  Center(
                                                    child: Text(
                                                      rightTitle!,
                                                      style: TextStyle(
                                                          color: !tabState!
                                                              ? Colors.white
                                                              : StyleTheme
                                                                  .cTitleColor),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  )),
                                )
                              ],
                            )),
                            Tab(child: Text(''))
                          ]
                        : tabs!
                            .asMap()
                            .keys
                            .map(
                              (key) => Tab(
                                child: tabWidth == null
                                    ? Stack(
                                        children: <Widget>[
                                          Positioned(
                                              bottom: 9.w,
                                              child: selectedTabIndex == key
                                                  ? LocalPNG(
                                                      url: tabs![key]['title']
                                                                  .length <=
                                                              3
                                                          ? underlines
                                                          : underlineLong,
                                                      fit: BoxFit.fitHeight,
                                                      height: 9.w,
                                                    )
                                                  : Text(' ')),
                                          Container(
                                              width: getTabWidth(key),
                                              height: 50.w,
                                              alignment: Alignment.centerLeft,
                                              margin:
                                                  EdgeInsets.only(left: 3.w),
                                              child: Text(tabs![key]['title'],
                                                  style: selectedTabIndex == key
                                                      ? TextStyle(
                                                          color: StyleTheme
                                                              .cTitleColor,
                                                          fontSize: 18.sp,
                                                          fontWeight:
                                                              FontWeight.w700)
                                                      : TextStyle(
                                                          color: StyleTheme
                                                              .cTitleColor,
                                                          fontSize: 14.sp))),
                                        ],
                                      )
                                    : Container(
                                        width: tabWidth,
                                        child: Stack(
                                          clipBehavior: Clip.none,
                                          alignment:
                                              AlignmentDirectional.center,
                                          children: <Widget>[
                                            tabStyle == null
                                                ? Positioned(
                                                    bottom: 0,
                                                    child:
                                                        selectedTabIndex == key
                                                            ? LocalPNG(
                                                                url: tabs![key]['title']
                                                                            .length <=
                                                                        3
                                                                    ? underlines
                                                                    : underlineLong,
                                                                fit: BoxFit
                                                                    .fitHeight,
                                                                height: 9.w,
                                                              )
                                                            : Text(' '))
                                                : Container(),
                                            Container(
                                                width: double.infinity,
                                                height: tabStyle != null
                                                    ? 25.w
                                                    : null,
                                                decoration:
                                                    selectedTabIndex == key
                                                        ? tabStyle
                                                        : BoxDecoration(),
                                                padding: tabStyle != null
                                                    ? EdgeInsets.symmetric(
                                                        horizontal: 13.5.w,
                                                        vertical: 2.5.w)
                                                    : null,
                                                child: Stack(
                                                    clipBehavior: Clip.none,
                                                    alignment:
                                                        AlignmentDirectional
                                                            .center,
                                                    children: [
                                                      // tabs![key]['num'] !=
                                                      //             null &&
                                                      //         tabs![key]
                                                      //                 ['num'] !=
                                                      //             0
                                                      //     ? Positioned(
                                                      //         top: -15.w,
                                                      //         left: 20.w,
                                                      //         child: Container(
                                                      //             child: Text(
                                                      //           tabs![key]
                                                      //                   ['num']
                                                      //               .toString(),
                                                      //           style: TextStyle(
                                                      //               fontSize:
                                                      //                   12.sp,
                                                      //               color: Color(
                                                      //                   0xff000000)),
                                                      //         )))
                                                      //     : Container(),
                                                      Text(
                                                          tabs![key]['num'] != null &&
                                                                  tabs![key]['num'] !=
                                                                      0
                                                              ? '${tabs![key]['title']}(${tabs![key]['num']})'
                                                              : tabs![key]
                                                                  ['title'],
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: selectedTabIndex == key &&
                                                                  tabStyle ==
                                                                      null
                                                              ? TextStyle(
                                                                  color: StyleTheme
                                                                      .cTitleColor,
                                                                  fontSize:
                                                                      18.sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700)
                                                              : TextStyle(
                                                                  color: selectedTabIndex == key
                                                                      ? Colors
                                                                          .white
                                                                      : StyleTheme
                                                                          .cTitleColor,
                                                                  fontSize: 14.sp,
                                                                  height: 1.3))
                                                    ])),
                                          ],
                                        ),
                                      ),
                              ),
                            )
                            .toList(),
                  ),
                ),
              ),
            ],
          ),
          // padding: EdgeInsets.only(left: 15.w),
          color: bgColor == null ? Colors.white : Colors.transparent,
        ),
        preferredSize: Size(double.infinity, 48.w));
  }
}
