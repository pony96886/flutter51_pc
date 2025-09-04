import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NetworkErr extends StatefulWidget {
  final Function()? errorRetry;
  final bool? transparent;
  NetworkErr({Key? key, this.errorRetry, this.transparent}) : super(key: key);

  @override
  State<StatefulWidget> createState() => NetworkErrState();
}

class NetworkErrState extends State<NetworkErr> {
  String networkPng = 'assets/images/default_netword.png';
  String nonetworkPng = 'assets/images/card/huakui-nonetwork.png';
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.errorRetry,
      child: Center(
          child: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        child: Container(
          color: widget.transparent == null ? Colors.white : Colors.transparent,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              LocalPNG(
                width: (widget.transparent == null ? 150 : 160).w,
                height: (widget.transparent == null ? 150 : 115).w,
                url: widget.transparent == null ? networkPng : nonetworkPng,
              ),
              Text(
                "客官～ 网络好像出问题了～",
                style: TextStyle(
                    color: widget.transparent == null
                        ? StyleTheme.cBioColor
                        : Color(0xff8a1e21),
                    fontSize: 14.sp),
              ),
              SizedBox(height: 10.w),
              widget.transparent == null
                  ? Text(
                      '点击重试',
                      style: TextStyle(
                          color: StyleTheme.cDangerColor, fontSize: 12.sp),
                    )
                  : GestureDetector(
                      onTap: () {
                        widget.errorRetry!();
                      },
                      child: Center(
                        child: Container(
                          width: 120.w,
                          height: 35.w,
                          margin: EdgeInsets.only(top: 20.w),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.w),
                            border: Border.all(
                                width: 1.w, color: Color(0xff8a1e21)),
                          ),
                          child: Center(
                            child: Text(
                              '点击重试',
                              style: TextStyle(
                                  fontSize: 15.sp, color: Color(0xff8a1e21)),
                            ),
                          ),
                        ),
                      ),
                    )
            ],
          ),
        ),
      )),
    );
  }
}
