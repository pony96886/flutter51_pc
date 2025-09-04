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
    defaultStyle = widget.defaultStyle ??
        TextStyle(
            fontSize: 14.sp,
            color: Color(0xff1e1e1e),
            fontWeight: FontWeight.w700);
    activeStyle = widget.activeStyle ??
        TextStyle(
            fontSize: 18.sp,
            color: Color(0xff1e1e1e),
            fontWeight: FontWeight.w700);
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
                  mainAxisAlignment: widget.isCenter
                      ? MainAxisAlignment.center
                      : MainAxisAlignment.start,
                  children: widget.tabs!.asMap().keys.map((e) {
                    if (widget.type == CgTabType.shuimo) {
                      return widget.isFlex
                          ? Expanded(
                              child: InkWell(
                              onTap: () {
                                _changeTap(e);
                              },
                              child: Center(
                                child: Stack(
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
                                          height: value == e ? 9.w : 0,
                                        )),
                                    Text(
                                      widget.tabs![e],
                                      style: value == e
                                          ? activeStyle
                                          : defaultStyle,
                                    )
                                  ],
                                ),
                              ),
                            ))
                          : Padding(
                              padding: EdgeInsets.only(
                                  right: e == widget.tabs!.length - 1
                                      ? 0
                                      : widget.spacing ?? 20.w),
                              child: InkWell(
                                  onTap: () {
                                    _changeTap(e);
                                  },
                                  child: Stack(
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
                                            height: value == e ? 9.w : 0,
                                          )),
                                      Text(
                                        widget.tabs![e],
                                        style: value == e
                                            ? activeStyle
                                            : defaultStyle,
                                      )
                                    ],
                                  )),
                            );
                    } else {
                      return widget.isFlex
                          ? Expanded(
                              child: InkWell(
                                  onTap: () {
                                    _changeTap(e);
                                  },
                                  child: Center(
                                    child: Container(
                                      alignment: Alignment.center,
                                      height: 25.w,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: widget.spacing ?? 15.w),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12.5.w),
                                          color: e == value
                                              ? Color(0xffff4149)
                                              : Colors.transparent),
                                      child: Text(
                                        widget.tabs![e],
                                        style: value == e
                                            ? activeStyle
                                            : defaultStyle,
                                      ),
                                    ),
                                  )))
                          : Padding(
                              padding: EdgeInsets.only(
                                  right: e == widget.tabs!.length - 1
                                      ? 0
                                      : widget.spacing ?? 20.w),
                              child: InkWell(
                                  onTap: () {
                                    _changeTap(e);
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    height: 25.w,
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 15.w),
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(12.5.w),
                                        color: e == value
                                            ? Color(0xffff4149)
                                            : Colors.transparent),
                                    child: Text(
                                      widget.tabs![e],
                                      style: value == e
                                          ? activeStyle
                                          : defaultStyle,
                                    ),
                                  )),
                            );
                    }
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
}
