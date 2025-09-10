import 'package:bot_toast/bot_toast.dart';
import 'package:chaguaner2023/components/card/rezhengCard.dart';
import 'package:chaguaner2023/components/loading.dart';
import 'package:chaguaner2023/components/networkErr.dart';
import 'package:chaguaner2023/components/nodata.dart';
import 'package:chaguaner2023/components/pullrefreshlist.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:chaguaner2023/components/page_title_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AuthenticationList extends StatefulWidget {
  const AuthenticationList({Key? key}) : super(key: key);

  @override
  State<AuthenticationList> createState() => _AuthenticationListState();
}

class _AuthenticationListState extends State<AuthenticationList> {
  bool networkErr = false;
  bool loading = true;
  List chaCardList = [];

  @override
  void initState() {
    super.initState();
    _onLoad();
  }

  _onLoad() {
    listAuth().then((res) {
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
              title: '认证专区',
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
                    : Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15.w),
                        child: PullRefreshList(
                            onRefresh: () {
                              networkErr = false;
                              loading = true;
                              chaCardList = [];
                              _onLoad();
                            },
                            child: CustomScrollView(
                              physics: ClampingScrollPhysics(),
                              cacheExtent: 5.sh,
                              slivers: [
                                SliverGrid(
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 0.7,
                                    mainAxisSpacing: 5.w,
                                    crossAxisSpacing: 5.w,
                                  ),
                                  delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
                                    return RenZhengCard(chapuData: chaCardList[index]);
                                  }, childCount: chaCardList.length),
                                )
                              ],
                            )),
                      ))));
  }
}
