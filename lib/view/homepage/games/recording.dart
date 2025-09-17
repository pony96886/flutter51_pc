import 'package:chaguaner2023/components/loading.dart';
import 'package:chaguaner2023/components/networkErr.dart';
import 'package:chaguaner2023/components/nodata.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GameRecordingPage extends StatefulWidget {
  final int? type; //0 充值记录  1 提现记录
  GameRecordingPage({Key? key, this.type}) : super(key: key);

  @override
  _GameRecordingPageState createState() => _GameRecordingPageState();
}

class _GameRecordingPageState extends State<GameRecordingPage> {
  List<dynamic>? orderList;
  ScrollController scrollController = ScrollController();
  bool loading = true;
  bool networkErr = false;
  int page = 1;
  bool isAll = false;
  bool isLoading = false;
  _getOrderList() async {
    setState(() {
      networkErr = false;
    });
    var order;
    if (widget.type == 0) {
      order = await getGemeOrder(page);
    } else {
      order = await getWithdrawList(page);
    }
    if (order != null && order['status'] != 0) {
      if (page == 1) {
        setState(() {
          loading = false;
          orderList = order['data'];
        });
      } else {
        setState(() {
          orderList!.addAll(order['data'] == null ? [] : order['data']);
        });
        if (order.data == null || order['data'].length == 0) {
          setState(() {
            isLoading = false;
            isAll = true;
          });
        }
      }
    } else {
      setState(() {
        networkErr = true;
      });
      return;
    }
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
          _getOrderList();
        }
      }
    });
    _getOrderList();
  }

  @override
  Widget build(BuildContext context) {
    String chargeStr = '充值记录';
    String charrr = '充值';
    String txsd = '提现';
    String txjlstr = '提现记录';
    String cccc = widget.type == 0 ? charrr : txsd;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          iconTheme: IconThemeData(
            color: StyleTheme.cTitleColor,
          ),
          title: Text(
            widget.type == 0 ? chargeStr : txjlstr,
            style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 18.sp, fontWeight: FontWeight.w500),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark),
      body: networkErr
          ? NetworkErr(
              errorRetry: () {
                _getOrderList();
              },
            )
          : (loading
              ? Loading()
              : (orderList!.length == 0)
                  ? NoData(
                      text: '无$cccc记录～',
                    )
                  : _buildListView()),
    );
  }

  Widget _buildListView() {
    return (ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 16.sp),
      controller: scrollController,
      itemCount: (orderList!.length == 0) ? 1 : orderList!.length + 1,
      itemBuilder: (context, index) {
        //显示单词列表项
        return index == orderList!.length ? renderMore() : coinWidget(orderList![index]);
      },
      separatorBuilder: (context, idnex) => SizedBox(height: 10.w),
    ));
  }

  Color getStatus(int status) {
    switch (status) {
      case 0:
        return Color(0xff0bc10f);
      case 2:
        return Color(0xfff34751);
      case 3:
        return Color(0xff999999);
      default:
        return Color(0xff999999);
    }
  }

  Widget coinWidget(Map oderItem) {
    String add = '+';
    String ctime = '充值时间';
    String cstatus = '充值状态';
    String lijis = '提现';
    String reducss = '-';
    String sqsja = '申请时间';
    String asdsq = widget.type == 0 ? add : reducss;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 11.w, horizontal: 15.w),
      margin: EdgeInsets.only(bottom: 15.w),
      width: 345.w,
      decoration: BoxDecoration(
          color: Color(0xfffafafa),
          borderRadius: BorderRadius.circular(10.w),
          border: Border.all(
            width: 0.5.w,
            color: Color.fromRGBO(217, 217, 217, 0.5),
          )),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.type == 0 ? oderItem['descp'].toString() : lijis,
                style: TextStyle(color: Colors.black, fontSize: 15.w),
              ),
              Text('$asdsq' + oderItem['amount'].toString(),
                  style: TextStyle(color: Color(0xfff8c855), fontSize: 14.w)),
            ],
          ),
          Container(
            height: 0.5.w,
            color: Color(0xffe6e6e6),
            margin: EdgeInsets.symmetric(vertical: 12.5.w),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 12.w,
                    child: LocalPNG(
                      url: 'assets/images/games/time_icon.png',
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                  SizedBox(
                    width: 6.5.w,
                  ),
                  Text(
                    widget.type == 0 ? ctime : sqsja,
                    style: TextStyle(color: Color(0xff666666), fontSize: 12.sp),
                  )
                ],
              ),
              Text(oderItem['created_at'].toString(), style: TextStyle(color: Color(0xff999999), fontSize: 12.sp)),
            ],
          ),
          SizedBox(
            height: 12.sp,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 12.w,
                    child: LocalPNG(
                      url: 'assets/images/games/time_icon.png',
                    ),
                  ),
                  SizedBox(
                    width: 6.5.w,
                  ),
                  Text(
                    widget.type == 0 ? cstatus : '申请状态',
                    style: TextStyle(color: Color(0xff666666), fontSize: 12.sp),
                  )
                ],
              ),
              Text(widget.type == 0 ? oderItem['status_text'] ?? "-" : oderItem['status'] ?? "-",
                  style: TextStyle(
                      color: widget.type == 0 ? getStatus(oderItem['status']) : Color(0xff999999), fontSize: 12.sp)),
            ],
          )
        ],
      ),
    );
  }

  String loadData = '正在加载数据';
  String noData = '没有数据啦～';
  Widget renderMore() {
    return Padding(
      padding: EdgeInsets.only(top: 15.w, bottom: 15.w),
      child: Center(
        child: Text(
          isLoading ? loadData : noData,
          style: TextStyle(color: StyleTheme.cBioColor),
        ),
      ),
    );
  }
}
