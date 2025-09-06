import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/netimage_tool.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../utils/cache/image_net_tool.dart';

class NakedchtCard extends StatelessWidget {
  final Map? data;
  const NakedchtCard({Key? key, this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (int.parse('${data!['status']}') != 1) {
          CommonUtils.showText('该资源状态不可访问');
          return;
        }
        AppGlobal.appRouter
            ?.push(CommonUtils.getRealHash('nakedchatDetail/${data!['id']}'));
      },
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.w),
            boxShadow: [
              BoxShadow(
                  color: Colors.black12,
                  offset: Offset(0, 0.5.w),
                  blurRadius: 2.5.w)
            ]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadiusDirectional.vertical(
                      top: Radius.circular(10.w)),
                  child: Container(
                    height: 170.w,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(10.w))),
                    child: ImageNetTool(
                      url: data!['cover'],
                    ),
                  ),
                ),
                Positioned(
                    top: 0,
                    left: 10.w,
                    child: (data!['buy_count'] ?? 0) == 0
                        ? SizedBox()
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 5.w),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: Color.fromRGBO(255, 65, 73, 1),
                                    borderRadius: BorderRadius.vertical(
                                        bottom: Radius.circular(3.w))),
                                height: 17.w,
                                child: Text(
                                  '${data!['buy_count']}人聊过',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12.w),
                                ),
                              )
                            ],
                          ))
              ],
            ),
            Expanded(
                child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.w),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(10.w))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    data!['title'].toString(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: StyleTheme.cTitleColor, fontSize: 15.w),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${data!['girl_age']}岁',
                        style: TextStyle(color: Colors.black, fontSize: 12.w),
                      ),
                      SizedBox(
                        width: 15.w,
                      ),
                      data!['girl_tags'].isEmpty
                          ? SizedBox()
                          : Expanded(
                              child: Text(
                              '#${data!['girl_tags'].replaceAll(',', '#')}',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 12.w,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
                            ))
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
