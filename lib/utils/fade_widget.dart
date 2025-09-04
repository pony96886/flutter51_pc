//@dart=2.12
import 'dart:convert';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:flutter/widgets.dart';

/// The direction in which an animation is running.
enum AnimationDirection {
  /// The animation is running from beginning to end.
  forward,

  /// The animation is running backwards, from end to beginning.
  reverse,
}

final _image = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAOIAAABuBAMAAADITNJHAAAAD1BMVEVHcEz///////////////8T4DEaAAAABXRSTlMAMwwaJzzI5yoAAAVmSURBVGjezVrbYesgDE2xB+A1AE46ADQdALfZf6bbm9jmJSHh/pS/phYHvYXQ5fInlrjdH+uqlLL2cf9wQ7TXH9JRyvtDletxZ4Pe1pLyg4OnoMXDFGtDaL8ImmlV8LKM004wpe/RvCt8fZMcnqAMqrcMgbiOU/YBKchlnHJR6heQU5dSQySzotfXORZ/VhzQe7E832zsTwC43g/lumElEnKdEXGId4xyUrwVmVaXFHdDxLMyERWCWIu0ZcYiQvn+uF7vn8NMTr2v3iHKTSjfrhtdgaNu660riaXV5NQYv/gcYnLpGtgW4X1DUHrbbcRcQ/9UcxMGwK0w83V0TPXwieojeGbqirSpOtiyYilUw42VhkZExK7L7z07PDsqxllsp+Ive2GHd38C8aVpnzuT5qcEfQbxeXaZy9jz07QhMweWXEyuxpHqxZ1AfB09UyOe3meGIgXDZd8S5dxRIyxXSXkHavcxgcuRqlBTiBJLaDLxEEeqtF0FH1iU05isTOspvEp0P7VDvrDYwW0SWvdeMcPGKhIvgWE6835WBmLDpN9swTpE8BEzHX8w0C/wZ3DDOSnsjVERixHEWmpyh9mZnBm1idgpFw7iDLGwJGYmTim9U7IQK02ag/GdSc5FY91+DyzEGRBanmVXxUtY5viWvAAD+z0pNyYDozYJG+XK8I7G/rNDaNBYodSwIyoeomg8fPvlxeTEqE22fCWIaxrsIBnii0lOuA8vSjbiXBv/ztaLyZVmcn39OvVvaYjt5Igvbhb6Qr2ljKmT0XDbKRANUir0EfVYgyjmGBIpbSUkJL/TGRoxV1WB6JA7r4UQ405nL0NilZkLWrTMjIB/HYjqMiTWHFGjNZ8Fbzuz4rpHbq05YsQLW9+6V6zpmEEgR3R49a7bm7usZcMMAhmixXoBdRRYKkSOsQoIUfeufrGRUELkmE7yAJ0QZa8nZBoryBD9iH+kciWjW7piFQ2iHFFkKleyPSGxypo2Q9QjHpn0aPutNlM3mTJEliJbRNPpXBUiCC2iH/DIhKiJ262sDisrH+OaTkKMzCv8dPjLzO7156aDIE54e3QGEOnqKm2ZEB3Vpo0l+wVi5JsOhviOxtYVQhzIyhG7ImEpa0psTXRHGrCNA9HSHSdX/O6b6oVnrB5rrglEkSuMyBDrW4Vo6LaarngU1PUddA8cUcCKFAlCkH0YCNHVnbYek8XPrrQuy3XIDuIEVzsiwa+sd6lqv8MTDKOrFjMmbY1oeIWHLe68VPdHV5RBjdgOA1EgZevRjV/ojlqznSnuvKTtZKS6/b/jIOqy0cZrqj2/l23i1hxEmaIB46Fut0exUVbWbB0DMSZeHKMHHJO4PeA/moHoy9YeJVaZiB0kA0f7o0vokdF1NsmmwLytacSmD93vjh6IwsIxwlNx1TR96L4ik0Hf2O2mMlvpug9NPLla8kEjEhlZ5hs7hunQD3CuX+f49gmjvyXlsD25FgcS2LfUG0/gD3BUeT8wow71tN6x16V0n+XkKy9UuyPBrnqNmc6+8rIf4Sfw3uvHX7IXLmTzxB1Yb66K91qMbhQbSuoF1F5YYgW4DM3+Av5wJsWFjCwZB+xjgEP4vvWzRw2q6Tqw2zyDYgt0NkJnno75mX2yxIKJSXcNJ3InDfYZof+gt9AdSwFHgPrhhDv11JjdPl3pOwUr2QQfm+xqG7SBV1Scn14LVfRfmOn2/ITelGbyrhdxW7njZ7+YQiQoNf/Zn52o+xpxI+MU3MognGLx8puJ2TA4X3esz9NTwRilpS6k5yefbysZmJF1erpb3Mnkg1HeTk+wV7PvnInwA/T+eFh1Ykr/SflEe9yvlz+y/gF3T6scNM7+qgAAAABJRU5ErkJggg==');

/// Helper Widget to Fade in or out
class FadeWidget extends StatefulWidget {
  /// Child widget being faded
  final Widget child;

  /// Fade duration
  final Duration duration;

  /// Duration direction, forward is from invisible to visible
  final AnimationDirection direction;

  /// Animation curve. See [Curves] for more options.
  final Curve curve;

  /// Fading [child] in or out depending on [direction] with a [curve] and
  /// [duration]./
  const FadeWidget(
      {required this.child,
      this.duration = const Duration(milliseconds: 800),
      this.direction = AnimationDirection.forward,
      this.curve = Curves.easeOut,
      Key? key})
      : super(key: key);

  @override
  _FadeWidgetState createState() => _FadeWidgetState();
}

class _FadeWidgetState extends State<FadeWidget>
    with SingleTickerProviderStateMixin {
  late Animation<double> opacity;
  late AnimationController controller;
  late bool hideWidget;

  @override
  Widget build(BuildContext context) {
    if (hideWidget) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: opacity,
      child: Container(
        color: Color.fromRGBO(238, 238, 238, 1),
        alignment: Alignment.center,
        child: LocalPNG(
          url: 'assets/images/default_avatar.png',
          width: double.infinity,
          fit: BoxFit.fitWidth,
        ),
      ),
      builder: (context, child) {
        return Stack(
          children: [
            Opacity(
              opacity: 1 - opacity.value,
              child: child,
            ),
            Opacity(
              opacity: opacity.value,
              child: widget.child,
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    controller = AnimationController(duration: widget.duration, vsync: this);
    final curved = CurvedAnimation(parent: controller, curve: widget.curve);
    var begin = widget.direction == AnimationDirection.forward ? 0.0 : 1.0;
    var end = widget.direction == AnimationDirection.forward ? 1.0 : 0.0;
    opacity = Tween<double>(begin: begin, end: end).animate(curved);
    controller.forward();

    hideWidget = false;
    if (widget.direction == AnimationDirection.reverse) {
      opacity.addStatusListener(animationStatusChange);
    }
  }

  @override
  void didUpdateWidget(FadeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (Widget.canUpdate(oldWidget.child, widget.child)) return;
    opacity.removeStatusListener(animationStatusChange);
    controller.duration = widget.duration;
    controller.value = 0;
    final curved = CurvedAnimation(parent: controller, curve: widget.curve);
    var begin = widget.direction == AnimationDirection.forward ? 0.0 : 1.0;
    var end = widget.direction == AnimationDirection.forward ? 1.0 : 0.0;
    opacity = Tween<double>(begin: begin, end: end).animate(curved);
    controller.forward();

    hideWidget = false;
    if (widget.direction == AnimationDirection.reverse) {
      opacity.addStatusListener(animationStatusChange);
    }
  }

  @override
  void dispose() {
    opacity.removeStatusListener(animationStatusChange);
    controller.dispose();
    super.dispose();
  }

  void animationStatusChange(AnimationStatus status) {
    setState(() {
      hideWidget = widget.direction == AnimationDirection.reverse &&
          status == AnimationStatus.completed;
    });
  }
}
