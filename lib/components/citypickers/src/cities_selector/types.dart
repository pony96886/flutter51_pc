//
// target:  暂时未使用到. 目的是将builder暴露给开发者, 方便其自定义样式
//

import 'package:flutter/material.dart';

typedef Widget CityItemWidgetBuilder(BuildContext context);

/// Called to build IndexBar.
typedef Widget IndexBarBuilder(BuildContext context, List<String> tags);

/// Called to build index hint.
typedef Widget IndexHintBuilder(BuildContext context, String hint);
