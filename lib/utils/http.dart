// import 'dart:convert';
// import 'dart:io';
// import 'package:chaguaner2023/utils/api.dart';
// import 'package:chaguaner2023/utils/common.dart';
// import 'package:chaguaner2023/utils/encdecrypt.dart';
// import 'package:chaguaner2023/utils/app_global.dart';
// import 'package:dio/dio.dart';
// import 'package:flutter/foundation.dart';
// import 'package:go_router/go_router.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:http_parser/http_parser.dart';
// import 'dart:ui' as ui;
// import 'package:image_compression_flutter/image_compression_flutter.dart';
//
// // 是否因token失效跳转到登录页
// bool isJump = false;
//
// String getToken() {
//   Box box = AppGlobal.appBox!;
//   return box.get('apiToken') == null ? "" : box.get('apiToken').toString();
// }
//
// Dio _uploadDio = new Dio(new BaseOptions(
//   connectTimeout: Duration(seconds: 60),
//   receiveTimeout: Duration(seconds: 300),
// ));
//
// Dio _apiDio = new Dio(new BaseOptions(
//     connectTimeout: Duration(seconds: 60),
//     receiveTimeout: Duration(seconds: 300),
//     validateStatus: (status) {
//       return status! < 500;
//     },
//     contentType: Headers.formUrlEncodedContentType))
//   ..interceptors.add(InterceptorsWrapper(onRequest: (options, handler) async {
//     Map _data = {};
//     String yytoken = getToken();
//     if (yytoken != '') {
//       AppGlobal.apiToken.value = yytoken;
//     }
//     _data.addAll(AppGlobal.appinfo!);
//     if (AppGlobal.apiToken.value.isNotEmpty) {
//       _data.addAll({'token': AppGlobal.apiToken.value});
//     }
//     if (options.data != null) {
//       _data.addAll(options.data);
//     }
//     CommonUtils.debugPrint('参数:${_data}');
//     options.data = await EncDecrypt.encryptReqParams(jsonEncode(_data));
//     if (!kIsWeb) {
//       options.headers["Cf-Ray-Xf"] = await EncDecrypt.secretValue();
//       CommonUtils.debugPrint(options.headers);
//     }
//     return handler.next(options);
//   }, onResponse: (response, handler) async {
//     if (response.data['data'] != null) {
//       String _data = await EncDecrypt.decryptResData(response.data);
//       response.data = jsonDecode(_data);
//     }
//     if (response.data["msg"] == "token无效" && !isJump) {
//       CommonUtils.showText("token失效,请重新登录");
//       isJump = true;
//       AppGlobal.apiToken.value = '';
//       Box box = AppGlobal.appBox!;
//       box.delete('apiToken');
//       getHomeConfig(AppGlobal.appContext!).then((value) {
//         AppGlobal.appContext!.go('/home/loginPage/2');
//       });
//       Future.delayed(Duration(seconds: 3), () {
//         isJump = false;
//       });
//     }
//     return handler.next(response);
//   }, onError: (DioError e, handler) {
//     return handler.next(e);
//   }));
//
// class PlatformAwareHttp {
//   static CancelToken? cancelToken;
//   static Future<ui.Image> bytesToImage(Uint8List imgBytes) async {
//     ui.Codec codec = await ui.instantiateImageCodec(imgBytes);
//     ui.FrameInfo frame = await codec.getNextFrame();
//     return frame.image;
//   }
//
//   static Future<Response> uploadImage(
//       {Map? imageUrl,
//       String? id,
//       String position = 'head',
//       ProgressCallback? progressCallback}) async {
//     var imgKey = AppGlobal.uploadImgKey.replaceFirst('head', '');
//     var newKey = 'id=$id&position=$position$imgKey';
//     var tmpSha256 = CommonUtils.gvSha256(newKey);
//     var sign = CommonUtils.gvMD5(tmpSha256);
//     String _path = File.fromRawPath(imageUrl!['value']).path;
//     Configuration config = Configuration(
//       outputType: ImageOutputType.jpg,
//       useJpgPngNativeCompressor: false,
//       quality: 40,
//     );
//     final param = ImageFileConfiguration(
//         input: ImageFile(filePath: _path, rawBytes: imageUrl['value']),
//         config: config);
//     final output = await compressor.compress(param);
//
//     MultipartFile imageData = MultipartFile.fromBytes(output.rawBytes,
//         filename: imageUrl['name'], contentType: new MediaType('image', 'jpg'));
//     FormData formData = FormData.fromMap({
//       'id': id,
//       'position': position,
//       'sign': sign,
//       'cover': imageData,
//     });
//     cancelToken = null;
//     cancelToken = new CancelToken();
//     Response response = await _uploadDio
//         .post(AppGlobal.uploadImgUrl,
//             data: formData,
//             cancelToken: cancelToken,
//             onSendProgress: progressCallback,
//             options: Options(contentType: 'multipart/form-data'))
//         .catchError((e) {
//       CommonUtils.showText('上传错误:${e.toString()}');
//     });
//     return response;
//   }
//
//   static Future<Response?> uploadVideo(
//       {dynamic videoUrl, ProgressCallback? progressCallback}) async {
//     try {
//       var timestamp = '${DateTime.now().millisecondsSinceEpoch}';
//       var videoKey = AppGlobal.uploadVideoKey.replaceFirst('head', '');
//       var newKey = '$timestamp$videoKey';
//       var sign = CommonUtils.gvMD5(newKey);
//       List<String> videoUrlSplit = kIsWeb ? [] : videoUrl.split(".");
//       String videoType = kIsWeb ? '' : videoUrlSplit.last;
//       if (!kIsWeb && videoUrlSplit.length <= 1) {
//         videoType = 'mp4';
//       }
//       // print(lookupMimeType(videoUrl));
//       var videoName = CommonUtils.gvMD5(timestamp);
//
//       var videoData = kIsWeb
//           ? await MultipartFile.fromBytes(videoUrl['value'],
//               filename: videoUrl['name'],
//               contentType: MediaType.parse(videoUrl['type']))
//           : await MultipartFile.fromFile(
//               videoUrl,
//               filename: '$videoName.$videoType',
//               contentType: MediaType.parse('video/$videoType'),
//             );
//       FormData formData = FormData.fromMap({
//         'uuid': 'chaguaner',
//         'timestamp': timestamp,
//         'sign': sign,
//         'video': videoData,
//       });
//       cancelToken = null;
//       cancelToken = new CancelToken();
//       Response response = await _uploadDio.post(AppGlobal.uploadVideoUrl,
//           data: formData,
//           cancelToken: cancelToken,
//           onSendProgress: progressCallback,
//           options: Options(contentType: 'multipart/form-data'));
//       return response;
//     } catch (e) {
//       CommonUtils.showText('视频上传时出错,换个视频试试～');
//       CommonUtils.debugPrint(e);
//       return null;
//     }
//   }
//
//   static Future newUploadVideo(
//       {dynamic videoUrl, ProgressCallback? progressCallback}) async {
//     try {
//       var pathData = await uploadvideo();
//       File file = File(kIsWeb ? '' : videoUrl);
//       int contentLength = kIsWeb ? await videoUrl.length : await file.length();
//       Stream<List<int>> stream = kIsWeb ? videoUrl : file.openRead();
//       cancelToken = null;
//       cancelToken = new CancelToken();
//       return await Dio()
//           .put(pathData['data']['uploadUrl'],
//               data: stream,
//               cancelToken: cancelToken,
//               onSendProgress: progressCallback,
//               options: Options(contentType: 'video/mp4', headers: {
//                 HttpHeaders.contentLengthHeader: contentLength,
//               }))
//           .then((value) {
//         return pathData['data']['publicUrl'];
//       }).catchError((e) {
//         print('错误:$e');
//         return null;
//       });
//     } catch (e) {
//       CommonUtils.showText('视频上传时出错,换个视频试试～');
//       return null;
//     }
//   }
//
//   static Future<Response> download(String urlPath, String savePath,
//       {ProgressCallback? onReceiveProgress}) {
// //    if(_dio == null) return;
//     return _uploadDio.download(urlPath, savePath,
//         onReceiveProgress: onReceiveProgress);
//   }
//
//   // cancelToken 用于二级页面销毁时，中断正在进行的异步请求
//   static Future post(String path, {Map? data, CancelToken? cancelToken}) {
//     // AppGlobal.apiBaseURL = 'https://laochaguan.yesebo.net/api.php';
//     return _apiDio.post(AppGlobal.apiBaseURL + path,
//         data: data, cancelToken: cancelToken);
//   }
// }
