import 'package:chaguaner2023/components/avatar_widget.dart';
import 'package:chaguaner2023/components/citypickers/elegantCity.dart';
import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/list/public_list.dart';
import 'package:chaguaner2023/components/page_status.dart';
import 'package:chaguaner2023/components/pagetitlebar.dart';
import 'package:chaguaner2023/components/yy_dialog.dart';
import 'package:chaguaner2023/input/InputDailog.dart';
import 'package:chaguaner2023/model/basic.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:chaguaner2023/utils/netimage_tool.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../utils/cache/image_net_tool.dart';

class TeablackDetailPage extends StatefulWidget {
  final String id;
  const TeablackDetailPage({Key? key, required this.id}) : super(key: key);

  @override
  State<TeablackDetailPage> createState() => _TeablackDetailPageState();
}

class _TeablackDetailPageState extends State<TeablackDetailPage> {
  Map data = {};
  bool loading = true;
  initpage() async {
    Basic? res = await blackDetail(black_id: widget.id);
    if (res?.status != 0) {
      data = res?.data;
      loading = false;
      setState(() {});
    } else {
      CommonUtils.showText(res?.msg ?? '系统错误');
    }
  }

  @override
  void initState() {
    super.initState();
    initpage();
  }

  @override
  Widget build(BuildContext context) {
    return HeaderContainer(
        child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: PreferredSize(
                child: PageTitleBar(
                  title: '曝光详情',
                ),
                preferredSize: Size(double.infinity, 44.w)),
            body: loading
                ? PageStatus.loading(true)
                : Column(
                    children: [
                      Expanded(
                          child: PublicList(
                        api: "/api/black/getCommentList",
                        data: {'black_id': widget.id},
                        isSliver: true,
                        isShow: true,
                        noRefresh: true,
                        nullText: '还没有评论哦～',
                        sliverHead: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 15.w),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(bottom: 15.w),
                                    child: GestureDetector(
                                      onTap: () {
                                        AppGlobal.appRouter?.push(CommonUtils.getRealHash('brokerHomepage/' +
                                            data['aff'].toString() +
                                            '/' +
                                            Uri.encodeComponent(data['thumb'].toString()) +
                                            '/' +
                                            Uri.encodeComponent(data['nickname'].toString())));
                                      },
                                      child: Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.all(Radius.circular(5.w)),
                                            child: Container(
                                              margin: new EdgeInsets.only(right: 9.5.w),
                                              width: 30.w,
                                              height: 30.w,
                                              child: LocalPNG(
                                                  url: 'assets/images/common/${data['thumb']}.png', fit: BoxFit.fill),
                                            ),
                                          ),
                                          Expanded(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  data['nickname'],
                                                  style: TextStyle(color: Color(0xFF1E1E1E), fontSize: 16.sp),
                                                ),
                                                SizedBox(
                                                  height: 4.5.w,
                                                ),
                                                Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    LocalPNG(
                                                      url: "assets/images/icon-black-loction.png",
                                                      width: 10.w,
                                                      height: 14.w,
                                                    ),
                                                    SizedBox(
                                                      width: 4.w,
                                                    ),
                                                    Text(
                                                      data['cityName'] ?? '未知',
                                                      style: TextStyle(color: StyleTheme.cTextColor, fontSize: 10.sp),
                                                    )
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                          Text(
                                            data['created_at'],
                                            style: TextStyle(color: Color(0xFFB4B4B4), fontSize: 12.sp),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (data["title"] != null && data["title"].isNotEmpty)
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 12.5.w),
                                      child: Text(
                                        "${data["title"]}",
                                        style: TextStyle(
                                            color: StyleTheme.color50, fontSize: 18.sp, fontWeight: FontWeight.w500),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 11.w),
                                    child: Text(
                                      "${data['content']}",
                                      style: TextStyle(color: StyleTheme.color50, fontSize: 15.sp),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (data['resources'] != null && data['resources'].isNotEmpty)
                                    Container(
                                      margin: EdgeInsets.only(bottom: 10.w),
                                      child: GridView.builder(
                                          itemCount: data['resources'].length,
                                          physics: NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          padding: EdgeInsets.zero,
                                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                              childAspectRatio: 1,
                                              crossAxisCount: 3,
                                              mainAxisSpacing: 5.w,
                                              crossAxisSpacing: 5.w),
                                          itemBuilder: (context, index) {
                                            return GestureDetector(
                                              onTap: () {
                                                AppGlobal.picMap = {'resources': data['resources'], 'index': index};
                                                context.push('/teaViewPicPage');
                                              },
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(5.w),
                                                child: Container(
                                                  width: 114.w,
                                                  height: 114.w,
                                                  child: ImageNetTool(
                                                    url: data['resources'][index]['url'],
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            );
                                          }),
                                    ),
                                  Text(
                                    "${data["view_num"]}浏览",
                                    style: TextStyle(color: StyleTheme.color153, fontSize: 11.sp),
                                  ),
                                  Text(
                                    '评论留言(${data["comment_num"] ?? 0})',
                                    style: TextStyle(
                                        fontSize: 18.sp, color: StyleTheme.color30, fontWeight: FontWeight.w500),
                                  ),
                                  SizedBox(
                                    height: 17.w,
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                        itemBuild: (context, index, comment, page, limit, getListData) {
                          return TeablankCommentItem(
                            black_id: widget.id,
                            comment: comment,
                            aff: data['aff'],
                          );
                        },
                      )),
                      GestureDetector(
                        onTap: () {
                          CommonUtils.routerTo('teablankCommentPage', extra: data);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          height: ScreenUtil().bottomBarHeight + 49.w,
                          padding: EdgeInsets.only(left: 15.w, right: 15.w, bottom: ScreenUtil().bottomBarHeight + 5.w),
                          child: Container(
                            decoration:
                                BoxDecoration(color: StyleTheme.color245, borderRadius: BorderRadius.circular(17.5.w)),
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            height: 35.w,
                            child: Row(
                              children: [
                                Text(
                                  '请输入评论',
                                  style: TextStyle(fontSize: 15.sp, color: StyleTheme.color102),
                                )
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  )));
  }
}

class TeablankCommentItem extends StatefulWidget {
  final dynamic black_id;
  final dynamic aff;
  final Map comment;
  const TeablankCommentItem({Key? key, this.aff, required this.comment, this.black_id}) : super(key: key);

  @override
  State<TeablankCommentItem> createState() => _TeablankCommentItemState();
}

class _TeablankCommentItemState extends State<TeablankCommentItem> {
  bool isTap = false;
  int like_count = 0;
  //回复评论
  replyItemComment(_id, String nickname) {
    InputDialog.show(context, '回复给 $nickname', limitingText: 99, btnText: '发送', onSubmit: (value) {
      if (value != null) {
        blackCreateComment(p_id: _id, black_id: widget.black_id, content: value, medias: []).then((res) {
          if (res?.data != 0) {
            CommonUtils.showText(res?.msg ?? '评论成功,请耐心等待审核');
          } else {
            CommonUtils.showText(res?.msg ?? "系统错误");
          }
        });
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    like_count = widget.comment['like_count'];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: new EdgeInsets.only(
        left: 15.w,
        right: 15.w,
        bottom: 20.w,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                margin: new EdgeInsets.only(right: 9.5.w),
                child: GestureDetector(
                  onTap: () {
                    AppGlobal.appRouter?.push(CommonUtils.getRealHash('brokerHomepage/' +
                        widget.comment['aff'].toString() +
                        '/' +
                        Uri.encodeComponent(widget.comment['thumb'].toString()) +
                        '/' +
                        Uri.encodeComponent(widget.comment['nickname'].toString())));
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15.w),
                    child: Container(
                      height: 30.w,
                      width: 30.w,
                      child: Avatar(type: widget.comment['user']['thumb'].toString()),
                    ),
                  ),
                ),
              ),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.comment['user']['nickname'].toString(),
                    style: TextStyle(
                      color: StyleTheme.color31,
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(
                    height: 5.5.w,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "${DateUtil.formatDate(
                          DateTime.fromMillisecondsSinceEpoch(widget.comment['created_at'] * 1000), // 转成毫秒
                          format: "yyyy-MM-dd",
                        )}",
                        style: TextStyle(color: StyleTheme.color153, fontSize: 11.sp),
                      ),
                      if (widget.comment['time_str'] != null && widget.comment['time_str'].trim().isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(left: 6.w),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                alignment: Alignment.center,
                                height: 13.w,
                                padding: EdgeInsets.symmetric(horizontal: 6.w),
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                        colors: [Color.fromRGBO(255, 144, 0, 1), Color.fromRGBO(255, 194, 30, 1)]),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(6.5.w),
                                      bottomLeft: Radius.circular(6.5.w),
                                      bottomRight: Radius.circular(6.5.w),
                                    )),
                                child: Text(
                                  "${widget.comment['time_str']}",
                                  style: TextStyle(color: Color.fromRGBO(248, 253, 255, 1), fontSize: 8.sp),
                                ),
                              )
                            ],
                          ),
                        ),
                    ],
                  )
                ],
              ))
            ],
          ),
          if (widget.comment['content'] != null && widget.comment['content'] != '')
            Padding(
              padding: EdgeInsets.only(top: 12.w),
              child: Text(
                widget.comment['content'],
                style: TextStyle(color: StyleTheme.color102, fontSize: 14.sp),
              ),
            ),
          if (widget.comment['media'] != null && widget.comment['media'].isNotEmpty)
            GridView.builder(
              shrinkWrap: true,
              itemCount: widget.comment['media'].length,
              padding: EdgeInsets.symmetric(vertical: 11.w),
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, mainAxisSpacing: 7.5.w, crossAxisSpacing: 7.5.w, childAspectRatio: 1),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    AppGlobal.picMap = {'resources': widget.comment['media'], 'index': index};
                    context.push('/teaViewPicPage');
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5.w),
                    child: ImageNetTool(
                      url: widget.comment['media'][index]['url_str'],
                    ),
                  ),
                );
              },
            ),
          SizedBox(
            height: 15.5.w,
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () async {
                  if (isTap) {
                    CommonUtils.showText('请勿频繁操作');
                    return;
                  }
                  isTap = true;
                  Basic? res = await blackLikeToggle(comment_id: widget.comment['id']);
                  isTap = false;
                  if (res?.status != 0) {
                    widget.comment['is_liked'] = res?.data['is_like'] == 1;
                    if (widget.comment['is_liked']) {
                      like_count = like_count + 1;
                    } else {
                      like_count = like_count - 1;
                    }
                    setState(() {});
                  } else {
                    CommonUtils.showText(res?.msg ?? '系统错误');
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LocalPNG(
                      url: 'assets/images/${widget.comment['is_liked'] ? 'icon_like' : 'icon_unlike'}.png',
                      width: 15.w,
                      height: 15.w,
                    ),
                    SizedBox(
                      width: 5.w,
                    ),
                    Text(
                      widget.comment['is_liked'] ? '点赞' : '已点赞${CommonUtils.renderFixedNumber(like_count)}',
                      style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 12.sp),
                    )
                  ],
                ),
              ),
              SizedBox(
                width: 13.5.w,
              ),
              GestureDetector(
                onTap: () {
                  replyItemComment(widget.comment['id'], widget.comment["user"]['nickname']);
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LocalPNG(
                      url: 'assets/images/elegantroom/icon_reply.png',
                      width: 15.w,
                      height: 15.w,
                    ),
                    SizedBox(
                      width: 5.w,
                    ),
                    Text(
                      '回复',
                      style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 12.sp),
                    )
                  ],
                ),
              ),
            ],
          ),
          //二级评论
          if (widget.comment['child'] != null && widget.comment['child'].isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 2.w),
              margin: EdgeInsets.only(top: 11.5.w),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: StyleTheme.bottomappbarColor),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: (widget.comment['child'] as List).map((e) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 7.w),
                    child: Row(
                      children: [
                        Text.rich(
                          TextSpan(text: "${e['user']['nickname']} : ", children: [
                            if (widget.comment['aff'] == widget.aff)
                              WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: Align(
                                  alignment: Alignment.center,
                                  widthFactor: 1,
                                  heightFactor: 1,
                                  child: CommonUtils.authorWidget(),
                                ),
                              ),
                            TextSpan(text: "${e['content']}", style: TextStyle(color: StyleTheme.color102))
                          ]),
                          style: TextStyle(fontSize: 15.sp, color: StyleTheme.color34),
                        )
                      ],
                    ),
                  );
                }).toList(),
              ),
            )
        ],
      ),
    );
  }
}
