import 'package:chaguaner2023/components/loading.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MinePopularizePage extends StatefulWidget {
  MinePopularizePage({Key? key}) : super(key: key);

  @override
  _MinePopularizePageState createState() => _MinePopularizePageState();
}

class _MinePopularizePageState extends State<MinePopularizePage> {
  bool isNullList = false;
  bool isLoadding = true;
  Map? proxyData;
  String selfchannelStr = "assets/images/popularize/selfchannel.png";
  String channelStr = "assets/images/popularize/channel.png";

  _onGetProxyData() async {
    var result = await getProxyNewInfo();
    if (result!['data'] != null) {
      setState(() {
        proxyData = result['data'];
        isLoadding = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    _onGetProxyData();
  }

  String proxyLevel() {
    String levelString = "普通代理";
    if (proxyData!['invite_vip_num'] == null) {
      return levelString;
    }
    if (proxyData!['invite_vip_num'] >= 400) {
      levelString = "钻石代理";
    } else if (proxyData!['invite_vip_num'] >= 100) {
      levelString = "铂金代理";
    } else if (proxyData!['invite_vip_num'] >= 50) {
      levelString = "黄金代理";
    } else if (proxyData!['invite_vip_num'] >= 20) {
      levelString = "白银代理";
    } else if (proxyData!['invite_vip_num'] >= 5) {
      levelString = "青铜代理";
    }
    return levelString;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFDC4F3F),
      body: isLoadding
          ? Loading()
          : Stack(
              children: <Widget>[
                SingleChildScrollView(
                  child: Column(
                    children: [
                      LocalPNG(
                        width: double.infinity,
                        height: 350.w,
                        url: selfchannelStr,
                      ),
                      Container(
                          transform: Matrix4.translationValues(0.0, -85.w, 0.0),
                          width: double.infinity,
                          padding: EdgeInsets.all(15.w),
                          child: Column(
                            children: [
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(vertical: 20.w, horizontal: 20.5.w),
                                decoration:
                                    BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10.0)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    RichText(
                                        text: TextSpan(
                                            text: "我的邀请 ",
                                            style: TextStyle(
                                                color: Color(0xFFDD5341), fontSize: 18.sp, fontWeight: FontWeight.w500),
                                            children: <TextSpan>[
                                          TextSpan(
                                              text: ' (以下收入将自动结算到铜钱/元宝钱包中)',
                                              style: TextStyle(
                                                  color: Color(0xFFDD5341),
                                                  fontSize: 12.sp,
                                                  fontWeight: FontWeight.w400))
                                        ])),
                                    Container(
                                        padding: EdgeInsets.symmetric(vertical: 30.w),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            PopularizeNumber(
                                              numbers: proxyData!['invited_num'].toString(),
                                              title: "成功邀请数",
                                            ),
                                            PopularizeNumber(
                                              numbers: proxyData!['money_num'].toString(),
                                              title: "元宝收益",
                                            ),
                                            PopularizeNumber(
                                              numbers: proxyData!['coin_num'].toString(),
                                              title: "铜钱收益",
                                            ),
                                            Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  proxyData!['agent_level'].toString(),
                                                  style: TextStyle(fontSize: 16.sp, color: Color(0xFF323232)),
                                                ),
                                                SizedBox(height: 10.w),
                                                Text(
                                                  "代理等级",
                                                  style: TextStyle(fontSize: 12.sp, color: Color(0xFFB4B4B4)),
                                                ),
                                              ],
                                            )
                                          ],
                                        )),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        PopularizeMenu(
                                          icon: "assets/images/popularize/detial.png",
                                          title: "收益明细",
                                          onTap: () {
                                            AppGlobal.appRouter?.push(CommonUtils.getRealHash('ingotsDetailPage'));
                                          },
                                        ),
                                        PopularizeMenu(
                                          icon: "assets/images/popularize/withdraw.png",
                                          title: "去提现",
                                          onTap: () {
                                            AppGlobal.appRouter?.push(CommonUtils.getRealHash('withdrawPage/0'));
                                          },
                                        ),
                                        PopularizeMenu(
                                          icon: "assets/images/popularize/record.png",
                                          title: "推广记录",
                                          onTap: () {
                                            AppGlobal.appRouter?.push(CommonUtils.getRealHash('promotionRecordPage'));
                                          },
                                        ),
                                        PopularizeMenu(
                                          icon: "assets/images/popularize/to_popu.png",
                                          title: "去推广",
                                          onTap: () {
                                            AppGlobal.appRouter?.push(CommonUtils.getRealHash('shareQRCodePage'));
                                          },
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 30.w, bottom: 20.w),
                                height: 23.w,
                                child: LocalPNG(
                                  url: "assets/images/popularize/mid_tips.png",
                                  height: 24.w,
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(bottom: 10.w),
                                height: 70.w,
                                child: LocalPNG(
                                  url: "assets/images/popularize/popularize1.png",
                                  height: 70.w,
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(bottom: 10.w),
                                height: 70.w,
                                child: LocalPNG(
                                  url: "assets/images/popularize/popularize2.png",
                                  height: 70.w,
                                ),
                              ),
                              Container(
                                  margin: EdgeInsets.only(bottom: 10.w),
                                  height: 70.w,
                                  child: LocalPNG(
                                    url: "assets/images/popularize/popularize3.png",
                                    height: 70.w,
                                  )),
                              Container(
                                  margin: EdgeInsets.only(bottom: 10.w),
                                  height: 70.w,
                                  child: LocalPNG(
                                    url: "assets/images/popularize/popularize4.png",
                                    height: 70.w,
                                  )),
                              Container(
                                  margin: EdgeInsets.only(bottom: 10.w),
                                  height: 70.w,
                                  child: LocalPNG(
                                    url: "assets/images/popularize/popularize5.png",
                                    height: 70.w,
                                  )),
                              Container(
                                margin: EdgeInsets.only(top: 20.w),
                                child: Text(
                                  "＊以上收益分成会受VIP打折权益影响",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 12.sp, color: Color(0xFFFCEFD3)),
                                ),
                              ),
                              Container(
                                  margin: EdgeInsets.only(top: 20.w),
                                  height: 341.w,
                                  child: LocalPNG(
                                    url: "assets/images/popularize/popularize-table.png",
                                    height: 70.w,
                                  )),
                            ],
                          )),
                    ],
                  ),
                ),
                Positioned(
                  top: ScreenUtil().statusBarHeight,
                  child: Container(
                    width: 1.sw,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        IconButton(
                          padding: EdgeInsets.only(left: 20.0),
                          icon: Icon(Icons.arrow_back_ios),
                          onPressed: () => Navigator.pop(context),
                          iconSize: 25.0,
                          color: Colors.white,
                        ),
                        Text(
                          "推广赚钱",
                          style: TextStyle(fontSize: 18.sp, color: Colors.white),
                        ),
                        IconButton(
                          padding: EdgeInsets.only(right: 20.0),
                          icon: Icon(Icons.arrow_back),
                          onPressed: () => {},
                          iconSize: 30.0,
                          color: Colors.transparent,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class PopularizeNumber extends StatelessWidget {
  final String? numbers;
  final String? title;
  const PopularizeNumber({Key? key, this.numbers, this.title}) : super(key: key);

  String orderNumber() {
    var shownumber = double.parse(numbers!);
    if (shownumber <= 0) {
      return "0";
    } else {
      return CommonUtils.renderFixedNumber(shownumber);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          orderNumber(),
          style: TextStyle(fontSize: 22.sp, color: Color(0xFF323232)),
        ),
        SizedBox(height: 10.w),
        Text(
          title!,
          style: TextStyle(fontSize: 12.sp, color: Color(0xFFB4B4B4)),
        ),
      ],
    );
  }
}

class PopularizeMenu extends StatelessWidget {
  final String? icon;
  final String? title;
  final GestureTapCallback? onTap;
  const PopularizeMenu({Key? key, this.icon, this.title, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
        ),
        child: Column(children: <Widget>[
          LocalPNG(
            url: icon,
            width: 45.w,
            height: 45.w,
          ),
          SizedBox(height: 10.w),
          Text(
            title!,
            style: TextStyle(
              fontSize: 12.sp,
              color: Color(0xFF323232),
            ),
          )
        ]),
      ),
    );
  }
}
