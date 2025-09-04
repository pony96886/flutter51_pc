// To parse this JSON data, do
//
//     final getLotteryUserDetail = getLotteryUserDetailFromJson(jsonString);

import 'dart:convert';

GetLotteryUserDetail getLotteryUserDetailFromJson(String str) =>
    GetLotteryUserDetail.fromJson(json.decode(str));

String getLotteryUserDetailToJson(GetLotteryUserDetail data) =>
    json.encode(data.toJson());

class GetLotteryUserDetail {
  GetLotteryUserDetail({
    this.data,
    this.status,
    this.msg,
    this.crypt,
    this.isVip,
  });

  List<LotteryDatum>? data;
  int? status;
  String? msg;
  bool? crypt;
  bool? isVip;

  factory GetLotteryUserDetail.fromJson(Map<String, dynamic> json) =>
      GetLotteryUserDetail(
        data: json["data"] == null
            ? null
            : List<LotteryDatum>.from(
                json["data"].map((x) => LotteryDatum.fromJson(x))),
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

class LotteryDatum {
  LotteryDatum({
    this.id,
    this.aff,
    this.lotteryId,
    this.lotteryNum,
    this.investment,
    this.createdAt,
    this.updatedAt,
    this.nickname,
  });

  int? id;
  int? aff;
  int? lotteryId;
  int? lotteryNum;
  int? investment;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? nickname;

  factory LotteryDatum.fromJson(Map<String, dynamic> json) => LotteryDatum(
        id: json["id"] == null ? null : json["id"],
        aff: json["aff"] == null ? null : json["aff"],
        lotteryId: json["lottery_id"] == null ? null : json["lottery_id"],
        lotteryNum: json["lottery_num"] == null ? null : json["lottery_num"],
        investment: json["investment"] == null ? null : json["investment"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        nickname: json["nickname"] == null ? null : json["nickname"],
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "aff": aff == null ? null : aff,
        "lottery_id": lotteryId == null ? null : lotteryId,
        "lottery_num": lotteryNum == null ? null : lotteryNum,
        "investment": investment == null ? null : investment,
        "created_at": createdAt == null ? null : createdAt!.toIso8601String(),
        "updated_at": updatedAt == null ? null : updatedAt!.toIso8601String(),
        "nickname": nickname == null ? null : nickname,
      };
}
