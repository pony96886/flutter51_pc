import 'package:chaguaner2023/input/InputWidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class InputDialog {
  static Future<String?> show(BuildContext context, String tips,
      {int? limitingText,
      Function? onChange,
      Function? onSubmit,
      Widget? btnWidget,
      TextInputType? boardType,
      String? btnText}) async {
    return Navigator.of(context).push(InputOverlay(
        tips: tips,
        limitingText: limitingText,
        onSubmit: onSubmit,
        onChange: onChange,
        btnWidget: btnWidget,
        boardType: boardType,
        btnText: btnText));
  }
}

class InputOverlay extends ModalRoute<String> {
  final String? tips;
  final int? limitingText;
  final TextInputType? boardType;
  final Widget? btnWidget;
  final String? btnText;
  final Function? onChange;
  final Function? onSubmit;
  InputOverlay(
      {this.tips,
      this.btnWidget,
      @required this.limitingText,
      @required this.boardType,
      this.onChange,
      this.btnText,
      this.onSubmit});

  @override
  Duration get transitionDuration => Duration(milliseconds: 200);

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => true;

  @override
  Color get barrierColor => const Color(0x01000000);

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return InputWidget(
        tips: tips,
        btnWidget: btnWidget,
        limitingText: limitingText,
        onSubmit: onSubmit,
        onChange: onChange,
        boardType: boardType,
        btnText: btnText);
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
      ),
      child: child,
    );
  }
}
