import 'package:bot_toast/bot_toast.dart';
import 'package:chaguaner2023/components/card/V3zhaopiaoCard.dart';
import 'package:chaguaner2023/components/loading.dart';
import 'package:chaguaner2023/components/networkErr.dart';
import 'package:chaguaner2023/components/nodata.dart';
import 'package:chaguaner2023/components/pullrefreshlist.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:chaguaner2023/components/page_title_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PayoutList extends StatefulWidget {
  const PayoutList({Key? key}) : super(key: key);

  @override
  State<PayoutList> createState() => _PayoutListState();
}

class _PayoutListState extends State<PayoutList> {
  bool networkErr = false;
  bool loading = true;
  List chaCardList = [];

  @override
  void initState() {
    super.initState();
    _onLoad();
  }

  _onLoad() {
    listGuarantee().then((res) {
      if (res['status'] != 0) {
        setState(() {
          chaCardList = res['data'];
          loading = false;
        });
      } else {
        setState(() {
          networkErr = true;
          loading = false;
        });
        BotToast.showText(text: res.msg, align: Alignment(0, 0));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
            child: PageTitleBar(
              title: '赔付专区',
            ),
            preferredSize: Size(double.infinity, 44.w)),
        body: networkErr
            ? NetworkErr(
                errorRetry: () {
                  _onLoad();
                },
              )
            : (loading
                ? Loading()
                : (chaCardList.length == 0
                    ? NoData(
                        text: '茶老板已无言以对～',
                      )
                    : PullRefreshList(
                        onRefresh: () {
                          networkErr = false;
                          loading = true;
                          chaCardList = [];
                          _onLoad();
                        },
                        child: CustomScrollView(physics: ClampingScrollPhysics(), cacheExtent: 5.sh, slivers: [
                          SliverList(
                            delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
                              return V3ZhaoPiaoCard(isPeifu: true, zpInfo: chaCardList[index]);
                            }, childCount: chaCardList.length),
                          ),
                        ])))));
  }
}
