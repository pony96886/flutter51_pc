import 'dart:ui';

import 'package:chaguaner2023/components/page_pop.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/netimage_tool.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

extension WidgetUtils on Widget {
  addBackground(String img) {
    return Stack(
      children: [
        Positioned.fill(
          child: NetImageTool(
            url: img,
            fit: BoxFit.fill,
          ),
        ),
        this
      ],
    );
  }

  addImageBlur(String img) {
    return Stack(
      children: [
        Opacity(opacity: 0.7, child: NetImageTool(url: img)),
        Positioned(
          right: 0,
          left: 0,
          bottom: 0,
          top: 0,
          child: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                color: Colors.black38,
              ),
            ),
          ),
        ),
        this
      ],
    );
  }

  CustomTransitionPage addTransitionPage(dynamic key,
      {bool isAnimation = true, int transitionDuration = 500}) {
    return CustomTransitionPage<void>(
      opaque: false,
      key: key,
      child: isAnimation
          ? PagePop(
              page: this,
            )
          : this,
      transitionDuration:
          Duration(milliseconds: isAnimation ? transitionDuration : 0),
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          isAnimation
              ? Opacity(
                  opacity: animation.value,
                  child: Transform.scale(
                    alignment: Alignment.center,
                    scale: animation.value,
                    child: child,
                  ))
              : Opacity(opacity: animation.value, child: child),
    );
  }
}

extension TextUtils on Text {
  toEmoji() {
    return Text(
      AppGlobal.emoji.emojify(this.data!),
      style: this.style,
      maxLines: this.maxLines,
      overflow: this.overflow,
      textHeightBehavior: this.textHeightBehavior,
    );
  }
}
