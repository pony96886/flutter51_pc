import 'dart:convert';

SystemNotice systemNoticeFromJson(String str) =>
    SystemNotice.fromJson(json.decode(str));

String systemNoticeToJson(SystemNotice data) => json.encode(data.toJson());

class SystemNotice {
  SystemNotice({
    this.data,
    this.status,
    this.msg,
    this.crypt,
    this.isVip,
  });

  Data? data;
  int? status;
  String? msg;
  bool? crypt;
  bool? isVip;

  factory SystemNotice.fromJson(Map<String, dynamic> json) => SystemNotice(
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
        status: json["status"] == null ? null : json["status"],
        msg: json["msg"] == null ? null : json["msg"],
        crypt: json["crypt"] == null ? null : json["crypt"],
        isVip: json["isVip"] == null ? null : json["isVip"],
      );

  Map<String, dynamic> toJson() => {
        "data": data == null ? null : data!.toJson(),
        "status": status == null ? null : status,
        "msg": msg == null ? null : msg,
        "crypt": crypt == null ? null : crypt,
        "isVip": isVip == null ? null : isVip,
      };
}

class Data {
  Data({
    this.systemNoticeCount,
    this.feedCount,
    this.systemNotice,
    this.feed,
    this.groupMessageCount,
    this.groupMessage,
  });

  int? systemNoticeCount;
  int? feedCount;
  int? groupMessageCount;
  Feed? systemNotice;
  Feed? feed;
  GroupMessage? groupMessage;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
      systemNoticeCount:
          json["systemNoticeCount"] == null ? null : json["systemNoticeCount"],
      feedCount: json["feedCount"] == null ? null : json["feedCount"],
      systemNotice: json["systemNotice"] == null
          ? null
          : Feed.fromJson(json["systemNotice"]),
      feed: json["feed"] == null ? null : Feed.fromJson(json["feed"]),
      groupMessage: json["groupMessage"] == null
          ? null
          : GroupMessage.fromJson(json["groupMessage"]),
      groupMessageCount:
          json["groupMessageCount"] == null ? 0 : json["groupMessageCount"]);

  Map<String, dynamic> toJson() => {
        "systemNoticeCount": systemNoticeCount == null ? 0 : systemNoticeCount,
        "feedCount": feedCount == null ? 0 : feedCount,
        "systemNotice": systemNotice == null ? null : systemNotice!.toJson(),
        "feed": feed == null ? null : feed!.toJson(),
        "groupMessageCount": groupMessageCount == null ? 0 : groupMessageCount,
        "groupMessage": groupMessage == null ? null : groupMessage!.toJson()
      };
}

Feed feedFromJson(String str) => Feed.fromJson(json.decode(str));

String feedToJson(Feed data) => json.encode(data.toJson());

class Feed {
  Feed({
    this.id,
    this.uuid,
    this.userIp,
    this.question,
    this.messageType,
    this.helpType,
    this.image1,
    this.status,
    this.isRead,
    this.evaluation,
    this.createdAt,
    this.updatedAt,
    this.isReplay,
  });

  int? id;
  String? uuid;
  String? userIp;
  String? question;
  int? messageType;
  dynamic helpType;
  String? image1;
  int? status;
  int? isRead;
  int? evaluation;
  String? createdAt;
  String? updatedAt;
  int? isReplay;

  factory Feed.fromJson(Map<String, dynamic> json) => Feed(
        id: json["id"],
        uuid: json["uuid"],
        userIp: json["user_ip"],
        question: json["question"],
        messageType: json["message_type"],
        helpType: json["help_type"],
        image1: json["image_1"],
        status: json["status"],
        isRead: json["is_read"],
        evaluation: json["evaluation"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        isReplay: json["is_replay"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "uuid": uuid,
        "user_ip": userIp,
        "question": question,
        "message_type": messageType,
        "help_type": helpType,
        "image_1": image1,
        "status": status,
        "is_read": isRead,
        "evaluation": evaluation,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "is_replay": isReplay,
      };
}

class GroupMessage {
  GroupMessage({
    this.id,
    this.title,
    this.content,
    this.createdAt,
  });
  int? id;
  String? title;
  String? content;
  String? createdAt;

  factory GroupMessage.fromJson(Map<String, dynamic> json) => GroupMessage(
        id: json["id"],
        title: json["title"],
        content: json["content"],
        createdAt: json["created_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "content": content,
        "created_at": createdAt,
      };
}
