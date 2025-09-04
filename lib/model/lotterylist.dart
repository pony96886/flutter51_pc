// To parse this JSON data, do
//
//     final getLottery = getLotteryFromJson(jsonString);

import 'dart:convert';

GetLottery getLotteryFromJson(String str) =>
    GetLottery.fromJson(json.decode(str));

String getLotteryToJson(GetLottery data) => json.encode(data.toJson());

class GetLottery {
  GetLottery({
    this.data,
    this.status,
    this.msg,
    this.crypt,
    this.isVip,
  });

  List<Datum>? data;
  int? status;
  String? msg;
  bool? crypt;
  bool? isVip;

  factory GetLottery.fromJson(Map<String, dynamic> json) => GetLottery(
        data: json["data"] == null
            ? null
            : List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
        status: json["status"] == null ? null : json["status"],
        msg: json["msg"] == null ? null : json["msg"],
        crypt: json["crypt"] == null ? null : json["crypt"],
        isVip: json["isVip"] == null ? null : json["isVip"],
      );

  Map<String, dynamic> toJson() => {
        "data": data == null
            ? null
            : List<dynamic>.from(data!.map((x) => x.toJson())),
        "status": status == null ? null : status,
        "msg": msg == null ? null : msg,
        "crypt": crypt == null ? null : crypt,
        "isVip": isVip == null ? null : isVip,
      };
}

class Datum {
  Datum({
    this.id,
    this.type,
    this.title,
    this.reward,
    this.commission,
    this.lotteryNum,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.currentInvestment,
    this.myInvestment,
    this.userNum,
    this.lastRewardUser,
    this.newestUser,
    this.desc,
    this.minBetAmount,
  });

  int? id;
  int? type;
  String? title;
  int? reward;
  int? commission;
  int? lotteryNum;
  dynamic status;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic currentInvestment;
  dynamic myInvestment;
  dynamic userNum;
  User? lastRewardUser;
  List<User>? newestUser;
  String? desc;
  int? minBetAmount;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"] == null ? null : json["id"],
        type: json["type"] == null ? null : json["type"],
        title: json["title"] == null ? null : json["title"],
        reward: json["reward"] == null ? null : json["reward"],
        commission: json["commission"] == null ? null : json["commission"],
        lotteryNum: json["lottery_num"] == null ? null : json["lottery_num"],
        status: json["status"] == null ? null : json["status"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        currentInvestment: json["currentInvestment"],
        myInvestment:
            json["myInvestment"] == null ? null : json["myInvestment"],
        userNum: json["userNum"] == null ? null : json["userNum"],
        lastRewardUser: json["lastRewardUser"] == null
            ? null
            : User.fromJson(json["lastRewardUser"]),
        newestUser: json["newestUser"] == null
            ? null
            : List<User>.from(json["newestUser"].map((x) => User.fromJson(x))),
        desc: json["desc"] ?? '',
        minBetAmount: json["min_bet_amount"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "type": type == null ? null : type,
        "title": title == null ? null : title,
        "reward": reward == null ? null : reward,
        "commission": commission == null ? null : commission,
        "lottery_num": lotteryNum == null ? null : lotteryNum,
        "status": status == null ? null : status,
        "created_at": createdAt == null ? null : createdAt!.toIso8601String(),
        "updated_at": updatedAt == null ? null : updatedAt!.toIso8601String(),
        "currentInvestment": currentInvestment,
        "myInvestment": myInvestment == null ? null : myInvestment,
        "userNum": userNum == null ? null : userNum,
        "lastRewardUser":
            lastRewardUser == null ? null : lastRewardUser!.toJson(),
        "newestUser": newestUser == null
            ? null
            : List<dynamic>.from(newestUser!.map((x) => x.toJson())),
        "desc": desc == null ? null : desc,
        "min_bet_amount": minBetAmount ?? 0,
      };
}

class User {
  User({
    this.nickname,
    this.thumb,
  });

  String? nickname;
  String? thumb;

  factory User.fromJson(Map<String, dynamic> json) => User(
        nickname: json["nickname"] == null ? null : json["nickname"],
        thumb: json["thumb"] == null ? null : json["thumb"],
      );

  Map<String, dynamic> toJson() => {
        "nickname": nickname == null ? null : nickname,
        "thumb": thumb == null ? null : thumb,
      };
}
