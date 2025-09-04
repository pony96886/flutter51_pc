import 'package:chaguaner2023/components/tab/tab_nav_shuimo.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:flutter/material.dart';

class TabNav extends StatefulWidget {
  final bool? initTab;
  final Function? setTabState;
  final String? leftTitle;
  final bool? tabState;
  final String? rightTitle;
  final int? leftWidth;
  final int? rightWidth;
  final GestureTapCallback? leftTap;
  final GestureTapCallback? rightTap;
  final Widget? leftChild;
  final Widget? rightChild;
  final bool? isV4ui;
  final List<Widget>? v4Child;
  final List? v4Tabs;
  final double? tabWidth;
  final Function? callBack;

  const TabNav(
      {Key? key,
      this.isV4ui = false,
      this.v4Child,
      this.v4Tabs,
      this.leftTitle,
      this.rightTitle,
      this.leftWidth,
      this.rightWidth,
      this.leftTap,
      this.rightTap,
      this.leftChild,
      this.rightChild,
      this.tabState,
      this.setTabState,
      this.tabWidth,
      this.callBack,
      this.initTab = false})
      : super(key: key);
  @override
  State<StatefulWidget> createState() => TabNavPage();
}

class TabNavPage extends State<TabNav> with TickerProviderStateMixin {
  int _selectedTabIndex = 0;
  TabController? _tabController;
  tabadd() {
    if (!_tabController!.indexIsChanging) {
      widget.callBack?.call(_tabController?.index);

      _selectedTabIndex = _tabController!.index;

      setState(() {});
    }

    if (!_tabController!.indexIsChanging) {
      widget.setTabState!(_tabController?.index == 0);
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        vsync: this,
        length: widget.isV4ui! ? widget.v4Tabs!.length : 2,
        initialIndex: widget.initTab! ? 1 : 0);
    _tabController!.addListener(tabadd);
    if (widget.initTab!) {
      _selectedTabIndex = 1;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _tabController!.removeListener(tabadd);
    _tabController!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.isV4ui!
        ? //水墨风tag
        Expanded(
            child: Column(
            children: [
              Container(
                color: Colors.transparent,
                child: TabNavShuimo(
                  tabWidth: widget.tabWidth,
                  tabs: widget.v4Tabs,
                  tabController: _tabController,
                  selectedTabIndex: _selectedTabIndex,
                ).build(context),
              ),
              Expanded(
                child: Container(
                    height: double.infinity,
                    child: TabBarView(
                        controller: _tabController, children: widget.v4Child!)),
              )
            ],
          ))
        : //常见的左右tab
        Expanded(
            child: Column(
            children: [
              Container(
                color: Colors.red,
                child: TabNavShuimo(
                  tabWidth: widget.tabWidth,
                  isWidget: true,
                  tabState: _selectedTabIndex == 0,
                  leftTitle: widget.leftTitle,
                  rightTitle: widget.rightTitle,
                  leftWidth: widget.leftWidth,
                  rightWidth: widget.rightWidth,
                  rightTap: () {
                    FocusScope.of(AppGlobal.appContext!)
                        .requestFocus(FocusNode());
                    setState(() {
                      _tabController?.index = 1;
                    });
                    widget.setTabState?.call(false);
                  },
                  leftTap: () {
                    FocusScope.of(AppGlobal.appContext!)
                        .requestFocus(FocusNode());
                    setState(() {
                      _tabController?.index = 0;
                    });
                    widget.setTabState?.call(true);
                  },
                  tabController: _tabController,
                ).build(context),
              ),
              Expanded(
                child: Container(
                    height: double.infinity,
                    child: TabBarView(
                        controller: _tabController,
                        children: [widget.leftChild!, widget.rightChild!])),
              )
            ],
          ));
  }
}
