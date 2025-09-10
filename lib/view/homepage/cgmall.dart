import 'package:chaguaner2023/components/detail_ad.dart';
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
import 'package:extended_tabs/extended_tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class CgmallPage extends StatefulWidget {
  const CgmallPage({Key? key}) : super(key: key);

  @override
  State<CgmallPage> createState() => _CgmallPageState();
}

class _CgmallPageState extends State<CgmallPage> with SingleTickerProviderStateMixin {
  ValueNotifier<List> _banner = ValueNotifier([]);
  List<Map> tabs = [];
  ValueNotifier<List> categoryList = ValueNotifier([]);
  TabController? tabController;
  bool loading = true;
  Map selectTab = {};

  @override
  void initState() {
    super.initState();
    categoriesList().then((res) {
      print(res);
      print('_________');
      if (res!['status'] != 0) {
        tabs = (res!['data']['categories'] as List).map((e) => e as Map).toList();
        tabController = TabController(length: tabs.length, vsync: this);
        _banner.value = res!['data']['banner'];
        loading = false;
        setState(() {});
      } else {
        CommonUtils.showText(res['msg'] ?? '系统错误～');
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    categoryList.dispose();
    tabController!.dispose();
    _banner.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // var imPrivilege =
    //     Provider.of<HomeConfig>(context, listen: false).data['im_privilege'];
    return HeaderContainer(
        child: Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: PreferredSize(
              child: PageTitleBar(
                title: '茶馆商城',
                rightWidget: GestureDetector(
                  onTap: () {
                    AppGlobal.appRouter?.push(CommonUtils.getRealHash('searchResult'), extra: {'index': 7});
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
              : Column(
                  children: [
                    NavTabBarWidget(
                      tabBarHeight: 44.0.w,
                      tabVc: tabController,
                      tabs: tabs.map((e) => e['name'] as String).toList(),
                      // containerPadding: EdgeInsets.symmetric(horizontal: 70.w),
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
                                  child: ValueListenableBuilder(
                                      valueListenable: _banner,
                                      builder: (context, List<dynamic> value, child) {
                                        return value.length > 0
                                            ? RepaintBoundary(
                                                child: Container(
                                                margin: EdgeInsets.only(top: 5.w, left: 15.w, right: 15.w),
                                                child: Detail_ad(
                                                    radius: 18.w,
                                                    width: ScreenUtil().screenWidth - 30.w,
                                                    app_layout: true,
                                                    data: value),
                                              ))
                                            : SizedBox(height: 0);
                                      }),
                                ),
                              ];
                            },
                            body: CGmaillList(tags: item['tags'], orderBy: item['orderBy'], goodsType: item['id']));
                      }).toList(),
                    ))
                  ],
                ),
        ),
        Positioned(
            right: 25.5.w,
            bottom: 50.w + ScreenUtil().bottomBarHeight,
            child: GestureDetector(
              onTap: () {
                if (UserInfo.isMerchant! > 0) {
                  context.push(CommonUtils.getRealHash('merchantCenter'));
                } else {
                  AppGlobal.appRouter?.push(CommonUtils.getRealHash('onlineServicePage'));
                  // if (!CgPrivilege.getPrivilegeStatus(
                  //     PrivilegeType.infoSystem, PrivilegeType.privilegeIm)) {
                  //   CommonUtils.showVipDialog(
                  //       context,
                  //       PrivilegeType.infoSysteString +
                  //           PrivilegeType.privilegeImString);
                  //   return;
                  // }
                  // if (WebSocketUtility.imToken == null) {
                  //   CommonUtils.getImPath(context, callBack: () {
                  //     AppGlobal.chatUser = FormUserMsg(
                  //         isVipDetail: true,
                  //         uuid: UserInfo.manageUuid,
                  //         nickname: '茶管理',
                  //         avatar: 'chaxiaowai');
                  //     AppGlobal.appRouter
                  //         .push(CommonUtils.getRealHash('llchat'));
                  //   }, status: 1);
                  // } else {
                  //   AppGlobal.chatUser = FormUserMsg(
                  //       isVipDetail: true,
                  //       uuid: UserInfo.manageUuid,
                  //       nickname: '茶管理',
                  //       avatar: 'chaxiaowai');
                  //   AppGlobal.appRouter.push(CommonUtils.getRealHash('llchat'));
                  // }
                }
              },
              child: Image.asset(
                'assets/images/elegantroom/${UserInfo.isMerchant! > 0 ? 'join_mall' : 'add_mall'}.png',
                fit: BoxFit.fitWidth,
                width: 46.w,
              ),
            ))
      ],
    ));
  }
}
