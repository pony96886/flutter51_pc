import 'package:bot_toast/bot_toast.dart';
import 'package:chaguaner2023/components/avatar_widget.dart';
import 'package:chaguaner2023/components/starrating.dart';
import 'package:chaguaner2023/store/global.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:chaguaner2023/utils/netimage_tool.dart';
import 'package:chaguaner2023/view/im/im_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OderCard extends StatefulWidget {
  final String? cardType;
  final int? status;
  final Function? setCallBack;
  final int? orderStatus;
  final int? index;
  final Map? oderInfo;
  final int? oderType;
  OderCard(
      {Key? key,
      this.status,
      this.orderStatus,
      this.oderInfo,
      this.oderType,
      this.setCallBack,
      this.index,
      this.cardType})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _OderCardState();
}

class _OderCardState extends State<OderCard> {
  List? resources;
  getStatus(int status) {
    String ss = '订单已确认';
    String ff = '订单已完成';
    String ww = '待客户确认';
    String ws = '待您确认';
    String comf = '已确认';
    String tod = '待评价';
    switch (status) {
      case 1:
        return widget.oderType == 0 ? ww : ws;
      case 3:
        return '已取消';
      case 2:
        return widget.oderType == 0
            ? (widget.cardType == 'pintuan' ? ss : comf)
            : (widget.cardType == 'pintuan' ? ff : tod);
      case 4:
        return '已完成';
      default:
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    resources = null;
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    resources = widget.oderInfo!['resources'];
    resources!.sort((video, img) => video['type'].compareTo(img['type']));
  }

  void contactServer() {
    print('contactServer');
    String yuyueUUID = "";
    if (UserInfo.yuyueCS == "") {
      yuyueUUID = UserInfo.officialUuid.toString();
    } else {
      yuyueUUID = UserInfo.yuyueCS!;
    }
    AppGlobal.chatUser = FormUserMsg(
        uuid: widget.oderInfo!['type'] == 2 ? yuyueUUID : widget.oderInfo!['uuid'].toString(),
        nickname: widget.oderInfo!['type'] == 2 ? '茶女郎客服' : widget.oderInfo!['nickname'],
        avatar: widget.oderInfo!['type'] == 2 ? 'chaxiaowai' : widget.oderInfo!['thumb']);
    AppGlobal.appRouter?.push(CommonUtils.getRealHash('llchat'));
  }

  @override
  Widget build(BuildContext context) {
    String contac = '联系客服';
    String comfss = '确认交易';
    String canss = '取消预约';
    return Container(
      width: 345.w,
      child: Container(
          margin: new EdgeInsets.symmetric(horizontal: 15.w),
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
                      Container(
                        height: 30.w,
                        width: 30.w,
                        margin: new EdgeInsets.only(right: 10.5.w),
                        child: Avatar(
                          type: widget.oderInfo!['thumb'],
                          onPress: () {
                            AppGlobal.appRouter?.push(CommonUtils.getRealHash('brokerHomepage/' +
                                widget.oderInfo!['aff'].toString() +
                                '/' +
                                Uri.encodeComponent(widget.oderInfo!['thumb'].toString()) +
                                '/' +
                                Uri.encodeComponent(widget.oderInfo!['nickname'].toString())));
                          },
                        ),
                      ),
                      Flexible(
                          child: Container(
                        constraints: BoxConstraints(maxWidth: 130.w),
                        child: Text(
                          widget.oderInfo!['nickname'],
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
                            widget.oderInfo!['type'] == 2 ? contac : '私聊',
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
                    AppGlobal.appRouter
                        ?.push(CommonUtils.getRealHash('vipDetailPage/' + widget.oderInfo!['info_id'].toString() + '/null/'));
                  },
                  child: Container(
                    width: double.infinity,
                    color: StyleTheme.bottomappbarColor,
                    margin: new EdgeInsets.only(top: 15.w),
                    height: 70.w,
                    child: (widget.oderInfo!['type'] == 2 || widget.oderInfo!['type'] == 3
                        ? Row(
                            children: <Widget>[
                              Container(
                                width: 70.w,
                                height: 70.w,
                                margin: new EdgeInsets.only(right: 10.5.w),
                                child: NetImageTool(
                                  url: resources![0]['url'],
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  Text(
                                    widget.oderInfo!['title'].toString(),
                                    style: TextStyle(
                                        fontSize: 16.sp, fontWeight: FontWeight.bold, color: StyleTheme.cTitleColor),
                                  ),
                                  Container(
                                      width: 225.w,
                                      child: Text(
                                        widget.oderInfo!['desc'].toString(),
                                        style: TextStyle(fontSize: 12.sp, color: StyleTheme.cTitleColor),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ))
                                ],
                              )
                            ],
                          )
                        : Row(
                            children: <Widget>[
                              Container(
                                width: 70.w,
                                height: 70.w,
                                margin: new EdgeInsets.only(right: 10.w),
                                child: NetImageTool(
                                  url: resources![0]['url'],
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  Text(
                                    widget.oderInfo!['title'],
                                    style: TextStyle(
                                        fontSize: 16.sp, fontWeight: FontWeight.bold, color: StyleTheme.cTitleColor),
                                  ),
                                  Container(
                                      width: 225.w,
                                      child: Text(
                                        widget.oderInfo!['cityName'].toString(),
                                        style: TextStyle(fontSize: 12.sp, color: StyleTheme.cTitleColor),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ))
                                ],
                              )
                            ],
                          )),
                  )),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  (widget.oderInfo!['type'] == 2 || widget.oderInfo!['type'] == 3
                      ? Container(
                          margin: new EdgeInsets.only(top: 15.w, bottom: 5.w),
                          child: Text('预约金' + widget.oderInfo!['freeze_money'].toString() + '元宝',
                              style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 14.sp)),
                        )
                      : Container()),
                  widget.oderType == 0 || (widget.oderType == 1 && widget.oderInfo!['status'] == 1)
                      ? (widget.oderInfo!['status'] != 3 && widget.oderInfo!['status'] != 4
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                GestureDetector(
                                  onTap: () async {
                                    if (widget.oderType == 0) {
                                      //用户的事件
                                      if (widget.oderInfo!['status'] == 2) {
                                        var isPull = await AppGlobal.appRouter
                                            ?.push(CommonUtils.getRealHash('vipComment'), extra: widget.oderInfo);
                                        if (isPull == true) {
                                          widget.setCallBack!(3);
                                        }
                                      } else {
                                        bool? yes = await showPrompt(comfss, '请在见到妹子后，如需她提供服务，点击“确认交易”', 0);
                                        if (yes == true) {
                                          confirmAppointment(widget.oderInfo!['id']).then((res) {
                                            if (res!.status != 0)
                                              BotToast.showText(text: '交易成功～', align: Alignment(0, 0));
                                            widget.setCallBack!(2);
                                          });
                                        }
                                      }
                                    } else {
                                      //经纪人
                                      bool? yes = await showPrompt(canss, '是否取消预约订单？', 1);
                                      if (yes == true) {
                                        cancelAppointment(widget.oderInfo!['id']).then((res) {
                                          if (res!.status != 0) {
                                            BotToast.showText(text: '预约取消成功～', align: Alignment(0, 0));
                                            widget.setCallBack!(3);
                                          } else {
                                            BotToast.showText(text: res.msg! + '～', align: Alignment(0, 0));
                                          }
                                        });
                                      }
                                    }
                                  },
                                  child: Container(
                                    margin: new EdgeInsets.only(top: 15.w, bottom: 5.w),
                                    padding: new EdgeInsets.symmetric(vertical: 6.w, horizontal: 17.w),
                                    decoration: BoxDecoration(
                                        color: StyleTheme.cDangerColor, borderRadius: BorderRadius.circular(12.5.w)),
                                    child: Text(
                                      widget.oderType == 0
                                          ? (widget.oderInfo!['status'] == 1 ? comfss : '评价茶女郎')
                                          : canss,
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            )
                          : Container())
                      : Container()
                ],
              )
            ],
          )),
    );
  }

  // 购买资源弹框
  Future<bool?> showPrompt(String title, String content, int type) {
    String comfss = '确认交易';
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 300.w,
            padding: new EdgeInsets.symmetric(vertical: 15.w, horizontal: 25.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Center(
                      child: Text(
                        title,
                        style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 18.sp, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                        margin: new EdgeInsets.only(top: 20.w),
                        child: Text(
                          content,
                          style: TextStyle(fontSize: 14.sp, color: StyleTheme.cTitleColor),
                        )),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              margin: new EdgeInsets.only(top: 30.w),
                              height: 50.w,
                              width: 80.w,
                              child: Stack(
                                children: [
                                  LocalPNG(
                                    height: 50.w,
                                    width: 80.w,
                                    url: 'assets/images/mymony/money-img.png',
                                  ),
                                  Center(
                                      child: Text(
                                    '取消',
                                    style: TextStyle(fontSize: 15.sp, color: Colors.white),
                                  )),
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop(true);
                            },
                            child: Container(
                              margin: new EdgeInsets.only(top: 30.w),
                              height: 50.w,
                              width: 110.w,
                              child: Stack(
                                children: [
                                  LocalPNG(
                                    url: 'assets/images/mymony/money-img.png',
                                    height: 50.w,
                                    width: 110.w,
                                  ),
                                  Center(
                                      child: Text(
                                    type == 0 ? comfss : '确定取消',
                                    style: TextStyle(fontSize: 15.sp, color: Colors.white),
                                  )),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: LocalPNG(
                        width: 30.w,
                        height: 30.w,
                        url: 'assets/images/mymony/close.png',
                        fit: BoxFit.cover,
                      )),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
