import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StyleTheme {
  static double get headTabHeight => 44.w;
  static double get footTabHeight => 48.w;
  static double get margin => 13.w;

// Color

// 标题 详情主题色 ()
  static Color get cTitleColor => Color(0xFF1E1E1E);
// 文本内容主题色
  static Color get cTextColor => Color(0xFF787878);
// 危险色 （未注册 消息页面 Tab Active色 底部激活颜色）
  static Color get cDangerColor => Color(0xFFFF4149);
// 警告色 (验证状态 消息资源获得)
  static Color get cWanningColor => Color(0xFFCD79FF);
// 占位符颜色 (Input 推广记录等)
  static Color get cBioColor => Color(0xFFB4B4B4);
// 输入框背景色
  static Color get textbgColor1 => Color(0xFFEEEEEEE);
// 底部导航夜色
  static Color get bottomappbarColor => Color(0xFFF5F5F5);
// 边框颜色
  static Color get borderColor1 => Color(0xFFEBEBEB);

  static Color get color30 => Color.fromRGBO(30, 30, 30, 1);
  static Color white08Color = const Color.fromRGBO(255, 255, 255, 0.8);
  static Color get color31 => Color.fromRGBO(31, 31, 31, 1);
  static Color get color34 => Color.fromRGBO(34, 34, 34, 1);
  static Color get color50 => Color.fromRGBO(50, 50, 50, 1);
  static Color get color153 => Color.fromRGBO(153, 153, 153, 1);
  static Color get color102 => Color.fromRGBO(102, 102, 102, 1);
  static Color get color245 => Color.fromRGBO(245, 245, 245, 1);
  static Color get color253240228 => Color.fromRGBO(253, 240, 228, 1);
  static Color gray102Color = const Color.fromRGBO(102, 102, 102, 1);
  static Color gray153Color = const Color.fromRGBO(153, 153, 153, 1);

  static LinearGradient gradYellow = const LinearGradient(
    colors: [
      Color.fromRGBO(255, 135, 135, 1),
      Color.fromRGBO(255, 174, 0, 1),
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static TextStyle font_white_08_15 = StyleTheme.font(size: 15, weight: FontWeight.normal, color: white08Color);

  static TextStyle font_white_08_14 = StyleTheme.font(size: 14, weight: FontWeight.normal, color: white08Color);

  static TextStyle font_gray_153_13 = StyleTheme.font(size: 13, weight: FontWeight.normal, color: gray153Color);

  static TextStyle font(
      {int size = 16,
      Color color = Colors.white,
      FontWeight weight = FontWeight.normal,
      List<Shadow>? shadows,
      TextDecoration decoration = TextDecoration.none,
      FontStyle fontStyle = FontStyle.normal,
      double? height}) {
    return TextStyle(
        fontFamily: null,
        color: color,
        fontSize: size.sp,
        fontWeight: weight,
        overflow: TextOverflow.ellipsis,
        decoration: decoration,
        fontStyle: fontStyle,
        decorationStyle: TextDecorationStyle.dotted,
        shadows: shadows,
        height: height);
  }
}
