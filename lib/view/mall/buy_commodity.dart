import 'package:chaguaner2023/components/cgDialog.dart';
import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/page_status.dart';
import 'package:chaguaner2023/components/page_title_bar.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class BuyCommodityPage extends StatefulWidget {
  const BuyCommodityPage({Key? key, this.id}) : super(key: key);
  final int? id;
  @override
  State<BuyCommodityPage> createState() => _BuyCommodityPageState();
}

class _BuyCommodityPageState extends State<BuyCommodityPage> {
  ValueNotifier<int> buyNum = ValueNotifier(1);
  Map data = {};
  bool loading = true;
  String contactInfo = '';
  String shippingAddress = '';
  String remark = '';
  Widget _pageItemWidget({String? title, Widget? right}) {
    return Container(
      height: 57.w,
      decoration: BoxDecoration(
          border:
              Border(bottom: BorderSide(width: 1.w, color: Color(0xffeeeeee)))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title!,
            style: TextStyle(color: Color(0xff1e1e1e), fontSize: 14.sp),
          ),
          SizedBox(
            width: 15.w,
          ),
          right!
        ],
      ),
    );
  }

  _payMoney() {
    if (contactInfo.trim().isEmpty) {
      CommonUtils.showText('请输入联系方式');
      return;
    }
    if(contactInfo.trim().length < 8) {
      CommonUtils.showText('请至少输入8位联系方式');
      return;
    }
    if (shippingAddress.trim().isEmpty) {
      CommonUtils.showText('请输入收货地址');
      return;
    }
    if (shippingAddress.trim().length > 300) {
      CommonUtils.showText('收货地址不能超过300字');
      return;
    }
    PageStatus.showLoading();
    productBuy(
            product_id: widget.id,
            qty: buyNum.value,
            contact_info: contactInfo,
            shipping_address: shippingAddress,
            remark: remark)
        .then((res) {
          print(res);
      if (res!['status'] != 0) {
        CgDialog.cgShowDialog(
            context, '购买成功', '已支付，请等待商家发货，可前往我的订单查看详情', ['朕知道了'], callBack: () {
          context.pop();
        });
      } else {
        CommonUtils.showText(res['msg'] ?? '系统错误～');
      }
    }).whenComplete(() {
      PageStatus.closeLoading();
    });
  }

  @override
  void initState() {
    super.initState();
    productList(widget.id).then((res) {
      if (res!['status'] != 0) {
        data = res['data'];
        loading = false;
        setState(() {});
      } else {
        CommonUtils.showText(res['msg'] ?? '系统错误～');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: HeaderContainer(
          child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: PreferredSize(
                  child: PageTitleBar(
                    title: '立即购买',
                  ),
                  preferredSize: Size(double.infinity, 44.w)),
              body: loading
                  ? PageStatus.loading(true)
                  : ListView(
                      padding: EdgeInsets.all(15.w),
                      children: [
                        _pageItemWidget(
                            title: '商品类型',
                            right: Text(
                              data['goods_type']['name'].toString(),
                              style: TextStyle(
                                  color: Color(0xff1e1e1e), fontSize: 15.sp),
                            )),
                        _pageItemWidget(
                            title: '商品数量',
                            right: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    if (buyNum.value > 1) {
                                      buyNum.value--;
                                    }
                                  },
                                  child: LocalPNG(
                                    url: 'assets/images/icon_jian_b.png',
                                    width: 20.5.w,
                                    height: 20.5.w,
                                  ),
                                ),
                                Container(
                                  height: 20.5.w,
                                  margin:
                                      EdgeInsets.symmetric(horizontal: 4.5.w),
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 15.w),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      color: Color(0xffdedede),
                                      borderRadius: BorderRadius.circular(5.w)),
                                  child: ValueListenableBuilder(
                                      valueListenable: buyNum,
                                      builder: (context, value, child) {
                                        return Text(
                                          value.toString(),
                                          style: TextStyle(
                                              color: Color(0xff1e1e1e),
                                              fontSize: 15.sp),
                                        );
                                      }),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    buyNum.value++;
                                  },
                                  child: LocalPNG(
                                    url: 'assets/images/icon_jia_b.png',
                                    width: 20.5.w,
                                    height: 20.5.w,
                                  ),
                                )
                              ],
                            )),
                        _pageItemWidget(
                            title: '商品价格',
                            right: Text(
                              '${data['price'].toString().split('.')[0]}元宝',
                              style: TextStyle(
                                  color: Color(0xff1e1e1e), fontSize: 15.sp),
                            )),
                        _pageItemWidget(
                            title: '联系方式',
                            right: Expanded(
                                child: TextField(
                              textAlign: TextAlign.right,
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.phone,
                              onChanged: (e) {
                                contactInfo = e;
                              },
                              decoration: InputDecoration(
                                hintText: '请输入联系方式',
                                hintStyle: TextStyle(
                                    color: Color(0xffb4b4b4), fontSize: 15.sp),
                                labelStyle: TextStyle(
                                    color: Color(0xff1e1e1e), fontSize: 15.sp),
                                border: InputBorder
                                    .none, // Removes the default border
                              ),
                            ))),
                        SizedBox(
                          height: 25.w,
                        ),
                        Text(
                          '收货地址',
                          style: TextStyle(
                              color: Color(0xff1e1e1e), fontSize: 18.sp),
                        ),
                        Container(
                          height: 140.w,
                          padding: EdgeInsets.all(10.w),
                          margin: EdgeInsets.only(top: 17.w),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.w),
                              color: Color(0xfff5f5f5)),
                          child: TextField(
                            maxLines: 999,
                            onChanged: (e) {
                              shippingAddress = e;
                            },
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.zero,
                              hintText: '请输入您的收货地址',
                              hintStyle: TextStyle(
                                  color: Color(0xffb4b4b4), fontSize: 15.sp),
                              labelStyle: TextStyle(
                                  color: Color(0xff1e1e1e), fontSize: 15.sp),
                              border: InputBorder
                                  .none, // Removes the default border
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 25.w,
                        ),
                        Text('备注(选填)',
                            style: TextStyle(
                                color: Color(0xff1e1e1e), fontSize: 18.sp)),
                        SizedBox(
                          height: 17.w,
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 17.w),
                          height: 94.5.w,
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.w),
                              color: Color(0xfff5f5f5)),
                          child: TextField(
                            maxLines: 999,
                            maxLength: 100,
                            onChanged: (e) {
                              remark = e;
                            },
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.zero,
                              hintText: '请输入备注信息',
                              counterStyle: TextStyle(
                                  color: Color(0xffb4b4b4), fontSize: 15.sp),
                              hintStyle: TextStyle(
                                  color: Color(0xffb4b4b4), fontSize: 15.sp),
                              labelStyle: TextStyle(
                                  color: Color(0xff1e1e1e), fontSize: 15.sp),
                              border: InputBorder
                                  .none, // Removes the default border
                            ),
                          ),
                        ),
                        Text(
                          '温馨提示：\n请按照格式输入信息，支付前请确认信息是否正确',
                          style: TextStyle(
                              color: Color(0xffff4149), fontSize: 13.sp),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 24.w),
                          child: Center(
                            child: GestureDetector(
                              onTap: _payMoney,
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                      child: LocalPNG(
                                          url:
                                              'assets/images/elegantroom/shuimo_btn.png')),
                                  Container(
                                    width: 275.w,
                                    height: 50.w,
                                    alignment: Alignment.center,
                                    child: Text(
                                      '确认支付',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 15.sp),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ))),
    );
  }
}
