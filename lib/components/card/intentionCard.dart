import 'package:bot_toast/bot_toast.dart';
import 'package:chaguaner2023/components/avatar_widget.dart';
import 'package:chaguaner2023/components/card_countdown.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:chaguaner2023/view/im/im.dart';
import 'package:chaguaner2023/view/im/im_page.dart';
import 'package:flutter/material.dart';

class IntentionCard extends StatefulWidget {
  final Map? requireData;
  final int? type; //1商家  2用户
  final bool? closeTime;
  final Function? callBack; //取消
  final dynamic? myMoney;
  IntentionCard({
    Key? key,
    this.requireData,
    this.type = 2,
    this.callBack,
    this.myMoney,
    this.closeTime,
  }) : super(key: key);
  @override
  _IntentionCardState createState() => _IntentionCardState();
}

class _IntentionCardState extends State<IntentionCard> {
  int? oderStatus;
  String yixiangdan = '您的意向单已过期,您取消意向单后需发布新的意向单茶老板才能再次看见接单,确定要取消该意向单吗?';
  String cancles = '取消意向单后茶老板可再次抢单,确定要取消该意向单吗?';
  String tipsS = '预约将不在消耗元宝数量,预约成功之后只有茶老板才能取消预约，如需取消预约单可以联系茶老板或在线客服,是否确定预约?';
  String cancleS = '取消成功';
  String intenS = '预约成功';
  String cancleInten = '取消预约';
  Map? carInfo;
  @override
  void initState() {
    super.initState();
    carInfo = widget.requireData;
    oderStatus = carInfo!['status'];
  }

  @override
  void dispose() {
    carInfo = null;
    oderStatus = null;
    super.dispose();
  }

  cancelOdeer(int status) {
    var curTime = new DateTime.now().millisecondsSinceEpoch;
    var isExpired = (carInfo!['expireTime'] * 1000 - curTime) <= 0; //意向单是否已过期
    showBuy(
            '提示',
            status == 1
                ? (isExpired
                    ? yixiangdan //过期的意向单
                    : cancles) //正常的意向单
                : tipsS) //确认预约
        .then((val) {
      if (val == 1) {
        //用户更改意向单状态  1取消 3预约
        setOder(carInfo!['id'], status).then((res) {
          if (res!['status'] != 0) {
            oderStatus = (status == 1 ? (isExpired ? 4 : 1) : 3);
            widget.callBack!(status == 3);
            BotToast.showText(
                text: status == 1 ? cancleS : intenS, align: Alignment(0, 0));
          } else {
            BotToast.showText(text: res!['msg'], align: Alignment(0, 0));
          }
        });
      }
    });
  }

  confirmOder() {
    showBuy('提示', '交易成功后将完成交易无法取消预约,是否确认交易?').then((val) {
      //确认交易
      if (val == 1) {
        //客户确认意向单
        confirmRequire(carInfo!['id']).then((res) {
          if (res!['status'] != 0) {
            oderStatus = 5;
            widget.callBack!(true);
            BotToast.showText(text: '交易成功,祝您品茶愉快', align: Alignment(0, 0));
          } else {
            BotToast.showText(text: res['msg'], align: Alignment(0, 0));
          }
        });
      }
    });
  }

  brokerCancelNegotiate() {
    showBuy('提示', '取消洽谈后该意向单将退回到抢单大厅,是否取消洽谈?').then((val) {
      if (val == 1) {
        setOder(carInfo!['id'], 1).then((res) {
          if (res!['status'] != 0) {
            widget.callBack!(false);
            BotToast.showText(text: '取消成功', align: Alignment(0, 0));
          } else {
            BotToast.showText(text: res['msg'], align: Alignment(0, 0));
          }
        });
      }
    });
  }

  brokerCancelOder() {
    showBuy('提示', '交易取消后如果该意向单未过期将再次恢复待抢单状态,是否取消意向单?').then((val) {
      //茶老板取消意向单
      if (val == 1) {
        cancelRequire(carInfo!['id']).then((res) {
          if (res!['status'] != 0) {
            widget.callBack!(false);
            BotToast.showText(text: '交易取消成功', align: Alignment(0, 0));
          } else {
            BotToast.showText(text: res!['msg'], align: Alignment(0, 0));
          }
        });
      }
    });
  }

  toLlIm() {
    AppGlobal.chatUser = FormUserMsg(
        uuid: carInfo!['uuid'].toString(),
        nickname: carInfo!['nickname'].toString(),
        avatar: carInfo!['thumb'].toString());
    AppGlobal.appRouter?.push(CommonUtils.getRealHash('llchat'));
  }

// 更改意向单状态
  getOderStatus(int status) {
    if (widget.type == 1) {
      //商家
      switch (carInfo!['status']) {
        case 2:
          return '已抢单';
        case 3:
          return '待客户确认';
        case 4:
          return '已取消';
        case 5:
          return '交易完成';
        default:
      }
    } else {
      //用户
      switch (carInfo!['status']) {
        case 1:
          return '等待经纪人抢单';
        case 2:
          return '已抢单';
        case 3:
          return '待确认';
        case 4:
          return '已取消';
        case 5:
          return '交易完成';
        default:
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Container(
          width: CommonUtils.getWidth(690),
          margin:
              new EdgeInsets.symmetric(horizontal: CommonUtils.getWidth(30)),
          padding: new EdgeInsets.only(
              left: CommonUtils.getWidth(30),
              bottom: CommonUtils.getWidth(30),
              right: CommonUtils.getWidth(30)),
          decoration: BoxDecoration(boxShadow: [
            //阴影
            BoxShadow(
                color: Colors.black12,
                offset: Offset(0, CommonUtils.getWidth(1)),
                blurRadius: CommonUtils.getWidth(5))
          ], color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: CommonUtils.getWidth(40)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    carInfo!['status'] != 1 && carInfo!['nickname'] != null
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(
                                    right: CommonUtils.getWidth(21)),
                                width: CommonUtils.getWidth(60),
                                height: CommonUtils.getWidth(60),
                                decoration: BoxDecoration(
                                    color: StyleTheme.cDangerColor,
                                    borderRadius: BorderRadius.circular(5)),
                                child: Avatar(
                                  type: carInfo!['thumb'],
                                  onPress: () {
                                    AppGlobal.appRouter?.push(CommonUtils
                                        .getRealHash('brokerHomepage/' +
                                            carInfo!['aff'].toString() +
                                            '/' +
                                            Uri.encodeComponent(
                                                carInfo!['thumb'].toString()) +
                                            '/' +
                                            Uri.encodeComponent(widget
                                                .requireData!['nickname']
                                                .toString())));
                                  },
                                ),
                              ),
                              Flexible(
                                  child: Container(
                                constraints: BoxConstraints(
                                    maxWidth: CommonUtils.getWidth(260)),
                                child: Text(
                                  carInfo!['nickname'],
                                  style: TextStyle(
                                      fontSize: CommonUtils.getFontSize(32),
                                      fontWeight: FontWeight.bold,
                                      color: StyleTheme.cTitleColor),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )),
                              GestureDetector(
                                  onTap: () {
                                    if (carInfo!['nickname'] != null &&
                                        WebSocketUtility.uuid !=
                                            carInfo!['uuid']) {
                                      if (WebSocketUtility.imToken == null) {
                                        CommonUtils.getImPath(context,
                                            callBack: () {
                                          //跳转IM
                                          toLlIm();
                                        });
                                      } else {
                                        //跳转IM
                                        toLlIm();
                                      }
                                    }
                                  },
                                  child: Container(
                                    margin: new EdgeInsets.only(
                                        left: CommonUtils.getWidth(20)),
                                    padding: new EdgeInsets.symmetric(
                                        vertical: CommonUtils.getWidth(12),
                                        horizontal: CommonUtils.getWidth(34)),
                                    decoration: BoxDecoration(
                                        color: StyleTheme.cDangerColor,
                                        borderRadius: BorderRadius.circular(
                                            CommonUtils.getWidth(60))),
                                    child: Text(
                                      '私聊',
                                      style: TextStyle(
                                        fontSize: CommonUtils.getWidth(26),
                                        color: Colors.white,
                                      ),
                                    ),
                                  )),
                            ],
                          )
                        : Container(),
                    Text(
                      getOderStatus(carInfo!['status']),
                      style: TextStyle(
                          color: carInfo!['status'] == 3
                              ? StyleTheme.cDangerColor
                              : StyleTheme.cBioColor,
                          fontSize: CommonUtils.getFontSize(28)),
                    )
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  AppGlobal.appRouter?.push(CommonUtils.getRealHash(
                      'intentionDetailPage/' + carInfo!['id'].toString()));
                },
                child: Container(
                  margin: EdgeInsets.only(top: CommonUtils.getWidth(40)),
                  padding: EdgeInsets.symmetric(
                      horizontal: CommonUtils.getWidth(30),
                      vertical: CommonUtils.getWidth(29)),
                  decoration: BoxDecoration(
                      color: StyleTheme.bottomappbarColor,
                      borderRadius: BorderRadius.circular(5)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        carInfo!['cityName'].toString(),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: CommonUtils.getFontSize(36),
                            color: StyleTheme.cTitleColor),
                      ),
                      Container(
                        height: CommonUtils.getWidth(24),
                      ),
                      Text(
                        '最晚' +
                            carInfo!['latestTime'].toString() +
                            '；' +
                            carInfo!['costWay'].replaceAll(",", "、") +
                            '、' +
                            carInfo!['serviceType'].replaceAll(",", "、") +
                            '、最高接受' +
                            carInfo!['highestPrice'].toString() +
                            '元',
                        style: TextStyle(
                            fontSize: CommonUtils.getFontSize(22),
                            color: StyleTheme.cTitleColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    ],
                  ),
                ),
              ),
              Container(
                  margin: EdgeInsets.only(top: CommonUtils.getWidth(42)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        '预约金' + carInfo!['freezeMoney'].toString() + '元宝',
                        style: TextStyle(
                            color: StyleTheme.cTitleColor,
                            fontSize: CommonUtils.getWidth(28)),
                      ),
                      // const STATUS_INIT = 1;  等待抢单
                      // const STATUS_PICKED = 2; 已抢单待确认
                      // const STATUS_APPOINTMENT = 3 已预约  可取消;
                      // const STATUS_CANCEL = 4; 已取消
                      // const STATUS_FINISH = 5; 交易完成
                      widget.type == 2
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                carInfo!['status'] == 2
                                    ? GestureDetector(
                                        onTap: () {
                                          cancelOdeer(1);
                                        },
                                        child: Container(
                                          margin: EdgeInsets.only(
                                              right: CommonUtils.getWidth(40)),
                                          width: CommonUtils.getWidth(170),
                                          height: CommonUtils.getWidth(50),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12.5),
                                              color: StyleTheme.cDangerColor),
                                          child: Center(
                                            child: Text(
                                              '取消',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize:
                                                      CommonUtils.getFontSize(
                                                          26)),
                                            ),
                                          ),
                                        ),
                                      )
                                    : Container(),
                                carInfo!['status'] == 2
                                    ? GestureDetector(
                                        onTap: () {
                                          cancelOdeer(3);
                                        },
                                        child: Container(
                                          width: CommonUtils.getWidth(170),
                                          height: CommonUtils.getWidth(50),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12.5),
                                              color: StyleTheme.cDangerColor),
                                          child: Center(
                                            child: Text(
                                              '预约',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize:
                                                      CommonUtils.getFontSize(
                                                          26)),
                                            ),
                                          ),
                                        ),
                                      )
                                    : Container(),
                                carInfo!['status'] == 1 && widget.type == 2
                                    ? GestureDetector(
                                        onTap: () {
                                          AppGlobal.appRouter?.push(
                                              CommonUtils.getRealHash(
                                                  'teaTastingIntention/' +
                                                      carInfo!['id']
                                                          .toString()));
                                        },
                                        child: Container(
                                          margin: EdgeInsets.only(
                                              right: CommonUtils.getWidth(20)),
                                          width: CommonUtils.getWidth(170),
                                          height: CommonUtils.getWidth(50),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12.5),
                                              color: StyleTheme.cDangerColor),
                                          child: Center(
                                            child: Text(
                                              '编辑',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize:
                                                      CommonUtils.getFontSize(
                                                          26)),
                                            ),
                                          ),
                                        ),
                                      )
                                    : Container(),
                                carInfo!['status'] == 3
                                    ? GestureDetector(
                                        onTap: () {
                                          confirmOder();
                                        },
                                        child: Container(
                                          width: CommonUtils.getWidth(170),
                                          height: CommonUtils.getWidth(50),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12.5),
                                              color: StyleTheme.cDangerColor),
                                          child: Center(
                                            child: Text(
                                              '确认交易',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize:
                                                      CommonUtils.getFontSize(
                                                          26)),
                                            ),
                                          ),
                                        ),
                                      )
                                    : Container()
                              ],
                            )
                          : (carInfo!['status'] == 3 || carInfo!['status'] == 2
                              ? GestureDetector(
                                  onTap: () {
                                    if (carInfo!['status'] == 3) {
                                      //取消预约
                                      brokerCancelOder();
                                    } else {
                                      //取消洽谈
                                      brokerCancelNegotiate();
                                    }
                                  },
                                  child: Container(
                                    width: CommonUtils.getWidth(170),
                                    height: CommonUtils.getWidth(50),
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(12.5),
                                        color: StyleTheme.cDangerColor),
                                    child: Center(
                                      child: Text(
                                        carInfo!['status'] == 3
                                            ? cancleInten
                                            : '取消洽谈',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize:
                                                CommonUtils.getFontSize(26)),
                                      ),
                                    ),
                                  ),
                                )
                              : Container())
                    ],
                  ))
            ],
          ),
        ),
        Positioned(
            left: CommonUtils.getWidth(50),
            top: CommonUtils.getWidth(-10),
            child: widget.type == 1 && !widget.closeTime!
                ? Container(
                    width: CommonUtils.getWidth(220),
                    height: CommonUtils.getWidth(40),
                    child: Stack(
                      children: [
                        LocalPNG(
                            width: CommonUtils.getWidth(220),
                            height: CommonUtils.getWidth(40),
                            url: 'assets/images/card/timing.png',
                            fit: BoxFit.fill),
                        Center(
                          child: CardCountdown(
                            timer: carInfo!['expireTime'],
                          ),
                        ),
                      ],
                    ),
                  )
                : Container()),
      ],
    );
  }

  Future<int?> showBuy(String title, String content) {
    return showDialog<int?>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: CommonUtils.getWidth(560),
            padding: new EdgeInsets.symmetric(
                vertical: CommonUtils.getWidth(30),
                horizontal: CommonUtils.getWidth(50)),
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
                            fontSize: CommonUtils.getFontSize(36),
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                        margin:
                            new EdgeInsets.only(top: CommonUtils.getWidth(40)),
                        child: Text(
                          content,
                          style: TextStyle(
                              fontSize: CommonUtils.getFontSize(28),
                              color: StyleTheme.cTitleColor),
                        )),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop(0);
                          },
                          child: Container(
                            margin: new EdgeInsets.only(
                                top: CommonUtils.getWidth(60)),
                            height: CommonUtils.getWidth(100),
                            width: CommonUtils.getWidth(220),
                            child: Stack(
                              children: [
                                LocalPNG(
                                    height: CommonUtils.getWidth(100),
                                    width: CommonUtils.getWidth(220),
                                    url: 'assets/images/mymony/money-img.png',
                                    fit: BoxFit.fill),
                                Center(
                                    child: Text(
                                  '取消',
                                  style: TextStyle(
                                      fontSize: CommonUtils.getFontSize(30),
                                      color: Colors.white),
                                )),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop(1);
                          },
                          child: Container(
                            margin: new EdgeInsets.only(
                                top: CommonUtils.getWidth(60)),
                            height: CommonUtils.getWidth(100),
                            width: CommonUtils.getWidth(220),
                            child: Stack(
                              children: [
                                LocalPNG(
                                    height: CommonUtils.getWidth(100),
                                    width: CommonUtils.getWidth(220),
                                    url: 'assets/images/mymony/money-img.png',
                                    fit: BoxFit.fill),
                                Center(
                                    child: Text(
                                  '确定',
                                  style: TextStyle(
                                      fontSize: CommonUtils.getFontSize(30),
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
                  right: CommonUtils.getWidth(0),
                  top: CommonUtils.getWidth(0),
                  child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: LocalPNG(
                          width: CommonUtils.getWidth(60),
                          height: CommonUtils.getWidth(60),
                          url: 'assets/images/mymony/close.png',
                          fit: BoxFit.cover)),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
