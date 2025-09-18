import 'package:chaguaner2023/store/global.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../theme/style_theme.dart';
import '../view/yajian/datetime/src/date_format.dart';

class FilterTabsContainer extends StatefulWidget {
  final List? tabs;
  final int? selectTabIndex;
  final Function? onTabs;
  final bool? needLimit;
  final int? filter;
  final TextStyle? selectTabTextStyle;

  FilterTabsContainer(
      {Key? key,
      this.tabs,
      this.selectTabIndex,
      this.onTabs,
      this.needLimit = false,
      this.filter,
      this.selectTabTextStyle})
      : super(key: key);

  @override
  _FilterTabsContainerState createState() => _FilterTabsContainerState();
}

class _FilterTabsContainerState extends State<FilterTabsContainer> {
  int? index;

  @override
  void initState() {
    super.initState();
    index = widget.selectTabIndex;
  }

  onTapTabsItem(int vipValue, int e) {
    // if (widget.needLimit && vipValue == 0 && e == 1) {
    //   BotToast.showText(text: '只有会员才能使用智能排序', align: Alignment(0, 0));
    //   return;
    // }
    setState(() {
      index = e;
    });
    widget.onTabs!(e);
  }

  @override
  void didUpdateWidget(covariant FilterTabsContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectTabIndex != index) {
      index = widget.selectTabIndex;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    var vipValue;
    var profile = Provider.of<GlobalState>(context).profileData;
    if (["", null, false, 0].contains(profile)) {
      vipValue = 0;
    } else {
      vipValue = profile?['vip_level'];
    }
    return Container(
      child: Row(
        children: widget.tabs!.asMap().keys.map((e) {
          if (widget.filter == null) {
            return TabsItem(
              title: widget.tabs![e]['title'] ?? widget.tabs![e]['name'],
              index: index!,
              keys: e,
              selectTabTextStyle: widget.selectTabTextStyle,
              onTap: () {
                onTapTabsItem(vipValue, e);
              },
            );
          } else {
            return widget.tabs![e]['type'] == widget.filter || widget.tabs![e]['type'] == null
                ? TabsItem(
                    title: widget.tabs![e]['title'] ?? widget.tabs![e]['name'],
                    index: index!,
                    keys: e,
                    selectTabTextStyle: widget.selectTabTextStyle,
                    onTap: () {
                      onTapTabsItem(vipValue, e);
                    },
                  )
                : const SizedBox();
          }
        }).toList(),
      ),
    );
  }
}

class TabsItem extends StatelessWidget {
  final String? title;
  final int? index;
  final int? keys;
  final GestureTapCallback? onTap;
  final TextStyle? selectTabTextStyle;

  TabsItem({Key? key, this.title, this.index, this.onTap, this.keys, this.selectTabTextStyle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(right: 21.5.w),
        child: Stack(
          children: <Widget>[
            Positioned(
                top: 0,
                right: 0,
                child: index == keys
                    ? Opacity(
                        opacity: 0.8,
                        child: Container(
                          width: 12.w,
                          height: 12.w,
                          decoration:
                              BoxDecoration(color: StyleTheme.cDangerColor, borderRadius: BorderRadius.circular(10)),
                        ),
                      )
                    : SizedBox()),
            Text("$title",
                style: index == keys
                    ? (selectTabTextStyle ??
                        TextStyle(color: Color(0xff646464), fontSize: 12.sp, fontWeight: FontWeight.w700))
                    : TextStyle(color: Color(0xff646464), fontSize: 12.sp)),
          ],
        ),
      ),
    );
  }
}
