import 'package:chaguaner2023/components/card/adoptCard.dart';
import 'package:chaguaner2023/components/loading.dart';
import 'package:chaguaner2023/components/nodata.dart';
import 'package:chaguaner2023/components/page_status.dart';
import 'package:chaguaner2023/components/page_title_bar.dart';
import 'package:chaguaner2023/components/pullrefreshlist.dart';
import 'package:chaguaner2023/store/homeConfig.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:flutter/material.dart';

import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class AdoptScreen extends StatefulWidget {
  const AdoptScreen({Key? key}) : super(key: key);

  @override
  State<AdoptScreen> createState() => _AdoptScreenState();
}

class _AdoptScreenState extends State<AdoptScreen> with TickerProviderStateMixin {
  bool loading = true;
  bool listLoading = true;
  bool isload = false;
  bool isAll = false;
  int priceIndex = 0;
  int orderIndex = 0;
  int page = 1;
  int limit = 15;
  Map<dynamic, dynamic> filterTabs = {};
  List<dynamic> adoptList = [];

  _getAdoptTabsList() async {
    var result = await getAdoptPreList();
    print(result);
    if (result!['status'] == 1) {
      filterTabs = result['data'];
      loading = false;
      setState(() {});
      _filterAdoptList();
    } else {
      Navigator.of(context).pop();
      CommonUtils.showText('请求错误，请稍后重试');
    }
  }

  _filterAdoptList() async {
    String orderValue = filterTabs['order'][orderIndex]['value'];
    String priceValue = filterTabs['girl_price'][priceIndex]['value'] ?? "";
    var result = await getAdoptList(page, limit, orderValue, priceValue);
    if (result == null) {
      setState(() {
        adoptList = [];
        isAll = true;
        listLoading = false;
        isload = false;
      });
      return;
    }
    if (page == 1 && result["data"] != null && result["data"] is List) {
      adoptList = result["data"];
    } else {
      if (result["data"] is List && result["data"].length > 0) {
        adoptList.addAll(result["data"] ?? []);
      } else {
        isAll = true;
      }
    }
    listLoading = false;
    isload = false;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _getAdoptTabsList();
  }

  @override
  void dispose() {
    super.dispose();
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
                    AppGlobal.appRouter?.push(CommonUtils.getRealHash('searchResult'), extra: {'index': 8});
                  },
                  child: Padding(
                    padding: EdgeInsets.only(left: 15.w),
                    child: LocalPNG(
                      url: "assets/images/home/searchicon.png",
                      width: 25.w,
                      height: 25.w,
                    ),
                  ),
                ),
              ),
              preferredSize: Size(double.infinity, 44.w)),
          body: loading
              ? Loading()
              : Column(children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15.w),
                    child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 15.w),
                        width: 1.sw - 30.w,
                        margin: EdgeInsets.only(bottom: 10.w, top: 10.w),
                        height: 70.w,
                        color: Color(0xfff8f6f1),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: {
                              'girl_price': priceIndex,
                              'order': orderIndex,
                            }
                                .entries
                                .map((entry) => Column(
                                      children: [
                                        SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: TabsContainer(
                                            tabs: entry.key == 'order'
                                                ? List<Map<String, dynamic>>.from(filterTabs[entry.key])
                                                : filterTabs[entry.key],
                                            selectTabIndex: entry.value,
                                            onTabs: (int index) {
                                              setState(() {
                                                if (entry.key == 'girl_price') {
                                                  priceIndex = index;
                                                } else {
                                                  orderIndex = index;
                                                }
                                                listLoading = true;
                                                page = 1;
                                              });
                                              _filterAdoptList();
                                            },
                                          ),
                                        ),
                                        if (entry.key == 'girl_price') SizedBox(height: 10.w),
                                      ],
                                    ))
                                .toList())),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15.w),
                      child: PullRefreshList(
                          isAll: isAll,
                          onRefresh: () {
                            setState(() {
                              priceIndex = 0;
                              orderIndex = 0;
                              page = 1;
                              listLoading = true;
                              adoptList = [];
                            });
                            _filterAdoptList();
                          },
                          onLoading: () {
                            if (isload || loading) {
                              return;
                            }
                            isload = true;
                            page++;
                            _filterAdoptList();
                          },
                          child: CustomScrollView(physics: ClampingScrollPhysics(), cacheExtent: 3.h, slivers: [
                            listLoading
                                ? SliverToBoxAdapter(
                                    child: PageStatus.loading(true),
                                  )
                                : (adoptList.length == 0
                                    ? SliverToBoxAdapter(
                                        child: NoData(
                                        text: '没有数据啦～',
                                      ))
                                    : SliverGrid(
                                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          mainAxisSpacing: 7.w,
                                          crossAxisSpacing: 7.w,
                                          childAspectRatio: 0.7,
                                        ),
                                        delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
                                          return AdoptCard(adoptData: adoptList[index]);
                                        }, childCount: adoptList.length),
                                      ))
                          ])),
                    ),
                  )
                ]),
          floatingActionButton: Consumer<HomeConfig>(builder: (_, value, __) {
            return FloatingActionButton(
                backgroundColor: Colors.transparent,
                child: LocalPNG(
                  url: value.member.isKeepAuth == 1
                      ? "assets/images/adopt_manage.png"
                      : "assets/images/user_emplacement.png",
                  alignment: Alignment.center,
                  fit: BoxFit.contain,
                ),
                onPressed: () {
                  if (value.member.isKeepAuth == 1) {
                    AppGlobal.appRouter?.push(CommonUtils.getRealHash('adoptManageScreen'));
                  } else {
                    AppGlobal.appRouter?.push(CommonUtils.getRealHash('onlineServicePage'));
                  }
                });
          })),
    );
  }
}

class TabsContainer extends StatefulWidget {
  final List? tabs;
  final int? selectTabIndex;
  final Function? onTabs;
  final bool? needLimit;
  final int? filter;
  TabsContainer({Key? key, this.tabs, this.selectTabIndex, this.onTabs, this.needLimit = false, this.filter})
      : super(key: key);

  @override
  _TabsContainerState createState() => _TabsContainerState();
}

class _TabsContainerState extends State<TabsContainer> {
  int? index;

  @override
  void initState() {
    super.initState();
    index = widget.selectTabIndex;
  }

  onTapTabsItem(int e) {
    setState(() {
      index = e;
    });
    widget.onTabs!(e);
  }

  @override
  void didUpdateWidget(covariant TabsContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectTabIndex != index) {
      index = widget.selectTabIndex;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: widget.tabs!.asMap().keys.map((e) {
          return TabsItem(
            title: widget.tabs![e]['title'],
            index: index!,
            keys: e,
            onTap: () {
              onTapTabsItem(e);
            },
          );
        }).toList(),
      ),
    );
  }
}

class TabsItem extends StatelessWidget {
  final String? title;
  final int? index;
  final int? keys;
  final GestureTapCallback? onTap;
  TabsItem({Key? key, this.title, this.index, this.onTap, this.keys}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(right: 21.5.w),
        child: Stack(
          children: <Widget>[
            Positioned(
                top: 0,
                right: 0,
                child: index == keys
                    ? Opacity(
                        opacity: 0.8,
                        child: Container(
                          width: 12.w,
                          height: 12.w,
                          decoration:
                              BoxDecoration(color: StyleTheme.cDangerColor, borderRadius: BorderRadius.circular(10)),
                        ),
                      )
                    : SizedBox()),
            Text("$title",
                style: index == keys
                    ? TextStyle(color: Color(0xff646464), fontSize: 12.sp, fontWeight: FontWeight.w700)
                    : TextStyle(color: Color(0xff646464), fontSize: 12.sp)),
          ],
        ),
      ),
    );
  }
}
