import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:chaguaner2023/utils/network_imagecrp.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// 网络图片加载
class NetImageTool extends StatelessWidget {
  const NetImageTool({
    Key? key,
    this.url = "",
    this.fit = BoxFit.cover,
    this.scale = 1.0,
    this.radius = const BorderRadius.all(Radius.circular(0)),
    this.isLoad = false,
  }) : super(key: key);

  final String url;
  final BoxFit? fit;
  final double scale;
  final BorderRadius radius;
  final bool isLoad;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: radius,
      child: url.isEmpty
          ? Container(
              color: isLoad ? Colors.transparent : StyleTheme.cBioColor,
            )
          : _NetImageWork(
              provider: NetworkImageCRP(
                url,
                scale: scale,
                context: context,
              ),
              fit: fit,
              isLoad: isLoad,
            ),
    );
  }
}

class _NetImageWork extends StatefulWidget {
  const _NetImageWork({
    Key? key,
    required this.provider,
    this.fit,
    this.isLoad = false,
  }) : super(key: key);

  final BoxFit? fit;
  final NetworkImageCRP provider;
  final bool isLoad;

  @override
  State<_NetImageWork> createState() => __NetImageWorkState();
}

class __NetImageWorkState extends State<_NetImageWork>
    with SingleTickerProviderStateMixin {
  ImageStream? _imageStream;
  ImageInfo? _imageInfo;
  bool _loading = true; // 图片加载状态，加载中则为true
  AnimationController? _controller;
  Animation<double>? _animation;
  late DisposableBuildContext<State<_NetImageWork>> _scrollAwareContext;

  @override
  void initState() {
    super.initState();
    _scrollAwareContext = DisposableBuildContext<State<_NetImageWork>>(this);
    _controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    _animation = Tween(begin: 1.0, end: 1.0).animate(_controller!);
    _controller!.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolveImage();
  }

  @override
  void didUpdateWidget(covariant _NetImageWork oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.provider != oldWidget.provider) {
      _resolveImage();
    }
  }

  void _resolveImage() {
    final ScrollAwareImageProvider _provider = ScrollAwareImageProvider<Object>(
      context: _scrollAwareContext,
      imageProvider: widget.provider,
    );
    final ImageStream? oldImageStream = _imageStream;
    // 调用 imageProvider.resolve 方法，获得 ImageStream。
    _imageStream = _provider.resolve(createLocalImageConfiguration(context));

    // 判断新旧 ImageStream 是否相同，如果不同，则需要调整流的监听器
    if (_imageStream?.key != oldImageStream?.key) {
      final ImageStreamListener listener = ImageStreamListener(_updateImage);
      oldImageStream?.removeListener(listener);
      _imageStream?.addListener(listener);
    }
  }

  void _updateImage(ImageInfo imageInfo, bool synchronousCall) {
    if (mounted) {
      _imageInfo = imageInfo;
      _loading = false;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? widget.isLoad
            ? Center(
                child: CircularProgressIndicator(
                  color: StyleTheme.cBioColor,
                  strokeWidth: 1.w,
                ),
              )
            : Container(
                color: const Color.fromRGBO(238, 238, 238, 1.0),
                child: Center(
                  child: LocalPNG(
                    url: 'assets/images/default_avatar.png',
                    width: 80.w,
                    height: 80.w,
                  ),
                ),
              )
        : RawImage(
            filterQuality: FilterQuality.high,
            width: widget.fit == BoxFit.fitHeight ? null : double.infinity,
            height: widget.fit == BoxFit.fitWidth ? null : double.infinity,
            opacity: _animation,
            image: _imageInfo!.image,
            scale: _imageInfo!.scale,
            repeat: ImageRepeat.noRepeat,
            fit: widget.fit,
          );
  }

  @override
  void dispose() {
    _imageStream?.removeListener(ImageStreamListener(_updateImage));
    _controller?.dispose();
    _scrollAwareContext.dispose();
    super.dispose();
  }
}
