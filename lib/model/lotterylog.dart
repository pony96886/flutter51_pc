// To parse this JSON data, do
//
//     final getLotteryLog = getLotteryLogFromJson(jsonString);

import 'dart:convert';

GetLotteryLog getLotteryLogFromJson(String str) =>
    GetLotteryLog.fromJson(json.decode(str));

String getLotteryLogToJson(GetLotteryLog data) => json.encode(data.toJson());

class GetLotteryLog {
  GetLotteryLog({
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

  factory GetLotteryLog.fromJson(Map<String, dynamic> json) => GetLotteryLog(
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
    this.lotteryId,
    this.lotteryNum,
    this.aff,
    this.total,
    this.rewardAff,
    this.updatedAt,
    this.nickname,
  });

  int? lotteryId;
  int? lotteryNum;
  int? aff;
  String? total;
  int? rewardAff;
  DateTime? updatedAt;
  String? nickname;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        lotteryId: json["lottery_id"] == null ? null : json["lottery_id"],
        lotteryNum: json["lottery_num"] == null ? null : json["lottery_num"],
        aff: json["aff"] == null ? null : json["aff"],
        total: json["total"] == null ? null : json["total"],
        rewardAff: json["reward_aff"] == null ? null : json["reward_aff"],
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        nickname: json["nickname"] == null ? null : json["nickname"],
      );

  Map<String, dynamic> toJson() => {
        "lottery_id": lotteryId == null ? null : lotteryId,
        "lottery_num": lotteryNum == null ? null : lotteryNum,
        "aff": aff == null ? null : aff,
        "total": total == null ? null : total,
        "reward_aff": rewardAff == null ? null : rewardAff,
        "updated_at": updatedAt == null ? null : updatedAt!.toIso8601String(),
        "nickname": nickname == null ? null : nickname,
      };
}
