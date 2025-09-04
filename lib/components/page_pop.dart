import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class PagePop extends StatefulWidget {
  PagePop({Key? key, this.page}) : super(key: key);
  final Widget? page;
  @override
  _PagePopState createState() => _PagePopState();
}

class _PagePopState extends State<PagePop> with SingleTickerProviderStateMixin {
  AnimationController? _pageAnimationController;
  Animation<double>? _pageAnimation;
  double? starW;
  double updateW = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _pageAnimationController = AnimationController(
        duration: Duration(milliseconds: 300), upperBound: 1.sw, vsync: this);
    _pageAnimation = Tween(begin: 0.0, end: 1.sw)
        .animate(_pageAnimationController!)
        .drive(CurveTween(curve: Curves.easeIn));
    _pageAnimationController!.value = 1.sw;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: _pageAnimationController!,
            builder: (context, child) {
              return Opacity(
                  opacity: _pageAnimationController!.value / 1.sw,
                  child: Transform.scale(
                    alignment: Alignment.center,
                    scale: _pageAnimationController!.value / 1.sw,
                    child: child,
                  ));
            },
            child: widget.page,
          ),
          Positioned(
              top: 0,
              bottom: 0,
              left: 0,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onHorizontalDragStart: (DragStartDetails e) {
                  starW = e.globalPosition.dx;
                },
                onHorizontalDragUpdate: (DragUpdateDetails e) {
                  updateW = 1.sw - (e.globalPosition.dx - starW!);
                  _pageAnimationController!.value = updateW;
                },
                onHorizontalDragEnd: (DragEndDetails e) {
                  if (updateW <= 0) return;
                  if (updateW <= 1.sw / 1.5) {
                    _pageAnimationController!.reverse().then((value) {
                      context.pop();
                    });
                  } else {
                    _pageAnimationController!.forward();
                  }
                },
                child: Container(
                  // color: Colors.white30,
                  width: 50.w,
                ),
              ))
        ],
      ),
    );
  }
}

// extension CustomTransitionPageUtil on CustomTransitionPage{
//   @override
//   void initState() {
//     super.initState();

//   }
// }
