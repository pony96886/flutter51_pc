import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_compression_flutter/image_compression_flutter.dart';
import 'package:universal_html/html.dart' as html;
import 'package:image/image.dart' as ImgLib;
import 'package:cross_file/cross_file.dart';

import 'api.dart';
import 'app_global.dart';
import 'cache/cache_manager.dart';
import 'encdecrypt.dart';

// 是否因token失效跳转到登录页
bool isJump = false;

String getToken() {
  Box box = AppGlobal.appBox!;
  return box.get('apiToken') == null ? "" : box.get('apiToken').toString();
}

//网络加载
class NetworkHttp {
  NetworkHttp._internal();

  factory NetworkHttp() => instance;
  static final NetworkHttp instance = NetworkHttp._internal();

  // // cancelToken 用于二级页面销毁时，中断正在进行的异步请求
  // static  Future post(String path, {Map? data, CancelToken? cancelToken}) {
  //   // AppGlobal.apiBaseURL = 'https://laochaguan.yesebo.net/api.php';
  //   return _apiDio.post(AppGlobal.apiBaseURL + path,
  //       data: data, cancelToken: cancelToken);
  // }

  //是否因token失效跳转到登录页
  static bool _isJump = false;
  static late final Dio _uploadDio;
  static late final Dio _httpDio;

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;
    //上传
    _uploadDio = Dio(BaseOptions(
      connectTimeout: const Duration(milliseconds: 60000),
      receiveTimeout: const Duration(milliseconds: 300000),
    ));
    _httpDio = Dio(
      BaseOptions(
        connectTimeout: const Duration(milliseconds: 60000),
        receiveTimeout: const Duration(milliseconds: 300000),
        validateStatus: (status) {
          return status != null && status >= 200 && status < 300;
        },
        contentType: Headers.formUrlEncodedContentType,
      ),
    )..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            // Map _data = {};
            // String _token = await CacheManager.instance.getToken();
            // _data.addAll(CacheManager.instance.appinfo);
            // _data.addAll({'token': _token});
            // if (options.data != null) _data.addAll(options.data);
            // // LogUtilS.d('参数:$_data');
            // options.data = await EncDecrypt.encryptReqParams(jsonEncode(_data));
            // return handler.next(options);
            Map _data = {};
            String yytoken = getToken();
            if (yytoken != '') {
              AppGlobal.apiToken.value = yytoken;
            }
            _data.addAll(AppGlobal.appinfo!);
            if (AppGlobal.apiToken.value.isNotEmpty) {
              _data.addAll({'token': AppGlobal.apiToken.value});
            }
            if (options.data != null) {
              _data.addAll(options.data);
            }
            CommonUtils.debugPrint('参数:${_data}');
            options.data = await EncDecrypt.encryptReqParams(jsonEncode(_data));
            if (!kIsWeb) {
              options.headers["Cf-Ray-Xf"] = await EncDecrypt.secretValue();
              CommonUtils.debugPrint(options.headers);
            }
            return handler.next(options);
          },
          onResponse: (response, handler) async {
            if (response.data['data'] != null) {
              String _data = await EncDecrypt.decryptResData(response.data);
              response.data = jsonDecode(_data);
              // LogUtilS.d('数据返回:${response.data['data']}');
            }
            if (response.data["msg"] == "token无效" && !_isJump) {
              CommonUtils.showText("token失效,请重新登录");
              isJump = true;
              AppGlobal.apiToken.value = '';
              Box box = AppGlobal.appBox!;
              box.delete('apiToken');
              getHomeConfig(AppGlobal.appContext!).then((value) {
                AppGlobal.appContext!.go('/home/loginPage/2');
              });
              Future.delayed(Duration(seconds: 3), () {
                isJump = false;
              });
              // Utils.showDialog(
              //   setContent: () {
              //     return RichText(
              //         text: TextSpan(children: [
              //       TextSpan(text: "您已经在另外台设备登录，请重新登录！", style: StyleTheme.font_gray_153_13),
              //     ]));
              //   },
              //   confirm: () async {
              //     //清空数据
              //     await CacheManager.instance.clearToken();
              //     CacheManager.instance.context.read<UserStatusProvider>().initStatus();
              //     reqUserInfo(CacheManager.instance.context).then((value) {
              //       UtilEventbus().fire(EventbusClass({"name": "logout"}));
              //       CacheManager.instance.appRouter.go("/mineloginpage");
              //       _isJump = false;
              //     });
              //   },
              // );
            }
            return handler.next(response);
          },
          onError: (DioError e, handler) async {
            return handler.next(e);
          },
        ),
      );
  }

  static CancelToken? cancelToken;
  static Future<Response> uploadImage(
      {Map? imageUrl, String? id, String position = 'head', ProgressCallback? progressCallback}) async {
    var imgKey = AppGlobal.uploadImgKey.replaceFirst('head', '');
    var newKey = 'id=$id&position=$position$imgKey';
    var tmpSha256 = CommonUtils.gvSha256(newKey);
    var sign = CommonUtils.gvMD5(tmpSha256);
    String _path = File.fromRawPath(imageUrl!['value']).path;
    Configuration config = Configuration(
      outputType: ImageOutputType.jpg,
      useJpgPngNativeCompressor: false,
      quality: 40,
    );
    final param =
        ImageFileConfiguration(input: ImageFile(filePath: _path, rawBytes: imageUrl['value']), config: config);
    final output = await compressor.compress(param);

    MultipartFile imageData = MultipartFile.fromBytes(output.rawBytes,
        filename: imageUrl['name'], contentType: new MediaType('image', 'jpg'));
    FormData formData = FormData.fromMap({
      'id': id,
      'position': position,
      'sign': sign,
      'cover': imageData,
    });
    cancelToken = null;
    cancelToken = new CancelToken();
    Response response = await _uploadDio
        .post(AppGlobal.uploadImgUrl,
            data: formData,
            cancelToken: cancelToken,
            onSendProgress: progressCallback,
            options: Options(contentType: 'multipart/form-data'))
        .catchError((e) {
      CommonUtils.showText('上传错误:${e.toString()}');
    });
    return response;
  }

  static Future<Response?> uploadVideo({dynamic videoUrl, ProgressCallback? progressCallback}) async {
    try {
      var timestamp = '${DateTime.now().millisecondsSinceEpoch}';
      var videoKey = AppGlobal.uploadVideoKey.replaceFirst('head', '');
      var newKey = '$timestamp$videoKey';
      var sign = CommonUtils.gvMD5(newKey);
      List<String> videoUrlSplit = kIsWeb ? [] : videoUrl.split(".");
      String videoType = kIsWeb ? '' : videoUrlSplit.last;
      if (!kIsWeb && videoUrlSplit.length <= 1) {
        videoType = 'mp4';
      }
      // print(lookupMimeType(videoUrl));
      var videoName = CommonUtils.gvMD5(timestamp);

      var videoData = kIsWeb
          ? await MultipartFile.fromBytes(videoUrl['value'],
              filename: videoUrl['name'], contentType: MediaType.parse(videoUrl['type']))
          : await MultipartFile.fromFile(
              videoUrl,
              filename: '$videoName.$videoType',
              contentType: MediaType.parse('video/$videoType'),
            );
      FormData formData = FormData.fromMap({
        'uuid': 'chaguaner',
        'timestamp': timestamp,
        'sign': sign,
        'video': videoData,
      });
      cancelToken = null;
      cancelToken = new CancelToken();
      Response response = await _uploadDio.post(AppGlobal.uploadVideoUrl,
          data: formData,
          cancelToken: cancelToken,
          onSendProgress: progressCallback,
          options: Options(contentType: 'multipart/form-data'));
      return response;
    } catch (e) {
      CommonUtils.showText('视频上传时出错,换个视频试试～');
      CommonUtils.debugPrint(e);
      return null;
    }
  }

  Future xfileHtmlUploadImage(
      {XFile? file, String? id, String position = 'head', Function(html.ProgressEvent)? progressCallback}) async {
    try {
      id ??= DateTime.now().millisecondsSinceEpoch.toString();
      var imgKey = CacheManager.instance.uploadImgKey.replaceFirst('head', '');
      var newKey = 'id=$id&position=$position$imgKey';
      var tmpSha256 = CommonUtils.gvSha256(newKey);
      var sign = CommonUtils.gvMD5(tmpSha256);
      var ext = file?.name.split(".").last;

      html.Blob? blob = html.Blob([await file?.readAsBytes()], "image/$ext");
      String url = html.Url.createObjectUrl(blob);
      final html.FormData formData = html.FormData()
        ..append('id', id)
        ..append('position', position)
        ..append('sign', sign)
        ..appendBlob(
          "cover",
          blob,
        );

      html.HttpRequest httpRequest = await html.HttpRequest.request(CacheManager.instance.uploadImgUrl,
          method: "POST", mimeType: "image/$ext", sendData: formData, onProgress: progressCallback);
      html.Url.revokeObjectUrl(url);
      return jsonDecode(httpRequest.response);
    } catch (e) {
      // Utils.log(e);
      return null;
    }
  }

  Future htmlBytesUploadMp4(
      {XFile? file,
      String position = 'head',
      CancelToken? cancelToken,
      Function(html.ProgressEvent)? progressCallback}) async {
    try {
      String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
      var videoKey = CacheManager.instance.uploadMp4Key.replaceFirst('head', '');
      var newKey = '$timeStamp$videoKey';
      var sign = CommonUtils.gvMD5(newKey);

      html.Blob? blob = html.Blob([await file?.readAsBytes()], "video/mp4");
      String url = html.Url.createObjectUrl(blob);
      final html.FormData formData = html.FormData()
        ..append('timestamp', timeStamp)
        ..append('uuid', "9544f11ed4381ebcef5429b6f20e69c1")
        ..append('position', position)
        ..append('sign', sign)
        ..appendBlob(
          "video",
          blob,
        );

      html.HttpRequest httpRequest = await html.HttpRequest.request(
        CacheManager.instance.uploadMp4Url,
        method: "POST",
        mimeType: "video/mp4",
        sendData: formData,
        onProgress: progressCallback,
      );
      html.Url.revokeObjectUrl(url);
      return httpRequest.response;
    } catch (e) {
      // Utils.log(e);
      return null;
    }
  }

  Future<Map<String, dynamic>> uploadImageBytes(Uint8List bytes, {CancelToken? cancel}) async {
    try {
      var image = ImgLib.decodeImage(bytes);
      var timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
      var imgKey = CacheManager.instance.uploadImgKey.replaceFirst('head', '');
      var newKey = 'id=$timeStamp&position=head$imgKey';
      var tmpSha256 = CommonUtils.gvSha256(newKey);
      var sign = CommonUtils.gvMD5(tmpSha256);

      FormData formData = FormData.fromMap({
        'id': timeStamp,
        'position': 'head',
        'sign': sign,
        'cover': MultipartFile.fromBytes(
          bytes,
          filename: timeStamp + ".png",
          contentType: MediaType.parse('image/png'),
        ),
      });

      Response response = await _uploadDio.post(
        CacheManager.instance.uploadImgUrl,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
        cancelToken: cancel,
      );
      Map<String, dynamic> p = jsonDecode(response.data);
      p["thumb_width"] = image?.width ?? 100;
      p["thumb_height"] = image?.height ?? 100;
      return p;
    } catch (e) {
      return {};
    }
  }

  Future xfileBytesUploadMp4(
      {XFile? file, String position = 'head', CancelToken? cancelToken, ProgressCallback? progressCallback}) async {
    try {
      String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
      var videoKey = CacheManager.instance.uploadMp4Key.replaceFirst('head', '');
      var newKey = '$timeStamp$videoKey';
      var sign = CommonUtils.gvMD5(newKey);

      FormData formData = FormData.fromMap({
        'timestamp': timeStamp,
        'uuid': '9544f11ed4381ebcef5429b6f20e69c1',
        'sign': sign,
        'video': MultipartFile.fromBytes(
          await file?.readAsBytes() ?? [],
          filename: file?.name,
          contentType: MediaType.parse('video/mp4'),
        ),
      });

      Response response = await _uploadDio.post(
        CacheManager.instance.uploadMp4Url,
        data: formData,
        onSendProgress: progressCallback,
        options: Options(contentType: 'multipart/form-data'),
        cancelToken: cancelToken,
      );
      return response.data;
    } catch (e) {
      // Utils.log(e);
      return null;
    }
  }

  Future xfileUploadMp4(
      {XFile? file, String position = 'head', CancelToken? cancelToken, ProgressCallback? progressCallback}) async {
    try {
      String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
      var videoKey = CacheManager.instance.uploadMp4Key.replaceFirst('head', '');
      var newKey = '$timeStamp$videoKey';
      var sign = CommonUtils.gvMD5(newKey);
      var imageName = CommonUtils.gvMD5(timeStamp);

      var filename = '$imageName.mp4';
      FormData formData = FormData.fromMap({
        'timestamp': timeStamp,
        'uuid': '9544f11ed4381ebcef5429b6f20e69c1',
        'sign': sign,
        'video': await MultipartFile.fromFile(
          file?.path ?? "",
          filename: filename,
          contentType: MediaType.parse('video/mp4'),
        ),
      });
      Response response = await _uploadDio.post(CacheManager.instance.uploadMp4Url,
          data: formData,
          onSendProgress: progressCallback,
          cancelToken: cancelToken,
          options: Options(contentType: 'multipart/form-data'));
      return response.data;
    } catch (e) {
      // Utils.log(e);
      return null;
    }
  }

  //R2大文件上传
  Future r2fileUploadMp4(
    String url,
    String filename, {
    XFile? file,
    CancelToken? cancelToken,
    ProgressCallback? progressCallback,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        "video": await MultipartFile.fromFile(
          file?.path ?? "",
          filename: filename,
        ),
      });
      Response response = await _uploadDio.put(
        url,
        data: formData.files.first.value.finalize(),
        onSendProgress: progressCallback,
        cancelToken: cancelToken,
        options: Options(
          contentType: 'video/mp4',
          headers: {Headers.contentLengthHeader: formData.files.first.value.length},
        ),
      );
      return response.statusCode;
    } catch (e) {
      // Utils.log(e);
      return null;
    }
  }

  //post请求
  Future post(String path, {Map? data, CancelToken? cancelToken}) {
    String apiPath = AppGlobal.apiBaseURL + path;
    // String apiPath = "https://se12311.hyys.info/api.php$path";
    // LogUtilS.d('地址：$apiPath');
    return _httpDio.post(
      apiPath,
      data: data,
      cancelToken: cancelToken,
    );
  }

  //get请求
  Future get(String url) {
    // Utils.log("request url: $url");
    return Dio().get(url);
  }

  Future<Response> download(String urlPath, String savePath, {ProgressCallback? onReceiveProgress}) {
    return _uploadDio.download(
      urlPath,
      savePath,
      onReceiveProgress: onReceiveProgress,
    );
  }
}
