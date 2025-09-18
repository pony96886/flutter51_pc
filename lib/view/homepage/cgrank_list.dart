import 'package:chaguaner2023/components/card/V3zhaopiaoCard.dart';
import 'package:chaguaner2023/components/card/reportCard.dart';
import 'package:chaguaner2023/components/card/reportNewCard.dart';
import 'package:chaguaner2023/components/card/rezhengRankCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:chaguaner2023/components/card/elegantRankCard.dart';
import 'package:chaguaner2023/components/card/rankCard.dart';
import 'package:chaguaner2023/components/list/public_list.dart';
import 'package:chaguaner2023/components/nodata.dart';
import 'package:chaguaner2023/view/homepage/squarePages.dart';

import '../../components/filterTabsContainer.dart';

class CGRankList extends StatefulWidget {
  final int type;
  final List? tab;
  const CGRankList({Key? key, required this.type, this.tab}) : super(key: key);

  @override
  State<CGRankList> createState() => _CGRankListState();
}

class _CGRankListState extends State<CGRankList> {
  Map tabList = {};
  int selectTab = 0;
  @override
  void initState() {
    super.initState();
    tabList = {
      'tags': widget.tab!.map((item) => {...item, 'title': item['name']}).toList(),
    };
  }

  @override
  Widget build(BuildContext context) {
    List _tabList = tabList.keys.toList();
    final isTypeVer = widget.type == 0 || widget.type == 1;
    return Column(
      children: [
        Container(
            padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 8.w),
            width: double.infinity,
            margin: EdgeInsets.only(top: 15.w),
            color: Color(0xfff8f6f1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _tabList.asMap().keys.map((index) {
                return SingleChildScrollView(
                    padding: EdgeInsets.zero,
                    scrollDirection: Axis.horizontal,
                    child: FilterTabsContainer(
                      tabs: tabList['tags'],
                      selectTabIndex: selectTab,
                      onTabs: (e) {
                        selectTab = e;
                        setState(() {});
                      },
                    ));
              }).toList(),
            )),
        Expanded(
            child: PublicList(
                row: isTypeVer ? 2 : 1,
                aspectRatio: isTypeVer ? 1.5 : (170.5 / 275.5),
                isFlow: isTypeVer,
                api: '/api/ranking/list',
                noController: true,
                mainAxisSpacing: 10.w,
                crossAxisSpacing: 6.w,
                data: {
                  "rank_type": widget.type,
                  "rank_time": widget.tab!.isEmpty ? 'day' : widget.tab![selectTab]["type"],
                },
                isShow: true,
                noData: NoData(text: '还没有商品哦～'),
                itemBuild: (context, index, data, page, limit, getListData) {
                  if (widget.type == 0) {
                    return ElegantRankCard(cardInfo: data);
                  }
                  if (widget.type == 1) {
                    return RenZhengRankCard(
                      chapuData: data,
                      isNew: data['is_new'] ?? true,
                    );
                  }
                  if (widget.type == 2) {
                    return V3ZhaoPiaoCard(isPeifu: true, zpInfo: data);
                  }
                  if (widget.type == 3) {
                    return ReportNewCard(reportInfo: data);
                  }
                  if (widget.type == 4) {
                    return V3ZhaoPiaoCard(zpInfo: data);
                  }
                  return RankCard(data: data);
                }))
      ],
    );
  }
}
