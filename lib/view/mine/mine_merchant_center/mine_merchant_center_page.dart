import 'package:chaguaner2023/components/card/mallCard.dart';
import 'package:chaguaner2023/components/card/mall_order_card.dart';
import 'package:chaguaner2023/components/cg_tabview.dart';
import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/list/public_list.dart';
import 'package:chaguaner2023/components/nodata.dart';
import 'package:chaguaner2023/components/page_title_bar.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/pageviewmixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class MineMerchantCenterPage extends StatefulWidget {
  const MineMerchantCenterPage({Key? key}) : super(key: key);

  @override
  State<MineMerchantCenterPage> createState() => _MineMerchantCenterPageState();
}

class _MineMerchantCenterPageState extends State<MineMerchantCenterPage> {
  @override
  Widget build(BuildContext context) {
    return HeaderContainer(
        child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: PreferredSize(
                child: PageTitleBar(
                  title: '商家中心',
                  rightWidget: GestureDetector(
                    child: GestureDetector(
                      onTap: () {
                        context.push('/mallPublish');
                      },
                      child: Text(
                        '发布',
                        style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 14.sp),
                      ),
                    ),
                  ),
                ),
                preferredSize: Size(double.infinity, 44.w)),
            body: CgTabView(
              isCenter: true,
              isFlex: false,
              spacing: 66.5.w,
              padding: EdgeInsets.symmetric(vertical: 12.w),
              tabs: ['我的商品', '订单列表'],
              pages: [
                CgTabView(
                    padding: EdgeInsets.only(bottom: 12.w),
                    isCenter: true,
                    isFlex: false,
                    type: CgTabType.redRaduis,
                    defaultStyle: TextStyle(color: Color(0xff1e1e1e), fontSize: 14.w),
                    activeStyle: TextStyle(color: Colors.white, fontSize: 14.w),
                    tabs: [
                      '审核中',
                      '审核通过',
                      '审核失败',
                    ],
                    pages: [
                      PageViewMixin(
                        child: PublicList(
                            row: 2,
                            aspectRatio: 170.5 / 275.5,
                            api: '/api/product/my_product_list',
                            noController: true,
                            mainAxisSpacing: 10.w,
                            crossAxisSpacing: 6.w,
                            emitName: 'producta',
                            data: {'tag': 0},
                            isShow: true,
                            noData: NoData(
                              text: '还没有商品哦～',
                            ),
                            itemBuild: (context, index, data, page, limit, getListData) {
                              return MallGirlCard(
                                data: data,
                                isDelete: true,
                              );
                            }),
                      ),
                      PageViewMixin(
                        child: PublicList(
                            row: 2,
                            aspectRatio: 170.5 / 275.5,
                            api: '/api/product/my_product_list',
                            noController: true,
                            mainAxisSpacing: 10.w,
                            crossAxisSpacing: 6.w,
                            emitName: 'productb',
                            data: {'tag': 1},
                            isShow: true,
                            noData: NoData(
                              text: '还没有商品哦～',
                            ),
                            itemBuild: (context, index, data, page, limit, getListData) {
                              return MallGirlCard(
                                data: data,
                                isDelete: true,
                              );
                            }),
                      ),
                      PageViewMixin(
                        child: PublicList(
                            row: 2,
                            aspectRatio: 170.5 / 275.5,
                            api: '/api/product/my_product_list',
                            noController: true,
                            mainAxisSpacing: 10.w,
                            crossAxisSpacing: 6.w,
                            data: {'tag': 2},
                            emitName: 'productc',
                            isShow: true,
                            noData: NoData(
                              text: '还没有商品哦～',
                            ),
                            itemBuild: (context, index, data, page, limit, getListData) {
                              return MallGirlCard(
                                data: data,
                                isDelete: true,
                              );
                            }),
                      ),
                    ]),
                CgTabView(
                    padding: EdgeInsets.only(bottom: 12.w, left: 15.w, right: 15.w),
                    isCenter: false,
                    isFlex: true,
                    type: CgTabType.redRaduis,
                    defaultStyle: TextStyle(color: Color(0xff1e1e1e), fontSize: 14.w),
                    activeStyle: TextStyle(color: Colors.white, fontSize: 14.w),
                    tabs: [
                      '全部',
                      '待发货',
                      '已发货',
                      '已收货',
                    ],
                    pages: [
                      PageViewMixin(
                        child: PublicList(
                            api: '/api/product/order_list',
                            noController: true,
                            mainAxisSpacing: 10.w,
                            crossAxisSpacing: 6.w,
                            data: {'for_seller': 1, 'status': -1},
                            isShow: true,
                            noData: NoData(
                              text: '还没有商品哦～',
                            ),
                            itemBuild: (context, index, data, page, limit, getListData) {
                              return MallOrderCard(data: data, isEller: true);
                            }),
                      ),
                      PageViewMixin(
                        child: PublicList(
                            api: '/api/product/order_list',
                            noController: true,
                            mainAxisSpacing: 10.w,
                            crossAxisSpacing: 6.w,
                            data: {'for_seller': 1, 'status': 0},
                            isShow: true,
                            noData: NoData(
                              text: '还没有商品哦～',
                            ),
                            itemBuild: (context, index, data, page, limit, getListData) {
                              return MallOrderCard(data: data, isEller: true);
                            }),
                      ),
                      PageViewMixin(
                        child: PublicList(
                            api: '/api/product/order_list',
                            noController: true,
                            mainAxisSpacing: 10.w,
                            crossAxisSpacing: 6.w,
                            data: {'for_seller': 1, 'status': 1},
                            isShow: true,
                            noData: NoData(
                              text: '还没有商品哦～',
                            ),
                            itemBuild: (context, index, data, page, limit, getListData) {
                              return MallOrderCard(data: data, isEller: true);
                            }),
                      ),
                      PageViewMixin(
                        child: PublicList(
                            api: '/api/product/order_list',
                            noController: true,
                            mainAxisSpacing: 10.w,
                            crossAxisSpacing: 6.w,
                            data: {'for_seller': 1, 'status': 2},
                            isShow: true,
                            noData: NoData(
                              text: '还没有商品哦～',
                            ),
                            itemBuild: (context, index, data, page, limit, getListData) {
                              return MallOrderCard(
                                data: data,
                                isEller: true,
                              );
                            }),
                      ),
                      PageViewMixin(
                        child: PublicList(
                            api: '/api/product/order_list',
                            noController: true,
                            mainAxisSpacing: 10.w,
                            crossAxisSpacing: 6.w,
                            data: {'for_seller': 1, 'status': 3},
                            isShow: true,
                            noData: NoData(
                              text: '还没有商品哦～',
                            ),
                            itemBuild: (context, index, data, page, limit, getListData) {
                              return MallOrderCard(data: data, isEller: true);
                            }),
                      ),
                    ]),
              ],
            )));
  }
}
