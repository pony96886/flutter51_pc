import 'dart:async';
import 'package:chaguaner2023/components/page_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

typedef AlphaChanged = void Function(String alpha);
typedef OnTouchStart = void Function();
typedef OnTouchMove = void Function();
typedef OnTouchEnd = void Function();

class LetterPicker extends StatefulWidget {
  final Function? headHeigh;
  final List<PickersContent>? contentList;
  final Color backgroundColor;
  const LetterPicker(
      {Key? key,
      this.headHeigh,
      this.contentList,
      this.backgroundColor = Colors.white})
      : super(key: key);

  @override
  State<LetterPicker> createState() => _LetterPickerState();
}

class _LetterPickerState extends State<LetterPicker> {
  // 加载中
  bool loading = false;
  Timer? _changeTimer;
  bool _isTouchTagBar = false;
  double letterItemSize = ScreenUtil().setSp(12);
  String? _tagName;
  Map fromTop = {};
  List letters = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.contentList!.forEach((item) {
      letters.add(item.letter);
      item.key = GlobalKey();
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      widget.contentList!.forEach((item) {
        RenderBox? renderBox =
            item.key!.currentContext!.findRenderObject() as RenderBox;
        Offset positions = renderBox.localToGlobal(Offset(0, 0));
        fromTop[item.letter] = {
          'height': renderBox.size.height,
          'top': positions.dy - widget.headHeigh!()
        };
      });
    });
  }

  // 获取首字母
// PinyinHelper.getFirstWordPinyin(cityList[i].name).substring(0, 1)

  _onTagChange(String alpha) {
    if (fromTop[alpha] != null) {
      if (_scrollController.position.maxScrollExtent <
              (fromTop[alpha]['top'] + fromTop[alpha]['height']) &&
          fromTop[alpha]['top'] != 0) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      } else {
        _scrollController.jumpTo(fromTop[alpha]['top']);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.backgroundColor,
      body: Column(
        children: [
          SizedBox(
            height: widget.headHeigh == null ? 0 : widget.headHeigh!(),
          ),
          Expanded(child: loading ? PageStatus.loading(true) : ContentBox())
        ],
      ),
    );
  }

  /// 全部城市列表
  Widget ContentBox() {
    Widget tempWidget = Text(
      '暂无数据',
      style: TextStyle(color: Color(0xfff9f9f9)),
      textAlign: TextAlign.center,
    ); // 判定是否有数据
    Widget tempTouchBar = const SizedBox(); // 判定操作列表
    tempWidget = CustomScrollView(
      controller: _scrollController,
      slivers: widget.contentList!.asMap().keys.map((e) {
        return SliverToBoxAdapter(
          child: Container(
            key: widget.contentList![e].key,
            child: widget.contentList![e].content,
          ),
        );
      }).toList(),
    );
    if (_isTouchTagBar) {
      tempTouchBar = Center(
        child: Card(
          color: Colors.black38,
          child: Container(
            alignment: Alignment.center,
            width: 80.0,
            height: 80.0,
            child: Text(
              _tagName!,
              style: const TextStyle(
                fontSize: 32.0,
                color: Color(0xfff9f9f9),
              ),
            ),
          ),
        ),
      );
    }
    return Stack(
      children: <Widget>[
        tempWidget,
        tempTouchBar,
        Positioned(
          top: 20.w,
          right: 0,
          bottom: 0,
          child: Alpha(
            alphas: letters,
            alphaItemSize: letterItemSize,
            onTouchStart: () {
              setState(() {
                _isTouchTagBar = true;
              });
            },
            onTouchEnd: () {
              setState(() {
                _isTouchTagBar = false;
              });
            },
            onAlphaChange: (String alpha) {
              setState(() {
                if (!_isTouchTagBar) {
                  _isTouchTagBar = true;
                }
                _tagName = alpha;
              });
              // _initOffsetRangList();
              _onTagChange(alpha);
            },
          ),
        )
      ],
    );
  }
}

class Alpha extends StatefulWidget {
  /// 单个字母的字体大小
  final double? alphaItemSize;
  final List? alphas;

  /// 当选中的字母发生改变
  final AlphaChanged? onAlphaChange;

  final OnTouchStart? onTouchStart;
  final OnTouchMove? onTouchMove;
  final OnTouchEnd? onTouchEnd;

  /// 激活状态下的背景色
  final Color activeBgColor;

  /// 未激活状态下的背景色
  final Color bgColor;

  /// 未激活状态下字体的颜色
  final Color fontColor;

  /// 激活状态下字体的颜色
  final Color fontActiveColor;

  ///字母上下pading
  final double pyPading;

  /// 单个字母的上下pading;
  final double alphaPading;

  const Alpha(
      {Key? key,
      @required this.alphaItemSize,

      /// 可供选择的字母集
      @required this.alphas,

      /// 当右侧字母集, 因触摸而产生的回调
      this.onAlphaChange,
      this.onTouchStart,
      this.onTouchMove,
      this.onTouchEnd,
      this.activeBgColor = Colors.transparent,
      this.bgColor = Colors.transparent,
      this.fontColor = Colors.black,
      this.fontActiveColor = Colors.red,
      this.pyPading = 8,
      this.alphaPading = 4})
      : super(key: key);

  @override
  AlphaState createState() {
    return AlphaState();
  }
}

class AlphaState extends State<Alpha> {
//  Timer _changeTimer;

  bool isTouched = false;

  List<double> indexRange = [];

  // 当触摸结束前, 最后一个字母;
  String? _lastTag;

  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() {
    List alphas = widget.alphas!;
    for (int i = 0; i <= alphas.length; i++) {
      indexRange.add((i) * widget.alphaItemSize!);
    }
  }

  String? _getHitAlpha(offset) {
    int hit = offset;
    if (hit < 0) {
      return null;
    }
    if (hit >= widget.alphas!.length) {
      return null;
    }
    return widget.alphas![hit];
  }

  _onAlphaChange([String? tag]) {
    if (tag != _lastTag) {
      _lastTag = tag;
      widget.onAlphaChange!(tag!);
    }
  }

  _touchStartEvent(String tag) {
    setState(() {
      isTouched = true;
    });
    _onAlphaChange(tag);

    widget.onTouchStart!();
  }

  _touchMoveEvent(String tag) {
    _onAlphaChange(tag);
    widget.onTouchMove!();
  }

  _touchEndEvent() {
    setState(() {
      isTouched = false;
    });
    // 这里本可以不用再触发一次的. 但是为了数据的准备, 最后再触发一次
    _onAlphaChange(_lastTag);
    widget.onTouchEnd!();
  }

  _buildAlpha() {
    List<Widget> result = [];
    for (var alpha in widget.alphas!) {
      result.add(Padding(
        padding:
            EdgeInsets.symmetric(horizontal: 0.w, vertical: widget.alphaPading),
        child: SizedBox(
          key: Key(alpha),
          height: widget.alphaItemSize,
          child: Text(
            alpha,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: widget.alphaItemSize, color: Color(0xff282828)),
          ),
        ),
      ));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 31.w,
          padding: EdgeInsets.symmetric(vertical: widget.pyPading),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: result,
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onVerticalDragDown: (DragDownDetails details) {
        int touchOffset2Begin = ((details.localPosition.dy - widget.pyPading) /
                (widget.alphaItemSize! + (widget.alphaPading * 2)))
            .truncate();
        String? tag = _getHitAlpha(touchOffset2Begin);
        _touchStartEvent(tag!);
      },
      onVerticalDragUpdate: (DragUpdateDetails details) {
        int touchOffset2Begin = ((details.localPosition.dy - widget.pyPading) /
                (widget.alphaItemSize! + (widget.alphaPading * 2)))
            .truncate();
        String? tag = _getHitAlpha(touchOffset2Begin);
        _touchMoveEvent(tag!);
      },
      onVerticalDragEnd: (DragEndDetails details) {
        _touchEndEvent();
      },
      child: _buildAlpha(),
    );
  }
}

class PickersContent {
  PickersContent({
    @required this.letter,
    @required this.content,
    this.key,
  });

  String? letter;
  Widget? content;
  GlobalKey? key;

  factory PickersContent.fromJson(Map<String, dynamic> json) => PickersContent(
        letter: json["letter"] ?? '',
        content: json["content"] ?? '',
        key: json["key"] ?? null,
      );

  Map<String, dynamic> toJson() => {
        "letter": letter,
        "content": content,
        "fromTop": key,
      };
}
