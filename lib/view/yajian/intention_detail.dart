import 'package:bot_toast/bot_toast.dart';
import 'package:chaguaner2023/components/card_countdown.dart';
import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/loading.dart';
import 'package:chaguaner2023/components/page_title_bar.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:chaguaner2023/view/im/im.dart';
import 'package:chaguaner2023/view/im/im_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class IntentionDetailPage extends StatefulWidget {
  final String? id;
  IntentionDetailPage({Key? key, this.id}) : super(key: key);

  @override
  _IntentionDetailPageState createState() => _IntentionDetailPageState();
}

class _IntentionDetailPageState extends State<IntentionDetailPage> {
  List<Map>? itemList;
  Map? detailData;
  bool loading = true;

  toLlIm() {
    AppGlobal.chatUser = FormUserMsg(
        isVipDetail: true,
        uuid: detailData!['uuid'].toString(),
        nickname: detailData!['nickname'].toString(),
        avatar: detailData!['thumb'].toString());
    AppGlobal.appRouter?.push(CommonUtils.getRealHash('llchat'));
  }

  @override
  void initState() {
    super.initState();
    getRequireDetail(widget.id!).then((res) {
      if (res!['status'] != 0) {
        detailData = res['data'];
        loading = false;
        String serTypeStr = detailData!['serviceType'].replaceAll(',', '、').toString();
        String costWayStr = detailData!['costWay'].replaceAll(',', '、').toString();
        itemList = [
          {'icon': 'assets/images/detail/icon-postion.png', 'title': '城市: ', 'detail': detailData!['cityName'] ?? '--'},
          {'icon': 'assets/images/detail/icon-time.png', 'title': '时间: ', 'detail': '最晚' + detailData!['latestTime']},
          {
            'icon': 'assets/images/detail/icon-money.png',
            'title': '消费: ',
            'detail': costWayStr + "," + serTypeStr + "、最高接受" + detailData!['highestPrice'].toString()
          },
          {
            'icon': 'assets/images/detail/icon-project.png',
            'title': '服务项目: ',
            'detail': detailData!['serviceTag'].split(',')
          },
          {'icon': 'assets/images/detail/icon-remarks.png', 'title': '备注: ', 'detail': detailData!['comment'] ?? '--'}
        ];
        (context as Element).markNeedsBuild();
      } else {
        Navigator.of(context).pop();
        BotToast.showText(text: res['msg'], align: Alignment(0, 0));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return HeaderContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
            child: PageTitleBar(
              title: '意向详情',
            ),
            preferredSize: Size(double.infinity, 44.w)),
        body: loading
            ? Loading()
            : Container(
                width: double.infinity,
                height: double.infinity,
                child: SingleChildScrollView(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: <Widget>[
                      Container(
                        width: 345.w,
                        margin: new EdgeInsets.symmetric(horizontal: 15.w),
                        padding: new EdgeInsets.only(top: 20.w, left: 15.w, right: 15.w),
                        decoration: BoxDecoration(boxShadow: [
                          //阴影
                          BoxShadow(color: Colors.black12, offset: Offset(0, 0.5.w), blurRadius: 2.5.w)
                        ], color: Colors.white, borderRadius: BorderRadius.circular(10)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            for (var item in itemList!) hallItem(item['icon'], item['title'], item['detail']),
                            detailData!['status'] == 1
                                ? Container(
                                    margin: EdgeInsets.only(top: 5.w),
                                    height: 54.w,
                                    decoration: BoxDecoration(
                                        border: Border(top: BorderSide(width: 0.5, color: Color(0xFFEEEEEE)))),
                                    child: GestureDetector(
                                      onTap: () {
                                        gradOder(detailData!['id']).then((res) {
                                          if (res!['status'] != 0) {
                                            if (WebSocketUtility.imToken == null) {
                                              CommonUtils.getImPath(context, callBack: () {
                                                //跳转IM
                                                toLlIm();
                                              });
                                            } else {
                                              //跳转IM
                                              toLlIm();
                                            }
                                          } else {
                                            BotToast.showText(text: res['msg'], align: Alignment(0, 0));
                                          }
                                        });
                                      },
                                      behavior: HitTestBehavior.translucent,
                                      child: Center(
                                        child: Text(
                                          '抢单私聊',
                                          style: TextStyle(
                                              fontSize: 15.sp, fontWeight: FontWeight.w500, color: Color(0xFF5584E3)),
                                        ),
                                      ),
                                    ))
                                : Container(),
                          ],
                        ),
                      ),
                      Positioned(
                          right: 25.w,
                          top: -5.w,
                          child: SizedBox(
                            width: 110.w,
                            height: 20.w,
                            child: Stack(
                              children: [
                                LocalPNG(
                                  url: 'assets/images/card/timing.png',
                                  fit: BoxFit.fill,
                                  width: 110.w,
                                  height: 20.w,
                                ),
                                Center(
                                  child: CardCountdown(
                                    timer: detailData!['expireTime'],
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget hallItem(String imgPath, String title, dynamic detail) {
    return Container(
      margin: EdgeInsets.only(bottom: 11.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(
              right: 11.w,
            ),
            width: 15.w,
            height: 15.w,
            child: LocalPNG(
              url: imgPath,
              width: 15.w,
              height: 15.w,
            ),
          ),
          Text(
            title,
            style: TextStyle(height: 1.2, color: StyleTheme.cTitleColor, fontSize: 14.sp),
          ),
          (detail is String)
              ? Flexible(
                  child: Text(
                  detail,
                  style: TextStyle(height: 1.2, color: StyleTheme.cTitleColor, fontSize: 14.sp),
                ))
              : Expanded(
                  child: Container(
                  child: detail.length > 0
                      ? Wrap(
                          spacing: 0,
                          runSpacing: 10.w,
                          children: <Widget>[for (var item in detail) yjTag(item)],
                        )
                      : Text('--'),
                ))
        ],
      ),
    );
  }

  Widget yjTag(String title) {
    int value = title.length > 4 ? 4 : (title.length < 2 ? 2 : title.length);
    return Container(
      margin: EdgeInsets.only(right: 5.w),
      height: 15.w,
      child: Stack(
        children: [
          LocalPNG(height: 15.w, url: 'assets/images/card/tag-bg-$value.png', fit: BoxFit.fill),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 7.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(fontSize: 10.w, color: StyleTheme.cDangerColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
