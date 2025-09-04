import 'package:chaguaner2023/components/LoadingLayout.dart';
import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/nodata.dart';
import 'package:chaguaner2023/components/pagetitlebar.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PromotionRecordPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => PromotionRecordPageState();
}

class PromotionRecordPageState extends State<PromotionRecordPage> {
  int _allNumber = 0;
  bool loadmore = true;
  int _page = 1;
  int _limit = 10;
  int _regNumber = 0;
  bool isAll = false;
  List _words = [];
  LoadState _layoutState = LoadState.State_Loading;

  Future getInvition(_page, _limit) async {
    var result = await getListInvition(_page, _limit);
    if (result!['status'] == 1) {
      if (_page == 1) {
        if (result['data']['list'] == null ||
            result['data']['list'].length == 0) {
          setState(() {
            _layoutState = LoadState.State_Empty;
            _words = [];
            loadmore = false;
            _page = 1;
          });
          return;
        }
        setState(() {
          isAll = (result['data']['list'] == null ||
              result['data']['list'].length < _limit);
          _words = result['data']['list'];
          _allNumber = result['data']['count']['all_num'];
          _regNumber = result['data']['count']['reg_num'];
          _layoutState = LoadState.State_Success;
          loadmore = true;
        });
      } else {
        isAll = (result['data']['list'] == null ||
            result['data']['list'].length < _limit);
        _words.addAll(result['data']['list']);
        _allNumber = result['data']['count']['all_num'];
        _regNumber = result['data']['count']['reg_num'];
        _layoutState = LoadState.State_Success;
        loadmore = true;
        setState(() {});
      }
    } else {
      if (result == null) {
        setState(() {
          _layoutState = LoadState.State_Error;
          _words = [];
          _page = 1;
        });
      } else {
        BotToast.showText(text: result['msg']);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getInvition(_page, _limit);
  }

  @override
  Widget build(BuildContext context) {
    return HeaderContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
            child: PageTitleBar(
              title: '推广记录',
            ),
            preferredSize: Size(double.infinity, 44.w)),
        body: LoadStateLayout(
            state: _layoutState,
            emptyTips: "没有推广记录",
            errorRetry: () {
              setState(() {
                _layoutState = LoadState.State_Loading;
              });
              getInvition(_page, _limit);
            },
            successWidget: SafeArea(
              child: Column(
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    padding: new EdgeInsets.only(
                        top: 10.5.sp, bottom: 10.5.sp, left: 15.5.sp),
                    color: Color(0xFFF5F5F5),
                    child: Text(
                      '累计邀请用户 $_allNumber 人, 注册成功的用户 $_regNumber 人',
                      style: TextStyle(
                          fontSize: 14.sp, color: StyleTheme.cTitleColor),
                    ),
                  ),
                  _recordList()
                ],
              ),
            )),
      ),
    );
  }

  _onScrollNotification(ScrollNotification scrollInfo) {
    if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
      //滑到了底部
      if (loadmore) {
        if (!isAll) {
          loadmore = false;
          _page++;
          getInvition(_page, _limit);
        }
      }
    }
  }

  Widget _recordList() {
    return NotificationListener<ScrollNotification>(
      child: _words.length == 0
          ? NoData()
          : Expanded(
              child: ListView.separated(
                padding: EdgeInsets.only(
                  left: 14.5.sp,
                  right: 14.5.sp,
                ),
                itemCount: _words.length,
                itemBuilder: (context, index) {
                  //显示单词列表项
                  return RecordItem(
                    nickname: _words[index]['nickname'].toString(),
                    created: _words[index]['created_at'].toString(),
                    register: _words[index]['register'].toString(),
                  );
                },
                separatorBuilder: (context, idnex) => Divider(height: .1),
              ),
            ),
      onNotification: (ScrollNotification scrollInfo) =>
          _onScrollNotification(scrollInfo),
    );
  }
}

class RecordItem extends StatelessWidget {
  final String? nickname;
  final String? created;
  final String? register;
  const RecordItem({Key? key, this.nickname, this.created, this.register})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var times =
        new DateTime.fromMillisecondsSinceEpoch(int.parse(created!) * 1000);
    String _createdtime =
        '${times.year}-${times.month}-${times.day} ${times.hour}:${times.minute}';

    return Container(
      height: 80.5.w,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                nickname!,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: StyleTheme.cTitleColor,
                ),
              ),
              Text(
                _createdtime,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: StyleTheme.cBioColor,
                ),
              )
            ],
          ),
          Text(
            register!,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: register == "未注册"
                  ? StyleTheme.cDangerColor
                  : StyleTheme.cBioColor,
            ),
          ),
        ],
      ),
    );
  }
}
