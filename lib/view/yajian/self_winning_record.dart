import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/list/public_list.dart';
import 'package:chaguaner2023/components/pagetitlebar.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SelfWinningRecord extends StatefulWidget {
  const SelfWinningRecord({Key? key}) : super(key: key);

  @override
  State<SelfWinningRecord> createState() => _WinningRecordPageState();
}

class _WinningRecordPageState extends State<SelfWinningRecord> {
  @override
  Widget build(BuildContext context) {
    return HeaderContainer(
        child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: PreferredSize(
                child: PageTitleBar(
                  title: '往期记录',
                ),
                preferredSize: Size(double.infinity, 44.w)),
            body: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 11.5.w),
                  child: Row(
                    children: [
                      Expanded(
                          child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          "场别",
                          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14.sp, color: StyleTheme.color30),
                        ),
                      )),
                      Expanded(
                          child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          "期数",
                          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14.sp, color: StyleTheme.color30),
                        ),
                      )),
                      Expanded(
                          child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          "开奖时间",
                          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14.sp, color: StyleTheme.color30),
                        ),
                      )),
                      Expanded(
                          child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          "中奖记录",
                          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14.sp, color: StyleTheme.color30),
                        ),
                      )),
                    ],
                  ),
                ),
                Expanded(
                    child: PublicList(
                  api: "/api/lottery/getLotteryRecordList",
                  itemBuild: (context, index, data, page, limit, getListData) {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 11.5.w),
                      child: Row(
                        children: [
                          Expanded(
                              child: Container(
                            alignment: Alignment.center,
                            child: Text(
                              "${data['title']}",
                              style: TextStyle(fontSize: 14.sp, color: StyleTheme.color30),
                            ),
                          )),
                          Expanded(
                              child: Container(
                            alignment: Alignment.center,
                            child: Text(
                              "第${data['lottery_num']}期",
                              style: TextStyle(fontSize: 14.sp, color: StyleTheme.color30),
                            ),
                          )),
                          Expanded(
                              child: Container(
                            alignment: Alignment.center,
                            child: Text(
                              "${data['updated_at']}",
                              style: TextStyle(fontSize: 14.sp, color: StyleTheme.color30),
                            ),
                          )),
                          Expanded(
                              child: Container(
                            alignment: Alignment.center,
                            child: Text(
                              "${data['status_str']}",
                              style: TextStyle(fontSize: 14.sp, color: StyleTheme.color30),
                            ),
                          )),
                        ],
                      ),
                    );
                  },
                ))
              ],
            )));
  }
}
