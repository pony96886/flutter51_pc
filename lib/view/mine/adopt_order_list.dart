import 'package:chaguaner2023/components/card/adoptCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/netimage_tool.dart';
import 'package:chaguaner2023/components/list/public_list.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/pageviewmixin.dart';

class AdoptOrderList extends StatefulWidget {
  AdoptOrderList({Key? key}) : super(key: key);

  @override
  _AdoptOrderListState createState() => _AdoptOrderListState();
}

class _AdoptOrderListState extends State<AdoptOrderList> {
  @override
  Widget build(BuildContext context) {
    return PageViewMixin(
      child: PublicList(
          isShow: true,
          limit: 15,
          isFlow: false,
          isSliver: false,
          api: '/api/keep/order_list',
          mainAxisSpacing: 7.w,
          crossAxisSpacing: 7.w,
          aspectRatio: 0.7,
          row: 2,
          itemBuild: (context, index, data, page, limit, getListData) {
            return AdoptCard(adoptData: data);
          }),
    );
  }
}
