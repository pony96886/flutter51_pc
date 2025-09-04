import 'package:chaguaner2023/components/card/mallCard.dart';
import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/list/public_list.dart';
import 'package:chaguaner2023/components/nodata.dart';
import 'package:chaguaner2023/components/page_status.dart';
import 'package:chaguaner2023/components/pagetitlebar.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MerchantHome extends StatefulWidget {
  const MerchantHome({Key? key, this.uuid}) : super(key: key);
  final String? uuid;
  @override
  State<MerchantHome> createState() => _MerchantHomeState();
}

class _MerchantHomeState extends State<MerchantHome> {
  Map user = {};
  bool loading = true;
  @override
  void initState() {
    super.initState();
    getInfoByUUID(widget.uuid!).then((res) {
      if (res['status'] != 0) {
        user = res['data'][0];
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
                child: PageTitleBar(title: ''),
                preferredSize: Size(double.infinity, 44.w)),
            body: loading
                ? PageStatus.loading(true)
                : NestedScrollView(
                    headerSliverBuilder: (context, _v) {
                      return [
                        SliverAppBar(
                          expandedHeight: 123.5.w,
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
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(45.w),
                                    child: SizedBox(
                                      width: 90.w,
                                      height: 90.w,
                                      child: LocalPNG(
                                        width: double.infinity,
                                        height: double.infinity,
                                        url:
                                            'assets/images/common/${user['thumb']}.png',
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 17.w,
                                  ),
                                  Expanded(
                                      child: SizedBox(
                                    height: 90.w,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          user['nickname'].toString(),
                                          style: TextStyle(
                                              color: StyleTheme.cTitleColor,
                                              fontSize: 18.sp),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(
                                          height: 20.w,
                                        ),
                                        Text('发布${user['goods_num']}个商品',
                                            style: TextStyle(
                                                color: StyleTheme.cTitleColor,
                                                fontSize: 15.sp)),
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
                    body: PublicList(
                        row: 2,
                        aspectRatio: 170.5 / 275.5,
                        api: '/api/product/list',
                        noController: true,
                        mainAxisSpacing: 10.w,
                        crossAxisSpacing: 6.w,
                        data: {'uuid': widget.uuid},
                        isShow: true,
                        noData: NoData(
                          text: '还没有商品哦～',
                        ),
                        itemBuild:
                            (context, index, data, page, limit, getListData) {
                          return MallGirlCard(data: data);
                        }),
                  )));
  }
}
