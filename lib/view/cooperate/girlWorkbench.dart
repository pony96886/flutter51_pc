import 'package:bot_toast/bot_toast.dart';
import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/page_title_bar.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:chaguaner2023/utils/pageviewmixin.dart';
import 'package:chaguaner2023/view/mine/oderForm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GirlWorkbenchPage extends StatefulWidget {
  GirlWorkbenchPage({Key? key}) : super(key: key);
  @override
  _GirlWorkbenchPageState createState() => _GirlWorkbenchPageState();
}

class _GirlWorkbenchPageState extends State<GirlWorkbenchPage> with TickerProviderStateMixin {
  Function? callBack;
  int isWork = 0; //0 休息 1 工作
  int switchoff = 0; // 0 不开启  1 开启
  Map? pageData;
  String networkErrStr = '网络错误';
  String nowoStr = 'nowork';
  String asdaas2 = 'iswork';
  @override
  void initState() {
    super.initState();
    getPageData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  getPageData() async {
    var result = await getPerson();
    if (result!['status'] == 1) {
      pageData = result['data'];
      isWork = int.parse((pageData!['girl_age'] ?? '0').toString());
      switchoff = result['data']['price_pp'] ?? 0;
      setState(() {});
    } else {
      CommonUtils.showText(result['msg']);
    }
  }

  void handleEditChaGirlInfo() async {
    if (pageData == null) {
      BotToast.showText(text: '当前没有茶女郎的信息，无法编辑', align: Alignment(0, 0));
      return;
    }
    AppGlobal.girlParmas = {
      'editInfoData': pageData,
      'editVideo': pageData!['resources'].where((item) => item['type'] == 2).toList(),
      'editImage': pageData!['resources'].where((item) => item['type'] == 1).toList()
    };
    AppGlobal.appRouter?.push(CommonUtils.getRealHash('chaGirlBaseInformation'));
  }

  @override
  Widget build(BuildContext context) {
    String workAssStr = isWork == 1 ? asdaas2 : nowoStr;
    String switchStr = switchoff == 1 ? asdaas2 : nowoStr;
    return HeaderContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: false,
        appBar: PreferredSize(
            child: PageTitleBar(
              title: '茶女郎认证',
              rightWidget: GestureDetector(
                  onTap: handleEditChaGirlInfo,
                  child: Center(
                    child: Container(
                      margin: new EdgeInsets.only(right: 15.w),
                      child: Text(
                        '编辑资料',
                        style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 15.sp, fontWeight: FontWeight.w500),
                      ),
                    ),
                  )),
            ),
            preferredSize: Size(double.infinity, 44.w)),
        body: Column(
          children: [
            SizedBox(
              width: 345.w,
              height: 70.w,
              child: Stack(
                children: [
                  LocalPNG(
                    width: 345.w,
                    height: 70.w,
                    url: 'assets/images/card/nlbanner.png',
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                      top: 9.w,
                      right: 10.w,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isWork = (isWork == 1) ? 0 : 1;
                          });
                          // print(isWork);
                          setGirlWorkingStatus(isWork).then((res) {
                            if (res!['status'] != 0) {
                              BotToast.showText(text: '操作成功～', align: Alignment(0, 0));
                            } else {
                              isWork = (isWork == 1) ? 0 : 1;
                              setState(() {});
                              BotToast.showText(text: res['msg'], align: Alignment(0, 0));
                            }
                          });
                        },
                        child: LocalPNG(
                            url: 'assets/images/card/$workAssStr.png', width: 40.w, height: 20.w, fit: BoxFit.cover),
                      ))
                ],
              ),
            ),
            Container(
              width: 345.w,
              height: 70.w,
              margin: EdgeInsets.only(top: 10.w),
              child: Stack(
                children: [
                  LocalPNG(width: 345.w, height: 70.w, url: 'assets/images/card/chatswitch.png', fit: BoxFit.cover),
                  Positioned(
                      top: 9.w,
                      right: 10.w,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            switchoff = (switchoff == 1) ? 0 : 1;
                          });
                          setGirlChatStatus(switchoff).then((res) {
                            if (res!['status'] != 0) {
                              CommonUtils.showText('操作成功～');
                            } else {
                              switchoff = (switchoff == 1) ? 0 : 1;
                              setState(() {});
                              CommonUtils.showText(res['msg']);
                            }
                          });
                        },
                        child: LocalPNG(
                            url: 'assets/images/card/$switchStr.png', width: 40.w, height: 20.w, fit: BoxFit.cover),
                      ))
                ],
              ),
            ),
            Expanded(
                child: Container(
                    color: Colors.white,
                    child: PageViewMixin(
                      child: OderFromPage(),
                    )))
          ],
        ),
      ),
    );
  }
}
