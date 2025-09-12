import 'package:chaguaner2023/utils/cache/cache.dart';
import 'package:chaguaner2023/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

class CacheManager {
  CacheManager._internal();
  factory CacheManager() => instance;
  static final CacheManager instance = CacheManager._internal();

  static ImageCacheManager get image => ImageCacheManager.instance;

  bool _isInitialized = false;
  late final ICache _appBox;

  Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;
    // 初始化数据库，必须放在最前面
    await ImageCacheManager.instance.init(_imageKey, salt: _imageSalt); //图片缓存
    _appBox = HiveBoxCache(await Hive.openLazyBox(_boxKey)); // 用于存储一些简单的键值对
  }

  String get _imageKey => 'snsdsbox_ImageCache';
  String get _imageSalt => 'MxqtSeXnRz';
  String get _boxKey => "snsdsbox";
  String get _tokenKey => "snsds_token";
  String get _lineKey => "lines_url";
  String get _gitKey => "github_url";
  String get _officeKey => "office_web";
  String get _adsmapKey => "adsmap";
  String get _authorKey => "oauth_id";
  String get _recordKey => "search_record";
  String get _elesKey => "select_eles";
  String get _idKey => "select_id";
  String get _ruleKey => "readrule";
  String get _sortKey => "sort_rank";
  String get _adKey => "home_ad";
  String get _fdsKey => "fds_v";
  String get _defaultKey => "viiDw6axfsvec0nDfNjXow9nRSZkd+RDCsAcrJ7n+2lOrwchr6QKAmsVlmAxaGbU";

  late GoRouter appRouter;
  late Map<String, dynamic> appinfo = {};
  late String apiBaseURL = "";
  late String uploadImgUrl = "";
  late String uploadImgKey = "";
  late String imgBaseUrl = "";
  late String uploadMp4Url = "";
  late String uploadMp4Key = "";
  late Map mediaMap = {};
  late String m3u8_encrypt = "0";
  late BuildContext context;

  final List<String> _tempLines = kIsWeb
      ? [
          'https://api3.xnxfmjg.com/api.php',
        ]
      : [
          'https://api1.xnxfmjg.com/api.php',
          'https://api2.xnxfmjg.com/api.php',
        ];
  final String _tempGitLine = "https://raw.githubusercontent.com/ailiu258099-blip/master/main/mrdssns.txt";
  final String _tempId = '${Utils.randomId(16)}_${DateTime.now().millisecondsSinceEpoch.toString()}';

  Future<List<String>> getLines() async {
    final data = await _appBox.read(_lineKey);
    if (data != null) {
      return List<String>.from(data);
    }
    return _tempLines;
  }

  Future<void> setLines(List<String>? v) async => await _appBox.upsert(_lineKey, v);

  Future<String> getToken() async => ((await _appBox.read(_tokenKey)) ?? "").toString();
  Future<void> setToken(String? v) async => await _appBox.upsert(_tokenKey, v ?? "");
  Future<void> clearToken() async => await _appBox.delete(_tokenKey);

  Future<String> getGitLine() async => ((await _appBox.read(_gitKey)) ?? _tempGitLine).toString();
  Future<void> setGitLine(String? v) async => await _appBox.upsert(_gitKey, v ?? "");

  Future<String> getOffice() async => ((await _appBox.read(_officeKey)) ?? "").toString();
  Future<void> setOffice(String? v) async => await _appBox.upsert(_officeKey, v ?? "");

  Future<Map<dynamic, dynamic>> getAds() async {
    final data = await _appBox.read(_adsmapKey);
    if (data != null) {
      return Map.from(data);
    }
    return {};
  }

  Future<void> setAds(Map<dynamic, dynamic>? v) async => await _appBox.upsert(_adsmapKey, v);
  Future<void> clearAds() async => await _appBox.delete(_adsmapKey);

  Future<Uint8List?> getHomeAd() async => await _appBox.read(_adKey);
  Future<void> setHomeAd(Uint8List? v) async => await _appBox.upsert(_adKey, v);
  Future<void> clearHomeAd() async => await _appBox.delete(_adKey);

  Future<String> getAuthorId() async => ((await _appBox.read(_authorKey)) ?? _tempId).toString();
  Future<void> setAuthorId(String? v) async => await _appBox.upsert(_authorKey, v ?? "");

  Future<List<dynamic>> getHistory() async {
    final data = await _appBox.read(_recordKey);
    if (data != null) {
      return List.from(data);
    }
    return [];
  }

  Future<void> setHistory(List<dynamic>? v) async => await _appBox.upsert(_recordKey, v);

  Future<void> clearHistory() async => await _appBox.delete(_recordKey);

  Future<List<int>> getEles() async {
    final data = await _appBox.read(_elesKey);
    if (data != null) {
      return List.from(data);
    }
    return [];
  }

  Future<void> setEles(List<int>? v) async => await _appBox.upsert(_elesKey, v);
  Future<void> clearEles() async => await _appBox.delete(_elesKey);

  Future<int> getId() async => (await _appBox.read(_idKey)) ?? 0;
  Future<void> setId(int? v) async => await _appBox.upsert(_idKey, v ?? 0);

  Future<int> getRule() async => (await _appBox.read(_ruleKey)) ?? 0;
  Future<void> setRule(int? v) async => await _appBox.upsert(_ruleKey, v ?? 0);

  Future<int> getSort() async => (await _appBox.read(_sortKey)) ?? 0;
  Future<void> setSort(int? v) async => await _appBox.upsert(_sortKey, v ?? 0);
  Future<void> clearSort() async => await _appBox.delete(_sortKey);

  //保存fds
  Future<String> getFds() async => (await _appBox.read(_fdsKey)) ?? _defaultKey;

  Future<void> setFds(String? v) async => await _appBox.upsert(_fdsKey, v ?? "");
  Future<void> clearFds() async => await _appBox.delete(_fdsKey);
}
