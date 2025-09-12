import 'dart:typed_data';

import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/cache/cache_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

//有bytes直接读取 否则网络图片加载
class ImageNetTool extends StatelessWidget {
  const ImageNetTool({
    Key? key,
    this.url = "",
    this.bytes,
    this.fit = BoxFit.cover,
    this.scale = 1.0,
    this.radius = const BorderRadius.all(Radius.circular(0)),
  }) : super(key: key);

  final String url;
  final BoxFit fit;
  final double scale;
  final BorderRadius radius;
  final Uint8List? bytes;

  Widget placeholder({int type = 1}) => RepaintBoundary(
        child: type == 1
            ? Container(color: Colors.white.withOpacity(0.05))
            : Container(
                width: ScreenUtil().screenWidth,
                height: ScreenUtil().screenWidth / 2,
                alignment: Alignment.center,
                child: SizedBox(
                  height: 20.w,
                  width: 20.w,
                  child: CircularProgressIndicator(
                    color: Colors.white.withOpacity(0.05),
                    strokeWidth: 2.w,
                  ),
                ),
              ),
      );

  bool isHttp(String url) {
    return url.startsWith('http://') || url.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    String path = url;
    if (!isHttp(path)) {
      path = CacheManager.instance.imgBaseUrl + url;
    }
    return ClipRRect(
      borderRadius: radius,
      child: bytes != null
          ? Image.memory(
              bytes!,
              scale: scale,
              fit: fit,
              width: fit == BoxFit.cover ? double.infinity : null,
              height: fit == BoxFit.cover ? double.infinity : null,
              frameBuilder: (context, child, frame, bool wasSynchronous) {
                if (wasSynchronous || frame != null) return child;
                return placeholder(type: fit == BoxFit.cover ? 1 : 2);
              },
              errorBuilder: (context, error, stackTrace) {
                return placeholder(type: fit == BoxFit.cover ? 1 : 2);
              },
            )
          : path.isEmpty
              ? placeholder(type: fit == BoxFit.cover ? 1 : 2)
              : Image.network(
                  path,
                  scale: scale,
                  fit: fit,
                  width: fit == BoxFit.cover ? double.infinity : null,
                  height: fit == BoxFit.cover ? double.infinity : null,
                  frameBuilder: (context, child, frame, bool wasSynchronous) {
                    if (wasSynchronous || frame != null) return child;
                    return placeholder(type: fit == BoxFit.cover ? 1 : 2);
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return placeholder(type: fit == BoxFit.cover ? 1 : 2);
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return placeholder(type: fit == BoxFit.cover ? 1 : 2);
                  },
                ),
    );
  }
}
