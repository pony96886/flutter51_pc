import 'dart:convert';

import 'package:bot_toast/bot_toast.dart';
import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/loading.dart';
import 'package:chaguaner2023/components/networkErr.dart';
import 'package:chaguaner2023/components/pagetitlebar.dart';
import 'package:chaguaner2023/store/homeConfig.dart';
import 'package:chaguaner2023/store/sharedPreferences.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:chaguaner2023/utils/netimage_tool.dart';
import 'package:chaguaner2023/utils/yy_toast.dart';
import 'package:chaguaner2023/view/homepage/online_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';

class GamePage extends StatefulWidget {
  GamePage({Key? key}) : super(key: key);

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  // TextEditingController _numberController = TextEditingController();
  // TextEditingController _nameController = TextEditingController();
  List? menuList;
  List? hotGame;
  List? moreGame;
  bool loading = true;
  bool networkErr = false;
  int sConin = 0;
  String? tips;
  List historyList = [];
  String intoGStr = '进入大厅';
  intpage() async {
    await rechargeValue().then((res) {
      if (res == null) {
        CommonUtils.showText('请检查网络后重试');
        return;
      }
      if (res['status'] != 0) {
        sConin = res['data']['activity']['value'];
        getdata();
      } else {
        CommonUtils.showText(res['msg']);
      }
    });
  }

  getHistory() {
    PersistentState.getState('gameHistory').then((res) {
      if (res != null) {
        historyList = json.decode(res);
        setState(() {});
      }
    });
  }

  setHistory({int? id, String? icon, String? name}) {
    var changeHistory = historyList
        .where((item) => item['id'].toString() == id.toString())
        .toList();
    if (changeHistory.isEmpty) {
      historyList.insert(0, {"id": id.toString(), "icons": icon, "name": name});
      var newObj = historyList;
      PersistentState.saveState('gameHistory', jsonEncode(newObj));
    } else {
      historyList.removeWhere((item) => item['id'].toString() == id.toString());
      historyList.insert(0, {"id": id.toString(), "icons": icon, "name": name});
      var newObj = historyList;
      PersistentState.saveState('gameHistory', jsonEncode(newObj));
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getHistory();
    intpage();
    getBalance().then((res) {
      if (res == null) {
        CommonUtils.showText('网络错误,请重试～');
        Navigator.pop(context);
        return;
      }
      if (res['status'] != 0) {
        Provider.of<HomeConfig>(context, listen: false)
            .setGameCoin(res['data']);
        setState(() {});
      } else {
        CommonUtils.showText(res['msg']);
      }
    });
  }

  Widget startBtn() {
    return Container(
      width: 65.w,
      height: 25.w,
      decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xfffbad3e), Color(0xffffedb5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(12.5.w)),
      child: Center(
        child: Text(
          '马上开始',
          style: TextStyle(color: Color(0xff903600), fontSize: 12.w),
        ),
      ),
    );
  }

  getdata() {
    var phone = Provider.of<HomeConfig>(context, listen: false).member.phone;
    String gameHoStr = 'game_home';
    String lsisd = 'zhuce';
    String coniStr = sConin == 0 ? gameHoStr : lsisd;
    String vipStriii = 'assets/images/games/vip.png';
    String asio5 = 'assets/images/games/money.png';
    getGameList().then((res) {
      if (res == null) {
        networkErr = true;
        setState(() {});
      }
      if (res!['status'] != 0) {
        hotGame = res['data']['hotGame'];
        networkErr = false;
        moreGame = res['data']['moreGame'];
        loading = false;
        tips = res['data']['tips'];
        menuList = [
          {
            'title': '充值',
            'cover': 'assets/images/games/recharge.png',
            'onTap': () {
              AppGlobal.appRouter
                  ?.push(CommonUtils.getRealHash('gameRechargePage'));
            },
            'icon': res['data']['vipIcon'] ? vipStriii : null
          },
          {
            'title': '提现',
            'cover': 'assets/images/games/withdraw.png',
            'onTap': () {
              AppGlobal.appRouter
                  ?.push(CommonUtils.getRealHash('gameWithdrawPage'));
            },
            'icon': null
          },
          {
            'title': sConin == 0 ? intoGStr : '注册送$sConin元',
            'cover': 'assets/images/games/$coniStr.png',
            'onTap': () {
              if (phone == null) {
                YyToast.errorToast('需要注册账号哦～');
                return;
              }
              enterGamePage(id: 0);
            },
            'icon': res['data']['iconIcon'] ? asio5 : null
          },
          {
            'title': "活动",
            'cover': 'assets/images/games/activity.png',
            'onTap': () {
              if (res['data']['button'].isNotEmpty) {
                AppGlobal.appRouter?.push(CommonUtils.getRealHash('webview/' +
                    Uri.encodeComponent(res['data']['button'].toString()) +
                    '/活动'));
              }
            },
            'icon': null
          }
        ];
        if (res['data']['notice'].length != 0) {
          _showDialog(res['data']['notice'][0], res['data']['button']);
        }
        setState(() {});
      } else {
        BotToast.showText(text: res['msg'], align: Alignment(0, 0));
      }
    });
  }

  Future<bool?> _showDialog(String text, String url) {
    return showDialog<bool>(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return Dialog(
              backgroundColor: Colors.transparent,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 300.w,
                    width: 310.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.w),
                    ),
                    margin: EdgeInsets.only(top: 20.w),
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: 66.w,
                        left: 35.w,
                        right: 15.w,
                        bottom: 20.w,
                      ),
                      child: Column(
                        children: [
                          Expanded(
                              child: SingleChildScrollView(
                                  child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(bottom: 7.5.w),
                                child: Text("游戏公告",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.w600)),
                              ),
                              Text(text,
                                  style: TextStyle(
                                      color: Color(0xff808080),
                                      fontSize: 14.sp)),
                            ],
                          ))),
                          url.isEmpty
                              ? Container()
                              : GestureDetector(
                                  onTap: () {
                                    AppGlobal.appRouter?.push(
                                        CommonUtils.getRealHash('gameWebView/' +
                                            Uri.encodeComponent(
                                                url.toString()) +
                                            '/0'));
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    margin: EdgeInsets.only(top: 10.w),
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(20.w),
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFFffedb5),
                                            Color(0xFFfbad3e)
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        )),
                                    width: 261.w,
                                    height: 40.w,
                                    child: Text('查看详情',
                                        style: TextStyle(
                                            fontSize: 14.sp,
                                            color: Color(0xff903600))),
                                  ),
                                )
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                      top: 0,
                      child: Container(
                        width: 76.w,
                        height: 76.w,
                        child: NetImageTool(
                          url: 'assets/images/games/lingdang.png',
                          fit: BoxFit.contain,
                        ),
                      )),
                ],
              ));
        });
  }

  @override
  Widget build(BuildContext context) {
    String _coin =
        Provider.of<HomeConfig>(context, listen: false).gameCoin ?? '0';
    return HeaderContainer(
        child: Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 90.w),
        child: GestureDetector(
          onTap: () {
            ServiceParmas.type = 'game';
            AppGlobal.appRouter
                ?.push(CommonUtils.getRealHash('onlineServicePage'));
          },
          child: LocalPNG(
            url: 'assets/images/games/kefu.png',
            height: 58.w,
            fit: BoxFit.fitHeight,
          ),
        ),
      ),
      appBar: PreferredSize(
          child: PageTitleBar(
            title: '游戏大厅',
          ),
          preferredSize: Size(double.infinity, 44.w)),
      body: networkErr
          ? NetworkErr(
              errorRetry: () {
                getdata();
              },
            )
          : (loading
              ? Loading()
              : CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: tips == ''
                          ? null
                          : Container(
                              height: 25.w,
                              decoration: BoxDecoration(
                                color: Color(0xffffe38f),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 10.w,
                                  ),
                                  LocalPNG(
                                    url: 'assets/images/games/speaker.png',
                                    width: 29.5.w,
                                    fit: BoxFit.fitWidth,
                                  ),
                                  Expanded(
                                      child: new Marquee(
                                    text: tips!,
                                    style: TextStyle(
                                        color: Color(0xff6b000c),
                                        fontSize: 11.sp),
                                    scrollAxis: Axis.horizontal,
                                  ))
                                ],
                              ),
                            ),
                    ),
                    SliverToBoxAdapter(
                      child: Center(
                        child: Container(
                          margin: EdgeInsets.only(top: 18.w),
                          width: 345.w,
                          height: 100.w,
                          child: Stack(
                            children: [
                              LocalPNG(
                                  url: 'assets/images/games/coin_banner.png',
                                  width: 345.w,
                                  height: 104.w,
                                  fit: BoxFit.fill),
                              Padding(
                                padding:
                                    EdgeInsets.symmetric(horizontal: 39.5.w),
                                child: Center(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '钱包余额（元）',
                                        style: TextStyle(
                                            color: Color(0xffcccccc),
                                            fontSize: 12.sp),
                                      ),
                                      SizedBox(
                                        height: 20.w,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            _coin,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 33.sp),
                                          ),
                                          Container()
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    headWidget(),
                    SliverToBoxAdapter(
                      child: historyList.length == 0
                          ? Container()
                          : Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 14.w, horizontal: 15.w),
                              child: Text(
                                '最近在玩',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.sp),
                              ),
                            ),
                    ),
                    SliverToBoxAdapter(
                      child: historyList.length == 0
                          ? Container()
                          : Container(
                              width: 1.sw,
                              height: 168.5.w,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: historyList.length,
                                padding:
                                    EdgeInsets.symmetric(horizontal: 10.5.w),
                                itemBuilder: (BuildContext content, int index) {
                                  return Container(
                                    margin: EdgeInsets.only(right: 15.w),
                                    width: 168.w,
                                    child: GestureDetector(
                                      onTap: () {
                                        enterGamePage(
                                            id: int.parse(
                                                historyList[index]['id']),
                                            name: historyList[index]['name'],
                                            icon: historyList[index]['icons']);
                                      },
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 168.w,
                                            height: 100.w,
                                            child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                child: NetImageTool(
                                                  url: historyList[index]
                                                      ['icons'],
                                                )),
                                          ),
                                          SizedBox(
                                            height: 10.5.w,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                historyList[index]['name']
                                                    .toString(),
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 12.sp),
                                              ),
                                              startBtn()
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 14.w, horizontal: 15.w),
                        child: Text(
                          '更多游戏',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 19.sp),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15.w),
                        child: Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            runSpacing: 9.w,
                            // spacing: GVScreenUtil.setWidth(18),
                            children: moreGame!.asMap().keys.map((e) {
                              return Container(
                                width: 168.w,
                                child: GestureDetector(
                                  onTap: () {
                                    enterGamePage(
                                        id: moreGame![e]['id'],
                                        name: moreGame![e]['name'],
                                        icon: moreGame![e]['icons']);
                                  },
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 168.w,
                                        height: 100.w,
                                        child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            child: NetImageTool(
                                              url: moreGame![e]['icons'],
                                            )),
                                      ),
                                      SizedBox(
                                        height: 10.5.w,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            moreGame![e]['name'],
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12.sp),
                                          ),
                                          startBtn()
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              );
                            }).toList()),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 91.w,
                      ),
                    )
                  ],
                )),
    ));
  }

  enterGamePage({int? id, String? icon, String? name}) async {
    BotToast.showLoading();
    await enterGame(id!).then((res) {
      if (res!['status'] != 0) {
        BotToast.closeAllLoading();
        setHistory(id: id, icon: icon, name: name);
        AppGlobal.appRouter?.push(CommonUtils.getRealHash('gameWebView/' +
            Uri.encodeComponent(res['data']['url'].toString()) +
            '/0'));
      } else {
        BotToast.showText(text: res['msg'], align: Alignment(0, 0));
        BotToast.closeAllLoading();
      }
    });
  }

  inputItem(
      {String? text,
      TextEditingController? textController,
      String? hintText,
      TextInputType? type}) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 25.w,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text!,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 15.sp,
            ),
          ),
          Container(
            width: 254.w,
            decoration: BoxDecoration(
                border: Border.all(color: Color(0XFFe6e6e6), width: 0.5.w),
                borderRadius: BorderRadius.circular(5.w)),
            padding: EdgeInsets.symmetric(horizontal: 17.5.w),
            child: Center(
              child: TextField(
                controller: textController,
                keyboardType: type,
                // autofocus: true,
                decoration: InputDecoration(
                  hintText: hintText,
                  suffixStyle: TextStyle(fontSize: 5.sp),
                  // 未获得焦点下划线设为灰色
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                  //获得焦点下划线设为蓝色
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  headWidget() {
    return SliverToBoxAdapter(
      child: Center(
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 18.w),
          width: 345.w,
          height: 76.w,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: menuList!.asMap().keys.map((e) {
              return SizedBox(
                width: 80.w,
                height: 64.5.w,
                child: Stack(
                  children: [
                    LocalPNG(
                      width: 80.w,
                      height: 64.5.w,
                      url: 'assets/images/games/game_bg.png',
                      fit: BoxFit.fill,
                    ),
                    Center(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          GestureDetector(
                            onTap: menuList![e]['onTap'],
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                LocalPNG(
                                    url: menuList![e]['cover'],
                                    width: 35.w,
                                    height: 35.w,
                                    fit: BoxFit.contain),
                                Text(
                                  menuList![e]['title'],
                                  style: TextStyle(
                                      color: Color(0xff666666),
                                      fontSize: 12.sp),
                                )
                              ],
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: (e == 0 ? -27.5 : -20).w,
                            child: menuList![e]['icon'] == null
                                ? Container()
                                : LocalPNG(url: menuList![e]['icon']),
                            width: 35.w,
                            height: 15.w,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
