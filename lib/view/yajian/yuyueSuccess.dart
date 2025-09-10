import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/page_title_bar.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class Yuyuesuccess extends StatefulWidget {
  final int? fee;
  final String? title;
  final String? nickname;
  final int? youhui;
  final int? type;
  Yuyuesuccess(
      {Key? key, this.youhui, this.fee, this.title, this.nickname, this.type})
      : super(key: key);

  @override
  _YuyuesuccessState createState() => _YuyuesuccessState();
}

class _YuyuesuccessState extends State<Yuyuesuccess> {
  @override
  Widget build(BuildContext context) {
    return HeaderContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
            child: PageTitleBar(
              title: '预约成功',
              rightWidget: GestureDetector(
                  onTap: () {
                    context.go('/home');
                    context.push('/reservationPage');
                  },
                  child: Center(
                    child: Container(
                      margin: new EdgeInsets.only(right: 15.w),
                      child: Text(
                        '完成',
                        style: TextStyle(
                            color: StyleTheme.cTitleColor,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  )),
            ),
            preferredSize: Size(double.infinity, 44.w)),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 181.w,
              width: double.infinity,
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          margin: EdgeInsets.only(right: 11.w),
                          width: 38.w,
                          height: 27.w,
                          child: LocalPNG(
                              width: 38.w,
                              height: 27.w,
                              url: 'assets/images/detail/vip-yuanbao.png',
                              fit: BoxFit.contain),
                        ),
                        Text.rich(TextSpan(
                            text: (widget.fee! - widget.youhui!).toString(),
                            style: TextStyle(
                                color: StyleTheme.cTitleColor, fontSize: 36.sp),
                            children: [
                              TextSpan(
                                text: '元宝',
                                style: TextStyle(
                                    color: StyleTheme.cTitleColor,
                                    fontSize: 18.sp),
                              )
                            ])),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.only(top: 10.w),
                      child: Text(
                        '发布者收款${widget.fee}元宝',
                        style: TextStyle(
                            color: StyleTheme.cBioColor, fontSize: 14.sp),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 15.sp, right: 15.sp),
              child: Column(
                children: [
                  widget.youhui == 0 ? Container() : BottomLine(),
                  widget.youhui == 0
                      ? Container()
                      : rowText('优惠券', '-' + widget.youhui.toString() + '元宝',
                          StyleTheme.cDangerColor),
                  BottomLine(),
                  rowText('预约妹子', widget.title!),
                  BottomLine(),
                  rowText('发布用户', widget.nickname!),
                  BottomLine(),
                ],
              ),
            ),
            Expanded(
                child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 345.w,
                    height: 80.w,
                    child: Stack(
                      children: [
                        LocalPNG(
                            width: 345.w,
                            height: 80.w,
                            url: 'assets/images/card/youhuiquan-cai.png',
                            fit: BoxFit.fill),
                        Padding(
                          padding: EdgeInsets.only(
                            right: 19.w,
                            left: 15.sp,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '元宝优惠券',
                                    style: TextStyle(
                                        fontSize: 18.sp,
                                        color: Color(0xffffff00)),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                      top: 10.w,
                                    ),
                                    child: Text(
                                      '超多元宝等你来领',
                                      style: TextStyle(
                                          fontSize: 14.w,
                                          color: Color(0xffdcdcdc)),
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text.rich(TextSpan(
                                      text: "??",
                                      style: TextStyle(
                                          color: Color(0xffc92630),
                                          fontSize: 30.sp),
                                      children: [
                                        TextSpan(
                                          text: '元宝',
                                          style: TextStyle(
                                              color: Color(0xffc92630),
                                              fontSize: 18.sp),
                                        )
                                      ])),
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 30.w),
                    child: Text(
                      '交易完成后，评价可获得元宝优惠券奖励',
                      style:
                          TextStyle(fontSize: 12.sp, color: Color(0xffc92630)),
                    ),
                  ),
                  SizedBox(
                    height: 20.w,
                  ),
                  AppGlobal.connetGirl == null
                      ? SizedBox()
                      : GestureDetector(
                          onTap: AppGlobal.connetGirl,
                          child: Container(
                            width: 220.w,
                            height: 55.w,
                            margin: new EdgeInsets.only(left: 10.w),
                            child: Stack(
                              children: [
                                LocalPNG(
                                  width: 220.w,
                                  height: 55.w,
                                  url: 'assets/images/mymony/money-img.png',
                                ),
                                Center(
                                  child: Text(
                                    widget.type == 1 ? '联系茶老板' : '联系茶女郎',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                ],
              ),
            ))
          ],
        ),
      ),
    );
  }

  Widget rowText(String title, String content, [Color? color]) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 14.sp, color: Color(0xFF969693)),
            ),
            color != null
                ? Container(
                    margin: EdgeInsets.only(left: 5.w),
                    width: 65.w,
                    height: 20.w,
                    child: LocalPNG(
                      width: 65.w,
                      height: 20.w,
                      url: 'assets/images/elegantroom/zhekou.png',
                    ),
                  )
                : Container()
          ],
        ),
        color != null
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    content,
                    style: TextStyle(color: color, fontSize: 14.sp),
                  ),
                ],
              )
            : Text(
                content,
                style:
                    TextStyle(fontSize: 14.sp, color: StyleTheme.cTitleColor),
              )
      ],
    );
  }
}

class BottomLine extends StatelessWidget {
  const BottomLine({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(
        top: 10.w,
        bottom: 10.w,
      ),
      decoration: BoxDecoration(
        color: Color(0xFFEEEEEE),
        border: Border(
          top: BorderSide.none,
          left: BorderSide.none,
          right: BorderSide.none,
          bottom: BorderSide(width: 0.5, color: Color(0xFFEEEEEE)),
        ),
      ),
    );
  }
}
