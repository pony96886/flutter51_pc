import 'package:card_swiper/card_swiper.dart';
import 'package:chaguaner2023/components/cgDialog.dart';
import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/page_status.dart';
import 'package:chaguaner2023/components/pullrefreshlist.dart';
import 'package:chaguaner2023/store/global.dart';
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
import 'package:chaguaner2023/view/mall/commodity_comment_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../utils/cache/image_net_tool.dart';

class CommodityDetail extends StatefulWidget {
  const CommodityDetail({Key? key, this.id});
  final int? id;

  @override
  State<CommodityDetail> createState() => _CommodityDetailState();
}

class _CommodityDetailState extends State<CommodityDetail> {
  Map data = {};
  bool loading = true;
  int page = 1;
  bool isAll = false;
  int limit = 15;
  ValueNotifier<List> comment = ValueNotifier([]);
  ValueNotifier<bool> liked = ValueNotifier(false);
  bool isTap = false;
  List resources = [];
  getComments() {
    if (isAll) return;
    productConmentList(id: widget.id, page: page, limit: limit).then((res) {
      print(res);
      print('______________-');
      if (res!['status'] != 0) {
        List _data = res['data'] ?? [];
        if (page == 1) {
          comment.value = _data;
        } else {
          comment.value = [...comment.value, ..._data];
        }
        isAll = _data.length < limit;
      } else {
        CommonUtils.showText(res['msg'] ?? '系统错误～');
      }
    });
  }

  @override
  void initState() {
    super.initState();
    productList(widget.id).then((res) {
      if (res!['status'] != 0) {
        data = res['data'];
        if (data['videos'].isEmpty) {
          resources = data['cover_images'];
        } else {
          resources = [...data['videos'], ...data['cover_images']];
        }
        liked.value = data['is_favoried'];
        loading = false;
        CommonUtils.debugPrint(data);
        setState(() {});
      } else {
        CommonUtils.showText(res['msg'] ?? '系统错误～');
      }
    });
    getComments();
  }

  toLlIm() {
    AppGlobal.chatUser = FormUserMsg(
        uuid: data['user']['uuid'].toString(),
        nickname: data['user']['nickname'].toString(),
        avatar: data['user']['thumb'].toString());
    AppGlobal.appRouter?.push(CommonUtils.getRealHash('llchat'));
  }

  onLike() {
    if (isTap) {
      CommonUtils.showText('请勿频繁操作');
      return;
    }
    isTap = true;
    liked.value = !liked.value;
    favoriteToggle(widget.id!, 1).then((res) {
      if (res!['status'] == 0) {
        liked.value = !liked.value;
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
        CommonUtils.showText(liked.value ? '收藏成功' : '取消收藏成功');
      }
    }).whenComplete(() {
      isTap = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var profileDatas = Provider.of<GlobalState>(context).profileData;
    var vipLevel = profileDatas != null ? profileDatas['vip_level'] : 0;
    return HeaderContainer(
        child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                      top: ScreenUtil().statusBarHeight,
                      left: 15.w,
                      right: 15.w),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios),
                        onPressed: () {
                          context.pop();
                        },
                        iconSize: 25.0,
                        color: Colors.black,
                      ),
                      loading
                          ? SizedBox()
                          : data['user'] != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12.5.w),
                                  child: SizedBox(
                                    width: 25.w,
                                    height: 25.w,
                                    child: LocalPNG(
                                      width: double.infinity,
                                      height: double.infinity,
                                      url:
                                          'assets/images/common/${data['user']['thumb']}.png',
                                    ),
                                  ),
                                )
                              : SizedBox.shrink(),
                      SizedBox(
                        width: 6.5.w,
                      ),
                      loading
                          ? SizedBox()
                          : Expanded(
                              child: Text(
                              data['user'] == null
                                  ? ''
                                  : data['user']['nickname'],
                              style: TextStyle(
                                  color: Color(0xff1e1e1e),
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w700),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )),
                      SizedBox(
                        width: 6.5.w,
                      ),
                      if (data['user'] != null)
                        GestureDetector(
                          onTap: () {
                            context
                                .push('/merchantHome/${data['user']['uuid']}');
                          },
                          child: Text(
                            '进入店铺',
                            style: TextStyle(
                              color: Color(0xff1e1e1e),
                              fontSize: 14.sp,
                            ),
                          ),
                        )
                    ],
                  ),
                ),
                Expanded(
                    child: loading
                        ? PageStatus.loading(true)
                        : PullRefreshList(
                            onLoading: () {},
                            child: NestedScrollView(
                                headerSliverBuilder: (context, _v) {
                                  return [
                                    SliverToBoxAdapter(
                                      child: Container(
                                        color: Color(0xffeeeeee),
                                        width: 1.sw,
                                        height: 210.w,
                                        child: Swiper(
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return resources[index]
                                                        ['media_type'] ==
                                                    1
                                                ? ShortVPlayer(
                                                    url: resources[index]
                                                        ['media_url_full'],
                                                    cover_url: resources[index]
                                                        ['cover_url'],
                                                  )
                                                : GestureDetector(
                                                    onTap: () {
                                                      AppGlobal.picMap = {
                                                        'resources': resources,
                                                        'index': index
                                                      };
                                                      context.push(
                                                          '/teaViewPicPage');
                                                    },
                                                    child: ImageNetTool(
                                                      url: resources[index]
                                                          ['media_url_full'],
                                                      fit: BoxFit.fitHeight,
                                                    ),
                                                  );
                                          },
                                          itemCount: resources.length,
                                          layout: SwiperLayout.DEFAULT,
                                          duration: 300,
                                          itemWidth: double.infinity,
                                          itemHeight: 210.w,
                                          pagination: SwiperPagination(
                                            alignment: Alignment.bottomRight,
                                            builder: new SwiperCustomPagination(
                                                builder: (BuildContext context,
                                                    SwiperPluginConfig config) {
                                              return IgnorePointer(
                                                child: Container(
                                                    padding: new EdgeInsets
                                                        .symmetric(
                                                      horizontal:
                                                          CommonUtils.getWidth(
                                                              26),
                                                      vertical:
                                                          CommonUtils.getWidth(
                                                              7),
                                                    ),
                                                    decoration: BoxDecoration(
                                                        color: Colors.black45,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    10.0)),
                                                    child: Text(
                                                      (config.activeIndex + 1)
                                                              .toString() +
                                                          '/' +
                                                          config.itemCount
                                                              .toString(),
                                                      style: TextStyle(
                                                          fontSize: 14.sp,
                                                          color: Colors.white),
                                                    )),
                                              );
                                            }),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SliverToBoxAdapter(
                                      child: Padding(
                                        padding: EdgeInsets.all(15.w),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                LocalPNG(
                                                  url:
                                                      'assets/images/elegantroom/yuanbao.png',
                                                  width: 21.w,
                                                  fit: BoxFit.fitWidth,
                                                ),
                                                SizedBox(
                                                  width: 5.w,
                                                ),
                                                Text(
                                                  '${data['price'].toString().split('.')[0]}元宝',
                                                  style: TextStyle(
                                                      height: 1,
                                                      color: Color(0xffff4149),
                                                      fontSize: 25.sp,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                )
                                              ],
                                            ),
                                            SizedBox(
                                              height: 14.5.w,
                                            ),
                                            Text(
                                              data['title'],
                                              style: TextStyle(
                                                  height: 1,
                                                  color: Color(0xff1e1e1e),
                                                  fontSize: 18.sp,
                                                  fontWeight: FontWeight.w700),
                                            ),
                                            SizedBox(
                                              height: 12.w,
                                            ),
                                            Text(
                                              '#${data['goods_type']['name']}     已售${CommonUtils.renderFixedNumber(data['goods_type']['buy_num'])}',
                                              style: TextStyle(
                                                color: Color(0xffb4b4b4),
                                                fontSize: 12.sp,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 14.w,
                                            ),
                                            Text(
                                              data['description'].toString(),
                                              style: TextStyle(
                                                  color: Color(0xff1e1e1e),
                                                  fontSize: 14.sp),
                                            ),
                                            SizedBox(
                                              height: 15.5.w,
                                            ),
                                            LayoutBuilder(
                                                builder: (context, box) {
                                              return Column(
                                                children: data['detail_images']
                                                    .map<Widget>((item) {
                                                  return Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 10.w),
                                                    child: SizedBox(
                                                      width: box.maxWidth,
                                                      height: (box.maxWidth /
                                                              item['width']) *
                                                          item['height'],
                                                      child: ImageNetTool(
                                                        url: item[
                                                            'media_url_full'],
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                              );
                                            }),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  top: 16.w, bottom: 5.5.w),
                                              child: Text(
                                                '${CommonUtils.renderFixedNumber(data['comment_num'])}评论 / ${CommonUtils.renderFixedNumber(data['view_num'])}浏览 /  收藏${CommonUtils.renderFixedNumber(data['favorite_num'])} / ${RelativeDateFormat.format(DateTime.parse(data['created_at']))}更新',
                                                style: TextStyle(
                                                    color: Color(0xffb4b4b4),
                                                    fontSize: 12.sp),
                                              ),
                                            ),
                                            Text(
                                              '温馨提示：\n用户需要开通会员才能私聊商家，点击购买输入信息，商家安排发货',
                                              style: TextStyle(
                                                  height: 1.5,
                                                  color: Color(0xffff4149),
                                                  fontSize: 13.sp),
                                            ),
                                            Container(
                                              margin: EdgeInsets.symmetric(
                                                  vertical: 16.w),
                                              height: 1,
                                              color: Color(0xfff5f5f5),
                                            ),
                                            Text(
                                              '评论留言（${data['comment_num']}）',
                                              style: TextStyle(
                                                  color: Color(0xff1e1e1e),
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.w700),
                                            )
                                          ],
                                        ),
                                      ),
                                    )
                                  ];
                                },
                                body: ValueListenableBuilder(
                                    valueListenable: comment,
                                    builder: (context,
                                        List<dynamic> commentList, child) {
                                      return commentList.length == 0
                                          ? SingleChildScrollView(
                                              child: PageStatus.noData(
                                                  text: '还没有评论~'),
                                            )
                                          : ListView.builder(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 15.w,
                                                  vertical: 0),
                                              itemCount: commentList.length,
                                              itemBuilder: (context, index) {
                                                return CommodityCommentCard(
                                                    data: commentList[index]);
                                              });
                                    })),
                          )),
                loading
                    ? SizedBox()
                    : Container(
                        height: 46.w + ScreenUtil().bottomBarHeight,
                        color: Color(0xfff5f5f5),
                        padding: EdgeInsets.fromLTRB(
                            15.w, 0, 15.w, ScreenUtil().bottomBarHeight),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ValueListenableBuilder(
                                    valueListenable: liked,
                                    builder: (context, bool value, child) {
                                      return GestureDetector(
                                        onTap: onLike,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              margin: new EdgeInsets.only(
                                                  right: 10.w),
                                              child: LocalPNG(
                                                url:
                                                    'assets/images/card/${value ? 'iscollect' : 'notcollect'}.png',
                                                width: 25.w,
                                                height: 25.w,
                                              ),
                                            ),
                                            Text(value ? '取消收藏' : '收藏',
                                                style: TextStyle(
                                                    fontSize: 14.sp,
                                                    color:
                                                        StyleTheme.cTitleColor,
                                                    fontWeight:
                                                        FontWeight.w500))
                                          ],
                                        ),
                                      );
                                    }),
                                SizedBox(
                                  width: 22.5.w,
                                ),
                                if (data['user'] != null)
                                  GestureDetector(
                                    onTap: () {
                                      if (!CgPrivilege.getPrivilegeStatus(
                                          PrivilegeType.infoSystem,
                                          PrivilegeType.privilegeIm)) {
                                        CommonUtils.showVipDialog(
                                            context,
                                            PrivilegeType.infoSysteString +
                                                PrivilegeType
                                                    .privilegeImString);
                                        return;
                                      }
                                      if (data['user']['nickname'] != null &&
                                          WebSocketUtility.uuid !=
                                              data['user']['uuid']) {
                                        if (WebSocketUtility.imToken == null) {
                                          CommonUtils.getImPath(context,
                                              callBack: () {
                                            //跳转IM
                                            toLlIm();
                                          });
                                        } else {
                                          //跳转IM
                                          toLlIm();
                                        }
                                      }
                                    },
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          margin:
                                              new EdgeInsets.only(right: 10.w),
                                          child: LocalPNG(
                                            url:
                                                'assets/images/detail/chat.png',
                                            width: 25.w,
                                            height: 25.w,
                                          ),
                                        ),
                                        Text('私聊',
                                            style: TextStyle(
                                                fontSize: 14.sp,
                                                color: StyleTheme.cTitleColor,
                                                fontWeight: FontWeight.w500))
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            GestureDetector(
                              // ignore: missing_return
                              onTap: () {
                                context.push('/buyCommodityPage/${data['id']}');
                                // if (verifyDetail['status'] == 2) {
                                //   setState(() {
                                //     myMoney = money;
                                //   });
                                //   showPublish();
                                // }
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
                                        url:
                                            'assets/images/mymony/money-img.png',
                                        fit: BoxFit.fill),
                                    Center(
                                        child: Text(
                                      '立即购买',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14.w,
                                          fontWeight: FontWeight.w500),
                                    ))
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      )
              ],
            )));
  }
}
