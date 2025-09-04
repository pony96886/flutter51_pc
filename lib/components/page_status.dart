import 'package:bot_toast/bot_toast.dart';
import 'package:chaguaner2023/components/hint_page.dart';
import 'package:chaguaner2023/components/loading_gif.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PageStatus {
  static Function? showHintText(
    BuildContext context, {
    int time = 1000,
    int type = 1,
    String? text,
  }) {
    AppGlobal.overlayEntryIndex++;
    final int index = AppGlobal.overlayEntryIndex;
    AppGlobal.overlayEntry[index] =
        OverlayEntry(builder: (context) => HintPage(text: text, time: time, type: type, index: index));
    Overlay.of(context).insert(AppGlobal.overlayEntry[index]!);
    return null;
  }

  //全屏式loding
  static Function showLoading({String? text, int milliseconds = 200}) {
    return BotToast.showLoading(
        animationDuration: Duration(milliseconds: milliseconds),
        backgroundColor: Colors.black45,
        wrapToastAnimation: (AnimationController animation, fc, Widget child) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LoadingGif(
                width: 1.sw / 5,
              ),
              SizedBox(
                height: ScreenUtil().setWidth(15),
              ),
              Text(
                text == null ? '' : text,
                style: TextStyle(color: Colors.white, fontSize: 12.sp),
              )
            ],
          );
        });
  }

  //列表loding
  static Widget loading(bool mouted, {String? text}) {
    if (mouted) {
      return Container(
        alignment: Alignment.topCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 100.w),
            LoadingGif(
              width: 1.sw / 5,
            ),
            SizedBox(
              height: ScreenUtil().setWidth(15),
            ),
            Text(
              text == null ? '正在努力加载...' : text,
              // style: StyleTheme.lgray12,
            )
          ],
        ),
      );
    } else {
      return Container();
    }
  }

//关闭全屏式loading
  static void closeLoading() {
    return BotToast.closeAllLoading();
  }

//无数据
  static Widget noData({String? text}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(100)),
      alignment: Alignment.topCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LocalPNG(
            url: 'assets/images/empty-data.png',
            width: ScreenUtil().setWidth(100),
            height: ScreenUtil().setWidth(100),
          ),
          SizedBox(
            height: ScreenUtil().setWidth(9),
          ),
          Text(
            text == null ? '没有找到数据' : text,
            // style: StyleTheme.gray15,
          )
        ],
      ),
    );
  }

//网络错误
  static Widget noNetWork({String? text, Function? onTap}) {
    return InkWell(
      onTap: () {
        onTap!();
      },
      child: Container(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: EdgeInsets.only(top: ScreenUtil().setWidth(100)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LocalPNG(
                url: 'assets/images/default_netword.png',
                width: double.infinity,
                fit: BoxFit.fitWidth,
              ),
              SizedBox(
                height: ScreenUtil().setWidth(9),
              ),
              Text(
                text ?? '网络错误',
                // style: StyleTheme.gray15,
              ),
              SizedBox(
                height: ScreenUtil().setWidth(20),
              )
            ],
          ),
        ),
      ),
    );
  }
}
