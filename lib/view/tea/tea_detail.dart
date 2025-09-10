import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/page_title_bar.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TeaDetailPage extends StatefulWidget {
  final Map<String, String>? data;
  TeaDetailPage({Key? key, this.data}) : super(key: key);
  @override
  State<StatefulWidget> createState() => TeaDetailState();
}

class TeaDetailState extends State<TeaDetailPage> {
  Widget build(BuildContext context) {
    String price = widget.data!['price']!;
    String buys = widget.data!['buy']!;
    return HeaderContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
            child: PageTitleBar(
              title: '茶叶详情',
            ),
            preferredSize: Size(double.infinity, 44.w)),
        body: Container(
          child: Column(
            children: [
              Expanded(
                  child: ListView(
                shrinkWrap: true,
                padding: new EdgeInsets.all(
                  15.w,
                ),
                children: [
                  LocalPNG(width: double.infinity, height: 240.w, url: widget.data!['image'], fit: BoxFit.cover),
                  Text(
                    widget.data!['name']!,
                    style: TextStyle(fontSize: 18.w, color: StyleTheme.cTitleColor, fontWeight: FontWeight.w500),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('¥$price',
                          style: TextStyle(
                              fontSize: 18.sp,
                              color: StyleTheme.cDangerColor,
                              height: 1.5,
                              fontWeight: FontWeight.w500)),
                      Text(
                        '$buys人购买',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: StyleTheme.cBioColor,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: new EdgeInsets.only(top: 10.sp),
                    child: Row(
                      children: [
                        Expanded(
                            child: Text(
                          widget.data!['decs']!,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: StyleTheme.cTitleColor,
                            height: 1.5,
                          ),
                        ))
                      ],
                    ),
                  ),
                  Container(
                    padding: new EdgeInsets.all(21.w),
                    child: Column(
                      children: [
                        LocalPNG(
                          url: 'assets/images/no-data.png',
                          width: 150.w,
                          height: 150.w,
                        ),
                        Text('目前暂时无货，不可购买',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: StyleTheme.cBioColor,
                            ))
                      ],
                    ),
                  )
                ],
              ))
            ],
          ),
        ),
      ),
    );
  }
}
