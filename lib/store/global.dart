import 'package:flutter/foundation.dart';

class UserInfo {
  static int? agent;
  static int? vipLevel;
  static String? jcsUrl; //鉴茶师介绍
  static String? fpznUrl; //防骗指南
  static String? wxykUrl; //无限月卡
  static String? officialUuid;
  static String? officialName;
  static String? serviceUuid;
  static String? shenheUuid;
  static String? mobileUrl;
  static List? kefuList;
  static String? gameIconUrl;
  static String? imageCode; //图形验证码
  static String? datingCS; // 大厅客服
  static String? yuyueCS; // 预约单客服
  static String? manageUuid; //茶管理UUID
  static int? isMerchant;
}

class GlobalState with ChangeNotifier, DiagnosticableTreeMixin {
  int _msgLength = 0; //首页消息条数
  Map? _profiledata;
  String? _cityCode;
  String? _cityName;
  dynamic _freezeMoney = 0;
  dynamic _msgList; //系统消息列表
  dynamic _oltime = 0;
  dynamic _reservationInfo;
  List? _infotype;
  Map? _cityList;

  String? get cityCode => _cityCode!;
  String get cityName => _cityName!;
  int get msgLength => _msgLength;
  dynamic get msgList => _msgList;
  Map? get profileData => _profiledata!;
  dynamic get freezeMoney => _freezeMoney;
  dynamic get reservationInfo => _reservationInfo;
  List get infotype => _infotype!;
  dynamic get oltime => _oltime;
  Map get cityList => _cityList!;

  void setMsgLength(int value) {
    _msgLength = value;
    notifyListeners();
  }

  void setOltime(int value) {
    _oltime = value;
    notifyListeners();
  }

  void setMsgList(dynamic value) {
    _msgList = value;
    notifyListeners();
  }

  void setProfile(Map profile) {
    _profiledata = profile;
    UserInfo.agent = _profiledata!['agent'];
    UserInfo.vipLevel = _profiledata == null ? 0 : _profiledata!['vip_level'];
    notifyListeners();
  }

  void setCityCode(dynamic code) {
    _cityCode = code.toString();
    notifyListeners();
  }

  void setCityName(dynamic name) {
    _cityName = name;
    notifyListeners();
  }

  void setFreezeMoney(dynamic value) {
    _freezeMoney = value;
    notifyListeners();
  }

  void setReservationInfo(dynamic value) {
    _reservationInfo = value;
    notifyListeners();
  }

  void setInfoType(dynamic value) {
    _infotype = value;
    notifyListeners();
  }

  void setCityList(dynamic value) {
    _cityList = value;
    notifyListeners();
  }
}
