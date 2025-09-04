import 'package:chaguaner2023/model/signuplist.dart';
import 'package:flutter/foundation.dart';

class SignInConfig with ChangeNotifier, DiagnosticableTreeMixin {
  RewardInfo? _rewardInfo;
  Data? _data;
  bool? _show = true;
  bool? _showActivity = true;
  int? _isSign;
  int? _days;

  Data get datas => _data!;
  RewardInfo get rewardInfo => _rewardInfo!;
  bool get show => _show!;
  bool get showActivity => _showActivity!;
  int get isSign => _isSign!;
  int? get days => _days;

  void setData(Map<String, dynamic> list) {
    _data = Data.fromJson(list);
    _rewardInfo = RewardInfo.fromJson(list['rewardInfo'][0]);
    _days = Data.fromJson(list).days;
    _isSign = Data.fromJson(list).isSign;
    notifyListeners();
  }

  void setShow(bool value) {
    _show = value;
    notifyListeners();
  }

  void setDays(int value) {
    _days = value;
    _isSign = 1;
    notifyListeners();
  }

  void setSign(int value) {
    _isSign = value;
    notifyListeners();
  }

  void setActivity(bool value) {
    _showActivity = value;
    notifyListeners();
  }
}
