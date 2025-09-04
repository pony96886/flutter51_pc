import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui' as ui;

enum NavIndicatorStyle {
  none,
  sys_line,
  sys_icon,
  sys_fixed,
  cus_line,
  cus_icon,
}

class NavTabBarWidget extends StatefulWidget {
  /// tabBarHeight default 44.w
  const NavTabBarWidget(
      {Key? key,
      this.indicatorStyle = NavIndicatorStyle.none,
      this.isScrollable = true,
      @required this.tabVc,
      @required this.tabs,
      this.tabBarHeight,
      this.textPadding,
      this.selectedIndex,
      @required this.norTextStyle,
      this.selTextStyle,
      this.onTapCallback,
      this.indicator = const BoxDecoration(),
      this.indicatorPadding = EdgeInsets.zero,
      this.itemPadding,
      this.itemMargin,
      this.backgroundColor,
      this.itemBackgroundColor,
      this.containerPadding,
      this.containerMargin,
      this.containerDecoration,
      this.containerWidth,
      this.indicatorHeight,
      this.onChange})
      : super(key: key);
  final NavIndicatorStyle? indicatorStyle;
  final bool? isScrollable;
  final TabController? tabVc; // 控制器
  final List<String>? tabs; // 栏目
  final double? tabBarHeight; // 栏目高度
  final EdgeInsets? textPadding; // 文字左右边距
  final int? selectedIndex; // 选择
  final EdgeInsetsGeometry? itemPadding;
  final EdgeInsetsGeometry? itemMargin;
  final Color? backgroundColor;
  final Color? itemBackgroundColor;
  final Function(int current)? onChange;
  final TextStyle? norTextStyle; //
  final TextStyle? selTextStyle; //
  final void Function(int)? onTapCallback; // 选中回调

  final double? indicatorHeight;
  final Decoration? indicator;
  final EdgeInsetsGeometry? indicatorPadding;

  final EdgeInsetsGeometry? containerPadding; // 内容编剧
  final EdgeInsetsGeometry? containerMargin;
  final Decoration? containerDecoration;
  final double? containerWidth;

  @override
  State createState() => _NavTabBarWidgetState();
}

class _NavTabBarWidgetState extends State<NavTabBarWidget> {
  double? _tabBarHeight;
  List<double> itemsWidth = [];

  TextStyle? _norTextStyle;
  TextStyle? _selTextStyle;
  EdgeInsets? _textPadding;
  // late int _selectedIndex;
  final ValueNotifier<int> _selectedIndex = ValueNotifier(0);
  @override
  void initState() {
    super.initState();
    _selectedIndex.value = widget.selectedIndex ?? 0;
    _tabBarHeight = widget.tabBarHeight ?? 44;
    _norTextStyle = widget.norTextStyle;
    _selTextStyle = widget.selTextStyle ?? widget.norTextStyle;
    _textPadding =
        widget.textPadding ?? const EdgeInsets.fromLTRB(10, 0, 10, 0);
    toCalculateTextListAction(); // 计算item的宽度
    // LogUtil.i(itemsWidth.toString());
    toOnTapItemListener();
  }

  onChange() {
    int _avalue = widget.tabVc!.animation!.value.round();
    if (_selectedIndex.value != _avalue) {
      _selectedIndex.value = _avalue;
      if (widget.onChange != null) {
        widget.onChange?.call(_avalue);
      }
      FocusScope.of(context).requestFocus(FocusNode());
    }
  }

  void toOnTapItemListener() {
    widget.tabVc!.animation!.addListener(onChange);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _selectedIndex.dispose();
    widget.tabVc!.animation!.removeListener(onChange);
  }

  @override
  void didUpdateWidget(covariant NavTabBarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 有变化的地方，需要在这里重置
    _norTextStyle = widget.norTextStyle;
    _selTextStyle = widget.selTextStyle ?? widget.norTextStyle;
    toCalculateTextListAction(); // 评论 -》评论(1)
    if (oldWidget.tabVc != widget.tabVc) {
      _selectedIndex.value = widget.tabVc!.index;
      widget.tabVc!.animation!.removeListener(onChange);
      toOnTapItemListener(); // 重新监听
    }
  }

  void toCalculateTextListAction() {
    // 因字体站位宽度不同，解决选择时的拖动感
    var lrPadding = _textPadding!.left + _textPadding!.right;
    itemsWidth = widget.tabs!.map<double>((text) {
      return calculateTextWidth(text, _selTextStyle!) + lrPadding;
    }).toList();
  }

  double calculateTextWidth(String value, TextStyle style,
      {int maxLines = 1,
      double maxWidth = double.infinity,
      double textScaleFactor = 1.0}) {
    var local = const Locale('zh', 'CN');
    // LogUtil.i(local.toString());

    var text = TextSpan(text: value, style: style, locale: local);
    var painter = TextPainter(
        // locale: WidgetsBinding.instance.window.locale,
        locale: local,
        maxLines: maxLines,
        textDirection: TextDirection.ltr,
        textScaleFactor: textScaleFactor,
        text: text);
    painter.layout(maxWidth: maxWidth);
    return painter.width;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.containerMargin,
      padding: widget.containerPadding,
      decoration: widget.containerDecoration,
      color: widget.backgroundColor,
      height: _tabBarHeight,
      width: widget.containerWidth ?? double.infinity,
      clipBehavior:
          widget.containerDecoration != null ? Clip.hardEdge : Clip.none,
      child: _buildTabBarWidget(),
    );
  }

  Widget _buildTabBarWidget() {
    Decoration indicator;
    switch (widget.indicatorStyle) {
      case NavIndicatorStyle.cus_line:
        indicator = widget.indicator!;
        break;
      case NavIndicatorStyle.cus_icon:
        indicator = widget.indicator!;
        break;
      default:
        indicator = const BoxDecoration();
    }
    return Theme(
        data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            useMaterial3: false),
        child: ValueListenableBuilder(
            valueListenable: _selectedIndex,
            builder: (context, int value, child) {
              return TabBar(
                padding: EdgeInsets.zero,
                onTap: (value) => widget.onTapCallback?.call(value),
                controller: widget.tabVc,
                isScrollable: widget.isScrollable!,
                labelPadding: EdgeInsets.zero,
                labelStyle: _selTextStyle,
                unselectedLabelStyle: _norTextStyle,
                labelColor: _selTextStyle!.color,
                unselectedLabelColor: _norTextStyle!.color,
                indicator: indicator,
                indicatorWeight: 0,
                indicatorPadding: widget.indicatorPadding!,
                enableFeedback: true,
                tabs: _buildTabBarItemsWidget(value),
              );
            }));
  }

  BoxDecoration? itemDecoration(bool isSelected) {
    if (widget.itemBackgroundColor == null) return null;
    return BoxDecoration(
      color: isSelected ? widget.itemBackgroundColor : Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: widget.itemBackgroundColor!),
    );
  }

  List<Widget> _buildTabBarItemsWidget(int value) {
    return itemsWidth.asMap().keys.map((i) {
      Widget? indicator = SizedBox();
      switch (widget.indicatorStyle) {
        case NavIndicatorStyle.sys_line:
          indicator = const SizedBox();
          break;
        case NavIndicatorStyle.sys_icon:
          // indicator = i == value
          //     ? _buildIndicatorImage(itemsWidth[i])
          //     :
          const SizedBox();
          break;
        case NavIndicatorStyle.sys_fixed:
          indicator = i == value ? _buildFixedWidthImage() : SizedBox();
          break;
        default:
          indicator = const SizedBox();
      }

      return Container(
        padding: widget.itemPadding,
        margin: widget.itemMargin,
        decoration: itemDecoration(i == value),
        width: itemsWidth[i],
        alignment: Alignment.center,
        child: Stack(
            alignment: widget.indicatorStyle == NavIndicatorStyle.sys_fixed
                ? AlignmentDirectional.bottomCenter
                : AlignmentDirectional.center,
            children: [
              indicator,
              Text(widget.tabs![i],
                  style: i == value ? _selTextStyle : _norTextStyle),
            ]),
      );
    }).toList();
  }

  Image _buildFixedWidthImage() {
    return Image.asset(
      'assets/images/tab-underline.png',
      width: double.infinity,
      fit: BoxFit.fill,
      height: 9.w,
    );
  }
}

class LineIndicator extends Decoration {
  const LineIndicator({
    this.width,
    this.color = const Color.fromRGBO(87, 184, 148, 1),
    this.colors = const [],
    this.height = 3,
    this.style = BorderStyle.solid,
    this.insets = EdgeInsets.zero,
    this.strokeCap = StrokeCap.round,
    this.isCenter = false,
  });

  final double? width;
  final Color color;
  final List<Color> colors; // linear gradient colors
  final double height;
  final BorderStyle style;
  final EdgeInsetsGeometry insets;
  final StrokeCap strokeCap;
  final bool isCenter;

  BorderSide get borderSide => BorderSide(width: height, color: color);

  @override
  Decoration? lerpFrom(Decoration? a, double t) {
    if (a is LineIndicator) {
      var side = BorderSide.lerp(a.borderSide, borderSide, t);
      return LineIndicator(
        color: side.color,
        height: side.width,
        style: side.style,
        insets: EdgeInsetsGeometry.lerp(a.insets, insets, t)!,
        isCenter: a.isCenter,
      );
    }
    return super.lerpFrom(a, t);
  }

  @override
  Decoration? lerpTo(Decoration? b, double t) {
    if (b is LineIndicator) {
      var side = BorderSide.lerp(b.borderSide, borderSide, t);
      return LineIndicator(
        color: side.color,
        height: side.width,
        style: side.style,
        insets: EdgeInsetsGeometry.lerp(insets, b.insets, t)!,
        isCenter: b.isCenter,
      );
    }
    return super.lerpTo(b, t);
  }

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _UnderlinePainter(this, onChanged!);
  }

  Rect _indicatorRectFor(Rect rect, TextDirection textDirection) {
    final Rect indicator = insets.resolve(textDirection).deflateRect(rect);
    var width = this.width ?? 20; // default width
    if (isCenter) {
      final double centerY =
          indicator.top + indicator.height / 2; // Vertical center
      return Rect.fromLTWH(
        (indicator.left + indicator.right - width) / 2,
        centerY - height / 2,
        width,
        height,
      );
    } else {
      return Rect.fromLTWH(
        (indicator.left + indicator.right - width) / 2,
        indicator.bottom - height,
        width,
        height,
      );
    }
  }

  @override
  Path getClipPath(Rect rect, TextDirection textDirection) {
    return Path()..addRect(_indicatorRectFor(rect, textDirection));
  }
}

class _UnderlinePainter extends BoxPainter {
  _UnderlinePainter(this.decoration, VoidCallback onChanged) : super(onChanged);

  final LineIndicator decoration;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    assert(configuration.size != null);
    final Rect rect = offset & configuration.size!;
    final TextDirection textDirection = configuration.textDirection!;
    final Rect indicator = decoration
        ._indicatorRectFor(rect, textDirection)
        .deflate(decoration.borderSide.width / 2.0);
    final Paint paint = decoration.borderSide.toPaint()
      ..strokeCap = decoration.strokeCap;

    // linear gradient
    if (decoration.colors.isNotEmpty) {
      paint.shader = ui.Gradient.linear(
        Offset(indicator.left, 0),
        Offset(indicator.right, 0),
        decoration.colors,
      );
    }

    canvas.drawLine(indicator.bottomLeft, indicator.bottomRight, paint);
  }
}
