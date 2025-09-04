import 'package:chaguaner2023/components/cgDialog.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:chaguaner2023/utils/netimage_tool.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MallGirlCard extends StatefulWidget {
  const MallGirlCard({Key? key, this.data, this.isDelete = false})
      : super(key: key);
  final Map? data;
  final bool isDelete;
  @override
  State<MallGirlCard> createState() => _MallGirlCardState();
}

class _MallGirlCardState extends State<MallGirlCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.data!['status'] != 1) {
          CommonUtils.showText('当前状态不可查看');
          return;
        }
        AppGlobal.appRouter?.push(
            CommonUtils.getRealHash('commodityDetail/${widget.data!['id']}'));
      },
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
            boxShadow: [
              BoxShadow(
                  color: Colors.black12,
                  offset: Offset(0, 0.5.w),
                  blurRadius: 2.5.w)
            ]),
        child: Column(
          children: [
            Container(
              height: 170.w,
              child: NetImageTool(
                radius: BorderRadius.only(
                  topLeft: Radius.circular(5.w),
                  topRight: Radius.circular(5.w),
                ),
                url: widget.data!['cover_images'][0]['media_url_full'],
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
                child: Padding(
              padding: EdgeInsets.all(10.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.data!['title'],
                    style: TextStyle(
                        color: Color(0xff1e1e1e),
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${widget.data!['price'].toString().split('.')[0]}元宝',
                        style: TextStyle(
                          color: Color(0xffff4149),
                          fontSize: 12.sp,
                        ),
                      ),
                      Text(
                          widget.data!['buy_num'] > 999
                              ? '1000人+付款'
                              : '${widget.data!['buy_num']}人付款',
                          style: TextStyle(
                            color: Color(0xffb4b4b4),
                            fontSize: 12.sp,
                          )),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10.w),
                        child: SizedBox(
                          width: 20.w,
                          height: 20.w,
                          child: LocalPNG(
                            width: double.infinity,
                            height: double.infinity,
                            url:
                                'assets/images/common/${widget.data!['user'] == null ? '1' : widget.data!['user']['thumb']}.png',
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 8.w,
                      ),
                      Expanded(
                          child: Text(
                              widget.data!['user'] == null
                                  ? '茶馆用户'
                                  : widget.data!['user']['nickname'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Color(0xff1e1e1e),
                                fontSize: 12.sp,
                              ))),
                      widget.isDelete
                          ? GestureDetector(
                              onTap: () {
                                CgDialog.cgShowDialog(
                                    context, '提示', '是否删除该商品', ['取消', '确定'],
                                    callBack: () {
                                  productDelete(widget.data!['id']).then((res) {
                                    if (res!['status'] != 0) {
                                      CommonUtils.showText('删除成功,下拉刷新查看');
                                    } else {
                                      CommonUtils.showText(
                                          res['msg'] ?? '系统错误～');
                                    }
                                  });
                                });
                              },
                              child: Container(
                                width: 50.w,
                                height: 20.w,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: StyleTheme.cDangerColor,
                                    borderRadius: BorderRadius.circular(10.w)),
                                child: Text(
                                  '删除',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            )
                          : SizedBox()
                    ],
                  )
                ],
              ),
            ))
          ],
        ),
      ),
    );
  }
}
