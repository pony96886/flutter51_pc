import 'package:chaguaner2023/components/avatar_widget.dart';
import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/page_title_bar.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/cgprivilege.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:chaguaner2023/view/im/im_page.dart';
import 'package:chaguaner2023/view/im/imdb.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class MsgListPage extends StatefulWidget {
  MsgListPage({Key? key}) : super(key: key);

  @override
  _MsgListPageState createState() => _MsgListPageState();
}

class _MsgListPageState extends State<MsgListPage> {
  @override
  Widget build(BuildContext context) {
    return HeaderContainer(
        child: Scaffold(
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        child: PageTitleBar(
          isNoback: true,
          title: '消息',
        ),
        preferredSize: Size(double.infinity, 44.w),
      ),
      body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          child: CustomScrollView(
            cacheExtent: 5.sh,
            slivers: [
              SliverToBoxAdapter(
                  child: Container(
                margin: EdgeInsets.only(bottom: 15.w),
                decoration: BoxDecoration(
                  boxShadow: [
                    //阴影
                    BoxShadow(
                        color: Colors.black12,
                        offset: Offset(0, 0.5.w),
                        blurRadius: 2.5.w)
                  ],
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(
                    10.w,
                  ),
                ),
                child: ValueListenableBuilder(
                  valueListenable: AppGlobal.noticeList,
                  builder: (context, List value, child) {
                    return Column(
                      children: value.asMap().keys.map((e) {
                        return GestureDetector(
                          onTap: () {
                            AppGlobal.appRouter?.push(
                                CommonUtils.getRealHash(value[e]['router']));
                          },
                          behavior: HitTestBehavior.translucent,
                          child: Container(
                            margin: new EdgeInsets.symmetric(
                                horizontal: 15.w, vertical: 10.w),
                            child: Row(
                              children: [
                                Container(
                                  margin: new EdgeInsets.only(right: 9.5.w),
                                  width: 45.w,
                                  height: 45.w,
                                  child: LocalPNG(
                                    width: 45.w,
                                    height: 45.w,
                                    url: value[e]['icon'],
                                  ),
                                ),
                                Expanded(
                                    child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Text(
                                          value[e]['title'],
                                          style: TextStyle(
                                              color: StyleTheme.cTitleColor,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 16.sp),
                                        ),
                                        Text(
                                          value[e]['time'] == '' ||
                                                  value[e]['time'] == null
                                              ? ''
                                              : CommonUtils.getCgTime(int.parse(
                                                  value[e]['time'].toString())),
                                          style: TextStyle(
                                              color: StyleTheme.cTextColor,
                                              fontSize: 12.sp),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Expanded(
                                            child: value[e]['content'] != '' &&
                                                    value[e]['content'] != null
                                                ? (value[e]['content'] is List
                                                    ? Text.rich(
                                                        TextSpan(
                                                          children: value[e]
                                                                  ['content']
                                                              .asMap()
                                                              .keys
                                                              .map<TextSpan>(
                                                                  (i) {
                                                            return TextSpan(
                                                                text: value[e]
                                                                        ['content']
                                                                    [
                                                                    i]['value'],
                                                                style: TextStyle(
                                                                    color: Color(
                                                                        int.parse(value[e]['content'][i]
                                                                            [
                                                                            'color'])),
                                                                    fontSize:
                                                                        14.sp));
                                                          }).toList(),
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      )
                                                    : Text(
                                                        value[e]['content']
                                                            .toString(),
                                                        style: TextStyle(
                                                            color: Color(
                                                                0xFF787878),
                                                            fontSize: 14.sp),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ))
                                                : Text(
                                                    '还没有收到过消息哦～',
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xFF787878),
                                                        fontSize: 14.sp),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )),
                                        value[e]['readCount'] != 0
                                            ? Container(
                                                padding:
                                                    new EdgeInsets.symmetric(
                                                        horizontal: 6.5.w),
                                                height: 15.w,
                                                decoration: BoxDecoration(
                                                    color: Color(0xFFE23828),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.w)),
                                                child: Text(
                                                  value[e]['readCount']
                                                      .toString(),
                                                  style: TextStyle(
                                                      fontSize: 12.sp,
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              )
                                            : Container(),
                                      ],
                                    )
                                  ],
                                ))
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              )),
              SliverToBoxAdapter(
                child: Container(
                  padding: new EdgeInsets.symmetric(
                      horizontal: 15.w, vertical: 10.w),
                  decoration: BoxDecoration(
                    boxShadow: [
                      //阴影
                      BoxShadow(
                          color: Colors.black12,
                          offset: Offset(0, 0.5.w),
                          blurRadius: 2.5.w)
                    ],
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      10.w,
                    ),
                  ),
                  child: ValueListenableBuilder(
                      valueListenable: AppGlobal.accountContact,
                      builder: (context, List<ContaictData> value, child) {
                        return ListView.builder(
                            padding: EdgeInsets.only(
                                bottom: 84.w +
                                    ScreenUtil().bottomBarHeight / 2 +
                                    AppGlobal.webBottomHeight),
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: value.length > 50 ? 50 : value.length,
                            itemBuilder: (context, index) {
                              return UserItem(
                                data: value[index],
                              );
                            });
                      }),
                ),
              )
            ],
          )),
    ));
  }
}

class UserItem extends StatefulWidget {
  final ContaictData? data;
  UserItem({Key? key, this.data}) : super(key: key);

  @override
  _UserItemState createState() => _UserItemState();
}

class _UserItemState extends State<UserItem> {
  ContaictData? user;
  int unRead = 0;
  bool isShow = true;
  @override
  void initState() {
    super.initState();
    user = widget.data;
    AppGlobal.appDb!.gelUnreadLength(widget.data!.userUuid!).then((value) {
      unRead = value;
      setState(() {});
    });
  }

  deleteItem() {
    AppGlobal.appDb!.deleteChatRecord(widget.data!.id!).then((value) {
      isShow = false;
      setState(() {});
    });
  }

  @override
  void didUpdateWidget(covariant UserItem oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    // if (oldWidget.data.messageId != widget.data.messageId) {
    AppGlobal.appDb!.gelUnreadLength(widget.data!.userUuid!).then((value) {
      unRead = value;
      user = widget.data;
      setState(() {});
    });
    // }
  }

  @override
  Widget build(BuildContext context) {
    String typeStr = '';
    if (user!.lastMsgType == 'photos') {
      typeStr = '[图片]';
    } else if (user!.lastMsgType == 'videos') {
      typeStr = '[视频]';
    } else if (user!.lastMsgType == 'product') {
      typeStr = '[卡片信息]';
    } else {
      typeStr = AppGlobal.emoji.emojify(user!.lastMsgContent!);
    }
    return !isShow
        ? SizedBox()
        : Slidable(
            endActionPane: ActionPane(
              motion: ScrollMotion(),
              children: [
                SizedBox(
                  width: 15.w,
                ),
                SlidableAction(
                  onPressed: (context) {
                    deleteItem();
                  },
                  spacing: 1,
                  backgroundColor: StyleTheme.cDangerColor,
                  foregroundColor: Colors.white,
                  icon: Icons.delete_forever,
                  label: '删除',
                ),
              ],
            ),
            child: GestureDetector(
              onTap: () {
                if (!CgPrivilege.getPrivilegeStatus(
                    PrivilegeType.infoSystem, PrivilegeType.privilegeIm)) {
                  CommonUtils.showVipDialog(
                      context,
                      PrivilegeType.infoSysteString +
                          PrivilegeType.privilegeImString);
                  return;
                }
                AppGlobal.chatUser = FormUserMsg(
                  avatar: user!.userAvatar,
                  uuid: user!.userUuid,
                  nickname: user!.userNickname,
                );
                AppGlobal.appRouter?.push(CommonUtils.getRealHash('llchat'));
              },
              behavior: HitTestBehavior.translucent,
              child: Container(
                margin: new EdgeInsets.symmetric(vertical: 5.w),
                child: Row(
                  children: [
                    Container(
                      margin: new EdgeInsets.only(right: 9.5.w),
                      width: 45.w,
                      height: 45.w,
                      child: Avatar(
                        type: user!.userAvatar,
                        onPress: () {
                          if (user!.aff == '') return;
                          AppGlobal.appRouter?.push(CommonUtils.getRealHash(
                              'brokerHomepage/' +
                                  user!.aff.toString() +
                                  '/' +
                                  Uri.encodeComponent(
                                      user!.userAvatar.toString()) +
                                  '/' +
                                  Uri.encodeComponent(
                                      user!.userNickname.toString())));
                        },
                      ),
                    ),
                    Expanded(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Text(
                              user!.userNickname!,
                              style: TextStyle(
                                  color: StyleTheme.cTitleColor,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16.sp),
                            ),
                            Text(
                              user!.lastMsgTime == null
                                  ? ''
                                  : CommonUtils.getCgTime(
                                      int.parse(user!.lastMsgTime!)),
                              style: TextStyle(
                                  color: StyleTheme.cTextColor,
                                  fontSize: 12.sp),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                                child: Text(
                              typeStr,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: StyleTheme.cBioColor, fontSize: 14.sp),
                            )),
                            unRead == 0
                                ? Container()
                                : Container(
                                    height: 16.w,
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 6.6.w),
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(8.w),
                                        color: Color(0XFFe23838)),
                                    child: Text(
                                      unRead.toString(),
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 12.w),
                                    ),
                                  )
                          ],
                        )
                      ],
                    ))
                  ],
                ),
              ),
            ));
  }
}
