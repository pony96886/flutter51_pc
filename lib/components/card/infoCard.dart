import 'package:bot_toast/bot_toast.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:chaguaner2023/store/homeConfig.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:chaguaner2023/utils/netimage_tool.dart';
import 'package:chaguaner2023/view/yajian/slectYouhuiquan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

//茶女郎卡片
class InfoCard extends StatefulWidget {
  final String? nickname;
  final String? name;
  final String? fee;
  final String? id;
  final String? priceMin;
  final String? thumb;
  final int? status;
  final Function? onPush;
  final Function? toDetail;
  final String? type;
  InfoCard(
      {Key? key,
      this.name,
      this.fee,
      this.thumb,
      this.id,
      this.status,
      this.onPush,
      this.priceMin,
      this.toDetail,
      this.nickname,
      this.type})
      : super(key: key);
  @override
  State<StatefulWidget> createState() => _InfoCardState();
}

class _InfoCardState extends State<InfoCard> {
  bool onPushDelay = false;
  dynamic myMoney;
  int dialogIndex = 0;
  int selectValue = 0;
  int? selectId;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    AppGlobal.connetGirl = null;
  }

  SwiperController swiperController = new SwiperController();
  reservation() async {
    await isAppointment(widget.id!, selectId).then((res) {
      if (res!['status'] != 0) {
        getProfilePage().then((val) {
          if (val!['status'] != 0) {
            Provider.of<HomeConfig>(context, listen: false)
                .setMoney(val!['data']['money']);
          }
        });
        AppGlobal.connetGirl = () {
          context.pop();
        };
        BotToast.showText(text: '预约成功～', align: Alignment(0, 0));
        Navigator.of(context).pop('val');
        AppGlobal.appRouter?.push(CommonUtils.getRealHash('yuyuesuccess/' +
            widget.fee.toString() +
            '/' +
            selectValue.toString() +
            '/' +
            Uri.encodeComponent(widget.name.toString()) +
            '/' +
            Uri.encodeComponent(widget.nickname.toString()) +
            '/${widget.type == 'chanvlang' ? 2 : 1}'));
      } else {
        CommonUtils.showText(res!['msg']);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var money = Provider.of<HomeConfig>(context).member.money;
    var agent = Provider.of<HomeConfig>(context).member.agent;
    String priceMin = '消费情况：${widget.priceMin}';
    String detailStr = '查看详情';
    return Container(
      color: StyleTheme.bottomappbarColor,
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      child: Row(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              widget.toDetail!(widget.id.toString());
            },
            child: Container(
              width: 60.w,
              height: 60.w,
              child: ClipRRect(
                child: NetImageTool(
                  url: widget.thumb!,
                  fit: BoxFit.cover,
                ),
              ),
              margin: new EdgeInsets.only(right: 15.w),
            ),
          ),
          Expanded(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Container(
                    height: 60.w,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          widget.name!,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.sp,
                              color: StyleTheme.cTitleColor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Flexible(
                          child: Text(
                            widget.type == 'chanvlang'
                                ? priceMin
                                : '最低消费：' + widget.priceMin.toString(),
                            style: TextStyle(
                                fontSize: 12.sp, color: StyleTheme.cTitleColor),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    )),
              ),
              Row(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      if (!onPushDelay) {
                        onPushDelay = true;
                        widget.onPush!();
                        Future.delayed(new Duration(seconds: 3), () {
                          onPushDelay = false;
                        });
                      } else {
                        BotToast.showText(
                            text: '请不要发送太频繁', align: Alignment(0, 0));
                      }
                    },
                    child: Container(
                      height: 25.w,
                      margin: EdgeInsets.only(right: 15.w),
                      padding: new EdgeInsets.symmetric(horizontal: 10.5.w),
                      decoration: BoxDecoration(
                          color: StyleTheme.cDangerColor,
                          borderRadius: BorderRadius.circular(12.5.w)),
                      child: Center(
                          child: Text(
                        '发送妹子',
                        style: TextStyle(fontSize: 13.w, color: Colors.white),
                      )),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (agent == 1) {
                        AppGlobal.appRouter?.push(CommonUtils.getRealHash(
                            'vipDetailPage/' + widget.id.toString() + '/null/'));
                      }
                      if (widget.status == 2) {
                        setState(() {
                          myMoney = money;
                        });
                        showPublish();
                      } else {
                        switch (widget.status) {
                          case 4:
                            showBuy('提示', '当前茶女郎已被经纪人删除,不能支付预约金哦～', 2);
                            break;
                          case 5:
                            showBuy('提示', '当前妹子不在线,不能支付预约金,请稍后再来吧～', 2);
                            break;
                          default:
                        }
                      }
                    },
                    child: Container(
                      height: 25.w,
                      padding: new EdgeInsets.symmetric(horizontal: 10.5.w),
                      decoration: BoxDecoration(
                          color: StyleTheme.cDangerColor,
                          borderRadius: BorderRadius.circular(12.5.w)),
                      child: Center(
                          child: Text(
                        agent == 1 ? detailStr : '支付预约金',
                        style: TextStyle(fontSize: 13.sp, color: Colors.white),
                      )),
                    ),
                  )
                ],
              )
            ],
          ))
        ],
      ),
    );
  }

  Future<bool?> showBuy(String title, dynamic content, int type) {
    String surepay = '确认支付';
    String igot = '朕知道了';
    String toCharges = '去充值';
    return showDialog<bool?>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 300.w,
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
                        child: (content is String)
                            ? Text(
                                content,
                                style: TextStyle(
                                    fontSize: 14.sp,
                                    color: StyleTheme.cTitleColor),
                              )
                            : content),
                    GestureDetector(
                      onTap: () => {
                        Navigator.of(context).pop(true),
                      },
                      child: Container(
                          child: Row(
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
                                    height: 50.w,
                                    width: 110.w,
                                    url: 'assets/images/mymony/money-img.png',
                                  ),
                                  Center(
                                      child: Text(
                                    '取消',
                                    style: TextStyle(
                                        fontSize: 15.sp, color: Colors.white),
                                  )),
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              switch (type) {
                                case 0:
                                  Navigator.of(context).pop();
                                  if (double.parse(widget.fee.toString()) >
                                      double.parse(myMoney.toString())) {
                                    showBuy(
                                        '确认下单',
                                        '需要支付预约金' +
                                            widget.fee.toString() +
                                            '元宝。',
                                        1);
                                    return;
                                  } else {
                                    reservation();
                                  }
                                  break;
                                case 1:
                                  Navigator.of(context).pop();
                                  AppGlobal.appRouter?.push(
                                      CommonUtils.getRealHash('ingotWallet'));
                                  break;
                                case 2:
                                  Navigator.of(context).pop();
                                  break;
                                default:
                              }
                            },
                            child: Container(
                              margin: new EdgeInsets.only(top: 30.w),
                              height: 50.w,
                              width: 110.w,
                              child: Stack(
                                children: [
                                  LocalPNG(
                                    height: 50.w,
                                    width: 110.w,
                                    url: 'assets/images/mymony/money-img.png',
                                  ),
                                  Center(
                                      child: Text(
                                    type != 2
                                        ? (type == 1 ? toCharges : surepay)
                                        : igot,
                                    style: TextStyle(
                                        fontSize: 15.sp, color: Colors.white),
                                  )),
                                ],
                              ),
                            ),
                          )
                        ],
                      )),
                    )
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

  Future showPublish() {
    String nowPay = '立即支付';
    return showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setBottomSheetState) {
            return Container(
              color: Colors.transparent,
              child: Container(
                height: 400.w + ScreenUtil().bottomBarHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Container(
                        padding:
                            EdgeInsets.only(top: 20.w, left: 15.w, right: 15.w),
                        child: Swiper(
                          controller: swiperController,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (BuildContext context, int index) {
                            return index == 0
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        child: Center(
                                            child: Text(
                                          '支付预约金',
                                          style: TextStyle(
                                              fontSize: 18.sp,
                                              color: StyleTheme.cTitleColor,
                                              fontWeight: FontWeight.w500),
                                        )),
                                      ),
                                      Container(
                                        child: Flex(
                                          direction: Axis.horizontal,
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                                flex: 1, child: Container()),
                                            Expanded(
                                                flex: 2,
                                                child: Container(
                                                  margin: EdgeInsets.only(
                                                      top: 40.w, bottom: 40.w),
                                                  child: Center(
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        LocalPNG(
                                                          width: 38.w,
                                                          height: 27.w,
                                                          url:
                                                              'assets/images/detail/vip-yuanbao.png',
                                                          fit: BoxFit.contain,
                                                        ),
                                                        SizedBox(
                                                          width: 11.w,
                                                        ),
                                                        Text.rich(TextSpan(
                                                            text: (int.parse(widget
                                                                        .fee
                                                                        .toString()) -
                                                                    selectValue)
                                                                .toString(),
                                                            style: TextStyle(
                                                                color: StyleTheme
                                                                    .cTitleColor,
                                                                fontSize:
                                                                    36.sp),
                                                            children: [
                                                              TextSpan(
                                                                text: '元宝',
                                                                style: TextStyle(
                                                                    color: StyleTheme
                                                                        .cTitleColor,
                                                                    fontSize:
                                                                        18.sp),
                                                              )
                                                            ])),
                                                      ],
                                                    ),
                                                  ),
                                                )),
                                            Expanded(
                                                flex: 1,
                                                child: selectValue != 0
                                                    ? Container(
                                                        margin: EdgeInsets.only(
                                                            top: 15.w),
                                                        child: Text(
                                                          widget.fee
                                                                  .toString() +
                                                              '元宝',
                                                          style: TextStyle(
                                                            color: StyleTheme
                                                                .cBioColor,
                                                            fontSize: 18.sp,
                                                            decoration:
                                                                TextDecoration
                                                                    .lineThrough,
                                                            decorationColor:
                                                                StyleTheme
                                                                    .cBioColor,
                                                          ),
                                                        ),
                                                      )
                                                    : Container()),
                                          ],
                                        ),
                                      ),
                                      BottomLine(),
                                      rowText(
                                        '优惠券',
                                        selectValue == 0
                                            ? '选择优惠券'
                                            : selectValue.toString() + '元宝优惠券',
                                        setBottomSheetState,
                                        selectValue == 0
                                            ? StyleTheme.cBioColor
                                            : StyleTheme.cDangerColor,
                                      ),
                                      BottomLine(),
                                      rowText('预约妹子', widget.name!,
                                          setBottomSheetState),
                                      BottomLine(),
                                      rowText('发布用户', widget.nickname!,
                                          setBottomSheetState),
                                      BottomLine(),
                                      Expanded(
                                          child: Center(
                                        child: GestureDetector(
                                          onTap: () {
                                            if (myMoney <
                                                (double.parse(widget.fee!) -
                                                    selectValue)) {
                                              AppGlobal.appRouter?.push(
                                                  CommonUtils.getRealHash(
                                                      'ingotWallet'));
                                            } else {
                                              if (widget.status == 2) {
                                                reservation();
                                              } else {
                                                switch (widget.status) {
                                                  case 4:
                                                    showBuy(
                                                        '提示',
                                                        '当前茶女郎已被经纪人删除,不能支付预约金哦～',
                                                        2);
                                                    break;
                                                  case 5:
                                                    showBuy(
                                                        '提示',
                                                        '当前妹子不在线,不能支付预约金,请稍后再来吧～',
                                                        2);
                                                    break;
                                                  default:
                                                }
                                              }
                                            }
                                          },
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                margin: EdgeInsets.only(
                                                    bottom: 10.w),
                                                width: 275.w,
                                                height: 50.w,
                                                child: Stack(
                                                  children: [
                                                    LocalPNG(
                                                      width: 275.w,
                                                      height: 50.w,
                                                      url:
                                                          'assets/images/mymony/money-img.png',
                                                    ),
                                                    Center(
                                                        child: Text(
                                                      myMoney <
                                                              (double.parse(widget
                                                                      .fee!) -
                                                                  selectValue)
                                                          ? '余额不足,去充值'
                                                          : nowPay,
                                                      style: TextStyle(
                                                          fontSize: 15.sp,
                                                          color: Colors.white),
                                                    )),
                                                  ],
                                                ),
                                              ),
                                              Text(
                                                '支付预约金前，请先和茶老板沟通妹子和服务等',
                                                style: TextStyle(
                                                    color:
                                                        StyleTheme.cDangerColor,
                                                    fontSize: 12.sp),
                                              )
                                            ],
                                          ),
                                        ),
                                      ))
                                    ],
                                  )
                                : youHuiQuan(setBottomSheetState);
                          },
                          itemCount: 2,
                          layout: SwiperLayout.DEFAULT,
                          itemWidth: double.infinity,
                          itemHeight: double.infinity,
                        )),
                    dialogIndex == 1
                        ? Container()
                        : Positioned(
                            top: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: LocalPNG(
                                url: "assets/images/nav/closemenu.png",
                                width: 30.w,
                                height: 30.w,
                              ),
                            ),
                          )
                  ],
                ),
              ),
            );
          });
        }).then((value) => {
          if (value == null) {dialogIndex = 0, selectId = null, selectValue = 0}
        });
  }

  Widget youHuiQuan(Function setBottomSheetState) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                swiperController.move(0);
                setBottomSheetState(() {
                  dialogIndex = 0;
                  selectValue = 0;
                  selectId = null;
                });
              },
              child: Text(
                '取消',
                style: TextStyle(
                  fontSize: 15.sp,
                  color: StyleTheme.cTitleColor,
                ),
              ),
            ),
            Expanded(
                child: Center(
              child: Text(
                '选择优惠券',
                style: TextStyle(
                    fontSize: 18.sp,
                    color: StyleTheme.cTitleColor,
                    fontWeight: FontWeight.w500),
              ),
            )),
            GestureDetector(
              onTap: () {
                swiperController.move(0);
                setBottomSheetState(() {
                  dialogIndex = 0;
                });
              },
              child: Text('确定',
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: StyleTheme.cTitleColor,
                  )),
            )
          ],
        )),
        SlectYouHuiQuan(
            isSelect: selectId!,
            setCallBack: (id, value) {
              setBottomSheetState(() {
                selectId = id;
                selectValue = value;
              });
            })
      ],
    );
  }

  Widget rowText(String title, String content, Function callBack,
      [Color? color]) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 14.sp, color: Color(0xFF969693)),
        ),
        color != null
            ? GestureDetector(
                onTap: () {
                  if (int.parse(widget.fee.toString()) < 200) {
                    CommonUtils.showText('预约金大于200才能使用优惠券哦');
                    return;
                  }
                  swiperController.move(1);
                  callBack(() {
                    dialogIndex = 1;
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      content,
                      style: TextStyle(color: color, fontSize: 14.sp),
                    ),
                    SizedBox(
                      width: 5.5.w,
                    ),
                    LocalPNG(
                      width: 15.w,
                      height: 15.w,
                      url: 'assets/images/detail/right-icon.png',
                    )
                  ],
                ),
              )
            : Text(
                content,
                style:
                    TextStyle(fontSize: 14.sp, color: StyleTheme.cTitleColor),
              )
      ],
    );
  }
}

class BottomLine extends StatelessWidget {
  const BottomLine({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(
        top: 10.w,
        bottom: 10.w,
      ),
      decoration: BoxDecoration(
        color: Color(0xFFEEEEEE),
        border: Border(
          top: BorderSide.none,
          left: BorderSide.none,
          right: BorderSide.none,
          bottom: BorderSide(width: 0.5, color: Color(0xFFEEEEEE)),
        ),
      ),
    );
  }
}
