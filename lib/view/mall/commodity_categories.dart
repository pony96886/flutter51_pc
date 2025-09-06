import 'package:chaguaner2023/components/card/mallCard.dart';
import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/list/public_list.dart';
import 'package:chaguaner2023/components/pagetitlebar.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/netimage_tool.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/cache/image_net_tool.dart';

class CommodityCategories extends StatefulWidget {
  const CommodityCategories({Key? key, this.id}) : super(key: key);
  final int? id;
  @override
  State<CommodityCategories> createState() => _CommodityCategoriesState();
}

class _CommodityCategoriesState extends State<CommodityCategories> {
  String currentType = 'new';
  Map data = {};
  bool loading = true;
  List tabList = [
    {
      'name': '最新',
      'key': 'new',
    },
    {
      'name': '最热',
      'key': 'hottest',
    }
  ];
  @override
  void initState() {
    super.initState();
    productCategoryDetail(widget.id!).then((res) {
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
    return HeaderContainer(
        child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: PreferredSize(
                child: PageTitleBar(
                  title: loading ? '' : data['name'],
                ),
                preferredSize: Size(double.infinity, 44.w)),
            body: NestedScrollView(
              headerSliverBuilder: (context, _v) {
                return [
                  SliverAppBar(
                    expandedHeight: 112.5.w,
                    floating: false,
                    pinned: true,
                    leading: Container(),
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 13.5.w, vertical: 11.w),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 90.w,
                              height: 90.w,
                              child: ImageNetTool(
                                url: data['img'] ?? '111',
                                radius: BorderRadius.circular(5.w),
                              ),
                            ),
                            SizedBox(
                              width: 17.w,
                            ),
                            Expanded(
                                child: SizedBox(
                              height: 90.w,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    data['description'] ?? '',
                                    style: TextStyle(
                                        color: StyleTheme.cTitleColor,
                                        fontSize: 18.sp),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  DefaultTextStyle(
                                      style: TextStyle(
                                          color: StyleTheme.cBioColor,
                                          fontSize: 12.sp),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('${data['product_num']}个商品'),
                                          Text('${data['buy_num']}人付款'),
                                        ],
                                      )),
                                  SizedBox(
                                    height: 14.w,
                                  )
                                ],
                              ),
                            ))
                          ],
                        ),
                      ),
                    ),
                  )
                ];
              },
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PreferredSize(
                    preferredSize: Size.fromHeight(55.w),
                    child: Container(
                      color: Colors.white,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 14.5.w, vertical: 15.5.w),
                        child: Row(
                          children: tabList
                              .map((e) => InkWell(
                                    onTap: () {
                                      currentType = e['key'];
                                      setState(() {});
                                    },
                                    child: Container(
                                      height: 25.w,
                                      width: 78.w,
                                      alignment: Alignment.center,
                                      margin: EdgeInsets.only(right: 15.w),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12.5.w),
                                          color: currentType == e['key']
                                              ? Color(0xffff4149)
                                              : Colors.transparent),
                                      child: Text(
                                        e['name'],
                                        style: TextStyle(
                                            color: currentType == e['key']
                                                ? Colors.white
                                                : StyleTheme.cTitleColor,
                                            fontSize: 14.sp),
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                      child: PublicList(
                          isShow: true,
                          limit: 20,
                          isSliver: false,
                          aspectRatio: 170.5 / 275.5,
                          api: '/api/product/list',
                          data: {'goods_type': widget.id, 'tag': currentType},
                          row: 2,
                          itemBuild:
                              (context, index, data, page, limit, getListData) {
                            return MallGirlCard(
                              data: data,
                            );
                          })),
                ],
              ),
            )));
  }
}
