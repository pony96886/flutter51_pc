//四种视图状态
import 'package:chaguaner2023/components/loading_gif.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum LoadState { State_Success, State_Error, State_Loading, State_Empty }

///根据不同状态来展示不同的视图
class LoadStateLayout extends StatefulWidget {
  final LoadState? state; //页面状态
  final Widget? successWidget; //成功视图
  final VoidCallback? errorRetry; //错误事件处理
  final VoidCallback? emptyRetry; //空数据事件处理
  final String? emptyTips;

  LoadStateLayout(
      {Key? key,
      this.state = LoadState.State_Loading, //默认为加载状态
      this.successWidget,
      this.errorRetry,
      this.emptyRetry,
      this.emptyTips})
      : super(key: key);

  @override
  _LoadStateLayoutState createState() => _LoadStateLayoutState();
}

class _LoadStateLayoutState extends State<LoadStateLayout> {
  @override
  Widget build(BuildContext context) {
    return Container(
      //宽高都充满屏幕剩余空间
      width: double.infinity,
      height: double.infinity,
      child: _buildWidget,
    );
  }

  ///根据不同状态来显示不同的视图
  Widget? get _buildWidget {
    switch (widget.state) {
      case LoadState.State_Success:
        return widget.successWidget;
      case LoadState.State_Error:
        return _errorView;
      case LoadState.State_Loading:
        return _loadingView;
      case LoadState.State_Empty:
        return NoDataView(
            emptyRetry: widget.emptyRetry, emptyTips: widget.emptyTips);
      default:
        return null;
    }
  }

  ///加载中视图
  Widget get _loadingView {
    return Container(
      width: double.infinity,
      height: double.infinity,
      alignment: Alignment.center,
      color: Colors.white,
      child: Container(
        height: 170.w,
        padding: EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            LoadingGif(
              width: 1.sw / 5,
            ),
            Padding(
              padding: new EdgeInsets.symmetric(vertical: 10.w),
              child: Text(
                '数据加载中',
                style: TextStyle(fontSize: 14.sp, color: StyleTheme.cBioColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ///错误视图
  Widget get _errorView {
    return Container(
        width: double.infinity,
        height: double.infinity,
        child: InkWell(
          onTap: widget.errorRetry,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 150.w,
                height: 150.w,
                child: LocalPNG(url: 'assets/images/default_netword.png'),
              ),
              Text(
                "网络出现问题",
                style: TextStyle(color: StyleTheme.cBioColor, fontSize: 14.sp),
              ),
              SizedBox(height: 10.w),
              Text(
                '点击重试',
                style:
                    TextStyle(color: StyleTheme.cDangerColor, fontSize: 12.sp),
              )
            ],
          ),
        ));
  }
}

class NoDataView extends StatefulWidget {
  final String? emptyTips; //无数据提示
  final VoidCallback? emptyRetry; //无数据事件处理

  NoDataView({this.emptyRetry, this.emptyTips});

  @override
  _NoDataViewState createState() => _NoDataViewState();
}

class _NoDataViewState extends State<NoDataView> {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        height: double.infinity,
        child: InkWell(
          onTap: widget.emptyRetry,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 150.w,
                height: 150.w,
                child: LocalPNG(url: 'assets/images/empty-data.png'),
              ),
              Text(
                widget.emptyTips ?? "暂无相关数据",
                style: TextStyle(color: StyleTheme.cBioColor, fontSize: 12.sp),
              )
            ],
          ),
        ));
  }
}
