// To parse this JSON data, do
//
//     final flollow = flollowFromJson(jsonString);

import 'dart:convert';

Flollow flollowFromJson(String str) => Flollow.fromJson(json.decode(str));

String flollowToJson(Flollow data) => json.encode(data.toJson());

class Flollow {
  Flollow({
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

  factory Flollow.fromJson(Map<String, dynamic> json) => Flollow(
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
  Datum(
      {this.nickname,
      this.avatar,
      this.aff,
      this.gender,
      this.roleId,
      this.sign,
      this.isFollow,
      this.vipLevel,
      this.agent});

  String? nickname;
  String? avatar;
  int? aff;
  int? gender;
  int? agent;
  int? roleId;
  String? sign;
  bool? isFollow;
  int? vipLevel;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        nickname: json["nickname"] == null ? null : json["nickname"],
        agent: json["agent"] == null ? null : json["agent"],
        avatar: json["avatar"] == null ? null : json["avatar"],
        aff: json["aff"] == null ? null : json["aff"],
        gender: json["gender"] == null ? null : json["gender"],
        roleId: json["role_id"] == null ? null : json["role_id"],
        sign: json["sign"] == null ? null : json["sign"],
        isFollow: json["is_follow"] == null ? null : json["is_follow"],
        vipLevel: json["vip_level"] == null ? null : json["vip_level"],
      );

  Map<String, dynamic> toJson() => {
        "nickname": nickname == null ? null : nickname,
        "agent": agent == null ? null : agent,
        "avatar": avatar == null ? null : avatar,
        "aff": aff == null ? null : aff,
        "gender": gender == null ? null : gender,
        "role_id": roleId == null ? null : roleId,
        "sign": sign == null ? null : sign,
        "is_follow": isFollow == null ? null : isFollow,
        "vip_level": vipLevel == null ? null : vipLevel,
      };
}
