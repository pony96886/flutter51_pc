import 'package:chaguaner2023/components/avatar_widget.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ReportNewCard extends StatefulWidget {
  final Map? reportInfo;
  final int? status;
  ReportNewCard({Key? key, this.reportInfo, this.status}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ReportNewCardState();
}

class ReportNewCardState extends State<ReportNewCard> {
  List? _itemList;
  @override
  void initState() {
    super.initState();
    print(widget.reportInfo);
    setState(() {
      _itemList = [
        {'title': '妹子花名', 'introduction': widget.reportInfo!['girl_name']},
        {'title': '品茶时间', 'introduction': widget.reportInfo!['time']},
        {'title': '所在位置', 'introduction': widget.reportInfo!['address']},
        // {'title': '身高身材', 'introduction': widget.reportInfo.girlBody},
        // {'title': '颜值相似', 'introduction': widget.reportInfo.girlFaceLike},
        {
          'title': '服务详情',
          'introduction': widget.reportInfo!['girl_service_detail']
        }
      ];
    });
  }

  @override
  void dispose() {
    _itemList = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AppGlobal.appRouter?.push(CommonUtils.getRealHash('reportDetailPage/' +
            widget.reportInfo!['id'].toString() +
            '/' +
            widget.reportInfo!['info_id'].toString() +
            '/false'));
      },
      child: Container(
        padding: EdgeInsets.only(bottom: 15.w),
        margin: EdgeInsets.symmetric(vertical: 5.w, horizontal: 15.w),
        decoration: BoxDecoration(boxShadow: [
          //阴影
          BoxShadow(
              color: Colors.black12,
              offset: Offset(0, 0.5.w),
              blurRadius: 2.5.w)
        ], color: Colors.white, borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            //  CGAssetsImage(url:
            //   'assets/images/card/card-split.png',
            //   fit: BoxFit.fitHeight,
            //   repeat: ImageRepeat.repeatX,
            //   height: GVScreenUtil.setWidth(16),
            // ),
            Container(
              padding: new EdgeInsets.only(bottom: 6.5.w),
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 10.w),
                    padding: new EdgeInsets.all(5.5.w),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.w),
                    color: Color(0xfff8f8f8),
                        ),
                    child: Column(
                      children: [
                        for (var item in _itemList!)
                          _detaiItem(item['title'], item['introduction'])
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _detaiItem(String title, String introduction) {
    return Row(
      children: [
        Expanded(
            child: Text(
          '【$title】:  $introduction',
          style: TextStyle(
              fontSize: 12.sp, color: StyleTheme.cTitleColor, height: 1.5.w),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ))
      ],
    );
  }

  Widget _header() {
    return Container(
        padding: new EdgeInsets.symmetric(horizontal: 15.5.w, vertical: 12.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 30.w,
                  height: 30.w,
                  margin: new EdgeInsets.only(right: 10.5.w),
                  child: Avatar(
                      onPress: () {
                        AppGlobal.appRouter?.push(CommonUtils.getRealHash(
                            'brokerHomepage/' +
                                widget.reportInfo!['uid'].toString() +
                                '/' +
                                Uri.encodeComponent(
                                    widget.reportInfo!['thumb'].toString()) +
                                '/' +
                                Uri.encodeComponent(widget
                                    .reportInfo!['nickname']
                                    .toString())));
                      },
                      type: widget.reportInfo!['thumb']),
                ),
                (widget.reportInfo?['member'] != null) ?
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Container(
                          constraints: BoxConstraints(maxWidth: 150.w),
                          margin: new EdgeInsets.only(right: 6.w),
                          child: Text(
                            widget.reportInfo!['member']['nickname'],
                            style: TextStyle(
                                fontSize: 15.sp,
                                color: StyleTheme.cTitleColor,
                                fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        widget.reportInfo!['member']['agent'] == 4
                            ? LocalPNG(
                                height: 14.w,
                                width: 48.w,
                                url: 'assets/images/detail/icon-jianchashi.png',
                              )
                            : Container()
                      ],
                    ),
                    Text(
                      CommonUtils.getCgTime(int.parse(
                              widget.reportInfo!['created_at'].toString())) +
                          ' 发布',
                      style: TextStyle(
                          fontSize: 12.sp, color: StyleTheme.cBioColor),
                    )
                  ],
                ) : SizedBox(),
              ],
            ),
            (widget.reportInfo?['video'] ?? widget.reportInfo?['video'] != null)
                ? Container(
                    child: Container(
                      margin: EdgeInsets.only(left: 7.5.w),
                      alignment: Alignment.center,
                      width: 50.w,
                      height: 20.w,
                      child: LocalPNG(
                        width: 50.w,
                        height: 20.w,
                        url: 'assets/images/detail/icon-video.png',
                        alignment: Alignment.center,
                      ),
                    ),
                  )
                : Container()
          ],
        ));
  }
}
