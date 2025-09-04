//
// target: 开放给city_pickers直接调用的工具方法
//
import 'package:chaguaner2023/components/citypickers/meta/province.dart';
import 'package:chaguaner2023/components/citypickers/modal/result.dart';
import 'package:chaguaner2023/components/citypickers/src/utils/international.dart';

import 'location.dart';

class CityPickerUtil {
  Map<String, dynamic>? citiesData;
  Map<String, String>? provincesData;
  Map<String, dynamic>? hotCitiesData;
  Map<String, dynamic>? internationalData;

  CityPickerUtil(
      {this.citiesData,
      this.provincesData,
      this.hotCitiesData,
      this.internationalData});

  Result getAllAreaResultByCode(String code) {
    if (code.length >= 10) {
      return getAreaResultByInternationalCode(code);
    } else {
      return getAreaResultByCode(code);
    }
  }

  Result getAreaResultByCode(String code) {
    Location location = new Location(
        citiesData: citiesData!,
        provincesData: provincesData!,
        hotCitiesData: hotCitiesData!);
    return location.initLocation(code);
  }

  Result getAreaResultByInternationalCode(String code) {
    International internationalValue = new International(
        provincesData: countryData, citiesData: internationalData!);
    return internationalValue.initLocationInternational(code);
  }
}
