import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/list/public_list.dart';
import 'package:chaguaner2023/components/page_title_bar.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OfficeMessagePage extends StatefulWidget {
  OfficeMessagePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => SystemNoticeState();
}

class SystemNoticeState extends State<OfficeMessagePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HeaderContainer(
        child: Scaffold(
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        child: PageTitleBar(
          title: '官方通知',
        ),
        preferredSize: Size(double.infinity, 44.w),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        child: PublicList(
            api: '/api/message/getGroupNoticeList',
            data: {},
            isShow: true,
            row: 1,
            itemBuild: (context, index, data, page, limit, getListData) {
              return noticeTimeItem(data);
            }),
      ),
    ));
  }

  Widget noticeTimeItem(Map item) {
    return Container(
      child: Column(
        children: [
          item['created_at'] != null
              ? Container(
                  margin: new EdgeInsets.only(bottom: 20.w),
                  child: Center(
                    child: Text(
                        CommonUtils.getCgTime(
                            int.parse(item['created_at'].toString())),
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: StyleTheme.cBioColor,
                          height: 1.5,
                        )),
                  ),
                )
              : Container(),
          noticeItem(item['title'], item['content'])
        ],
      ),
    );
  }

  Widget noticeItem(String title, String content) {
    return Container(
      margin: new EdgeInsets.only(bottom: 20.w),
      width: double.infinity,
      decoration: BoxDecoration(boxShadow: [
        //阴影
        BoxShadow(
            color: Colors.black12, offset: Offset(0, 0.5.w), blurRadius: 2.5.w)
      ], color: Colors.white, borderRadius: BorderRadius.circular(10.w)),
      padding: new EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: new EdgeInsets.only(bottom: 10.w),
            child: Text(
              title,
              style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: StyleTheme.cTitleColor),
            ),
          ),
          Container(
              child: Text(
            content,
            style: TextStyle(
              fontSize: 14.sp,
              color: StyleTheme.cTextColor,
              height: 1.5,
            ),
            // maxLines: 4,
            // overflow: TextOverflow.ellipsis,
          )),
        ],
      ),
    );
  }
}
