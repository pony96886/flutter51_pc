import 'package:bot_toast/bot_toast.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/pagetitlebar.dart';
import 'package:chaguaner2023/store/global.dart';
import 'package:chaguaner2023/store/homeConfig.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:chaguaner2023/view/yajian/selectMultiple.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class ExchangeMember extends StatefulWidget {
  ExchangeMember({Key? key}) : super(key: key);

  @override
  State<ExchangeMember> createState() => _ExchangeMemberState();
}

class _ExchangeMemberState extends State<ExchangeMember> {
  bool loading = true;
  bool networkErr = false;
  int dialogIndex = 0;
  List selectValue = [];
  List selectId = [];
  SwiperController swiperController = new SwiperController();
  List products = [];
  String coinsValue = "";

  getList() {
    getProductListOfCard(1).then((res) {
      if (res!['status'] != 0) {
        products = res['data']['product'];
        CommonUtils.debugPrint(res['data']);
        loading = false;
        setState(() {});
      } else {
        setState(() {
          networkErr = true;
        });
        return;
      }
    });
  }

  onBuyMember(Map product) {
    double promoPrice = double.parse(product['promo_price']) / 2;
    if (coinsValue.isEmpty) {
      onExchangeProducet(product);
    } else {
      if (double.parse(coinsValue) > promoPrice) {
        BotToast.showText(text: '最高可使用50%抵用券', align: Alignment(0, 0));
      } else {
        onExchangeProducet(product);
      }
    }
  }

  onExchangeProducet(Map product) {
    String selectIdList = selectId.isNotEmpty ? selectId.join(',') : "";
    onCouponExchange(id: product['id'], idList: selectIdList).then((result) {
      if (result!['status'] == 1) {
        BotToast.showText(text: "兑换成功", align: Alignment(0, 0));
        getList();
        _getNumInfo();
      } else {
        BotToast.showText(text: result['msg'], align: Alignment(0, 0));
      }
    });
  }

  _getNumInfo() async {
    var _number = await getProfilePage();
    await getHomeConfig(context);
    Provider.of<GlobalState>(context, listen: false)
        .setProfile(_number!['data']);
    Provider.of<GlobalState>(context, listen: false)
        .setOltime(_number['data']['oltime']);
  }

  List matchObjectsById(List<dynamic> idList, List objectList) {
    List matchedObjects = [];
    for (var obj in objectList) {
      if (idList.contains(obj['id'])) {
        matchedObjects.add(obj);
      }
    }
    return matchedObjects;
  }

  onChangeCoupon() {
    List matchedObjects = matchObjectsById(selectId, selectValue);
    int sumber = 0;
    if (matchedObjects.isNotEmpty) {
      for (var obj in matchedObjects) {
        sumber += obj['value'] as int;
      }
      coinsValue = sumber.toString();
      setState(() {});
    } else {
      coinsValue = "";
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    getList();
  }

  @override
  Widget build(BuildContext context) {
    return HeaderContainer(
        child: Scaffold(
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
          child: PageTitleBar(title: '兑换会员'),
          preferredSize: Size(double.infinity, 44.w)),
      body: ListView(
        children: <Widget>[
          Center(
            child: Wrap(
              spacing: 15.w,
              runSpacing: 15.w,
              children: <Widget>[for (var item in products) monyCart(item)],
            ),
          )
        ],
      ),
    ));
  }

  showPay(Map product) {
    print(product);
    String nowPay = '立即兑换';
    return showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          var money =
              Provider.of<HomeConfig>(context, listen: false).member.money;
          return StatefulBuilder(builder: (context, setBottomSheetState) {
            return Container(
                color: Colors.transparent,
                child: Container(
                    height: 400.w + ScreenUtil().bottomBarHeight,
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    child:
                        Stack(alignment: Alignment.center, children: <Widget>[
                      Padding(
                          padding: EdgeInsets.only(
                              top: 20.w, left: 15.w, right: 15.w),
                          child: Swiper(
                            controller: swiperController,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (BuildContext context, int index) {
                              return index == 0
                                  ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                          Center(
                                            child: Text(
                                              '兑换${product['pname']}',
                                              style: TextStyle(
                                                  fontSize: 18.sp,
                                                  color: StyleTheme.cTitleColor,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                          Flex(
                                              direction: Axis.horizontal,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Expanded(
                                                    flex: 1,
                                                    child: Container()),
                                                Expanded(
                                                    flex: 2,
                                                    child: Container(
                                                      margin: EdgeInsets.only(
                                                          top: 40.w,
                                                          bottom: 40.w),
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
                                                              fit: BoxFit
                                                                  .contain,
                                                            ),
                                                            SizedBox(
                                                              width: 11.w,
                                                            ),
                                                            Text.rich(TextSpan(
                                                                text: double.parse(
                                                                        product[
                                                                            'promo_price'])
                                                                    .toStringAsFixed(
                                                                        0),
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
                                                    child: coinsValue.isNotEmpty
                                                        ? Container(
                                                            margin:
                                                                EdgeInsets.only(
                                                                    top: 15.w),
                                                            child: Text(
                                                              '-$coinsValue元宝',
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
                                              ]),
                                          BottomLine(),
                                          rowText(
                                            '元宝优惠券',
                                            coinsValue.isEmpty
                                                ? '选择抵用券'
                                                : coinsValue.toString() +
                                                    '元宝抵用券',
                                            setBottomSheetState,
                                            coinsValue.isEmpty
                                                ? StyleTheme.cBioColor
                                                : StyleTheme.cDangerColor,
                                          ),
                                          BottomLine(),
                                          Center(
                                            child: Text(
                                              '最高可使用50%抵用券',
                                              style: TextStyle(
                                                  color: Color(0xFF969696),
                                                  fontSize: 14.sp),
                                            ),
                                          ),
                                          Expanded(
                                              child: Center(
                                                  child: GestureDetector(
                                                      onTap: () {
                                                        if (double.parse(money
                                                                .toString()) <
                                                            (double.parse(product[
                                                                    'promo_price']
                                                                .toString()))) {
                                                          BotToast.showText(
                                                              text: '元宝不足',
                                                              align: Alignment(
                                                                  0, 0));
                                                          AppGlobal.appRouter
                                                              ?.push(CommonUtils
                                                                  .getRealHash(
                                                                      'ingotWallet'));
                                                        } else {
                                                          onBuyMember(product);
                                                        }
                                                      },
                                                      child: Container(
                                                          margin:
                                                              EdgeInsets.only(
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
                                                                  double.parse(money
                                                                              .toString()) <
                                                                          (double.parse(
                                                                              product['promo_price'].toString()))
                                                                      ? '余额不足,去充值'
                                                                      : nowPay,
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          15.sp,
                                                                      color: Colors
                                                                          .white),
                                                                )),
                                                              ])))))
                                        ])
                                  : youHuiQuan(setBottomSheetState);
                            },
                            itemCount: 2,
                            layout: SwiperLayout.DEFAULT,
                            itemWidth: double.infinity,
                            itemHeight: double.infinity,
                          ))
                    ])));
          });
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
                  selectValue = [];
                  selectId = [];
                  coinsValue = "";
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
                '选择抵扣券',
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
                onChangeCoupon();
              },
              child: Text('确定',
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: StyleTheme.cTitleColor,
                  )),
            )
          ],
        )),
        SelectMultipleCoupon(
            isSelect: selectId,
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
                  // if (int.parse(widget.fee.toString()) < 200) {
                  //   CommonUtils.showText('预约金大于200才能使用优惠券哦');
                  //   return;
                  // }
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

  Widget monyCart(Map item) {
    String promoPrice = double.parse(item['promo_price']).toStringAsFixed(0);
    return GestureDetector(
      onTap: () {
        showPay(item);
      },
      child: Container(
          height: 90.w,
          width: 168.w,
          decoration: BoxDecoration(
              color: Color(0xFFFDF8E5),
              borderRadius: BorderRadius.circular(10.w),
              border: Border.all(width: 2.w, color: Color(0xFFFEE7DF))),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                item['pname'].toString(),
                style: TextStyle(color: Color(0xFF505050), fontSize: 15.sp),
              ),
              Text(
                '¥$promoPrice',
                style: TextStyle(
                    color: Color(0xFF505050),
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w500),
              ),
            ],
          )),
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
