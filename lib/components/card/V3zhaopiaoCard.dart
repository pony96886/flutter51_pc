import 'package:bot_toast/bot_toast.dart';
import 'package:chaguaner2023/components/cgDialog.dart';
import 'package:chaguaner2023/components/loading_gif.dart';
import 'package:chaguaner2023/components/starrating.dart';
import 'package:chaguaner2023/store/global.dart';
import 'package:chaguaner2023/store/homeConfig.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:chaguaner2023/utils/netimage_tool.dart';
import 'package:chaguaner2023/view/homepage/online_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../utils/cache/image_net_tool.dart';

class V3ZhaoPiaoCard extends StatefulWidget {
  final bool isPeifu; //是否赔付
  final int type; //收藏 3 发布 4 待验证茶帖 5
  final bool isCollect;
  final bool isBrokerhome; //是否从茶小二主页跳转
  final int? index;
  final zpInfo;
  final Function? deleteCallBack;
  final Function? refreshCallBack;
  final Function? reqCallBack;
  V3ZhaoPiaoCard(
      {Key? key,
      this.isBrokerhome = false,
      this.type = 1,
      this.isCollect = false,
      this.zpInfo,
      this.deleteCallBack,
      this.reqCallBack,
      this.refreshCallBack,
      this.index,
      this.isPeifu = false})
      : super(key: key);
  @override
  V3ZhaoPiaoCardState createState() => new V3ZhaoPiaoCardState();
}

class V3ZhaoPiaoCardState extends State<V3ZhaoPiaoCard> {
  bool isFavorite = true;
  TextEditingController appealController = TextEditingController();
  List<String>? _piclist = [];
  List? _cardInfos;
  String freeze = '0'; //1冻结
  String revoke = '0'; //3撤销
  String arrive = '0'; //2到账
  // List<Media> images = [];
  // List<Media> _listImagePaths = [];
  Map<int, String>? servicesStatus = {};

  @override
  void initState() {
    super.initState(); //1冻结 2到账 3撤销
    var tabLists = Provider.of<GlobalState>(context, listen: false).infotype;
    if (tabLists.length > 0) {
      tabLists.forEach((e) {
        servicesStatus!.addAll({e['id']: e['title']});
      });
    }
    if (widget.type == 4 && widget.zpInfo['reward'] != null) {
      widget.zpInfo['reward'].forEach((item) {
        if (item['status'] == 1) {
          freeze = item['num'];
        } else if (item['status'] == 2) {
          arrive = item['num'];
        } else if (item['status'] == 3) {
          revoke = item['num'];
        }
      });
    }
    _cardInfos = [
      {
        'title': '类型：',
        'content': widget.zpInfo['type'] == null
            ? widget.zpInfo['name']
            : servicesStatus![widget.zpInfo['type']],
        'type': 'text',
        'show': true
      },
      {
        'title': '所在地区：',
        'content': widget.zpInfo['cityName'] == null
            ? widget.zpInfo['areaname']
            : widget.zpInfo[
                'cityName'], //_initCity(widget.zpInfo.cityCode.toString()),
        'type': 'text',
        'show': !["", null, false, 0, "0"].contains(widget.zpInfo['cityName'])
      },
      {
        'title': '服务项目：',
        'content': widget.zpInfo['girl_service_type'],
        'type': 'text',
        'show': widget.zpInfo['girl_service_type'] != '' ? true : false
      },
      {
        'title': '妹子颜值：',
        'content': widget.zpInfo['girl_face'].toDouble(),
        'type': 'star',
        'show': true
      },
      {
        'title': '消费情况：',
        'content': widget.zpInfo['fee'],
        'type': 'text',
        'show': widget.zpInfo['fee'] != '' ? true : false
      },
    ];
    setState(() {});
  }

  @override
  void dispose() {
    _piclist = null;
    _cardInfos = null;
    appealController.dispose();
    servicesStatus = null;
    super.dispose();
  }

  _deleteFailInfo(String id) {
    deleteFailInfo(id).then((res) {
      if (res['status'] != 0) {
        BotToast.showText(text: '茶帖删除成功～', align: Alignment(0, 0));
        if (widget.deleteCallBack != null) {
          widget.deleteCallBack!();
        }
      }
    });
  }

  Widget build(BuildContext context) {
    // CommonUtils.debugPrint(widget.zpInfo);
    var profileDatas = Provider.of<GlobalState>(context).profileData;
    var vipLevel = profileDatas != null ? profileDatas['vip_level'] : 0;
    String v3UnderRE = 'assets/images/card/v3-under-review.png';
    String v3audit = 'assets/images/card/v3-audit-failure.png';
    String tqs = '铜钱';
    String ybs = '元宝';
    String isMoneyStr = ybs;
    if (widget.type == 4 && widget.zpInfo != null) {
      isMoneyStr = widget.zpInfo['is_money'] == 0 ? tqs : ybs;
    }
    dynamic freezeNumber = CommonUtils.renderFixedNumber(double.parse(freeze));
    dynamic rovokeNumber = CommonUtils.renderFixedNumber(double.parse(revoke));
    dynamic arriveNumber = CommonUtils.renderFixedNumber(double.parse(arrive));
    dynamic freezes = '$freezeNumber' + isMoneyStr;
    dynamic revokes = '$rovokeNumber' + isMoneyStr;
    dynamic arrives = '$arriveNumber' + isMoneyStr;

    return Container(
      margin: EdgeInsets.only(bottom: 10.w, left: 15.w, right: 15.w),
      child: GestureDetector(
        onTap: () {
          if (widget.type == 3 && widget.zpInfo['status'] == 4) {
            CgDialog.cgShowDialog(
                context, '提示', '该资源已被删除,是否为您取消收藏?', ['取消', '确定'],
                callBack: () async {
              var favorite =
                  await collectResources(widget.zpInfo['id'].toString());
              if (favorite.status != 0) {
                BotToast.showText(text: '已为您取消收藏', align: Alignment(0, 0));
                if (widget.deleteCallBack != null) {
                  widget.deleteCallBack!();
                }
              } else {
                BotToast.showText(text: favorite.msg, align: Alignment(0, 0));
              }
            });
          } else {
            if ((widget.type == 5 && widget.zpInfo['status'] == 2) ||
                widget.type == 2 ||
                widget.zpInfo['status'] == 2 ||
                widget.zpInfo['status'] == 1) {
              AppGlobal.appRouter?.push(CommonUtils.getRealHash(
                  'resourcesDetailPage/' +
                      widget.isBrokerhome.toString() +
                      '/' +
                      widget.zpInfo['id'].toString() +
                      '/null/null/null'));
            } else {
              AppGlobal.appRouter?.push(CommonUtils.getRealHash(
                  'resourcesDetailPage/' +
                      widget.isBrokerhome.toString() +
                      '/' +
                      widget.zpInfo['id'].toString() +
                      '/' +
                      (widget.type == 5).toString() +
                      '/' +
                      widget.zpInfo['buy_id'].toString() +
                      '/null'));
            }
          }
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 0),
              child: Stack(
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                        boxShadow: [
                          //阴影
                          BoxShadow(
                              color: Colors.black12,
                              offset: Offset(0, 0.5.w),
                              blurRadius: 2.5.w)
                        ],
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10)),
                    child: Stack(
                      children: [
                        LocalPNG(
                          fit: BoxFit.cover,
                          url: "assets/images/card/cardbg.png",
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 10.w, bottom: 10.w),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 15.w),
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 3.5.w,
                                                horizontal: 7.5.w),
                                            decoration: BoxDecoration(
                                              color: Color(0xFFDBC1A0),
                                              borderRadius:
                                                  BorderRadius.circular(15.w),
                                            ),
                                            alignment: Alignment.center,
                                            margin:
                                                EdgeInsets.only(bottom: 9.5.w),
                                            child: Align(
                                              alignment: Alignment.topCenter,
                                              child: Text(
                                                widget.zpInfo['title'],
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    height: 1.2,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14.w),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(left: 10.w),
                                            decoration: BoxDecoration(
                                              color: Colors.transparent,
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: _cardInfos!
                                                      .asMap()
                                                      .keys
                                                      .map((key) =>
                                                          _cardInfos![key][
                                                                      'show'] ==
                                                                  true
                                                              ? Container(
                                                                  height: 20.w,
                                                                  child: Row(
                                                                    children: <Widget>[
                                                                      Text(
                                                                          _cardInfos![key]
                                                                              [
                                                                              'title'],
                                                                          style: TextStyle(
                                                                              color: Color(0xFF646464),
                                                                              fontSize: 11.w)),
                                                                      _buildContent(
                                                                          _cardInfos![
                                                                              key])
                                                                    ],
                                                                  ),
                                                                )
                                                              : SizedBox())
                                                      .toList(),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                        margin: EdgeInsets.only(left: 5.w),
                                        width: 150.w,
                                        height: 150.w,
                                        padding: EdgeInsets.all(5.w),
                                        decoration: BoxDecoration(
                                            color: Color(0xFFF2F3EE),
                                            borderRadius:
                                                BorderRadius.circular(100)),
                                        child: Stack(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                              child: Container(
                                                color: Color(0xFFF2F3EE),
                                                width: 140.w,
                                                height: 140.w,
                                                child: ImageNetTool(
                                                  url: widget.zpInfo['pic']
                                                              .length >
                                                          0
                                                      ? widget.zpInfo['pic'][0]
                                                          ['img_url']
                                                      : '',
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            this.widget.type == 4 &&
                                                    widget.zpInfo['status'] != 2
                                                ? Positioned(
                                                    bottom: 0,
                                                    right: 0,
                                                    child: Container(
                                                      width: 63.w,
                                                      height: 53.w,
                                                      child: LocalPNG(
                                                        url: widget.zpInfo[
                                                                    'status'] ==
                                                                1
                                                            ? v3UnderRE
                                                            : v3audit,
                                                        fit: BoxFit.fill,
                                                      ),
                                                    ))
                                                : Container(),
                                          ],
                                        )),
                                  ],
                                ),
                              ),
                              widget.type == 4
                                  ? Container(
                                      height: 25.w,
                                      margin: EdgeInsets.only(top: 10.w),
                                      color: Color(0xfffdf0e4),
                                      child: DefaultTextStyle(
                                        style: TextStyle(
                                            color: StyleTheme.cDangerColor,
                                            fontSize: 12.w),
                                        child: Row(
                                          mainAxisAlignment: //1冻结 2到账 3撤销
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Text('冻结:$freezes'),
                                            Text('撤销:$revokes'),
                                            Text('到账:$arrives'),
                                          ],
                                        ),
                                      ))
                                  : Container(),
                              widget.type == 4
                                  ? Container(
                                      margin: EdgeInsets.only(top: 15.w),
                                      child: Flex(
                                        direction: Axis.horizontal,
                                        children: <Widget>[
                                          Expanded(
                                              flex: 1,
                                              child: GestureDetector(
                                                  onTap: () {
                                                    AppGlobal.publishPostType =
                                                        widget.zpInfo[
                                                            'post_type'];
                                                    AppGlobal.appRouter?.push(
                                                        CommonUtils.getRealHash(
                                                            'publishPage/${widget.zpInfo['id']}'));
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        border: Border(
                                                            right: BorderSide(
                                                                color: StyleTheme
                                                                    .textbgColor1,
                                                                width: 1.w))),
                                                    child: Center(
                                                      child: Text(
                                                        '编辑',
                                                        style: TextStyle(
                                                            color: Color(
                                                                0xff5584e3),
                                                            fontSize: 15.sp),
                                                      ),
                                                    ),
                                                  ))),
                                          widget.zpInfo['status'] == 3
                                              ? Expanded(
                                                  flex: 1,
                                                  child: GestureDetector(
                                                      onTap: () {
                                                        showAppeal()
                                                            .then((val) {
                                                          ServiceParmas
                                                                  .orderId =
                                                              "[审核申诉]\n申诉茶帖ID: ${widget.zpInfo.id};\n茶帖标题: ${widget.zpInfo.title};\n申诉原因: ${val!['text']};\n图片证据如下:";
                                                          ServiceParmas.images =
                                                              [val['images']];
                                                          AppGlobal.appRouter
                                                              ?.push(CommonUtils
                                                                  .getRealHash(
                                                                      'onlineServicePage'));
                                                        });
                                                      },
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                            border: Border(
                                                                right: BorderSide(
                                                                    color: StyleTheme
                                                                        .textbgColor1,
                                                                    width:
                                                                        1.w))),
                                                        child: Center(
                                                          child: Text(
                                                            '申诉',
                                                            style: TextStyle(
                                                                color: Color(
                                                                    0xff5584e3),
                                                                fontSize:
                                                                    15.sp),
                                                          ),
                                                        ),
                                                      )))
                                              : Container(),
                                          Expanded(
                                              flex: 1,
                                              child: GestureDetector(
                                                  onTap: () {
                                                    showEdit(
                                                            '删除茶帖', '确定删除该茶帖吗?')
                                                        .then((value) => {
                                                              if (value == true)
                                                                {
                                                                  _deleteFailInfo(widget
                                                                      .zpInfo[
                                                                          'id']
                                                                      .toString())
                                                                }
                                                            });
                                                  },
                                                  child: Container(
                                                    child: Center(
                                                      child: Text(
                                                        '删除',
                                                        style: TextStyle(
                                                            color: StyleTheme
                                                                .cDangerColor,
                                                            fontSize: 15.sp),
                                                      ),
                                                    ),
                                                  )))
                                        ],
                                      ),
                                    )
                                  : Container(),
                              widget.type == 5
                                  ? Container(
                                      margin: EdgeInsets.only(
                                          left: 15.w, top: 15.w),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          BeforePublich(
                                            createdAt: this
                                                .widget
                                                .zpInfo['created_at']
                                                .toString(),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              var phone =
                                                  Provider.of<HomeConfig>(
                                                          context,
                                                          listen: false)
                                                      .member
                                                      .phone;
                                              if (phone == null) {
                                                BotToast.showText(
                                                    text: '需要注册登录才能验证茶帖');
                                                return;
                                              }
                                              var agent =
                                                  Provider.of<GlobalState>(
                                                          context,
                                                          listen: false)
                                                      .profileData?['agent'];
                                              AppGlobal.appRouter?.push(
                                                  CommonUtils.getRealHash(
                                                      'verificationReportPage/' +
                                                          widget.zpInfo['id']
                                                              .toString() +
                                                          '/' +
                                                          agent.toString() +
                                                          '/9/true'));
                                            },
                                            child: Container(
                                              width: 150.w,
                                              child: Center(
                                                child: Text(
                                                  '立即验证资源>',
                                                  style: TextStyle(
                                                      color: StyleTheme
                                                          .cDangerColor,
                                                      fontSize: 15.sp),
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  : (this.widget.type == 1 ||
                                          this.widget.type == 3
                                      ? Container(
                                          padding: EdgeInsets.only(
                                            top: 10.w,
                                            left: 15.w,
                                            right: 10.w,
                                          ),
                                          child: Row(
                                            children: <Widget>[
                                              this.widget.zpInfo['tran_flag'] ==
                                                      1
                                                  ? GestureDetector(
                                                      onTap: () {
                                                        CgDialog.cgShowDialog(
                                                            context,
                                                            '什么是品茶宝',
                                                            '品茶宝是官方创建的安全、可靠的资金托管工具。支持品茶宝交易的茶帖，其他用户可支付元宝托管，确认服务完成后，资金才会到茶帖发布者的账户中。线下交易受骗，平台概不负责!!',
                                                            ['知道了']);
                                                      },
                                                      child: LocalPNG(
                                                        width: 73.5.w,
                                                        height: 21.w,
                                                        url:
                                                            'assets/images/mine/v5/zcpcb.png',
                                                      ),
                                                    )
                                                  : SizedBox(),
                                              SizedBox(
                                                width: 10.w,
                                              ),
                                              BeforePublich(
                                                createdAt: this
                                                    .widget
                                                    .zpInfo['created_at']
                                                    .toString(),
                                              ),
                                              Row(
                                                children: <Widget>[
                                                  BottmNumbers(
                                                    assetImage:
                                                        "assets/images/card/unlock.png",
                                                    number: this
                                                        .widget
                                                        .zpInfo['buy'],
                                                  ),
                                                  BottmNumbers(
                                                    assetImage:
                                                        "assets/images/card/collect.png",
                                                    number: this
                                                        .widget
                                                        .zpInfo['favorite'],
                                                  ),
                                                  BottmNumbers(
                                                      assetImage:
                                                          "assets/images/card/confirm.png",
                                                      number: this
                                                          .widget
                                                          .zpInfo['confirm'])
                                                ],
                                              )
                                            ],
                                          ),
                                        )
                                      : Container())
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // this.widget.type != 5 &&
                  //         widget.zpInfo?.status == 2 &&
                  //         this.widget.zpInfo.authentication == true &&
                  //         this.widget.type != 4
                  //     ? Positioned(
                  //         top: 0,
                  //         right: 10.w,
                  //         child: Container(
                  //           width: GVScreenUtil.setWidth(80),
                  //           height: GVScreenUtil.setWidth(200),
                  //           decoration: BoxDecoration(
                  //             image: DecorationImage(
                  //                 fit: BoxFit.cover,
                  //                 image: AssetImage(
                  //                     "assets/images/card/certifications.png")),
                  //           ),
                  //         ),
                  //       )
                  //     : SizedBox(),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: widget.isPeifu
                        ? LocalPNG(
                            width: 55.w,
                            height: 55.w,
                            url: "assets/images/card/peifu.png",
                            fit: BoxFit.cover,
                          )
                        : SizedBox(),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
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
                    TextStyle(fontSize: 15.sp, color: StyleTheme.cTitleColor),
                hintText: topic),
          ),
        ));
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
                        '茶帖申诉',
                        style: TextStyle(
                            color: StyleTheme.cTitleColor,
                            fontSize: 18.sp,
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
                                    '申诉原因',
                                    style: TextStyle(
                                        color: StyleTheme.cTitleColor,
                                        fontSize: 16.w,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                                _inputDetail('简单描述一下申诉原因', appealController),
                                // Container(
                                //   margin:
                                //       EdgeInsets.only(top: 15.w, bottom: 15.w),
                                //   child: Text(
                                //     '图片证据',
                                //     style: TextStyle(
                                //         color: StyleTheme.cTitleColor,
                                //         fontSize: 16.w,
                                //         fontWeight: FontWeight.w500),
                                //   ),
                                // ),
                                // previewImage(context)
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
                                  ),
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
                              }
                              // if (images.length < 1) {
                              //   return BotToast.showText(
                              //       text: '请上传至少一张图片证据',
                              //       align: Alignment(0, 0));
                              // }
                              await onUpdate().then((value) => {
                                    Navigator.of(context).pop({
                                      'text': appealController.text,
                                      'images': _piclist
                                    }),
                                  });
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
                                  ),
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

  Future<void> onUpdate() async {
    BotToast.showCustomLoading(toastBuilder: (cancelFunc) {
      return Container(
        padding: const EdgeInsets.all(15),
        decoration: const BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.all(Radius.circular(8))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            LoadingGif(
              width: 1.sw / 5,
            ),
            SizedBox(
              height: 12.5.w,
            ),
            Text(
              '上传中...',
              style: TextStyle(color: Colors.white, fontSize: 14.w),
            )
          ],
        ),
      );
    });
    // images = (images == null) ? [] : images;
    // for (var i = 0; i < images.length; i++) {
    //   // 获取 ByteData
    //   String imagePath = images[i].path;
    //   var resultFutrue =
    //       Future<dynamic>.delayed(Duration(seconds: 2), () async {
    //     return await GVDio().uploadImage(
    //       imageUrl: imagePath,
    //     );
    //   });
    //   var resultJson = await resultFutrue;
    //   var convert = jsonDecode(resultJson.data);
    //   if (convert['code'] == 1) {
    //     var newImagePath = convert['msg'];
    //     _piclist.add(newImagePath);
    //   }
    // }
    BotToast.closeAllLoading();
  }

  Future<bool?> showEdit(String title, dynamic content, [bool? type]) {
    String comfDel = '确认删除';
    return showDialog<bool?>(
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
                        title,
                        style: TextStyle(
                            color: StyleTheme.cTitleColor,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                        margin: new EdgeInsets.only(top: 20.w),
                        child: (content is String)
                            ? Text(
                                content,
                                style: TextStyle(
                                    fontSize: 14.w,
                                    color: StyleTheme.cTitleColor),
                              )
                            : content),
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
                                  ),
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
                                    height: 50.w,
                                    width: 110.w,
                                    url: 'assets/images/mymony/money-img.png',
                                  ),
                                  Center(
                                      child: Text(
                                    type == null ? comfDel : '刷新',
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

_buildContent(Map item) {
  if (item['type'] == 'text') {
    if (item['show']) {
      if (["", null, false, 0, "0"].contains(item['content'])) {
        return SizedBox();
      } else {
        return Expanded(
          flex: 1,
          child: Text(
            item['content'] ?? '',
            style: TextStyle(color: Color(0xFF646464), fontSize: 11.sp),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }
    } else {
      return SizedBox();
    }
  } else if (item['type'] == 'star') {
    return Container(
      child: StarRating(
        rating: item['content'],
        size: 8.w,
        spacing: 5.w,
        disable: true,
      ),
    );
  }
}

class BottmNumbers extends StatelessWidget {
  final String? assetImage;
  final dynamic number;
  const BottmNumbers({Key? key, this.assetImage, this.number})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String zero = '0';
    return Container(
      margin: EdgeInsets.only(left: 15.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          LocalPNG(
            url: assetImage!,
            width: 15.w,
            height: 15.w,
          ),
          Text(
            number == null ? zero : "$number",
            style: TextStyle(color: StyleTheme.cBioColor, fontSize: 12.sp),
          )
        ],
      ),
    );
  }
}

class BeforePublich extends StatelessWidget {
  final String? createdAt;
  BeforePublich({Key? key, this.createdAt}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var dataTimes =
        DateTime.fromMillisecondsSinceEpoch(int.parse(createdAt!) * 1000);
    var beforeText = RelativeDateFormat.format(dataTimes);
    return Text("$beforeText更新",
        style: TextStyle(color: StyleTheme.cBioColor, fontSize: 12.sp));
  }
}

class CollectInformation extends StatelessWidget {
  final bool isCollect;
  final GestureTapCallback? onTap;

  const CollectInformation({Key? key, this.isCollect = false, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String iscollect = 'assets/images/card/iscollect.png';
    String notcollect = 'assets/images/card/notcollect.png';
    return Container(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 25.w,
          height: 25.w,
          margin: EdgeInsets.symmetric(horizontal: 15.w),
          child: LocalPNG(
            width: 25.w,
            height: 25.w,
            url: isCollect ? iscollect : notcollect,
          ),
        ),
      ),
    );
  }
}
