import 'package:bot_toast/bot_toast.dart';
import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/pagetitlebar.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/cgprivilege.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:chaguaner2023/view/homepage/online_service.dart';
import 'package:chaguaner2023/view/im/im.dart';
import 'package:chaguaner2023/view/im/im_page.dart';
import 'package:chaguaner2023/view/yajian/vip_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NakedChatSuccess extends StatefulWidget {
  final Map? data;
  const NakedChatSuccess({Key? key, this.data}) : super(key: key);

  @override
  State<NakedChatSuccess> createState() => _NakedChatSuccessState();
}

class _NakedChatSuccessState extends State<NakedChatSuccess> {
  Widget rowText(String title, String content) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 14.sp, color: Color(0xFF969693)),
        ),
        Text(
          content,
          style: TextStyle(fontSize: 14.sp, color: StyleTheme.cTitleColor),
        )
      ],
    );
  }

  toLlIm() {
    Map user = widget.data!['user'];
    if (user['uuid'] != null) {
      AppGlobal.chatUser = FormUserMsg(
          uuid: user['uuid'].toString(),
          nickname: user['nickname'].toString(),
          avatar: user['thumb'].toString());
      AppGlobal.appRouter?.go(CommonUtils.getRealHash('llchat'));
    } else {
      BotToast.showText(text: '数据出现错误，无法私聊～', align: Alignment(0, 0));
    }
  }

  connectGirl() {
    if (!CgPrivilege.getPrivilegeStatus(
        PrivilegeType.infoSystem, PrivilegeType.privilegeIm)) {
      CommonUtils.showVipDialog(context,
          PrivilegeType.infoSysteString + PrivilegeType.privilegeImString);
      return;
    }
    if (WebSocketUtility.imToken == null) {
      CommonUtils.getImPath(context, callBack: () {
        //跳转IM
        toLlIm();
      });
    } else {
      //跳转IM
      toLlIm();
    }
  }

  @override
  Widget build(BuildContext context) {
    return HeaderContainer(
        child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Column(
              children: [
                PageTitleBar(
                  title: '裸聊',
                ),
                Expanded(
                    child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 15.w,
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 21.w,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.data!['price'].toString(),
                            style: TextStyle(
                                color: StyleTheme.cTitleColor, fontSize: 36.w),
                          ),
                          Text('元宝',
                              style: TextStyle(
                                  color: StyleTheme.cTitleColor,
                                  fontSize: 18.w)),
                        ],
                      ),
                      SizedBox(
                        height: 64.w,
                      ),
                      BottomLine(),
                      rowText('预约妹子', widget.data!['title']),
                      BottomLine(),
                      rowText('发布用户', widget.data!['user']['nickname']),
                      BottomLine(),
                      Spacer(),
                      Text(
                        '交易完成后，评价可获得元宝优惠券奖励',
                        style: TextStyle(
                            color: StyleTheme.cDangerColor, fontSize: 12.sp),
                      ),
                      SizedBox(
                        height: 38.5.w,
                      ),
                      GestureDetector(
                        onTap: () {
                          ServiceParmas.type = 'chat';
                          AppGlobal.appRouter?.push(
                              CommonUtils.getRealHash('onlineServicePage'));
                        },
                        child: Stack(
                          children: [
                            LocalPNG(
                              width: 275.w,
                              height: 50.w,
                              url: 'assets/images/mymony/money-img.png',
                            ),
                            Positioned.fill(
                                child: Center(
                                    child: Text(
                              '前往聊天',
                              style: TextStyle(
                                  fontSize: 15.w, color: Colors.white),
                            ))),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 64.w + ScreenUtil().bottomBarHeight,
                      ),
                    ],
                  ),
                ))
              ],
            )));
  }
}
