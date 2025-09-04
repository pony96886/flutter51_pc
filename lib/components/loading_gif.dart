import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoadingGif extends StatelessWidget {
  final double? width;
  const LoadingGif({Key? key, this.width}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
        child: Image.asset(
      'assets/lottie/pull_refresh/images/loading.gif',
      width: width ?? 1.w,
      fit: BoxFit.fitWidth,
    ));
  }
}
