// ignore_for_file: unnecessary_null_comparison
import 'dart:async';
import 'dart:ui' as ui show instantiateImageCodec, Codec;
import 'package:chaguaner2023/utils/image_request_async.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

//图片解密
class NetworkImageCRP extends ImageProvider<NetworkImageCRP> {
  const NetworkImageCRP(this.url,
      {this.scale = 1.0, this.headers, this.context})
      : assert(url != null),
        assert(scale != null);

  final String url;
  final double scale;
  final Map<String, String>? headers;
  final BuildContext? context;

  @override
  Future<NetworkImageCRP> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<NetworkImageCRP>(this);
  }

  Future<ui.Codec> _loadAsync(NetworkImageCRP key) async {
    assert(key == this);

    Uint8List bys = await ImageRequestAsync.getImageRequest(key.url);
    return ui.instantiateImageCodec(bys);
  }

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) return false;
    final NetworkImageCRP typedOther = other;
    return url == typedOther.url && scale == typedOther.scale;
  }

  @override
  int get hashCode => Object.hash(url, scale);

  @override
  String toString() => '$runtimeType("$url", scale: $scale)';

  @override
  void resolveStreamForKey(ImageConfiguration configuration, ImageStream stream,
      NetworkImageCRP key, ImageErrorListener handleError) {
    //TODO: implement resolveStreamForKey
    if (stream.completer != null ||
        PaintingBinding.instance.imageCache.containsKey(key)) {
      super.resolveStreamForKey(configuration, stream, key, handleError);
      return;
    }
    // The context has gone out of the tree - ignore it.
    if (context == null) {
      return;
    }

    if (Scrollable.recommendDeferredLoadingForContext(context!)) {
      SchedulerBinding.instance.scheduleFrameCallback((_) {
        scheduleMicrotask(() =>
            super.resolveStreamForKey(configuration, stream, key, handleError));
      });
      return;
    }
    super.resolveStreamForKey(configuration, stream, key, handleError);
  }

  @override
  ImageStreamCompleter loadImage(NetworkImageCRP key, decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key),
      scale: key.scale,
    );
  }
}
