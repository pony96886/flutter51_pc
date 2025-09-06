import 'package:card_swiper/card_swiper.dart';
import 'package:chaguaner2023/components/cgDialog.dart';
import 'package:chaguaner2023/components/page_status.dart';
import 'package:chaguaner2023/components/pagetitlebar.dart';
import 'package:chaguaner2023/mixins/pay_mixin.dart';
import 'package:chaguaner2023/store/homeConfig.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:chaguaner2023/utils/netimage_tool.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';

import '../utils/cache/image_net_tool.dart';

class NewMemberPage extends StatefulWidget {
  const NewMemberPage({Key? key}) : super(key: key);

  @override
  State<NewMemberPage> createState() => _NewMemberPageState();
}

class _NewMemberPageState extends State<NewMemberPage> with PayMixin {
  bool loading = true;
  List productList = [];
  bool? vipUpgrade = false;
  Map myCard = {};
  ValueNotifier<int> currentIndex = ValueNotifier(0);
  getProducList() {
    if (vipUpgrade!) {
      getProductUpgrade().then((res) {
        if (res!['status'] != 0) {
          productList = res['data']['products'];
          myCard = res['data']['my_card'];
          loading = false;
          setState(() {});
        } else {
          CommonUtils.showText(res['msg']);
        }
      });
    } else {
      getProductListOfCard(1).then((res) {
        if (res!['status'] != 0) {
          productList = res['data']['product'];
          loading = false;
          setState(() {});
        } else {
          CommonUtils.showText(res['msg']);
        }
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    vipUpgrade =
        Provider.of<HomeConfig>(context, listen: false).member.vipUpgrade;
    getProducList();
  }

  @override
  Widget build(BuildContext context) {
    String rechargeTips = Provider.of<HomeConfig>(context).rechargeTips;
    dynamic money = Provider.of<HomeConfig>(context).member.money;

    return Scaffold(
      body: Stack(
        children: [
          LocalPNG(
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.fill,
            url: 'assets/images/member_bg.png',
          ),
          Column(
            children: [
              PageTitleBar(
                title: 'VIP充值',
                rightWidget: GestureDetector(
                  onTap: () {
                    AppGlobal.appRouter
                        ?.push(CommonUtils.getRealHash('rechargeRecord/1'));
                  },
                  child: Center(
                    child: Container(
                        margin: new EdgeInsets.only(left: 3.w, right: 15.w),
                        child: Text(
                          '订单记录',
                          style: TextStyle(
                              color: StyleTheme.cTitleColor,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w500),
                        )),
                  ),
                ),
              ),
              rechargeTips.isEmpty
                  ? SizedBox()
                  : Container(
                      height: 32.w,
                      color: Color.fromRGBO(86, 52, 53, 0.5),
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.symmetric(horizontal: 12.5.w),
                      child: Row(
                        children: [
                          LocalPNG(
                            width: 18.w,
                            height: 14.w,
                            fit: BoxFit.fill,
                            url: 'assets/images/member_notices_ic.png',
                          ),
                          SizedBox(
                            width: 3.w,
                          ),
                          Expanded(
                              child: new Marquee(
                            text: rechargeTips,
                            style: new TextStyle(
                                color: Color(0xFFf3f3f4), fontSize: 11.sp),
                            scrollAxis: Axis.horizontal,
                          ))
                        ],
                      ),
                    ),
              Expanded(
                  child: loading
                      ? PageStatus.loading(true)
                      : ListView(
                          padding: EdgeInsets.symmetric(
                              vertical: 16.w, horizontal: 0),
                          children: [
                            vipUpgrade!
                                ? Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 15.w, vertical: 14.w),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '当前会员: ${myCard['pname']}',
                                          style: TextStyle(
                                              color: StyleTheme.cTitleColor,
                                              fontSize: 18.sp),
                                        ),
                                        Container(
                                          width: 315.5.w,
                                          height: 150.w,
                                          margin: EdgeInsets.only(
                                              top: 17.w, bottom: 28.w),
                                          child: ImageNetTool(
                                            url: myCard['bg_url'],
                                          ),
                                        ),
                                        Text(
                                          '可升级至',
                                          style: TextStyle(
                                              color: StyleTheme.cTitleColor,
                                              fontSize: 18.sp),
                                        ),
                                      ],
                                    ),
                                  )
                                : SizedBox(),
                            SizedBox(
                              height: 150.w,
                              child: Swiper(
                                itemBuilder: (BuildContext context, int index) {
                                  return Container(
                                    width: 342.w,
                                    alignment: Alignment.centerLeft,
                                    padding: EdgeInsets.only(right: 26.5.w),
                                    child: ImageNetTool(
                                        url: productList[index]['bg_url'],
                                        fit: BoxFit.fill),
                                  );
                                },
                                loop: true,
                                itemCount: productList.length,
                                onIndexChanged: (int index) {
                                  currentIndex.value = index;
                                },
                                viewportFraction: 0.85,
                                scale: 1,
                              ),
                            ),
                            ValueListenableBuilder(
                                valueListenable: currentIndex,
                                builder: (context, int? index, Widget? child) {
                                  return productList[index!]['description']
                                          .isEmpty
                                      ? SizedBox()
                                      : Padding(
                                          padding: EdgeInsets.only(
                                              left: 42.5.w,
                                              right: 42.5.w,
                                              top: 12.w),
                                          child: Text(
                                            productList[index]['description'],
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 12.sp,
                                                color: Color(0xff0e0e0e)),
                                          ),
                                        );
                                }),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 28.5.w, vertical: 16.5.w),
                              child: Column(
                                children: [
                                  LocalPNG(
                                    url: 'assets/images/member_title.png',
                                    width: 120.5.w,
                                    height: 32.5.w,
                                  ),
                                  SizedBox(
                                    height: 20.w,
                                  ),
                                  ValueListenableBuilder(
                                    valueListenable: currentIndex,
                                    builder: (context, int i, child) {
                                      List right =
                                          productList[i]['right'] ?? [];
                                      return GridView.builder(
                                          itemCount: right.length,
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          padding: EdgeInsets.zero,
                                          gridDelegate:
                                              SliverGridDelegateWithFixedCrossAxisCount(
                                                  childAspectRatio: 0.8,
                                                  crossAxisCount: 3,
                                                  mainAxisSpacing: 15.5.w,
                                                  crossAxisSpacing: 20.5.w),
                                          itemBuilder: (context, index) {
                                            return Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  width: 46.w,
                                                  height: 39.w,
                                                  child: ImageNetTool(
                                                    url: right[index]
                                                            ['img_url'] ??
                                                        '',
                                                    fit: BoxFit.fill,
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 9.w),
                                                  child: Text(
                                                    right[index]['name']
                                                        .toString(),
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xff0e0e0e),
                                                        fontSize: 14.sp,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                                Text(
                                                    right[index]['desc']
                                                        .toString(),
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Color(0xff666666),
                                                      fontSize: 11.sp,
                                                    )),
                                              ],
                                            );
                                          });
                                    },
                                  )
                                ],
                              ),
                            )
                          ],
                        )),
              SizedBox(
                height: 10.w,
              ),
              loading
                  ? SizedBox()
                  : ValueListenableBuilder(
                      valueListenable: currentIndex,
                      builder: (context, int value, child) {
                        return GestureDetector(
                          onTap: () {
                            if (vipUpgrade!) {
                              if (money <
                                  double.parse(
                                      '${productList[value]['upgrade_price']}')) {
                                CgDialog.cgShowDialog(
                                    context,
                                    '温馨提示',
                                    '元宝金额不足，是否立即充值',
                                    ['取消', '立即充值'], callBack: () {
                                  AppGlobal.appRouter?.push(
                                      CommonUtils.getRealHash('ingotWallet'));
                                });
                                return;
                              }
                              CgDialog.cgShowDialog(
                                  context, '温馨提示', '', ['取消', '确认'],
                                  contentWidget: Padding(
                                    padding: EdgeInsets.only(top: 15.w),
                                    child: Text.rich(
                                      TextSpan(children: [
                                        TextSpan(text: '是否确认话费'),
                                        TextSpan(
                                            text: productList[value]
                                                ['upgrade_price'],
                                            style: TextStyle(
                                                color:
                                                    StyleTheme.cDangerColor)),
                                        TextSpan(text: '元宝,升级至'),
                                        TextSpan(
                                            text: productList[value]['pname'],
                                            style: TextStyle(
                                                color:
                                                    StyleTheme.cDangerColor)),
                                        TextSpan(text: '会员？'),
                                      ]),
                                      style: TextStyle(
                                          color: StyleTheme.cTitleColor,
                                          fontSize: 15.sp),
                                    ),
                                  ), callBack: () {
                                vipUpgradePay(productList[value]['id'])
                                    .then((res) {
                                  if (res!['status'] != 0) {
                                    CgDialog.cgShowDialog(
                                        context, '升级成功', '', ['确定'],
                                        contentWidget: Padding(
                                          padding: EdgeInsets.only(top: 15.w),
                                          child: Text.rich(
                                            TextSpan(children: [
                                              TextSpan(text: '恭喜你，已升级至'),
                                              TextSpan(
                                                  text: productList[value]
                                                      ['pname'],
                                                  style: TextStyle(
                                                      color: StyleTheme
                                                          .cDangerColor)),
                                              TextSpan(text: '，赶快体验吧！'),
                                            ]),
                                            style: TextStyle(
                                                color: StyleTheme.cTitleColor,
                                                fontSize: 15.sp),
                                          ),
                                        ));
                                  } else {
                                    CommonUtils.showText(res['msg']);
                                  }
                                });
                              });
                            } else {
                              showPay(productList[value]);
                            }
                          },
                          child: Container(
                            margin: EdgeInsets.only(top: 50.w),
                            width: 275.w,
                            height: 50.w,
                            child: Stack(
                              children: [
                                LocalPNG(
                                  url:
                                      'assets/images/elegantroom/shuimo_btn.png',
                                  fit: BoxFit.contain,
                                  width: 275.w,
                                  height: 50.w,
                                ),
                                Center(
                                  child: Text(
                                    vipUpgrade!
                                        ? '立即购买(补差价${double.parse('${productList[value]['upgrade_price']}')}元宝)'
                                        : '立即购买',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 15.sp),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
              SizedBox(
                height: ScreenUtil().bottomBarHeight + 10.w,
              )
            ],
          )
        ],
      ),
    );
  }
}
