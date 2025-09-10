import 'package:bot_toast/bot_toast.dart';
import 'package:chaguaner2023/components/citypickers/CommonCity_pickers.dart';
import 'package:chaguaner2023/components/datetime/src/date_format.dart';
import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/list/public_list.dart';
import 'package:chaguaner2023/components/loading.dart';
import 'package:chaguaner2023/components/nodata.dart';
import 'package:chaguaner2023/components/page_title_bar.dart';
import 'package:chaguaner2023/components/tab/nav_tab_bar_mixin.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:chaguaner2023/utils/netimage_tool.dart';
import 'package:extended_tabs/extended_tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../utils/cache/image_net_tool.dart';

class TeaBlackList extends StatefulWidget {
  TeaBlackList({Key? key}) : super(key: key);

  @override
  _TeaBlackListState createState() => _TeaBlackListState();
}

class _TeaBlackListState extends State<TeaBlackList> with SingleTickerProviderStateMixin {
  Map? blackType;
  bool loading = true;
  TabController? mangeController;
  String? cityName;
  String cityCode = '';
  List mangeTabs = ['普通用户', '鉴茶师'];
  setBlackType() async {
    await getBlackType().then((res) {
      if (res!['status'] != 0) {
        blackType = res['data'];
        loading = false;
        setState(() {});
      }
    });
  }

  @override
  void initState() {
    super.initState();
    mangeController = TabController(length: mangeTabs.length, vsync: this);
    setBlackType();
  }

  _showCityPickers(BuildContext context) async {
    final dynamic result =
        await Navigator.push(context, new MaterialPageRoute(builder: (context) => CommonCityPickers()));
    BotToast.showLoading();
    if (result != null) {
      setState(() {
        cityName = result.city;
      });
      var setAreaResult = await setArea(result.code);
      if (setAreaResult!['status'] == 1) {
        print(result.code);
        print(result.city);
        cityName = result.city;
        cityCode = result.code.toString();
        setState(() {});
        BotToast.showText(text: '切换城市成功，如信息和城市不匹配请[下拉刷新]', align: Alignment(0, 0), duration: Duration(seconds: 3));
        BotToast.closeAllLoading();
      }
    } else {
      BotToast.closeAllLoading();
    }
  }

  @override
  Widget build(BuildContext context) {
    // String cityCode = Provider.of<GlobalState>(context, listen: false).cityCode;
    return HeaderContainer(
        child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: PreferredSize(
              child: PageTitleBar(
                title: '茶馆黑榜',
                rightWidget: GestureDetector(
                  onTap: () {
                    AppGlobal.blackList = blackType!;
                    AppGlobal.appRouter?.push(CommonUtils.getRealHash('teaBlackPublish'));
                  },
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.only(right: 15.w),
                      child: Text(
                        '去曝光',
                        style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 15.sp, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ),
              ),
              preferredSize: Size(double.infinity, 44.w),
            ),
            body: loading
                ? Loading()
                : Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                                child: NavTabBarWidget(
                              tabBarHeight: 44.0.w,
                              tabVc: mangeController,
                              tabs: mangeTabs.map((e) => e as String).toList(),
                              textPadding: EdgeInsets.symmetric(horizontal: 12.5.w),
                              selectedIndex: mangeController!.index,
                              norTextStyle: TextStyle(color: StyleTheme.cTitleColor, fontSize: 14.sp),
                              selTextStyle: TextStyle(color: Colors.white, fontSize: 14.sp),
                              indicatorStyle: NavIndicatorStyle.cus_icon,
                              indicator: LineIndicator(
                                  isCenter: true, width: 75.w, height: 25.w, color: StyleTheme.cDangerColor),
                            )),
                            GestureDetector(
                              onTap: () async {
                                await _showCityPickers(context);
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  LocalPNG(
                                    url: 'assets/images/home/icon-location.png',
                                    height: 20.w,
                                    width: 20.w,
                                  ),
                                  SizedBox(
                                    width: 3.w,
                                  ),
                                  Text(
                                    cityName ?? '全部',
                                    style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 14.sp),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      Expanded(
                          child: ExtendedTabBarView(
                        controller: mangeController,
                        children: [
                          PublicList(
                              noData: NoData(
                                text: '该地区还没有黑榜呦～',
                              ),
                              isShow: true,
                              limit: 12,
                              isFlow: false,
                              isSliver: false,
                              api: '/api/black/getList',
                              data: {'cityCode': cityCode, 'cate': 0},
                              row: 1,
                              itemBuild: (context, index, data, page, limit, getListData) {
                                return BlackListCard(data: data, blackType: blackType!);
                              }),
                          PublicList(
                              noData: NoData(
                                text: '该地区还没有黑榜呦～',
                              ),
                              isShow: true,
                              limit: 12,
                              isFlow: false,
                              isSliver: false,
                              api: '/api/black/getList',
                              data: {'cityCode': cityCode, 'cate': 1},
                              row: 1,
                              itemBuild: (context, index, data, page, limit, getListData) {
                                return BlackListCard(data: data, blackType: blackType!);
                              }),
                        ],
                      ))
                    ],
                  )));
  }
}

class BlackListCard extends StatefulWidget {
  final Function? onTap;
  final Map? data;
  final Map? blackType;
  BlackListCard({Key? key, this.onTap, this.data, this.blackType}) : super(key: key);

  @override
  _BlackListCardState createState() => _BlackListCardState();
}

class _BlackListCardState extends State<BlackListCard> {
  bool lineNumber = true;
  String zhankai = "zhankai";
  String shouqi = "shouqi";
  String openZN = "展开";
  String closeZN = "收起";

  void handleSwitch() {
    setState(() {
      lineNumber = !lineNumber;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        CommonUtils.routerTo('teablackDetailPage/${widget.data!['id']}');
      },
      child: Container(
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
          width: 1.w,
          color: Colors.black12,
        ))),
        margin: EdgeInsets.only(
          top: 20.w,
        ),
        key: Key(widget.data!['id'].toString() + '_key'),
        padding: EdgeInsets.only(right: 15.w, left: 15.w, bottom: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 15.w),
              child: GestureDetector(
                onTap: () {
                  AppGlobal.appRouter?.push(CommonUtils.getRealHash('brokerHomepage/' +
                      widget.data!['aff'].toString() +
                      '/' +
                      Uri.encodeComponent(widget.data!['thumb'].toString()) +
                      '/' +
                      Uri.encodeComponent(widget.data!['nickname'].toString())));
                },
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(15.w)),
                      child: Container(
                        margin: new EdgeInsets.only(right: 9.5.w),
                        width: 30.w,
                        height: 30.w,
                        child: LocalPNG(url: 'assets/images/common/${widget.data!['thumb']}.png', fit: BoxFit.fill),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.data!['nickname'],
                            style: TextStyle(color: Color(0xFF1E1E1E), fontSize: 16.sp),
                          ),
                          SizedBox(
                            height: 4.5.w,
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              LocalPNG(
                                url: "assets/images/icon-black-loction.png",
                                width: 10.w,
                                height: 14.w,
                              ),
                              SizedBox(
                                width: 4.w,
                              ),
                              Text(
                                widget.data!['cityName'] ?? '未知',
                                style: TextStyle(color: StyleTheme.cTextColor, fontSize: 10.sp),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    Text(
                      widget.data!['created_at'],
                      style: TextStyle(color: Color(0xFFB4B4B4), fontSize: 12.sp),
                    ),
                  ],
                ),
              ),
            ),
            if (widget.data?["title"] != null && widget.data?["title"].isNotEmpty)
              Padding(
                padding: EdgeInsets.only(bottom: 12.5.w),
                child: Text(
                  "${widget.data?["title"]}",
                  style: TextStyle(color: StyleTheme.color50, fontSize: 18.sp, fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            Padding(
              padding: EdgeInsets.only(bottom: 11.w),
              child: Text(
                "${widget.data!['content']}",
                style: TextStyle(color: StyleTheme.color50, fontSize: 15.sp),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (widget.data!['resources'] != null && widget.data!['resources'].isNotEmpty)
              Container(
                margin: EdgeInsets.only(bottom: 10.w),
                child: GridView.builder(
                    itemCount: widget.data!['resources'].length >= 3 ? 3 : widget.data!['resources'].length,
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        childAspectRatio: 1, crossAxisCount: 3, mainAxisSpacing: 5.w, crossAxisSpacing: 5.w),
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(5.w),
                            child: Container(
                              width: 114.w,
                              height: 114.w,
                              child: ImageNetTool(
                                url: widget.data!['resources'][index]['url'],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          if (index == 2 && widget.data!['resources'].length > 3)
                            Positioned(
                                bottom: 6.w,
                                right: 6.w,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(7.5.w), color: Colors.black38),
                                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                                      alignment: Alignment.center,
                                      height: 15.w,
                                      child: Text(
                                        "+ ${widget.data!['resources'].length - 3}",
                                        style: TextStyle(color: Colors.white, fontSize: 12.sp),
                                      ),
                                    )
                                  ],
                                ))
                        ],
                      );
                      // GestureDetector(
                      //   onTap: () {
                      //     AppGlobal.picMap = {'resources': widget.data!['resources'], 'index': index};
                      //     context.push('/teaViewPicPage');
                      //   },
                      //   child:,
                      // );
                    }),
              ),
            Text(
              "${widget.data?["view_num"]}浏览",
              style: TextStyle(color: StyleTheme.color153, fontSize: 11.sp),
            )
          ],
        ),
      ),
    );
  }
}

class LineNumber extends StatelessWidget {
  const LineNumber({Key? key, this.value}) : super(key: key);
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 9.w,
      height: 6.w,
      margin: EdgeInsets.only(left: 5.5.w),
      child: LocalPNG(
        url: 'assets/images/card/$value.png',
        fit: BoxFit.cover,
      ),
    );
  }
}
