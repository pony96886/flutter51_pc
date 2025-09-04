import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/encdecrypt.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/index.dart';
import 'package:chaguaner2023/view/im/im_page.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// WebSocket状态
enum SocketStatus {
  SocketStatusConnected, // 已连接
  SocketStatusFailed, // 失败
  SocketStatusClosed, // 连接关闭
}

//消息model
class MessageModel {
  String? fromUuid;
  String? toUuid;
  String? action;
  String? content;
  String? msgType;
  int? createdAt;
  int? updatedAt;
  String? contentType;
  String? ext;
  String? duration;
  String? via;
  int? sendTime;
  int? isAdv;
  int? status;
  String? uniqueId;
  String? type;
  String? timestamp;
  int? microtime;
  String? avatar;
  String? nickname;

  MessageModel({
    this.fromUuid,
    this.toUuid,
    this.action,
    this.content,
    this.msgType,
    this.createdAt,
    this.updatedAt,
    this.contentType,
    this.ext,
    this.duration,
    this.via,
    this.sendTime,
    this.isAdv,
    this.status,
    this.uniqueId,
    this.type,
    this.timestamp,
    this.microtime,
    this.nickname,
    this.avatar,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
        fromUuid: json["from_uuid"],
        toUuid: json["to_uuid"],
        action: json["action"],
        content: json["content"],
        msgType: json["msgType"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        contentType: json["content_type"],
        ext: json["ext"],
        duration: json["duration"],
        via: json["via"],
        sendTime: json["send_time"],
        isAdv: json["is_adv"],
        status: json["status"],
        uniqueId: json["uniqueId"],
        type: json["type"],
        timestamp: json["timestamp"],
        microtime: int.parse(json["microtime"].toString()),
        avatar: json["avatar"],
        nickname: json["nickname"],
      );

  Map<String, dynamic> toJson() => {
        "from_uuid": fromUuid,
        "to_uuid": toUuid,
        "action": action,
        "content": content,
        "msgType": msgType,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "content_type": contentType,
        "ext": ext,
        "duration": duration,
        "via": via,
        "send_time": sendTime,
        "is_adv": isAdv,
        "status": status,
        "uniqueId": uniqueId,
        "type": type,
        "timestamp": timestamp,
        "microtime": microtime,
        "avatar": avatar,
        "nickname": nickname,
      };
}

class WebSocketUtility {
  static WebSocketUtility? _socket;
  static String? imToken;
  static String? uuid;
  static String? oauthType;
  static String? oauthId;
  static String? oauthAdsId;
  static String? phone;
  static String? nickname;
  static String? avatar;
  static String? aff;
  static int? agent;
  static int? vipLevel;
  static int? gender;
  static bool isOline = false;
  static List messageList = [];
  static StreamSubscription? _streamSubscription;

  /// 内部构造方法，可避免外部暴露构造函数，进行实例化
  WebSocketUtility._();

  /// 获取单例内部方法
  factory WebSocketUtility() {
    // 只能有一个实例
    if (_socket == null) {
      _socket = new WebSocketUtility._();
    }
    return _socket!;
  }

  WebSocketChannel? _webSocket; // WebSocket
  SocketStatus? _socketStatus; // socket状态
  Timer? _heartBeat; // 心跳定时器
  int _heartTimes = 15000; // 心跳间隔(毫秒)
  int _reconnectCount = 60; // 重连次数，默认60次
  int _errCount = 3; // 错误次数，错误重连次数  默认 3次
  int _errTimes = 0; // 错误重连计数器
  int _reconnectTimes = 0; // 重连计数器
  Timer? _reconnectTimer; // 重连定时器
  Function? onError; // 连接错误回调
  Function? onOpen; // 连接开启回调
  Function? onMessage; // 接收消息回调

  /// 初始化WebSocket
  void initWebSocket(BuildContext context, {Function? onOpen, Function? onMessage, Function? onError}) {
    this.onOpen = onOpen;
    this.onMessage = onMessage;
    this.onError = onError;
    openSocket();
  }

  /// 开启WebSocket连接
  void openSocket() {
    closeSocket();
    AppGlobal.socketUrl = AppGlobal.imUrl[Random().nextInt(AppGlobal.imUrl.length - 1)];
    if (kIsWeb) {
      _webSocket = WebSocketChannel.connect(Uri.parse(AppGlobal.socketUrl));
    } else {
      _webSocket = IOWebSocketChannel.connect(AppGlobal.socketUrl);
    }
    CommonUtils.debugPrint('WebSocket连接成功: ${AppGlobal.socketUrl}');

    // 连接成功，返回WebSocket实例
    _socketStatus = SocketStatus.SocketStatusConnected;
    Map initUserdata = {
      "uuid": WebSocketUtility.uuid,
      'via': 'chaguaner',
      "oauth_type": WebSocketUtility.oauthType,
      "oauth_id": WebSocketUtility.oauthId,
      "oauth_ads_id": WebSocketUtility.oauthAdsId,
      "token": WebSocketUtility.imToken,
    };
    CommonUtils.debugPrint('初始化用户:$initUserdata');
    //初始化用户
    sendMessage('message/initUser', initUserdata);
    // 连接成功，重置重连计数器
    _reconnectTimes = 0;
    _errTimes = 0;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    onOpen!();
    // 接收消息
    _streamSubscription = _webSocket?.stream
        .listen((data) => webSocketOnMessage(data), onError: webSocketOnError, onDone: webSocketOnDone);
  }

  //拉取消息列表
  void pullMessage(String uuid) async {
    AppGlobal.appDb!.getAccountContact(uuid: uuid).then((value) {
      if (value.length > 0) {
        sendMessage(
          'message/pullMessages',
          {
            "to_id": uuid,
            "type": "one",
            "direct": "up",
            "message_id": value[0].messageId,
            "number": 100,
            "include": true,
          },
        );
      } else {
        EventBus().emit(LlImKey.pullMessage, []);
      }
    });
  }

  //获取在线状态
  void getOnline(String uuid) {
    sendMessage(
      'message/isOnline',
      {"to_uuid": AppGlobal.chatUser?.uuid},
    );
  }

  //正在输入
  void typingStatus(bool type) {
    String isTyping = 'isTyping';
    String endTyping = 'endTyping';
    sendMessage(
      'message/typingStatus',
      {
        "to_id": AppGlobal.chatUser?.uuid,
        "type": "one",
        "action": type ? isTyping : endTyping,
        "nickname": nickname,
      },
    );
  }

  /// WebSocket接收消息回调
  webSocketOnMessage(data) {
    data = jsonDecode(data);
    if (data is String) {
    } else {
      // onMessage(data);
      if (data['data'] != null) {
        // CommonUtils.debugPrint(data['data']);
        EncDecrypt.decryptResData(data).then((value) {
          var _decryData = data;
          _decryData["data"] = value;
          receiveMsg(_decryData);
          onMessage!(_decryData);
        });
      } else {
        receiveMsg(data);
        onMessage!(data);
      }
    }
  }

  receiveMsg(data) {
    CommonUtils.debugPrint('收到:$data');
    dynamic _inofData;
    if (data["data"] != null) {
      _inofData = json.decode(data["data"]);
    }
    if (data["message_type"] != null) {
      switch (data["message_type"]) {
        case "initMessage": //初始化返回
          isOline = true;
          List? messageList = _inofData['offlineMessageForOne'];
          messageList?.forEach((element) {
            MessageModel _msg = MessageModel.fromJson(element['newest']);
            sendMessage("message/ack", {
              "message_ids": [_msg.uniqueId],
              "type": "one",
              "sender": _msg.fromUuid
            });
            AppGlobal.appDb?.addContact(_msg).then((value) {
              AppGlobal.appDb?.getAccountContact();
            });
            if (_msg.fromUuid != AppGlobal.chatUser?.uuid) {
              AppGlobal.appDb?.addChatRecord(_msg);
            }
            if (_msg.fromUuid == AppGlobal.chatUser?.uuid) {
              EventBus().emit(LlImKey.sendMessage, _msg);
            }
          });
          sendMessage("message/AckOfflineMessage", {});
          break;
        case "chatMessage": //收到消息
          List? messageList = _inofData['offlineMessageForOne'];
          if (messageList != null) {
            messageList.forEach((element) {
              MessageModel _msg = MessageModel.fromJson(element);
              sendMessage("message/ack", {
                "message_ids": [_msg.uniqueId],
                "type": "one",
                "sender": _msg.fromUuid
              });
              AppGlobal.appDb?.addContact(_msg).then((value) {
                AppGlobal.appDb?.getAccountContact();
              });
              if (_msg.fromUuid != AppGlobal.chatUser?.uuid) {
                AppGlobal.appDb?.addChatRecord(_msg);
              }
              if (_msg.fromUuid == AppGlobal.chatUser?.uuid) {
                EventBus().emit(LlImKey.sendMessage, _msg);
              }
            });
          } else {
            MessageModel _msg = MessageModel.fromJson(_inofData);
            sendMessage("message/ack", {
              "message_ids": [_msg.uniqueId],
              "type": "one",
              "sender": _msg.fromUuid
            });
            AppGlobal.appDb!.addContact(_msg).then((value) {
              AppGlobal.appDb?.getAccountContact();
            });
            if (_msg.fromUuid != AppGlobal.chatUser?.uuid) {
              AppGlobal.appDb?.addChatRecord(_msg);
            }
            if (_msg.fromUuid == AppGlobal.chatUser?.uuid) {
              EventBus().emit(LlImKey.sendMessage, _msg);
            }
          }
          // 消息通知
          if (AppGlobal.appState != AppLifecycleState.resumed) {
            EasyDebounce.debounce('im_show_notification', Duration(seconds: 3),
                () => CommonUtils.showNotification(title: '亲爱的茶友', des: '茶馆儿有一条新到信息～'));
          }
          break;
        case 'ackMessage': //发送消息回执
          MessageModel _msg = MessageModel.fromJson(_inofData);
          _msg.avatar = AppGlobal.chatUser?.avatar;
          _msg.nickname = AppGlobal.chatUser?.nickname;
          AppGlobal.appDb?.addContact(_msg).then((value) {
            AppGlobal.appDb?.getAccountContact();
          });
          // AppGlobal.appDb.addChatRecord(_msg);
          EventBus().emit(LlImKey.sendMessage, _msg);
          break;
        case 'isTypingMessage': //正在输入
          if (AppGlobal.chatUser?.uuid == _inofData['from_uuid']) {
            EventBus().emit(LlImKey.isTyping, _inofData['action'] == 'isTyping' ? true : false);
          }
          break;
        case 'queryOnlineTime': //查询在线
          EventBus().emit(LlImKey.isOnline, _inofData['online_time']);
          break;
        case 'beenReadNotice': //已读未读
          break;
        case 'pullMessageForOne': //拉取消息
          List<MessageModel> messageList = (_inofData ?? []).asMap().keys.map<MessageModel>((e) {
            return MessageModel.fromJson(_inofData[e]);
          }).toList();
          EventBus().emit(LlImKey.pullMessage, messageList);
          break;
        default:
      }
    }
  }

  /// WebSocket关闭连接回调
  webSocketOnDone() {
    print('closed');
    isOline = false;
    if (WebSocketUtility.vipLevel == 0) return;
    reconnect();
  }

  /// WebSocket连接错误回调
  webSocketOnError(e) {
    WebSocketChannelException ex = e;
    isOline = false;
    _socketStatus = SocketStatus.SocketStatusFailed;
    closeSocket();
    _errTimes++;
    if (_errTimes < _errCount) {
      print('错误重连');
      webSocketOnDone();
    }
  }

  /// 初始化心跳
  void initHeartBeat() {
    destroyHeartBeat();
    _heartBeat = new Timer.periodic(Duration(milliseconds: _heartTimes), (timer) {
      sentHeart();
    });
  }

  /// 心跳
  void sentHeart() {
    isOline = true;
    print('-------------ping');
    sendMessage("message/ping", {});
  }

  /// 销毁心跳
  void destroyHeartBeat() {
    _heartBeat?.cancel();
    _heartBeat = null;
  }

  /// 关闭WebSocket
  void closeSocket() {
    print('WebSocket连接关闭');
    _streamSubscription?.cancel();
    _streamSubscription = null;
    _webSocket?.sink.close();
    destroyHeartBeat();
    _socketStatus = SocketStatus.SocketStatusClosed;
    isOline = false;
  }

  /// 发送WebSocket消息
  void sendMessage(String api, dynamic message, {String? ackid}) {
    switch (_socketStatus) {
      case SocketStatus.SocketStatusConnected:
        CommonUtils.debugPrint('发送:${message}');
        CommonUtils.debugPrint({
          "route": api,
          "encrypt": "self",
          'client': 'new',
          "data": json.encode(message),
        });
        EncDecrypt.encryptReqParams(json.encode(message), isIm: true).then((value) {
          Map _data = {
            "route": api,
            "encrypt": "self",
            'client': 'new',
            "data": value,
          };
          _data['ack_id'] = ackid;
          _webSocket?.sink.add(json.encode(_data));
        });
        break;
      case SocketStatus.SocketStatusClosed:
        print('连接已关闭');
        break;
      case SocketStatus.SocketStatusFailed:
        print('发送失败');
        break;
      default:
        break;
    }
  }

  /// 重连机制
  void reconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    closeSocket();
    isOline = false;
    if (_reconnectTimes < _reconnectCount) {
      _reconnectTimes++;
      _reconnectTimer = new Timer.periodic(Duration(milliseconds: _heartTimes), (timer) {
        openSocket();
      });
    } else {
      print('重连次数超过最大次数');
      _reconnectTimer!.cancel();
      _reconnectTimer = null;
      return;
    }
  }
}
