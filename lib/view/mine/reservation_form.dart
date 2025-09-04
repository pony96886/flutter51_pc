import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:chaguaner2023/utils/pageviewmixin.dart';
import 'package:chaguaner2023/view/mine/intention_form.dart';
import 'package:chaguaner2023/view/mine/oderForm.dart';
import 'package:chaguaner2023/view/mine/office_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ReservationPage extends StatefulWidget {
  ReservationPage({Key? key}) : super(key: key);

  @override
  _ReservationPageState createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage>
    with TickerProviderStateMixin {
  List _tabs = [
    {
      'title': '预约单',
      'activeWidth': 70.w,
      'inActiveWidth': 70.w,
    },
    {
      'title': '官方单',
      'activeWidth': 70.w,
      'inActiveWidth': 70.w,
    },
    {
      'title': '意向单',
      'activeWidth': 70.w,
      'inActiveWidth': 70.w,
    }
  ];
  ValueNotifier<int> _selectedTabIndex = ValueNotifier<int>(0);
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: _tabs.length);
    _tabController!.addListener(() {
      _selectedTabIndex.value = _tabController!.index;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _tabController!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HeaderContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: StyleTheme.cTitleColor,
          ),
          title: PreferredSize(
              child: Container(
                margin: new EdgeInsets.only(left: 20.w),
                height: 50.w,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    ValueListenableBuilder(
                        valueListenable: _selectedTabIndex,
                        builder: (context, value, child) {
                          return TabBar(
                              controller: _tabController,
                              isScrollable: true,
                              indicatorColor: Colors.transparent,
                              indicatorPadding: EdgeInsets.all(0),
                              labelPadding: EdgeInsets.all(0),
                              tabs: _tabs
                                  .asMap()
                                  .keys
                                  .map(
                                    (key) => Tab(
                                      child: Stack(
                                        children: <Widget>[
                                          Positioned(
                                              bottom: 9.w,
                                              child:
                                                  _selectedTabIndex.value == key
                                                      ? LocalPNG(
                                                          url:
                                                              'assets/images/tab-underline.png',
                                                          fit: BoxFit.fitHeight,
                                                          height: 9.w,
                                                        )
                                                      : Text(' ')),
                                          Container(
                                              width: 80.w,
                                              color: Colors.transparent,
                                              height: 50.w,
                                              alignment: Alignment.centerLeft,
                                              margin: EdgeInsets.only(left: 3),
                                              child: Text(_tabs[key]['title'],
                                                  style: value == key
                                                      ? TextStyle(
                                                          color: StyleTheme
                                                              .cTitleColor,
                                                          fontSize: 18.sp,
                                                          fontWeight:
                                                              FontWeight.w700)
                                                      : TextStyle(
                                                          color: StyleTheme
                                                              .cTitleColor,
                                                          fontSize: 14.sp))),
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList());
                        }),
                  ],
                ),
                padding: EdgeInsets.only(left: 0),
                color: Colors.transparent,
              ),
              preferredSize: Size(double.infinity, 50.w)),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Container(
          child: TabBarView(
            controller: _tabController,
            children: [
              PageViewMixin(
                child: OderFromPage(
                  userType: 0,
                ),
              ),
              PageViewMixin(
                child: OfficeFormPage(),
              ),
              PageViewMixin(
                child: IntentionFormPage(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
