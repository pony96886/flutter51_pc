import 'dart:convert';

import 'package:bot_toast/bot_toast.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:chaguaner2023/utils/netimage_tool.dart';
import 'package:chaguaner2023/view/im/im.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../utils/cache/image_net_tool.dart';

class WorkBenchCard extends StatefulWidget {
  final bool isShare;
  final int? keys;
  final int? type;
  final bool edit;
  final Function? editCallBack;
  final Map? cardInfo;
  WorkBenchCard(
      {Key? key,
      this.isShare = false,
      this.keys,
      this.type,
      this.edit = false,
      this.editCallBack,
      this.cardInfo})
      : super(key: key);

  @override
  _WorkBenchCardState createState() => _WorkBenchCardState();
}

class _WorkBenchCardState extends State<WorkBenchCard> {
  // const STATUS_INIT = 1;//待审核
  //   const STATUS_PASS = 2;//审核通过
  //   const STATUS_FAIL = 3;//审核失败
  //   const STATUS_DELETE = 4;//用户删除
  //   const STATUS_REST = 5;//用户下架
  //   const STATUS_SLICE = 6;//待切片
  Map? cardInfo;
  getTags() {
    if (cardInfo!['tags'] != null && cardInfo!['tags'].length != 0) {
      var tags = [];
      cardInfo!['tags'].forEach((item) {
        tags.add(item['name']);
      });
      return tags.join(',');
    } else {
      return '--';
    }
  }

  @override
  void initState() {
    super.initState();
    cardInfo = widget.cardInfo;
  }

  @override
  void dispose() {
    cardInfo = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var image = cardInfo!['resources'].length > 0
        ? cardInfo!['resources'].firstWhere((v) => v['type'] == 1)
        : null;
    var dataTimes = DateTime.fromMillisecondsSinceEpoch(
        int.parse(cardInfo!['created_at'].toString()) * 1000);
    var beforeText = RelativeDateFormat.format(dataTimes);
    String v3under = 'v3-under-review';
    String v3andit = 'v3-audit-failure';
    String statuss = cardInfo!['status'] == 1 ? v3under : v3andit;
    String upSre = '上';
    String downStr = '下';
    dynamic cupValue = cardInfo!['post_type'] == 2
        ? cardInfo!['girl_cup']
        : CommonUtils.getCup(cardInfo!['girl_cup']);
    String jobgs = 'jobs';
    String resS = 'rest';
    String workStatus = cardInfo!['status'] == 2 ? jobgs : resS;
    return Stack(
      children: <Widget>[
        Container(
            margin: EdgeInsets.only(bottom: 15.w),
            decoration: BoxDecoration(boxShadow: [
              //阴影
              BoxShadow(
                  color: Colors.black12,
                  offset: Offset(0, 0.5.w),
                  blurRadius: 2.5.w)
            ], color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: EdgeInsets.only(
                  left: 15.w,
                  right: 15.w,
                  top: 15.w,
                  bottom: (widget.isShare ? 0 : 15).w),
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    //内容区域
                    GestureDetector(
                      onTap: () {
                        if (cardInfo!['status'] != 6) {
                          AppGlobal.appRouter?.push(CommonUtils.getRealHash(
                              'vipDetailPage/' + cardInfo!['id'].toString() + '/null/'));
                        } else {
                          BotToast.showText(
                              text: '该茶女郎的视频正在处理中,请稍后再试',
                              align: Alignment(0, 0));
                        }
                      },
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: <Widget>[
                          Container(
                            height: 100.w,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Expanded(
                                    child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Text(
                                          cardInfo!['title'],
                                          style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w500,
                                              color: StyleTheme.cTitleColor),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        DefaultTextStyle(
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              color: StyleTheme.cBioColor,
                                            ),
                                            child: Container(
                                              margin: EdgeInsets.only(top: 5.w),
                                              child: Row(
                                                children: <Widget>[
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        right: 15.w),
                                                    child: Text(cardInfo![
                                                                'girl_age_num']
                                                            .toString() +
                                                        '岁'),
                                                  ),
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        right: 15.w),
                                                    child: Text(
                                                        cardInfo!['girl_height']
                                                                .toString() +
                                                            'cm'),
                                                  ),
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        right: 15.w),
                                                    child: Text('$cupValue'),
                                                  )
                                                ],
                                              ),
                                            ))
                                      ],
                                    ),
                                    DefaultTextStyle(
                                        style: TextStyle(
                                            fontSize: 14.sp,
                                            color: StyleTheme.cTitleColor),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Text('所在地区：' +
                                                cardInfo!['cityName']
                                                    .toString()),
                                            Container(
                                              margin:
                                                  EdgeInsets.only(top: 7.5.w),
                                              child: Text(
                                                '服务项目：${getTags()}',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            )
                                          ],
                                        ))
                                  ],
                                )),
                                Container(
                                  width: 100.w,
                                  height: 100.w,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5)),
                                  child: cardInfo!['resources'].length > 0 &&
                                          cardInfo!['resources'][0]['url'] !=
                                              null
                                      ? ImageNetTool(
                                          url: image['url'],
                                        )
                                      : LocalPNG(
                                          url:
                                              "assets/images/default_image.png",
                                          fit: BoxFit.cover,
                                        ),
                                )
                              ],
                            ),
                          ),
                          (cardInfo!['status'] == 1 || cardInfo!['status'] == 3)
                              ? Positioned(
                                  right: -10.w,
                                  bottom: -10.w,
                                  child: LocalPNG(
                                    width: 63.w,
                                    height: 53.w,
                                    url: 'assets/images/card/$statuss.png',
                                  ))
                              : Container(),
                        ],
                      ),
                    ),
                    //当前状况
                    Container(
                      padding:
                          EdgeInsets.only(bottom: (widget.isShare ? 15 : 0).w),
                      margin: EdgeInsets.only(top: 20.w),
                      child: DefaultTextStyle(
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: StyleTheme.cBioColor,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(beforeText + '发布'),
                              Text('预约成功' +
                                  cardInfo!['appointment'].toString() +
                                  '人'),
                            ],
                          )),
                    ),
                    //操作区域
                    widget.isShare
                        ? ((cardInfo!['status'] == 2 ||
                                cardInfo!['status'] == 5)
                            ? Container(
                                margin: EdgeInsets.only(top: 5.w),
                                height: 54.w,
                                decoration: BoxDecoration(
                                    border: Border(
                                        top: BorderSide(
                                            //FlatButton
                                            width: 0.5,
                                            color: Color(0xFFEEEEEE)))),
                                child: GestureDetector(
                                  onTap: () {
                                    context.pop();
                                    String _data = JsonEncoder().convert({
                                      'id': cardInfo!['id'],
                                      'title': cardInfo!['title'],
                                      'content': cardInfo!['desc'] ?? '--',
                                      'avatar': cardInfo!['resources'].length >
                                                  0 &&
                                              cardInfo!['resources'][0]
                                                      ['url'] !=
                                                  null
                                          ? image['url']
                                          : "assets/images/default_image.png"
                                    });
                                    String _ext = JsonEncoder().convert({
                                      'uuid': WebSocketUtility.uuid,
                                      'avatar': WebSocketUtility.avatar,
                                      'aff': WebSocketUtility.aff,
                                      'agent': WebSocketUtility.agent,
                                      'vipLevel': WebSocketUtility.vipLevel,
                                      'nickname': WebSocketUtility.nickname
                                    });
                                    WebSocketUtility()
                                        .sendMessage('message/chat', {
                                      "to_id": AppGlobal.chatUser!.uuid,
                                      "type": "one",
                                      "content": _data,
                                      "action": "",
                                      "msgType": 'product',
                                      "microtime": DateTime.now()
                                          .millisecondsSinceEpoch, //microtime 为客户端发送消息毫秒时间,
                                      "ext": _ext,
                                      "avatar": WebSocketUtility.avatar,
                                      "nickname": WebSocketUtility.nickname,
                                      "duration": "默认空；语音长度；视频时长或其他自定义单位"
                                    });
                                  },
                                  child: Text(
                                    '分享妹子',
                                    style: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF5584E3)),
                                  ),
                                ))
                            : Container())
                        : (cardInfo!['status'] != 6
                            ? Container(
                                margin: EdgeInsets.only(top: 10.w),
                                child: Material(
                                  child: Ink(
                                    child: Row(
                                      children: <Widget>[
                                        (cardInfo!['status'] == 2 ||
                                                cardInfo!['status'] == 5)
                                            ? Expanded(
                                                flex: 1,
                                                child: InkWell(
                                                  onTap: () async {
                                                    String statusS =
                                                        cardInfo!['status'] == 2
                                                            ? downStr
                                                            : upSre;
                                                    await showBuy(
                                                            statusS + '架茶女郎',
                                                            '确定要' +
                                                                statusS +
                                                                '架该茶女郎吗?',
                                                            1)
                                                        .then((val) => {
                                                              if (val == true)
                                                                {
                                                                  changeStatusVipInfo(
                                                                          cardInfo![
                                                                              'id'])
                                                                      .then(
                                                                          (res) {
                                                                    if (res![
                                                                            'status'] !=
                                                                        0) {
                                                                      BotToast.showText(
                                                                          text: '茶女郎' +
                                                                              statusS +
                                                                              '架成功～',
                                                                          align: Alignment(
                                                                              0,
                                                                              0));

                                                                      cardInfo![
                                                                          'status'] = cardInfo!['status'] ==
                                                                              2
                                                                          ? 5
                                                                          : 2;
                                                                      setState(
                                                                          () {});
                                                                    } else {
                                                                      BotToast.showText(
                                                                          text:
                                                                              '操作失败,请稍后再试～',
                                                                          align: Alignment(
                                                                              0,
                                                                              0));
                                                                    }
                                                                  })
                                                                }
                                                            });
                                                  },
                                                  child: Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 5.w),
                                                    child: Center(
                                                      child: cardInfo![
                                                                  'status'] ==
                                                              2
                                                          ? Text('下架',
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      14.sp,
                                                                  color: Color(
                                                                      0xFF5584E3)))
                                                          : Text('上架',
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      14.sp,
                                                                  color: StyleTheme
                                                                      .cDangerColor)),
                                                    ),
                                                  ),
                                                ))
                                            : Container(),
                                        (cardInfo!['status'] == 2 ||
                                                cardInfo!['status'] == 5)
                                            ? Container(
                                                width: 1.w,
                                                height: 18.w,
                                                color: StyleTheme.textbgColor1,
                                              )
                                            : Container(),
                                        Expanded(
                                            flex: 1,
                                            child: InkWell(
                                              onTap: () {
                                                if (cardInfo!['status'] != 6) {
                                                  AppGlobal.uploadParmas =
                                                      cardInfo!;
                                                  AppGlobal.appRouter?.push(
                                                      CommonUtils.getRealHash(
                                                          'elegantPublishPage'));
                                                } else {
                                                  BotToast.showText(
                                                      text: '资源正在处理中,请稍后再试～',
                                                      align: Alignment(0, 0));
                                                }
                                              },
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 5.w),
                                                child: Center(
                                                  child: Text(
                                                    '编辑',
                                                    style: TextStyle(
                                                        fontSize: 14.sp,
                                                        color:
                                                            Color(0xFF5584E3)),
                                                  ),
                                                ),
                                              ),
                                            )),
                                        Container(
                                          width: 1.w,
                                          height: 18.w,
                                          color: StyleTheme.textbgColor1,
                                        ),
                                        Expanded(
                                            flex: 1,
                                            child: InkWell(
                                              onTap: () async {
                                                await showBuy('删除茶女郎',
                                                        '确定要删除该茶女郎吗?', 1)
                                                    .then((val) {
                                                  if (val == true) {
                                                    deleteVipInfo(widget
                                                            .cardInfo!['id']
                                                            .toString())
                                                        .then((res) {
                                                      if (res!['status'] != 0) {
                                                        widget.editCallBack!();
                                                        BotToast.showText(
                                                            text: '茶女郎删除成功～',
                                                            align: Alignment(
                                                                0, 0));
                                                      } else {
                                                        BotToast.showText(
                                                            text: res['msg'],
                                                            align: Alignment(
                                                                0, 0));
                                                      }
                                                    });
                                                  }
                                                });
                                              },
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 5.w),
                                                child: Center(
                                                  child: Text(
                                                    '删除',
                                                    style: TextStyle(
                                                        fontSize: 14.sp,
                                                        color: StyleTheme
                                                            .cDangerColor),
                                                  ),
                                                ),
                                              ),
                                            ))
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : Container())
                  ],
                ),
              ),
            )),
        (cardInfo!['status'] == 2 || cardInfo!['status'] == 5)
            ? Positioned(
                right: 0,
                top: 0,
                child: LocalPNG(
                  width: 50.w,
                  height: 50.w,
                  url: 'assets/images/card/$workStatus.png',
                ))
            : Container(),
      ],
    );
  }

  Future<bool?> showBuy(String title, String content, int type,
      [String? btnText]) {
    return showDialog<bool?>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 280.w,
            padding: new EdgeInsets.symmetric(vertical: 15.w, horizontal: 25.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Center(
                      child: Text(
                        title,
                        style: TextStyle(
                            color: StyleTheme.cTitleColor,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                        margin: new EdgeInsets.only(top: 20.w),
                        child: Text(
                          content,
                          style: TextStyle(
                              fontSize: 14.sp, color: StyleTheme.cTitleColor),
                        )),
                    type == 0
                        ? GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop(true);
                            },
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop();
                                AppGlobal.appRouter?.push(
                                    CommonUtils.getRealHash('memberCardsPage'));
                              },
                              child: Container(
                                margin: new EdgeInsets.only(top: 30.w),
                                height: 50.w,
                                width: 200.w,
                                child: Stack(
                                  children: [
                                    LocalPNG(
                                      url: 'assets/images/mymony/money-img.png',
                                      height: 50.w,
                                      width: 200.w,
                                    ),
                                    Center(
                                        child: Text(
                                      btnText ?? '去开通',
                                      style: TextStyle(
                                          fontSize: 15.sp, color: Colors.white),
                                    )),
                                  ],
                                ),
                              ),
                            ))
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                                child: Container(
                                  margin: new EdgeInsets.only(top: 30.w),
                                  height: 50.w,
                                  width: 110.w,
                                  child: Stack(
                                    children: [
                                      LocalPNG(
                                        url:
                                            'assets/images/mymony/money-img.png',
                                        height: 50.w,
                                        width: 110.w,
                                      ),
                                      Center(
                                          child: Text(
                                        '取消',
                                        style: TextStyle(
                                            fontSize: 15.sp,
                                            color: Colors.white),
                                      )),
                                    ],
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pop(true);
                                },
                                child: Container(
                                  margin: new EdgeInsets.only(top: 30.w),
                                  height: 50.w,
                                  width: 110.w,
                                  child: Stack(
                                    children: [
                                      LocalPNG(
                                        url:
                                            'assets/images/mymony/money-img.png',
                                        height: 50.w,
                                        width: 220.w,
                                      ),
                                      Center(
                                          child: Text(
                                        '确定',
                                        style: TextStyle(
                                            fontSize: 15.sp,
                                            color: Colors.white),
                                      )),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                  ],
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: LocalPNG(
                        width: 30.w,
                        height: 30.w,
                        url: 'assets/images/mymony/close.png',
                        fit: BoxFit.cover,
                      )),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
