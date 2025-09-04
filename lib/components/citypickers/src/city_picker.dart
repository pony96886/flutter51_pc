import 'dart:async';
import 'package:chaguaner2023/components/citypickers/src/cities_selector/cities_selector.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../city_pickers.dart';
import '../meta/province.dart' as meta;
// import './util.dart';
// import './mod/picker_popup_route.dart';
// import './show_types.dart';

/// ios city pickers
/// provide config height, initLocation and so on
///
/// Sample:flutter format
/// ```
/// await CityPicker.showPicker(
///   location: String,
///   height: double
/// );
///
/// ```

class CityPickers {
  /// static original city data for this plugin
  static Map<String, dynamic> metaCities = meta.citiesData;

  /// static original province data for this plugin
  static Map<String, String> metaProvinces = meta.provincesData;

  static Map<String, dynamic> metaHotCities = meta.hotCitiesData;

  static Map<String, dynamic> metaInternationalCities =
      meta.internationalCitiesData;

  static utils(
      {Map<String, String>? provinceData,
      Map<String, dynamic>? citiesData,
      Map<String, dynamic>? hotCitieData,
      Map<String, dynamic>? internationalData}) {
    // print("CityPickers.metaProvinces::: ${CityPickers.metaCities}");
    return CityPickerUtil(
        provincesData: provinceData ?? CityPickers.metaProvinces,
        citiesData: citiesData ?? CityPickers.metaCities,
        hotCitiesData: hotCitieData ?? CityPickers.metaHotCities,
        internationalData:
            internationalData ?? CityPickers.metaInternationalCities);
  }

  static Future<Result?> showCitiesSelector({
    @required BuildContext? context,
    ThemeData? theme,
    bool? showAlpha,
    String? locationCode,
    Map<String, dynamic>? citiesData,
    Map<String, dynamic>? provincesData,
    Map<String, dynamic>? hotCitiesData,
    BaseStyle? sideBarStyle,
    BaseStyle? cityItemStyle,
    BaseStyle? topStickStyle,
  }) {
    BaseStyle _sideBarStyle = BaseStyle(
        fontSize: 14,
        color: defaultTagFontColor,
        activeColor: defaultTagActiveBgColor,
        backgroundColor: defaultTagBgColor,
        backgroundActiveColor: defaultTagActiveBgColor);
    _sideBarStyle = _sideBarStyle.merge(sideBarStyle);

    BaseStyle _cityItemStyle = BaseStyle(
      fontSize: 15.sp,
      color: StyleTheme.cTitleColor,
      activeColor: Colors.red,
    );
    _cityItemStyle = _cityItemStyle.merge(cityItemStyle);

    BaseStyle _topStickStyle = BaseStyle(
        fontSize: 16,
        height: 40,
        color: defaultTopIndexFontColor,
        backgroundColor: defaultTopIndexBgColor);

    _topStickStyle = _topStickStyle.merge(topStickStyle);

    return Navigator.push(
        context!,
        new PageRouteBuilder(
          settings: RouteSettings(name: 'CitiesPicker'),
          transitionDuration: const Duration(milliseconds: 250),
          pageBuilder: (context, _, __) => new Theme(
              data: ThemeData(primaryColor: Colors.white),
              child: CitiesSelector(
                  provincesData: provincesData ?? meta.provincesData,
                  citiesData: citiesData ?? meta.citiesData,
                  hotcitiesData: hotCitiesData ?? meta.hotCitiesData,
                  locationCode: locationCode,
                  tagBarActiveColor: _sideBarStyle.backgroundActiveColor!,
                  tagBarFontActiveColor: _sideBarStyle.activeColor!,
                  tagBarBgColor: _sideBarStyle.backgroundColor!,
                  tagBarFontColor: _sideBarStyle.color!,
                  tagBarFontSize: _sideBarStyle.fontSize!,
                  topIndexFontSize: _topStickStyle.fontSize!,
                  topIndexHeight: _topStickStyle.height!,
                  topIndexFontColor: _topStickStyle.color!,
                  topIndexBgColor: _topStickStyle.backgroundColor!,
                  itemFontColor: _cityItemStyle.color,
                  cityItemFontSize: _cityItemStyle.fontSize!,
                  itemSelectFontColor: _cityItemStyle.activeColor)),
          transitionsBuilder:
              (_, Animation<double> animation, __, Widget child) =>
                  new SlideTransition(
                      position: new Tween<Offset>(
                        begin: Offset(0.0, 1.0),
                        end: Offset(0.0, 0.0),
                      ).animate(animation),
                      child: child),
        ));
  }
}
