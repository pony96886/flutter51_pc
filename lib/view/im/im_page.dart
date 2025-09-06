import 'dart:async';
import 'dart:convert';

import 'package:bot_toast/bot_toast.dart';
import 'package:chaguaner2023/components/avatar_widget.dart';
import 'package:chaguaner2023/components/card/infoCard.dart';
import 'package:chaguaner2023/components/cgDialog.dart';
import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/page_status.dart';
import 'package:chaguaner2023/components/pagetitlebar.dart';
import 'package:chaguaner2023/components/upload/start_upload.dart';
import 'package:chaguaner2023/components/upload/upload_resouce.dart';
import 'package:chaguaner2023/store/global.dart';
import 'package:chaguaner2023/store/homeConfig.dart';
import 'package:chaguaner2023/store/sharedPreferences.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/index.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:chaguaner2023/utils/netimage_tool.dart';
import 'package:chaguaner2023/view/im/im.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../utils/cache/image_net_tool.dart';

class FormUserMsg {
  final String? avatar;
  final String? uuid;
  final String? nickname;
  final bool? isGirl;
  final bool? isAgent; //是否是经纪人
  final bool? isVipDetail; //是否是从详情跳转过来的
  const FormUserMsg(
      {this.avatar = '',
      this.uuid = '',
      this.nickname,
      this.isGirl = false,
      this.isVipDetail = false,
      this.isAgent = false});
}

class LlImKey {
  static String pullMessage = 'pullMessage';
  static String sendMessage = 'sendMessage';
  static String isTyping = 'isTyping';
  static String isOnline = 'isOnline';
}

class LLchat extends StatefulWidget {
  LLchat({Key? key}) : super(key: key);

  @override
  _LLchatState createState() => _LLchatState();
}

class _LLchatState extends State<LLchat> with SingleTickerProviderStateMixin {
  Key centerKey = Key('im_center');
  ScrollController imController = ScrollController();
  ValueNotifier<bool> showUpload = ValueNotifier<bool>(false);
  ValueNotifier<bool> isNewmsg = ValueNotifier<bool>(false);
  ValueNotifier<bool> showList = ValueNotifier<bool>(false);
  ValueNotifier<String> onlineText = ValueNotifier<String>('正在连接...');
  bool showChat = false;
  AnimationController? inputAnimation;
  TextEditingController? _textEditingController;
  bool loading = true;
  List chatList = [];
  List newChatList = [];
  bool isInput = false;
  Timer? inputTimer;
  FocusNode? _focusNode;
  Map? requireData; //意向单信息
  String? requireDetail; //意向单描述
  Map? _mzDetail; // 最后一单的妹子信息
  String lkjsbzj = '请勿引导用户在其他平台支付定金或发送自己的联系方式给客人，否则将扣除保证金！';
  String lakjsd2 = '请通过平台与茶老板或茶女郎沟通以及支付预约金，私下交易被坑平台不承担任何责任！';
  String timeasd = '专属客服的工作时间: 10:00 - 22:00';
  int page = 1;
  bool isLoading = false;
  bool isAll = false;
  FormUserMsg? useInfo;
  int officialAppointmentPrice = 100;
  String girlType = "中端妹妹";
  List _typeValueList = [
    {'name': '中端妹妹', 'value': 100},
    {'name': '高端妹妹', 'value': 200},
    {'name': '极品妹妹', 'value': 500}
  ];
  bool isDataEmpty() {
    return chatList.length + newChatList.length == 0;
  }

  getUserOnline(arg) {
    DateTime currentTime = new DateTime.now();
    int _second = currentTime.millisecondsSinceEpoch;
    if (_second / 1000 - arg > 30) {
      String _time = RelativeDateFormat.format(DateTime.fromMillisecondsSinceEpoch(arg * 1000));
      onlineText.value = _time.toString() + '在线';
    } else {
      onlineText.value = '对方在线';
    }
  }

  sendMessage({String? content, String? contentType, String? ext}) {
    String _ext = JsonEncoder().convert({
      'uuid': WebSocketUtility.uuid,
      'avatar': WebSocketUtility.avatar,
      'aff': WebSocketUtility.aff,
      'agent': WebSocketUtility.agent,
      'vipLevel': WebSocketUtility.vipLevel,
      'nickname': WebSocketUtility.nickname
    });
    WebSocketUtility().sendMessage('message/chat', {
      "to_id": useInfo!.uuid,
      "type": "one",
      "content": AppGlobal.emoji.unemojify(content!),
      "action": "",
      "msgType": contentType ?? 'text',
      "microtime": DateTime.now().millisecondsSinceEpoch, //microtime 为客户端发送消息毫秒时间,
      "ext": _ext,
      "avatar": WebSocketUtility.avatar,
      "nickname": WebSocketUtility.nickname,
      "duration": "默认空；语音长度；视频时长或其他自定义单位"
    });
  }

  onTyping(e) {
    if (e) {
      inputAnimation!.forward();
    } else {
      inputAnimation!.reverse();
    }
  }

  kefuItem(String avatar, dynamic data) {
    String _status = '休息中';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 40.w,
                height: 40.w,
                margin: EdgeInsets.only(right: 10.w),
                child: Avatar(
                  type: 'chaxiaowai',
                )),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  data['nickname'],
                  style: TextStyle(fontSize: 15.sp, color: StyleTheme.cTitleColor),
                ),
                Text(
                  data['work'] == 0 ? _status : '接待中',
                  style: TextStyle(
                      fontSize: 11.sp, color: data['work'] == 0 ? StyleTheme.cDangerColor : Color(0xff25b864)),
                )
              ],
            )
          ],
        ),
        GestureDetector(
          onTap: () {
            PersistentState.saveState('vipkefu', json.encode(data));
            UserInfo.officialUuid = data['uuid'];
            UserInfo.officialName = data['nickname'];
            Navigator.of(context).pop('swich');
            AppGlobal.chatUser =
                FormUserMsg(isGirl: true, uuid: data['uuid'], nickname: data['nickname'], avatar: 'chaxiaowai');
            AppGlobal.appRouter?.push(CommonUtils.getRealHash('llchat'));
          },
          child: Container(
            width: 90.w,
            height: 30.w,
            decoration: BoxDecoration(color: Color(0xfff5f5f5), borderRadius: BorderRadius.circular(30)),
            child: Center(
              child: Text(
                '确认更换',
                style: TextStyle(color: Color(0xffdd5341), fontSize: 18.sp),
              ),
            ),
          ),
        )
      ],
    );
  }

  //获取意向单信息
  getLetterIntent() {
    bool isAgent = Provider.of<HomeConfig>(context, listen: false).member.agent == 1;
    getBothRequire(isAgent ? WebSocketUtility.uuid : useInfo!.uuid, isAgent ? useInfo!.uuid : WebSocketUtility.uuid)
        .then((res) {
      if (res!['data'] == null) return;
      if (res['status'] != 0) {
        String cityName = res['data']['cityName'];
        String latstTimes = res['data']['latestTime'].toString();
        String costWayss = res['data']['costWay'].replaceAll(',', '、');
        String serviceTyess = res['data']['serviceType'].replaceAll(',', '、');
        String serviceTags = res['data']['serviceTag'].replaceAll(',', '、');
        String highestPrice = res['data']['highestPrice'].toString();
        dynamic commentsre = res['data']['comment'] != null ? res['data']['comment'] : '--';

        requireData = res['data'];
        requireDetail = res['data'] == null
            ? null
            : '$cityName/最晚$latstTimes/$costWayss,$serviceTyess、最高接受$highestPrice/$serviceTags$commentsre';
        setState(() {});
      } else {
        CommonUtils.showText(res['msg']);
      }
    });
  }

  cancelOdeer(int status) {
    var curTime = new DateTime.now().millisecondsSinceEpoch;
    var isExpired = (requireData!['expireTime'] * 1000 - curTime) <= 0; //意向单是否已过期
    String pageaa = '您的意向单已过期,您取消意向单后需发布新的意向单茶老板才能再次看见接单,确定要取消该意向单吗?';
    String canclesss = '取消意向单后茶老板可再次抢单,确定要取消该意向单吗?';
    String askdff = '预约将不在消耗元宝数量,预约成功之后只有茶老板才能取消预约，如需取消预约单可以联系茶老板或在线客服,是否确定预约?';
    CgDialog.cgShowDialog(
        context,
        '提示',
        status == 1
            ? (isExpired
                ? pageaa //过期的意向单
                : canclesss) //正常的意向单
            : askdff //确认预约
        ,
        ['取消', '确定'], callBack: () {
      //用户更改意向单状态  1取消 3预约
      setOder(requireData!['id'], status).then((res) {
        if (res!['status'] != 0) {
          getLetterIntent();
          String cenclSS = '取消成功';
          String yycgStr = '预约成功';
          requireData = null;
          setState(() {});
          BotToast.showText(text: status == 1 ? cenclSS : yycgStr, align: Alignment(0, 0));
        } else {
          BotToast.showText(text: res['msg'], align: Alignment(0, 0));
        }
      });
    });
  }

  onSendMessage(data) {
    if (isDataEmpty()) {
      _textEditingController!.text = '';
      CommonUtils.dismissKeyboard(context);
      newChatList.add(data);
      setState(() {});
      showList.value = true;
      return;
    }
    bool isSlide = true;
    if (imController.hasClients) {
      isSlide = (imController.position.pixels >= imController.position.maxScrollExtent - 1.sh);
    }
    bool isSelf = data.fromUuid == WebSocketUtility.uuid;
    _textEditingController!.text = '';
    CommonUtils.dismissKeyboard(context);
    newChatList.add(data);
    setState(() {});
    if (isSlide || (isSelf && !isSlide)) {
      Future.delayed(Duration(milliseconds: 200), () {
        if (!imController.hasClients) return;
        imController.animateTo(imController.position.maxScrollExtent,
            duration: Duration(milliseconds: 200), curve: Curves.easeIn);
      });
    } else {
      isNewmsg.value = true;
    }
  }

  Future<String?> _showModalBottomSheet() {
    return showModalBottomSheet<String>(
      context: context,
      builder: (BuildContext context) {
        return Container(
            height: 360.w,
            color: Colors.white,
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 40.w),
                  child: ListView.separated(
                      itemBuilder: (BuildContext context, int index) {
                        return kefuItem('chaxiaowai', UserInfo.kefuList![index]);
                      },
                      separatorBuilder: (BuildContext context, int index) => Divider(
                            color: Colors.transparent,
                            height: 20.w,
                          ),
                      itemCount: UserInfo.kefuList!.length),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: LocalPNG(
                      url: "assets/images/nav/closemenu.png",
                      width: 30.w,
                      height: 30.w,
                    ),
                  ),
                )
              ],
            ));
      },
    );
  }

  cleanMessage(useInfo) {
    AppGlobal.appDb!.cleanMsg(useInfo).then((value) {
      AppGlobal.appDb!.gelUnreadLength(WebSocketUtility.uuid!).then((value) {
        AppGlobal.unreadMessage.value = (value ?? 0);
      });
    });
  }

  //API接口获取聊天记录
  apiPullMessage() {
    getImHistory(page: page, uuid: useInfo!.uuid).then((res) {
      if (res!['status'] != 0) {
        loading = false;
        if (res['data'] == null || res['data'].length == 0) {
          isAll = true;
        }
        List<MessageModel> _msgList = (res['data'] ?? []).asMap().keys.map<MessageModel>((e) {
          return MessageModel.fromJson(res['data'][e]);
        }).toList();
        if (page == 1) {
          chatList = _msgList;
          cleanMessage(useInfo);
        } else {
          chatList.addAll(_msgList);
        }
        chatList.sort((left, right) => left.createdAt.compareTo(right.createdAt));
        setState(() {});
        showList.value = true;
        if (page == 1) {
          Future.delayed(Duration(milliseconds: 200), () {
            if (!imController.hasClients) return;
            imController.jumpTo(imController.position.maxScrollExtent);
            showList.value = true;
          });
        }
      } else {
        chatList = [];
        loading = false;
        setState(() {});
        CommonUtils.showText(res['msg']);
      }
    }).whenComplete(() {
      isLoading = false;
    });
  }

  //IM接口获取聊天记录
  pullMessage(data) {
    loading = false;
    chatList = data;
    chatList.sort((left, right) => left.createdAt.compareTo(right.createdAt));
    setState(() {});
    if (isDataEmpty()) return;
    try {
      Future.delayed(Duration(milliseconds: 200), () {
        if (!imController.hasClients) return;
        imController.jumpTo(imController.position.maxScrollExtent);
        showList.value = true;
      });
    } catch (e) {}
  }

  @override
  void initState() {
    super.initState();
    useInfo = AppGlobal.chatUser;
    Future.delayed(Duration(milliseconds: 500), () {
      apiPullMessage();
    });
    dynamic receiveUuidS = WebSocketUtility.uuid! + 'ImKey' + useInfo!.uuid!;
    PersistentState.getState('$receiveUuidS').then((mzInfo) {
      if (mzInfo != null) {
        _mzDetail = json.decode(mzInfo);
        setState(() {});
        if (_mzDetail!['type'] == 'vipOder') {
          bossSendMessage(_mzDetail!['id']);
        }
      }
    });
    getLetterIntent();
    EventBus().on(LlImKey.pullMessage, pullMessage);
    EventBus().on(LlImKey.sendMessage, onSendMessage);
    EventBus().on(LlImKey.isTyping, onTyping);
    EventBus().on(LlImKey.isOnline, getUserOnline);
    _textEditingController = TextEditingController();
    WebSocketUtility().getOnline(useInfo!.uuid!);
    //通过IM接口获取数据
    // WebSocketUtility().pullMessage(useInfo.uuid);
    _focusNode = FocusNode();
    _focusNode!.addListener(() {
      if (_focusNode!.hasFocus) {
        showUpload.value = false;
      }
    });
    inputAnimation = AnimationController(vsync: this, duration: Duration(milliseconds: 500))
      ..drive(CurveTween(curve: Curves.easeIn));
  }

  @override
  void dispose() {
    EventBus().off(LlImKey.pullMessage, pullMessage);
    EventBus().off(LlImKey.sendMessage, onSendMessage);
    EventBus().off(LlImKey.isTyping, onTyping);
    EventBus().off(LlImKey.isOnline, getUserOnline);
    UploadFileList.dispose();
    showUpload.dispose();
    inputAnimation!.dispose();
    showList.dispose();
    isNewmsg.dispose();
    AppGlobal.chatUser = null;
    if (WebSocketUtility.vipLevel! < 3) {
      WebSocketUtility.imToken = null;
      WebSocketUtility().closeSocket();
    }
    super.dispose();
  }

  Future<dynamic> onSubmit() async {
    BotToast.showLoading();
    var result = await onOfficialAppointment(money: officialAppointmentPrice);
    if (result!['status'] != 0) {
      BotToast.closeAllLoading();
      sendMessage(content: "我已支付预约金$officialAppointmentPrice元宝，预约$girlType，订单号: ${result['data']['order_no']}");
      return true;
    } else {
      BotToast.closeAllLoading();
      BotToast.showText(text: result['msg'], align: Alignment(0, 0));
    }
  }

  Widget getLetterIintentWidget(bool isAgent) {
    if (isAgent) {
      return GestureDetector(
        onTap: () {
          if (useInfo!.isVipDetail!) {
            context.pop();
          } else {
            AppGlobal.appRouter?.push(CommonUtils.getRealHash('intentionDetailPage/' + requireData!['id'].toString()));
          }
        },
        child: Container(
            padding: EdgeInsets.symmetric(horizontal: 15.w),
            height: 50.w,
            color: StyleTheme.bottomappbarColor,
            child: Center(
              child: Row(
                children: <Widget>[
                  Expanded(
                      child: Text(
                    '品茶意向:' + requireDetail.toString(),
                    style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 12.sp, fontWeight: FontWeight.w500),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  )),
                  SizedBox(
                    width: 33.w,
                  ),
                  LocalPNG(
                    width: 12.w,
                    height: 19.w,
                    url: 'assets/images/im_right.png',
                  )
                ],
              ),
            )),
      );
    } else {
      return Container(
        height: 50.w,
        child: Flex(
          direction: Axis.horizontal,
          children: <Widget>[
            Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: () {
                    cancelOdeer(1);
                  },
                  child: Container(
                    color: Color(0xffc8c8c8),
                    height: double.infinity,
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          '取消',
                          style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '取消后其他茶老板可重新抢单',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                          ),
                        )
                      ],
                    ),
                  ),
                )),
            Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: () {
                    cancelOdeer(3);
                  },
                  child: Container(
                    color: StyleTheme.cDangerColor,
                    height: double.infinity,
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          '预约',
                          style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '和茶老板谈妥后，无需再支付',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                          ),
                        )
                      ],
                    ),
                  ),
                )),
          ],
        ),
      );
    }
  }

  Widget _bottomInput() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(width: 1.w, color: Color(0xFFEEEEEE)),
        ),
      ),
      padding: EdgeInsets.only(
        left: 10.w,
        right: 10.w,
        top: 10.w,
        bottom: 15.w,
      ),
      child: Row(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              showUpload.value = !showUpload.value;
              CommonUtils.dismissKeyboard(context);
            },
            child: LocalPNG(
              height: 25.w,
              width: 25.w,
              url: 'assets/images/msg/add.png',
            ),
          ),
          SizedBox(
            width: 15.w,
          ),
          Expanded(
            child: Container(
//              height: GVScreenUtil.setWidth(70),
              decoration:
                  BoxDecoration(color: StyleTheme.bottomappbarColor, borderRadius: BorderRadius.circular(17.5.w)),
              child: TextField(
                focusNode: _focusNode,
                minLines: 1,
                maxLines: 4,
                controller: _textEditingController,
                onSubmitted: (e) {
                  if (_textEditingController!.text == '') {
                    return CommonUtils.showText('请输入消息内容');
                  }
                  sendMessage(content: _textEditingController!.text);
                },
                onChanged: (e) {
                  if (!isInput) {
                    isInput = true;
                    WebSocketUtility().typingStatus(true);
                  }
                  if (inputTimer?.isActive ?? false) {
                    inputTimer?.cancel();
                  }

                  inputTimer = Timer.periodic(Duration(milliseconds: 1500), (timer) {
                    inputTimer?.cancel();
                    isInput = false;
                    WebSocketUtility().typingStatus(false);
                  });
                },
                decoration: InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: StyleTheme.cBioColor, fontSize: 16.sp),
                    hintText: "请输入消息..."),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              if (_textEditingController!.text == '') {
                return CommonUtils.showText('请输入消息内容');
              }
              sendMessage(content: _textEditingController!.text);
            },
            child: Container(
              margin: new EdgeInsets.only(left: 15.w),
              width: 55.w,
              height: 30.w,
              decoration: BoxDecoration(color: StyleTheme.cDangerColor, borderRadius: BorderRadius.circular(5.w)),
              child: Center(
                child: Text(
                  '发送',
                  style: TextStyle(color: Colors.white, fontSize: 14.sp),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _bottomFunction(bool isAgent) {
    return ValueListenableBuilder(
        valueListenable: showUpload,
        builder: (context, bool value, child) {
          return AnimatedContainer(
            duration: Duration(milliseconds: 200),
            height: value ? 100.w : 0,
            margin: EdgeInsets.only(bottom: 10.w),
            width: 1.sw,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Stack(
                  children: [
                    LocalPNG(
                      url: 'assets/images/msg/photo.png',
                      width: 90.w,
                      height: 90.w,
                    ),
                    Positioned.fill(
                        child: UploadResouceWidget(
                      maxLength: 1,
                      isIndependent: true,
                      parmas: 'images',
                      transparent: true,
                      onSelect: () {
                        StartUploadFile.upload().then((value) {
                          sendMessage(content: value!['images'][0]['url'], contentType: 'photos');
                        }).whenComplete(() {
                          UploadFileList.allFile['images']!.originalUrls.clear();
                          UploadFileList.allFile['images']!.urls.clear();
                        });
                      },
                    ))
                  ],
                ),
                // Stack(
                //   children: [
                //     LocalPNG(
                //       url: 'assets/images/msg/video.png',
                //       width: 90.w,
                //       height: 90.w,
                //     ),
                //     Positioned.fill(
                //         child: Opacity(
                //       opacity: 0,
                //       child: UploadResouceWidget(
                //         maxLength: 1,
                //         isIndependent: true,
                //         parmas: 'video',
                //         uploadType: 'video',
                //         onSelect: () {
                //           StartUploadFile.upload().then((value) {
                //             if (value != null) {
                //               sendMessage(
                //                   content: value['video'][0]['url'],
                //                   contentType: 'videos');
                //             }
                //           }).whenComplete(() {
                //             UploadFileList.allFile['video'].originalUrls
                //                 .clear();
                //             UploadFileList.allFile['video'].urls.clear();
                //           });
                //         },
                //       ),
                //     ))
                //   ],
                // ),
                isAgent
                    ? GestureDetector(
                        child: LocalPNG(
                          url: 'assets/images/msg/girl.png',
                          width: 90.w,
                          height: 90.w,
                        ),
                        onTap: () {
                          context.push(CommonUtils.getRealHash('shareMeiziPage'));
                        },
                      )
                    : Container(
                        width: 90.w,
                      ),
              ],
            ),
          );
        });
  }

  String getHeadText() {
    return Provider.of<HomeConfig>(context).member.agent == 1 ? lkjsbzj : lakjsd2;
  }

  Widget checkboxServes(Map girlMap, Function setBottomSheetState) {
    String seleStr = 'select';
    String luesS = 'unselect';
    String sercStr = girlType.contains(girlMap['name']) ? seleStr : luesS;
    return GestureDetector(
      onTap: () {
        setBottomSheetState(() {
          girlType = girlMap['name'];
          officialAppointmentPrice = girlMap['value'];
        });
      },
      child: Container(
        margin: EdgeInsets.only(left: CommonUtils.getWidth(20)),
        child: Row(
          children: <Widget>[
            Container(
              width: CommonUtils.getWidth(30),
              height: CommonUtils.getWidth(30),
              margin: EdgeInsets.only(right: CommonUtils.getWidth(8)),
              child: LocalPNG(
                width: CommonUtils.getWidth(30),
                height: CommonUtils.getWidth(30),
                url: 'assets/images/card/$sercStr.png',
                fit: BoxFit.cover,
              ),
            ),
            Text(girlMap['name'])
          ],
        ),
      ),
    );
  }

  showPay() {
    return showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          var myMoney = Provider.of<HomeConfig>(context).member.money;
          return StatefulBuilder(builder: (context, setBottomSheetState) {
            return Container(
              color: Colors.transparent,
              child: Container(
                height: 350.w + ScreenUtil().bottomBarHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Container(
                        padding: EdgeInsets.only(top: CommonUtils.getWidth(40), left: 15.w, right: 15.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              child: Center(
                                  child: Text(
                                '支付预约金',
                                style: TextStyle(
                                    fontSize: 18.sp, color: StyleTheme.cTitleColor, fontWeight: FontWeight.w500),
                              )),
                            ),
                            Column(
                              children: [
                                Container(
                                  margin: EdgeInsets.only(top: 30.w, bottom: 14.w),
                                  child: Center(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        LocalPNG(
                                          width: CommonUtils.getWidth(76),
                                          height: CommonUtils.getWidth(54),
                                          url: 'assets/images/detail/vip-yuanbao.png',
                                          fit: BoxFit.contain,
                                        ),
                                        SizedBox(
                                          width: CommonUtils.getWidth(22),
                                        ),
                                        Text.rich(TextSpan(
                                            text: '$officialAppointmentPrice',
                                            style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 36.sp),
                                            children: [
                                              TextSpan(
                                                text: '元宝',
                                                style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 18.sp),
                                              )
                                            ])),
                                      ],
                                    ),
                                  ),
                                ),
                                Consumer<HomeConfig>(
                                  builder: (context, homeConfig, child) {
                                    return Text("账户余额${homeConfig.member.money}元宝",
                                        style: TextStyle(color: StyleTheme.cDangerColor, fontSize: 12.sp));
                                  },
                                )
                              ],
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 33.w, bottom: CommonUtils.getWidth(40)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text('妹子类型',
                                      style: TextStyle(
                                          color: StyleTheme.cTitleColor, fontSize: CommonUtils.getFontSize(28))),
                                  Row(
                                    children: <Widget>[
                                      for (var item2 in _typeValueList) checkboxServes(item2, setBottomSheetState)
                                    ],
                                  )
                                ],
                              ),
                            ),
                            Expanded(
                                child: Center(
                              child: GestureDetector(
                                onTap: () {
                                  if (myMoney < officialAppointmentPrice) {
                                    AppGlobal.appRouter?.push(CommonUtils.getRealHash('ingotWallet'));
                                  } else {
                                    onSubmit().then((value) => Navigator.of(context).pop());
                                  }
                                },
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(bottom: CommonUtils.getWidth(20)),
                                      width: CommonUtils.getWidth(550),
                                      height: 50.w,
                                      child: Stack(
                                        children: [
                                          LocalPNG(
                                            width: CommonUtils.getWidth(550),
                                            height: CommonUtils.getWidth(100),
                                            url: 'assets/images/mymony/money-img.png',
                                          ),
                                          Center(
                                              child: Text(
                                            myMoney < officialAppointmentPrice ? '余额不足,去充值' : '立即支付',
                                            style: TextStyle(fontSize: 15.w, color: Colors.white),
                                          )),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ))
                          ],
                        )),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: LocalPNG(
                          url: "assets/images/nav/closemenu.png",
                          width: 30.w,
                          height: 30.w,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    bool isAgent = Provider.of<HomeConfig>(context).member.agent == 1;
    AppGlobal.chatUser = useInfo;
    return HeaderContainer(
      child: GestureDetector(
        onTap: () {
          CommonUtils.dismissKeyboard(context);
          showUpload.value = false;
        },
        behavior: HitTestBehavior.translucent,
        child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: PreferredSize(
                child: ValueListenableBuilder(
                    valueListenable: onlineText,
                    builder: (context, String value, child) {
                      return PageTitleBar(
                        title: useInfo!.nickname,
                        isIm: true,
                        onlineText: value,
                        rightWidget: isAgent && _mzDetail == null
                            ? GestureDetector(
                                onTap: () {
                                  AppGlobal.appRouter?.push(CommonUtils.getRealHash('workbenchPage'));
                                },
                                child: Center(
                                  child: Container(
                                    margin: new EdgeInsets.only(right: 15.w),
                                    child: Text(
                                      '工作台',
                                      style: TextStyle(
                                          color: StyleTheme.cTitleColor, fontSize: 15.sp, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ))
                            : (useInfo!.isGirl!
                                ? GestureDetector(
                                    onTap: () {
                                      _showModalBottomSheet().then((value) {
                                        if (value == 'swich') {
                                          useInfo = AppGlobal.chatUser;
                                          chatList = [];
                                          loading = true;
                                          dynamic receiveUuidS = WebSocketUtility.uuid! + 'ImKey' + useInfo!.uuid!;
                                          PersistentState.getState('$receiveUuidS').then((mzInfo) {
                                            if (mzInfo != null) {
                                              _mzDetail = json.decode(mzInfo);
                                            }
                                          });
                                          setState(() {});
                                          cleanMessage(useInfo);
                                          apiPullMessage();
                                        }
                                      });
                                    },
                                    child: Center(
                                      child: Container(
                                        margin: new EdgeInsets.only(right: 15.w),
                                        child: Text(
                                          '更换客服',
                                          style: TextStyle(
                                              color: StyleTheme.cTitleColor,
                                              fontSize: 15.w,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ))
                                : Container()),
                      );
                    }),
                preferredSize: Size(double.infinity, 44.w)),
            body: Column(
              children: [
                useInfo!.avatar == 'chaxiaowai' && useInfo!.nickname == '茶小歪'
                    ? Container(
                        color: Color.fromRGBO(253, 240, 228, 1),
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 12.5.w, vertical: 10.w),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "官方极速安排服务",
                                    style: TextStyle(color: Color.fromRGBO(255, 65, 73, 1), fontSize: 12.sp),
                                  ),
                                  Text(
                                    timeasd,
                                    style: TextStyle(color: Color.fromRGBO(255, 65, 73, 1), fontSize: 12.sp),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                showPay();
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 5.w, horizontal: 10.w),
                                decoration: BoxDecoration(
                                    color: StyleTheme.cDangerColor, borderRadius: BorderRadius.circular(5.w)),
                                child: Center(
                                  child: Text(
                                    "立即下单",
                                    style: TextStyle(color: Colors.white, fontSize: 12.sp),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    : Container(
                        color: Color.fromRGBO(253, 240, 228, 1),
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 12.5.w, vertical: 10.w),
                        child: Text(
                          getHeadText(),
                          style: TextStyle(color: Color.fromRGBO(255, 65, 73, 1), fontSize: 12.sp),
                        ),
                      ),
                requireData != null
                    ? getLetterIintentWidget(isAgent)
                    : _mzDetail != null
                        ? InfoCard(
                            toDetail: (id) {
                              if (useInfo!.isVipDetail!) {
                                context.pop();
                              } else {
                                AppGlobal.appRouter?.push(CommonUtils.getRealHash('vipDetailPage/' + id.toString() + '/null/'));
                              }
                            },
                            nickname: useInfo!.nickname,
                            onPush: () {
                              String girlUrl = _mzDetail!['image'].toString();
                              if (girlUrl.startsWith("http")) {
                                int index = girlUrl.indexOf("/", 8);
                                girlUrl = girlUrl.substring(index);
                              }

                              sendMessage(content: girlUrl, contentType: 'photos');
                              Future.delayed(new Duration(microseconds: 500), () {
                                dynamic title2 = _mzDetail!['title'];
                                sendMessage(content: '老板, 这个妹子【' + title2.toString() + '】能约吗？');
                              }).then((value) {
                                Future.delayed(new Duration(microseconds: 500), () {
                                  if (_mzDetail!['type'] == 'chanvlang') {
                                    sendImMsg(useInfo!.uuid!, type: 1);
                                  } else {
                                    sendImMsg(useInfo!.uuid!, type: 2);
                                  }
                                });
                              });
                            },
                            priceMin: _mzDetail!['priceMin'],
                            name: _mzDetail!['title'],
                            fee: _mzDetail!['price'],
                            type: _mzDetail!['type'],
                            thumb: _mzDetail!['image'],
                            id: _mzDetail!['id'].toString(),
                            status: int.parse(_mzDetail!['status']))
                        : Container(),
                Expanded(
                    child: loading
                        ? PageStatus.loading(true)
                        : chatList.length == 0 && newChatList.length == 0
                            ? PageStatus.noData(text: '你们还没有聊过哦～')
                            : Stack(clipBehavior: Clip.none, children: [
                                ValueListenableBuilder(
                                  valueListenable: showList,
                                  builder: (context, bool value, child) {
                                    return AnimatedOpacity(
                                      opacity: value ? 1 : 0,
                                      duration: Duration(milliseconds: 200),
                                      child: child,
                                    );
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                                    child: NotificationListener<OverscrollNotification>(
                                        child: CustomScrollView(
                                          physics: ClampingScrollPhysics(),
                                          // center: centerKey,
                                          controller: imController,
                                          cacheExtent: 5.sh,
                                          slivers: [
                                            SliverList(
                                                delegate: SliverChildBuilderDelegate(
                                              (BuildContext context, int index) {
                                                return UserDialog(
                                                  data: chatList[index],
                                                  useInfo: useInfo!,
                                                );
                                              },
                                              childCount: chatList.length,
                                            )),
                                            SliverPadding(
                                              padding: EdgeInsets.zero,
                                              key: centerKey,
                                            ),
                                            SliverList(
                                                delegate: SliverChildBuilderDelegate(
                                              (BuildContext context, int index) {
                                                return UserDialog(
                                                  data: newChatList[index],
                                                  useInfo: useInfo!,
                                                );
                                              },
                                              childCount: newChatList.length,
                                            )),
                                          ],
                                        ),
                                        onNotification: (OverscrollNotification notification) {
                                          double pixels = notification.metrics.pixels;
                                          if (pixels == notification.metrics.minScrollExtent) {
                                            // if (!isLoading && !isAll) {
                                            //   isLoading = true;
                                            //   page++;
                                            //   apiPullMessage();
                                            // }
                                          }
                                          return false;
                                        }),
                                  ),
                                ),
                                Positioned(
                                  left: 0,
                                  top: 0,
                                  right: 0,
                                  child: Container(
                                      height: 30.w,
                                      child: AnimatedBuilder(
                                        animation: inputAnimation!,
                                        builder: (context, child) {
                                          return Opacity(
                                            opacity: inputAnimation!.value,
                                            child: Transform.scale(
                                              scale: inputAnimation!.value,
                                              child: child,
                                            ),
                                          );
                                        },
                                        child: Center(
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(15),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                      begin: Alignment.centerLeft,
                                                      end: Alignment.centerRight,
                                                      colors: [Color(0xffee3abe), Color(0xff7a13d6)])),
                                              alignment: Alignment.center,
                                              height: double.infinity,
                                              width: 100.w,
                                              child: Text(
                                                '正在输入...',
                                                style: TextStyle(color: Colors.white, fontSize: 14.sp),
                                              ),
                                            ),
                                          ),
                                        ),
                                      )),
                                ),
                                ValueListenableBuilder(
                                    valueListenable: isNewmsg,
                                    builder: (context, bool value, child) {
                                      return AnimatedPositioned(
                                          top: 0,
                                          right: value ? 0 : -100.w,
                                          bottom: 0,
                                          duration: Duration(milliseconds: 300),
                                          curve: Curves.easeIn,
                                          child: Center(
                                            child: Opacity(
                                              opacity: value ? 1 : 0,
                                              child: GestureDetector(
                                                  onTap: () {
                                                    isNewmsg.value = false;
                                                    setState(() {});
                                                    imController.animateTo(imController.position.maxScrollExtent,
                                                        duration: Duration(milliseconds: 300), curve: Curves.easeIn);
                                                  },
                                                  child: ClipRRect(
                                                    borderRadius: BorderRadius.only(
                                                        topLeft: Radius.circular(15.w),
                                                        bottomLeft: Radius.circular(15.w)),
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: Color(0xff7a13d6),
                                                      ),
                                                      alignment: Alignment.center,
                                                      height: 30.w,
                                                      width: 100.w,
                                                      child: Text(
                                                        'Hi~ 有新消息',
                                                        style: TextStyle(color: Colors.white, fontSize: 14.sp),
                                                      ),
                                                    ),
                                                  )),
                                            ),
                                          ));
                                    }),
                              ])),
                _bottomInput(),
                _bottomFunction(isAgent),
              ],
            )),
      ),
    );
  }
}

class UserDialog extends StatefulWidget {
  MessageModel? data;
  bool shoWDate;
  FormUserMsg? useInfo;
  UserDialog({Key? key, this.data, this.shoWDate = true, this.useInfo})
      : super(
          key: key,
        );

  @override
  _UserDialogState createState() => _UserDialogState();
}

class _UserDialogState extends State<UserDialog> {
  DateTime? date;
  bool loading = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.shoWDate) {
      date = DateTime.fromMillisecondsSinceEpoch(widget.data!.createdAt! * 1000);
    }
  }

  String _num(int _date) {
    return _date < 10 ? '0' + _date.toString() : _date.toString();
  }

  String getDate() {
    return '${_num(date!.month)}-${_num(date!.day)} ${_num(date!.hour)}:${_num(date!.minute)}:${_num(date!.second)}';
  }

  Widget photosWidget() {
    String girlUrl = widget.data!.content.toString();
    if (girlUrl.startsWith("http")) {
      int index = girlUrl.indexOf("/", 8);
      girlUrl = girlUrl.substring(index);
    }

    String imagePath = AppGlobal.bannerImgBase + girlUrl;
    return GestureDetector(
        onTap: () {
          AppGlobal.picMap = {
            'resources': [
              {'img_url': imagePath}
            ],
            'index': 0
          };
          context.push('/teaViewPicPage');
          // CommonUtils.setStatusBar(isLight: true);
          // showImageViewer(
          //   context,
          //   NetworkImageCRP(imagePath),
          //   useSafeArea: true,
          //   swipeDismissible: true,
          //   doubleTapZoomable: true,
          //   immersive: false,
          //   onViewerDismissed: () {
          //     CommonUtils.setStatusBar();
          //   },
          // );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.w),
          child: SizedBox(
            width: 125.w,
            height: 125.w,
            child: ImageNetTool(
              url: imagePath,
              fit: BoxFit.cover,
            ),
          ),
        ));
  }

  video() {
    return GestureDetector(
      child: ClipRRect(
        child: Hero(
          child: Container(
            width: 160.w,
            height: 160.w,
            color: Colors.black,
            child: Center(
              child: LocalPNG(
                url: 'assets/images/msg/pause.png',
                width: 50.w,
                height: 50.w,
              ),
            ),
          ),
          tag: 'videos_play',
        ),
        borderRadius: BorderRadius.circular(10.w),
      ),
      onTap: () {
        // String url = API.imBaseUrl + '/' + _content;
        // Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //         builder: (_) => FullVideo(
        //               url: url,
        //             )));
      },
    );
  }

  product() {
    // {avatar:"",title:"",content:""}
    try {
      Map data = jsonDecode(widget.data!.content!);
      return GestureDetector(
        child: Container(
          height: 60.w,
          margin: EdgeInsets.all(5.w),
          child: ClipRRect(
              borderRadius: BorderRadius.circular(10.w),
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 60.w,
                    height: 60.w,
                    child: ImageNetTool(
                      url: data['avatar'].toString(),
                      fit: BoxFit.cover,
                    ),
                  ),
                  Expanded(
                      child: Container(
                    color: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    height: 60.w,
                    width: double.infinity,
                    child: Container(
                      child: Container(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              data['title'].toString(),
                              style: TextStyle(
                                color: StyleTheme.cTitleColor,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              height: 4.w,
                            ),
                            Text(
                              data['content'].toString(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: StyleTheme.cTitleColor,
                                fontSize: 10.sp,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ))
                ],
              )),
        ),
        onTap: () {
          AppGlobal.appRouter?.push(CommonUtils.getRealHash('vipDetailPage/' + data['id'].toString() + '/null/'));
        },
      );
    } catch (e) {
      return Container();
    }
  }

  // 茶女郎卡片
  productTeaGirl() {
    // {avatar:"",title:"",content:""}
    try {
      Map data = jsonDecode(widget.data!.content!);
      String girlUrl = data['avatar'].toString();
      if (girlUrl.startsWith("http")) {
        int index = girlUrl.indexOf("/", 8);
        girlUrl = girlUrl.substring(index);
      }
      String imageUrl = AppGlobal.bannerImgBase + girlUrl;

      String title = data['title'].toString();
      String city = data['city'].toString();
      String age = data['age'].toString() + "    ";
      String height = data['height'].toString() + "    ";
      String bust = data['bust'].toString();
      return GestureDetector(
        child: Container(
          // color: Colors.white,
          height: 60.w,
          // margin: EdgeInsets.all(GVScreenUtil.setWidth(10)),
          child: Row(
            children: <Widget>[
//             CGAssetsImage(url:
//              '${data['avatar']}',
//              width: GVScreenUtil.setWidth(100),
//              height: GVScreenUtil.setWidth(100),
//            ),
              ClipRRect(
                child: SizedBox(
                  width: 50.w,
                  height: 50.w,
                  child: ImageNetTool(
                    url: imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
                borderRadius: BorderRadius.circular(5.w),
              ),
              Container(
                width: 10,
              ),
              Expanded(
                child: Container(
//              color: Colors.amberAccent,
                  child: Column(
                    // mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 100.sp,
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: StyleTheme.cTitleColor,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            city,
                            style: TextStyle(
                              color: StyleTheme.cTitleColor,
                              fontSize: 12.sp,
                              // fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        height: 4.sp,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            age,
                            style: TextStyle(
                              color: StyleTheme.cTitleColor,
                              fontSize: 12.sp,
                              // fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            height,
                            style: TextStyle(
                              color: StyleTheme.cTitleColor,
                              fontSize: 12.sp,
                              // fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            bust,
                            style: TextStyle(
                              color: StyleTheme.cTitleColor,
                              fontSize: 12.sp,
                              // fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
        onTap: () {
          AppGlobal.appRouter?.push(CommonUtils.getRealHash('gilrDrtailPage/' + data['id'].toString() + '/2'));
        },
      );
    } catch (e) {
      return Container();
    }
  }

  textContent() {
    String _context = widget.data!.content!;
    if (_context.contains('cgmsgtype') && _context.contains('teagirl')) {
      return productTeaGirl();
    }
    bool isSelf = widget.data!.fromUuid == WebSocketUtility.uuid;
    return SelectableText(AppGlobal.emoji.emojify(widget.data!.content!),
        style: TextStyle(color: isSelf ? Colors.white : Color(0xff323232), fontSize: 14.sp));
  }

  getContentype() {
    switch (widget.data!.contentType) {
      case 'text':
        return textContent();
      case 'photos':
        return photosWidget();
      case 'videos':
        return video();
      case 'product':
        return product();
      default:
        return textContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isSelf = widget.data!.fromUuid == WebSocketUtility.uuid;
    return Container(
      margin: EdgeInsets.only(bottom: 20.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          widget.shoWDate
              ? Padding(
                  padding: EdgeInsets.only(bottom: 20.w),
                  child: Text(
                    getDate(),
                    style: TextStyle(color: Color(0xffb4b4b4), fontSize: 14.sp),
                  ),
                )
              : Container(),
          Row(
            mainAxisAlignment: isSelf ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              isSelf
                  ? Container()
                  : Padding(
                      padding: EdgeInsets.only(right: 10.w),
                      child: ClipRRect(
                        child: LocalPNG(
                          height: 40.w,
                          width: 40.w,
                          url: 'assets/images/common/' +
                              (isSelf ? WebSocketUtility.avatar! : widget.useInfo!.avatar!) +
                              '.png',
                        ),
                        borderRadius: BorderRadius.circular(5.w),
                      ),
                    ),
              Flexible(
                child: Container(
                  padding: EdgeInsets.all((widget.data!.contentType == 'text' ? 10 : 0).w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular((widget.data!.contentType == 'text' ? 5 : 2.5).w),
                    color: widget.data!.contentType == 'videos' || widget.data!.contentType == 'photos'
                        ? Colors.transparent
                        : (isSelf ? StyleTheme.cDangerColor : Color(0xfff5f5f5)),
                  ),
                  child: getContentype(),
                ),
              ),
              !isSelf
                  ? Container()
                  : Padding(
                      padding: EdgeInsets.only(left: 10.w),
                      child: ClipRRect(
                        child: LocalPNG(
                          height: 40.w,
                          width: 40.w,
                          url: 'assets/images/common/' +
                              (isSelf ? WebSocketUtility.avatar! : widget.useInfo!.avatar!) +
                              '.png',
                        ),
                        borderRadius: BorderRadius.circular(5.w),
                      ),
                    )
            ],
          )
        ],
      ),
    );
  }
}
