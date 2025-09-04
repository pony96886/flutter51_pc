import 'package:chaguaner2023/utils/local_png.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:pull_to_refresh_notification/pull_to_refresh_notification.dart';

class PullRreshAppBar {
  Function getBuilder(
      List<Widget> customChildren,
      PreferredSizeWidget bottom,
      AnimationController _lottieController,
      double headerHeight,
      double tabBarHeight,
      {double offsetvalue = 200}) {
    return (PullToRefreshScrollNotificationInfo info) {
      double offset = info.dragOffset ?? 0.0;
      List<Widget> backgroundWidgets = [];
      backgroundWidgets.add(Lottie.asset(
        'assets/lottie/pull_refresh/data.json',
        width: double.infinity,
        height: offset - 10.w,
        fit: BoxFit.contain,
        controller: _lottieController,
        onLoaded: (composition) {
          _lottieController..duration = composition.duration;
          _lottieController.stop();
        },
      ));
      backgroundWidgets.addAll(customChildren);
      return SliverAppBar(
        pinned: true,
        floating: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: Text(''),
        expandedHeight: headerHeight + offset,
        actions: <Widget>[],
        flexibleSpace: FlexibleSpaceBar(
          collapseMode: CollapseMode.pin,
          background: Stack(
            children: [
              LocalPNG(
                width: double.infinity,
                height: double.infinity,
                alignment:
                    Alignment(-offset / offsetvalue, -offset / offsetvalue),
                fit: BoxFit.fitWidth,
                url: "assets/images/appbg2.png",
              ),
              Container(
                width: double.infinity,
                height: double.infinity,
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: backgroundWidgets,
                  ),
                  margin: EdgeInsets.only(bottom: tabBarHeight),
                ),
              ),
            ],
          ),
        ),
        bottom: bottom,
      );
    };
  }
}
