import 'package:chaguaner2023/components/card/adoptCard.dart';
import 'package:chaguaner2023/components/card/elegantCard.dart';
import 'package:chaguaner2023/components/card/mallCard.dart';
import 'package:chaguaner2023/components/card/rezhengCard.dart';
import 'package:chaguaner2023/components/card/talkCard.dart';
import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/list/public_list.dart';
import 'package:chaguaner2023/components/pagetitlebar.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/pageviewmixin.dart';
import 'package:chaguaner2023/view/homepage/nakedchat/nakedchat_card.dart';
import 'package:chaguaner2023/view/mine/myteapost.dart';
import 'package:chaguaner2023/view/yajian/tanhua.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ElegantCollect extends StatefulWidget {
  ElegantCollect({Key? key}) : super(key: key);

  @override
  _ElegantCollectState createState() => _ElegantCollectState();
}

class _ElegantCollectState extends State<ElegantCollect>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  int _selectedTabIndex = 0;
  bool isPublic = false;
  List _tabs = [
    {
      'title': '雅间',
    },
    {
      'title': '茶女郎',
    },
    {
      'title': '商品',
    },
    {
      'title': '视频',
    },
    {
      'title': '裸聊',
    },
    {
      'title': '包养',
    },
    {
      'title': '茶谈',
    },
  ];
  @override
  void initState() {
    super.initState();
    isPublic = AppGlobal.switchFavoriteTab == 1 ? true : false;
    _tabController = TabController(vsync: this, length: _tabs.length);
    _tabController!.addListener(() {
      _selectedTabIndex = _tabController!.index;
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    _tabController!.dispose();
  }

  void setPublic(bool value) {
    isPublic = value;
    favoriteCollectToggle(value ? 1 : 0).then((value) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return HeaderContainer(
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.transparent,
          appBar: PreferredSize(
              child: PageTitleBar(
                title: '我的收藏',
                rightWidget:  PublicPrivacySwitch(
                  value: isPublic,
                  onChanged: (v) {
                    setPublic(v);
                    if (v) {
                      _tabController!.animateTo(0);
                    } else {
                      _tabController!.animateTo(1);
                    }
                  },
                  width: 60.w,
                  height: 27.w,
                ) ,
              ),
              preferredSize: Size(double.infinity, 44.w)),
          body: Column(
            children: [
              TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  indicatorPadding: EdgeInsets.all(0),
                  labelPadding: const EdgeInsets.symmetric(horizontal: 10),
                  indicatorColor: Colors.transparent,
                  tabs: _tabs
                      .asMap()
                      .keys
                      .map((key) => CustomTab(
                          tabIndex: _selectedTabIndex,
                          keyIndex: key,
                          title: _tabs[key]['title']))
                      .toList()),
              Expanded(
                  child: TabBarView(controller: _tabController, children: [
                PageViewMixin(
                    child: PublicList(
                        isShow: true,
                        limit: 30,
                        isFlow: true,
                        isSliver: false,
                        api: '/api/user/getFavoriteVipList',
                        data: {},
                        row: 2,
                        itemBuild:
                            (context, index, data, page, limit, getListData) {
                          return ElegantCard(
                            cardInfo: data,
                            isCollect: true,
                          );
                        })),
                PageViewMixin(
                    child: PublicList(
                        isShow: true,
                        limit: 20,
                        isSliver: false,
                        aspectRatio: 0.7,
                        api: '/api/goods/getFavoriteList',
                        data: {},
                        row: 2,
                        itemBuild:
                            (context, index, data, page, limit, getListData) {
                          return RenZhengCard(chapuData: data);
                        })),
                PageViewMixin(
                    child: PublicList(
                        isShow: true,
                        limit: 20,
                        isSliver: false,
                        aspectRatio: 170.5 / 275.5,
                        api: '/api/product/my_favorite_list',
                        data: {},
                        row: 2,
                        itemBuild:
                            (context, index, data, page, limit, getListData) {
                          return MallGirlCard(
                            data: data,
                          );
                        })),
                PageViewMixin(
                    child: PublicList(
                        isShow: true,
                        limit: 20,
                        isSliver: false,
                        aspectRatio: 1.3,
                        crossAxisSpacing: 10.w,
                        mainAxisSpacing: 10.w,
                        api: '/api/mv/my_favorite_list',
                        data: {},
                        row: 2,
                        itemBuild:
                            (context, index, data, page, limit, getListData) {
                          return TanhuaCard(
                            item: data,
                          );
                        })),
                PageViewMixin(
                  child: PublicList(
                      isShow: true,
                      limit: 30,
                      isFlow: false,
                      isSliver: false,
                      api: '/api/girlchat/favorite_list',
                      data: {},
                      row: 2,
                      aspectRatio: 0.74,
                      mainAxisSpacing: 10.w,
                      crossAxisSpacing: 5.w,
                      itemBuild:
                          (context, index, data, page, limit, getListData) {
                        return NakedchtCard(
                          data: data,
                        );
                      }),
                ),
                PageViewMixin(
                  child: PublicList(
                      isShow: true,
                      limit: 30,
                      isFlow: false,
                      isSliver: false,
                      api: '/api/keep/my_favorite',
                      data: {},
                      row: 2,
                      aspectRatio: 0.7,
                      mainAxisSpacing: 7.w,
                      crossAxisSpacing: 7.w,
                      itemBuild:
                          (context, index, data, page, limit, getListData) {
                        return AdoptCard(
                          adoptData: data,
                        );
                      }),
                ),
                PageViewMixin(
                  child: PublicList(
                      isShow: true,
                      limit: 30,
                      isFlow: false,
                      isSliver: false,
                      api: '/api/talk/my_favorite',
                      data: {},
                      itemBuild:
                          (context, index, data, page, limit, getListData) {
                        return TalkCard(
                          item: data,
                        );
                      }),
                ),
              ]))
            ],
          )),
    );
  }
}

class PublicPrivacySwitch extends StatelessWidget {
  const PublicPrivacySwitch({
    Key? key,
    required this.value,
    required this.onChanged,
    this.width = 100,
    this.height = 40,
    this.enabled = true,
  }) : super(key: key);

  final bool value;
  final ValueChanged<bool> onChanged;
  final double width;
  final double height;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final radius = height / 2;
    final bgColor = value ? Color(0xFF34C759) : Color(0xFF6b6b6b);

    return Opacity(
      opacity: enabled ? 1 : 0.6,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? () => onChanged(!value) : null,
        onHorizontalDragEnd: enabled
            ? (d) {
                onChanged(!value);
              }
            : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          width: width,
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(radius),
            boxShadow: [
              if (value)
                BoxShadow(
                  blurRadius: 12,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                  color: Colors.black.withOpacity(0.12),
                ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Opacity(
                    opacity: value ? 1 : 0,
                    child: Text(
                      '公开',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: value ? Colors.white : Colors.white70,
                      ),
                    ),
                  ),
                  Opacity(
                    opacity: !value ? 1 : 0,
                    child: Text(
                      '隐藏',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: !value ? Colors.white : Colors.white70,
                      ),
                    ),
                  ),
                ],
              ),
              AnimatedAlign(
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                child: Container(
                  width: height - 8,
                  height: height - 8,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(radius),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                        color: Colors.black.withOpacity(0.18),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
