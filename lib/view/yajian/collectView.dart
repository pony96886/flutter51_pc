import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:chaguaner2023/components/card/adoptCard.dart';
import 'package:chaguaner2023/components/card/elegantCard.dart';
import 'package:chaguaner2023/components/card/mallCard.dart';
import 'package:chaguaner2023/components/card/rezhengCard.dart';
import 'package:chaguaner2023/components/card/talkCard.dart';
import 'package:chaguaner2023/components/list/public_list.dart';
import 'package:chaguaner2023/utils/pageviewmixin.dart';
import 'package:chaguaner2023/view/homepage/nakedchat/nakedchat_card.dart';
import 'package:chaguaner2023/view/yajian/tanhua.dart';


class CollectView extends StatefulWidget {
  final String? aff;
  const CollectView({Key? key, this.aff}) : super(key: key);

  @override
  State<CollectView> createState() => _CollectViewState();
}

class _CollectViewState extends State<CollectView>
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Color(0xfff8f6f1),
          child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorPadding: EdgeInsets.all(0),
              labelPadding: const EdgeInsets.symmetric(horizontal: 10),
              indicatorColor: Colors.transparent,
              tabs: _tabs
                  .asMap()
                  .keys
                  .map((key) => CustomTabs(
                      tabIndex: _selectedTabIndex,
                      keyIndex: key,
                      title: _tabs[key]['title']))
                  .toList()),
        ),
        Expanded(
            child: TabBarView(controller: _tabController, children: [
          PageViewMixin(
              child: PublicList(
                  isShow: true,
                  limit: 30,
                  isFlow: true,
                  isSliver: false,
                  api: '/api/user/getFavoriteVipList',
                  data: {
                    'other_user_collect': 1
                  },
                  row: 2,
                  itemBuild: (context, index, data, page, limit, getListData) {
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
                  data: {
                    'other_user_collect': 1
                  },
                  row: 2,
                  itemBuild: (context, index, data, page, limit, getListData) {
                    return RenZhengCard(chapuData: data);
                  })),
          PageViewMixin(
              child: PublicList(
                  isShow: true,
                  limit: 20,
                  isSliver: false,
                  aspectRatio: 170.5 / 275.5,
                  api: '/api/product/my_favorite_list',
                  data: {
                    'other_user_collect': 1
                  },
                  row: 2,
                  itemBuild: (context, index, data, page, limit, getListData) {
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
                  data: {
                    'other_user_collect': 1
                  },
                  row: 2,
                  itemBuild: (context, index, data, page, limit, getListData) {
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
                data: {
                  'other_user_collect': 1
                },
                row: 2,
                aspectRatio: 0.74,
                mainAxisSpacing: 10.w,
                crossAxisSpacing: 5.w,
                itemBuild: (context, index, data, page, limit, getListData) {
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
                data: {
                  'other_user_collect': 1
                },
                row: 2,
                aspectRatio: 0.7,
                mainAxisSpacing: 7.w,
                crossAxisSpacing: 7.w,
                itemBuild: (context, index, data, page, limit, getListData) {
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
                data: {
                  'other_user_collect': 1
                },
                itemBuild: (context, index, data, page, limit, getListData) {
                  return TalkCard(
                    item: data,
                  );
                }),
          ),
        ]))
      ],
    );
  }
}

class CustomTabs extends StatelessWidget {
  final int? tabIndex;
  final int? keyIndex;
  final String? title;
  const CustomTabs({Key? key, this.tabIndex, this.keyIndex, this.title})
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
                url: 'assets/images/tabsitem.png',
                alignment: Alignment.center,
                fit: BoxFit.fitWidth,
                width: 45.w,
                height: tabIndex == keyIndex ? 9.w : 0,
              )),
          Text(
            '$title',
            style: TextStyle(
              color: StyleTheme.cTitleColor,
              fontSize: tabIndex == keyIndex ? 16.sp : 14.sp,
            ),
          )
        ],
      ),
    );
  }
}