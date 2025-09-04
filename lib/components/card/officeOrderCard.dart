import 'package:bot_toast/bot_toast.dart';
import 'package:chaguaner2023/store/global.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:chaguaner2023/view/im/im_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OfficeOrderCard extends StatefulWidget {
  final Function? setCallBack;
  final int? index;
  final Map? oderInfo;
  OfficeOrderCard({
    Key? key,
    this.oderInfo,
    this.setCallBack,
    this.index,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _OfficeOrderCardState();
}

class _OfficeOrderCardState extends State<OfficeOrderCard> {
  getStatus(int status) {
    switch (status) {
      case 1:
        return "待确认";
        break;
      case 2:
        return "已完成";
        break;
      case 3:
        return '已取消';
        break;
      default:
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  void onConfrimOrder() {
    confrimAppointmentOfficial(orderNum: widget.oderInfo!['order_no']).then((result) {
      if (result!['status'] == 1) {
        widget.setCallBack!(1);
        widget.setCallBack!(2);
        BotToast.showText(text: '订单已确认', align: Alignment(0, 0));
      } else {
        BotToast.showText(text: result['msg'], align: Alignment(0, 0));
      }
    });
  }

  void contactServer() {
    AppGlobal.chatUser = FormUserMsg(uuid: UserInfo.serviceUuid!, nickname: '茶小歪', avatar: 'chaxiaowai');
    AppGlobal.appRouter?.push(CommonUtils.getRealHash('llchat'));
  }

  @override
  Widget build(BuildContext context) {
    String contac = '联系客服';
    String comfss = '确认订单';
    return Container(
      width: 345.w,
      child: Container(
          margin: new EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.w),
          padding: new EdgeInsets.symmetric(vertical: 10.w, horizontal: 10.w),
          decoration: BoxDecoration(boxShadow: [
            //阴影
            BoxShadow(color: Colors.black12, offset: Offset(0, 0.5.w), blurRadius: 2.5.w)
          ], color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          contactServer();
                        },
                        child: Container(
                          height: 30.w,
                          width: 30.w,
                          margin: new EdgeInsets.only(right: 10.5.w),
                          child: LocalPNG(
                            width: CommonUtils.getWidth(30),
                            height: CommonUtils.getWidth(30),
                            url: 'assets/images/common/chaxiaowai.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      Flexible(
                          child: Container(
                        constraints: BoxConstraints(maxWidth: 130.w),
                        child: Text(
                          "茶小歪客服",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: StyleTheme.cTitleColor,
                            fontSize: 16.sp,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )),
                      GestureDetector(
                        onTap: () {
                          contactServer();
                        },
                        child: Container(
                          margin: new EdgeInsets.only(left: 10.w),
                          padding: new EdgeInsets.symmetric(vertical: 2.5.w, horizontal: 10.w),
                          decoration:
                              BoxDecoration(color: StyleTheme.cDangerColor, borderRadius: BorderRadius.circular(30.w)),
                          child: Text(
                            contac,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    getStatus(widget.oderInfo!['status']),
                    style: TextStyle(
                        color: widget.oderInfo!['status'] == 1 ? StyleTheme.cDangerColor : StyleTheme.cBioColor,
                        fontSize: 14.sp),
                  )
                ],
              ),
              GestureDetector(
                  onTap: () {
                    AppGlobal.appRouter?.push(CommonUtils.getRealHash(
                        'vipDetailPage/' + (widget.oderInfo!['info_id'] ?? widget.oderInfo!['id'] + '/null/').toString()));
                  },
                  child: Container(
                    width: double.infinity,
                    color: StyleTheme.bottomappbarColor,
                    margin: new EdgeInsets.only(top: 15.w),
                    height: 70.w,
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Container(
                          width: 70.w,
                          height: 70.w,
                          margin: new EdgeInsets.only(right: 10.5.w),
                          child: LocalPNG(
                            width: CommonUtils.getWidth(70),
                            height: CommonUtils.getWidth(70),
                            url: 'assets/images/nav/chagirl.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Text(
                                "官方预约单",
                                style: TextStyle(
                                    fontSize: 16.sp, fontWeight: FontWeight.bold, color: StyleTheme.cTitleColor),
                              ),
                              Container(
                                  width: 225.w,
                                  child: Text(
                                    '茶馆官方安排服务',
                                    style: TextStyle(fontSize: 12.sp, color: StyleTheme.cTitleColor),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  )),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: widget.oderInfo!['order_no']));
                            BotToast.showText(text: '复制成功', align: Alignment(0, 0));
                          },
                          child: Container(
                            margin: EdgeInsets.only(right: 10.w),
                            padding: new EdgeInsets.all(5.w),
                            decoration:
                                BoxDecoration(color: StyleTheme.cBioColor, borderRadius: BorderRadius.circular(5.w)),
                            child: Text(
                              '复制订单号',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  )),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    margin: new EdgeInsets.only(top: 15.w, bottom: 5.w),
                    child: Text('预约金' + widget.oderInfo!['money'].toString() + '元宝',
                        style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 14.sp)),
                  ),
                  widget.oderInfo!['status'] == 1
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            GestureDetector(
                              onTap: () {
                                onConfrimOrder();
                              },
                              child: Container(
                                margin: new EdgeInsets.only(top: 15.w, bottom: 5.w),
                                padding: new EdgeInsets.symmetric(vertical: 6.w, horizontal: 17.w),
                                decoration: BoxDecoration(
                                    color: StyleTheme.cDangerColor, borderRadius: BorderRadius.circular(12.5.w)),
                                child: Text(
                                  comfss,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            )
                          ],
                        )
                      : SizedBox()
                ],
              )
            ],
          )),
    );
  }
}
