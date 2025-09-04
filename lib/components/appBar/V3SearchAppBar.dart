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
class V3SearchAppBarWidget extends StatefulWidget {
  final VoidCallback? tapSearch, tapFilter, tapTitle; //点击输入框函数
  final bool? isHidden;
  final Function? callBack;
  late V3SearchAppBarState _state;

  V3SearchAppBarWidget(
      {this.tapSearch,
      this.callBack,
      this.tapFilter,
      this.tapTitle,
      this.isHidden}) {
    _state = V3SearchAppBarState(
      tapSearch: tapSearch!,
      tapFilter: tapFilter!,
      isHidden: isHidden!,
      tapTitle: tapTitle!,
    );
  }

  @override
  V3SearchAppBarState createState() => _state;
}

class V3SearchAppBarState extends State<V3SearchAppBarWidget>
    with TickerProviderStateMixin {
  final VoidCallback? tapSearch, tapFilter, tapTitle; //输入框点击回调函数 取消点击回调函数
  final bool? isHidden;
  // 设置防抖周期为3s

  late String code;

  V3SearchAppBarState({
    this.tapSearch,
    this.tapFilter,
    this.isHidden,
    this.tapTitle,
  });
  late String cityName;

  initState() {
    super.initState();
  }

  _initCity(String cityCode, String cityNames) {
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
      var setAreaResult = await setArea(result.code);
      if (setAreaResult!['status'] == 1) {
        widget.callBack!(result.code);
        print(result.code);
        print(result.city);
        Provider.of<GlobalState>(context, listen: false)
            .setCityCode(result.code.toString());
        Provider.of<GlobalState>(context, listen: false)
            .setCityName(result.city);
        BotToast.showText(
            text: '切换城市成功，如信息和城市不匹配请[下拉刷新]',
            align: Alignment(0, 0),
            duration: Duration(seconds: 3));
        BotToast.closeAllLoading();
      }
    } else {
      BotToast.closeAllLoading();
    }
  }

  dispose() {
    //路由销毁释放动画资源
    BotToast.closeAllLoading();
    super.dispose();
  }

  Widget build(BuildContext context) {
    String? cityCode = Provider.of<GlobalState>(context).cityCode;
    String cityNamea = Provider.of<GlobalState>(context).cityName;
    _initCity(cityCode!, cityNamea);
    return Padding(
      padding: EdgeInsets.only(left: 15.w, right: 15.w, top: 10.w),
      child: Stack(
        children: [
          Center(
            child: GestureDetector(
              onTap: tapTitle,
              child: LocalPNG(
                url: 'assets/images/home/chaguaner.png',
                width: 100.w,
                height: 34.5.w,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  _showCityPickers(context);
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    LocalPNG(
                      url: 'assets/images/home/icon-location.png',
                      height: 20.w,
                      width: 20.w,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 3.w),
                      child: Text(
                        cityName ?? '选择城市',
                        maxLines: 1,
                        style: TextStyle(
                            fontSize: 15.w, color: StyleTheme.cTitleColor),
                      ),
                    ),
                  ],
                ),
              ),
              widget.isHidden!
                  ? Container(width: 25.w)
                  : GestureDetector(
                      onTap: tapFilter,
                      child: LocalPNG(
                        url: "assets/images/home/shaixuan.png",
                        width: 25.w,
                        height: 25.w,
                      ),
                    ),
              GestureDetector(
                onTap: tapSearch,
                child: Padding(
                  padding: EdgeInsets.only(left: 15.w),
                  child: LocalPNG(
                    url: "assets/images/home/searchicon.png",
                    width: 25.w,
                    height: 25.w,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
