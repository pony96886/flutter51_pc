import 'package:chaguaner2023/components/citypickers/modal/point.dart';
import 'package:lpinyin/lpinyin.dart';

import '../meta/province.dart';
import '../src/util.dart';

/// tree point

class InternationalCityTree {
  Map<String, String>? countrysInfo;
  Map<String, dynamic>? internationalInfo;
  Cache _cache = new Cache();

  Point? tree;

  /// @param metaInfo city and areas meta describe
  InternationalCityTree({this.countrysInfo, this.internationalInfo});

  Map<String, String> get _countrysData => this.countrysInfo ?? countryData;
  Map<String, dynamic> get _internationalInfo =>
      this.internationalInfo ?? internationalCitiesData;

  initTree(int provinceId) {
    String _cacheKey = provinceId.toString();
    String? name = this._countrysData[provinceId.toString()];
    String letter = PinyinHelper.getFirstWordPinyin(name!).substring(0, 1);
    var root =
        new Point(code: provinceId, letter: letter, child: [], name: name);
    tree = _buildTree(
        root, internationalInfo![provinceId.toString()], internationalInfo!);
    _cache.set(_cacheKey, tree);
    return tree;
  }

  int? _getProvinceByCode(int code) {
    String _code = code.toString();
    List<String> keys = internationalInfo!.keys.toList();
    for (int i = 0; i < keys.length; i++) {
      String key = keys[i];
      Map<String, dynamic> child = internationalInfo![key];
      if (child.containsKey(_code)) {
        // 当前元素的父key在省份内
        if (this._internationalInfo.containsKey(key)) {
          return int.parse(key);
        }
        return _getProvinceByCode(int.parse(key));
      }
    }
    return null;
  }

  /// build tree by any code provinceId or cityCode or areaCode
  /// @param code build a tree
  /// @return Point a province with its cities and areas tree
  Point initTreeByCode(int code) {
    String _code = code.toString();
    if (this._countrysData[_code] != null) {
      return initTree(code);
    }
    int? provinceId = _getProvinceByCode(code);
    return initTree(provinceId!);
    return Point().nullPoint;
//    return Point.nullPoint;
  }

  /// private function
  /// recursion to build tree
  Point _buildTree(Point target, Map citys, Map meta) {
    if (citys.isEmpty) {
      return target;
    } else {
      List keys = citys.keys.toList();

      for (int i = 0; i < keys.length; i++) {
        String key = keys[i];
        Map value = citys[key];
        Point _point = new Point(
          code: int.parse(key),
          letter: value['alpha'],
          child: [],
          name: value['name'],
        );

        // for avoid the data  error that such as
        //  "469027": {
        //        "469027": {
        //            "name": "乐东黎族自治县",
        //            "alpha": "l"
        //        }
        //    }
        if (citys.keys.length == 1) {
          if (target.code.toString() == citys.keys.first) {
            continue;
          }
        }

        _point = _buildTree(_point, meta[key], meta);
        target.addChild(_point);
      }
    }
    return target;
  }
}

/// Province Class
class Provinces {
  Map<String, String>? metaInfo;

  // 是否将省份排序, 进行排序
  bool? sort = true;
  Provinces({this.metaInfo, this.sort});

  Map<String, dynamic> get _metaInfo => this.metaInfo ?? countryData;

  // 获取省份数据
  get provinces {
    List<Point> provList = [];
    List<String> keys = this._metaInfo.keys.toList();
    for (int i = 0; i < keys.length; i++) {
      String name = this._metaInfo[keys[i]];
      provList.add(Point(
          code: int.parse(keys[i]),
          letter: PinyinHelper.getFirstWordPinyin(name).substring(0, 1),
          name: name));
    }
    if (this.sort == true) {
      provList.sort((Point a, Point b) {
        return a.letter!.compareTo(b.letter!);
      });
    }

    return provList;
  }
}
//main() {
//  var tree = new CityTree();
//  tree.initTree(460000);
//  print("treePo>>> ${tree.tree.toString()}");
//}
//

//main() {
//  var p = new Provinces(
////    metaInfo: provincesData
//  );
//  print("p.provinces ${p.provinces}");
//}
