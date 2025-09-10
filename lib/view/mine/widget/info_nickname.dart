import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../store/global.dart';
import '../../../store/homeConfig.dart';
import '../../../theme/style_theme.dart';
import '../../../utils/app_global.dart';
import '../../../utils/common.dart';
import '../../../utils/local_png.dart';

class InfoNickname extends StatelessWidget {
  InfoNickname({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var profile = Provider.of<GlobalState>(context).profileData;
    int vipValue = 0;
    if (["", null, false, 0].contains(profile)) {
      vipValue = 0;
    } else {
      vipValue = profile?['vip_level'];
    }
    return Consumer<HomeConfig>(
      builder: (ctx, state, child) {
        String ones = '1';
        String ltimeStr = state.member.oltime == 1 ? ones : '2';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  '${state.member.nickname}',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    color: StyleTheme.cTitleColor,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(
                  width: 5.w,
                ),
                state.member.vipUpgrade!
                    ? GestureDetector(
                        onTap: () {
                          AppGlobal.appRouter?.push(CommonUtils.getRealHash('memberCardsPage'));
                        },
                        behavior: HitTestBehavior.translucent,
                        child: Text("升级会员", style: TextStyle(color: StyleTheme.cDangerColor, fontSize: 10.sp)),
                      )
                    : SizedBox()
              ],
            ),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                if (state.member.oltime != 1) {
                  AppGlobal.appRouter?.push(
                      CommonUtils.getRealHash('webview/' + Uri.encodeComponent(UserInfo.wxykUrl!) + '/' + '无限悦帖'));
                }
              },
              child: LocalPNG(
                url: 'assets/images/mine/wuxian' + ltimeStr + '.png',
                height: 23.w,
                filterQuality: FilterQuality.medium,
                fit: BoxFit.fitHeight,
              ),
            )
          ],
        );
      },
    );
  }
}
