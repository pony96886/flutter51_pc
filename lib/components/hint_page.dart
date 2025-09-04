import 'package:chaguaner2023/utils/app_global.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HintPage extends StatefulWidget {
  HintPage({Key? key, this.text, this.time, this.type = 1, this.index})
      : super(key: key);
  final String? text;
  final int? time;
  final int? type;
  final int? index;
  @override
  _HintPageState createState() => _HintPageState();
}

class _HintPageState extends State<HintPage> with TickerProviderStateMixin {
  Animation<double>? animation;
  AnimationController? animationController;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    animationController =
        AnimationController(duration: Duration(milliseconds: 300), vsync: this);
    animation = Tween<double>(begin: 0, end: 1)
        .animate(animationController!)
        .drive(CurveTween(curve: Curves.bounceIn));
    animationController!.forward();
    Future.delayed(Duration(milliseconds: widget.time!), () {
      animationController!.reverse().then((value) {
        AppGlobal.overlayEntry[widget.index]!.remove();
        AppGlobal.overlayEntry.remove(widget.index);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
        top: 0,
        bottom: 0,
        right: 0,
        left: 0,
        child: IgnorePointer(
          ignoring: true,
          child: Material(
            color: Colors.transparent,
            child: widget.type == 2
                ? Container(
                    alignment: Alignment.centerRight,
                    child: AnimatedBuilder(
                      animation: animationController!,
                      builder: (BuildContext? context, Widget? child) {
                        return Opacity(
                          opacity: animationController!.value,
                          child: Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..setTranslationRaw(
                                  (1 - animationController!.value) * 50.w - 2.w,
                                  0,
                                  0),
                            child: child,
                          ),
                        );
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                color: Color(0xff31155f),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(15.w),
                                  bottomLeft: Radius.circular(15.w),
                                ),
                                border: Border.all(
                                    width: 1.w, color: Color(0xffd4029c))),
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                            ),
                            height: 30.w,
                            child: Text(widget.text ?? '请填写提示信息～',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12.sp)),
                          )
                        ],
                      ),
                    ))
                : AnimatedBuilder(
                    animation: animationController!,
                    builder: (BuildContext? context, Widget? child) {
                      return Center(
                        child: Opacity(
                            opacity: animationController!.value, child: child),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: Color.fromRGBO(0, 0, 0, 0.42),
                          borderRadius: BorderRadius.circular(10.w)),
                      alignment: Alignment.center,
                      width: 317.w,
                      height: 62.w,
                      child: Text(widget.text ?? '请填写提示信息～',
                          style:
                              TextStyle(color: Colors.white, fontSize: 16.sp)),
                    ),
                  ),
          ),
        ));
  }
}
