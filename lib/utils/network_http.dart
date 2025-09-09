import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:chaguaner2023/utils/common.dart';
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
            final Map _data = {};
            final String yytoken = getToken();
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
              final String _data =
                  await EncDecrypt.decryptResData(response.data);
              response.data = jsonDecode(_data);
            }
            if (response.data["msg"] == "token无效" && !_isJump) {
              CommonUtils.showText("token失效,请重新登录");
              isJump = true;
              AppGlobal.apiToken.value = '';
              final Box box = AppGlobal.appBox!;
              box.delete('apiToken');
              getHomeConfig(AppGlobal.appContext!).then((value) {
                AppGlobal.appContext!.go('/home/loginPage/2');
              });
              Future.delayed(const Duration(seconds: 3), () {
                isJump = false;
              });
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
      {Map? imageUrl,
      String? id,
      String position = 'head',
      ProgressCallback? progressCallback}) async {
    final imgKey = AppGlobal.uploadImgKey.replaceFirst('head', '');
    final newKey = 'id=$id&position=$position$imgKey';
    final sign = _computeSign(newKey);
    final String _path = File.fromRawPath(imageUrl!['value']).path;
    final Configuration config = Configuration(
      outputType: ImageOutputType.jpg,
      useJpgPngNativeCompressor: false,
      quality: 40,
    );
    final param = ImageFileConfiguration(
        input: ImageFile(filePath: _path, rawBytes: imageUrl['value']),
        config: config);
    final output = await compressor.compress(param);

    final MultipartFile imageData = MultipartFile.fromBytes(output.rawBytes,
        filename: imageUrl['name'], contentType: new MediaType('image', 'jpg'));
    final FormData formData = FormData.fromMap({
      'id': id,
      'position': position,
      'sign': sign,
      'cover': imageData,
    });
    cancelToken = null;
    cancelToken = CancelToken();
    final Response response = await _uploadDio
        .post(AppGlobal.uploadImgUrl,
            data: formData,
            cancelToken: cancelToken,
            onSendProgress: progressCallback,
            options: Options(contentType: 'multipart/form-data'))
        .catchError((e) {
      CommonUtils.showText('上传错误:${e.toString()}');
      return Response(
        requestOptions: RequestOptions(path: AppGlobal.uploadImgUrl),
        statusCode: 500,
        data: null,
        statusMessage: 'upload error',
      );
    });
    return response;
  }

  static Future<Response?> uploadVideo(
      {dynamic videoUrl, ProgressCallback? progressCallback}) async {
    try {
      final timestamp = '${DateTime.now().millisecondsSinceEpoch}';
      final videoKey = AppGlobal.uploadVideoKey.replaceFirst('head', '');
      final newKey = '$timestamp$videoKey';
      final sign = _computeSign(newKey);
      final List<String> videoUrlSplit = kIsWeb ? [] : videoUrl.split(".");
      String videoType = kIsWeb ? '' : videoUrlSplit.last;
      if (!kIsWeb && videoUrlSplit.length <= 1) {
        videoType = 'mp4';
      }
      final videoName = CommonUtils.gvMD5(timestamp);

      final videoData = kIsWeb
          ? await MultipartFile.fromBytes(videoUrl['value'],
              filename: videoUrl['name'],
              contentType: MediaType.parse(videoUrl['type']))
          : await MultipartFile.fromFile(
              videoUrl,
              filename: '$videoName.$videoType',
              contentType: MediaType.parse('video/$videoType'),
            );
      final FormData formData = FormData.fromMap({
        'uuid': 'chaguaner',
        'timestamp': timestamp,
        'sign': sign,
        'video': videoData,
      });
      cancelToken = null;
      cancelToken = CancelToken();
      final Response response = await _uploadDio.post(AppGlobal.uploadVideoUrl,
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
      {XFile? file,
      String? id,
      String position = 'head',
      Function(html.ProgressEvent)? progressCallback}) async {
    try {
      id ??= DateTime.now().millisecondsSinceEpoch.toString();
      final imgKey =
          CacheManager.instance.uploadImgKey.replaceFirst('head', '');
      final newKey = 'id=$id&position=$position$imgKey';
      final sign = _computeSign(newKey);
      final ext = file?.name.split(".").last;

      final html.Blob blob =
          html.Blob([await file?.readAsBytes()], "image/$ext");
      final String url = html.Url.createObjectUrl(blob);
      final html.FormData formData = html.FormData()
        ..append('id', id)
        ..append('position', position)
        ..append('sign', sign)
        ..appendBlob(
          "cover",
          blob,
        );

      final html.HttpRequest httpRequest = await html.HttpRequest.request(
          CacheManager.instance.uploadImgUrl,
          method: "POST",
          mimeType: "image/$ext",
          sendData: formData,
          onProgress: progressCallback);
      html.Url.revokeObjectUrl(url);
      return jsonDecode(httpRequest.response);
    } catch (e) {
      return null;
    }
  }

  Future htmlBytesUploadMp4(
      {XFile? file,
      String position = 'head',
      CancelToken? cancelToken,
      Function(html.ProgressEvent)? progressCallback}) async {
    try {
      final String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
      final videoKey =
          CacheManager.instance.uploadMp4Key.replaceFirst('head', '');
      final newKey = '$timeStamp$videoKey';
      final sign = _computeSign(newKey);

      final html.Blob blob =
          html.Blob([await file?.readAsBytes()], "video/mp4");
      final String url = html.Url.createObjectUrl(blob);
      final html.FormData formData = html.FormData()
        ..append('timestamp', timeStamp)
        ..append('uuid', "9544f11ed4381ebcef5429b6f20e69c1")
        ..append('position', position)
        ..append('sign', sign)
        ..appendBlob(
          "video",
          blob,
        );

      final html.HttpRequest httpRequest = await html.HttpRequest.request(
        CacheManager.instance.uploadMp4Url,
        method: "POST",
        mimeType: "video/mp4",
        sendData: formData,
        onProgress: progressCallback,
      );
      html.Url.revokeObjectUrl(url);
      return httpRequest.response;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>> uploadImageBytes(Uint8List bytes,
      {CancelToken? cancel}) async {
    try {
      final image = ImgLib.decodeImage(bytes);
      final timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
      final imgKey =
          CacheManager.instance.uploadImgKey.replaceFirst('head', '');
      final newKey = 'id=$timeStamp&position=head$imgKey';
      final sign = _computeSign(newKey);

      final FormData formData = FormData.fromMap({
        'id': timeStamp,
        'position': 'head',
        'sign': sign,
        'cover': MultipartFile.fromBytes(
          bytes,
          filename: timeStamp + ".png",
          contentType: MediaType.parse('image/png'),
        ),
      });

      final Response response = await _uploadDio.post(
        CacheManager.instance.uploadImgUrl,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
        cancelToken: cancel,
      );
      final dynamic respData = response.data;
      final Map<String, dynamic> p = respData is String
          ? jsonDecode(respData)
          : Map<String, dynamic>.from(respData as Map);
      p["thumb_width"] = image?.width ?? 100;
      p["thumb_height"] = image?.height ?? 100;
      return p;
    } catch (e) {
      return {};
    }
  }

  Future xfileBytesUploadMp4(
      {XFile? file,
      String position = 'head',
      CancelToken? cancelToken,
      ProgressCallback? progressCallback}) async {
    try {
      final String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
      final videoKey =
          CacheManager.instance.uploadMp4Key.replaceFirst('head', '');
      final newKey = '$timeStamp$videoKey';
      final sign = _computeSign(newKey);

      final FormData formData = FormData.fromMap({
        'timestamp': timeStamp,
        'uuid': '9544f11ed4381ebcef5429b6f20e69c1',
        'sign': sign,
        'video': MultipartFile.fromBytes(
          await file?.readAsBytes() ?? [],
          filename: file?.name,
          contentType: MediaType.parse('video/mp4'),
        ),
      });

      final Response response = await _uploadDio.post(
        CacheManager.instance.uploadMp4Url,
        data: formData,
        onSendProgress: progressCallback,
        options: Options(contentType: 'multipart/form-data'),
        cancelToken: cancelToken,
      );
      return response.data;
    } catch (e) {
      return null;
    }
  }

  Future xfileUploadMp4(
      {XFile? file,
      String position = 'head',
      CancelToken? cancelToken,
      ProgressCallback? progressCallback}) async {
    try {
      final String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
      final videoKey =
          CacheManager.instance.uploadMp4Key.replaceFirst('head', '');
      final newKey = '$timeStamp$videoKey';
      final sign = _computeSign(newKey);
      final imageName = CommonUtils.gvMD5(timeStamp);

      final filename = '$imageName.mp4';
      final FormData formData = FormData.fromMap({
        'timestamp': timeStamp,
        'uuid': '9544f11ed4381ebcef5429b6f20e69c1',
        'sign': sign,
        'video': await MultipartFile.fromFile(
          file?.path ?? "",
          filename: filename,
          contentType: MediaType.parse('video/mp4'),
        ),
      });
      final Response response = await _uploadDio.post(
          CacheManager.instance.uploadMp4Url,
          data: formData,
          onSendProgress: progressCallback,
          cancelToken: cancelToken,
          options: Options(contentType: 'multipart/form-data'));
      return response.data;
    } catch (e) {
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
      final FormData formData = FormData.fromMap({
        "video": await MultipartFile.fromFile(
          file?.path ?? "",
          filename: filename,
        ),
      });
      final Response response = await _uploadDio.put(
        url,
        data: formData.files.first.value.finalize(),
        onSendProgress: progressCallback,
        cancelToken: cancelToken,
        options: Options(
          contentType: 'video/mp4',
          headers: {
            Headers.contentLengthHeader: formData.files.first.value.length
          },
        ),
      );
      return response.statusCode;
    } catch (e) {
      return null;
    }
  }

  //post请求
  Future post(String path, {Map? data, CancelToken? cancelToken}) {
    final String apiPath = AppGlobal.apiBaseURL + path;
    return _httpDio.post(
      apiPath,
      data: data,
      cancelToken: cancelToken,
    );
  }

  //get请求
  Future get(String url) {
    return Dio().get(url);
  }

  Future<Response> download(String urlPath, String savePath,
      {ProgressCallback? onReceiveProgress}) {
    return _uploadDio.download(
      urlPath,
      savePath,
      onReceiveProgress: onReceiveProgress,
    );
  }

  // 计算 sign: MD5(SHA256(raw))，仅抽取公共逻辑，不改变原有算法
  static String _computeSign(String raw) {
    final tmpSha256 = CommonUtils.gvSha256(raw);
    return CommonUtils.gvMD5(tmpSha256);
  }
}
