import 'package:bot_toast/bot_toast.dart';
import 'package:chaguaner2023/components/card/elegantCard.dart';
import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/loading.dart';
import 'package:chaguaner2023/components/page_title_bar.dart';
import 'package:chaguaner2023/store/global.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/cgprivilege.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:chaguaner2023/utils/netimage_tool.dart';
import 'package:chaguaner2023/view/yajian/elegantPages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import '../../utils/cache/image_net_tool.dart';

class AuthBeautyPage extends StatefulWidget {
  AuthBeautyPage({Key? key}) : super(key: key);

  @override
  _AuthBeautyPageState createState() => _AuthBeautyPageState();
}

class _AuthBeautyPageState extends State<AuthBeautyPage> {
  int page = 1;
  int limit = 30;
  bool isAll = false;
  bool loading = true;
  bool loadmore = true;
  int _ruleListValue = 0;
  List authData = [];
  List headData = [];
  List ruleList = [
    {"name": "综合排序", "value": 1},
    {"name": "预约最多", "value": 2},
    {"name": "评价最高", "value": 3},
    {"name": "最新", "value": 4},
  ];
  getHeadAuthData() {
    var cityCode = Provider.of<GlobalState>(context, listen: false).cityCode;
    filterVipInfoByRule(
            page: 1, limit: 3, cityCode: cityCode != null ? cityCode.toString() : '110100', videoValid: '1', rule: '4')
        .then((res) {
      if (res!['status'] != 0) {
        List _data = res['data'] == null ? [] : res['data'];
        headData = _data.length > 3 ? _data.sublist(0, 3) : _data;
        setState(() {});
      } else {
        BotToast.showText(text: res['msg'], align: Alignment(0, 0));
      }
    });
  }

  getAuthData() {
    var cityCode = Provider.of<GlobalState>(context, listen: false).cityCode;
    filterVipInfoByRule(
            page: page,
            limit: limit,
            cityCode: cityCode != null ? cityCode.toString() : '110100',
            videoValid: '1',
            rule: ruleList[_ruleListValue]['value'].toString())
        .then((res) {
      if (res!['status'] != 0) {
        List _data = res['data'] == null ? [] : res['data'];
        if (page == 1) {
          authData = _data;
        } else {
          authData.addAll(_data);
        }
        loading = false;
        isAll = _data.length < limit;
        loadmore = true;
        setState(() {});
      } else {
        BotToast.showText(text: res['msg'], align: Alignment(0, 0));
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getHeadAuthData();
    getAuthData();
  }

  _onScrollNotification(ScrollNotification scrollInfo) {
    if (isAll) return false;
    if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
      //滑到了底部
      if (loadmore) {
        page++;
        loadmore = false;
        getAuthData();
      }
    }
    return false;
  }

  Future<bool?> showBuy(String title, String content, int type, [String? btnText]) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: CommonUtils.getWidth(560),
            padding: new EdgeInsets.symmetric(vertical: CommonUtils.getWidth(30), horizontal: CommonUtils.getWidth(50)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Center(
                      child: Text(
                        title,
                        style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 18.sp, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                        margin: new EdgeInsets.only(top: CommonUtils.getWidth(40)),
                        child: Text(
                          content,
                          style: TextStyle(fontSize: 14.sp, color: StyleTheme.cTitleColor),
                        )),
                    type == 0
                        ? GestureDetector(
                            onTap: () {
                              AppGlobal.appRouter?.push(CommonUtils.getRealHash('memberCardsPage'));
                            },
                            child: Container(
                              margin: new EdgeInsets.only(top: CommonUtils.getWidth(60)),
                              height: CommonUtils.getWidth(100),
                              width: CommonUtils.getWidth(400),
                              child: Stack(
                                children: [
                                  LocalPNG(
                                      height: CommonUtils.getWidth(100),
                                      width: CommonUtils.getWidth(400),
                                      url: 'assets/images/mymony/money-img.png',
                                      fit: BoxFit.fill),
                                  Center(
                                      child: Text(
                                    btnText ?? '去开通',
                                    style: TextStyle(fontSize: 15.sp, color: Colors.white),
                                  )),
                                ],
                              ),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                                child: Container(
                                  margin: new EdgeInsets.only(top: CommonUtils.getWidth(60)),
                                  height: CommonUtils.getWidth(100),
                                  width: CommonUtils.getWidth(220),
                                  child: Stack(
                                    children: [
                                      LocalPNG(
                                          height: CommonUtils.getWidth(100),
                                          width: CommonUtils.getWidth(220),
                                          url: 'assets/images/mymony/money-img.png',
                                          fit: BoxFit.fill),
                                      Center(
                                          child: Text(
                                        '取消',
                                        style: TextStyle(fontSize: 15.sp, color: Colors.white),
                                      )),
                                    ],
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pop(true);
                                },
                                child: Container(
                                  margin: new EdgeInsets.only(top: CommonUtils.getWidth(60)),
                                  height: CommonUtils.getWidth(100),
                                  width: CommonUtils.getWidth(220),
                                  child: Stack(
                                    children: [
                                      LocalPNG(
                                          height: CommonUtils.getWidth(100),
                                          width: CommonUtils.getWidth(220),
                                          url: 'assets/images/mymony/money-img.png',
                                          fit: BoxFit.fill),
                                      Center(
                                          child: Text(
                                        '确定',
                                        style: TextStyle(fontSize: 15.sp, color: Colors.white),
                                      )),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                  ],
                ),
                Positioned(
                  right: CommonUtils.getWidth(0),
                  top: CommonUtils.getWidth(0),
                  child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: LocalPNG(
                          width: CommonUtils.getWidth(60),
                          height: CommonUtils.getWidth(60),
                          url: 'assets/images/mymony/close.png',
                          fit: BoxFit.cover)),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var profileDatas = Provider.of<GlobalState>(context).profileData;
    // var agnet = Provider.of<HomeConfig>(context).member.agent;
    var vipLevel = profileDatas != null ? profileDatas['vip_level'] : 0;
    return HeaderContainer(
        child: Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          PreferredSize(
              child: PageTitleBar(
                title: '品茶意向',
              ),
              preferredSize: Size(double.infinity, 44.w)),
          Expanded(
              child: NotificationListener<ScrollNotification>(
            child: CustomScrollView(physics: ClampingScrollPhysics(), slivers: [
              headData.length == 0
                  ? SliverToBoxAdapter(
                      child: SizedBox(
                        height: 0,
                      ),
                    )
                  : SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: 15.w),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '新茶推荐',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xff1e1e1e), fontSize: 15.sp),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.w),
                              child: GridView(
                                physics: NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    childAspectRatio: 1.341,
                                    crossAxisCount: 3,
                                    mainAxisSpacing: 8.w,
                                    crossAxisSpacing: 8.w),
                                children: headData
                                    .asMap()
                                    .keys
                                    .map((e) => GestureDetector(
                                          onTap: () {
                                            if (headData[e]['status'] == 2) {
                                              var _id = headData[e]['info_id'] == null
                                                  ? headData[e]['id'].toString()
                                                  : headData[e]['info_id'].toString();
                                              if (CgPrivilege.getPrivilegeStatus(
                                                  PrivilegeType.infoVip, PrivilegeType.privilegeAppointment)) {
                                                AppGlobal.appRouter
                                                    ?.push(CommonUtils.getRealHash('vipDetailPage/' + _id + '/null/'));
                                              } else {
                                                showBuy('开通会员', '购买会员才能在线预约雅间妹子，平台担保交易，照片和人不匹配平台包赔，让你约到合乎心意的妹子', 0);
                                              }
                                            } else {
                                              BotToast.showText(text: '资源正在处理中,请稍后再试', align: Alignment(0, 0));
                                            }
                                          },
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(5),
                                            child: Container(
                                              width: CommonUtils.getWidth(220),
                                              height: CommonUtils.getWidth(164),
                                              child: Stack(
                                                children: [
                                                  ImageNetTool(
                                                    url: headData[e]['resources'][0]['url'] ?? '',
                                                    fit: BoxFit.cover,
                                                  ),
                                                  Positioned(
                                                      left: 0,
                                                      right: 0,
                                                      bottom: 0,
                                                      child: Container(
                                                        height: 48.5.w,
                                                        padding:
                                                            EdgeInsets.symmetric(vertical: 4.5.w, horizontal: 6.5.w),
                                                        decoration: BoxDecoration(
                                                            gradient: LinearGradient(
                                                          colors: [Colors.black54, Colors.transparent],
                                                          begin: Alignment.bottomCenter,
                                                          end: Alignment.topCenter,
                                                        )),
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          mainAxisSize: MainAxisSize.max,
                                                          mainAxisAlignment: MainAxisAlignment.end,
                                                          children: [
                                                            Text(
                                                              headData[e]['title'],
                                                              style: TextStyle(
                                                                color: Colors.white,
                                                                fontSize: 10.w,
                                                              ),
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                            Row(
                                                              mainAxisSize: MainAxisSize.min,
                                                              children: [
                                                                Container(
                                                                  margin: EdgeInsets.only(top: 3.5.w),
                                                                  padding: EdgeInsets.symmetric(
                                                                      horizontal: CommonUtils.getWidth(9)),
                                                                  height: 11.w,
                                                                  decoration: BoxDecoration(
                                                                      borderRadius: BorderRadius.circular(3),
                                                                      color: Color(0xffdbc1a0)),
                                                                  child: Center(
                                                                    child: Container(
                                                                        constraints: BoxConstraints(
                                                                            maxWidth: CommonUtils.getWidth(180)),
                                                                        child: Text(
                                                                          headData[e]['price_p'] == null
                                                                              ? '未设置价格'
                                                                              : headData[e]['price_p'].toString() + "元",
                                                                          style: TextStyle(
                                                                              fontSize: 7.sp, color: Colors.white),
                                                                          maxLines: 1,
                                                                          overflow: TextOverflow.ellipsis,
                                                                        )),
                                                                  ),
                                                                )
                                                              ],
                                                            )
                                                          ],
                                                        ),
                                                      )),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ))
                                    .toList(),
                              ),
                            )
                          ],
                        ),
                      )),
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 15.w),
                sliver: StatefulBuilder(builder: (context, setValue) {
                  return SliverToBoxAdapter(
                    child: Container(
                      padding: EdgeInsets.all(14.w),
                      decoration: BoxDecoration(color: Color(0xfff8f6f1), borderRadius: BorderRadius.circular(5.w)),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: RuleFilterTabs(
                          tabs: ruleList,
                          selectTabIndex: _ruleListValue,
                          onTabs: (e) {
                            _ruleListValue = e;
                            page = 1;
                            isAll = false;
                            loading = true;
                            setState(() {});
                            getAuthData();
                          },
                        ),
                      ),
                    ),
                  );
                }),
              ),
              loading
                  ? SliverToBoxAdapter(
                      child: Center(
                        child: Loading(),
                      ),
                    )
                  : (authData.length == 0
                      ? SliverToBoxAdapter(
                          child: Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(
                              vertical: 15.w,
                            ),
                            child: Text(
                              '本城市还没有认证美女～',
                              style: TextStyle(fontSize: 14.sp, color: Color(0xffb4b4b4)),
                            ),
                          ),
                        )
                      : SliverPadding(
                          padding: EdgeInsets.only(
                            top: CommonUtils.getWidth(30),
                            left: CommonUtils.getWidth(30),
                            right: CommonUtils.getWidth(30),
                            bottom: CommonUtils.getWidth(60),
                          ),
                          sliver: SliverWaterfallFlow(
                            gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: CommonUtils.getWidth(10),
                              crossAxisSpacing: CommonUtils.getWidth(10),
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (BuildContext c, int index) {
                                return ElegantCard(
                                  cardInfo: authData[index],
                                  key: Key('keys_$index'),
                                  keys: index,
                                );
                              },
                              childCount: authData.length,
                            ),
                          )))
            ]),
            onNotification: (ScrollNotification scrollInfo) => _onScrollNotification(scrollInfo),
          ))
        ],
      ),
    ));
  }
}
