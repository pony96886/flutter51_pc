import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/list/public_list.dart';
import 'package:chaguaner2023/components/pagetitlebar.dart';
import 'package:chaguaner2023/components/tab/tab_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MonyDtailPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MonyDtailPageState();
}

class MonyDtailPageState extends State<MonyDtailPage> {
  int limit = 30;
  bool networkErr = false;
  int coinType = 1;
  ScrollController scrollController = ScrollController();
  List? income;
  List? expenditure;

  @override
  Widget build(BuildContext context) {
    return HeaderContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
            child: PageTitleBar(
              title: '铜钱明细',
            ),
            preferredSize: Size(double.infinity, 44.w)),
        body: Container(
          color: Colors.white,
          child: Column(
            children: [
              TabNav(
                rightWidth: 142,
                leftWidth: 142,
                setTabState: (val) {
                  setState(() {
                    coinType = val ? 1 : 2;
                  });
                },
                leftTitle: '收益',
                rightTitle: '支出',
                rightChild: Column(
                  children: [
                    ListTile(
                        title: Row(
                      children: [
                        Expanded(
                            child: Center(
                          child: Text('时间'),
                        )),
                        Expanded(
                            child: Center(
                          child: Text('类型'),
                        )),
                        Expanded(
                            child: Center(
                          child: Text('数量'),
                        )),
                      ],
                    )),
                    Expanded(
                        child: PublicList(
                            isShow: true,
                            limit: 30,
                            isFlow: false,
                            isSliver: false,
                            api: '/api/user/listCoinDetail',
                            data: {'type': 2},
                            row: 1,
                            itemBuild: (context, index, data, page, limit,
                                getListData) {
                              return _record(
                                  data['time'], data['source'], data['coin']);
                            }))
                  ],
                ),
                leftChild: Column(
                  children: [
                    ListTile(
                        title: Row(
                      children: [
                        Expanded(
                            child: Center(
                          child: Text('时间'),
                        )),
                        Expanded(
                            child: Center(
                          child: Text('类型'),
                        )),
                        Expanded(
                            child: Center(
                          child: Text('数量'),
                        )),
                      ],
                    )),
                    Expanded(
                        child: PublicList(
                            isShow: true,
                            limit: 30,
                            isFlow: false,
                            isSliver: false,
                            api: '/api/user/listCoinDetail',
                            data: {'type': 1},
                            row: 1,
                            itemBuild: (context, index, data, page, limit,
                                getListData) {
                              return _record(
                                  data['time'], data['source'], data['coin']);
                            }))
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _record(String time, String type, dynamic coin) {
    String reduceStr = '-';
    String value = type == null ? reduceStr : type.toString();
    return Container(
      padding: new EdgeInsets.only(bottom: 20.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              child: Center(
            child: Text(time),
          )),
          Expanded(
              child: Center(
            child: Text(value),
          )),
          Expanded(
              child: Center(
            child: Text(coin.toString()),
          ))
        ],
      ),
    );
  }
}
