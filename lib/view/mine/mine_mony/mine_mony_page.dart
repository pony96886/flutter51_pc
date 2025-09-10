import 'package:bot_toast/bot_toast.dart';
import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/page_title_bar.dart';
import 'package:chaguaner2023/store/homeConfig.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:chaguaner2023/view/homepage/signinpage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class MineMonyPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MineMonyPageState();
}

class MineMonyPageState extends State<MineMonyPage> {
  void _onGotoPublish() {
    var phone = Provider.of<HomeConfig>(context, listen: false).member.phone;
    if (['', null, false].contains(phone)) {
      BotToast.showText(text: '登录/注册后发布茶帖可以赚取铜钱奖励', align: Alignment.center);
    } else {
      // Navigator.push(
      //     context, MaterialPageRoute(builder: (context) => PublishPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return HeaderContainer(
        image: 'assets/images/home/squarebg.png',
        fit: BoxFit.fitWidth,
        child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Column(
              children: [
                PageTitleBar(
                  title: '福利中心',
                  rightWidget: GestureDetector(
                      onTap: () {
                        AppGlobal.appRouter?.push(CommonUtils.getRealHash('exchangeCoupon'));
                      },
                      child: Text(
                        '兑换优惠券',
                        style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 15.sp, fontWeight: FontWeight.w500),
                      )),
                ),
                Expanded(
                    child: ListView(
                  padding: EdgeInsets.symmetric(vertical: 15.w, horizontal: 0),
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15.w),
                      child: _monyDetail(),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 5.w),
                      child: LocalPNG(
                        url: 'assets/images/home/tx_xian.png',
                        height: 14.5.w,
                        width: double.infinity,
                      ),
                    ),
                    Center(
                      child: SignInPage(),
                    ),
                    Container(
                      padding: new EdgeInsets.only(top: 20.w, left: 15.5.w, right: 15.5.w),
                      child: Column(
                        children: [
                          Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '如何获得铜钱',
                                  style: TextStyle(
                                      color: StyleTheme.cTitleColor, fontSize: 18.sp, fontWeight: FontWeight.w500),
                                ),
                                _menuItem('assets/images/mymony/promote.png', '推广赚铜钱', () {
                                  AppGlobal.appRouter?.push(CommonUtils.getRealHash('shareQRCodePage'));
                                }, true),
                                _menuItem('assets/images/mymony/sign_in.png', '每日签到得铜钱', () {
                                  BotToast.showText(text: '完成首页萌新15天签到活动可以获得大量铜钱', align: Alignment.center);
                                }, false),
                                _menuItem('assets/images/mymony/verification.png', '发布茶帖赚铜钱', () {
                                  BotToast.showText(text: '发布茶帖赚铜钱', align: Alignment.center);
                                }, false),
                                _menuItem('assets/images/mymony/unlock_report.png', '发布验茶报告赚铜钱', () {
                                  BotToast.showText(text: '发布验茶报告,用户解锁赚铜钱', align: Alignment.center);
                                }, false),
                                _menuItem('assets/images/mymony/order_comment.png', '对已完成的预约单进行评论获得铜钱', () {
                                  BotToast.showText(text: '对已完成的预约单进行评论获得铜钱', align: Alignment.center);
                                }, false),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      color: StyleTheme.bottomappbarColor,
                      padding: new EdgeInsets.only(left: 15.w, right: 15.w, top: 30.w, bottom: 30.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppGlobal.useCopperCoinsTips['title'],
                            style:
                                TextStyle(fontWeight: FontWeight.w500, fontSize: 18.sp, color: StyleTheme.cTitleColor),
                          ),
                          Text(
                            AppGlobal.useCopperCoinsTips['content'],
                            style: TextStyle(
                                fontWeight: FontWeight.normal, fontSize: 12.sp, color: Color(0xFF969696), height: 1.8),
                          )
                        ],
                      ),
                    )
                  ],
                ))
              ],
            )));
  }

  Widget _monyDetail() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '我的铜钱',
              style: TextStyle(fontSize: 14.sp, color: StyleTheme.cTitleColor, fontWeight: FontWeight.normal),
            ),
            Text(
              CommonUtils.renderFixedNumber(double.parse(Provider.of<HomeConfig>(context).member.coins.toString())),
              style: TextStyle(fontSize: 30.sp, color: StyleTheme.cTitleColor, fontWeight: FontWeight.w500),
            ),
            GestureDetector(
              onTap: () {
                AppGlobal.appRouter?.push(CommonUtils.getRealHash('monyDtailPage'));
              },
              behavior: HitTestBehavior.translucent,
              child: Container(
                margin: EdgeInsets.only(top: 5.w),
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(3.w), color: Color.fromRGBO(251, 240, 229, 1)),
                width: 60.w,
                height: 20.w,
                alignment: Alignment.center,
                child: Text(
                  '铜钱明细',
                  style: TextStyle(color: StyleTheme.cDangerColor, fontSize: 12.sp),
                ),
              ),
            ),
          ],
        ),
        // GestureDetector(
        //   child: LocalPNG(
        //     url: 'assets/images/mymony/mymoney-detail.png',
        //     fit: BoxFit.cover,
        //     height: 38.w,
        //     width: 130.w,
        //   ),
        // )
      ],
    );
  }
}

Widget _menuItem(String img, String title, GestureTapCallback onTap, bool arrow) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: new EdgeInsets.only(top: 22.5.w, bottom: 22.5.w),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: StyleTheme.textbgColor1, width: 1, style: BorderStyle.solid))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              LocalPNG(
                url: img,
                height: 22.w,
              ),
              Container(
                margin: new EdgeInsets.only(left: 8.5.w),
                child: Text(title),
              )
            ],
          ),
          Visibility(
            visible: arrow,
            child: LocalPNG(
              url: 'assets/images/mymony/menu_to.png',
              height: 15.w,
            ),
          )
        ],
      ),
    ),
  );
}
