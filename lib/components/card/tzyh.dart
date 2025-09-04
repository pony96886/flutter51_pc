import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TianZiYiHao extends StatefulWidget {
  final dynamic vipClub;
  TianZiYiHao({Key? key, this.vipClub}) : super(key: key);

  @override
  _TianZiYiHaoState createState() => _TianZiYiHaoState();
}

class _TianZiYiHaoState extends State<TianZiYiHao> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70.w,
      child: Stack(
        children: [
          LocalPNG(
              width: double.infinity,
              height: 70.w,
              url: "assets/images/tzyh/tzyh_banner.png",
              fit: BoxFit.fill),
          Container(
            width: double.infinity,
            height: 70.w,
            padding: EdgeInsets.only(left: 84.5.w, right: 10.w, top: 15.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LocalPNG(
                      url: 'assets/images/tzyh/tzyh_text.png',
                      height: 20.w,
                      fit: BoxFit.fitHeight,
                    ),
                    Text(
                      widget.vipClub == 0
                          ? '茶馆老板钦点高端定制化俱乐部'
                          : '编号：${widget.vipClub}',
                      style: TextStyle(fontSize: 12.sp, color: Colors.white),
                    )
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    AppGlobal.appRouter?.push(CommonUtils.getRealHash(
                        'tianZiYiHaoPage/${widget.vipClub}'));
                  },
                  child: LocalPNG(
                    url: 'assets/images/tzyh/jinru.png',
                    height: 30.w,
                    fit: BoxFit.fitHeight,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
