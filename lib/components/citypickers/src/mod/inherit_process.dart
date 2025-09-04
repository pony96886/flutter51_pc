//
// tartget:  xxx
//

import 'package:flutter/material.dart';
import 'picker_popup_route.dart';

class InheritRouteWidget extends InheritedWidget {
  final CityPickerRoute? router;

  InheritRouteWidget({Key? key, @required this.router, Widget? child})
      : super(key: key, child: child!);

  static InheritRouteWidget? of(BuildContext context) {
    // inheritFromWidgetOfExactType(InheritRouteWidget)
    return context.dependOnInheritedWidgetOfExactType(
        aspect: InheritRouteWidget);
  }

  @override
  bool updateShouldNotify(InheritRouteWidget oldWidget) {
    return oldWidget.router != router;
  }
}
