import 'package:bot_toast/bot_toast.dart';
import 'package:chaguaner2023/components/card_countdown.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:chaguaner2023/view/im/im.dart';
import 'package:chaguaner2023/view/im/im_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GrabOrderCard extends StatefulWidget {
  final Map? orderData;
  final Function? callBack;
  GrabOrderCard({Key? key, this.orderData, this.callBack}) : super(key: key);

  @override
  _GrabOrderCardState createState() => _GrabOrderCardState();
}

class _GrabOrderCardState extends State<GrabOrderCard> {
  List<Map>? itemList;
  toLlIm() {
    AppGlobal.chatUser = FormUserMsg(
        uuid: widget.orderData!['uuid'].toString(),
        nickname: widget.orderData!['nickname'],
        avatar: widget.orderData!['thumb']);
    AppGlobal.appRouter?.push(CommonUtils.getRealHash('llchat'));
  }

  @override
  void dispose() {
    // TODO: implement dispose
    itemList = null;
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    var serviceTag = widget.orderData!['serviceTag'].split(',');
    String costWayStr = widget.orderData!['costWay'].replaceAll(',', '、');
    String serviceTypeStr =
        widget.orderData!['serviceType'].replaceAll(',', '、');
    String highestPriceStr = widget.orderData!['highestPrice'].toString();
    setState(() {
      itemList = [
        {
          'icon': 'assets/images/detail/icon-postion.png',
          'title': '城市: ',
          'detail': widget.orderData!['cityName']
        },
        {
          'icon': 'assets/images/detail/icon-time.png',
          'title': '时间: ',
          'detail': '最晚' + widget.orderData!['latestTime'].toString()
        },
        {
          'icon': 'assets/images/detail/icon-money.png',
          'title': '消费: ',
          'detail':
              costWayStr + "," + serviceTypeStr + "、最高接受" + highestPriceStr
        },
        {
          'icon': 'assets/images/detail/icon-project.png',
          'title': '服务项目: ',
          'detail': serviceTag.getRange(
              0, serviceTag.length > 3 ? 3 : serviceTag.length)
        },
        {
          'icon': 'assets/images/detail/icon-remarks.png',
          'title': '备注: ',
          'detail': widget.orderData!['comment'] ?? '--'
        }
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        GestureDetector(
          onTap: () {
            AppGlobal.appRouter?.push(CommonUtils.getRealHash(
                'intentionDetailPage/' + widget.orderData!['id'].toString()));
          },
          child: Container(
            width: 345.w,
            margin: new EdgeInsets.symmetric(horizontal: 15.w),
            padding: new EdgeInsets.only(top: 20.w, left: 15.w, right: 15.w),
            decoration: BoxDecoration(boxShadow: [
              //阴影
              BoxShadow(
                  color: Colors.black12,
                  offset: Offset(0, 0.5.w),
                  blurRadius: 2.5.w)
            ], color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                for (var item in itemList!)
                  hallItem(item['icon'], item['title'], item['detail']),
                GestureDetector(
                  onTap: () {
                    gradOder(widget.orderData!['id']).then((res) {
                      if (res!['status'] != 0) {
                        if (WebSocketUtility.imToken == null) {
                          CommonUtils.getImPath(context, callBack: () {
                            BotToast.showText(
                                text: '抢单成功', align: Alignment(0, 0));
                            //跳转IM
                            toLlIm();
                          });
                        } else {
                          BotToast.showText(
                              text: '抢单成功', align: Alignment(0, 0));
                          //跳转IM
                          toLlIm();
                        }
                        widget.callBack!(true);
                      } else {
                        CommonUtils.showText(res['msg']);
                      }
                    });
                  },
                  behavior: HitTestBehavior.translucent,
                  child: Container(
                      margin: EdgeInsets.only(top: 5.w),
                      height: 54.w,
                      decoration: BoxDecoration(
                          border: Border(
                              top: BorderSide(
                                  //FlatButton
                                  width: 0.5,
                                  color: Color(0xFFEEEEEE)))),
                      child: Center(
                        child: Text(
                          '抢单私聊',
                          style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF5584E3)),
                        ),
                      )),
                ),
              ],
            ),
          ),
        ),
        Positioned(
            right: 25.w,
            top: 15.w,
            child: Stack(
              children: [
                Container(
                  width: 110.w,
                  height: 20.w,
                  child: LocalPNG(
                    url: 'assets/images/card/timing.png',
                  ),
                ),
                Positioned.fill(
                    child: CardCountdown(
                  timer: widget.orderData!['expireTime'],
                )),
              ],
            )),
      ],
    );
  }

  Widget hallItem(String imgPath, String title, dynamic detail) {
    return Container(
      margin: EdgeInsets.only(bottom: 11.w),
      child: Row(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(
              right: 11.w,
            ),
            width: 15.w,
            height: 15.w,
            child: LocalPNG(
              width: 15.w,
              height: 15.w,
              url: imgPath,
            ),
          ),
          Text(
            title,
            style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 14.sp),
          ),
          (detail is String)
              ? Flexible(
                  child: Text(
                  detail,
                  style:
                      TextStyle(color: StyleTheme.cTitleColor, fontSize: 14.sp),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ))
              : Row(
                  children: <Widget>[for (var item in detail) yjTag(item)],
                )
        ],
      ),
    );
  }

  Widget yjTag(String title) {
    int titleN = title.length > 4 ? 4 : (title.length < 2 ? 2 : title.length);
    return Container(
      margin: EdgeInsets.only(right: 5.w),
      height: 15.w,
      child: Stack(
        children: [
          LocalPNG(
            height: 15.w,
            width: 15.w,
            url: 'assets/images/card/tag-bg-$titleN.png',
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 7.w),
            child: Center(
              child: Text(
                title,
                style:
                    TextStyle(fontSize: 10.sp, color: StyleTheme.cDangerColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
