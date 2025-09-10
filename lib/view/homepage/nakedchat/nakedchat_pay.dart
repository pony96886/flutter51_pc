import 'package:bot_toast/bot_toast.dart';
import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/page_title_bar.dart';
import 'package:chaguaner2023/store/homeConfig.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/cgprivilege.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:chaguaner2023/view/yajian/vip_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class NakedChatPay extends StatefulWidget {
  final Map? data;
  const NakedChatPay({Key? key, this.data}) : super(key: key);

  @override
  State<NakedChatPay> createState() => _NakedChatPayState();
}

class _NakedChatPayState extends State<NakedChatPay> {
  String selectConnect = '手机';
  final myController = TextEditingController();
  List selectServes = [];
  int selectTime = -99;
  double timePrice = 0;
  double serverPrice = 0;
  num discount = 100;
  ValueNotifier<double> totalPrice = ValueNotifier(0);
  @override
  void dispose() {
    // TODO: implement dispose
    totalPrice.dispose();
    super.dispose();
  }

  Widget checkboxServes(String title) {
    String seleStr = 'select';
    String luesS = 'unselect';
    String sercStr = selectConnect == title ? seleStr : luesS;
    return GestureDetector(
      onTap: () {
        if (selectConnect != title) {
          setState(() {
            selectConnect = title;
          });
        }
      },
      child: Container(
        margin: EdgeInsets.only(right: 15.5.w),
        child: Row(
          children: <Widget>[
            Text(title),
            Container(
              width: 15.w,
              height: 15.w,
              margin: EdgeInsets.only(left: CommonUtils.getWidth(11)),
              child: LocalPNG(
                width: 15.w,
                height: 15.w,
                url: 'assets/images/card/$sercStr.png',
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget serversItem(Map item, int index) {
    String seleStr = 'select';
    String luesS = 'unselect';
    String sercStr = selectServes.indexOf(index) > -1 ? seleStr : luesS;
    return Padding(
      padding: EdgeInsets.only(bottom: 10.w),
      child: GestureDetector(
        onTap: () {
          if (selectServes.indexOf(index) > -1) {
            selectServes.remove(index);
            setState(() {});
          } else {
            selectServes.add(index);
            setState(() {});
          }
          serverPrice = 0;
          selectServes.forEach((e) {
            serverPrice +=
                double.parse(widget.data!['addition_items'][e]['coin']);
          });
          totalPrice.value = serverPrice + timePrice;
        },
        child: Container(
          height: 45.w,
          padding: EdgeInsets.symmetric(horizontal: 9.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.w),
            color: Color.fromRGBO(245, 245, 245, 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item['name'],
                style:
                    TextStyle(color: StyleTheme.cTitleColor, fontSize: 14.sp),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${item['coin']}元宝',
                    style: TextStyle(
                        color: StyleTheme.cTitleColor, fontSize: 14.sp),
                  ),
                  SizedBox(
                    width: 10.5.w,
                  ),
                  LocalPNG(
                    width: 15.w,
                    height: 15.w,
                    url: 'assets/images/card/$sercStr.png',
                    fit: BoxFit.cover,
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget rowText(String title, String content) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 14.sp, color: Color(0xFF969693)),
        ),
        Text(
          content,
          style: TextStyle(fontSize: 14.sp, color: StyleTheme.cTitleColor),
        )
      ],
    );
  }

  Future showPay() {
    return showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          double money =
              double.parse('${Provider.of<HomeConfig>(context).member.money}');
          return StatefulBuilder(builder: (context, setBottomSheetState) {
            return Container(
              height: 430 + ScreenUtil().bottomBarHeight,
              padding: EdgeInsets.only(
                  bottom: ScreenUtil().bottomBarHeight + 24.w,
                  left: 15.w,
                  right: 15.w),
              color: Colors.white,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 14.w),
                    child: Text(
                      '支付预约金',
                      style: TextStyle(
                          color: StyleTheme.cTitleColor, fontSize: 18.sp),
                    ),
                  ),
                  SizedBox(
                    height: 18.w,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ValueListenableBuilder(
                          valueListenable: totalPrice,
                          builder: (context, double value, child) {
                            return Text(
                              '${discount > 0 ? value * (discount / 100) : value}',
                              style: TextStyle(
                                  color: StyleTheme.cTitleColor,
                                  fontSize: 36.w),
                            );
                          }),
                      Text('元宝',
                          style: TextStyle(
                              color: StyleTheme.cTitleColor, fontSize: 18.w)),
                    ],
                  ),
                  SizedBox(
                    height: 10.w,
                  ),
                  Center(
                    child: Text(
                      '账户余额：$money 元宝',
                      style: TextStyle(
                          color: StyleTheme.cDangerColor, fontSize: 12.sp),
                    ),
                  ),
                  SizedBox(
                    height: 32.w,
                  ),
                  BottomLine(),
                  rowText('预约妹子', widget.data!['title']),
                  BottomLine(),
                  rowText('发布用户', widget.data!['user']['nickname']),
                  BottomLine(),
                  Spacer(),
                  GestureDetector(
                    onTap: () {
                      if (myController.text.isEmpty) {
                        CommonUtils.showText('请输入联系方式');
                        return;
                      }
                      if (selectTime < 0) {
                        CommonUtils.showText('请选择时间');
                        return;
                      }
                      List additionItems = [];
                      selectServes.forEach((e) {
                        additionItems
                            .add(widget.data!['addition_items'][e]['id']);
                      });
                      if (money < totalPrice.value) {
                        AppGlobal.appRouter
                            ?.push(CommonUtils.getRealHash('ingotWallet'));
                      } else {
                        Navigator.pop(context);
                        BotToast.showLoading();
                        getGirlchatBuy(
                                user_contact:
                                    '($selectConnect)${myController.text}',
                                time_set_id: selectTime,
                                girl_chat_id: widget.data!['girl_chat_id'],
                                addition_ids: additionItems)
                            .then((res) {
                          if (res!['status'] != 0) {
                            AppGlobal.appRouter?.push(
                                CommonUtils.getRealHash('nakedChatSuccess'),
                                extra: {
                                  ...widget.data!,
                                  'price': discount > 0
                                      ? totalPrice.value * (discount / 100)
                                      : totalPrice.value
                                });
                            CommonUtils.showText('预约成功');
                          } else {
                            CommonUtils.showText(res['msg']);
                          }
                        }).whenComplete(() {
                          BotToast.closeAllLoading();
                        });
                        BotToast.closeAllLoading();
                      }
                    },
                    child: Stack(
                      children: [
                        LocalPNG(
                          width: 275.w,
                          height: 50.w,
                          url: 'assets/images/mymony/money-img.png',
                        ),
                        Positioned.fill(
                            child: Center(
                                child: Text(
                          money < totalPrice.value ? '余额不足,去充值' : '立即预约',
                          style: TextStyle(fontSize: 15.w, color: Colors.white),
                        ))),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 7.5.w,
                  ),
                  Text(
                    '未服务前请勿点确认',
                    style: TextStyle(
                        color: StyleTheme.cDangerColor, fontSize: 12.sp),
                  )
                ],
              ),
            );
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    discount = CgPrivilege.getPrivilegeNumber(
        PrivilegeType.infoGirlChat, PrivilegeType.privilegeDiscount);
    return HeaderContainer(
        child: Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          PageTitleBar(
            title: '裸聊预约',
          ),
          Expanded(
              child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 18.w),
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '联系方式 ',
                    style: TextStyle(
                        color: StyleTheme.cTitleColor, fontSize: 16.sp),
                  ),
                  Text('金额支付完成后，请保持联系方式畅通',
                      style: TextStyle(
                          color: StyleTheme.cDangerColor, fontSize: 12.sp)),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(top: 30.w, bottom: 40.w),
                child: Row(
                  children: [
                    checkboxServes('手机'),
                    checkboxServes('微信'),
                    checkboxServes('QQ'),
                    Expanded(
                        child: SizedBox(
                      height: 15.w,
                      child: TextField(
                        scrollPadding: EdgeInsets.zero,
                        controller: myController,
                        inputFormatters: <TextInputFormatter>[
                          LengthLimitingTextInputFormatter(18),
                          FilteringTextInputFormatter.deny(RegExp('[ ]'))
                        ],
                        onEditingComplete: () {
                          FocusScope.of(context).unfocus();
                        },
                        decoration: InputDecoration(
                          hintText: '输入联系$selectConnect',
                          hintStyle: TextStyle(color: StyleTheme.cBioColor),
                          contentPadding: EdgeInsets.zero,
                          fillColor: StyleTheme.textbgColor1,
                          disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: BorderSide(
                                  color: Colors.transparent, width: 0)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: BorderSide(
                                  color: Colors.transparent, width: 0)),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: BorderSide(
                                  color: Colors.transparent, width: 0)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: BorderSide(
                                  color: Colors.transparent, width: 0)),
                        ),
                        style: TextStyle(
                          fontSize: 12.sp,
                        ),
                      ),
                    ))
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '选择时间 ',
                    style: TextStyle(
                        color: StyleTheme.cTitleColor, fontSize: 16.sp),
                  ),
                  Text('${widget.data!['price_per_minute']}元宝/分钟',
                      style: TextStyle(
                          color: StyleTheme.cBioColor, fontSize: 12.sp)),
                ],
              ),
              GridView.builder(
                  padding: EdgeInsets.only(top: 33.w, bottom: 25.w),
                  shrinkWrap: true,
                  itemCount: widget.data!['time_set'].length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      childAspectRatio: 3.37,
                      crossAxisCount: 3,
                      mainAxisSpacing: 10.w,
                      crossAxisSpacing: 22.5.w),
                  itemBuilder: (context, index) {
                    bool isSelect =
                        (selectTime == widget.data!['time_set'][index]['id']);
                    return GestureDetector(
                      onTap: () {
                        selectTime = widget.data!['time_set'][index]['id'];
                        timePrice = double.parse(
                            '${widget.data!['time_set'][index]['price']}');
                        setState(() {});
                        totalPrice.value = serverPrice + timePrice;
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: isSelect
                                ? Colors.red
                                : Color.fromRGBO(245, 245, 245, 1),
                            borderRadius: BorderRadius.circular(30.w)),
                        child: Text(
                          widget.data!['time_set'][index]['title'].toString(),
                          style: TextStyle(
                              color: isSelect
                                  ? Colors.white
                                  : StyleTheme.cTitleColor,
                              fontSize: 14.sp),
                        ),
                      ),
                    );
                  }),
              Text(
                '附加项目',
                style:
                    TextStyle(color: StyleTheme.cTitleColor, fontSize: 16.sp),
              ),
              SizedBox(
                height: 20.w,
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.data!['addition_items']
                    .asMap()
                    .keys
                    .map<Widget>((int e) {
                  return serversItem(widget.data!['addition_items'][e], e);
                }).toList(),
              )
            ],
          )),
          Container(
            height: 49.w + ScreenUtil().bottomBarHeight,
            padding: EdgeInsets.only(
                bottom: ScreenUtil().bottomBarHeight, left: 24.w, right: 15.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ValueListenableBuilder(
                    valueListenable: totalPrice,
                    builder: (context, double value, child) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '合计：',
                                style: TextStyle(
                                    color: StyleTheme.cTitleColor,
                                    fontSize: 12.sp),
                              ),
                              Text(
                                '${discount > 0 ? value * (discount / 100) : value}元宝',
                                style: TextStyle(
                                    color: StyleTheme.cDangerColor,
                                    fontSize: 16.sp),
                              )
                            ],
                          ),
                          discount > 0
                              ? Text(
                                  '已优惠${value - value * (discount / 100)}元宝',
                                  style: TextStyle(
                                      color: StyleTheme.cTextColor,
                                      fontSize: 12.sp),
                                )
                              : SizedBox()
                        ],
                      );
                    }),
                GestureDetector(
                  // ignore: missing_return
                  onTap: showPay,
                  child: Container(
                    width: 110.w,
                    height: 40.w,
                    margin: new EdgeInsets.only(left: 10.w),
                    child: Stack(
                      children: [
                        LocalPNG(
                          width: 110.w,
                          height: 40.w,
                          url: 'assets/images/mymony/money-img.png',
                        ),
                        Center(
                          child: Text(
                            '立即预约',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    ));
  }
}
