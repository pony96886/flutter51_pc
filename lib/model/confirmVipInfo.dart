// To parse this JSON data, do
//
//     final confirmVipInfo = confirmVipInfoFromJson(jsonString);

import 'dart:convert';

ConfirmVipInfo confirmVipInfoFromJson(String str) =>
    ConfirmVipInfo.fromJson(json.decode(str));

String confirmVipInfoToJson(ConfirmVipInfo data) => json.encode(data.toJson());

class ConfirmVipInfo {
  ConfirmVipInfo({
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

  factory ConfirmVipInfo.fromJson(Map<String, dynamic> json) => ConfirmVipInfo(
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
    this.aff,
    this.type,
    this.value,
    this.status,
    this.expiredAt,
    this.source,
    this.desc,
    this.updatedAt,
    this.createdAt,
    this.id,
  });

  int? aff;
  int? type;
  int? value;
  int? status;
  String? expiredAt;
  int? source;
  int? desc;
  String? updatedAt;
  String? createdAt;
  int? id;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        aff: json["aff"] == null ? null : json["aff"],
        type: json["type"] == null ? null : json["type"],
        value: json["value"] == null ? null : json["value"],
        status: json["status"] == null ? null : json["status"],
        expiredAt: json["expired_at"] == null ? null : json["expired_at"],
        source: json["source"] == null ? null : json["source"],
        desc: json["desc"] == null ? null : json["desc"],
        updatedAt: json["updated_at"] == null ? null : json["updated_at"],
        createdAt: json["created_at"] == null ? null : json["created_at"],
        id: json["id"] == null ? null : json["id"],
      );

  Map<String, dynamic> toJson() => {
        "aff": aff == null ? null : aff,
        "type": type == null ? null : type,
        "value": value == null ? null : value,
        "status": status == null ? null : status,
        "expired_at": expiredAt == null ? null : expiredAt,
        "source": source == null ? null : source,
        "desc": desc == null ? null : desc,
        "updated_at": updatedAt == null ? null : updatedAt,
        "created_at": createdAt == null ? null : createdAt,
        "id": id == null ? null : id,
      };
}
