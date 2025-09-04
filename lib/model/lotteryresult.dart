// To parse this JSON data, do
//
//     final lotteryresult = lotteryresultFromJson(jsonString);

import 'dart:convert';

Lotteryresult lotteryresultFromJson(String str) => Lotteryresult.fromJson(json.decode(str));

String lotteryresultToJson(Lotteryresult data) => json.encode(data.toJson());

class Lotteryresult {
  Lotteryresult({
    this.data,
    this.status,
    this.msg,
    this.crypt,
    this.isVip,
  });

  resultData? data;
  int? status;
  String? msg;
  bool? crypt;
  bool? isVip;

  factory Lotteryresult.fromJson(Map<String, dynamic> json) => Lotteryresult(
        data: json["data"] == null ? null : resultData.fromJson(json["data"]),
        status: json["status"] == null ? null : json["status"],
        msg: json["msg"] == null ? null : json["msg"],
        crypt: json["crypt"] == null ? null : json["crypt"],
        isVip: json["isVip"] == null ? null : json["isVip"],
      );

  Map<String, dynamic> toJson() => {
        "data": data == null ? null : resultData().toJson(),
        "status": status == null ? null : status,
        "msg": msg == null ? null : msg,
        "crypt": crypt == null ? null : crypt,
        "isVip": isVip == null ? null : isVip,
      };
}

class resultData {
  resultData({this.result, this.playNote, this.betAmountList});
  List<ResultItem>? result;
  String? playNote;
  List<BetAmountItem>? betAmountList;
  factory resultData.fromJson(Map<String, dynamic> json) => resultData(
        result:
            json["result"] == null ? null : List<ResultItem>.from(json["result"].map((x) => ResultItem.fromJson(x))),
        playNote: json["play_note"] == null ? null : json["play_note"],
        betAmountList: json["bet_amount_list"] == null
            ? null
            : List<BetAmountItem>.from(json["bet_amount_list"].map((x) => BetAmountItem.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "result": result == null ? null : List<dynamic>.from(result!.map((x) => x.toJson())),
        "play_note": playNote == null ? null : playNote,
        "bet_amount_list": betAmountList == null ? null : betAmountList,
      };
}

class ResultItem {
  ResultItem({
    this.nickname,
    this.lotteryId,
    this.title,
  });

  String? nickname;
  int? lotteryId;
  String? title;

  factory ResultItem.fromJson(Map<String, dynamic> json) => ResultItem(
        nickname: json["nickname"] == null ? null : json["nickname"],
        lotteryId: json["lottery_id"] == null ? null : json["lottery_id"],
        title: json["title"] == null ? null : json["title"],
      );

  Map<String, dynamic> toJson() => {
        "nickname": nickname == null ? null : nickname,
        "lottery_id": lotteryId == null ? null : lotteryId,
        "title": title == null ? null : title,
      };
}

class BetAmountItem {
  BetAmountItem({
    this.value,
    this.title,
  });

  int? value;
  String? title;

  factory BetAmountItem.fromJson(Map<String, dynamic> json) => BetAmountItem(
        value: json["value"] == null ? null : json["value"],
        title: json["title"] == null ? null : json["title"],
      );

  Map<String, dynamic> toJson() => {
        "value": value == null ? null : value,
        "title": title == null ? null : title,
      };
}
