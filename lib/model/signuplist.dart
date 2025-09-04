import 'dart:convert';

SignUpResult signUpResultFromJson(String str) =>
    SignUpResult.fromJson(json.decode(str));

String signUpResultToJson(SignUpResult data) => json.encode(data.toJson());

class SignUpResult {
  Data? data;
  int? status;
  String? msg;
  bool? crypt;
  bool? isVip;

  SignUpResult({
    this.data,
    this.status,
    this.msg,
    this.crypt,
    this.isVip,
  });

  factory SignUpResult.fromJson(Map<String, dynamic> json) => SignUpResult(
        data: Data.fromJson(json["data"]),
        status: json["status"],
        msg: json["msg"],
        crypt: json["crypt"],
        isVip: json["isVip"],
      );

  Map<String, dynamic> toJson() => {
        "data": data!.toJson(),
        "status": status,
        "msg": msg,
        "crypt": crypt,
        "isVip": isVip,
      };
}

class Data {
  List<RewardInfo>? rewardInfo;
  int? days;
  int? isSign;
  String? tips;

  Data({this.rewardInfo, this.days, this.isSign, this.tips});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        rewardInfo: List<RewardInfo>.from(
            json["rewardInfo"].map((x) => RewardInfo.fromJson(x))),
        days: json["days"],
        isSign: json["isSign"],
        tips: json["tips"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "rewardInfo": List<dynamic>.from(rewardInfo!.map((x) => x.toJson())),
        "days": days,
        "isSign": isSign,
        "tips": tips ?? '',
      };
}

class RewardInfo {
  int? id;
  int? days;
  dynamic coin;
  String? createdAt;
  String? updatedAt;
  String? title;
  int? rewardType;

  RewardInfo(
      {this.id,
      this.days,
      this.coin,
      this.createdAt,
      this.updatedAt,
      this.title,
      this.rewardType});

  factory RewardInfo.fromJson(Map<String, dynamic> json) => RewardInfo(
        id: json["id"],
        days: json["days"],
        coin: json["coin"],
        createdAt: json["created_at"].toString(),
        updatedAt: json["updated_at"].toString(),
        title: json["title"].toString(),
        rewardType: json["reward_type"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "days": days,
        "coin": coin,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "title": title,
        "reward_type": rewardType
      };
}
