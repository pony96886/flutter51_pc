import 'package:chaguaner2023/components/card/reportCard.dart';
import 'package:chaguaner2023/components/citypickers/modal/result.dart';
import 'package:chaguaner2023/components/citypickers/src/city_picker.dart';
import 'package:chaguaner2023/components/citypickers/src/utils/index.dart';
import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/loading.dart';
import 'package:chaguaner2023/components/networkErr.dart';
import 'package:chaguaner2023/components/nodata.dart';
import 'package:chaguaner2023/components/page_title_bar.dart';
import 'package:chaguaner2023/store/global.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class ReportPage extends StatefulWidget {
  ReportPage({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => ReportState();
}

class ReportState extends State<ReportPage> {
  List reportList = [];
  bool loading = true;
  bool networkErr = false;
  String? cityName;
  bool isEditCity = false; //是否切换了城市
  int? reportState;
  // 加载数据需要参数
  int page = 1; //页数
  bool isAll = false; //数据是否已加载完
  bool isLoading = true;
  int limit = 10;
  ScrollController scrollController = ScrollController();
  getConfirmList() async {
    setState(() {
      networkErr = false;
    });
    var confirmList = await reportConfirmList(page, limit, null);
    if (page == 1) {
      if (confirmList != null && confirmList['status'] != 0) {
        setState(() {
          reportState = confirmList['status'];
          reportList = confirmList['data'];
          loading = false;
        });
      } else {
        setState(() {
          networkErr = true;
        });
        return;
      }
      if (confirmList['data'].length < limit) {
        setState(() {
          isAll = true;
          isLoading = false;
        });
      }
    } else {
      if (confirmList['status'] != 0 && confirmList['data'].length > 0) {
        setState(() {
          reportList.addAll(confirmList['data']);
        });
      } else {
        setState(() {
          isLoading = false;
          isAll = true;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        if (!isAll) {
          setState(() {
            page++;
            isLoading = true;
          });
          getConfirmList();
        }
      }
    });
    getConfirmList();
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  _initCity(String cityCode) {
    CityPickerUtil cityPickerUtils = CityPickers.utils();
    Result result = new Result();
    result = cityPickerUtils.getAllAreaResultByCode(cityCode);
    setState(() {
      cityName = result.cityName;
      isEditCity = true;
    });
  }

  // ignore: unused_element
  _showCityPickers() async {
    Result? result2 = await CityPickers.showCitiesSelector(
      context: context,
    );
    setState(() {
      cityName = result2!.cityName;
    });
    var areaCode = int.parse(result2!.cityId!);
    Provider.of<GlobalState>(context, listen: false).setCityCode(areaCode.toString());
    var result = setArea(areaCode).then((value) => {
          setState(() {
            reportList = [];
            page = 1;
            loading = true;
          }),
          getConfirmList()
        });
  }

  @override
  Widget build(BuildContext context) {
    String? cityCode = Provider.of<GlobalState>(context).cityCode;
    _initCity(cityCode!);
    return HeaderContainer(
      child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: PreferredSize(
              child: PageTitleBar(
                title: '验茶报告',
              ),
              preferredSize: Size(double.infinity, 44.w)),
          body: networkErr
              ? NetworkErr(
                  errorRetry: () {
                    getConfirmList();
                  },
                )
              : (loading
                  ? Loading()
                  : (reportList.length == 0
                      ? NoData(
                          text: '还有没验茶报告哦～',
                        )
                      : ListView.separated(
                          padding: EdgeInsets.only(top: 5.w, bottom: ScreenUtil().bottomBarHeight + 20.w),
                          controller: scrollController,
                          itemCount: reportList.length,
                          physics: const ClampingScrollPhysics(),

                          ///新增坑位留给更多布局
                          separatorBuilder: (BuildContext context, int index) => Divider(
                                color: Colors.transparent,
                                height: 15.w,
                              ),
                          itemBuilder: (BuildContext context, int index) {
                            return Column(
                              children: [
                                index == 0
                                    ? GestureDetector(
                                        onTap: () {
                                          AppGlobal.appRouter?.push(CommonUtils.getRealHash('teaAppreciator'));
                                        },
                                        behavior: HitTestBehavior.translucent,
                                        child: Container(
                                          margin: EdgeInsets.only(bottom: 10.w),
                                          width: double.infinity,
                                          height: 120.w,
                                          child: LocalPNG(
                                              width: double.infinity,
                                              height: 120.w,
                                              url: 'assets/images/card/jianchabanner.png',
                                              fit: BoxFit.fill),
                                        ),
                                      )
                                    : Container(),
                                Container(
                                  margin: new EdgeInsets.only(bottom: 20.w),
                                  child: ReportCard(key: Key('zhaopiao_card_$index'), reportInfo: reportList[index]),
                                ),
                                index == reportList.length - 1 ? renderMore() : Container()
                              ],
                            );
                          })))),
    );
  }

  String loadData = '数据加载中...';
  String noData = '没有更多数据';
  Widget renderMore() {
    return Padding(
      padding: EdgeInsets.only(top: 15.w, bottom: 15.w),
      child: Center(
        child: Text(
          isLoading ? loadData : noData,
          style: TextStyle(color: StyleTheme.cBioColor),
        ),
      ),
    );
  }
}
