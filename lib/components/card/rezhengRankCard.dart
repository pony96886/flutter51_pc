import 'package:chaguaner2023/components/avatar_widget.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:chaguaner2023/utils/netimage_tool.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RenZhengRankCard extends StatefulWidget {
  final Map? chapuData;
  final bool? isNew;
  RenZhengRankCard({Key? key, this.chapuData, this.isNew = true}) : super(key: key);

  @override
  _RenZhengRankCardState createState() => _RenZhengRankCardState();
}

class _RenZhengRankCardState extends State<RenZhengRankCard> {
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
    print(widget.chapuData);
    List resources =
        (widget.chapuData!['resources'] ?? widget.chapuData!['pic']) as List;
    return widget.isNew!
        ? GestureDetector(
            onTap: () {
              AppGlobal.appRouter?.push(CommonUtils.getRealHash(
                  'gilrDrtailPage/' +
                      widget.chapuData!['id'].toString() +
                      '/' +
                      widget.chapuData!['type'].toString()));
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
                                url: resources.length > 0
                                    ? resources[0]['url']
                                    : '',
                                fit: BoxFit.cover,
                              ),
                            ),
                            widget.chapuData!['type'] == 2 &&
                                    widget.chapuData!['girl_age'] == "0"
                                ? Positioned(
                                    top: 5.w,
                                    left: 5.w,
                                    child: LocalPNG(
                                        width: 35.w,
                                        height: 13.w,
                                        url: 'assets/images/xiuxi.png',
                                        fit: BoxFit.cover))
                                : Container(),
                            widget.chapuData!['type'] == 2 &&
                                    widget.chapuData!['girl_face'] != null
                                ? Positioned(
                                    right: 0,
                                    top: 0,
                                    child: Container(
                                      height: 17.w,
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 3.w),
                                      decoration: BoxDecoration(
                                          color: Color(0xffee4257),
                                          borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(5))),
                                      child: Center(
                                        child: Text.rich(TextSpan(
                                            text: '颜值:',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10.w),
                                            children: [
                                              TextSpan(
                                                text: widget
                                                    .chapuData!['girl_face']
                                                    .toString(),
                                                style: TextStyle(
                                                    color: Color(0xffffff96),
                                                    fontSize: 10.sp),
                                              ),
                                              TextSpan(
                                                text: '分',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10.sp),
                                              )
                                            ])),
                                      ),
                                    ))
                                : Container(),
                            Positioned(
                                bottom: 5.w,
                                left: 10.w,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    widget.chapuData!['appointment'] == 0
                                        ? Container()
                                        : Container(
                                            height: 16.w,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 7.5.w),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(3),
                                                color: Color(0xffdbc1a0)),
                                            child: Center(
                                              child: Text(
                                                '成交' +
                                                    widget.chapuData![
                                                            'appointment']
                                                        .toString() +
                                                    '单',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 11.sp),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                  ],
                                ))
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
                                widget.chapuData!['title'],
                                style: TextStyle(
                                    fontSize: 15.w,
                                    fontWeight: FontWeight.w500,
                                    color: StyleTheme.cTitleColor),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              // SizedBox(
                              //   height: GVScreenUtil.setWidth(15),
                              // ),
                              widget.chapuData!['type'] == 3
                                  ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(7.5),
                                          child: Container(
                                            width: 15.w,
                                            height: 15.w,
                                            child: Avatar(
                                              type: widget.chapuData!['thumb'],
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 5.w,
                                        ),
                                        // Flexible(
                                        //     child: Text(
                                        //   widget.chapuData!['nickname'],
                                        //   style: TextStyle(
                                        //       fontSize: 11.sp,
                                        //       color: Color(0xff646464)),
                                        //   maxLines: 1,
                                        //   overflow: TextOverflow.ellipsis,
                                        // ))
                                      ],
                                    )
                                  : Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          widget.chapuData!['girl_age_num']
                                                  .toString() +
                                              '岁  ' +
                                              widget.chapuData!['girl_height']
                                                  .toString() +
                                              'cm ' +
                                              widget.chapuData!['girl_cup_str']
                                                  .toString(),
                                          style: TextStyle(
                                              fontSize: 11.sp,
                                              color: Color(0xff646464)),
                                        )
                                      ],
                                    ),
                              Text(
                                '消费情况:' + widget.chapuData!['price'],
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
          )
        : Stack(
            children: [
              GestureDetector(
                onTap: () {
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) => GilrDrtailPage(
                  //             id: widget.chapuData.id.toString(),
                  //             type: widget.chapuData.type)));
                },
                child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: 15.w),
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
                          width: double.infinity,
                          height: double.infinity,
                          url: "assets/images/card/cpcard-bg.png",
                          fit: BoxFit.cover),
                      Padding(
                        padding: EdgeInsets.all(15.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    height: 95.w,
                                    width: 95.w,
                                    color: Color(0xfff2f3ee),
                                    child: Center(
                                      child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          child: Stack(
                                            children: [
                                              Container(
                                                width: 85.w,
                                                height: 85.w,
                                                child: NetImageTool(
                                                  url: resources.length > 0
                                                      ? resources[0]['url']
                                                      : '',
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              widget.chapuData!['type'] == 2 &&
                                                      widget.chapuData![
                                                              'girl_face'] !=
                                                          null
                                                  ? Positioned(
                                                      right: 0,
                                                      top: 0,
                                                      child: Container(
                                                        height: 17.w,
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal:
                                                                    3.w),
                                                        decoration: BoxDecoration(
                                                            color: Color(
                                                                0xffee4257),
                                                            borderRadius:
                                                                BorderRadius.only(
                                                                    bottomLeft:
                                                                        Radius.circular(
                                                                            5))),
                                                        child: Center(
                                                          child: Text.rich(TextSpan(
                                                              text: '颜值:',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize:
                                                                      10.sp),
                                                              children: [
                                                                TextSpan(
                                                                  text: widget
                                                                      .chapuData![
                                                                          'girl_face']
                                                                      .toString(),
                                                                  style: TextStyle(
                                                                      color: Color(
                                                                          0xffffff96),
                                                                      fontSize:
                                                                          10.sp),
                                                                ),
                                                                TextSpan(
                                                                  text: '分',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          10.sp),
                                                                )
                                                              ])),
                                                        ),
                                                      ))
                                                  : Container()
                                            ],
                                          )),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 15.w,
                                ),
                                Container(
                                  height: 85.w,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            widget.chapuData!['title'],
                                            style: TextStyle(
                                                fontSize: 15.sp,
                                                fontWeight: FontWeight.w500,
                                                color: StyleTheme.cTitleColor),
                                          ),
                                          SizedBox(
                                            height: 7.5.w,
                                          ),
                                          widget.chapuData!['type'] == 3
                                              ? Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              7.5),
                                                      child: Container(
                                                        width: 15.w,
                                                        height: 15.w,
                                                        child: Avatar(
                                                          type:
                                                              widget.chapuData![
                                                                  'thumb'],
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 5.w,
                                                    ),
                                                    Text(
                                                      widget.chapuData![
                                                          'nickname'],
                                                      style: TextStyle(
                                                          fontSize: 11.sp,
                                                          color: Color(
                                                              0xff646464)),
                                                    )
                                                  ],
                                                )
                                              : Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      widget.chapuData![
                                                                  'girl_age_num']
                                                              .toString() +
                                                          '岁  ' +
                                                          widget.chapuData![
                                                                  'girl_height']
                                                              .toString() +
                                                          'cm ' +
                                                          widget.chapuData![
                                                                  'girl_cup_str']
                                                              .toString(),
                                                      style: TextStyle(
                                                          fontSize: 11.sp,
                                                          color: Color(
                                                              0xff646464)),
                                                    )
                                                  ],
                                                )
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          widget.chapuData!['appointment'] == 0
                                              ? Container()
                                              : Container(
                                                  margin: EdgeInsets.only(
                                                      right: 10.w),
                                                  height: 16.w,
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 7.5.w),
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              3),
                                                      color: Color(0xffff4149)),
                                                  child: Center(
                                                    child: Text(
                                                      '成交' +
                                                          widget.chapuData![
                                                              'appointment'] +
                                                          '单',
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 11.sp),
                                                    ),
                                                  ),
                                                ),
                                          Container(
                                            height: 16.w,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 7.5.w),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(3),
                                                color: Color(0xffdbc1a0)),
                                            child: Center(
                                              child: Text(
                                                '消费情况:' +
                                                    widget.chapuData!['price'],
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 11.w),
                                              ),
                                            ),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 19.5.w,
                            ),
                            Text(
                              widget.chapuData!['desc'],
                              style: TextStyle(
                                  fontSize: 11.sp, color: Color(0xff646464)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                  top: 0,
                  right: 25.w,
                  child: LocalPNG(
                      width: 30.w,
                      height: 85.w,
                      url: 'assets/images/card/renzheng.png',
                      fit: BoxFit.cover))
            ],
          );
  }
}
