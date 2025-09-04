// To parse this JSON data, do
//
//     final feedBack = feedBackFromJson(jsonString);

import 'dart:convert';

FeedBack feedBackFromJson(String str) => FeedBack.fromJson(json.decode(str));

String feedBackToJson(FeedBack data) => json.encode(data.toJson());

class FeedBack {
  List<Datum>? data;
  int? status;
  String? msg;
  bool? crypt;
  bool? isVip;

  FeedBack({
    this.data,
    this.status,
    this.msg,
    this.crypt,
    this.isVip,
  });

  factory FeedBack.fromJson(Map<String, dynamic> json) => FeedBack(
        data: json["data"] == null
            ? []
            : List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
        status: json["status"],
        msg: json["msg"],
        crypt: json["crypt"],
        isVip: json["isVip"],
      );

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data!.map((x) => x.toJson())),
        "status": status,
        "msg": msg,
        "crypt": crypt,
        "isVip": isVip,
      };
}

class Datum {
  int? id;
  String? nickname;
  String? thumb;
  dynamic message;
  int? messageType;
  int? status;
  String? createdAt;
  int? isLocal;
  List<ProblemList>? problemList;

  Datum({
    this.id,
    this.nickname,
    this.thumb,
    this.message,
    this.messageType,
    this.status,
    this.createdAt,
    this.isLocal,
    this.problemList,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        nickname: json["nickname"],
        thumb: json["thumb"],
        message: json["message"],
        messageType: json["messageType"],
        status: json["status"],
        createdAt: json["createdAt"],
        isLocal: json["isLocal"] == null ? null : json["isLocal"],
        problemList: json["problemList"] == null
            ? null
            : List<ProblemList>.from(
                json["problemList"].map((x) => ProblemList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "nickname": nickname,
        "thumb": thumb,
        "message": message,
        "messageType": messageType,
        "status": status,
        "createdAt": createdAt,
        "isLocal": isLocal == null ? null : isLocal,
        "problemList": problemList == null
            ? null
            : List<dynamic>.from(problemList!.map((x) => x.toJson())),
      };
}

class ProblemList {
  String? problem;
  String? reply;

  ProblemList({
    this.problem,
    this.reply,
  });

  factory ProblemList.fromJson(Map<String, dynamic> json) => ProblemList(
        problem: json["problem"],
        reply: json["reply"],
      );

  Map<String, dynamic> toJson() => {
        "problem": problem,
        "reply": reply,
      };
}
