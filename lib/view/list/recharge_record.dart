import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/list/public_list.dart';
import 'package:chaguaner2023/components/pagetitlebar.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/yy_toast.dart';
import 'package:chaguaner2023/view/homepage/online_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RechargeRecord extends StatefulWidget {
  final String? type;
  RechargeRecord({Key? key, this.type}) : super(key: key);

  @override
  State<StatefulWidget> createState() => RechargeRecordState();
}

class RechargeRecordState extends State<RechargeRecord> {
  List<Map>? orderList;
  ScrollController scrollController = ScrollController();
  bool loading = true;
  bool networkErr = false;
  int page = 1;
  bool isAll = false;
  bool isLoading = false;
  String reChaStr = '充值记录';
  String ddrecoreS = '订单记录';
  String recha = '充值';
  String dingdStr = '订单';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String noDataTips = widget.type == '1' ? recha : dingdStr;
    return HeaderContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
            child: PageTitleBar(
              title: widget.type == '1' ? reChaStr : ddrecoreS,
            ),
            preferredSize: Size(double.infinity, 44.w)),
        body: Padding(
          padding: new EdgeInsets.symmetric(
            horizontal: 15.w,
            vertical: 10.w,
          ),
          child: PublicList(
              isShow: true,
              limit: 30,
              isFlow: false,
              isSliver: false,
              api: '/api/order/orderList',
              data: {'type': widget.type},
              row: 1,
              itemBuild: (context, index, data, page, limit, getListData) {
                return _rechargeCard(data);
              }),
        ),
      ),
    );
  }

  Widget _rechargeCard(Map item) {
    dynamic amounts = item['amount'].substring(0, item['amount'].indexOf('.'));
    return Container(
      width: 300.w,
      height: 155.w,
      padding: new EdgeInsets.symmetric(horizontal: 15.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.w),
        boxShadow: [
          //阴影
          BoxShadow(
              color: Colors.black12,
              offset: Offset(0, 0.5.w),
              blurRadius: 2.5.w)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            padding: new EdgeInsets.symmetric(vertical: 12.w),
            decoration: BoxDecoration(
                border: Border(
                    bottom:
                        BorderSide(width: 0.5.w, color: Color(0xFFEEEEEE)))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  '订单ID: ' + item['id'].toString(),
                  style: TextStyle(
                      color: StyleTheme.cTitleColor,
                      fontWeight: FontWeight.w300,
                      fontSize: 12.sp),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(
                        ClipboardData(text: item['id'].toString()));
                    YyToast.successToast('复制成功！');
                  },
                  child: Text('复制',
                      style: TextStyle(
                          color: StyleTheme.cDangerColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 15.sp)),
                )
              ],
            ),
          ),
          Expanded(
            child: Container(
                padding: new EdgeInsets.symmetric(vertical: 15.sp),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          item['descp'].toString(),
                          style: TextStyle(
                              color: StyleTheme.cTitleColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 18.sp),
                        ),
                        Text(
                          '¥ $amounts',
                          style: TextStyle(
                              color: StyleTheme.cTitleColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 18.sp),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          item['payway'].toString(),
                          style: TextStyle(
                              color: Color(0xFF969696), fontSize: 12.sp),
                        ),
                        Text(
                          item['status_text'].toString(),
                          style: TextStyle(
                              color: Color(0xFF969696), fontSize: 12.sp),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          item['created_at'],
                          style: TextStyle(
                              color: Color(0xFF969696), fontSize: 12.sp),
                        ),
                        GestureDetector(
                          onTap: () {
                            ServiceParmas.orderId =
                                "订单ID:" + item['id'].toString();
                            ServiceParmas.type = 'cz';
                            AppGlobal.appRouter?.push(
                                CommonUtils.getRealHash('onlineServicePage'));
                          },
                          child: Text(
                            '联系客服>',
                            style: TextStyle(
                                color: Color(0xFF8A8BC5),
                                fontWeight: FontWeight.bold,
                                fontSize: 15.sp),
                          ),
                        )
                      ],
                    )
                  ],
                )),
          )
        ],
      ),
    );
  }
}
