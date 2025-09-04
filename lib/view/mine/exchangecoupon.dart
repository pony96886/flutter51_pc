import 'package:bot_toast/bot_toast.dart';
import 'package:chaguaner2023/store/global.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/loading.dart';
import 'package:chaguaner2023/components/networkErr.dart';
import 'package:chaguaner2023/components/pagetitlebar.dart';
import 'package:chaguaner2023/store/homeConfig.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/local_png.dart';

class ExchangeCoupon extends StatefulWidget {
  ExchangeCoupon({Key? key}) : super(key: key);

  @override
  State<ExchangeCoupon> createState() => _ExchangeCouponState();
}

class _ExchangeCouponState extends State<ExchangeCoupon> {
  bool loading = true;
  bool networkErr = false;
  List products = [];

  getList() {
    getCouponList().then((res) {
      if (res!['status'] != 0) {
        products = res['data'];
        loading = false;
        setState(() {});
      } else {
        setState(() {
          networkErr = true;
        });
        return;
      }
    });
  }

  onBuyCoupon(Map item) {
    onExChangeCoupon(id: item['id']).then((res) {
      if (res!['status'] != 0) {
        BotToast.showText(text: '兑换成功', align: Alignment(0, 0));
        _getNumInfo();
      } else {
        BotToast.showText(text: '兑换失败', align: Alignment(0, 0));
      }
    });
  }

  _getNumInfo() async {
    var _number = await getProfilePage();
    await getHomeConfig(context);
    Provider.of<GlobalState>(context, listen: false)
        .setProfile(_number!['data']);
    Provider.of<GlobalState>(context, listen: false)
        .setOltime(_number['data']['oltime']);
  }

  @override
  void initState() {
    super.initState();
    getList();
  }

  showPay(Map product) {
    print(product);
    return showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setBottomSheetState) {
            var coins =
                Provider.of<HomeConfig>(context, listen: false).member.coins;
            return Container(
                color: Colors.transparent,
                child: Container(
                    height: 300.w + ScreenUtil().bottomBarHeight,
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    child:
                        Stack(alignment: Alignment.center, children: <Widget>[
                      Padding(
                        padding:
                            EdgeInsets.only(top: 20.w, left: 15.w, right: 15.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              child: Text(
                                '兑换' + product['title'].toString(),
                                style: TextStyle(
                                    fontSize: 18.sp,
                                    color: StyleTheme.cTitleColor,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    LocalPNG(
                                      width: 40.w,
                                      height: 40.w,
                                      url:
                                          'assets/images/mine/wodetongqian.png',
                                      fit: BoxFit.contain,
                                    ),
                                    SizedBox(
                                      width: 11.w,
                                    ),
                                    Text.rich(TextSpan(
                                        text: product['exchange_price']
                                            .toString(),
                                        style: TextStyle(
                                            color: StyleTheme.cTitleColor,
                                            fontSize: 36.sp),
                                        children: [
                                          TextSpan(
                                            text: '铜钱',
                                            style: TextStyle(
                                                color: StyleTheme.cTitleColor,
                                                fontSize: 18.sp),
                                          )
                                        ])),
                                  ],
                                ),
                              ),
                            ),
                            BottomLine(),
                            Center(
                              child: GestureDetector(
                                onTap: () {
                                  if (double.parse(coins.toString()) <
                                      (double.parse(product['exchange_price']
                                          .toString()))) {
                                    AppGlobal.appRouter?.push(
                                        CommonUtils.getRealHash('ingotWallet'));
                                  } else {
                                    onBuyCoupon(product);
                                    Navigator.of(context).pop();
                                  }
                                },
                                child: Container(
                                  margin: EdgeInsets.only(bottom: 10.w),
                                  width: 275.w,
                                  height: 50.w,
                                  child: Stack(
                                    children: [
                                      LocalPNG(
                                        width: 275.w,
                                        height: 50.w,
                                        url:
                                            'assets/images/mymony/money-img.png',
                                      ),
                                      Center(
                                          child: Text(
                                        double.parse(coins.toString()) <
                                                (double.parse(
                                                    product['exchange_price']
                                                        .toString()))
                                            ? '铜钱不足，无法兑换'
                                            : '立即兑换',
                                        style: TextStyle(
                                            fontSize: 15.sp,
                                            color: Colors.white),
                                      )),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: LocalPNG(
                            url: "assets/images/nav/closemenu.png",
                            width: 30.w,
                            height: 30.w,
                          ),
                        ),
                      )
                    ])));
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return HeaderContainer(
        child: Scaffold(
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
          child: PageTitleBar(title: '兑换优惠券'),
          preferredSize: Size(double.infinity, 44.w)),
      body: networkErr
          ? NetworkErr(
              errorRetry: () {
                getList();
              },
            )
          : (loading
              ? Loading()
              : ListView(
                  children: <Widget>[
                    Center(
                      child: Wrap(
                        spacing: 15.w,
                        runSpacing: 15.w,
                        children: <Widget>[
                          for (var item in products) monyCart(item)
                        ],
                      ),
                    )
                  ],
                )),
    ));
  }

  Widget monyCart(Map item) {
    String promoPrice = item['exchange_price'].toString();
    return GestureDetector(
      onTap: () {
        showPay(item);
      },
      child: Column(
        children: [
          Container(
            height: 90.w,
            width: 169.w,
            child: Stack(
              children: [
                LocalPNG(
                  width: double.infinity,
                  height: 90.w,
                  url: 'assets/images/nigotwallet/coupon_bg.png',
                  fit: BoxFit.cover,
                ),
                Center(
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 10.w, horizontal: 40.w),
                    child: Text(
                      item['title'].toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Color(0xFF505050),
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 13.w),
          Container(
            width: 149.w,
            height: 50.w,
            child: Stack(
              children: [
                LocalPNG(
                  width: double.infinity,
                  height: 50.w,
                  url: 'assets/images/nigotwallet/coupon_button.png',
                  fit: BoxFit.cover,
                ),
                Center(
                  child: Text(
                    '$promoPrice铜币兑换',
                    style: TextStyle(color: Colors.white, fontSize: 14.sp),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class BottomLine extends StatelessWidget {
  const BottomLine({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(
        top: 10.w,
        bottom: 10.w,
      ),
      decoration: BoxDecoration(
        color: Color(0xFFEEEEEE),
        border: Border(
          top: BorderSide.none,
          left: BorderSide.none,
          right: BorderSide.none,
          bottom: BorderSide(width: 0.5, color: Color(0xFFEEEEEE)),
        ),
      ),
    );
  }
}
