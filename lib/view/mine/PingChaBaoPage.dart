import 'package:bot_toast/bot_toast.dart';
import 'package:chaguaner2023/components/cgDialog.dart';
import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/list/public_list.dart';
import 'package:chaguaner2023/components/pagetitlebar.dart';
import 'package:chaguaner2023/components/tab/tab_nav.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:chaguaner2023/utils/netimage_tool.dart';
import 'package:chaguaner2023/utils/pageviewmixin.dart';
import 'package:chaguaner2023/utils/yy_toast.dart';
import 'package:chaguaner2023/view/homepage/online_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../utils/cache/image_net_tool.dart';

class PingChaBaoPage extends StatefulWidget {
  @override
  _PingChaBaoPageState createState() => _PingChaBaoPageState();
}

class _PingChaBaoPageState extends State<PingChaBaoPage> {
  // ignore: unused_field
  bool _tabState = true;

  @override
  Widget build(BuildContext context) {
    return HeaderContainer(
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.transparent,
          appBar: PreferredSize(
              child: PageTitleBar(
                title: '品茶宝',
              ),
              preferredSize: Size(double.infinity, 44.w)),
          body: Column(
            children: <Widget>[
              TabNav(
                rightWidth: 142,
                setTabState: (val) {
                  setState(() {
                    _tabState = val;
                  });
                },
                initTab: false,
                leftWidth: 142,
                leftTitle: '支出',
                rightTitle: '收入',
                rightChild: PageViewMixin(
                  child: ZhiChu(
                    type: 2,
                  ),
                ),
                leftChild: PageViewMixin(
                  child: ZhiChu(),
                ),
              ),
            ],
          )),
    );
  }
}

class ZhiChu extends StatefulWidget {
  final int type; // 1支出 ，2 收入

  const ZhiChu({Key? key, this.type = 1}) : super(key: key);

  @override
  _ZhiChuState createState() => _ZhiChuState();
}

class _ZhiChuState extends State<ZhiChu> {
  RefreshController? _refreshController;

  bool _isLoaded = false;
  int _page = 1;
  List? pcbListData;

  @override
  void initState() {
    super.initState();
    _refreshController = RefreshController(initialRefresh: false);
    getList();
  }

  getList() async {
    String spenssa = 'spend';
    String incomeStr = 'income';
    Map? entity = await pcbList(
        page: _page, type: widget.type == 1 ? spenssa : incomeStr);

    pcbListData = entity!['data'] ?? [];
    setState(() {
      _isLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    String spendStr = 'spend';
    String incomeStr = 'income';
    return PublicList(
        isShow: true,
        limit: 15,
        isFlow: false,
        isSliver: false,
        api: '/api/transaction/tranList',
        data: {'type': widget.type == 1 ? spendStr : incomeStr},
        row: 1,
        itemBuild: (context, index, data, page, limit, getListData) {
          return PCBItem(
            data: data,
            type: widget.type,
          );
        });
  }
}

class PCBItem extends StatefulWidget {
  final Map? data;
  final int? type;

  const PCBItem({Key? key, this.data, this.type}) : super(key: key);

  @override
  _PCBItemState createState() => _PCBItemState();
}

class _PCBItemState extends State<PCBItem> {
  int? _statusCode;
  TextEditingController appealController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _statusCode = widget.data!['status'];
  }

  @override
  Widget build(BuildContext context) {
    Map? data = widget.data;
    String avatar = 'assets/images/common/' + data!['thumb'] + '.png';
    String nickname = data!['nickname'].toString();
    String title = data['title'].toString();
    String titleAvatar =
        data['resources'].length > 0 ? data['resources'][0]['img_url'] : '';
    String titleContent = data['cityName'].toString();
    int statusCode = _statusCode!;
    String fanhunStr = statusCode == 3 ? '已返还' : '';
    String count = '托管' + data['freeze_money'].toString() + '元宝$fanhunStr';
    // print('----------------$count');
    String dfkStr = '待放款';
    String dskStr = '待收款';
    String fkcgStr = "放款成功";
    String skcgStr = '收款成功';
    String tgqxStr = "托管取消";
    String qxfkStr = '取消放款';
    String qrfkStr = '确认放款';
    String qxfktipsStr = '取消放款后，元宝将会返回付款方';
    String qrfkTipsStr = '确认放款后，元宝将会到达收款方';
    String status = statusCode == 1
        ? widget.type == 1
            ? dfkStr
            : dskStr
        : statusCode == 2
            ? widget.type == 1
                ? fkcgStr
                : skcgStr
            : statusCode == 3
                ? tgqxStr
                : "";
    Color statusColor =
        statusCode == 1 ? StyleTheme.cDangerColor : StyleTheme.cTextColor;

    return Container(
//      width: GVScreenUtil.screenWidth,
//      color: Colors.amber,
      padding: EdgeInsets.all(10.w),
      child: Card(
        elevation: 3.0,
        shadowColor: Colors.black45,
        child: Padding(
          padding: EdgeInsets.all(10.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  ClipRRect(
                    child: Container(
                      width: 30.w,
                      height: 30.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.w),
//                      color: Colors.amberAccent,
                      ),
                      child: LocalPNG(
                        url: avatar,
                        width: 30.w,
                        height: 30.w,
                      ),
                    ),
                    borderRadius: BorderRadius.circular(5.w),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 10.w),
                  ),
                  Expanded(
                    child: Text(
                      nickname,
                      style: TextStyle(
                          fontSize: 16.w,
                          color: StyleTheme.cTitleColor,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    status,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10.w),
                child: ClipRRect(
                  child: Container(
                    color: Color.fromRGBO(
                      245,
                      245,
                      245,
                      1.0,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Container(
                          width: 70.w,
                          height: 70.w,
                          child: ImageNetTool(url: titleAvatar),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 10.w),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              title,
                              style: TextStyle(
                                  fontSize: 18.w,
                                  color: StyleTheme.cTitleColor,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              titleContent,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: StyleTheme.cTitleColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  borderRadius: BorderRadius.circular(5.w),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: StyleTheme.cTitleColor,
                    ),
                  ),
                  Expanded(
                    child: Container(),
                  ),
                  _statusCode != 1
                      ? Container()
                      : widget.type == 2
                          ? Container()
                          : GestureDetector(
                              child: Container(
                                width: 85.w,
                                height: 25.w,
                                decoration: BoxDecoration(
                                  color: StyleTheme.cDangerColor,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(
                                      25.w,
                                    ),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    '取消托管',
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      color: Color.fromRGBO(255, 255, 255, 1.0),
                                    ),
                                  ),
                                ),
                              ),
                              onTap: () {
                                showAppeal().then((val) {
                                  String textStr = val!['text'];
                                  appealController.text = '';
                                  ServiceParmas.isSend = 'send';
                                  ServiceParmas.orderId = "[取消托管单]\n托管单ID: " +
                                      widget.data!['id'].toString() +
                                      ";\n用户昵称: " +
                                      widget.data!['nickname'].toString() +
                                      ";\n取消原因: $textStr;";
                                  AppGlobal.appRouter?.push(
                                      CommonUtils.getRealHash(
                                          'onlineServicePage'));
                                });
                              }),
                  Padding(
                    padding: EdgeInsets.only(right: 5.w),
                  ),
                  _statusCode != 1
                      ? Container()
                      : GestureDetector(
                          onTap: () {
                            CgDialog.cgShowDialog(
                                context,
                                widget.type == 2 ? qxfkStr : qrfkStr,
                                widget.type == 2 ? qxfktipsStr : qrfkTipsStr,
                                ['取消', '确认'], callBack: () async {
                              String msg = '发生未知错误';
                              String id = widget.data!['id'].toString();
                              if (widget.type == 2) {
                                Map? data = await pcbCancel(id);
                                if (data!['status'] == 1) {
                                  msg = '已取消放款';
                                  _statusCode = 3;
                                  widget.data!['status'] = _statusCode;
                                } else {
                                  msg = data['msg'] ?? '网络错误';
                                }
                              } else {
                                Map? data = await pcbConfirm(id);

                                if (data!['status'] == 1) {
                                  msg = '已确认放款';
                                  _statusCode = 2;
                                  widget.data!['status'] = _statusCode;
                                } else {
                                  msg = data['msg'] ?? '网络错误';
                                }
                              }
                              YyToast.successToast(msg);
                              setState(() {});
                            });
                          },
                          behavior: HitTestBehavior.translucent,
                          child: Container(
                            width: 85.w,
                            height: 25.w,
                            decoration: BoxDecoration(
                              color: StyleTheme.cDangerColor,
                              borderRadius: BorderRadius.all(
                                Radius.circular(
                                  25.w,
                                ),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                widget.type == 2 ? qxfkStr : qrfkStr,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: Color.fromRGBO(255, 255, 255, 1.0),
                                ),
                              ),
                            ),
                          ),
                        )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Map?> showAppeal() {
    return showDialog<Map>(
      context: context,
      barrierDismissible: false,
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
                        '取消托管',
                        style: TextStyle(
                            color: StyleTheme.cTitleColor,
                            fontSize: 18.w,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Flexible(
                      child: SingleChildScrollView(
                        physics: ClampingScrollPhysics(),
                        child: Container(
                            margin: new EdgeInsets.only(top: 20.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(bottom: 15.w),
                                  child: Text(
                                    '取消原因',
                                    style: TextStyle(
                                        color: StyleTheme.cTitleColor,
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                                _inputDetail('简单描述一下申诉原因', appealController),
                              ],
                            )),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => {
                        Navigator.of(context).pop(),
                      },
                      child: Container(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              appealController.text = '';
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              margin: new EdgeInsets.only(top: 30.w),
                              height: 50.w,
                              width: 110.w,
                              child: Stack(
                                children: [
                                  LocalPNG(
                                      height: 50.w,
                                      width: 110.w,
                                      url: 'assets/images/mymony/money-img.png',
                                      fit: BoxFit.fill),
                                  Center(
                                      child: Text(
                                    '取消',
                                    style: TextStyle(
                                        fontSize: 15.sp, color: Colors.white),
                                  )),
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              if (appealController.text == '') {
                                BotToast.showText(
                                    text: '请填写申诉原因', align: Alignment(0, 0));
                                return;
                              } else {
                                Navigator.of(context)
                                    .pop({'text': appealController.text});
                              }
                            },
                            child: Container(
                              margin: new EdgeInsets.only(top: 30.w),
                              height: 50.w,
                              width: 110.w,
                              child: Stack(
                                children: [
                                  LocalPNG(
                                      height: 50.w,
                                      width: 110.w,
                                      url: 'assets/images/mymony/money-img.png',
                                      fit: BoxFit.fill),
                                  Center(
                                      child: Text(
                                    '提交申诉',
                                    style: TextStyle(
                                        fontSize: 15.sp, color: Colors.white),
                                  )),
                                ],
                              ),
                            ),
                          )
                        ],
                      )),
                    )
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
                          fit: BoxFit.cover)),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _inputDetail(String topic, dynamic value) {
    return Card(
        margin: EdgeInsets.zero,
        shadowColor: Colors.transparent,
        color: Color(0xFFF5F5F5),
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: TextField(
            controller: value,
            textInputAction: TextInputAction.done,
            autofocus: false,
            maxLines: 8,
            style: TextStyle(fontSize: 15.sp, color: StyleTheme.cTitleColor),
            decoration: InputDecoration.collapsed(
                hintStyle:
                    TextStyle(fontSize: 15.sp, color: StyleTheme.cBioColor),
                hintText: topic),
          ),
        ));
  }
}
