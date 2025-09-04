import 'dart:math';

import 'package:card_swiper/card_swiper.dart';
import 'package:chaguaner2023/components/datetime/src/date_format.dart';
import 'package:chaguaner2023/components/loading.dart';
import 'package:chaguaner2023/model/getlotteryuserdetail.dart';
import 'package:chaguaner2023/model/lotterylist.dart';
import 'package:chaguaner2023/model/lotteryresult.dart';
import 'package:chaguaner2023/store/homeConfig.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:flutter/material.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../components/datetime/src/i18n_model.dart';

class OneYuanSpring extends StatefulWidget {
  OneYuanSpring({Key? key}) : super(key: key);

  @override
  _OneYuanSpringState createState() => _OneYuanSpringState();
}

class _OneYuanSpringState extends State<OneYuanSpring> {
  bool isLoding = true;
  bool isShuffle = true;
  List swiperList = [];
  List lotteryResultList = [];
  List<BetAmountItem> betAmountItem = [];
  String note = '';
  @override
  void initState() {
    super.initState();
    initData();
    initLotteryRsult();
  }

  initData() async {
    var result = await getLottery();
    if (result!.status == 1) {
      if (result.data!.length > 0) {
        if (isShuffle) {
          setState(() {
            swiperList = shuffle(result.data!);
            isLoding = false;
            isShuffle = false;
          });
        } else {
          setState(() {
            swiperList = result.data!;
            isLoding = false;
            isShuffle = false;
          });
        }
      } else {
        isLoding = false;
      }
    }
    BotToast.closeAllLoading();
  }

  List shuffle(List items) {
    var random = new Random();
    for (var i = items.length - 1; i > 0; i--) {
      var n = random.nextInt(i + 1);
      var temp = items[i];
      items[i] = items[n];
      items[n] = temp;
    }

    return items;
  }

  initLotteryRsult() async {
    var result = await getLotteryResult();
    if (result!.status == 1) {
      if (result.data!.result!.length > 0) {
        lotteryResultList = result.data?.result ?? [];
        note = result.data?.playNote ?? "";
        betAmountItem = result.data?.betAmountList ?? [];
        setState(() {});
      }
    }
  }

  Future<bool?> showBuy(String title, String content, int type, [String? btnText]) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: CommonUtils.getWidth(560),
            padding: new EdgeInsets.symmetric(vertical: CommonUtils.getWidth(30), horizontal: CommonUtils.getWidth(50)),
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
                        style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 18.sp, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                        margin: new EdgeInsets.only(top: CommonUtils.getWidth(40)),
                        child: Text(
                          content,
                          style: TextStyle(fontSize: 14.sp, color: StyleTheme.cTitleColor),
                        )),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop(true);
                      },
                      child: Container(
                        margin: new EdgeInsets.only(top: CommonUtils.getWidth(60)),
                        height: CommonUtils.getWidth(100),
                        width: CommonUtils.getWidth(380),
                        child: Stack(
                          children: [
                            LocalPNG(
                              height: CommonUtils.getWidth(100),
                              width: CommonUtils.getWidth(380),
                              url: 'assets/images/mymony/money-img.png',
                              fit: BoxFit.fill,
                            ),
                            Center(
                                child: Text(
                              btnText ?? '确定',
                              style: TextStyle(fontSize: 15.sp, color: Colors.white),
                            )),
                          ],
                        ),
                      ),
                    )
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
                        fit: BoxFit.cover,
                        url: 'assets/images/mymony/close.png',
                      )),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void freshData() {
    BotToast.showLoading();
    initData();
  }

  @override
  Widget build(BuildContext context) {
    return isLoding
        ? Loading()
        : Scaffold(
            backgroundColor: Color(0xFFD5512B),
            body: SingleChildScrollView(
                physics: ClampingScrollPhysics(),
                child: Stack(children: <Widget>[
                  Column(
                    children: [
                      Stack(
                        children: [
                          LocalPNG(
                            width: double.infinity,
                            height: CommonUtils.getWidth(630),
                            url: "assets/images/elegantroom/header_bg.png",
                          ),
                          Positioned(
                              top: CommonUtils.getWidth(300),
                              child: Container(
                                  width: 1.sw,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      lotteryResultList.length > 0
                                          ? Container(
                                              width: 1.sw,
                                              height: CommonUtils.getWidth(60),
                                              child: Stack(
                                                children: [
                                                  LocalPNG(
                                                    width: 1.sw,
                                                    height: CommonUtils.getWidth(60),
                                                    url: "assets/images/elegantroom/zhongjiang.png",
                                                  ),
                                                  Swiper(
                                                    itemCount: lotteryResultList.length,
                                                    scrollDirection: Axis.vertical,
                                                    loop: true,
                                                    autoplay: true,
                                                    itemBuilder: (BuildContext context, int index) {
                                                      String nickname = lotteryResultList[index].nickname;
                                                      String lotteryStr = lotteryResultList[index].title;
                                                      return Container(
                                                        width: 1.sw,
                                                        height: 30.w,
                                                        alignment: Alignment.center,
                                                        child: Text.rich(
                                                          TextSpan(
                                                            style: TextStyle(fontSize: 12.sp, color: Colors.white),
                                                            children: [
                                                              TextSpan(
                                                                text: '恭喜【' + nickname.toString() + '】抽中',
                                                              ),
                                                              TextSpan(
                                                                text: '$lotteryStr',
                                                                style: TextStyle(color: Color(0xFFFFFF00)),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ))
                                          : SizedBox()
                                    ],
                                  )))
                        ],
                      ),
                      Container(
                        transform: Matrix4.translationValues(0, -10, 0),
                        width: 1.sw,
                        height: 440.w,
                        child: Swiper(
                          itemCount: swiperList.length,
                          itemBuilder: (BuildContext context, int index) {
                            return CircletPlace(
                              betAmountItem: betAmountItem,
                              swiperitem: swiperList[index],
                              callback: freshData,
                            );
                          },
                          viewportFraction: 0.8,
                          scale: 0.95,
                        ),
                      ),
                      LocalPNG(
                        width: double.infinity,
                        height: CommonUtils.getWidth(138),
                        url: "assets/images/elegantroom/bottom_bg.png",
                        alignment: Alignment.topCenter,
                      )
                    ],
                  ),
                  Positioned(
                    top: ScreenUtil().statusBarHeight,
                    child: Container(
                      margin: EdgeInsets.only(top: ScreenUtil().statusBarHeight),
                      width: 1.sw,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              width: CommonUtils.getWidth(56),
                              height: CommonUtils.getWidth(56),
                              margin: EdgeInsets.only(left: 20.0),
                              child: LocalPNG(
                                width: CommonUtils.getWidth(56),
                                height: CommonUtils.getWidth(56),
                                url: "assets/images/elegantroom/arrow_back.png",
                              ),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  showBuy("玩法说明", note, 0, "我知道了");
                                },
                                child: Container(
                                  width: CommonUtils.getWidth(196),
                                  height: CommonUtils.getWidth(65),
                                  margin: EdgeInsets.only(left: 20.0),
                                  child: LocalPNG(
                                    url: "assets/images/elegantroom/right_menu.png",
                                    width: CommonUtils.getWidth(196),
                                    height: CommonUtils.getWidth(65),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 6.w,
                              ),
                              GestureDetector(
                                onTap: () {
                                  AppGlobal.appRouter?.push(CommonUtils.getRealHash('selfWinningRecord'));
                                },
                                child: Container(
                                  width: CommonUtils.getWidth(196),
                                  height: CommonUtils.getWidth(65),
                                  margin: EdgeInsets.only(left: 20.0),
                                  child: LocalPNG(
                                    url: "assets/images/elegantroom/icon_right_jilu.png",
                                    width: CommonUtils.getWidth(196),
                                    height: CommonUtils.getWidth(65),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ])));
  }
}

class CircletPlace extends StatefulWidget {
  final Datum? swiperitem;
  final Function? callback;
  final List<BetAmountItem> betAmountItem;
  CircletPlace({Key? key, this.swiperitem, this.callback, required this.betAmountItem}) : super(key: key);

  @override
  _CircletPlaceState createState() => _CircletPlaceState();
}

class _CircletPlaceState extends State<CircletPlace> {
  TextEditingController yuanbao = TextEditingController();
  int progress = 0;
  int? currentId;

  @override
  void initState() {
    super.initState();
    yuanbao.text = widget.swiperitem!.minBetAmount.toString();
    currentId = widget.swiperitem!.id;
  }

  // showGotItDialog() {
  //   return showDialog<bool>(
  //       context: context,
  //       barrierDismissible: false,
  //       builder: (context) {
  //         return Dialog(
  //             backgroundColor: Colors.transparent,
  //             child: SizedBox(
  //               width: CommonUtils.getWidth(550),
  //               height: CommonUtils.getWidth(744),
  //               child: Stack(
  //                 children: [
  //                   LocalPNG(
  //                     width: CommonUtils.getWidth(550),
  //                     height: CommonUtils.getWidth(744),
  //                     url: "assets/images/elegantroom/got_it_bg.png",
  //                   ),
  //                   Column(
  //                     mainAxisAlignment: MainAxisAlignment.end,
  //                     crossAxisAlignment: CrossAxisAlignment.center,
  //                     children: [
  //                       Text('抽中$typeStr奖池',
  //                           style: TextStyle(
  //                               color: Colors.white, fontSize: 18.sp)),
  //                       SizedBox(height: CommonUtils.getWidth(20)),
  //                       Text.rich(
  //                         TextSpan(
  //                           style: TextStyle(
  //                               fontSize: 18.sp, color: Color(0xFFF2F22E)),
  //                           children: [
  //                             TextSpan(
  //                               text: '+',
  //                               style: TextStyle(fontSize: 25.sp),
  //                             ),
  //                             TextSpan(
  //                               text: '2000',
  //                               style: TextStyle(fontSize: 36.sp),
  //                             ),
  //                             TextSpan(
  //                               text: '元宝',
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                       GestureDetector(
  //                         onTap: () {
  //                           Navigator.of(context).pop(true);
  //                         },
  //                         child: Container(
  //                           margin: EdgeInsets.symmetric(
  //                               vertical: CommonUtils.getWidth(55)),
  //                           width: CommonUtils.getWidth(430),
  //                           height: CommonUtils.getWidth(90),
  //                           child: LocalPNG(
  //                             url: "assets/images/elegantroom/got_it.png",
  //                             width: CommonUtils.getWidth(430),
  //                             height: CommonUtils.getWidth(90),
  //                           ),
  //                         ),
  //                       )
  //                     ],
  //                   ),
  //                 ],
  //               ),
  //             ));
  //       });
  // }

  Widget joinUserList() {
    List<Widget> tiles = [];
    Widget content;
    for (int i = 0; i < widget.swiperitem!.newestUser!.length; i++) {
      tiles.add(
        JoinUserItem(
          type: widget.swiperitem!.newestUser![i].thumb,
          nickname: widget.swiperitem!.newestUser![i].nickname!,
        ),
      );
    }

    content = new Row(
      children: tiles,
    );
    return content;
  }

  void showCurrentInvestment(int id) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, state) {
          return LotteryRecord(
            lotteryId: id,
          );
        });
      },
    );
  }

  void lotteryAction() async {
    String numberStr = widget.swiperitem!.title!;
    int priceStr = widget.swiperitem!.minBetAmount!;
    if (handleCurrentInvestment()) {
      BotToast.showText(text: "当前目标已满，暂停投入", align: Alignment.center);
      return;
    }
    if (yuanbao.text.isEmpty) {
      BotToast.showText(text: "请输入元宝", align: Alignment.center);
      return;
    }
    if (int.parse(yuanbao.text) < priceStr) {
      BotToast.showText(
        text: "请正确输入元宝数量,$numberStr最低$priceStr元宝",
        align: Alignment.center,
      );
      return;
    }
    var result = await postLotteryAction(widget.swiperitem!.id!, yuanbao.text.toString());
    if (result!.status == 1) {
      CommonUtils.updateUserMoney(context, yuanbao.text.toString());
      BotToast.showText(text: "投入成功", align: Alignment.center);
      yuanbao.text = '';
    } else {
      BotToast.showText(text: result.msg!, align: Alignment.center);
    }
    widget.callback!.call();
  }

  dynamic onprogress() {
    var progressvalue = 0;
    var total = widget.swiperitem!.reward;
    var count = int.parse(widget.swiperitem!.currentInvestment.toString());
    var tmp = (count / total! * 100).toInt();
    if (tmp % 1 == 0) {
      progressvalue = tmp;
    }
    return progressvalue;
  }

  bool handleCurrentInvestment() {
    return widget.swiperitem!.reward! - int.parse(widget.swiperitem!.currentInvestment.toString()) <
        widget.swiperitem!.minBetAmount!;
  }

  @override
  Widget build(BuildContext context) {
    bool isFull = handleCurrentInvestment();
    dynamic userNumStr = widget.swiperitem!.userNum ?? 0;
    return Stack(
      children: [
        LocalPNG(
          width: 352.w,
          height: 450.w,
          url: "assets/images/elegantroom/oneyuan_bg.png",
          fit: BoxFit.fill,
        ),
        Padding(
          padding: EdgeInsets.only(top: 22.5.w, left: 20.w, right: 20.w),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 190.w,
                child: Stack(
                  children: [
                    LocalPNG(
                        width: double.infinity,
                        height: 190.w,
                        url: 'assets/images/elegantroom/oneyuan_bg.png',
                        alignment: Alignment.topCenter,
                        fit: BoxFit.fill),
                    Center(
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 10.w),
                            child: Text(widget.swiperitem!.title!,
                                style: TextStyle(fontSize: 23.sp, color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                          Text(
                            "当前目标",
                            style: TextStyle(fontSize: 14.sp, color: Colors.white),
                          ),
                          SizedBox(height: CommonUtils.getWidth(5)),
                          isFull
                              ? SizedBox(height: CommonUtils.getWidth(0))
                              : Text(
                                  "${widget.swiperitem!.currentInvestment}/${widget.swiperitem!.reward}",
                                  style: TextStyle(fontSize: 24.sp, color: Colors.white),
                                ),
                          isFull
                              ? Text("正在开奖", style: TextStyle(fontSize: 24.sp, color: Color(0xFFFFFF85)))
                              : Container(
                                  margin: EdgeInsets.only(top: CommonUtils.getWidth(10)),
                                  width: CommonUtils.getWidth(450),
                                  height: CommonUtils.getWidth(10),
                                  child: Stack(
                                    children: [
                                      Container(
                                        width: CommonUtils.getWidth(450),
                                        height: CommonUtils.getWidth(10),
                                        decoration: BoxDecoration(
                                          color: Colors.white38,
                                          borderRadius: BorderRadius.all(Radius.circular(8)),
                                        ),
                                      ),
                                      Container(
                                        width: onprogress() / 100 * CommonUtils.getWidth(450),
                                        height: CommonUtils.getWidth(10),
                                        decoration: BoxDecoration(
                                          color: Color(0xFFFFFF85),
                                          borderRadius: BorderRadius.all(Radius.circular(8)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                          SizedBox(height: CommonUtils.getWidth(10)),
                          Text(
                            widget.swiperitem!.desc!,
                            style: TextStyle(fontSize: 11.sp, color: Colors.white70),
                          ),
                          SizedBox(height: CommonUtils.getWidth(20)),
                          GestureDetector(
                            onTap: () {
                              AppGlobal.appRouter?.push(CommonUtils.getRealHash('winningRecord'));
                            },
                            child: Text(
                              "查看往期记录>",
                              style: TextStyle(fontSize: 14.sp, color: Colors.white),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text.rich(
                    TextSpan(
                      style: TextStyle(fontSize: 10.sp, color: Colors.white),
                      children: [
                        TextSpan(
                          text: '我已投入：',
                        ),
                        TextSpan(
                          text: '${widget.swiperitem!.myInvestment}',
                          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: ' 元宝',
                        )
                      ],
                    ),
                  ),
                  Spacer(),
                  if (widget.swiperitem!.lastRewardUser!.thumb != null &&
                      widget.swiperitem!.lastRewardUser!.nickname != null)
                    Text(
                      "上期中奖用户",
                      style: TextStyle(fontSize: 10.sp, color: Colors.white),
                    ),
                  SizedBox(
                    width: CommonUtils.getWidth(10),
                  ),
                  if (widget.swiperitem!.lastRewardUser!.thumb != null &&
                      widget.swiperitem!.lastRewardUser!.nickname != null)
                    AvatarBox(
                      commonValue: CommonUtils.getWidth(40),
                      circular: 5,
                      type: widget.swiperitem!.lastRewardUser!.thumb,
                    ),
                  if (widget.swiperitem!.lastRewardUser!.thumb != null &&
                      widget.swiperitem!.lastRewardUser!.nickname != null)
                    Container(
                      constraints: BoxConstraints(maxWidth: CommonUtils.getWidth(110)),
                      height: CommonUtils.getWidth(40),
                      padding: EdgeInsets.symmetric(horizontal: CommonUtils.getWidth(5)),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(topRight: Radius.circular(5), bottomRight: Radius.circular(5)),
                      ),
                      alignment: Alignment.center,
                      child: Center(
                        child: Text(
                          widget.swiperitem!.lastRewardUser!.nickname!,
                          maxLines: 1,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 10.sp),
                        ),
                      ),
                    ),
                ],
              ),
              Container(
                  margin: EdgeInsets.symmetric(vertical: CommonUtils.getWidth(20)),
                  width: double.infinity,
                  height: 35.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                          flex: 1,
                          child: Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(horizontal: CommonUtils.getWidth(20)),
                              child: isFull
                                  ? Text(
                                      "开奖中，暂停投入",
                                      style: TextStyle(color: StyleTheme.cBioColor, fontSize: 13.sp),
                                    )
                                  : Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            if (['', null, 0, "0"].contains(yuanbao.text)) {
                                              setState(() {
                                                yuanbao.text = widget.swiperitem!.minBetAmount!.toString();
                                              });
                                            } else {
                                              if (int.parse(yuanbao.text) <= widget.swiperitem!.minBetAmount!) {
                                                setState(() {
                                                  yuanbao.text = widget.swiperitem!.minBetAmount.toString();
                                                });
                                              } else {
                                                setState(() {
                                                  yuanbao.text =
                                                      (int.parse(yuanbao.text) - widget.swiperitem!.minBetAmount!)
                                                          .toString();
                                                });
                                              }
                                            }
                                          },
                                          child: LocalPNG(
                                            width: CommonUtils.getWidth(40),
                                            height: CommonUtils.getWidth(40),
                                            url: 'assets/images/elegantroom/reduce.png',
                                          ),
                                        ),
                                        Expanded(
                                            child: Container(
                                                padding: EdgeInsets.symmetric(horizontal: CommonUtils.getWidth(10)),
                                                child: TextField(
                                                  keyboardType: TextInputType.number,
                                                  textAlign: TextAlign.center,
                                                  controller: yuanbao,
                                                  decoration: InputDecoration(
                                                      isDense: true,
                                                      border: InputBorder.none,
                                                      hintStyle:
                                                          TextStyle(color: StyleTheme.cBioColor, fontSize: 14.sp),
                                                      hintText: "输入元宝"),
                                                ))),
                                        GestureDetector(
                                          onTap: () {
                                            // print(yuanbao.text);
                                            if (yuanbao.text == "") {
                                              setState(() {
                                                yuanbao.text = widget.swiperitem!.minBetAmount.toString();
                                              });
                                            } else {
                                              setState(() {
                                                yuanbao.text =
                                                    (int.parse(yuanbao.text) + widget.swiperitem!.minBetAmount!)
                                                        .toString();
                                              });
                                            }
                                          },
                                          child: LocalPNG(
                                            width: CommonUtils.getWidth(40),
                                            height: CommonUtils.getWidth(40),
                                            url: 'assets/images/elegantroom/add.png',
                                          ),
                                        ),
                                      ],
                                    ))),
                      GestureDetector(
                        onTap: () {
                          lotteryAction();
                        },
                        child: Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(horizontal: CommonUtils.getWidth(50)),
                          height: double.infinity,
                          decoration: BoxDecoration(
                            color: Color(0xFFF83139),
                            borderRadius:
                                BorderRadius.only(topRight: Radius.circular(8), bottomRight: Radius.circular(8)),
                          ),
                          child: Center(
                              child: Text('投入元宝',
                                  textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 12.sp))),
                        ),
                      ),
                    ],
                  )),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Consumer<HomeConfig>(
                  builder: (context, homeConfig, child) {
                    return Text("当前余额${homeConfig.member.money}元宝",
                        style: TextStyle(color: Colors.white, fontSize: 12.sp));
                  },
                )
              ]),
              widget.betAmountItem.isEmpty
                  ? SizedBox(
                      height: 10.w,
                    )
                  : Padding(
                      padding: EdgeInsets.only(top: 10.5.w, bottom: 15.w),
                      child: SizedBox(
                        height: 21.w,
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: widget.betAmountItem.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                yuanbao.text = "${widget.betAmountItem[index].value ?? 0}";
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(right: 7.w),
                                    height: 21.w,
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5.w), color: StyleTheme.cDangerColor),
                                    child: Text(
                                      '${widget.betAmountItem[index].title}',
                                      style: TextStyle(color: Colors.white, fontSize: 10.w),
                                    ),
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      child: Text('本期已有$userNumStr人参与',
                          textAlign: TextAlign.left, style: TextStyle(color: Colors.white, fontSize: 12.sp)),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      showCurrentInvestment(widget.swiperitem!.id!);
                    },
                    child: Text("投注记录>",
                        textAlign: TextAlign.left, style: TextStyle(color: Colors.white, fontSize: 12.sp)),
                  )
                ],
              ),
              Container(
                  margin: EdgeInsets.only(top: CommonUtils.getWidth(20)),
                  width: double.infinity,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: joinUserList(),
                  )),
              SizedBox(
                height: 20.w,
              )
            ],
          ),
        ),
      ],
    );
  }
}

class LotteryRecord extends StatefulWidget {
  final int? lotteryId;
  LotteryRecord({Key? key, this.lotteryId}) : super(key: key);

  @override
  _LotteryRecordState createState() => _LotteryRecordState();
}

class _LotteryRecordState extends State<LotteryRecord> {
  List<LotteryDatum> recordList = [];
  int page = 1;
  int limit = 20;
  bool isAllData = false;
  bool loadmore = true;

  @override
  void initState() {
    super.initState();
    loaddingRecord();
  }

  Widget recordItems() {
    List<Widget> tiles = [];
    Widget content;

    for (int i = 0; i < recordList.length; i++) {
      String investmentStr = recordList[i].investment.toString();
      tiles.add(Container(
        padding: EdgeInsets.only(bottom: CommonUtils.getWidth(20)),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          verticalDirection: VerticalDirection.down,
          children: <Widget>[
            Expanded(
              flex: 2,
              child: Text(
                recordList[i].nickname!,
                textDirection: TextDirection.ltr,
                style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 14.sp),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                formatDate(recordList[i].createdAt, [yyyy, "-", mm, "-", dd, " ", HH, ":", nn], LocaleType.zhCN),
                textAlign: TextAlign.right,
                style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 14.sp),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                investmentStr + "元宝",
                textDirection: TextDirection.rtl,
                style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 14.sp),
              ),
            ),
          ],
        ),
      ));
    }
    content = new Column(
      mainAxisSize: MainAxisSize.min,
      children: tiles,
    );
    return content;
  }

  void loaddingRecord() async {
    BotToast.showLoading();
    var result = await getLotteryUserDetail(page: page, limit: limit, id: widget.lotteryId);
    BotToast.closeAllLoading();
    if (result!.status == 1) {
      setState(() {
        recordList = result.data!;
        isAllData = result.data!.length < limit;
      });
    } else {
      BotToast.showText(text: "网络错误，请稍后再试");
    }
  }

  loaddingMoreData() async {
    BotToast.showLoading();
    var result = await getLotteryUserDetail(page: page, limit: limit, id: widget.lotteryId);
    BotToast.closeAllLoading();
    if (result!.status == 1) {
      if (page == 1) {
        setState(() {
          recordList = result.data!;
          isAllData = result.data!.length < limit;
          loadmore = true;
        });
      } else {
        setState(() {
          recordList.addAll(result.data ?? []);
          isAllData = result.data!.length < limit;
          loadmore = true;
        });
      }
    } else {
      BotToast.showText(text: "网络错误，请稍后再试");
    }
  }

  _onScrollNotification(ScrollNotification scrollInfo) {
    if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
      // 滑到了底部
      if (loadmore == true) {
        if (!isAllData) {
          page++;
          loaddingMoreData();
        }
        setState(() {
          loadmore = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10))),
        child: Stack(alignment: Alignment.center, children: <Widget>[
          Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                  top: CommonUtils.getWidth(30),
                  left: CommonUtils.getWidth(30),
                  right: CommonUtils.getWidth(30),
                  bottom: ScreenUtil().bottomBarHeight),
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(bottom: CommonUtils.getWidth(25)),
                    child: Text(
                      "投注记录",
                      style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 18.sp),
                    ),
                  ),
                  Expanded(
                    child: NotificationListener<ScrollNotification>(
                      key: Key('lottery_scroll'),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.only(bottom: CommonUtils.getWidth(20)),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    "投注用户",
                                    style: TextStyle(color: StyleTheme.cBioColor, fontSize: 14.sp),
                                  ),
                                  Text(
                                    "时间",
                                    style: TextStyle(color: StyleTheme.cBioColor, fontSize: 14.sp),
                                  ),
                                  Text(
                                    "金额",
                                    style: TextStyle(color: StyleTheme.cBioColor, fontSize: 14.sp),
                                  ),
                                ],
                              ),
                            ),
                            recordItems(),
                            isAllData
                                ? Container(
                                    padding: EdgeInsets.only(
                                        top: CommonUtils.getWidth(20),
                                        bottom: ScreenUtil().bottomBarHeight + CommonUtils.getWidth(20)),
                                    child: Text(
                                      "已经到底了",
                                      style: TextStyle(fontSize: 14.sp, color: StyleTheme.cBioColor),
                                    ),
                                  )
                                : Container(
                                    padding: EdgeInsets.only(
                                        top: CommonUtils.getWidth(20),
                                        bottom: ScreenUtil().bottomBarHeight + CommonUtils.getWidth(20)),
                                    child: Text(
                                      "加载中...",
                                      style: TextStyle(fontSize: 14.sp, color: StyleTheme.cBioColor),
                                    ),
                                  )
                          ],
                        ),
                      ),
                      onNotification: (ScrollNotification scrollInfo) => _onScrollNotification(scrollInfo),
                    ),
                  ),
                ],
              )),
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: LocalPNG(
                url: "assets/images/nav/closemenu.png",
                width: CommonUtils.getWidth(60),
                height: CommonUtils.getWidth(60),
              ),
            ),
          )
        ]),
      ),
    );
  }
}

class AvatarBox extends StatelessWidget {
  final double? commonValue;
  final double? circular;
  final dynamic type;
  AvatarBox({Key? key, this.type, this.commonValue, this.circular}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(circular!),
      child: LocalPNG(
        width: commonValue,
        height: commonValue,
        url: 'assets/images/common/$type.png',
      ),
    );
  }
}

class JoinUserItem extends StatelessWidget {
  final dynamic type;
  final String? nickname;
  const JoinUserItem({Key? key, this.type, this.nickname}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(right: CommonUtils.getWidth(15)),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.horizontal(left: Radius.circular(5.w)),
              child: AvatarBox(
                commonValue: CommonUtils.getWidth(60),
                circular: 0,
                type: type,
              ),
            ),
            Container(
              alignment: Alignment.center,
              height: CommonUtils.getWidth(60),
              padding: EdgeInsets.symmetric(horizontal: CommonUtils.getWidth(10)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topRight: Radius.circular(8), bottomRight: Radius.circular(8)),
              ),
              child: Text(
                nickname!,
                style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 12.sp),
              ),
            )
          ],
        ));
  }
}
