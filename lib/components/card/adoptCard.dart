import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:chaguaner2023/utils/netimage_tool.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AdoptCard extends StatefulWidget {
  final Map? adoptData;
  final bool? isNew;
  AdoptCard({Key? key, this.adoptData, this.isNew = true}) : super(key: key);

  @override
  _RenZhengCardState createState() => _RenZhengCardState();
}

class _RenZhengCardState extends State<AdoptCard> {
  String loadData = '数据加载中...';
  String noData = '没有更多数据';
  Widget renderMore(bool isloading) {
    return Container(
      width: double.infinity,
      child: Padding(
          padding: EdgeInsets.only(top: 10.w, bottom: 35.w),
          child: Center(
            child: Text(
              isloading ? loadData : noData,
              style: TextStyle(color: StyleTheme.cBioColor),
            ),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    List resources = widget.adoptData!['images'] as List;
    Map videoResources = widget.adoptData!['video'];
    return GestureDetector(
      onTap: () {
        if (widget.adoptData!['status'] == 0) {
          CommonUtils.showText("该资料审核中，暂时无法查看");
        } else {
          AppGlobal.appRouter?.push(CommonUtils.getRealHash(
              'adoptDetailPage/' + widget.adoptData!['id'].toString()));
        }
      },
      child: Container(
        decoration: BoxDecoration(boxShadow: [
          //阴影
          BoxShadow(
              color: Colors.black12,
              offset: Offset(0, 0.5.w),
              blurRadius: 2.5.w)
        ]),
        child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 170.w,
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 170.w,
                        height: 170.w,
                        child: NetImageTool(
                          url: (resources != null &&
                                  resources.isNotEmpty &&
                                  resources[0]['media_url'] != '')
                              ? resources[0]['media_url']
                              : (videoResources != null &&
                                      videoResources['cover'] != null)
                                  ? videoResources['cover']
                                  : '',
                          fit: BoxFit.cover,
                        ),
                      ),
                      widget.adoptData!['is_buy'] ||
                              widget.adoptData!['is_other_user_buy']
                          ? Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                height: 17.w,
                                padding: EdgeInsets.symmetric(horizontal: 3.w),
                                decoration: BoxDecoration(
                                    color: Color(0xffee4257),
                                    borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(5))),
                                child: Center(
                                  child: Text(
                                    '已包养',
                                    style: TextStyle(
                                        color: Color(0xffffffff),
                                        fontSize: 10.sp),
                                  ),
                                ),
                              ))
                          : Container(),
                      Positioned(
                          bottom: 5.w,
                          right: 5.w,
                          child: LocalPNG(
                              width: 62.w,
                              height: 21.w,
                              url: 'assets/images/video_auth.png',
                              fit: BoxFit.cover)),
                    ],
                  ),
                  Container(
                    width: 170.w,
                    height: 70.w,
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.adoptData!['girl_name'],
                          style: TextStyle(
                              fontSize: 15.w,
                              fontWeight: FontWeight.w500,
                              color: StyleTheme.cTitleColor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.adoptData!['age'].toString() +
                                  '岁/' +
                                  widget.adoptData!['height'].toString() +
                                  'cm/' +
                                  widget.adoptData!['weight'].toString() +
                                  'kg/' +
                                  widget.adoptData!['cup'].toString() +
                                  '罩杯',
                              style: TextStyle(
                                  fontSize: 11.sp, color: Color(0xff646464)),
                            )
                          ],
                        ),
                        Text(
                          '所在地区:' + widget.adoptData!['city_name'],
                          style: TextStyle(
                              color: Color(0xff646464), fontSize: 11.sp),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            )),
      ),
    );
  }
}
