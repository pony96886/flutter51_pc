// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

//加载本地图片
class LocalPNG extends StatefulWidget {
  LocalPNG(
      {Key? key,
      this.url,
      this.width,
      this.height,
      this.fit = BoxFit.fill,
      this.clipBehavior = Clip.hardEdge,
      this.filterQuality = FilterQuality.medium,
      this.alignment = Alignment.center,
      this.gaplessPlayback = false,
      this.call})
      : super(key: key);

  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final AlignmentGeometry alignment;
  final Clip clipBehavior;
  final FilterQuality filterQuality;
  final bool gaplessPlayback;
  final Function(Duration)? call;

  @override
  State<LocalPNG> createState() => _LocalPNGState();
}

class _LocalPNGState extends State<LocalPNG> {
  Widget _child = Container();
  Duration duration = Duration(milliseconds: 1150);

  @override
  void initState() {
    super.initState();
    if (widget.call == null) return;
    Future.delayed(duration, () {
      widget.call!(duration);
    });
  }

  _loadImage() {
    _child = widget.url!.isEmpty
        ? Container()
        : Image.asset(widget.url!,
            width: widget.width,
            height: widget.height,
            alignment: widget.alignment,
            fit: widget.fit,
            gaplessPlayback: widget.gaplessPlayback,
            filterQuality: widget.filterQuality);
  }

  @override
  Widget build(BuildContext context) {
    _loadImage();
    return _child;
  }
}
