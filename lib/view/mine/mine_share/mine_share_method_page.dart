import 'package:chaguaner2023/components/page_title_bar.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class MineShareMethodPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MineShareMethodPageState();
}

class MineShareMethodPageState extends State<MineShareMethodPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      color: Color(0xFF11131A),
      child: Stack(
        children: [
          LocalPNG(
            height: double.infinity,
            width: double.infinity,
            url: "assets/images/share/share-method-bg.png",
            alignment: Alignment.topLeft,
            fit: BoxFit.contain,
          ),
          Scaffold(
              backgroundColor: Colors.transparent,
              appBar: PreferredSize(
                  child: PageTitleBar(
                    backColor: Colors.white,
                    title: '推广方法',
                    color: Colors.white,
                  ),
                  preferredSize: Size(double.infinity, 44.w)),
              body: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //头部
                    LocalPNG(url: 'assets/images/share/share-method-content.png', width: 352.5.w),
                    //底部
                    Column(children: [
                      Container(
                          width: double.infinity,
                          height: 49.w,
                          alignment: Alignment.center,
                          child: Stack(
                            children: [
                              LocalPNG(
                                url: 'assets/images/share/share-bg-footer.png',
                                fit: BoxFit.contain,
                                width: double.infinity,
                                height: 49.w,
                              ),
                              Center(
                                child: GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: _toBack,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '学会了,去推广  ',
                                          style: TextStyle(color: Color(0xFFB8C1CC), fontSize: 12.sp),
                                        ),
                                        LocalPNG(
                                          url: 'assets/images/share/share-entr.png',
                                          height: 10.w,
                                        ),
                                      ],
                                    )),
                              ),
                            ],
                          )),
                      Container(
                        width: double.infinity,
                        height: ScreenUtil().bottomBarHeight,
                        color: Color(0xFF11131A),
                      )
                    ])
                  ],
                ),
              )),
        ],
      ),
    );
  }

  void _toBack() {
    context.pop();
  }
}
