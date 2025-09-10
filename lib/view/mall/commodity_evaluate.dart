import 'package:chaguaner2023/components/card/mall_order_card.dart';
import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/page_status.dart';
import 'package:chaguaner2023/components/page_title_bar.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class CommodityEvaluate extends StatefulWidget {
  const CommodityEvaluate({Key? key, this.id}) : super(key: key);
  final int? id;
  @override
  State<CommodityEvaluate> createState() => _CommodityEvaluateState();
}

class _CommodityEvaluateState extends State<CommodityEvaluate> {
  String content = '';
  _submit() {
    PageStatus.showLoading();
    productEvaluation(order_id: widget.id, content: content).then((res) {
      if (res!['status'] != 0) {
        CommonUtils.showText('评价成功～');
        context.pop();
      } else {
        CommonUtils.showText(res['msg'] ?? '系统错误～');
      }
    }).whenComplete(() {
      PageStatus.closeLoading();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: HeaderContainer(
            child: Scaffold(
                backgroundColor: Colors.transparent,
                appBar: PreferredSize(
                    child: PageTitleBar(
                      title: '评价',
                      rightWidget: GestureDetector(
                          onTap: () {
                            context.push(
                                CommonUtils.getRealHash('mallComplaint/1'));
                          },
                          child: Center(
                            child: Container(
                              margin: new EdgeInsets.only(right: 15.w),
                              child: Text(
                                '投诉',
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
                  children: [
                    Expanded(
                        child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        MallOrderCard(
                          isEvaluation: true,
                          data: AppGlobal.mallOrder,
                        ),
                        Container(
                          height: 140.w,
                          padding: EdgeInsets.all(10.w),
                          margin: EdgeInsets.only(
                              top: 17.w, left: 15.w, right: 15.w),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.w),
                              color: Color(0xfff5f5f5)),
                          child: TextField(
                            maxLines: 999,
                            onChanged: (e) {
                              content = e;
                            },
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.zero,
                              hintText: '说说你对商品的想法吧',
                              hintStyle: TextStyle(
                                  color: Color(0xffb4b4b4), fontSize: 15.sp),
                              labelStyle: TextStyle(
                                  color: Color(0xff1e1e1e), fontSize: 15.sp),
                              border: InputBorder
                                  .none, // Removes the default border
                            ),
                          ),
                        ),
                      ],
                    )),
                    Center(
                      child: GestureDetector(
                        onTap: _submit,
                        child: Stack(
                          children: [
                            Positioned.fill(
                                child: LocalPNG(
                                    url:
                                        'assets/images/elegantroom/shuimo_btn.png')),
                            Container(
                              width: 275.w,
                              height: 50.w,
                              alignment: Alignment.center,
                              child: Text(
                                '确认提交',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 15.sp),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: ScreenUtil().bottomBarHeight + 10.w,
                    )
                  ],
                ))));
  }
}
