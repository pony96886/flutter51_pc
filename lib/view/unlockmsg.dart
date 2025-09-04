import 'package:chaguaner2023/components/avatar_widget.dart';
import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/list/public_list.dart';
import 'package:chaguaner2023/components/pagetitlebar.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UnlockPage extends StatefulWidget {
  UnlockPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => UnlockPageState();
}

class UnlockPageState extends State<UnlockPage> {
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
    return Container(
      child: HeaderContainer(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: PreferredSize(
            child: PageTitleBar(
              title: '解锁和验证',
            ),
            preferredSize: Size(double.infinity, 44.w),
          ),
          body: PublicList(
            api: '/api/message/getMessageList',
            data: {},
            row: 1,
            isShow: true,
            itemBuild: (context, index, data, page, limit, getListData) {
              return msgBox(data);
            },
          ),
        ),
      ),
    );
  }

  Widget msgBox(Map item) {
    return GestureDetector(
      child: Container(
        margin: new EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.w),
        child: Row(
          children: [
            Container(
              margin: new EdgeInsets.only(right: 9.5.w),
              width: 45.w,
              height: 45.w,
              child: Avatar(
                type: item['thumb'],
                // onPress: () {
                //   Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //           builder: (context) => BrokerHomepage(
                //                 brokerName: item['nickname'],
                //                 aff: item['aff'].toString(),
                //                 thumb: item['thumb'],
                //               )));
                // },
              ),
            ),
            Expanded(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      item['nickname'],
                      style: TextStyle(
                          color: StyleTheme.cTitleColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 16.sp),
                    ),
                    Text(
                      item['created_at'] == null
                          ? ''
                          : CommonUtils.getCgTime(
                              int.parse(item['created_at'].toString())),
                      style: TextStyle(
                          color: StyleTheme.cTextColor, fontSize: 12.sp),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [getMsgType(item['content']), Text('')],
                )
              ],
            ))
          ],
        ),
      ),
    );
  }

  Widget getMsgType(List content) {
    return Expanded(
        child: Text.rich(
      TextSpan(
          text: content[0]['value'],
          style: TextStyle(
              color: Color(int.parse(content[0]['color'])), fontSize: 14.sp),
          children: [
            content.length > 1
                ? TextSpan(
                    text: content[1]['value'],
                    style: TextStyle(
                        color: Color(int.parse(content[1]['color'])),
                        fontSize: 14.sp),
                  )
                : TextSpan(),
          ]),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    ));
  }
}
