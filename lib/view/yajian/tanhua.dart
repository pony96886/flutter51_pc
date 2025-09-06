import 'package:chaguaner2023/components/cgDialog.dart';
import 'package:chaguaner2023/components/detail_ad.dart';
import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/list/public_list.dart';
import 'package:chaguaner2023/components/loading.dart';
import 'package:chaguaner2023/components/pagetitlebar.dart';
import 'package:chaguaner2023/components/tab/nav_tab_bar_mixin.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:chaguaner2023/utils/netimage_tool.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:extended_tabs/extended_tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/cache/image_net_tool.dart';

class TanhuaPage extends StatefulWidget {
  TanhuaPage({Key? key}) : super(key: key);

  @override
  _TanhuaPageState createState() => _TanhuaPageState();
}

class _TanhuaPageState extends State<TanhuaPage>
    with SingleTickerProviderStateMixin {
  List _banner = [];
  List? tanhuaList;
  bool networkErr = false;
  bool loading = true;
  TabController? tabController;
  ValueNotifier<dynamic> sort = ValueNotifier(null);
  bool isShow = false;
  List sortList = [];
  List tabs = [];
  initHeaderBanner() async {
    var result = await getDetail_ad(1101);
    if (result != null && result['status'] != 0) {
      _banner = result['data'];
      setState(() {});
    }
  }

  getTabList() {
    tanhuaNavList().then((res) {
      if (res!['status'] != 0) {
        tabs = res['data']['category'];
        sortList = res['data']['orderBy'];
        sort.value = sortList[0]['value'];
        tabController = TabController(vsync: this, length: tabs.length);
        loading = false;
        setState(() {});
      } else {
        CommonUtils.showText(res['msg']);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getTabList();
    initHeaderBanner();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    sort.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HeaderContainer(
      child: GestureDetector(
        onTap: () {
          if (isShow) {
            isShow = false;
            setState(() {});
          }
        },
        child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: PreferredSize(
                child: PageTitleBar(
                  title: '探花好片',
                ),
                preferredSize: Size(double.infinity, 44.w)),
            body: loading
                ? Loading()
                : ExtendedNestedScrollView(
                    headerSliverBuilder: (context, innerBoxIsScrolled) {
                      return [
                        SliverToBoxAdapter(
                          child: _banner.isEmpty
                              ? Container()
                              : Detail_ad(
                                  radius: 18.w,
                                  width: double.infinity,
                                  app_layout: true,
                                  data: _banner),
                        )
                      ];
                    },
                    body: Stack(children: [
                      Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                  child: NavTabBarWidget(
                                tabBarHeight: 44.0.w,
                                tabVc: tabController,
                                tabs: tabs
                                    .map((e) => e['title'] as String)
                                    .toList(),
                                // containerPadding: EdgeInsets.symmetric(horizontal: 70.w),
                                textPadding:
                                    EdgeInsets.symmetric(horizontal: 10.w),
                                selectedIndex: tabController!.index,
                                norTextStyle: TextStyle(
                                    color: StyleTheme.cTitleColor,
                                    fontSize: 15.sp),
                                selTextStyle: TextStyle(
                                    color: StyleTheme.cTitleColor,
                                    fontSize: 16.sp),
                                indicatorStyle: NavIndicatorStyle.sys_fixed,
                              )),
                              SizedBox(
                                width: 10.w,
                              ),
                              GestureDetector(
                                onTap: () {
                                  isShow = !isShow;
                                  setState(() {});
                                },
                                child: Row(
                                  children: [
                                    Text(
                                      '筛选',
                                      style: TextStyle(
                                          color: StyleTheme.cTitleColor,
                                          fontSize: 13.w),
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 12.w,
                              )
                            ],
                          ),
                          Expanded(
                              child: ExtendedTabBarView(
                                  controller: tabController,
                                  children: tabs.asMap().keys.map((e) {
                                    return Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 12.w),
                                      child: PublicList(
                                        cacheExtent: 5.sh,
                                        api: '/api/mv/getLIst',
                                        data: {
                                          "orderBy": sort.value,
                                          "categoryId": tabs[e]['value'],
                                        },
                                        isShow: true,
                                        isSliver: true,
                                        noRefresh: true,
                                        nullText: '还没有资源哦～',
                                        row: 2,
                                        aspectRatio: 1.3,
                                        mainAxisSpacing: 10,
                                        crossAxisSpacing: 10,
                                        itemBuild: (context, index, data, page,
                                            limit, getListData) {
                                          return TanhuaCard(
                                            item: data,
                                          );
                                        },
                                      ),
                                    );
                                  }).toList()))
                        ],
                      ),
                      AnimatedPositioned(
                          top: 35.w,
                          right: isShow ? 12.w : -1.sw,
                          duration: Duration(milliseconds: 300),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 5.w),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5.w),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black12,
                                      offset: Offset(0, 0.5.w),
                                      blurRadius: 2.5.w)
                                ]),
                            width: 71.w,
                            child: Column(
                              children: sortList.asMap().keys.map((e) {
                                return GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: () {
                                    sort.value = sortList[e]['value'];
                                    isShow = false;
                                    setState(() {});
                                  },
                                  child: ValueListenableBuilder(
                                    valueListenable: sort,
                                    builder: (context, value, child) {
                                      return Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          Positioned(
                                              top: 5.w,
                                              right: -2.5.w,
                                              child: value ==
                                                      sortList[e]['value']
                                                  ? Container(
                                                      width: 15.w,
                                                      height: 15.w,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    7.5.w),
                                                        color: Color.fromRGBO(
                                                            255, 65, 73, 1),
                                                      ),
                                                    )
                                                  : SizedBox()),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 5.w),
                                            child: Text(
                                              sortList[e]['title'],
                                              style: TextStyle(
                                                  color: StyleTheme.cTitleColor,
                                                  fontSize: 16.w),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                );
                              }).toList(),
                            ),
                          ))
                    ]))),
      ),
    );
  }
}

class TanhuaCard extends StatefulWidget {
  final Map? item;
  final bool? isHideShow;
  const TanhuaCard({Key? key, this.item, this.isHideShow = false})
      : super(key: key);

  @override
  State<TanhuaCard> createState() => _TanhuaCardState();
}

class _TanhuaCardState extends State<TanhuaCard> {
  Map itemInfo = {};
  freeTypeIcon(String text, Color color) {
    return Container(
      height: 15.w,
      width: 40.w,
      color: color,
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(color: Colors.white, fontSize: 10.sp),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    itemInfo = widget.item!;
  }

  Widget getFreeType() {
    Widget freeWidget = SizedBox();
    switch (widget.item!['isfree']) {
      case 0:
        freeWidget = freeTypeIcon('免费', Color(0xffd57434));
        break;
      case 1:
        freeWidget = freeTypeIcon('VIP', Color(0xffff4149));
        break;
      case 2:
        freeWidget = freeTypeIcon('元宝', Color(0xfffbb526));
        break;
      case 3:
        freeWidget = freeTypeIcon('原创', Color(0xffFF7300));
        break;
      case 4:
        freeWidget = freeTypeIcon('精品', Color(0xff3673F0));
        break;
      default:
        freeWidget = SizedBox();
    }
    return freeWidget;
  }

  mvShowHide() {
    hideShowMv(itemInfo['id']).then((res) {
      if (res!['status'] != 0) {
        itemInfo['status'] += 1;
        setState(() {});
      } else {
        CommonUtils.showText(res['msg']);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.item!['status'] == 3) {
          AppGlobal.appRouter?.push(CommonUtils.getRealHash(
              'tanhuaDetailPage/' + widget.item!['id'].toString()));
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6.w),
                  child: Container(
                    width: double.infinity,
                    height: CommonUtils.getWidth(192),
                    child: ImageNetTool(
                      url: widget.item!['thumb_cover'],
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                    right: CommonUtils.getWidth(10),
                    bottom: CommonUtils.getWidth(12),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Color.fromRGBO(0, 0, 0, 0.4),
                          borderRadius:
                              BorderRadius.circular(CommonUtils.getWidth(17))),
                      height: CommonUtils.getWidth(34),
                      padding: EdgeInsets.symmetric(
                          horizontal: CommonUtils.getWidth(8)),
                      child: Center(
                        child: Text(
                          CommonUtils.secondsToString(widget.item!['duration']),
                          style:
                              TextStyle(color: Colors.white, fontSize: 11.sp),
                        ),
                      ),
                    )),
                Positioned(top: 0, left: 12.5.w, child: getFreeType()),
                widget.isHideShow! && itemInfo['status'] == 3
                    ? Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            CgDialog.cgShowDialog(
                                context, '温馨提示', '是否下架该作品', ['取消', '确认'],
                                callBack: () {
                              mvShowHide();
                            });
                          },
                          child: Container(
                            height: 20.w,
                            width: 20.w,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: StyleTheme.cDangerColor,
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(5.w))),
                            child: LocalPNG(
                              url: 'assets/images/mine/ic_delete.png',
                              width: 11.3.w,
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        ))
                    : SizedBox(),
                widget.isHideShow! && itemInfo['status'] == 4
                    ? Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            CgDialog.cgShowDialog(
                                context,
                                '温馨提示',
                                '是否上架该作品,重新将会再次进入审核流程',
                                ['取消', '确认'], callBack: () {
                              mvShowHide();
                            });
                          },
                          child: Container(
                            height: 20.w,
                            width: 35.w,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: Color(0xff481fff),
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(5.w))),
                            child: Text(
                              '上架',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 10.sp),
                            ),
                          ),
                        ))
                    : SizedBox(),
              ],
            ),
          ),
          SizedBox(
            height: CommonUtils.getWidth(19),
          ),
          Text(
            widget.item!['title'] ?? '',
            style: TextStyle(color: Color(0xff333333), fontSize: 13.sp),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )
        ],
      ),
    );
  }
}
