import 'package:bot_toast/bot_toast.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:chaguaner2023/components/avatar_widget.dart';
import 'package:chaguaner2023/components/cgDialog.dart';
import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/list/public_list.dart';
import 'package:chaguaner2023/components/page_status.dart';
import 'package:chaguaner2023/components/pagetitlebar.dart';
import 'package:chaguaner2023/components/starrating.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/cgprivilege.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:chaguaner2023/utils/netimage_tool.dart';
import 'package:chaguaner2023/video/shortv_player.dart';
import 'package:chaguaner2023/view/im/im.dart';
import 'package:chaguaner2023/view/im/im_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../utils/cache/image_net_tool.dart';

class NakedchatDetail extends StatefulWidget {
  final int? id;
  const NakedchatDetail({Key? key, this.id}) : super(key: key);

  @override
  State<NakedchatDetail> createState() => _NakedchatDetailState();
}

class _NakedchatDetailState extends State<NakedchatDetail> {
  Map? verifyDetail;
  Map? user;
  bool loading = true;
  ValueNotifier<bool> is_favorite = ValueNotifier(false);
  getDetail() {
    getGirlchatDetail(widget.id).then((res) {
      if (res!['status'] != 0) {
        verifyDetail = res['data'];
        user = verifyDetail!['user'];
        is_favorite.value = verifyDetail!['is_favorited'];
        loading = false;
        setState(() {});
      } else {
        CommonUtils.showText(res['msg']);
      }
    });
  }

  toggleFavorite() {
    getGirlchatFavorite(widget.id).then((res) {
      if (res!['status'] != 0) {
        is_favorite.value = res['data']['is_favorite'] == 1;
        CommonUtils.showText(res['data']['msg']);
      } else {
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
      }
    });
  }

  toLlIm() {
    if (user!['uuid'] != null) {
      // var image = verifyDetail!['photos'].firstWhere((v) => v['type'] == 1);

      AppGlobal.chatUser = FormUserMsg(
          uuid: user!['uuid'].toString(),
          nickname: user!['nickname'].toString(),
          avatar: user!['thumb'].toString());
      AppGlobal.appRouter?.push(CommonUtils.getRealHash('llchat'));
    } else {
      BotToast.showText(text: '数据出现错误，无法私聊～', align: Alignment(0, 0));
    }
  }

  connectGirl() {
    if (!CgPrivilege.getPrivilegeStatus(
        PrivilegeType.infoSystem, PrivilegeType.privilegeIm)) {
      CommonUtils.showVipDialog(context,
          PrivilegeType.infoSysteString + PrivilegeType.privilegeImString);
      return;
    }
    if (WebSocketUtility.imToken == null) {
      CommonUtils.getImPath(context, callBack: () {
        //跳转IM
        toLlIm();
      });
    } else {
      //跳转IM
      toLlIm();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    getDetail();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    is_favorite.dispose();
    super.dispose();
  }

  Widget _scoreCard(item) {
    return Container(
      padding: new EdgeInsets.only(
        left: 15.w,
        right: 15.w,
        bottom: CommonUtils.getWidth(90),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          margin: new EdgeInsets.only(right: CommonUtils.getWidth(21)),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
          child: GestureDetector(
            onTap: () {
              AppGlobal.appRouter?.push(CommonUtils.getRealHash(
                  'brokerHomepage/' +
                      item['user']['aff'].toString() +
                      '/' +
                      Uri.encodeComponent(item['user']['thumb'].toString()) +
                      '/' +
                      Uri.encodeComponent(
                          item['user']['nickname'].toString())));
            },
            child: Container(
              height: CommonUtils.getWidth(80),
              width: CommonUtils.getWidth(80),
              child: Avatar(type: item['user']['thumb'].toString()),
            ),
          ),
        ),
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item['user']['nickname'].toString(),
              style: TextStyle(
                color: StyleTheme.cTitleColor,
                fontSize: 16.sp,
              ),
            ),
            Container(
              margin: new EdgeInsets.only(top: 9.5.w),
              child: Row(
                children: [
                  Text(
                    '妹子颜值:',
                    style: TextStyle(
                        fontSize: 14.sp, color: StyleTheme.cTitleColor),
                  ),
                  StarRating(
                    rating: item['face'].toDouble(),
                    disable: true,
                    size: 12.w,
                    spacing: 5.w,
                  )
                ],
              ),
            ),
            Container(
              margin: new EdgeInsets.only(top: 16.sp),
              child: Row(
                children: [
                  Text(
                    '服务质量:',
                    style: TextStyle(
                        fontSize: 14.sp, color: StyleTheme.cTitleColor),
                  ),
                  StarRating(
                    rating: item['service'].toDouble(),
                    disable: true,
                    size: 12.sp,
                    spacing: 5.sp,
                  )
                ],
              ),
            ),
            item['comment'] == null || item['comment'] == ''
                ? Container()
                : Container(
                    width: double.infinity,
                    margin: new EdgeInsets.only(top: 16.sp),
                    padding: EdgeInsets.symmetric(
                        horizontal: CommonUtils.getWidth(28), vertical: 15.w),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: StyleTheme.bottomappbarColor),
                    child: Text(
                      item['comment'],
                      style:
                          TextStyle(color: Color(0xFF646464), fontSize: 12.sp),
                    ),
                  ),
            SizedBox(
              height: 11.5.w,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      item['created_at'].toString() + ' 打分',
                      style: TextStyle(
                        color: StyleTheme.cBioColor,
                        fontSize: 12.sp,
                      ),
                    ),
                    SizedBox(
                      width: CommonUtils.getWidth(9),
                    ),
                    item['isReal'] == 1
                        ? LocalPNG(
                            width: CommonUtils.getWidth(109),
                            height: CommonUtils.getWidth(26),
                            url: 'assets/images/detail/tag-true.png',
                          )
                        : Container()
                  ],
                ),
                // GestureDetector(
                //   onTap: () {
                //     // replyItemComment(item['id']);
                //   },
                //   child: Row(
                //     mainAxisSize: MainAxisSize.min,
                //     children: [
                //       LocalPNG(
                //         url: 'assets/images/elegantroom/icon_reply.png',
                //         width: 15.w,
                //         height: 15.w,
                //       ),
                //       SizedBox(
                //         width: 5.w,
                //       ),
                //       Text(
                //         '回复',
                //         style: TextStyle(
                //             color: StyleTheme.cTitleColor, fontSize: 12.sp),
                //       )
                //     ],
                //   ),
                // )
              ],
            ),
            //二级评论
            // Column(
            //   mainAxisSize: MainAxisSize.min,
            //   crossAxisAlignment: CrossAxisAlignment.start,
            //   children: (item['child'] as List).map((e) {
            //     return Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       mainAxisSize: MainAxisSize.min,
            //       children: [
            //         SizedBox(
            //           height: 16.w,
            //         ),
            //         Row(
            //           mainAxisSize: MainAxisSize.min,
            //           children: [
            //             Container(
            //               height: 25.w,
            //               width: 25.w,
            //               child: Avatar(
            //                 type: e['thumb'],
            //                 radius: 12.5.w,
            //               ),
            //             ),
            //             SizedBox(
            //               width: 10.w,
            //             ),
            //             Text(
            //               e['nickname'].toString(),
            //               style: TextStyle(
            //                 color: StyleTheme.cTitleColor,
            //                 fontSize: 16.sp,
            //               ),
            //             ),
            //           ],
            //         ),
            //         Container(
            //           width: double.infinity,
            //           margin: new EdgeInsets.only(
            //               top: 10.w, left: 35.w, bottom: 10.w),
            //           padding: EdgeInsets.symmetric(
            //               horizontal: 14.w, vertical: 15.w),
            //           decoration: BoxDecoration(
            //               borderRadius: BorderRadius.circular(5),
            //               color: StyleTheme.bottomappbarColor),
            //           child: Text(
            //             e['desc'].toString(),
            //             style: TextStyle(
            //                 color: Color(0xFF646464), fontSize: 12.sp),
            //           ),
            //         ),
            //         Padding(
            //           padding: EdgeInsets.only(left: 35.w),
            //           child: Text(
            //             CommonUtils.getCgTime(
            //                 int.parse(e['created_at'].toString())),
            //             style: TextStyle(
            //               color: StyleTheme.cBioColor,
            //               fontSize: 12.sp,
            //             ),
            //           ),
            //         )
            //       ],
            //     );
            //   }).toList(),
            // )
          ],
        ))
      ]),
    );
  }

  Widget newSee() {
    return Container(
      color: StyleTheme.bottomappbarColor,
      padding: new EdgeInsets.only(left: 13.5.w, right: 14.5.w),
      // margin: new EdgeInsets.only(bottom: 15.w),
      height: 60.w,
      child: Row(
        children: [
          Container(
              child: LocalPNG(
            url: 'assets/images/detail/new-look.png',
            width: CommonUtils.getWidth(87),
          )),
          Container(
            width: 1.w,
            height: 30.w,
            color: Color.fromRGBO(230, 230, 230, 1),
            margin: new EdgeInsets.only(left: 10.w, right: 10.w),
          ),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text(
                  verifyDetail!['new_user_tips'],
                  style: TextStyle(
                      height: 2,
                      color: StyleTheme.cDangerColor,
                      fontSize: 12.sp),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget serverItem(String serverName, String serverDetail, {double top = 15}) {
    return DefaultTextStyle(
        style: TextStyle(fontSize: 14.sp, color: StyleTheme.cTitleColor),
        child: Padding(
          padding: EdgeInsets.only(left: 15.w, right: 15.w, top: top.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${serverName}:  '),
              Expanded(child: Text(serverDetail)),
            ],
          ),
        ));
  }

  Widget _swiper() {
    var image = verifyDetail!['photos']
        .where((element) => element['type'] != 2)
        .toList();
    return verifyDetail!['photos'] != null && verifyDetail!['photos'].length > 0
        ? Container(
            color: Color(0xFFE5E5E5),
            height: 240.w,
            child: verifyDetail!['photos'] != null &&
                    verifyDetail!['photos'].length > 0
                ? Swiper(
                    itemBuilder: (BuildContext context, int index) {
                      return verifyDetail!['photos'][index]['type'] == 2
                          ? ShortVPlayer(
                              url: verifyDetail!['photos'][index]['url'],
                              cover_url: image[0]['url'],
                            )
                          : GestureDetector(
                              onTap: () {
                                AppGlobal.picMap = {
                                  'resources': verifyDetail!['photos'],
                                  'index': index
                                };
                                context.push('/teaViewPicPage');
                              },
                              child: ImageNetTool(
                                url: verifyDetail!['photos'][index]['url'],
                                fit: BoxFit.fitHeight,
                              ),
                            );
                    },
                    itemCount: verifyDetail!['photos'].length,
                    layout: SwiperLayout.DEFAULT,
                    duration: 300,
                    itemWidth: CommonUtils.getWidth(750),
                    itemHeight: CommonUtils.getWidth(480),
                    pagination: SwiperPagination(
                      alignment: Alignment.bottomRight,
                      builder: new SwiperCustomPagination(builder:
                          (BuildContext context, SwiperPluginConfig config) {
                        return IgnorePointer(
                          child: Container(
                              padding: new EdgeInsets.symmetric(
                                horizontal: CommonUtils.getWidth(26),
                                vertical: CommonUtils.getWidth(7),
                              ),
                              decoration: BoxDecoration(
                                  color: Colors.black45,
                                  borderRadius: BorderRadius.circular(10.0)),
                              child: Text(
                                (config.activeIndex + 1).toString() +
                                    '/' +
                                    config.itemCount.toString(),
                                style: TextStyle(
                                    fontSize: 14.sp, color: Colors.white),
                              )),
                        );
                      }),
                    ),
                  )
                : Container(),
          )
        : Container();
  }

  @override
  Widget build(BuildContext context) {
    return HeaderContainer(
        child: Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          PageTitleBar(
            title: '裸聊详情',
          ),
          Expanded(
              child: loading
                  ? PageStatus.loading(true)
                  : PublicList(
                      api: '/api/girlchat/comment_list',
                      data: {'girl_chat_id': widget.id},
                      isShow: true,
                      isSliver: true,
                      noRefresh: true,
                      nullText: '还没有评论哦～',
                      sliverHead: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _swiper(),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 15.w, vertical: 20.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  verifyDetail!['title'].toString(),
                                  style: TextStyle(
                                      color: StyleTheme.cTitleColor,
                                      fontSize: 15.w),
                                ),
                                SizedBox(
                                  height: 10.w,
                                ),
                                Row(
                                  children: [
                                    Text(
                                      'ID：${verifyDetail!['id']}',
                                      style: TextStyle(
                                          color: StyleTheme.cBioColor,
                                          fontSize: 10.w),
                                    ),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    (verifyDetail!['unlock_count'] ?? 0) == 0
                                        ? SizedBox()
                                        : Text(
                                            '${verifyDetail!['unlock_count']}人聊过',
                                            style: TextStyle(
                                                color: StyleTheme.cBioColor,
                                                fontSize: 10.w),
                                          ),
                                  ],
                                )
                              ],
                            ),
                          ),
                          newSee(),
                          serverItem('个人资料',
                              '${verifyDetail!['girl_age']}岁/${verifyDetail!['girl_height']}cm/${verifyDetail!['girl_weight']}kg/${verifyDetail!['girl_cup']}罩杯',
                              top: 20),
                          serverItem(
                              '服务项目',
                              verifyDetail!['girl_service_type'].isEmpty
                                  ? '--'
                                  : verifyDetail!['girl_service_type']),
                          serverItem('是否露脸',
                              verifyDetail!['show_face'] == 1 ? '是' : '否'),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 15.w, vertical: 30.w),
                            child: Row(
                              children: [
                                Text('茶友评价',
                                    style: TextStyle(
                                        color: StyleTheme.cTitleColor,
                                        fontSize: 18.w)),
                                Text('（${verifyDetail!['comment_num'] ?? 0})',
                                    style: TextStyle(
                                        color: StyleTheme.cTitleColor,
                                        fontSize: 12.w))
                              ],
                            ),
                          )
                        ],
                      ),
                      itemBuild:
                          (context, index, data, page, limit, getListData) {
                        return _scoreCard(data);
                      },
                    )),
          loading
              ? SizedBox()
              : Container(
                  height: 49.w + ScreenUtil().bottomBarHeight,
                  padding: new EdgeInsets.only(
                      bottom: ScreenUtil().bottomBarHeight,
                      left: 15.w,
                      right: 15.w),
                  color: StyleTheme.bottomappbarColor,
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              ValueListenableBuilder(
                                  valueListenable: is_favorite,
                                  builder: (context, bool value, child) {
                                    return GestureDetector(
                                      onTap: toggleFavorite,
                                      child: Container(
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              child: LocalPNG(
                                                url: value
                                                    ? 'assets/images/card/iscollect.png'
                                                    : 'assets/images/mymony/collect.png',
                                                width: 25.w,
                                                height: 25.w,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 12.w,
                                            ),
                                            Text('收藏')
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                              SizedBox(
                                width: 17.w,
                              ),
                              GestureDetector(
                                  onTap: connectGirl,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        margin:
                                            new EdgeInsets.only(right: 10.w),
                                        child: LocalPNG(
                                          url: 'assets/images/detail/chat.png',
                                          width: 25.w,
                                          height: 25.w,
                                        ),
                                      ),
                                      Text('私聊')
                                    ],
                                  )),
                            ],
                          )
                        ],
                      ),
                      GestureDetector(
                        // ignore: missing_return
                        onTap: () {
                          AppGlobal.appRouter?.push(
                              CommonUtils.getRealHash('nakedChatpay'),
                              extra: {
                                'girl_chat_id': widget.id,
                                'time_set': verifyDetail!['time_set'],
                                'addition_items':
                                    verifyDetail!['addition_items'],
                                'price_per_minute':
                                    verifyDetail!['price_per_minute'] ?? 0,
                                'title': verifyDetail!['title'],
                                'user': verifyDetail!['user']
                              });
                        },
                        child: Container(
                          width: 110.w,
                          height: 40.w,
                          margin: new EdgeInsets.only(left: 10.w),
                          child: Stack(
                            children: [
                              LocalPNG(
                                width: 110.w,
                                height: 40.w,
                                url: 'assets/images/mymony/money-img.png',
                              ),
                              Center(
                                child: Text(
                                  '立即预约',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                )
        ],
      ),
    ));
  }
}
