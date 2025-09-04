import 'dart:convert';
import 'dart:typed_data';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:hex/hex.dart';

final imKey = Key.fromUtf8("Ksl5I9PXK63EdiJh");
final imIv = IV.fromUtf8("fyMqKuq1a4n0PJwf");
final key = Key.fromUtf8("NQYT3eSsXG52WPDS");
final iv = IV.fromUtf8("KIxEQJNeXG715zkh");
final appkey = "NaojbMJVDK1V82QG49dt6tiXQxAsZTQF";

final mediaKey = Key.fromUtf8("f5d965df75336270");
final mediaIv = IV.fromUtf8("97b60394abc2fbe1");

class EncDecrypt {
  //签名
  static String getSign(Map obj) {
    String md5Text;
    List keyValues = [];
    keyValues.add("client=" + obj['client'].toString());
    keyValues.add("data=" + obj['data'].toString());
    keyValues.add("timestamp=" + obj['timestamp'].toString());
    String text = keyValues.join('&') + appkey;
    Digest _digest = sha256.convert(utf8.encode(text));
    md5Text = md5.convert(utf8.encode(_digest.toString())).toString();
    return md5Text;
  }

  // md5 加密
  static String toMd5(String data) {
    var content = new Utf8Encoder().convert(data);
    var digest = md5.convert(content);
    return HEX.encode(digest.bytes);
  }

  static Future<dynamic> encryptReqParams(String word, {isIm = false}) async {
    Encrypter encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    Encrypted encrypted = encrypter.encryptBytes(utf8.encode(word), iv: iv);
    String data = utf8.decode(encrypted.base64.codeUnits);
    int timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    String sign =
        getSign({"client": "new", "data": data, "timestamp": timestamp});
    if (!isIm) {
      return "client=new&timestamp=$timestamp&data=$data&sign=$sign";
    } else {
      return data;
    }
  }

  static Future<String> decryptResData(dynamic data) async {
    try {
      Encrypter encrypter = Encrypter(AES(key, mode: AESMode.cbc));
      Encrypted encrypted = Encrypted.fromBase64(data['data']);
      String decrypted = encrypter.decrypt(encrypted, iv: iv);
      return decrypted;
    } catch (e) {
      return '';
    }
  }

  //加密线路
  static Future<String> encryptLine(String str) async {
    var encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    var encrypted = encrypter.encryptBytes(utf8.encode(str), iv: iv);
    var data = utf8.decode(encrypted.base64.codeUnits);
    return data;
  }

// 解密线路
  static Future<String> decryptLine(dynamic data) async {
    var encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    var encrypted = Encrypted.fromBase64(data);
    var decrypted = encrypter.decrypt(encrypted, iv: iv);
    return decrypted;
  }

  static Uint8List? decryptImage(data) {
    try {
      Encrypter encrypter = Encrypter(AES(mediaKey, mode: AESMode.cbc));
      Encrypted encrypted = Encrypted.fromBase64(base64Encode(data));
      // final stopwatch = Stopwatch()..start();
      List<int> decrypted = encrypter.decryptBytes(encrypted, iv: mediaIv);
      return Uint8List.fromList(decrypted);
    } catch (err) {
      CommonUtils.debugPrint(err);
      return null;
    }
  }

  static dynamic decryptM3U8(data) {
    try {
      Encrypter encrypter = Encrypter(AES(mediaKey, mode: AESMode.cbc));
      Encrypted encrypted = Encrypted.fromBase64(data);
      final stopwatch = Stopwatch()..start();
      String decrypted = encrypter.decrypt(encrypted, iv: mediaIv);
      CommonUtils.debugPrint('decode() executed in ${stopwatch.elapsed}');
      return decrypted;
    } catch (err) {
      return null;
    }
  }

  static Future<String> decryptSecret(String data) async {
    Encrypter encrypter =
        Encrypter(AES(Key.fromUtf8("856067f574aa6af5"), mode: AESMode.cbc));
    Encrypted encrypted = Encrypted.fromBase64(data);
    String decrypted =
        encrypter.decrypt(encrypted, iv: IV.fromUtf8("ef2d9fca68763f32"));
    return decrypted;
  }

  static Future<String> encryptSecret(String key) async {
    String serect = key.split('_').first ?? '';
    int interval = int.parse(key.split('_').last ?? '3600');
    int ct = (DateTime.now().millisecondsSinceEpoch / 1000 / interval).floor();
    String cal = (sha1.convert(utf8.encode(serect + ct.toString()))).toString();
    Digest sha = sha1.convert(utf8.encode(serect + cal));
    String str = md5.convert(utf8.encode(sha.toString())).toString();
    CommonUtils.debugPrint("ct: $ct cal:$cal sha:$sha str:$str");
    return str.substring(0, 16);
  }

  static Future<String> secretValue() async {
    String fds_key = AppGlobal.appBox!.get('fds_key') ?? "";
    String key = await decryptSecret(fds_key.isEmpty
        ? "likV31+s/PhN5xy0WbVMcGSQJTtIUegr2wjHtmqFOyrWYxM9kSwDAAObzZkkykYu"
        : fds_key);
    String value = await encryptSecret(key);
    return value;
  }
}
