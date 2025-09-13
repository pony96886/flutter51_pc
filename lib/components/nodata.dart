import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NoData extends StatefulWidget {
  final String? text;
  final bool? transparent;
  final Function? refresh;

  NoData({Key? key, this.text, this.transparent, this.refresh}) : super(key: key);

  @override
  State<StatefulWidget> createState() => NoDataState();
}

class NoDataState extends State<NoData> {
  String emptyPng = 'assets/images/empty-data.png';
  String noDataPng = 'assets/images/card/huakui-nodata.png';

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.transparent == null ? Colors.white : Colors.transparent,
      child: Center(
          child: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        child: Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LocalPNG(
                url: widget.transparent == null ? emptyPng : noDataPng,
                width: (widget.transparent == null ? 150 : 160).w,
                height: (widget.transparent == null ? 150 : 115).w,
              ),
              Container(
                margin: EdgeInsets.only(top: (widget.transparent == null ? 0 : 20).w),
                child: Center(
                    child: Text(
                  widget.text!,
                  style: TextStyle(
                      fontSize: 14.sp, color: widget.transparent == null ? StyleTheme.cBioColor : Color(0xff8a1e21)),
                )),
              ),
              if (widget.transparent != null)
                GestureDetector(
                    onTap: () {
                      widget.refresh!();
                    },
                    child: Center(
                      child: Container(
                        width: 120.w,
                        height: 35.w,
                        margin: EdgeInsets.only(top: 20.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.w),
                          border: Border.all(width: 1.w, color: Color(0xff8a1e21)),
                        ),
                        child: Center(
                          child: Text(
                            '点击刷新',
                            style: TextStyle(fontSize: 15.sp, color: Color(0xff8a1e21)),
                          ),
                        ),
                      ),
                    ))
            ],
          ),
        ),
      )),
    );
  }
}
