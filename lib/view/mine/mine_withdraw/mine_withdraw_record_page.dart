import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/loading.dart';
import 'package:chaguaner2023/components/networkErr.dart';
import 'package:chaguaner2023/components/nodata.dart';
import 'package:chaguaner2023/components/page_title_bar.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MineWithdrawRecordPage extends StatefulWidget {
  final int? type;
  MineWithdrawRecordPage({Key? key, this.type = 0}) : super(key: key);

  @override
  _MineWithdrawRecordPageState createState() => _MineWithdrawRecordPageState();
}

class _MineWithdrawRecordPageState extends State<MineWithdrawRecordPage> {
  List? withdrawList;
  int page = 1;
  bool isAll = false;
  bool networkErr = false;
  bool isLoading = true;
  bool loading = true;
  ScrollController scrollController = ScrollController();

  static getTime(int time) {
    setTime(int _num) {
      return _num < 10 ? '0' + _num.toString() : _num;
    }

    var times = new DateTime.fromMillisecondsSinceEpoch(time * 1000);
    dynamic month = setTime(times.month);
    dynamic day = setTime(times.day);
    dynamic hours = setTime(times.hour);
    dynamic minute = setTime(times.minute);
    String cTime = '${times.year}-$month-$day $hours:$minute';
    return '$cTime';
  }

  //提现记录
  getWithdraw() async {
    setState(() {
      networkErr = false;
    });
    await getListWithdraw(page, type: widget.type!).then((res) {
      if (res != null) {
        if (res['status'] != 0) {
          if (page == 1) {
            setState(() {
              loading = false;
              isLoading = false;
              withdrawList = res['data'];
            });
          } else {
            setState(() {
              withdrawList!.addAll(res['data']);
              isAll = (res['data'].length == 0);
              isLoading = (res['data'].length > 0);
            });
          }
        }
      } else {
        setState(() {
          networkErr = true;
        });
      }
    }).catchError((err) {
      setState(() {
        networkErr = true;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        if (!isAll) {
          setState(() {
            page++;
            isLoading = true;
          });
          getWithdraw();
        }
      }
    });
    getWithdraw();
  }

  @override
  Widget build(BuildContext context) {
    return HeaderContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
            child: PageTitleBar(
              title: '提现记录',
            ),
            preferredSize: Size(double.infinity, 44.w)),
        body: networkErr
            ? NetworkErr(
                errorRetry: () {
                  getWithdraw();
                },
              )
            : (loading
                ? Loading()
                : (withdrawList!.length == 0
                    ? NoData(
                        text: '您还没有提现记录哦~',
                      )
                    : Container(
                        padding: new EdgeInsets.only(top: 20.w, bottom: ScreenUtil().bottomBarHeight + 20),
                        child: Column(
                          children: <Widget>[
                            DefaultTextStyle(
                                style: TextStyle(
                                    color: StyleTheme.cTitleColor, fontSize: 14.sp, fontWeight: FontWeight.w300),
                                child: Padding(
                                  padding: new EdgeInsets.only(bottom: 26.w),
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                          flex: 1,
                                          child: Center(
                                            child: Text('时间'),
                                          )),
                                      Text('状态'),
                                      Expanded(
                                          flex: 1,
                                          child: Center(
                                            child: Text('提现金额'),
                                          )),
                                    ],
                                  ),
                                )),
                            Expanded(
                                child: ListView.separated(
                                    controller: scrollController,
                                    padding: EdgeInsets.only(top: 0),
                                    itemCount: withdrawList!.length > 0 ? withdrawList!.length + 1 : 0,
                                    physics: ClampingScrollPhysics(),
                                    separatorBuilder: (BuildContext context, int index) => Divider(
                                          color: Colors.transparent,
                                          height: 24.w,
                                        ),
                                    itemBuilder: (BuildContext context, int index) {
                                      return index != withdrawList!.length
                                          ? withdrawItem(
                                              getTime(int.parse(withdrawList![index]['created_at'].toString())),
                                              withdrawList![index]['status'],
                                              withdrawList![index]['amount'].toString())
                                          : renderMore();
                                    }))
                          ],
                        ),
                      ))),
      ),
    );
  }

  String loadData = '数据加载中...';
  String noData = '没有更多数据';
  Widget renderMore() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 15.w),
      child: Center(
        child: Text(
          isLoading ? loadData : noData,
          style: TextStyle(color: StyleTheme.cBioColor),
        ),
      ),
    );
  }

  Widget withdrawItem(String time, String state, String monney) {
    print(state);
    return DefaultTextStyle(
        style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 14.sp),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            children: <Widget>[
              Expanded(
                  flex: 1,
                  child: Center(
                    child: Text(
                      time.split(' ')[0],
                      // maxLines: 1,
                      // overflow: TextOverflow.ellipsis,
                    ),
                  )),
              Expanded(
                  flex: 1,
                  child: Center(
                    child: Text(state ?? '-'),
                  )),
              Expanded(
                  flex: 1,
                  child: Center(
                    child: Text(monney),
                  ))
            ],
          ),
        ));
  }
}
