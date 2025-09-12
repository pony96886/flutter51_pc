import 'package:bot_toast/bot_toast.dart';
import 'package:chaguaner2023/components/cgDialog.dart';
import 'package:chaguaner2023/store/global.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/cache/image_net_tool.dart';
import 'package:chaguaner2023/utils/cgprivilege.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:chaguaner2023/utils/netimage_tool.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ElegantCard extends StatefulWidget {
  final int? keys;
  final int? type;
  final bool? edit;
  final Function? editCallBack;
  final int? status;
  final Map? cardInfo;
  final bool? isCollect;
  ElegantCard(
      {Key? key,
      this.keys,
      this.type,
      this.edit = false,
      this.editCallBack,
      this.status,
      this.cardInfo,
      this.isCollect = false})
      : super(key: key);
  @override
  _ElegantCardState createState() => _ElegantCardState();
}

class _ElegantCardState extends State<ElegantCard> {
  Future<bool?> showBuy(String title, String content, int type,
      [String? btnText]) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 280.w,
            padding:
                new EdgeInsets.symmetric(vertical: 15.sp, horizontal: 25.sp),
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
                        child: Text(
                          content,
                          style: TextStyle(
                              fontSize: 14.sp, color: StyleTheme.cTitleColor),
                        )),
                    type == 0
                        ? GestureDetector(
                            onTap: () {
                              context.pop();
                            },
                            child: GestureDetector(
                              onTap: () {
                                AppGlobal.appRouter?.push(
                                    CommonUtils.getRealHash('memberCardsPage'));
                              },
                              child: Container(
                                margin: new EdgeInsets.only(top: 30.w),
                                height: 50.w,
                                width: 200.w,
                                child: Stack(
                                  children: [
                                    LocalPNG(
                                        height: 50.w,
                                        width: 200.w,
                                        url:
                                            'assets/images/mymony/money-img.png',
                                        fit: BoxFit.fill),
                                    Center(
                                        child: Text(
                                      btnText ?? '去开通',
                                      style: TextStyle(
                                          fontSize: 15.sp, color: Colors.white),
                                    )),
                                  ],
                                ),
                              ),
                            ))
                        : Row(
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
                                          url:
                                              'assets/images/mymony/money-img.png',
                                          fit: BoxFit.fill),
                                      Center(
                                          child: Text(
                                        '取消',
                                        style: TextStyle(
                                            fontSize: 15.sp,
                                            color: Colors.white),
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
                                          url:
                                              'assets/images/mymony/money-img.png',
                                          fit: BoxFit.fill),
                                      Center(
                                          child: Text(
                                        '确定',
                                        style: TextStyle(
                                            fontSize: 15.sp,
                                            color: Colors.white),
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
                          fit: BoxFit.cover)),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var profileDatas = Provider.of<GlobalState>(context).profileData;
    // var agnet = Provider.of<HomeConfig>(context).member.agent;
    var vipLevel = profileDatas != null ? profileDatas['vip_level'] : 0;
    List resources =
        (widget.cardInfo!['resources'] ?? widget.cardInfo!['pic']) as List;
    var image = resources.firstWhere((v) => v['type'] == 1,
        orElse: () => null); //找出第一张图片
    var imgCover = image == null ? ['300', '300'] : image['cover'].split(',');
    var isVideo = (resources.where((v) => v['type'] == 2).toList().length > 0);

    var adaptHeigbt =
        (double.parse(imgCover[1]) / (double.parse(imgCover[0]) / 170.w));
    var maxHeight = adaptHeigbt > 1.sh / 3 ? 1.sh / 3 : adaptHeigbt;

    String working = '工作中';
    String resting = '休息中';

    String underReview = 'assets/images/card/under-review.png';
    String auditFail = 'assets/images/card/audit-failure.png';

    String upSre = '上';
    String downStr = '下';

    return GestureDetector(
      onTap: () {
        if (widget.isCollect! && widget.cardInfo!['status'] == 4) {
          CgDialog.cgShowDialog(
              context, '提示', '该资源已被删除,是否为您取消收藏?', ['取消', '确定'],
              callBack: () async {
            var favorite = await favoriteVip(widget.cardInfo!['id'].toString());
            if (favorite!['status'] != 0) {
              BotToast.showText(
                  text: '已为您取消收藏,可下拉刷新列表～', align: Alignment(0, 0));
            } else {
              BotToast.showText(text: favorite['msg'], align: Alignment(0, 0));
            }
          });
          return;
        }
        var _id = widget.cardInfo!['info_id'] == null
            ? widget.cardInfo!['id'].toString()
            : widget.cardInfo!['info_id'].toString();
        if (widget.cardInfo!['status'] == 2) {
          if (CgPrivilege.getPrivilegeStatus(
              PrivilegeType.infoVip, PrivilegeType.privilegeAppointment)) {
            AppGlobal.appRouter?.push(
                CommonUtils.getRealHash('vipDetailPage/' + _id + '/null/'));
          } else {
            CommonUtils.showVipDialog(
                context, '购买会员才能在线预约雅间妹子，平台担保交易，照片和人不匹配平台包赔，让你约到合乎心意的妹子',
                isFull: true);
          }
        } else {
          BotToast.showText(text: '资源正在处理中,请稍后再试', align: Alignment(0, 0));
        }
      },
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
            boxShadow: [
              BoxShadow(
                  color: Colors.black12,
                  offset: Offset(0, 0.5.w),
                  blurRadius: 2.5.w)
            ]),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Container(
            width: 170.w,
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    Stack(
                      children: <Widget>[
                        Container(
                          width: 170.w,
                          height: maxHeight,
                          child: resources.length > 0 &&
                                  resources[0]['url'] != null
                              ? ImageNetTool(
                                  url: image['url'],
                                )
                              : LocalPNG(
                                  url: "assets/images/default_image.png",
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        isVideo
                            ? Positioned(
                                top: 10.w,
                                right: 10.w,
                                child: LocalPNG(
                                  url: "assets/images/elegantroom/play.png",
                                  width: 20.w,
                                  height: 20.w,
                                ),
                              )
                            : SizedBox()
                      ],
                    ),
                    widget.edit == true
                        ? Positioned(
                            top: 0,
                            left: 0,
                            child: GestureDetector(
                              onTap: () async {
                                if (widget.cardInfo!['status'] == 6) {
                                  //视频切片中
                                  BotToast.showText(
                                      text: '资源正在处理中,不允许删除哦～',
                                      align: Alignment(0, 0));
                                } else {
                                  await showBuy('删除茶女郎', '确定要删除该茶女郎吗?', 1)
                                      .then((val) => {
                                            if (val == true)
                                              {
                                                deleteVipInfo(widget
                                                        .cardInfo!['id']
                                                        .toString())
                                                    .then((res) {
                                                  if (res!['status'] != 0) {
                                                    widget.editCallBack!();
                                                    BotToast.showText(
                                                        text: '茶女郎删除成功～',
                                                        align: Alignment(0, 0));
                                                  } else {
                                                    BotToast.showText(
                                                        text: res['msg'],
                                                        align: Alignment(0, 0));
                                                  }
                                                })
                                              }
                                          });
                                  // 新的调用方式：
                                  // await ShowBuyDialog.showWithType(
                                  //   context: context,
                                  //   title: '删除茶女郎',
                                  //   content: '确定要删除该茶女郎吗?',
                                  //   type: 1,
                                  // ).then((val) => {
                                  //   if (val == true) {
                                  //     deleteVipInfo(widget.cardInfo!['id'].toString()).then((res) {
                                  //       if (res!['status'] != 0) {
                                  //         widget.editCallBack!();
                                  //         BotToast.showText(text: '茶女郎删除成功～', align: Alignment(0, 0));
                                  //       } else {
                                  //         BotToast.showText(text: res['msg'], align: Alignment(0, 0));
                                  //       }
                                  //     });
                                  //   }
                                  // });
                                }
                              },
                              child: LocalPNG(
                                width: 30.w,
                                height: 30.w,
                                url: "assets/images/elegantroom/del.png",
                              ),
                            ),
                          )
                        : SizedBox(),
                    widget.status != null
                        ? Positioned(
                            top: 0,
                            right: 10.w,
                            child: Container(
                              // height:20.w,
                              padding: EdgeInsets.symmetric(
                                  vertical: 1.w, horizontal: 4.5.w),
                              decoration: BoxDecoration(
                                color: widget.cardInfo!['status'] == 1
                                    ? Color(0xFFFF4149)
                                    : Color(0xFFCD79FF),
                              ),
                              child: Text(
                                  widget.cardInfo!['status'] == 2
                                      ? working
                                      : resting,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12.sp)),
                            ))
                        : SizedBox(),
                    (widget.cardInfo!['status'] == 2 ||
                                widget.cardInfo!['status'] == 5) &&
                            widget.cardInfo!['appointment'] != 0 &&
                            widget.status != 2
                        ? Positioned(
                            top: 0,
                            left: 10.w,
                            child: Container(
                              // height:20.w,
                              padding: EdgeInsets.symmetric(
                                  vertical: 1.w, horizontal: 4.5.w),
                              decoration: BoxDecoration(
                                color: Color(0xFFFF4149),
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(5),
                                    bottomRight: Radius.circular(5)),
                              ),
                              child: Text(
                                  widget.cardInfo!['appointment'].toString() +
                                      '人约过',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 10.sp)),
                            ))
                        : SizedBox(),
                    (widget.cardInfo!['status'] == 1 ||
                            widget.cardInfo!['status'] == 3)
                        ? Positioned(
                            top: 5.w,
                            right: 5.w,
                            child: LocalPNG(
                                width: 63.w,
                                height: 53.5.w,
                                url: widget.cardInfo!['status'] == 1
                                    ? underReview
                                    : auditFail,
                                fit: BoxFit.contain))
                        : Container(),
                    Positioned(
                        right: 10.w,
                        bottom: 10.w,
                        child: widget.cardInfo!['video_valid'] == 1
                            ? GestureDetector(
                                onTap: () {
                                  CgDialog.cgShowDialog(
                                      context,
                                      '视频认证',
                                      '视频认证指茶老板将妹子素颜视频提交官方认证，官方确认人照差距不大后才会有视频认证的标识。',
                                      ['知道了']);
                                },
                                child: LocalPNG(
                                  fit: BoxFit.cover,
                                  width: (54.5 * 1.2).w,
                                  height: (17.5 * 1.2).w,
                                  url: 'assets/images/card/videorenzheng.png',
                                ),
                              )
                            : Container())
                  ],
                ),
                Padding(
                  padding: EdgeInsets.all(10.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              widget.cardInfo!['title'],
                              style: TextStyle(
                                  color: StyleTheme.cTitleColor,
                                  fontSize: 15.sp),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Container(
                          //   width: GVScreenUtil.setWidth(33),
                          //   height: GVScreenUtil.setWidth(27),
                          //   decoration: BoxDecoration(
                          //     image: DecorationImage(
                          //         image: AssetImage(
                          //             'assets/images/elegantroom/yuanbao.png'),
                          //         fit: BoxFit.cover),
                          //   ),
                          // ),
                          // Text(widget.cardInfo.fee.toString(),
                          //     style: TextStyle(
                          //         color: Color(0xFFFF4149),
                          //         fontSize: 12.w))
                        ],
                      ),
                      SizedBox(
                        height: 5.w,
                      ),
                      Text.rich(
                        TextSpan(
                            text: "最低消费: ",
                            style: TextStyle(
                                color: StyleTheme.cTitleColor, fontSize: 12.sp),
                            children: [
                              TextSpan(
                                  text: widget.cardInfo!['price_p'] == null
                                      ? '未设置'
                                      : widget.cardInfo!['price_p'].toString() +
                                          "元",
                                  style: TextStyle(
                                      color: StyleTheme.cDangerColor,
                                      fontSize: 12.w))
                            ]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      widget.cardInfo!['tags'] != null &&
                              widget.cardInfo!['tags'].length > 0
                          ? Container(
                              width: double.infinity,
                              height: 15.sp,
                              margin: EdgeInsets.only(top: 5.w),
                              child: Row(
                                children: <Widget>[
                                  for (var item in widget.cardInfo!['tags']
                                      .getRange(
                                          0,
                                          widget.cardInfo!['tags'].length > 1
                                              ? 2
                                              : 1))
                                    yjTag(item['name'])
                                ],
                              ),
                            )
                          : Container(),
                      widget.status != null
                          ? Row(
                              children: <Widget>[
                                Expanded(
                                  flex: 1,
                                  child: GestureDetector(
                                    onTap: () async {
                                      String status =
                                          widget.cardInfo!['status'] == 2
                                              ? downStr
                                              : upSre;
                                      await showBuy(status + '架茶女郎',
                                              '确定要' + status + '架该茶女郎吗?', 1)
                                          .then((val) => {
                                                if (val == true)
                                                  {
                                                    changeStatusVipInfo(widget
                                                            .cardInfo!['id'])
                                                        .then((res) {
                                                      if (res!['status'] != 0) {
                                                        widget.editCallBack!();
                                                        BotToast.showText(
                                                            text: '茶女郎' +
                                                                status +
                                                                '架成功～',
                                                            align: Alignment(
                                                                0, 0));
                                                      } else {
                                                        BotToast.showText(
                                                            text: '操作失败,请稍后再试～',
                                                            align: Alignment(
                                                                0, 0));
                                                      }
                                                    })
                                                  }
                                              });
                                      // 新的调用方式：
                                      // await ShowBuyDialog.showWithType(
                                      //   context: context,
                                      //   title: status + '架茶女郎',
                                      //   content: '确定要' + status + '架该茶女郎吗?',
                                      //   type: 1,
                                      // ).then((val) => {
                                      //   if (val == true) {
                                      //     changeStatusVipInfo(widget.cardInfo!['id']).then((res) {
                                      //       if (res!['status'] != 0) {
                                      //         widget.editCallBack!();
                                      //         BotToast.showText(text: '茶女郎' + status + '架成功～', align: Alignment(0, 0));
                                      //       } else {
                                      //         BotToast.showText(text: '操作失败,请稍后再试～', align: Alignment(0, 0));
                                      //       }
                                      //     });
                                      //   }
                                      // });
                                    },
                                    child: Container(
                                        margin: EdgeInsets.only(
                                            top: 10.w, bottom: 5.w),
                                        decoration: BoxDecoration(
                                            border: Border(
                                                right: BorderSide(
                                                    width: 0.5,
                                                    color:
                                                        StyleTheme.cBioColor))),
                                        child: widget.cardInfo!['status'] == 2
                                            ? Text(
                                                '下架',
                                                style: TextStyle(
                                                    color: Color(0xFF5584E3),
                                                    fontSize: 14.sp),
                                                textAlign: TextAlign.center,
                                              )
                                            : Text(
                                                '上架',
                                                style: TextStyle(
                                                    color: Color(0xFFFF4149),
                                                    fontSize: 14.sp),
                                                textAlign: TextAlign.center,
                                              )),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: GestureDetector(
                                    onTap: () {
                                      if (widget.cardInfo!['status'] != 6) {
                                        AppGlobal.uploadParmas =
                                            widget.cardInfo!;
                                        AppGlobal.appRouter?.push(
                                            CommonUtils.getRealHash(
                                                'elegantPublishPage'));
                                      } else {
                                        BotToast.showText(
                                            text: '资源正在处理中,请稍后再试～',
                                            align: Alignment(0, 0));
                                      }
                                    },
                                    child: Container(
                                      margin: EdgeInsets.only(
                                          top: 10.w, bottom: 5.w),
                                      child: Text(
                                        '编辑',
                                        style: TextStyle(
                                            color: Color(0xFF5584E3),
                                            fontSize: 14.sp),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : SizedBox()
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget yjTag(String title) {
  int titleN = title.length > 4 ? 4 : (title.length < 2 ? 2 : title.length);
  return Container(
    margin: EdgeInsets.only(right: 5.w),
    height: 15.sp,
    child: Stack(
      children: [
        LocalPNG(
            height: 15.sp,
            url: 'assets/images/card/tag-bg-$titleN.png',
            fit: BoxFit.fill),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 7.w),
          child: Center(
            child: Text(
              title,
              style: TextStyle(fontSize: 10.sp, color: StyleTheme.cDangerColor),
            ),
          ),
        ),
      ],
    ),
  );
}

class TagsItem extends StatelessWidget {
  final String? text;
  const TagsItem({Key? key, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.5.w),
      decoration: BoxDecoration(
        color: Color(0xFFFDF0E4),
        borderRadius: BorderRadius.circular(30),
      ),
      padding: EdgeInsets.symmetric(vertical: 2.5.w, horizontal: 6.5.w),
      child: Text(
        text ?? '',
        style: TextStyle(color: Color(0xFFFF4149), fontSize: 10.sp),
      ),
    );
  }
}
