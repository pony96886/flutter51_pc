import 'package:chaguaner2023/model/homedata.dart';
import 'package:flutter/foundation.dart';

class GetConfig {
  static String? imagePath;
}

class HomeConfig with ChangeNotifier, DiagnosticableTreeMixin {
  Map _data = {};
  VersionMsg? _versionMsg;
  Ads? _ads;
  Notice? _notice;
  Help? _help;
  BossChat? _bossChat;
  Config? _config;
  Member? _member;
  String? _cityCode;
  String _gameCoin = '0';
  String _rechargeTips = "";
  Map get data => _data;
  VersionMsg get versionMsg => _versionMsg!;
  Ads get ads => _ads!;
  Notice get notice => _notice!;
  Help get help => _help!;
  BossChat get bossChat => _bossChat!;
  Config get config => _config!;
  Member get member => _member!;
  String get cityCode => _cityCode!;
  String get gameCoin => _gameCoin;
  String get rechargeTips => _rechargeTips;

  int? addCoinInvition;
  int? addCoinSystemConfirmPass;
  int? addCoinSystemInfoPass;
  int? addCoinConfirmReal;

  void setConfig(Map newData) {
    try {
      _data.addAll(newData); // 如需覆盖某一个字段，newData = { member: {...} }即可
      _versionMsg = VersionMsg.fromJson(newData['versionMsg']);
      _ads = Ads.fromJson(newData['ads']);
      _rechargeTips = newData['recharge_tips'];
      _notice = newData['notice'] == null ? null : Notice.fromJson(newData['notice']);
      _help = Help.fromJson(newData['help'][0]);
      _bossChat = BossChat.fromJson(newData['boss_chat']);
      print(newData['config']);
      print('_____________');
      _config = Config.fromJson(newData['config']);
      GetConfig.imagePath = Config.fromJson(newData['config']).imgBase;
      _member = Member.fromJson(newData['member']);
      _cityCode = newData['cityCode'];
      notifyListeners();
    } catch (err) {}
  }

  void setGameCoin(dynamic coin) {
    _gameCoin = coin;
    notifyListeners();
  }

  void setPhone(dynamic phonenumber) {
    _member!.phone = phonenumber;
    notifyListeners();
  }

  void setNickname(String nickname) {
    _member!.nickname = nickname;
    notifyListeners();
  }

  void setLoginStatus(int value) {
    _member!.isLogin = value;
    notifyListeners();
  }

  void setCoins(dynamic value) {
    _member!.coins = value;
    notifyListeners();
  }

  void setMoney(dynamic value) {
    _member!.money = value;
    notifyListeners();
  }

  void setConsumeMoney(int value) {
    _member!.money = _member!.money - value;
    notifyListeners();
  }

  void setOriginalBloggerMoney(dynamic value) {
    _member!.originalBloggerMoney = value;
    notifyListeners();
  }

  void setVipLevel(dynamic value) {
    _member!.vipLevel = value;
    notifyListeners();
  }

  void setAgent(dynamic value) {
    _member!.agent = value;
    notifyListeners();
  }

  void setInvitation(dynamic invitation) {
    _member!.invitedBy = invitation;
    notifyListeners();
  }

  void setAvatar(dynamic type) {
    _member!.thumb = type;
    notifyListeners();
  }

  void setAwardConfig(dynamic obj) {
    addCoinInvition = obj.addCoinInvition;
    addCoinSystemConfirmPass = obj.addCoinSystemConfirmPass;
    addCoinSystemInfoPass = obj.addCoinSystemInfoPass;
    addCoinConfirmReal = obj.addCoinConfirmReal;
    notifyListeners();
  }
}
