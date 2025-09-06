import 'package:bot_toast/bot_toast.dart';
import 'package:chaguaner2023/components/cgDialog.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/cache/image_net_tool.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:chaguaner2023/utils/netimage_tool.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ElegantRankCard extends StatefulWidget {
  final Map? cardInfo;
  ElegantRankCard({Key? key, this.cardInfo}) : super(key: key);
  @override
  _ElegantRankCardState createState() => _ElegantRankCardState();
}

class _ElegantRankCardState extends State<ElegantRankCard> {
  @override
  Widget build(BuildContext context) {
    List resources =
        (widget.cardInfo!['resources'] ?? widget.cardInfo!['pic']) as List;
    var image = resources.firstWhere((v) => v['type'] == 1, orElse: () => null);
    var imgCover = image == null ? ['300', '300'] : image['cover'].split(',');
    var isVideo = (resources.where((v) => v['type'] == 2).toList().length > 0);

    var adaptHeigbt =
        (double.parse(imgCover[1]) / (double.parse(imgCover[0]) / 170.w));
    var maxHeight = adaptHeigbt > 1.sh / 3 ? 1.sh / 3 : adaptHeigbt;

    String underReview = 'assets/images/card/under-review.png';
    String auditFail = 'assets/images/card/audit-failure.png';

    return GestureDetector(
      onTap: () {
        var _id = widget.cardInfo!['info_id'] == null
            ? widget.cardInfo!['id'].toString()
            : widget.cardInfo!['info_id'].toString();
        if (widget.cardInfo!['status'] == 2) {
          AppGlobal.appRouter
              ?.push(CommonUtils.getRealHash('vipDetailPage/' + _id + '/1'));
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

                    // (widget.cardInfo!['status'] == 2 ||
                    //             widget.cardInfo!['status'] == 5) &&
                    //         widget.cardInfo!['appointment'] != 0 &&
                    //         widget.status != 2
                    //     ? Positioned(
                    //         top: 0,
                    //         left: 10.w,
                    //         child: Container(
                    //           // height:20.w,
                    //           padding: EdgeInsets.symmetric(
                    //               vertical: 1.w, horizontal: 4.5.w),
                    //           decoration: BoxDecoration(
                    //             color: Color(0xFFFF4149),
                    //             borderRadius: BorderRadius.only(
                    //                 bottomLeft: Radius.circular(5),
                    //                 bottomRight: Radius.circular(5)),
                    //           ),
                    //           child: Text(
                    //               widget.cardInfo!['appointment'].toString() +
                    //                   '人约过',
                    //               style: TextStyle(
                    //                   color: Colors.white, fontSize: 10.sp)),
                    //         ))
                    //     : SizedBox(),
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
                      Text(
                        widget.cardInfo!['title'],
                        style: TextStyle(
                            color: StyleTheme.cTitleColor, fontSize: 15.sp),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
