import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:chaguaner2023/components/citypickers/city_pickers.dart';
import 'package:chaguaner2023/store/global.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class SearchAppBar extends AppBar {
  final TextEditingController? inputController;
  final VoidCallback? tapSearch;
  final VoidCallback? tapCancel;
  final bool? enabled;
  final Function? callBack;
  SearchAppBar({
    Key? key,
    this.inputController,
    this.tapSearch,
    this.tapCancel,
    this.callBack,
    this.enabled,
  }) : super(
          elevation: 0, //下阴影
          title: SearchAppBarWidget(
            inputController: inputController,
            tapSearch: tapSearch,
            tapCancel: tapCancel,
            callBack: callBack,
            enabled: enabled,
          ),
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        );
}

// ignore: must_be_immutable
class SearchAppBarWidget extends StatefulWidget {
  final TextEditingController? inputController;
  final VoidCallback? tapSearch, tapCancel; //点击输入框函数
  final Function? callBack;
  final bool? enabled;
  late SearchAppBarState _state;

  SearchAppBarWidget(
      {this.inputController,
      this.tapSearch,
      this.callBack,
      this.tapCancel,
      this.enabled}) {
    _state = SearchAppBarState(
        inputController: inputController!,
        tapSearch: tapSearch!,
        tapCancel: tapCancel!,
        enabled: enabled!);
  }

  @override
  SearchAppBarState createState() => _state;
}

class SearchAppBarState extends State<SearchAppBarWidget>
    with TickerProviderStateMixin {
  final TextEditingController? inputController;
  final VoidCallback? tapSearch, tapCancel; //输入框点击回调函数 取消点击回调函数
  final bool enabled;
  // 设置防抖周期为3s
  Duration durationTime = Duration(seconds: 3);

  late Timer timer;

  bool _showClear = false;

  late Animation<double> animation;
  late AnimationController aniController;

  late String code;

  SearchAppBarState(
      {this.inputController,
      this.tapSearch,
      this.tapCancel,
      this.enabled = true});
  late String cityName;

  initState() {
    super.initState();
    aniController = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);
    animation = CurvedAnimation(parent: aniController, curve: Curves.easeIn);
    animation = Tween(begin: 0.15, end: 0.0).animate(animation)
      ..addListener(() {
        setState(() {
          if (aniController.status == AnimationStatus.dismissed) {}
        });
      });
  }

  _initCity(String cityCode) {
    CityPickerUtil cityPickerUtils = CityPickers.utils();
    Result result = new Result();
    result = cityPickerUtils.getAllAreaResultByCode(cityCode);
    setState(() {
      cityName = result.cityName!;
    });
  }

  _showCityPickers() async {
    Result? result2 = await CityPickers.showCitiesSelector(
      context: context,
    );
    BotToast.showLoading();
    if (result2 != null) {
      var areaCode = int.parse(result2.cityId!);
      var result = await setArea(areaCode);
      if (result!['status'] == 1) {
        widget.callBack!();
        Provider.of<GlobalState>(context, listen: false)
            .setCityCode(areaCode.toString());
        BotToast.showText(text: '设置城市成功', align: Alignment(0, 0));
        BotToast.closeAllLoading();
      } else {
        BotToast.showText(text: '设置城市失败', align: Alignment(0, 0));
        BotToast.closeAllLoading();
      }
    } else {
      BotToast.closeAllLoading();
    }
  }

  _search() {}

  dispose() {
    //路由销毁释放动画资源
    aniController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    String? cityCode = Provider.of<GlobalState>(context).cityCode;
    _initCity(cityCode!);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        GestureDetector(
          onTap: _showCityPickers,
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                LocalPNG(
                  url: 'assets/images/home/icon-location.png',
                  height: 20.w,
                  width: 20.w,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 3.w),
                  child: Text(cityName ?? '选择城市',
                      style: TextStyle(fontSize: 15.sp)),
                ),
              ]),
        ),
        Expanded(
            child: Padding(
                child: SizedBox(
                    height: 30.w,
                    child: Theme(
                      data: Theme.of(context).copyWith(
                          primaryColor: Colors.grey, hintColor: Colors.white),
                      child: widget.enabled!
                          ? TextField(
                              controller: inputController,
                              enabled: widget.enabled,
                              onChanged: (e) {
                                if (e != "" && !_showClear) {
                                  setState(() {
                                    _showClear = true;
                                    timer.cancel();
                                    timer = new Timer(durationTime, () {
                                      _search();
                                    });
                                  });
                                } else if (e == "" && _showClear) {
                                  setState(() {
                                    _showClear = false;
                                  });
                                }
                              },
                              onTap: () {
                                tapSearch!();
                                setState(() {});
                                // 启动动画(正向执行)

                                aniController.forward();
                              },
                              decoration: InputDecoration(
                                  hintText: '输入关键词搜索',
                                  hintStyle:
                                      TextStyle(color: StyleTheme.cBioColor),
                                  contentPadding: EdgeInsets.zero,
                                  fillColor: StyleTheme.textbgColor1,
                                  filled: true,
                                  //右侧清除按钮
                                  suffixIcon: _showClear == false
                                      ? SizedBox()
                                      : GestureDetector(
                                          behavior: HitTestBehavior.translucent,
                                          onTap: () {
                                            FocusScope.of(context)
                                                .requestFocus(FocusNode());
                                            setState(() {
                                              _showClear = false;
                                            });
                                            inputController!.clear();
                                          },
                                          child: Icon(Icons.close),
                                        ),
                                  //搜索图标
                                  prefixIcon: Padding(
                                    child: LocalPNG(
                                      width: 20.w,
                                      height: 20.w,
                                      url: 'assets/images/home/icon-search.png',
                                    ),
                                    padding: EdgeInsets.only(
                                        left: 10.w, right: 10.w),
                                  ),
                                  prefixIconConstraints: BoxConstraints(
                                    maxHeight: 35.w,
                                    maxWidth: 35.w,
                                  ),
                                  disabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                      borderSide: BorderSide(
                                          color: Colors.white, width: 0)),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                      borderSide: BorderSide(
                                          color: Colors.white, width: 0)),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                      borderSide: BorderSide(
                                          color: Colors.white, width: 0))),
                              style: TextStyle(
                                fontSize: 15.sp,
                              ),
                            )
                          : GestureDetector(
                              onTap: () {
                                tapSearch!();
                              },
                              child: Container(
                                height: 30.w,
                                decoration: BoxDecoration(
                                  color: Color(0xFFEEEEEE),
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                child: Row(
                                  children: <Widget>[
                                    Padding(
                                      child: LocalPNG(
                                          width: 15.w,
                                          height: 15.w,
                                          url:
                                              'assets/images/home/icon-search.png',
                                          alignment: Alignment.center),
                                      padding: EdgeInsets.only(
                                          left: 10.w, right: 10.w),
                                    ),
                                    Expanded(
                                        child: Text(
                                      '输入关键词搜索',
                                      style: TextStyle(
                                          color: StyleTheme.cBioColor,
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.normal),
                                    ))
                                  ],
                                ),
                              ),
                            ),
                    )),
                padding: EdgeInsets.only(left: 15.w, right: 15.w)),
            flex: 1),
      ],
    );
  }
}
