import 'package:chaguaner2023/utils/local_png.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum CgTabType { shuimo, redRaduis }

class CgTabView extends StatefulWidget {
  const CgTabView(
      {Key? key,
      this.initIndex = 0,
      this.tabs,
      this.pages,
      this.defaultStyle,
      this.activeStyle,
      this.type = CgTabType.shuimo,
      this.isFlex = false,
      this.spacing,
      this.isCenter = false,
      this.padding})
      : super(key: key);
  final int initIndex;
  final List? tabs;
  final List? pages;
  final bool isFlex;
  final bool isCenter;
  final double? spacing;
  final TextStyle? defaultStyle;
  final TextStyle? activeStyle;
  final CgTabType type;
  final EdgeInsetsGeometry? padding;
  @override
  State<CgTabView> createState() => _CgTabViewState();
}

class _CgTabViewState extends State<CgTabView> {
  PageController? _controller;
  TextStyle? defaultStyle;
  TextStyle? activeStyle;
  ValueNotifier<int> currentIndex = ValueNotifier(0);
  _setPageVeiw() {
    currentIndex.value = _controller!.page!.round();
  }

  _changeTap(int _index) {
    currentIndex.value = _index;
    _controller!.jumpToPage(_index);
  }

  @override
  void initState() {
    super.initState();
    defaultStyle =
        widget.defaultStyle ?? TextStyle(fontSize: 14.sp, color: Color(0xff1e1e1e), fontWeight: FontWeight.w700);
    activeStyle =
        widget.activeStyle ?? TextStyle(fontSize: 18.sp, color: Color(0xff1e1e1e), fontWeight: FontWeight.w700);
    _controller = PageController(initialPage: 0);
    _controller!.addListener(_setPageVeiw);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: widget.padding ?? EdgeInsets.zero,
          child: ValueListenableBuilder(
              valueListenable: currentIndex,
              builder: (context, value, child) {
                return Row(
                  mainAxisAlignment: widget.isCenter ? MainAxisAlignment.center : MainAxisAlignment.start,
                  children: widget.tabs!.asMap().keys.map((e) {
                    return _buildTabItem(e, value as int);
                  }).toList(),
                );
              }),
        ),
        Expanded(
            child: PageView(
          physics: ClampingScrollPhysics(),
          controller: _controller,
          children: widget.pages!.map<Widget>((page) => page).toList(),
        ))
      ],
    );
  }

  Widget _buildTabContent(int index, int currentValue) {
    if (widget.type == CgTabType.shuimo) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            bottom: 0,
            left: -5.w,
            child: LocalPNG(
              url: 'assets/images/tabsitem.png',
              alignment: Alignment.center,
              fit: BoxFit.fitWidth,
              width: 90.w,
              height: currentValue == index ? 9.w : 0,
            ),
          ),
          Text(
            widget.tabs![index],
            style: currentValue == index ? activeStyle : defaultStyle,
          )
        ],
      );
    } else {
      return Container(
        alignment: Alignment.center,
        height: 25.w,
        padding: EdgeInsets.symmetric(
          horizontal: widget.isFlex ? (widget.spacing ?? 15.w) : 15.w,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.5.w),
          color: index == currentValue ? Color(0xffff4149) : Colors.transparent,
        ),
        child: Text(
          widget.tabs![index],
          style: currentValue == index ? activeStyle : defaultStyle,
        ),
      );
    }
  }

  Widget _buildTabItem(int index, int currentValue) {
    final tabContent = widget.type == CgTabType.shuimo
        ? Center(child: _buildTabContent(index, currentValue))
        : _buildTabContent(index, currentValue);

    final inkWell = InkWell(
      onTap: () => _changeTap(index),
      child: tabContent,
    );

    if (widget.isFlex) {
      return Expanded(child: inkWell);
    } else {
      return Padding(
        padding: EdgeInsets.only(
          right: index == widget.tabs!.length - 1 ? 0 : widget.spacing ?? 20.w,
        ),
        child: inkWell,
      );
    }
  }
}
