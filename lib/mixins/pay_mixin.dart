import 'package:bot_toast/bot_toast.dart';
import 'package:chaguaner2023/components/cgDialog.dart';
import 'package:chaguaner2023/components/page_status.dart';
import 'package:chaguaner2023/components/popupbox.dart';
import 'package:chaguaner2023/components/yy_dialog.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:chaguaner2023/utils/netimage_tool.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import "package:universal_html/html.dart" as html;

import '../utils/cache/image_net_tool.dart';

mixin PayMixin<T extends StatefulWidget> on State<T> {
  html.WindowBase? winRef;
  dynamic origin = html.window.location.origin! + '/';

  payErr() {
    YyShowDialog.showdialog(context, title: '提示', btnText: '知道啦',
        content: (setDialogState) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('支付失败,可能有如下原因,请您稍后再尝试'),
          SizedBox(
            height: ScreenUtil().setWidth(14),
          ),
          Text('1、当前充值人数过多，充值渠道拥挤。'),
          SizedBox(
            height: ScreenUtil().setWidth(14),
          ),
          Text('2、未支付订单过多，请过段时间再尝试。')
        ],
      );
    });
  }

  void _showDialog() {
    PopupBox.showText(BackButtonBehavior.none,
        title: '温馨提示',
        text:
            '1、充值高峰期间到账可能存在延迟，请稍作等待；\n2、如遇充值多次失败、长时间未到账且消费金额未返还情况，请在“充值记录”中选择该订单说明情况，我们会尽快处理。',
        confirmtext: '知道了',
        tapMaskClose: true);
  }

  showPay(Map product) {
    int? currentPay;
    List pays;
    pays = List.from(product['pay_channel']);
    return ChaguanDialog.showDialog(
        context: context,
        child: Dialog(
          alignment: Alignment.bottomCenter,
          backgroundColor: Colors.white.withOpacity(0.94),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          insetPadding: const EdgeInsets.only(bottom: 54, left: 10, right: 10),
          child: StatefulBuilder(builder: (context, setBottomSheetState) {
            bool isLogin = false;
            if (['', null, false].contains(AppGlobal.apiToken)) {
              isLogin = false;
            } else {
              isLogin = true;
            }
            return Container(
              width: double.infinity,
              padding:
                  EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(15)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(
                        top: ScreenUtil().setWidth(24.5),
                        bottom: ScreenUtil().setWidth(19.5)),
                    alignment: Alignment.center,
                    child: Text.rich(
                      TextSpan(
                        text: '支付金额 ',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                        children: [
                          TextSpan(
                            text: product['promo_price'].toString() + '元',
                            style: TextStyle(
                              color: Color.fromRGBO(228, 50, 52, 1),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Text(
                    '请选择支付方式',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  Column(
                    children: pays
                        .asMap()
                        .keys
                        .map((e) => Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                      color: const Color.fromRGBO(
                                          225, 225, 225, 1),
                                      width: 0.5),
                                  borderRadius: BorderRadius.circular(10)),
                              margin: EdgeInsets.only(top: 10.w),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10.w, vertical: 8.w),
                              width: double.infinity,
                              child: GestureDetector(
                                onTap: () {
                                  setBottomSheetState(() {
                                    currentPay = e;
                                  });
                                },
                                behavior: HitTestBehavior.translucent,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 40.w,
                                          height: 40.w,
                                          child: ImageNetTool(
                                            url: pays[e]['img_url']
                                                        .indexOf('http') ==
                                                    -1
                                                ? AppGlobal.bannerImgBase +
                                                    pays[e]['img_url']
                                                : pays[e]['img_url'],
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                        SizedBox(
                                          width: ScreenUtil().setSp(5.5),
                                        ),
                                        Text(
                                          pays[e]['name'],
                                        )
                                      ],
                                    ),
                                    ClipOval(
                                      child: Container(
                                        width: 16.w,
                                        height: 16.w,
                                        decoration: BoxDecoration(
                                          color: currentPay == e
                                              ? Color.fromRGBO(228, 50, 52, 1)
                                              : Color.fromRGBO(
                                                  240, 240, 240, 1),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: currentPay == e
                                                  ? Color.fromRGBO(
                                                      235, 235, 235, 1)
                                                  : Color.fromRGBO(
                                                      240, 240, 240, 1),
                                              width: 1),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                  SizedBox(
                    height: 20.w,
                  ),
                  GestureDetector(
                    onTap: () {
                      payMoney() async {
                        if (currentPay == null)
                          return CommonUtils.showText('请选择支付方式');
                        PageStatus.showLoading(text: '正在请求支付');
                        if (pays[currentPay!]['channel'] == 'money') {
                          try {
                            Map? res = await vipExchange(product['id']);
                            if (res!['status'] == 1) {
                              getHomeConfig(context);
                              CommonUtils.showText('兑换会员成功');
                            } else {
                              CommonUtils.showText(res!['msg']);
                            }
                          } catch (err) {
                            CommonUtils.showText('兑换会员失败，请稍后重试');
                          }
                        } else {
                          if (kIsWeb) {
                            winRef = html.window
                                .open('${origin}waiting.html', "_blank");
                          }
                          try {
                            Map? res = await onCreatePay(
                                pays[currentPay!]['channel'],
                                'online',
                                product['id']);
                            if (kIsWeb) {
                              PageStatus.closeLoading();
                              Navigator.pop(context);
                            }
                            if (res!['data'] != null &&
                                res!['data']['payUrl'] != null) {
                              _showDialog();
                              if (kIsWeb) {
                                winRef!.location.href = res!['data']['payUrl'];
                              } else {
                                CommonUtils.launchURL(res!['data']['payUrl']);
                              }
                            } else if (res['msg'] != null) {
                              if (kIsWeb) {
                                winRef!.close();
                                payErr();
                              }
                              CommonUtils.showText(res['data']['msg']);
                            } else {
                              if (kIsWeb) {
                                winRef!.close();
                                payErr();
                              }
                              CommonUtils.showText('创建订单失败，请稍后重试');
                            }
                          } catch (err) {
                            if (kIsWeb) {
                              winRef!.close();
                            }
                            CommonUtils.showText('创建订单失败，请稍后重试');
                          }
                        }
                        PageStatus.closeLoading();
                      }

                      payMoney();
                    },
                    behavior: HitTestBehavior.translucent,
                    child: Container(
                      width: double.infinity,
                      height: 50.w,
                      margin: EdgeInsets.only(top: 10.w),
                      child: Stack(
                        children: [
                          LocalPNG(
                              width: double.infinity,
                              height: 50.w,
                              url: "assets/images/pment/submit.png",
                              alignment: Alignment.center,
                              fit: BoxFit.contain),
                          Center(
                            child: Text(
                              '购买' + product['pname'].toString(),
                              style: TextStyle(
                                  color: Colors.white, fontSize: 15.sp),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20.w,
                  ),
                ],
              ),
            );
          }),
        ));
  }
}
