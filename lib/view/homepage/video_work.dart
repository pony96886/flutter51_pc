import 'package:chaguaner2023/components/cg_tabview.dart';
import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/list/public_list.dart';
import 'package:chaguaner2023/components/page_status.dart';
import 'package:chaguaner2023/components/pagetitlebar.dart';
import 'package:chaguaner2023/model/homedata.dart';
import 'package:chaguaner2023/store/homeConfig.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:chaguaner2023/utils/pageviewmixin.dart';
import 'package:chaguaner2023/view/yajian/tanhua.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class VideoWork extends StatefulWidget {
  const VideoWork({Key? key}) : super(key: key);

  @override
  State<VideoWork> createState() => _VideoWorkState();
}

class _VideoWorkState extends State<VideoWork> {
  bool loading = true;
  Map info = {};
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getProfilePage().then((res) {
      if (res!['status'] != 0) {
        info = res['data'];
        loading = false;
        setState(() {});
      } else {
        CommonUtils.showText(res['msg']);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Member members = Provider.of<HomeConfig>(context).member;
    return HeaderContainer(
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.transparent,
            appBar: PreferredSize(
                child: PageTitleBar(
                  title: '创作中心',
                  rightWidget: GestureDetector(
                    onTap: () {
                      context.push(CommonUtils.getRealHash('videoPublish'));
                    },
                    child: Text(
                      '发布',
                      style: TextStyle(
                          color: StyleTheme.cTitleColor, fontSize: 14.sp),
                    ),
                  ),
                ),
                preferredSize: Size(double.infinity, 44.w)),
            body: loading
                ? PageStatus.loading(true)
                : NestedScrollView(
                    headerSliverBuilder: (context, b) {
                      return [
                        SliverToBoxAdapter(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 15.w, vertical: 12.5.w),
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: AssetImage(
                                        'assets/images/mine/work_bg.png'))),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10.w),
                                      child: LocalPNG(
                                        width: 50.w,
                                        height: 50.w,
                                        url:
                                            'assets/images/common/${members.thumb}.png',
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10.5.w,
                                    ),
                                    Text(
                                      members.nickname!,
                                      style: TextStyle(
                                          fontSize: 18.sp,
                                          color: StyleTheme.cTitleColor),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 31.5.w,
                                ),
                                DefaultTextStyle(
                                    style: TextStyle(
                                        fontSize: 14.sp,
                                        color: StyleTheme.cTitleColor),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Column(
                                          children: [
                                            Text(
                                              '总收益',
                                            ),
                                            SizedBox(
                                              height: 11.5.w,
                                            ),
                                            Text(
                                                '${info['all_original_blogger_money'] ?? 0}'),
                                          ],
                                        ),
                                        Container(
                                          width: 0.5.w,
                                          height: 45.w,
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 64.5.w),
                                          color: Colors.black.withOpacity(0.2),
                                        ),
                                        Column(
                                          children: [
                                            Text(
                                              '当前余额',
                                            ),
                                            SizedBox(
                                              height: 11.5.w,
                                            ),
                                            Text(
                                                '${info['original_blogger_money' ?? 0]}'),
                                          ],
                                        )
                                      ],
                                    )),
                                SizedBox(
                                  height: 30.w,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    AppGlobal.appRouter?.push(
                                        CommonUtils.getRealHash(
                                            'withdrawPage/1'));
                                  },
                                  child: Container(
                                    width: 275.w,
                                    height: 50.w,
                                    margin: EdgeInsets.only(
                                        bottom: ScreenUtil().bottomBarHeight +
                                            15.w),
                                    child: Stack(
                                      children: [
                                        LocalPNG(
                                          width: double.infinity,
                                          height: 50.w,
                                          url:
                                              "assets/images/mine/black_button.png",
                                        ),
                                        Center(
                                            child: Text("立即提现",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 15.sp))),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: members.isOriginalBlogger == 0
                              ? Column(
                                  children: [
                                    Container(
                                      height: 52.5.w,
                                      width: 329.4.w,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 14.5.w),
                                      decoration: BoxDecoration(
                                          image: DecorationImage(
                                              fit: BoxFit.fill,
                                              image: AssetImage(
                                                  'assets/images/mine/work_bgb.png'))),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          DefaultTextStyle(
                                              style: TextStyle(
                                                  color: StyleTheme.cTitleColor,
                                                  fontSize: 14.sp),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text('认证博主发布视频'),
                                                  Text(
                                                      '可获得${info['original_certified_share'] ?? 0}%分成'),
                                                ],
                                              )),
                                          GestureDetector(
                                            onTap: () {
                                              context.push(
                                                  CommonUtils.getRealHash(
                                                      'upAuth'));
                                            },
                                            child: Container(
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                  color:
                                                      StyleTheme.cDangerColor,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.w)),
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 7.w),
                                              height: 30.w,
                                              child: Text(
                                                '立即认证',
                                                style: TextStyle(
                                                    color: Color(0XFFd9d9d9),
                                                    fontSize: 14.sp),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20.w,
                                    )
                                  ],
                                )
                              : SizedBox(),
                        )
                      ];
                    },
                    body: CgTabView(
                        padding: EdgeInsets.only(
                            bottom: 12.w, left: 15.w, right: 15.w),
                        isCenter: false,
                        spacing: 0,
                        isFlex: true,
                        type: CgTabType.redRaduis,
                        defaultStyle:
                            TextStyle(color: Color(0xff1e1e1e), fontSize: 14.w),
                        activeStyle:
                            TextStyle(color: Colors.white, fontSize: 14.w),
                        tabs: [
                          '已通过',
                          '待审核',
                          '未通过',
                        ],
                        pages: [
                          PageViewMixin(
                            child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12.w),
                                child: PublicList(
                                  cacheExtent: 5.sh,
                                  api: '/api/mv/list_my',
                                  data: {"cate": 'pass'},
                                  isShow: true,
                                  isSliver: true,
                                  nullText: '还没有资源哦～',
                                  row: 2,
                                  aspectRatio: 1.3,
                                  mainAxisSpacing: 10,
                                  crossAxisSpacing: 10,
                                  itemBuild: (context, index, data, page, limit,
                                      getListData) {
                                    return TanhuaCard(
                                        item: data, isHideShow: true);
                                  },
                                )),
                          ),
                          PageViewMixin(
                            child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12.w),
                                child: PublicList(
                                  cacheExtent: 5.sh,
                                  api: '/api/mv/list_my',
                                  data: {"cate": 'wait'},
                                  isShow: true,
                                  isSliver: true,
                                  nullText: '还没有资源哦～',
                                  row: 2,
                                  aspectRatio: 1.3,
                                  mainAxisSpacing: 10,
                                  crossAxisSpacing: 10,
                                  itemBuild: (context, index, data, page, limit,
                                      getListData) {
                                    return TanhuaCard(
                                      item: data,
                                    );
                                  },
                                )),
                          ),
                          PageViewMixin(
                            child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12.w),
                                child: PublicList(
                                  cacheExtent: 5.sh,
                                  api: '/api/mv/list_my',
                                  data: {"cate": 'fail'},
                                  isShow: true,
                                  isSliver: true,
                                  nullText: '还没有资源哦～',
                                  row: 2,
                                  aspectRatio: 1.3,
                                  mainAxisSpacing: 10,
                                  crossAxisSpacing: 10,
                                  itemBuild: (context, index, data, page, limit,
                                      getListData) {
                                    return TanhuaCard(
                                      item: data,
                                    );
                                  },
                                )),
                          ),
                        ]))));
  }
}
