import 'package:chaguaner2023/components/card/mallCard.dart';
import 'package:chaguaner2023/components/list/public_list.dart';
import 'package:chaguaner2023/components/nodata.dart';
import 'package:chaguaner2023/view/homepage/squarePages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../components/filterTabsContainer.dart';

class CGmaillList extends StatefulWidget {
  final List? orderBy;
  final List? tags;
  final int? goodsType;

  const CGmaillList({Key? key, this.orderBy, this.tags, this.goodsType}) : super(key: key);

  @override
  State<CGmaillList> createState() => _CGmaillListState();
}

class _CGmaillListState extends State<CGmaillList> {
  Map tabList = {};
  Map selectTab = {"orderBy": 0, "tags": 0};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabList = {
      'orderBy': widget.orderBy,
      'tags': widget.tags!.map((item) => {...item, 'title': item['name']}).toList(),
    };
  }

  @override
  Widget build(BuildContext context) {
    List _tabList = tabList.keys.toList();
    return Column(
      children: [
        Container(
            padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 8.w),
            width: double.infinity,
            margin: EdgeInsets.only(top: 15.w),
            color: Color(0xfff8f6f1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _tabList.asMap().keys.map((index) {
                String _key = _tabList[index];
                return Padding(
                  padding: EdgeInsets.only(top: index != 0 && tabList[_key].isNotEmpty ? 15.w : 0),
                  child: SingleChildScrollView(
                      padding: EdgeInsets.zero,
                      scrollDirection: Axis.horizontal,
                      child: FilterTabsContainer(
                        tabs: tabList[_key],
                        selectTabIndex: selectTab[_key],
                        selectTabTextStyle: TextStyle(color: Color(0xff646464), fontSize: 12.sp),
                        onTabs: (e) {
                          selectTab[_tabList[index]] = e;
                          setState(() {});
                        },
                      )),
                );
              }).toList(),
            )),
        Expanded(
            child: PublicList(
                row: 2,
                aspectRatio: 170.5 / 275.5,
                api: '/api/product/list',
                noController: true,
                mainAxisSpacing: 10.w,
                crossAxisSpacing: 6.w,
                data: {
                  "orderBy": widget.orderBy!.isEmpty ? null : widget.orderBy![selectTab["orderBy"]]['value'],
                  "tag_id": widget.tags!.isEmpty ? null : widget.tags![selectTab["tags"]]['id'],
                  "goods_type": widget.goodsType
                },
                isShow: true,
                noData: NoData(
                  text: '还没有商品哦～',
                ),
                itemBuild: (context, index, data, page, limit, getListData) {
                  return MallGirlCard(data: data);
                }))
      ],
    );
  }
}
