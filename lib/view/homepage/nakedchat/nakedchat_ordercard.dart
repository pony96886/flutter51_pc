import 'package:bot_toast/bot_toast.dart';
import 'package:chaguaner2023/components/popupbox.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:chaguaner2023/utils/netimage_tool.dart';
import 'package:chaguaner2023/view/homepage/online_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NakedChatOrderCard extends StatefulWidget {
  final Map? data;
  final int? type; //1 用户 2商家
  const NakedChatOrderCard({Key? key, this.data, this.type = 1})
      : super(key: key);

  @override
  State<NakedChatOrderCard> createState() => _NakedChatOrderCardState();
}

class _NakedChatOrderCardState extends State<NakedChatOrderCard> {
  List servers = [];
  Map? cardData;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    cardData = widget.data;
    cardData!['additions'].forEach((item) {
      servers.add('${item['name']}/${item['gold']}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AppGlobal.appRouter?.push(CommonUtils.getRealHash(
            'nakedchatDetail/${cardData!['girl_chat']['id']}'));
      },
      child: Container(
        margin: EdgeInsets.only(left: 15.w, right: 15.w, top: 10.w),
        padding:
            EdgeInsets.only(left: 15.w, right: 7.w, top: 15.w, bottom: 15.w),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.w),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  color: Colors.black12,
                  offset: Offset(0, 0.5.w),
                  blurRadius: 2.5.w)
            ]),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  height: 160.w,
                  width: 120.w,
                  margin: EdgeInsets.only(right: 15.5.w),
                  child: NetImageTool(
                    url: cardData!['girl_chat']['cover'],
                  ),
                ),
                Expanded(
                    child: SizedBox(
                  height: 160.w,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cardData!['girl_chat']['title'].toString(),
                        style: TextStyle(
                            color: StyleTheme.cTitleColor,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w500),
                      ),
                      Text(
                        'ID：${cardData!['girl_chat']['id']}',
                        style: TextStyle(
                          color: Color.fromRGBO(150, 150, 150, 1),
                          fontSize: 12.sp,
                        ),
                      ),
                      SizedBox(
                        height: 10.w,
                      ),
                      Text(
                        '附加项目：${servers.isEmpty ? '--' : servers.join('、')}',
                        style: TextStyle(
                          color: Color.fromRGBO(100, 100, 100, 1),
                          fontSize: 12.sp,
                        ),
                      ),
                      Spacer(),
                      Text(
                        '支付金额：${cardData!['total_amount']}元宝',
                        style: TextStyle(
                          color: Color.fromRGBO(100, 100, 100, 1),
                          fontSize: 12.sp,
                        ),
                      ),
                      // Text(
                      //   '联系方式：${cardData['user_contact'] ?? '- -'}',
                      //   style: TextStyle(
                      //     color: Color.fromRGBO(100, 100, 100, 1),
                      //     fontSize: 12.sp,
                      //   ),
                      // )
                    ],
                  ),
                ))
              ],
            ),
            widget.type == 1
                ? Container(
                    margin: EdgeInsets.only(top: 10.w),
                    child: Row(
                      children: [
                        cardData!['status'] == 1
                            ? GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  ServiceParmas.orderId =
                                      "裸聊订单:${cardData!['girl_chat']['title']};\n商家ID:${cardData!['girl_chat_id']};\n订单ID:${cardData!['order_id']};";
                                  ServiceParmas.type = 'chat';
                                  AppGlobal.appRouter?.push(
                                      CommonUtils.getRealHash(
                                          'onlineServicePage'));
                                },
                                child: Stack(
                                  children: [
                                    LocalPNG(
                                      width: 134.w,
                                      height: 50.w,
                                      url: 'assets/images/mymony/money-img.png',
                                    ),
                                    Positioned.fill(
                                        child: Center(
                                            child: Text(
                                      '专属客服',
                                      style: TextStyle(
                                          fontSize: 15.w, color: Colors.white),
                                    ))),
                                  ],
                                ),
                              )
                            : SizedBox(),
                        Spacer(),
                        cardData!['status'] == 1 //待确认
                            ? GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  PopupBox.showText(BackButtonBehavior.none,
                                      title: '温馨提示',
                                      text: '请确认妹子是否已与您完成交易',
                                      confirmtext: '确认交易',
                                      canceltext: '取消',
                                      showCancel: true, confirm: () {
                                    girlchatConfirm(cardData!['id'])
                                        .then((res) {
                                      if (res!['status'] != 0) {
                                        cardData!['status'] = 2;
                                        setState(() {});
                                        CommonUtils.showText('确认交易成功');
                                      } else {
                                        CommonUtils.showText(res['msg']);
                                      }
                                    });
                                  }, tapMaskClose: true);
                                },
                                child: Stack(
                                  children: [
                                    LocalPNG(
                                      width: 134.w,
                                      height: 50.w,
                                      url: 'assets/images/mymony/money-img.png',
                                    ),
                                    Positioned.fill(
                                        child: Center(
                                            child: Text(
                                      '确认交易',
                                      style: TextStyle(
                                          fontSize: 15.w, color: Colors.white),
                                    ))),
                                  ],
                                ),
                              )
                            : SizedBox(),
                        cardData!['status'] == 2 //待评价
                            ? GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  AppGlobal.appRouter?.push(
                                      CommonUtils.getRealHash('nackdChatMark'),
                                      extra: {
                                        ...cardData!,
                                      });
                                },
                                child: Stack(
                                  children: [
                                    LocalPNG(
                                      width: 134.w,
                                      height: 50.w,
                                      url: 'assets/images/mymony/money-img.png',
                                    ),
                                    Positioned.fill(
                                        child: Center(
                                            child: Text(
                                      '评价',
                                      style: TextStyle(
                                          fontSize: 15.w, color: Colors.white),
                                    ))),
                                  ],
                                ),
                              )
                            : SizedBox()
                      ],
                    ),
                  )
                : Container(
                    margin: EdgeInsets.only(top: 10.w),
                    child: Row(
                      children: [
                        cardData!['status'] == 1
                            ? GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  ServiceParmas.orderId =
                                      "裸聊订单：:${cardData!['girl_chat']['title']};\n商家ID:${cardData!['girl_chat_id']};\n订单ID:${cardData!['order_id']};";
                                  ServiceParmas.type = 'chat';
                                  AppGlobal.appRouter?.push(
                                      CommonUtils.getRealHash(
                                          'onlineServicePage'));
                                },
                                child: Stack(
                                  children: [
                                    LocalPNG(
                                      width: 134.w,
                                      height: 50.w,
                                      url: 'assets/images/mymony/money-img.png',
                                    ),
                                    Positioned.fill(
                                        child: Center(
                                            child: Text(
                                      '专属客服',
                                      style: TextStyle(
                                          fontSize: 15.w, color: Colors.white),
                                    ))),
                                  ],
                                ),
                              )
                            : SizedBox(),
                        Spacer(),
                        cardData!['status'] == 1 //待确认
                            ? GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  CommonUtils.showText('订单待确认');
                                },
                                child: Stack(
                                  children: [
                                    LocalPNG(
                                      width: 134.w,
                                      height: 50.w,
                                      url: 'assets/images/mymony/money-img.png',
                                    ),
                                    Positioned.fill(
                                        child: Center(
                                            child: Text(
                                      '待确认',
                                      style: TextStyle(
                                          fontSize: 15.w, color: Colors.white),
                                    ))),
                                  ],
                                ),
                              )
                            : SizedBox(),
                      ],
                    ),
                  )
          ],
        ),
      ),
    );
  }
}
