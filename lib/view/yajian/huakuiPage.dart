import 'package:bot_toast/bot_toast.dart';
import 'package:chaguaner2023/components/cgDialog.dart';
import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/loading.dart';
import 'package:chaguaner2023/components/networkErr.dart';
import 'package:chaguaner2023/components/nodata.dart';
import 'package:chaguaner2023/components/pagetitlebar.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:chaguaner2023/view/yajian/huakuiCard.dart';
import 'package:chaguaner2023/view/yajian/tcard/tcard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class HuakuiGelou extends StatefulWidget {
  HuakuiGelou({Key? key}) : super(key: key);

  @override
  _HuakuiGelouState createState() => _HuakuiGelouState();
}

class _HuakuiGelouState extends State<HuakuiGelou> {
  TCardController _controller = TCardController();
  ValueNotifier<int> currentIndex = ValueNotifier<int>(0);
  int page = 1;
  List<Widget>? cardList;
  // favorite 0未收藏1收藏
  ValueNotifier<bool> isFavorite = ValueNotifier<bool>(false);
  bool netWorkErr = false;
  bool isAll = false;
  bool loading = true;
  List? gelouList;
  gethuakuiData() async {
    loading = (page == 1);
    netWorkErr = false;
    setState(() {});
    var huakui = await huoKuiGeLou(page);
    if (huakui != null) {
      if (huakui['status'] != 0) {
        if (page == 1) {
          gelouList = huakui['data'] ?? [];
          loading = false;
          netWorkErr = false;
        } else {
          if (huakui['data'] == null || huakui['data'].length == 0) {
            isAll = true;
          }
          gelouList!.addAll(huakui['data'] == null ? [] : huakui['data']);
        }
      } else {
        BotToast.showText(
            text: huakui['msg'] ?? '出现错误，请稍后再试～', align: Alignment(0, 0));
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.pop();
        });
      }
      if (mounted) {
        setState(() {});
      }
    } else {
      setState(() {
        netWorkErr = true;
      });
    }
  }

  //收藏  favorite
  _collect() async {
    setState(() {
      isFavorite.value = !isFavorite.value;
    });
    String celSSStr = '收藏成功';
    String canlcolles = '取消收藏成功';
    var favorite =
        await favoriteVip(gelouList![currentIndex.value]['id'].toString());
    if (favorite!['status'] != 0) {
      BotToast.showText(
          text: isFavorite.value ? celSSStr : canlcolles,
          align: Alignment(0, 0));
      gelouList![currentIndex.value]['userFavorite'] = isFavorite.value ? 1 : 0;
      isFavorite.value = gelouList![currentIndex.value]['userFavorite'] == 1;
    } else {
      isFavorite.value = gelouList![currentIndex.value]['userFavorite'] == 1;
      if (favorite['msg'] == 'err') {
        CgDialog.cgShowDialog(
            context, '温馨提示', '免费收藏已达上限，请前往开通会员', ['取消', '立即前往'], callBack: () {
          AppGlobal.appRouter?.push(CommonUtils.getRealHash('memberCardsPage'));
        });
      } else {
        CommonUtils.showText(favorite['msg']);
      }
    }
  }

  @override
  void initState() {
    gethuakuiData();
    super.initState();
  }

  @override
  void dispose() {
    currentIndex.dispose();
    _controller.dispose();
    isFavorite.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HeaderContainer(
      image: "assets/images/huakui-bg.jpg",
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.transparent,
          appBar: PreferredSize(
              child: PageTitleBar(
                title: '花魁阁楼',
              ),
              preferredSize: Size(double.infinity, 44.w)),
          body: netWorkErr
              ? NetworkErr(
                  transparent: true,
                  errorRetry: () {
                    page = 1;
                    gethuakuiData();
                  },
                )
              : (loading
                  ? Loading(
                      transparent: true,
                    )
                  : (gelouList!.length == 0
                      ? NoData(
                          refresh: () {
                            setState(() {
                              page = 1;
                              loading = true;
                            });
                            gethuakuiData();
                          },
                          transparent: true,
                          text: '客官～ 当前暂时无数据～',
                        )
                      : Column(
                          children: <Widget>[
                            Expanded(
                                child: Container(
                              child: ValueListenableBuilder(
                                  valueListenable: currentIndex,
                                  builder: (context, value, child) {
                                    return TCard(
                                      cards: gelouList!.asMap().keys.map((e) {
                                        return Container(
                                            key: PageStorageKey('huakui_$e'),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: gelouList![e]['resources']
                                                        .where((item) =>
                                                            item['type'] == 2)
                                                        .length ==
                                                    0
                                                ? ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    child: NoData(
                                                      text: '此资源没有视频～',
                                                    ))
                                                : HuakuiCard(
                                                    gelouInfo: gelouList![e],
                                                    loaddingIndex: e,
                                                    currentIndex:
                                                        currentIndex));
                                      }).toList(),
                                      size: Size(325.w, 490.w),
                                      controller: _controller,
                                      onForward: (index, info) {
                                        currentIndex.value = index;
                                        isFavorite.value = (gelouList![index]
                                                ['userFavorite'] ==
                                            1);
                                        if (currentIndex.value ==
                                                (gelouList!.length - 3) &&
                                            !isAll) {
                                          page++;
                                          gethuakuiData();
                                        }
                                      },
                                      onBack: (int index) {
                                        currentIndex.value = index;
                                        isFavorite.value =
                                            (gelouList![currentIndex.value]
                                                    ['userFavorite'] ==
                                                1);
                                      },
                                    );
                                  }),
                            )),
                            Container(
                              color: Colors.transparent,
                              margin: EdgeInsets.only(
                                  bottom: ScreenUtil().bottomBarHeight + 28.w,
                                  top: 30.w),
                              child: Center(
                                child: Container(
                                  width: CommonUtils.getWidth(540),
                                  height: CommonUtils.getWidth(80),
                                  decoration: BoxDecoration(
                                      color: Colors.white70,
                                      borderRadius: BorderRadius.circular(
                                          CommonUtils.getWidth(40))),
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          GestureDetector(
                                            excludeFromSemantics: true,
                                            onTap: () {
                                              // swiperController.previous();
                                              if (currentIndex.value != 0) {
                                                _controller.back();
                                              }
                                            },
                                            child: ValueListenableBuilder(
                                              valueListenable: currentIndex,
                                              builder: (context, value, child) {
                                                return Container(
                                                    height: double.infinity,
                                                    color: Colors.transparent,
                                                    child: Opacity(
                                                      opacity:
                                                          value == 0 ? 0.5 : 1,
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: <Widget>[
                                                          Container(
                                                            width: 8.w,
                                                            height: 11.w,
                                                            margin:
                                                                EdgeInsets.only(
                                                                    right: 11.w,
                                                                    left: 20.w),
                                                            child: LocalPNG(
                                                              url:
                                                                  'assets/images/card/previou.png',
                                                              width: 8.w,
                                                              height: 11.w,
                                                            ),
                                                          ),
                                                          Text(
                                                            '上一张',
                                                            style: TextStyle(
                                                                fontSize: 12.sp,
                                                                color: StyleTheme
                                                                    .cTitleColor),
                                                          )
                                                        ],
                                                      ),
                                                    ));
                                              },
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              // swiperController.next();
                                              if (currentIndex.value !=
                                                  gelouList!.length - 1) {
                                                _controller.forward();
                                              }
                                            },
                                            child: Container(
                                                height: double.infinity,
                                                color: Colors.transparent,
                                                child: ValueListenableBuilder(
                                                    valueListenable:
                                                        currentIndex,
                                                    builder: (context, value,
                                                        child) {
                                                      return Opacity(
                                                        opacity: value ==
                                                                gelouList!
                                                                        .length -
                                                                    1
                                                            ? 0.5
                                                            : 1,
                                                        child: Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: <Widget>[
                                                            Text('下一张',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        12.sp,
                                                                    color: StyleTheme
                                                                        .cTitleColor)),
                                                            Container(
                                                              width: 8.w,
                                                              height: 11.w,
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      right:
                                                                          20.w,
                                                                      left:
                                                                          11.w),
                                                              child: LocalPNG(
                                                                url:
                                                                    'assets/images/card/next.png',
                                                                width: 8.w,
                                                                height: 11.w,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    })),
                                          ),
                                        ],
                                      ),
                                      Positioned(
                                          top: CommonUtils.getWidth(-20),
                                          left: CommonUtils.getWidth(200),
                                          child: ValueListenableBuilder(
                                              valueListenable: isFavorite,
                                              builder:
                                                  (context, bool value, child) {
                                                String yishStr = "yishoucang";
                                                String weishouc = "weishoucang";
                                                String isFaStr =
                                                    value ? yishStr : weishouc;
                                                return GestureDetector(
                                                  onTap: _collect,
                                                  child: Container(
                                                    width: CommonUtils.getWidth(
                                                        140),
                                                    height:
                                                        CommonUtils.getWidth(
                                                            120),
                                                    color: Colors.transparent,
                                                    child: LocalPNG(
                                                        width: CommonUtils
                                                            .getWidth(140),
                                                        height: CommonUtils
                                                            .getWidth(120),
                                                        url:
                                                            'assets/images/card/' +
                                                                isFaStr +
                                                                '.png',
                                                        fit: BoxFit.cover),
                                                  ),
                                                );
                                              }))
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        )))),
    );
  }
}
