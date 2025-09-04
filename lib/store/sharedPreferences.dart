// 持久化状态存储
import 'package:shared_preferences/shared_preferences.dart';

class PersistentState {
  static saveState(String key, dynamic value, {String? type}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

  static saveStateInt(String key, dynamic value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(key, value);
  }

  static removeState(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
  }

  static Future<dynamic> getState(String key) async {
    var _key;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _key = prefs.getString(key);
    return _key;
  }

  static Future<dynamic> getStateInt(String key) async {
    var _key;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _key = prefs.getInt(key);
    return _key;
  }
}
