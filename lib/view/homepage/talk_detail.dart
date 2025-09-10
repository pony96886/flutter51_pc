import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/loading.dart';
import 'package:chaguaner2023/components/page_title_bar.dart';
import 'package:chaguaner2023/store/homeConfig.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/yy_toast.dart';
import 'package:chaguaner2023/view/homepage/Template.dart';
import 'package:chaguaner2023/components/avatar_widget.dart';


class TackDetailPage extends StatefulWidget {
  final String? id;
  final bool isAds;
  TackDetailPage({Key? key, this.id, this.isAds = false}) : super(key: key);
  @override
  State<StatefulWidget> createState() => TackDetailState();
}

class TackDetailState extends State<TackDetailPage> {
  bool networkErr = false;
  Map? _tackDetai;
  String repId = '';
  bool loading = true;
  List setContentList = [];
  String? imagePath = '';
  String hintString = '请输入评论...';
  TextEditingController editingController = TextEditingController();

  getTackDetail() async {
    setState(() {
      networkErr = false;
    });
    var content = await gettalkDetail(int.parse(widget.id!));
    if (content['data'] != null && content['status'] != 0) {
      setState(() {
        _tackDetai = content['data'];
        if (_tackDetai!['content'].indexOf("*") > -1) {
          var setContent = _tackDetai!['content'].substring(
              _tackDetai!['content'].indexOf('*') + 1,
              _tackDetai!['content'].lastIndexOf('*'));
          setContent = setContent.trim();
          setContentList = setContent.split("</a>");
        }

        loading = false;
      });
    } else {
      setState(() {
        networkErr = true;
      });
      return;
    }
  }

  setContent(val) {
    var setVal = val;
    if (val.indexOf('*') > -1) {
      setVal = val.substring(0, val.indexOf('*'));
    }

    return setVal;
  }

  @override
  void initState() {
    super.initState();
    getTackDetail();
  }

  static getTime(int time) {
    setTime(int _num) {
      return _num < 10 ? '0' + _num.toString() : _num;
    }

    var times = new DateTime.fromMillisecondsSinceEpoch(time * 1000);
    dynamic monthC = setTime(times.month);
    dynamic dayC = setTime(times.day);
    dynamic hourC = setTime(times.hour);
    dynamic minuteC = setTime(times.minute);
    String cTime = '${times.year}-$monthC-$dayC $hourC:$minuteC';
    return '$cTime';
  }

  reviseTitle(val) {
    List _l = val.trim().split("<a>");
    return _l.length > 1 ? _l[1] : '';
  }

  Widget buildGrid() {
    List<Widget> tiles = [];
    Widget content;
    String zzss = r'[\u4e00-\u9fa5]+';
    RegExp rePla = new RegExp(zzss);
    if (setContentList.length > 0) {
      for (var item in setContentList) {
        if (item != '') {
          tiles.add(GestureDetector(
            onTap: () {
              String result = reviseTitle(item).replaceAll(rePla, '');
              result = result.replaceAll(":", '');
              result = result.replaceAll("：", '');
              Clipboard.setData(ClipboardData(text: result));
              YyToast.successToast('复制成功！', gravity: ToastGravity.CENTER);
            },
            child: Row(
              children: [
                Text(reviseTitle(item)),
                SizedBox(
                  width: 2.5.w,
                ),
                Text(
                  '复制',
                  style: TextStyle(color: StyleTheme.cDangerColor),
                ),
              ],
            ),
          ));
        }
      }
    }
    content = new Column(
        children: tiles //重点在这里，因为用编辑器写Column生成的children后面会跟一个<Widget>[]，
        //此时如果我们直接把生成的tiles放在<Widget>[]中是会报一个类型不匹配的错误，把<Widget>[]删了就可以了
        );
    return content;
  }

  _sendMsg() async {
    var text = editingController.text.trim();
    if (text.isNotEmpty) {
      var result = await talkComment(int.parse(widget.id!), text, repId);

      if (result!.status == 1) {
        setState(() {
          repId = '';
          editingController.text = '';
          hintString = '请输入评论...';
        });
        BotToast.showText(text: "提交成功，审核后将会显示", align: Alignment(0, 0));
      } else {
        CommonUtils.showText(result.msg!);
      }
    }
  }

  _replyComment(id, name) {
    setState(() {
      repId = id.toString();
      hintString = '回复@$name ';
    });
    FocusScope.of(context).requestFocus(FocusNode());
    Future.delayed(const Duration(milliseconds: 100), () {
      FocusScope.of(context).requestFocus(FocusNode());
    });
  }

  onFavoriteTalk() async {
    String collectStr = '收藏成功';
    String cancleColStr = '取消收藏成功';
    var result = await talkFavorite(widget.id!);
    if (result != null && result['status'] == 1) {
      setState(() {
        if (result!['data']['is_favorite'] == 1) {
          _tackDetai!['is_favorite'] = true;
          _tackDetai!['favorite_count'] = (_tackDetai!['favorite_count'] + 1);
        } else {
          _tackDetai!['is_favorite'] = false;
          _tackDetai!['favorite_count'] = (_tackDetai!['favorite_count'] - 1);
        }
      });
      BotToast.showText(
          text: result!['data']['is_favorite'] == 1 ? collectStr : cancleColStr,
          align: Alignment(0, 0));
    } else {
      CommonUtils.showText(result['msg']);
    }
  }

  @override
  Widget build(BuildContext context) {
    imagePath = Provider.of<HomeConfig>(context).config.imgBase;
    String adDetail = '广告详情';
    return HeaderContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
            child: PageTitleBar(
              title: widget.isAds ? adDetail : '',
            ),
            preferredSize: Size(double.infinity, 44.w)),
        body: loading
            ? Loading()
            : Container(
                child: Column(
                  children: [
                    widget.isAds
                        ? Container(
                            width: double.infinity,
                            decoration: BoxDecoration(color: Color(0xfffbf0e5)),
                            padding: EdgeInsets.all(5.w),
                            child: Center(
                              child: Text(
                                "广告信息非平台提供，请您仔细甄别谨慎消费",
                                style: TextStyle(
                                    color: Color(0xffec5251), fontSize: 12.sp),
                              ),
                            ),
                          )
                        : Container(),
                    Container(
                      padding: new EdgeInsets.only(left: 16.w, right: 16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                  child: Text(
                                _tackDetai!['title'],
                                style: TextStyle(
                                    fontSize: 20.w,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF323232),
                                    height: 1.5),
                              )),
                            ],
                          ),
                          Container(
                              height: 50.5.w,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: StyleTheme.textbgColor1,
                                        width: 1.w,
                                        style: BorderStyle.solid)),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                      _tackDetai!['created_at'] != null
                                          ? getTime(int.parse(
                                              _tackDetai!['created_at']
                                                  .toString()))
                                          : '',
                                      style: TextStyle(
                                        fontSize: 14.w,
                                        color: StyleTheme.cBioColor,
                                      )),
                                ],
                              ))
                        ],
                      ),
                    ),
                    Expanded(
                        child: ListView(
                      shrinkWrap: true,
                      padding: new EdgeInsets.only(
                          left: 15.w,
                          right: 15.w,
                          top: 15.w,
                          bottom: 20.w + ScreenUtil().statusBarHeight),
                      children: [
                        Template(
                            html: setContent(_tackDetai!['content']),
                            title: _tackDetai!['title'],
                            imagePath: imagePath!),
                        buildGrid(),
                        SizedBox(
                          height: 10.w,
                        ),
                        Divider(
                            height: 1.w,
                            color: Color.fromARGB(255, 174, 174, 174)),
                        SizedBox(
                          height: 10.w,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconAndText(
                              icons: _tackDetai!['is_favorite']
                                  ? 'assets/images/card/iscollect.png'
                                  : 'assets/images/detail/collo.png',
                              text: _tackDetai!['favorite_count']?.toString() ??
                                  '0',
                              onTap: () {
                                onFavoriteTalk();
                              },
                            ),
                            IconAndText(
                              icons: 'assets/images/detail/share.png',
                              text: '分享',
                              onTap: () {
                                AppGlobal.appRouter?.push(
                                    CommonUtils.getRealHash('shareQRCodePage'));
                              },
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20.w,
                        ),
                        TalkCommentList(
                            id: widget.id, onReplyComment: _replyComment),
                      ],
                    )),
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(width: 1, color: Color(0xFFEEEEEE)),
                        ),
                      ),
                      height: ScreenUtil().bottomBarHeight + 45.w,
                      padding: new EdgeInsets.only(
                        left: 15.w,
                        right: 15.w,
                      ),
                      child: Container(
                        margin: new EdgeInsets.only(
                            bottom: ScreenUtil().bottomBarHeight),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 35.w,
                                margin: EdgeInsets.only(left: 10.w),
                                decoration: BoxDecoration(
                                    color: StyleTheme.bottomappbarColor,
                                    borderRadius:
                                        BorderRadius.circular(17.5.w)),
                                child: Center(
                                  child: TextField(
                                    controller: editingController,
                                    decoration: InputDecoration(
                                        isDense: true,
                                        contentPadding: EdgeInsets.only(
                                            left: 10,
                                            right: 10,
                                            top: 5,
                                            bottom: 5),
                                        border: InputBorder.none,
                                        hintStyle: TextStyle(
                                            color: StyleTheme.cBioColor,
                                            fontSize: 16.sp),
                                        hintText: hintString),
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                                onTap: _sendMsg,
                                child: Container(
                                  margin: new EdgeInsets.only(left: 15.w),
                                  width: 55.w,
                                  height: 30.w,
                                  decoration: BoxDecoration(
                                      color: StyleTheme.cDangerColor,
                                      borderRadius: BorderRadius.circular(5.w)),
                                  child: Center(
                                    child: Text(
                                      '发送',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 14.sp),
                                    ),
                                  ),
                                ))
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
      ),
    );
  }
}

class IconAndText extends StatelessWidget {
  final String icons;
  final String text;
  final void Function()? onTap;
  const IconAndText(
      {Key? key, required this.icons, required this.text, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            icons,
            height: 25.w,
          ),
          SizedBox(width: 5.w),
          Text(
            text,
            style: TextStyle(color: Color(0xff1e1e1e), fontSize: 14.sp),
          ),
        ],
      ),
    );
  }
}

class TalkCommentList extends StatefulWidget {
  final String? id;
  final Function? onReplyComment;
  const TalkCommentList({Key? key, this.id, this.onReplyComment})
      : super(key: key);

  @override
  State<TalkCommentList> createState() => _TalkCommentListState();
}

class _TalkCommentListState extends State<TalkCommentList> {
  final ScrollController _scrollController = ScrollController();

  final List _commentList = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _page = 1;
  final int _limit = 20;

  @override
  void initState() {
    super.initState();
    _getCommentList(refresh: true);

    _scrollController.addListener(() {
      final position = _scrollController.position;
      if (_hasMore &&
          !_isLoading &&
          position.pixels >= position.maxScrollExtent - 200) {
        _page += 1;
        _getCommentList();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _getCommentList({bool refresh = false}) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    if (refresh) {
      _page = 1;
      _hasMore = true;
    }

    final result = await talkCommentList(
      id: int.parse(widget.id!),
      page: _page,
      limit: _limit,
    );

    if (!mounted) return;

    if (result != null && result['status'] == 1) {
      final List data = (result['data'] as List?) ?? [];

      setState(() {
        if (refresh) _commentList.clear();

        _commentList.addAll(data);

        _hasMore = data.length >= _limit;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      CommonUtils.showText(result?['msg'] ?? '加载失败');
    }
  }

  Widget _buildFooter() {
    if (_commentList.isEmpty && !_isLoading) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 40.w),
        child: Center(
          child: Text('暂无评论',
              style: TextStyle(color: Colors.grey, fontSize: 12.sp)),
        ),
      );
    }

    if (_isLoading) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 16.w),
        child: const Center(
            child: SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(strokeWidth: 2))),
      );
    }

    if (!_hasMore) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 16.w),
        child: Center(
          child: Text('没有更多了',
              style: TextStyle(color: Colors.grey, fontSize: 12.sp)),
        ),
      );
    }

    return SizedBox(height: 0); // 初始时不显示
  }

  Widget _buildCommentItem(dynamic item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          CircleAvatar(
            radius: 20.w,
            backgroundColor: Colors.grey[400],
            child: Avatar(type: item['thumb']),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(item['user']['nickname'] ?? '匿名用户',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14.sp)),
              ]),
              SizedBox(height: 3.w),
              Text(item['content'] ?? '', style: TextStyle(fontSize: 13.sp)),
              SizedBox(height: 5.w),
              Row(children: [
                Icon(Icons.location_on, size: 14.w, color: Colors.grey),
                SizedBox(width: 3.w),
                Text(
                  CommonUtils.getCgTime(
                          int.parse(item['created_at'].toString())) +
                      ' 发布' +
                      "  ${item['city_str'] ?? ''}",
                  style: TextStyle(fontSize: 11.sp, color: Colors.grey),
                ),
                const Spacer(),
                InkWell(
                  onTap: () {
                    if (widget.onReplyComment != null) {
                      widget.onReplyComment!(
                          item['id'], item['user']['nickname']);
                    }
                  },
                  child: Row(children: [
                    Icon(Icons.reply, size: 14.w, color: Colors.grey),
                    SizedBox(width: 3.w),
                    Text('回复',
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
                  ]),
                ),
              ]),
            ]),
          ),
        ]),
        SizedBox(height: 8.w),
        if (item['child'] != null && item['child'].isNotEmpty)
          Container(
            padding: EdgeInsets.all(8.w),
            margin: EdgeInsets.only(left: 50.w),
            decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(6.r)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(item['child'].length, (i) {
                final reply = item['child'][i];
                return Padding(
                  padding: EdgeInsets.only(
                      bottom: i == item['child'].length - 1 ? 0 : 6.w),
                  child: RichText(
                    text: TextSpan(children: [
                      TextSpan(
                          text: "${reply['user']['nickname'] ?? '匿名'}: ",
                          style: TextStyle(fontSize: 12.sp)),
                      if (item!['aff'] == reply['aff'])
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Align(
                            alignment: Alignment.center,
                            widthFactor: 1,
                            heightFactor: 1,
                            child: CommonUtils.authorWidget(),
                          ),
                        ),
                      TextSpan(
                          text: reply['content'] ?? '',
                          style: TextStyle(
                              color: Colors.black87, fontSize: 12.sp)),
                    ]),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => _getCommentList(refresh: true),
      child: ListView.separated(
        controller: _scrollController,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: _commentList.length + 1,
        separatorBuilder: (_, __) =>
            Divider(color: Colors.transparent, height: 15.w),
        itemBuilder: (context, index) {
          if (index == _commentList.length) return _buildFooter();
          final item = _commentList[index];
          return _buildCommentItem(item);
        },
      ),
    );
  }
}
