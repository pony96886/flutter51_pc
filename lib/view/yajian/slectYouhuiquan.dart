import 'package:chaguaner2023/components/card/youhuiquan_card.dart';
import 'package:chaguaner2023/components/loading.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SlectYouHuiQuan extends StatefulWidget {
  final int? isSelect;
  final Function? setCallBack;
  SlectYouHuiQuan({Key? key, this.isSelect, this.setCallBack})
      : super(key: key);

  @override
  _SlectYouHuiQuanState createState() => _SlectYouHuiQuanState();
}

class _SlectYouHuiQuanState extends State<SlectYouHuiQuan> {
  Map cardData = {
    'data': null,
    'id': 0,
    'page': 1,
    'networkErr': false,
    'loadmore': true,
    'loading': true,
    'isAll': false,
  };
  int limit = 10;
  getUserCouponList() async {
    setState(() {
      cardData['networkErr'] = false;
      cardData['loading'] = (cardData['page'] == 1);
    });
    var myCoupon = await getYouhuiquan(cardData['page'], limit, 'canUse');
    if (myCoupon!['status'] != 0) {
      if (cardData['page'] == 1) {
        cardData['data'] = (myCoupon['data'] == null ? [] : myCoupon['data']);
        cardData['loading'] = false;
        cardData['loadmore'] = true;
        cardData['isAll'] = (myCoupon['data'].length < limit);
      } else {
        cardData['data']
            .addAll((myCoupon['data'] == null ? [] : myCoupon['data']));
        cardData['loadmore'] = true;
        cardData['isAll'] = (myCoupon['data'].length < limit);
      }
      setState(() {});
    } else {
      setState(() {
        cardData['networkErr'] = true;
        cardData['loading'] = false;
      });
    }
  }

  _onScrollNotification(ScrollNotification scrollInfo) {
    if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
      // 滑到了底部
      if (cardData['loadmore'] == true) {
        if (!cardData['isAll']) {
          cardData['page']++;
          getUserCouponList();
        }
        setState(() {
          cardData['loadmore'] = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getUserCouponList();
  }

  @override
  Widget build(BuildContext context) {
    return cardData['data'] == null || cardData['loading']
        ? Expanded(
            child: Loading(),
          )
        : Expanded(
            child: Column(
            children: [
              cardData['data'].length == 0
                  ? Container(
                      width: double.infinity,
                      height: 100.w,
                      child: Center(
                        child: Text(
                          '无可用优惠券',
                          style: TextStyle(
                              color: StyleTheme.cBioColor, fontSize: 14.sp),
                        ),
                      ),
                    )
                  : Container(),
              cardData['data'].length == 0
                  ? Container(
                      margin: EdgeInsets.only(bottom: 15.w),
                      height: 2.5.w,
                      width: double.infinity,
                      child: LocalPNG(
                          height: 2.5.w,
                          width: double.infinity,
                          url: 'assets/images/card/xuxian.png',
                          fit: BoxFit.cover),
                    )
                  : Container(),
              cardData['data'].length == 0
                  ? Container(
                      width: double.infinity,
                      height: 100.w,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '雅间预约妹子成功',
                              style: TextStyle(
                                  color: StyleTheme.cDangerColor,
                                  fontSize: 14.sp),
                            ),
                            Text(
                              '并进行评价即可获得元宝优惠券',
                              style: TextStyle(
                                  color: StyleTheme.cDangerColor,
                                  fontSize: 14.sp),
                            )
                          ],
                        ),
                      ),
                    )
                  : Expanded(
                      child: NotificationListener<ScrollNotification>(
                      child: ListView.builder(
                          itemCount: cardData['data'].length,
                          itemBuilder: (BuildContext context, int index) {
                            if (cardData['data'][index]['value'] == 0) {
                              return SizedBox();
                            }
                            return GestureDetector(
                              onTap: () {
                                widget.setCallBack!(
                                    widget.isSelect ==
                                            cardData['data'][index]['id']
                                        ? null
                                        : cardData['data'][index]['id'],
                                    widget.isSelect ==
                                            cardData['data'][index]['id']
                                        ? 0
                                        : cardData['data'][index]['value']);
                              },
                              child: YouHuiQuanCard(
                                  type: 2,
                                  isSelect: widget.isSelect ==
                                      cardData['data'][index]['id'],
                                  cardData: cardData['data'][index]),
                            );
                          }),
                      onNotification: (ScrollNotification scrollInfo) =>
                          _onScrollNotification(scrollInfo),
                    ))
            ],
          ));
  }
}
