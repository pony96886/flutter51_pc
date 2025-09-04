import 'package:bot_toast/bot_toast.dart';
import 'package:chaguaner2023/components/citypickers/CommonCity_pickers.dart';
import 'package:chaguaner2023/store/global.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class V3ElegentAppBarWidget extends StatefulWidget {
  final VoidCallback? tapFilter;
  final VoidCallback? tapTitle;
  final Function? callBack;
  final List? cityList;
  late V3ElegentAppBarState _state;

  V3ElegentAppBarWidget({
    this.callBack,
    this.tapFilter,
    this.cityList,
    this.tapTitle,
  }) {
    _state = V3ElegentAppBarState(
        tapFilter: tapFilter!, cityList: cityList!, tapTitle: tapTitle!);
  }

  @override
  V3ElegentAppBarState createState() => _state;
}

class V3ElegentAppBarState extends State<V3ElegentAppBarWidget>
    with TickerProviderStateMixin {
  final VoidCallback? tapFilter; //输入框点击回调函数 取消点击回调函数
  final VoidCallback? tapTitle;
  final List? cityList;
  // 设置防抖周期为3s

  late Animation<double> animation;

  late String code;

  V3ElegentAppBarState({this.tapFilter, this.cityList, this.tapTitle});
  late String cityName;

  @override
  void initState() {
    super.initState();
  }

  initCityName(String cityCode, String cityNames) {
    setState(() {
      cityName = cityNames;
    });
  }

  _showCityPickers(BuildContext context) async {
    final dynamic result = await Navigator.push(context,
        new MaterialPageRoute(builder: (context) => CommonCityPickers()));
    BotToast.showLoading();
    if (result != null) {
      setState(() {
        cityName = result.city;
      });
      Map? setAreaResult = await setArea(result.code);
      if (setAreaResult!['status'] == 1) {
        Provider.of<GlobalState>(context, listen: false)
            .setCityCode(result.code.toString());
        Provider.of<GlobalState>(context, listen: false)
            .setCityName(result.city);
        BotToast.showText(
            text: '切换城市成功，如信息和城市不匹配请[下拉刷新]',
            align: Alignment(0, 0),
            duration: Duration(seconds: 3));
        widget.callBack!({'code': result.code, 'city': result.city});
        BotToast.closeAllLoading();
      }
    } else {
      BotToast.closeAllLoading();
    }
  }

  dispose() {
    super.dispose();
  }

  Widget build(BuildContext context) {
    String? cityCode = Provider.of<GlobalState>(context).cityCode;
    String cityNamea = Provider.of<GlobalState>(context).cityName;
    initCityName(cityCode!, cityNamea);
    return Padding(
      padding: EdgeInsets.only(
          bottom: 10.w,
          top: ScreenUtil().statusBarHeight + 10.w,
          left: 15.w,
          right: 15.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              _showCityPickers(context);
            },
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  LocalPNG(
                      url: 'assets/images/home/icon-location.png',
                      height: 20.w,
                      width: 20.w),
                  Padding(
                    padding: EdgeInsets.only(left: 3.w),
                    child: Text(
                      cityName ?? '选择城市',
                      maxLines: 1,
                      style: TextStyle(
                          fontSize: 15.sp, color: StyleTheme.cTitleColor),
                    ),
                  ),
                ]),
          ),
          Expanded(
              child: Padding(
                  child: GestureDetector(
                    onTap: tapTitle,
                    child: LocalPNG(
                      url: 'assets/images/home/yajian.png',
                      width: 108.w,
                      height: 30.w,
                      fit: BoxFit.contain,
                    ),
                  ),
                  padding: EdgeInsets.only(left: 15.w, right: 15.w)),
              flex: 1),
          GestureDetector(
            onTap: tapFilter,
            child: Container(
              padding: EdgeInsets.only(left: 30.w),
              child: LocalPNG(
                url: "assets/images/home/shaixuan.png",
                width: 25.w,
                height: 25.w,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
