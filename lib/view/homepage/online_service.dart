import 'dart:convert';
import 'dart:io';
import 'package:bot_toast/bot_toast.dart';
import 'package:chaguaner2023/components/avatar_widget.dart';
import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/loading.dart';
import 'package:chaguaner2023/components/loading_gif.dart';
import 'package:chaguaner2023/components/pagetitlebar.dart';
import 'package:chaguaner2023/components/upload/start_upload.dart';
import 'package:chaguaner2023/components/upload/upload_resouce.dart';
import 'package:chaguaner2023/store/homeConfig.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:chaguaner2023/utils/netimage_tool.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../utils/cache/image_net_tool.dart';

class ServiceParmas {
  static String? type;
  static String? orderId;
  static String? isSend;
  static List? images;
}

class OnlineServicePage extends StatefulWidget {
  final String? type;
  final String? orderId;
  final String? isSend;
  final List? images;
  OnlineServicePage(
      {Key? key, this.orderId, this.images, this.isSend, this.type})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => OnlineServicState();
}

class OnlineServicState extends State<OnlineServicePage> {
  bool isInit = true;
  bool loading = true;
  bool fetching = false;
  bool networkErr = false;
  RegExp regExp = new RegExp(
    r"(http|ftp|https):\/\/[\w\-_]+(\.[\w\-_]+)+([\w\-\.,@?^=%&amp;:/~\+#]*[\w\-\@?^=%&amp;/~\+#])?",
    multiLine: true,
  );
  String? thumb;
  int page = 1;
  TextEditingController editingController = TextEditingController();
  ScrollController scrollControllerFalse = ScrollController();
  List? helpList;
  List? msgList;
  bool isAll = false;
  String chaguanString = '[chaguan]';
  getMsgPath(String msg, int status) {
    var isPath = regExp.hasMatch(msg);
    var pathMsg = msg.replaceAll('http', '${chaguanString}http');
    var pathList = pathMsg.split(chaguanString);
    var textList = [];
    for (var i = 0; i < pathList.length; i++) {
      if (regExp.hasMatch(pathList[i])) {
        dynamic chaguanStr = regExp.stringMatch(pathList[i]);
        var newMsg = chaguanStr == null
            ? pathList[i]
            : pathList[i].replaceAll(regExp.stringMatch(pathList[i])!,
                '$chaguanString$chaguanStr$chaguanString');
        textList.addAll(newMsg.split(chaguanString));
      } else {
        textList.add(pathList[i]);
      }
    }

    return isPath
        ? Text.rich(TextSpan(
            children: textList
                .asMap()
                .keys
                .map((e) => TextSpan(
                      text: textList[e],
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: regExp.hasMatch(textList[e])
                            ? (status == 2
                                ? Color(0xff1967D2)
                                : Color(0xffffffff))
                            : (status == 2
                                ? StyleTheme.cTitleColor
                                : Colors.white),
                        decoration: regExp.hasMatch(textList[e])
                            ? TextDecoration.underline
                            : null,
                        height: 1.2,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          CommonUtils.launchURL(textList[e]);
                        },
                    ))
                .toList()))
        : Text(
            msg,
            style: TextStyle(
              fontSize: 14.sp,
              color: status == 2 ? StyleTheme.cTitleColor : Colors.white,
              height: 1.2,
            ),
            softWrap: true,
          );
  }

  int getHelpType() {
    int _type = 0;
    switch (ServiceParmas.type) {
      case 'game': //游戏
        _type = 1;
        break;
      case 'cz': //充值
        _type = 2;
        break;
      case 'chat': //裸聊
        _type = 3;
        break;
      default:
        _type = 0;
    }
    return _type;
  }

  upImage(String filePath) async {
    BotToast.showCustomLoading(toastBuilder: (cancelFunc) {
      return Container(
        padding: const EdgeInsets.all(15),
        decoration: const BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.all(Radius.circular(8))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            LoadingGif(
              width: 1.sw / 5,
            ),
            SizedBox(
              height: 12.5.w,
            ),
            Text(
              '上传中...',
              style: TextStyle(color: Colors.white, fontSize: 14.sp),
            )
          ],
        ),
      );
    });
    // var result = await PlatformAwareHttp.uploadImage(
    //     imageUrl: filePath,
    //     position: 'upload',
    //     progressCallback: (count, total) {});
    var result = 'sdas';
    var res = jsonDecode(result);
    if (res['code'] == 1) {
      var msg = await sendFeeding(res['msg'], 2, getHelpType());
      if (msg!['status'] != 0) {
        Map msgResult = {
          "messageType": 2,
          "status": 1,
          "isLocal": 1,
          "createdAt": null,
          "message": filePath,
          "thumb": thumb
        };
        setState(() {
          msgList!.insert(0, msgResult);
        });
        BotToast.closeAllLoading();
      } else {
        BotToast.showText(text: '图片发送失败，请重试～', align: Alignment(0, 0));
        BotToast.closeAllLoading();
      }
    }
  }

//发送消息
  _sendMsg() async {
    var text = editingController.text.trim();
    if (text.isNotEmpty) {
      var msg = await sendFeeding(text, 1, getHelpType());
      if (msg!['status'] != 0) {
        setState(() {
          Map msgResult = {
            "messageType": 1,
            "status": 1,
            "createdAt": null,
            "message": text,
            "thumb": thumb
          };
          msgList?.insert(0, msgResult);
        });
      } else {
        BotToast.showText(text: '网络不佳,请重新尝试～', align: Alignment(0, 0));
      }
      editingController.text = '';
      setState(() {});
    }
  }

  //拉取消息列表
  getFeedback() async {
    setState(() {
      networkErr = false;
    });
    if (fetching) return null;
    fetching = true;
    var feedback = await getFeedbackList(page);
    if (page == 1) {
      if (feedback!['status'] != 0) {
        msgList = feedback['data'];
        getHelp(helpList!);
        setState(() {
          loading = false;
        });
      } else {
        setState(() {
          networkErr = true;
        });
        return;
      }
    } else {
      if (feedback!['status'] != 0 && feedback['data'].length > 0) {
        setState(() {
          msgList!.addAll(feedback['data']);
        });
      } else {
        isAll = true;
      }
    }
    fetching = false;
    page++;
  }

  @override
  void initState() {
    super.initState();
    getFeedback();
    editingController.text =
        (ServiceParmas.orderId == null ? '' : ServiceParmas.orderId)!;
    scrollControllerFalse.addListener(() {
      if (scrollControllerFalse.position.pixels ==
          scrollControllerFalse.position.maxScrollExtent) {
        if (!isAll) {
          EasyDebounce.debounce('getFeedback-debouncer',
              Duration(milliseconds: 500), () => getFeedback());
        }
      }
    });
  }

  @override
  dispose() {
    super.dispose();
    scrollControllerFalse.dispose();
    UploadFileList.dispose();
    ServiceParmas.type = null;
    ServiceParmas.isSend = null;
    ServiceParmas.images = null;
    ServiceParmas.orderId = null;
    // EasyDebounce.cancel('getFeedback-debouncer');
  }

  getHelp(List help) {
    List problemList = [];
    help.forEach((element) {
      for (var item in element['items']) {
        var problem = {
          'problem': item['id'].toString() + '、' + item['question'],
          'reply': item['answer'],
        };
        problemList.add(problem);
      }
    });
    Map msgResult = {
      "messageType": 1,
      "status": 2,
      "createdAt": null,
      "problemList": problemList
    };
    msgList!.insert(0, msgResult);
    if ((ServiceParmas.images != null || ServiceParmas.isSend == 'send')) {
      BotToast.showCustomLoading(toastBuilder: (cancelFunc) {
        return Container(
          padding: const EdgeInsets.all(15),
          decoration: const BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.all(Radius.circular(8))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              LoadingGif(
                width: 1.sw / 5,
              ),
              SizedBox(
                height: 12.5.w,
              ),
              Text(
                '上传中...',
                style: TextStyle(color: Colors.white, fontSize: 14.sp),
              )
            ],
          ),
        );
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          editingController.text = '';
        });
        sendFeeding(ServiceParmas.orderId!, 1, getHelpType()).then((msg) => {
              if (msg!['status'] != 0)
                {
                  setState(() {
                    Map msgResult = {
                      "messageType": 1,
                      "status": 1,
                      "createdAt": null,
                      "message": ServiceParmas.orderId,
                      "thumb": thumb
                    };
                    msgList!.insert(0, msgResult);
                  }),
                  if (ServiceParmas.images!.length > 0)
                    {
                      Future.delayed(new Duration(seconds: 1), () {
                        ServiceParmas.images!.forEach((path) {
                          sendImage(path);
                        });
                        BotToast.closeAllLoading();
                      }),
                    }
                }
              else
                {
                  BotToast.closeAllLoading(),
                  BotToast.showText(text: '网络不佳,请重新尝试～', align: Alignment(0, 0))
                }
            });
      });
    }
  }

  sendImage(String path) async {
    var msg = await sendFeeding(path, 2, getHelpType());
    if (msg!['status'] != 0) {
      Map msgResult = {
        "messageType": 2,
        "status": 1,
        "isLocal": null,
        "createdAt": null,
        "message": AppGlobal.bannerImgBase + path,
        "thumb": thumb
      };

      msgList = [msgResult, ...msgList!];
      setState(() {});
    } else {
      BotToast.showText(text: '图片发送失败，请重试～', align: Alignment(0, 0));
    }
  }

  Widget problemItem(String problem, String reply) {
    return Expanded(
      child: GestureDetector(
          onTap: () {
            Map msgResult = {
              "messageType": 1,
              "status": 2,
              "createdAt": null,
              "message": reply,
              "thumb": thumb
            };
            setState(() {
              msgList!.insert(0, msgResult);
            });
          },
          child: Text(
            problem,
            style: TextStyle(
              fontSize: 14.sp,
              color: Color(0xFFCD79FF),
              height: 2,
            ),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    var help = Provider.of<HomeConfig>(context).data['help'];
    if (isInit) {
      setState(() {
        isInit = false;
        helpList = help;
        thumb = Provider.of<HomeConfig>(context).member.thumb;
      });
    }
    return HeaderContainer(
        child: Scaffold(
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
          child: PageTitleBar(
            title: '在线客服',
          ),
          preferredSize: Size(double.infinity, 44.w)),
      body: loading
          ? Loading()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                    child: ListView.separated(
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                        controller: scrollControllerFalse,
                        padding: EdgeInsets.only(
                            top: 5.w, left: 15.w, right: 15.w, bottom: 20.w),
                        reverse: true,
                        separatorBuilder: (BuildContext context, int index) =>
                            Container(),
                        itemCount: msgList!.length,
                        itemBuilder: (BuildContext context, int index) {
                          return conversationTimeItem(msgList![index], index);
                        })),
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
                        Stack(
                          children: [
                            LocalPNG(
                              url: 'assets/images/icon-img.png',
                              fit: BoxFit.fill,
                              width: 25.w,
                              height: 25.w,
                            ),
                            Positioned.fill(
                                child: UploadResouceWidget(
                              maxLength: 1,
                              noMark: true,
                              isIndependent: true,
                              transparent: true,
                              parmas: 'images',
                              onSelect: () {
                                StartUploadFile.upload().then((value) {
                                  print(value);
                                  sendImage(value!['images'][0]['url']);
                                }).whenComplete(() {
                                  UploadFileList.allFile['images']!.originalUrls
                                      .clear();
                                  UploadFileList.allFile['images']!.urls
                                      .clear();
                                });
                              },
                            ))
                          ],
                        ),
                        Expanded(
                          child: Container(
                            height: 35.w,
                            margin: EdgeInsets.only(left: 15.w),
                            decoration: BoxDecoration(
                                color: StyleTheme.bottomappbarColor,
                                borderRadius: BorderRadius.circular(17.5.w)),
                            child: TextField(
                              controller: editingController,
                              decoration: InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.only(
                                      left: 10, right: 10, top: 5, bottom: 5),
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(
                                      color: StyleTheme.cBioColor,
                                      fontSize: 16.sp),
                                  hintText: "请输入消息..."),
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
    ));
  }

  Widget conversationItem(String msg, int status, String thumb, int messageType,
      List? problemList, int isLocal) {
    var _avatarType = Provider.of<HomeConfig>(context).member.thumb;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      textDirection: status == 2 ? TextDirection.ltr : TextDirection.rtl,
      children: [
        Container(
            width: 40.w,
            height: 40.w,
            margin: new EdgeInsets.only(
                right: status == 2 ? 10.w : 0, left: status == 1 ? 10.w : 0),
            child: status == 2
                ? LocalPNG(
                    url: 'assets/images/service.png',
                    fit: BoxFit.cover,
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(5.0),
                    child: _avatarType == null
                        ? LocalPNG(
                            url: "assets/images/default_avatar.png",
                            fit: BoxFit.cover,
                          )
                        : Avatar(type: _avatarType))),
        Expanded(
            child: Container(
          margin: new EdgeInsets.only(bottom: 50.w),
          width: double.infinity,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            problemList == null
                ? Row(
                    mainAxisAlignment: status == 2
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.end,
                    children: [
                      Flexible(
                          child: Container(
                              decoration: BoxDecoration(
                                  boxShadow: [
                                    //阴影
                                    BoxShadow(
                                        color: Colors.black12,
                                        offset: Offset(0, 0.5.w),
                                        blurRadius: 2.5.w)
                                  ],
                                  color: status == 2
                                      ? StyleTheme.bottomappbarColor
                                      : StyleTheme.cDangerColor,
                                  borderRadius: BorderRadius.circular(8.w)),
                              padding: new EdgeInsets.symmetric(
                                  horizontal: 12.5.w, vertical: 12.5.w),
                              child: messageType == 1
                                  ? getMsgPath(msg, status)
                                  : GestureDetector(
                                      onTap: () {
                                        AppGlobal.picMap = {
                                          'resources': [
                                            {'img_url': msg}
                                          ],
                                          'index': 0
                                        };
                                        context.push('/teaViewPicPage');
                                      },
                                      child: SizedBox(
                                        width: 150.w,
                                        height: 150.w,
                                        child: ImageNetTool(
                                          url: msg,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    )))
                    ],
                  )
                : Container(
                    //常见问题
                    decoration: BoxDecoration(
                        boxShadow: [
                          //阴影
                          BoxShadow(
                              color: Colors.black12,
                              offset: Offset(0, 0.5.w),
                              blurRadius: 2.5.w)
                        ],
                        color: StyleTheme.bottomappbarColor,
                        borderRadius: BorderRadius.circular(8.w)),
                    padding: new EdgeInsets.symmetric(
                        horizontal: 12.5.w, vertical: 12.w),
                    child: Container(
                        margin: new EdgeInsets.only(bottom: 10.w),
                        child: Container(
                            child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                    child: Text(
                                  '你可以点击下方常见问题马上获得答案~',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: StyleTheme.cTitleColor,
                                    height: 1.5,
                                  ),
                                ))
                              ],
                            ),
                            for (var item in problemList)
                              Row(
                                children: [
                                  problemItem(item['problem'], item['reply'])
                                ],
                              ),
                            Row(
                              children: [
                                Expanded(
                                    child: Text(
                                  '你也可以直接留言，客服小姐姐在线会马上回复。~',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: StyleTheme.cTitleColor,
                                    height: 1.5,
                                  ),
                                ))
                              ],
                            )
                          ],
                        ))),
                  )
          ]),
        ))
      ],
    );
  }

// 首先遍历时间
  Widget conversationTimeItem(Map item, int index) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          item['created_at'] != null &&
                  (index >= 1 &&
                      index < msgList!.length - 1 &&
                      msgList![index].createdAt !=
                          msgList![index + 1].createdAt)
              ? Container(
                  margin: new EdgeInsets.only(bottom: 20.w),
                  child: Center(
                    child: Text(item['created_at'].toString(),
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: StyleTheme.cBioColor,
                          height: 1.5,
                        )),
                  ),
                )
              : Container(),
          conversationItem(
              item['message'] ?? '',
              item['status'],
              item['thumb'] ?? '0',
              item['messageType'],
              item['problemList'] ?? null,
              item['isLocal'] ?? 0)
        ],
      ),
    );
  }
}
