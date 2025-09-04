import 'package:bot_toast/bot_toast.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class YouHuiQuanCard extends StatefulWidget {
  final Map? cardData;
  final int type;
  final bool isSelect;
  YouHuiQuanCard(
      {Key? key, this.cardData, this.type = 1, this.isSelect = false})
      : super(key: key);

  @override
  _YouHuiQuanCardState createState() => _YouHuiQuanCardState();
}

class _YouHuiQuanCardState extends State<YouHuiQuanCard> {
  String caiss = 'youhuiquan-cai';
  String huiSs = 'youhuiquan-hui';
  String slees = 'select-icon';
  String unseleic = 'unselect-icon';
  String used = 'yishiyong';
  String exps = 'yiguoqi';

  onExchangeMember() {
    onExchangeTempVip(id: widget.cardData!['id']).then((result) {
      if (result!['status'] == 1) {
        BotToast.showText(text: "使用成功", align: Alignment(0, 0));
      } else {
        BotToast.showText(text: result['msg'], align: Alignment(0, 0));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    dynamic statuch = huiSs, selecSs = unseleic, useStatus = exps, lisss;
    statuch = widget.cardData!['status'] == 1 ? caiss : huiSs;
    lisss = widget.cardData!['expired_at'].split(' ')[0];
    useStatus = widget.cardData!['status'] == 2 ? used : exps;
    selecSs = widget.isSelect ? slees : unseleic;

    return Container(
        width: double.infinity,
        height: 90.w,
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              child: Stack(
                children: [
                  LocalPNG(
                    width: double.infinity,
                    height: double.infinity,
                    url: 'assets/images/card/$statuch.png',
                    fit: BoxFit.contain,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: 15.w,
                      right: 18.5.w,
                      left: 15.w,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.cardData!['value'] == 0
                                  ? "24小时会员体验券"
                                  : '元宝优惠券',
                              style: TextStyle(
                                  fontSize: 18.sp,
                                  color: Color(widget.cardData!['status'] != 1
                                      ? 0xffffffff
                                      : 0xffffff00)),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                top: 10.w,
                              ),
                              child: Text(
                                '$lisss 到期',
                                style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Color(widget.cardData!['status'] != 1
                                        ? 0xffdcdcdc
                                        : 0xffdcdcdc)),
                              ),
                            )
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              child: widget.cardData!['value'] == 0
                                  ? GestureDetector(
                                      onTap: () {
                                        onExchangeMember();
                                      },
                                      child: Text("使用",
                                          style: TextStyle(
                                            fontSize: 20.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xffc92630),
                                          )),
                                    )
                                  : Text(
                                      widget.cardData!['value'].toString(),
                                      style: TextStyle(
                                          fontSize: 30.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Color(
                                              widget.cardData!['status'] != 1
                                                  ? 0xff969696
                                                  : 0xffc92630)),
                                    ),
                            ),
                            widget.cardData!['status'] == 1 && widget.type != 1
                                ? Container(
                                    width: 25.w,
                                    height: 25.w,
                                    margin: EdgeInsets.only(left: 5.5.w),
                                    child: LocalPNG(
                                      url: 'assets/images/card/$selecSs.png',
                                      fit: BoxFit.contain,
                                    ),
                                  )
                                : Container(
                                    width: 25.w,
                                    height: 25.w,
                                  )
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            widget.cardData!['status'] == 1
                ? Container()
                : Positioned(
                    right: 0,
                    top: 5.w,
                    child: LocalPNG(
                      width: 50.w,
                      height: 50.w,
                      url: 'assets/images/card/$useStatus.png',
                      fit: BoxFit.contain,
                    ))
          ],
        ));
  }
}
