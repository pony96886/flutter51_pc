import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/page_title_bar.dart';
import 'package:chaguaner2023/components/tab/tab_nav.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:chaguaner2023/utils/pageviewmixin.dart';
import 'package:chaguaner2023/view/cooperate/IntentionSheet.dart';
import 'package:chaguaner2023/view/cooperate/meizi_mange.dart';
import 'package:chaguaner2023/view/mine/oderForm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WorkbenchPage extends StatefulWidget {
  WorkbenchPage({Key? key}) : super(key: key);
  @override
  _WorkbenchPageState createState() => _WorkbenchPageState();
}

class _WorkbenchPageState extends State<WorkbenchPage>
    with TickerProviderStateMixin {
  Function? callBack;
  List<bool> isIntPage = [true, false, false, false]; //控制页面的载入，不然会有报错
  List headTabs = [
    {
      'id': 0,
      'key': 'meiziguanli',
      'title': '妹子管理',
    },
    {
      'id': 1,
      'key': 'yuyue',
      'title': '预约单',
    },
    {
      'id': 2,
      'key': 'yixiang',
      'title': '意向单',
    },
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return HeaderContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: false,
        appBar: PreferredSize(
            child: PageTitleBar(
              title: '工作台',
              rightWidget: GestureDetector(
                  onTap: () {
                    AppGlobal.uploadParmas = null;
                    AppGlobal.appRouter
                        ?.push(CommonUtils.getRealHash('elegantPublishPage'));
                  },
                  child: Center(
                    child: Container(
                      margin: new EdgeInsets.only(right: 15.w),
                      child: Text(
                        '发布',
                        style: TextStyle(
                            color: StyleTheme.cTitleColor,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  )),
            ),
            preferredSize: Size(double.infinity, 44.w)),
        body: Container(
          color: Colors.white,
          child: Column(
            children: [
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // GestureDetector(
                      //   onTap: () {
                      //     AppGlobal.appRouter?.push(CommonUtils.getRealHash(
                      //         'resourcesCertification'));
                      //   },
                      //   child: LocalPNG(
                      //     url: 'assets/images/elegantroom/cp-banner.png',
                      //     width: 167.w,
                      //     height: 60.w,
                      //   ),
                      // ),
                      GestureDetector(
                        onTap: () {
                          AppGlobal.appRouter
                              ?.push(CommonUtils.getRealHash('chabossconnect'));
                        },
                        child: LocalPNG(
                          url: 'assets/images/elegantroom/cp-connect.png',
                          width: 167.w,
                          height: 60.w,
                        ),
                      )
                    ],
                  )),
              TabNav(
                tabWidth: (1.sw - 15.w) / headTabs.length,
                v4Tabs: headTabs,
                callBack: (e) {},
                isV4ui: true,
                v4Child: <Widget>[
                  PageViewMixin(
                    child: MeiziManage(),
                  ),
                  // 预约单
                  PageViewMixin(
                    child: OderFromPage(),
                  ),
                  //意向单
                  PageViewMixin(
                    child: IntentionSheetPage(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
