import 'package:chaguaner2023/components/loading.dart';
import 'package:chaguaner2023/store/global.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/cgprivilege.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class PublishGuide extends StatefulWidget {
  PublishGuide({Key? key}) : super(key: key);

  @override
  _PublishGuideState createState() => _PublishGuideState();
}

class _PublishGuideState extends State<PublishGuide> {
  bool isNullList = false;
  bool isLoadding = true;
  List? randomUser;
  String isVipStr = "assets/images/publish/is_vip.png";
  String needVipStr = "assets/images/publish/need_vip.png";

  _onGetProxyData() async {
    var result = await getRewardUser();
    if (result!['data'] != null) {
      setState(() {
        isLoadding = false;
        randomUser = result['data'];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _onGetProxyData();
  }

  @override
  Widget build(BuildContext context) {
    var vipValue;
    var profile = Provider.of<GlobalState>(context).profileData;
    if (["", null, false, 0].contains(profile)) {
      vipValue = 0;
    } else {
      vipValue = profile?['vip_level'];
    }
    return Scaffold(
      backgroundColor: Color(0xFFCE1C4E),
      body: isLoadding
          ? Loading()
          : Stack(
              children: <Widget>[
                SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      LocalPNG(
                        width: double.infinity,
                        height: 256.w,
                        url: "assets/images/publish/publish_guide_header.png",
                      ),
                      Container(
                        transform: Matrix4.translationValues(0.0, -30.w, 0.0),
                        width: double.infinity,
                        padding: EdgeInsets.all(15.w),
                        child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                              height: 210.w,
                              child: LocalPNG(
                                width: double.infinity,
                                height: 210.w,
                                url: "assets/images/publish/vip_guide.png",
                              ),
                            ),
                            randomUser!.length > 0
                                ? Container(
                                    width: double.infinity,
                                    padding:
                                        EdgeInsets.symmetric(vertical: 15.w),
                                    child: Text(
                                      "他们已经在茶馆赚钱",
                                      style: TextStyle(
                                          fontSize: 15.sp, color: Colors.white),
                                    ),
                                  )
                                : SizedBox(),
                            randomUser!.length > 0
                                ? SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: randomUser!
                                            .asMap()
                                            .keys
                                            .map((e, {index}) =>
                                                publishGuideUserItem(
                                                    randomUser![e]['thumb'],
                                                    randomUser![e]['nickname']))
                                            .toList()),
                                  )
                                : SizedBox(),
                            GestureDetector(
                              onTap: () {
                                if (AppGlobal.publishPostType == 0 &&
                                    CgPrivilege.getPrivilegeStatus(
                                        PrivilegeType.infoStore,
                                        PrivilegeType.privilegeCreate)) {
                                  AppGlobal.appRouter?.push(
                                      CommonUtils.getRealHash(
                                          'publishPage/null'));
                                } else if (AppGlobal.publishPostType == 1 &&
                                    CgPrivilege.getPrivilegeStatus(
                                        PrivilegeType.infoPersonal,
                                        PrivilegeType.privilegeCreate)) {
                                  AppGlobal.appRouter?.push(
                                      CommonUtils.getRealHash(
                                          'publishPage/null'));
                                } else {
                                  AppGlobal.appRouter?.push(
                                      CommonUtils.getRealHash(
                                          'memberCardsPage'));
                                }
                              },
                              child: Container(
                                width: double.infinity,
                                height: 50.w,
                                margin: EdgeInsets.symmetric(vertical: 40.w),
                                child: LocalPNG(
                                  width: double.infinity,
                                  height: 50.w,
                                  url: vipValue > 0 ? isVipStr : needVipStr,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: ScreenUtil().statusBarHeight,
                  child: Container(
                    width: 1.sw,
                    child: Row(
                      children: <Widget>[
                        IconButton(
                          padding: EdgeInsets.only(left: 20.0),
                          icon: Icon(Icons.arrow_back_ios),
                          onPressed: () => context.pop(),
                          iconSize: 25.0,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget publishGuideUserItem(String avatar, String username) {
    return Container(
        margin: EdgeInsets.only(right: 20.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipOval(
              child: Container(
                width: 30.w,
                height: 30.w,
                color: const Color(0xFFFFFFFF),
                child: LocalPNG(
                  url: "assets/images/common/$avatar.png",
                ),
              ),
            ),
            SizedBox(height: 10.w),
            Text(
              username,
              style: TextStyle(fontSize: 12.sp, color: Colors.white),
            ),
          ],
        ));
  }
}
