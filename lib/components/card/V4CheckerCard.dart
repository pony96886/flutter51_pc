import 'package:bot_toast/bot_toast.dart';
import 'package:chaguaner2023/components/starrating.dart';
import 'package:chaguaner2023/store/global.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:chaguaner2023/utils/netimage_tool.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class V4CheckerCard extends StatefulWidget {
  final int type;
  final bool isCollect;
  final zpInfo;
  final deleteCallBack;
  final Function? reqCallBack;
  V4CheckerCard(
      {Key? key,
      this.type = 0,
      this.isCollect = false,
      this.zpInfo,
      this.deleteCallBack,
      this.reqCallBack})
      : super(key: key);
  @override
  V4CheckerCardState createState() => new V4CheckerCardState();
}

class V4CheckerCardState extends State<V4CheckerCard> {
  bool isFavorite = true;
  List? _cardInfos;
  Map<int, String> servicesStatus = {};

  @override
  void initState() {
    super.initState();
    var tabLists = Provider.of<GlobalState>(context, listen: false).infotype;
    if (tabLists.length > 0) {
      tabLists.forEach((e) {
        servicesStatus.addAll({e['id']: e['title']});
      });
    }
    setState(() {
      _cardInfos = [
        {
          'title': '类型：',
          'content': widget.zpInfo['type'] == null
              ? widget.zpInfo['name']
              : servicesStatus[widget.zpInfo['type']],
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
    });
  }

  Widget build(BuildContext context) {
    String tongguo = 'assets/images/card/tongguo.png';
    String jujue = 'assets/images/card/jujue.png';
    return Stack(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(15.w, 0, 15.w, 0),
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
                    Positioned.fill(
                        child: LocalPNG(
                      fit: BoxFit.fill,
                      url: "assets/images/card/cardbg.png",
                    )),
                    Padding(
                      padding: EdgeInsets.only(
                          top: 10.w, left: 15.w, right: 10.w, bottom: 10.w),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          GestureDetector(
                              onTap: () {
                                if (widget.type == 1 ||
                                    widget.type == 2 ||
                                    widget.zpInfo['status'] == 2) {
                                  AppGlobal.appRouter?.push(
                                      CommonUtils.getRealHash(
                                          'resourcesDetailPage/null/' +
                                              widget.zpInfo['id'].toString() +
                                              '/null/null/2'));
                                }
                              },
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
                                                  fontSize: 14.sp),
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
                                                        _cardInfos![key]
                                                                    ['show'] ==
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
                                                                            color:
                                                                                Color(0xFF646464),
                                                                            fontSize: 11.sp)),
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
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(100),
                                      child: Container(
                                        width: 140.w,
                                        height: 140.w,
                                        color: Color(0xFFF2F3EE),
                                        child: NetImageTool(
                                          url: widget.zpInfo['pic'].length > 0
                                              ? widget.zpInfo['pic'][0]['url']
                                              : '',
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )),
                          this.widget.type == 1
                              ? GestureDetector(
                                  onTap: () {
                                    checkerPick(widget.zpInfo['id'].toString())
                                        .then((res) {
                                      if (res!['status'] != 0) {
                                        CommonUtils.showText('领取成功');
                                        widget.reqCallBack!();
                                      } else {
                                        CommonUtils.showText(res['msg']);
                                      }
                                    });
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(top: 10.w),
                                    padding: EdgeInsets.only(top: 10.w),
                                    decoration: BoxDecoration(
                                      border: Border(
                                          top: BorderSide(
                                              width: 1,
                                              color: Color(0xFFEEEEEE))),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '领取任务',
                                        style: TextStyle(
                                            color: Color(0xFF5584E3),
                                            fontSize: 15.sp),
                                      ),
                                    ),
                                  ),
                                )
                              : SizedBox(),
                          this.widget.type == 2
                              ? Container(
                                  margin: EdgeInsets.only(top: 10.w),
                                  padding: EdgeInsets.only(top: 10.w),
                                  decoration: BoxDecoration(
                                    border: Border(
                                        top: BorderSide(
                                            width: 1,
                                            color: Color(0xFFEEEEEE))),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Expanded(
                                          child: GestureDetector(
                                        onTap: () {
                                          showBuy('拒绝理由(选填)', null, 1)
                                              .then((val) {
                                            if (val != null) {
                                              checkerCheck(
                                                      widget.zpInfo['id']
                                                          .toString(),
                                                      2,
                                                      val['value'])
                                                  .then((res) {
                                                if (res!['status'] != 0) {
                                                  BotToast.showText(
                                                      text: "审核成功",
                                                      align: Alignment.center);
                                                  widget.reqCallBack!();
                                                } else {
                                                  BotToast.showText(
                                                      text: res['msg'],
                                                      align: Alignment.center);
                                                }
                                              });
                                            }
                                          });
                                        },
                                        behavior: HitTestBehavior.translucent,
                                        child: Container(
                                          child: Center(
                                            child: Text(
                                              '拒绝',
                                              style: TextStyle(
                                                  color: Color(0xFFFF4149),
                                                  fontSize: 15.sp),
                                            ),
                                          ),
                                        ),
                                      )),
                                      Container(
                                        width: 1,
                                        height: 18.sp,
                                        color: Color(0xFFEEEEEE),
                                      ),
                                      Expanded(
                                          child: GestureDetector(
                                        onTap: () {
                                          showBuy('确认信息', '确定审核通过？', 2)
                                              .then((val) {
                                            if (val != null) {
                                              checkerCheck(
                                                      widget.zpInfo['id']
                                                          .toString(),
                                                      1,
                                                      null)
                                                  .then((res) {
                                                if (res!['status'] != 0) {
                                                  BotToast.showText(
                                                      text: "审核成功",
                                                      align: Alignment.center);
                                                  widget.reqCallBack!();
                                                } else {
                                                  BotToast.showText(
                                                      text: res['msg'],
                                                      align: Alignment.center);
                                                }
                                              });
                                            }
                                          });
                                        },
                                        behavior: HitTestBehavior.translucent,
                                        child: Container(
                                          child: Center(
                                            child: Text(
                                              '通过',
                                              style: TextStyle(
                                                  color: Color(0xFF5584E3),
                                                  fontSize: 15.sp),
                                            ),
                                          ),
                                        ),
                                      ))
                                    ],
                                  ))
                              : SizedBox(),
                          this.widget.type == 3
                              ? Container(
                                  padding: EdgeInsets.only(
                                    top: 10.w,
                                    left: 10.w,
                                    right: 10.w,
                                  ),
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
                                      Row(
                                        children: <Widget>[
                                          BottmNumbers(
                                            assetImage:
                                                "assets/images/card/unlock.png",
                                            number: this.widget.zpInfo['buy'],
                                          ),
                                          BottmNumbers(
                                            assetImage:
                                                "assets/images/card/collect.png",
                                            number:
                                                this.widget.zpInfo['favorite'],
                                          ),
                                          BottmNumbers(
                                            assetImage:
                                                "assets/images/card/confirm.png",
                                            number:
                                                this.widget.zpInfo['confirm'],
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                )
                              : Container()
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        widget.type == 3
            ? Positioned(
                right: 15.w,
                top: 0,
                child: LocalPNG(
                  width: 60.w,
                  height: 60.w,
                  url: widget.zpInfo['status'] == 2 ? tongguo : jujue,
                ))
            : Container()
      ],
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

  Future<dynamic> showBuy(String title, String? content, int type,
      [String? btnText]) {
    TextEditingController inputValue = TextEditingController();
    String submitS = '提交';
    return showDialog<dynamic>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 280.w,
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
                    type == 1
                        ? Container(
                            margin: EdgeInsets.only(top: 15.sp),
                            child: _inputDetail('请输入拒绝理由(选填)', inputValue),
                          )
                        : Container(
                            margin: new EdgeInsets.only(top: 20.w),
                            child: Text(
                              content!,
                              style: TextStyle(
                                  fontSize: 14.sp,
                                  color: StyleTheme.cTitleColor),
                            )),
                    Row(
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
                            if (type == 1) {
                              if (inputValue.text
                                      .replaceAll(RegExp(' '), '')
                                      .length <
                                  5) {
                                BotToast.showText(
                                    text: '理由长度为至少五个字符～',
                                    align: Alignment(0, 0));
                                return;
                              }
                              Navigator.of(context)
                                  .pop({'value': inputValue.text});
                            } else {
                              Navigator.of(context).pop(true);
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
                                ),
                                Center(
                                    child: Text(
                                  type == 1 ? submitS : '确定',
                                  style: TextStyle(
                                      fontSize: 15.sp, color: Colors.white),
                                )),
                              ],
                            ),
                          ),
                        )
                      ],
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
            style: TextStyle(color: Color(0xFF646464), fontSize: 11.w),
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
        size: 10.sp,
        spacing: 5,
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
    String zeros = '0';
    return Container(
      margin: EdgeInsets.only(left: 25.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          LocalPNG(
            url: assetImage!,
            width: 15.w,
            height: 15.w,
          ),
          Text(
            number == null ? zeros : "$number",
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
