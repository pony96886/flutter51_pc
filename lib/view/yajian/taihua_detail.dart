import 'package:chaguaner2023/components/avatar_widget.dart';
import 'package:chaguaner2023/components/cgDialog.dart';
import 'package:chaguaner2023/components/detail_ad.dart';
import 'package:chaguaner2023/components/loading.dart';
import 'package:chaguaner2023/components/pagetitlebar.dart';
import 'package:chaguaner2023/input/InputDailog.dart';
import 'package:chaguaner2023/store/global.dart';
import 'package:chaguaner2023/store/homeConfig.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:chaguaner2023/video/shortv_player.dart';
import 'package:chaguaner2023/view/yajian/tanhua.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../components/list/public_list.dart';

class TanhuaDetailPage extends StatefulWidget {
  final String? id;
  TanhuaDetailPage({Key? key, this.id}) : super(key: key);

  @override
  _TanhuaDetailPageState createState() => _TanhuaDetailPageState();
}

class _TanhuaDetailPageState extends State<TanhuaDetailPage> {
  Map? tanhuaDetail;
  Map? tanhuaRecommend;
  bool isTap = false;
  bool networkErr = false;
  bool loading = true;
  Map? adData; // 广告数据
  ValueNotifier<bool> isFavorite = ValueNotifier(false);
  ValueNotifier<bool> isLike = ValueNotifier(false);
  @override
  void initState() {
    super.initState();
    getData();
    getAd();
  }

  // 获取广告
  getAd() async {
    var data = await getDetail_ad(801);
    if (data != null) {
      this.setState(() {
        adData = data;
      });
    }
  }

  onZan() {
    if (isTap) {
      CommonUtils.showText('请勿频繁操作');
      return;
    }
    isTap = true;
    isLike.value = !isLike.value;
    tanhuaFavoriteToggle(related_id: widget.id, type: 3).then((res) {
      if (res!['status'] == 0) {
        isLike.value = !isLike.value;
      } else {
        CommonUtils.showText(isLike.value ? '点赞成功' : '取消点赞成功');
      }
    }).whenComplete(() {
      isTap = false;
    });
  }

  onLike() {
    if (isTap) {
      CommonUtils.showText('请勿频繁操作');
      return;
    }
    isTap = true;
    isFavorite.value = !isFavorite.value;
    tanhuaFavoriteToggle(related_id: widget.id).then((res) {
      if (res!['status'] == 0) {
        isFavorite.value = !isFavorite.value;
        if (res['msg'] == 'err') {
          CgDialog.cgShowDialog(
              context, '温馨提示', '免费收藏已达上限，请前往开通会员', ['取消', '立即前往'],
              callBack: () {
            AppGlobal.appRouter
                ?.push(CommonUtils.getRealHash('memberCardsPage'));
          });
        } else {
          CommonUtils.showText(res['msg']);
        }
      } else {
        CommonUtils.showText(isFavorite.value ? '收藏成功' : '取消收藏成功');
      }
    }).whenComplete(() {
      isTap = false;
    });
  }

  getData() async {
    var data = await tanhuaDetailData(widget.id!);
    if (data!['status'] != 0) {
      tanhuaDetail = data['data'];
      CommonUtils.debugPrint(tanhuaDetail);
      isFavorite.value = tanhuaDetail!['is_favorited'];
      isLike.value = tanhuaDetail!['is_liked'];
      if (isLike.value) {
        tanhuaDetail!['count_like'] = tanhuaDetail!['count_like'] - 1;
      }
      loading = false;
      setState(() {});
    } else {
      CommonUtils.showText(data['msg']);
      networkErr = true;
      setState(() {});
    }
  }

  List<Widget> videoTagList() {
    List<Widget> list = [];
    if (tanhuaDetail!['tags'] != '') {
      var aba = tanhuaDetail!['tags'].split(',');
      for (var i = 0; i < aba.length; i++) {
        if (aba[i] != '') {
          list.add(videoTag(aba[i]));
        }
      }
    }
    return list.toList();
  }

  onShowTips() {
    if (tanhuaDetail!['isfree'] == 1) {
      //会员视频
      CgDialog.cgShowDialog(context, '温馨提示', '开通会员,解锁视频完整版', ['取消', '去充值'],
          callBack: () {
        AppGlobal.appRouter?.push(CommonUtils.getRealHash('memberCardsPage'));
      });
    } else {
      var money = Provider.of<HomeConfig>(context, listen: false).member.money;
      //金币视频  原创视频
      CgDialog.cgShowDialog(context, '温馨提示', '', [
        '取消',
        money < tanhuaDetail!['coins_after_discount'] ? '余额不足' : '立即解锁'
      ], callBack: () {
        if (money < tanhuaDetail!['coins_after_discount']) {
          AppGlobal.appRouter?.push(CommonUtils.getRealHash('ingotWallet'));
        } else {
          mvUnlock(tanhuaDetail!['id']).then((res) {
            if (res!['status'] != 0) {
              loading = true;
              setState(() {});
              getData();
            } else {
              CommonUtils.showText(res!['msg']);
            }
          });
        }
      },
          contentWidget: Padding(
            padding: EdgeInsets.only(top: 15.w),
            child: Text.rich(
              TextSpan(
                  text: '使用',
                  children: [
                    TextSpan(
                        text: '${tanhuaDetail!['coins_after_discount']}',
                        style: TextStyle(
                          color: Color(0xffff4149),
                        )),
                    TextSpan(text: '元宝解锁视频完整版'),
                  ],
                  style: TextStyle(
                      color: StyleTheme.cTitleColor, fontSize: 12.sp)),
            ),
          ));
    }
  }

  Widget videoWidget() {
    return tanhuaDetail == null
        ? Container()
        : Container(
            height: CommonUtils.getWidth(420),
            width: 1.sw,
            child: Stack(
              children: [
                tanhuaDetail!['has_privilege']
                    ? Positioned.fill(
                        child: ShortVPlayer(
                        url: tanhuaDetail!['source_240'],
                        cover_url: tanhuaDetail!['thumb_cover'],
                        isPlayer: true,
                      ))
                    : Positioned.fill(
                        child: ShortVPlayer(
                        url: tanhuaDetail!['preview'],
                        cover_url: tanhuaDetail!['thumb_cover'],
                        isPlayer: true,
                        onVideoEnd: onShowTips,
                      ))
                // Positioned.fill(
                //     child: Container(
                //       child: Stack(
                //         children: [
                //           LocalPNG(
                //             url: tanhuaDetail['thumb_cover'],
                //             height: CommonUtils.getWidth(420),
                //             width: 1.sw,
                //           ),
                //           Center(
                //             child: Text(
                //               '该视频暂无法播放，请稍后再试～',
                //               style: TextStyle(
                //                   color: Colors.red, fontSize: 14.sp),
                //             ),
                //           )
                //         ],
                //       ),
                //     ),
                //   ),
              ],
            ),
          );
  }

  @override
  void dispose() {
    super.dispose();
    isFavorite.dispose();
  }

  Widget commentCard(item) {
    return Container(
      padding: new EdgeInsets.only(
          left: 15.w, right: 15.w, bottom: 10.5.w, top: 19.5.w),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          margin: new EdgeInsets.only(right: 10.5.w),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
          child: GestureDetector(
            onTap: () {
              AppGlobal.appRouter?.push(CommonUtils.getRealHash(
                  'brokerHomepage/' +
                      item['user']['uid'].toString() +
                      '/' +
                      Uri.encodeComponent(item['user']['thumb'].toString()) +
                      '/' +
                      Uri.encodeComponent(
                          item['user']['nickname'].toString())));
            },
            child: Container(
              height: 40.sp,
              width: 40.sp,
              child: Avatar(type: item['user']['thumb']),
            ),
          ),
        ),
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item['user']['nickname'],
              style: TextStyle(
                color: StyleTheme.cTitleColor,
                fontSize: 16.sp,
              ),
            ),
            SizedBox(
              height: 13.5.w,
            ),
            Text(
              item['content'],
              style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 14.sp),
            ),
            SizedBox(
              height: 11.5.w,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item['created_at'].toString(),
                  style: TextStyle(
                    color: StyleTheme.cBioColor,
                    fontSize: 12.sp,
                  ),
                ),

                SizedBox()
                // Row(
                //   mainAxisSize: MainAxisSize.min,
                //   children: [
                //     LocalPNG(
                //       url: 'assets/images/elegantroom/icon_reply.png',
                //       width: 15.w,
                //       height: 15.w,
                //     ),
                //     SizedBox(
                //       width: 5.w,
                //     ),
                //     Text(
                //       '回复',
                //       style: TextStyle(
                //           color: StyleTheme.cTitleColor, fontSize: 12.sp),
                //     )
                //   ],
                // )
              ],
            ),
            //二级评论
            item['child'].isEmpty
                ? SizedBox()
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: item['child'].asMap().keys.map((e) {
                      Map childItem = item['child'][e];
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: 16.w,
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                height: 25.w,
                                width: 25.w,
                                child: Avatar(
                                  type: childItem['user']['thumb'],
                                  radius: 12.5.w,
                                ),
                              ),
                              SizedBox(
                                width: 10.w,
                              ),
                              Text(
                                childItem['user']['nickname'].toString(),
                                style: TextStyle(
                                  color: StyleTheme.cTitleColor,
                                  fontSize: 16.sp,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: double.infinity,
                            margin: new EdgeInsets.only(top: 10.w, left: 35.w),
                            padding: EdgeInsets.symmetric(
                                horizontal: 14.w, vertical: 15.w),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: StyleTheme.bottomappbarColor),
                            child: Text(
                              childItem['content'].toString(),
                              style: TextStyle(
                                  color: Color(0xFF646464), fontSize: 12.sp),
                            ),
                          )
                        ],
                      );
                    }).toList(),
                  )
          ],
        ))
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    dynamic code = Provider.of<GlobalState>(context, listen: false).cityCode;
    return Scaffold(
      backgroundColor: Colors.white,
      body: loading
          ? Column(
              children: [
                PageTitleBar(
                  title: '探花好片',
                ),
                Expanded(child: Loading())
              ],
            )
          : Column(
              children: [
                Container(height: ScreenUtil().statusBarHeight),
                videoWidget(),
                tanhuaDetail!['has_privilege']
                    ? SizedBox()
                    : Padding(
                        padding: EdgeInsets.only(top: 15.w),
                        child: Center(
                          child: GestureDetector(
                            onTap: onShowTips,
                            behavior: HitTestBehavior.translucent,
                            child: Stack(
                              children: [
                                LocalPNG(
                                  height: 50.w,
                                  width: 300.w,
                                  url: 'assets/images/mymony/money-img.png',
                                  fit: BoxFit.fill,
                                ),
                                Positioned.fill(
                                    child: Center(
                                        child: Text(
                                  tanhuaDetail!['isfree'] == 1
                                      ? '开通会员解锁完整版'
                                      : '${tanhuaDetail!['coins_after_discount']}元宝解锁完整版',
                                  style: TextStyle(
                                      fontSize: 15.sp, color: Colors.white),
                                ))),
                                Positioned(
                                    right: 0,
                                    top: 0,
                                    child: double.parse(
                                                '${tanhuaDetail!['coins_after_discount']}') <
                                            double.parse(
                                                '${tanhuaDetail!['coins']}')
                                        ? Container(
                                            height: 15.w,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 5.w),
                                            decoration: BoxDecoration(
                                                color: StyleTheme.cDangerColor,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        7.5.w)),
                                            child: Text(
                                              '原价:${tanhuaDetail!['coins']}元宝',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12.sp,
                                                  decoration: TextDecoration
                                                      .lineThrough),
                                            ),
                                          )
                                        : SizedBox())
                              ],
                            ),
                          ),
                        ),
                      ),
                Expanded(
                    child: PublicList(
                  sliverHead: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: CommonUtils.getWidth(30),
                            vertical: CommonUtils.getWidth(29)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              tanhuaDetail!['title'] ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w700),
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                  top: CommonUtils.getWidth(20)),
                              child: Wrap(
                                spacing: CommonUtils.getWidth(10),
                                runSpacing: CommonUtils.getWidth(10),
                                children: videoTagList(),
                              ),
                            ),
                            SizedBox(
                              height: 27.w,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${CommonUtils.renderFixedNumber(tanhuaDetail!['count_play'])}万次播观看',
                                  style: TextStyle(
                                      color: StyleTheme.cBioColor,
                                      fontSize: 12.sp),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ValueListenableBuilder(
                                      valueListenable: isLike,
                                      builder: (context, bool value, child) {
                                        return GestureDetector(
                                          onTap: onZan,
                                          child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Image.asset(
                                                  'assets/images/elegantroom/${value ? 'ic_video_zan' : 'ic_video_unzan'}.png',
                                                  height: 25.5.w,
                                                ),
                                                SizedBox(
                                                  width: 5.w,
                                                ),
                                                Text(
                                                  value
                                                      ? '${tanhuaDetail!['count_like'] + 1}'
                                                      : '${tanhuaDetail!['count_like']}',
                                                  style: TextStyle(
                                                      color:
                                                          StyleTheme.cBioColor,
                                                      fontSize: 12.sp),
                                                ),
                                              ]),
                                        );
                                      },
                                    ),
                                    SizedBox(
                                      width: 21.w,
                                    ),
                                    ValueListenableBuilder(
                                      valueListenable: isFavorite,
                                      builder: (context, bool value, child) {
                                        return GestureDetector(
                                          onTap: onLike,
                                          child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Image.asset(
                                                  'assets/images/elegantroom/${value ? 'ic_video_sc' : 'ic_video_unsc'}.png',
                                                  height: 25.5.w,
                                                ),
                                                SizedBox(
                                                  width: 5.w,
                                                ),
                                                Text(
                                                  value ? '已收藏' : '收藏',
                                                  style: TextStyle(
                                                      color:
                                                          StyleTheme.cBioColor,
                                                      fontSize: 12.sp),
                                                ),
                                              ]),
                                        );
                                      },
                                    ),
                                    SizedBox(
                                      width: 21.w,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        AppGlobal.appRouter?.push(
                                            CommonUtils.getRealHash(
                                                'shareQRCodePage'));
                                      },
                                      child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Image.asset(
                                              'assets/images/elegantroom/ic_video_share.png',
                                              height: 25.5.w,
                                            ),
                                            SizedBox(
                                              width: 5.w,
                                            ),
                                            Text(
                                              '分享',
                                              style: TextStyle(
                                                  color: StyleTheme.cBioColor,
                                                  fontSize: 12.sp),
                                            ),
                                          ]),
                                    )
                                  ],
                                )
                              ],
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 12.w),
                              height: 1.w,
                              color: Color(0xfff5f5f5),
                            ),
                            adData != null && adData!["data"].length > 0
                                ? Container(
                                    padding: EdgeInsets.only(bottom: 14.sp),
                                    height: 180.w,
                                    child: Detail_ad(
                                        width: double.infinity,
                                        app_layout: true,
                                        data: adData!["data"]),
                                  )
                                : SizedBox(),
                            tanhuaDetail!['recommend_list'].isEmpty ||
                                    tanhuaDetail!['recommend_list'] == null
                                ? SizedBox()
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '为你推荐',
                                        style: TextStyle(
                                            color: StyleTheme.cTitleColor,
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(
                                        height: 12.w,
                                      ),
                                      GridView.builder(
                                        itemCount:
                                            tanhuaDetail!['recommend_list']
                                                .length,
                                        physics: NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        padding: EdgeInsets.zero,
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                                childAspectRatio: 1.3,
                                                crossAxisCount: 2,
                                                mainAxisSpacing: 10.w,
                                                crossAxisSpacing: 10.w),
                                        itemBuilder: (context, index) {
                                          return TanhuaCard(
                                            item:
                                                tanhuaDetail!['recommend_list']
                                                    [index],
                                          );
                                        },
                                      ),
                                      Text(
                                        '全部评论（${tanhuaDetail!['count_comment']}）',
                                        style: TextStyle(
                                            color: StyleTheme.cTitleColor,
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(
                                        height: 12.w,
                                      ),
                                    ],
                                  )
                          ],
                        ),
                      )
                    ],
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 15.w),
                  cacheExtent: 5.sh,
                  api: '/api/mv/comment_list',
                  data: {'mv_id': widget.id},
                  isShow: true,
                  isSliver: true,
                  nullText: '还没有数据哦～',
                  itemBuild: (context, index, data, page, limit, getListData) {
                    return commentCard(data);
                  },
                )),
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      //阴影
                      BoxShadow(
                          color: Colors.black12,
                          offset: Offset(0, 0.5.w),
                          blurRadius: 2.5.w)
                    ],
                    color: Colors.white,
                  ),
                  padding: EdgeInsets.only(
                      top: 12.w,
                      bottom: 10.w + ScreenUtil().bottomBarHeight,
                      left: 12.w,
                      right: 12.w),
                  child: Row(
                    children: [
                      Expanded(
                          child: GestureDetector(
                        onTap: () {
                          InputDialog.show(context, '写精彩影评',
                              limitingText: 99,
                              btnText: '发送', onSubmit: (value) {
                            if (value != null) {
                              tanhuaMvComment(content: value, mv_id: widget.id)
                                  .then((res) {
                                if (res!['status'] != 0) {
                                  CommonUtils.showText(res['msg']);
                                } else {
                                  CommonUtils.showText(res['msg']);
                                }
                              });
                            }
                          });
                        },
                        child: Container(
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.symmetric(horizontal: 16.5.w),
                          height: 36.w,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18.w),
                              color: Color.fromRGBO(241, 241, 241, 1)),
                          child: Text(
                            '写精彩影评',
                            style: TextStyle(
                                color: StyleTheme.cBioColor, fontSize: 16.sp),
                          ),
                        ),
                      )),
                      SizedBox(
                        width: 12.w,
                      ),
                      Text(
                        '发送',
                        style: TextStyle(
                            color: StyleTheme.cTitleColor, fontSize: 16.sp),
                      )
                    ],
                  ),
                )
              ],
            ),
    );
  }

  List<Widget> yjTagList(List theList) {
    List<Widget> list = [];
    if (theList.length > 0) {
      for (var i = 0; i < theList.length; i++) {
        list.add(yjTag(theList[i]['name']));
        if (i == 4) {
          break;
        }
      }
    }
    return list.toList();
  }

  Widget yjTag(String title) {
    dynamic titleValue =
        title.length > 4 ? 4 : (title.length < 2 ? 2 : title.length);
    return Container(
      margin: EdgeInsets.only(right: CommonUtils.getWidth(10)),
      height: CommonUtils.getWidth(30),
      child: Stack(
        children: [
          LocalPNG(
            height: CommonUtils.getWidth(30),
            url: 'assets/images/card/tag-bg-$titleValue.png',
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: CommonUtils.getWidth(14)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(
                      fontSize: 10.sp, color: StyleTheme.cDangerColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  videoTag(String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(CommonUtils.getWidth(10)),
              color: Color(0xfff5f5f5)),
          height: CommonUtils.getWidth(60),
          padding: EdgeInsets.symmetric(horizontal: CommonUtils.getWidth(36)),
          child: Center(
            child: Text(
              '#$text',
              style: TextStyle(color: Color(0xff999999), fontSize: 13.sp),
            ),
          ),
        )
      ],
    );
  }
}
