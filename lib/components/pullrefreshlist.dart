import 'dart:async';

import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class GifHeader extends RefreshIndicator {
  GifHeader()
      : super(
            height: ScreenUtil().setWidth(80),
            refreshStyle: RefreshStyle.Follow);
  @override
  State<StatefulWidget> createState() {
    return GifHeaderState();
  }
}

class GifHeaderState extends RefreshIndicatorState<GifHeader> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void onModeChange(RefreshStatus? mode) {
    if (mode == RefreshStatus.refreshing) {}
    super.onModeChange(mode);
  }

  @override
  Future<void> endRefresh() {
    return Future.delayed(new Duration(microseconds: 500), () {});
  }

  @override
  void resetValue() {
    super.resetValue();
  }

  static String gifImage = 'assets/images/downrefresh.gif';
  static String pnfImage = 'assets/images/downrefresh.png';
  @override
  Widget buildContent(BuildContext context, RefreshStatus mode) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: ScreenUtil().setWidth(15)),
      child: LocalPNG(
        url: mode == RefreshStatus.refreshing ? gifImage : pnfImage,
        height: ScreenUtil().setWidth(50),
        width: ScreenUtil().setWidth(50),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

// ignore: must_be_immutable
class PullRefreshList extends StatefulWidget {
  PullRefreshList(
      {Key? key,
      this.child,
      this.onRefresh,
      this.offset = 0,
      this.onLoading,
      this.color,
      this.isAll = false})
      : super(key: key);
  Widget? child;
  double? offset;
  Color? color;
  Function? onRefresh;
  Function? onLoading;
  bool isAll;
  @override
  _PullRefreshListState createState() => _PullRefreshListState();
}

class _PullRefreshListState extends State<PullRefreshList> {
  RefreshController? _refreshController;
  Timer? _timerout;
  Timer? _timer;
  bool startReq = false;
  @override
  void initState() {
    super.initState();
    _refreshController = RefreshController(initialRefresh: false);
  }

  @override
  void dispose() {
    super.dispose();
    _refreshController!.dispose();
    _timer?.cancel();
    _timerout?.cancel();
  }

  void _onRefresh() async {
    // 下拉刷新数据
    startReq = true;
    _timerout = Timer.periodic(Duration(seconds: 10), (time) {
      time.cancel();
      if (_timer!.isActive) {
        _timer?.cancel();
      }
      CommonUtils.showText('请求超时,请您检查网络');
      _refreshController!.refreshCompleted();
    });
    _timer = Timer.periodic(Duration(milliseconds: 1500), (time) {
      if (!startReq) {
        if (_timerout!.isActive) {
          _timerout!.cancel();
        }
        time.cancel();
        _refreshController!.refreshCompleted();
      }
    });
    await widget.onRefresh!();
    startReq = false;
  }

  void _onLoading() async {
    // 加载更多数据
    widget.onLoading!();
    _refreshController!.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      enablePullDown: widget.onRefresh != null,
      enablePullUp: widget.onLoading != null,
      header: WaterDropMaterialHeader(
        offset: widget.offset!,
        backgroundColor: widget.color ?? Color(0xffe43234),
      ),
      footer: CustomFooter(
        builder: (BuildContext? context, LoadStatus? mode) {
          Widget body;
          if (widget.isAll) {
            body = Text("没有更多数据");
          } else {
            if (mode == LoadStatus.idle) {
              body = Text("再拉一点");
            } else if (mode == LoadStatus.loading) {
              body = CupertinoActivityIndicator();
            } else if (mode == LoadStatus.failed) {
              body = Text("加载失败，点击重新加载");
            } else if (mode == LoadStatus.canLoading) {
              body = Text("松手加载更多数据");
            } else {
              body = Text("老兄，我已经在海底了，再拉跟你急了");
            }
          }

          return Container(
            height: 55.0,
            child: DefaultTextStyle(
                style: TextStyle(color: Color(0xff282828)),
                child: Center(child: body)),
          );
        },
      ),
      controller: _refreshController!,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      child: widget.child,
    );
  }
}
