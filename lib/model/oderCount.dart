// To parse this JSON data, do
//
//     final oderCount = oderCountFromJson(jsonString);

import 'dart:convert';

OderCount oderCountFromJson(String str) => OderCount.fromJson(json.decode(str));

String oderCountToJson(OderCount data) => json.encode(data.toJson());

class OderCount {
  OderCount({
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

  factory OderCount.fromJson(Map<String, dynamic> json) => OderCount(
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
    this.unconfirm,
    this.confirm,
  });

  int? unconfirm;
  int? confirm;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        unconfirm: json["unconfirm"] == null ? null : json["unconfirm"],
        confirm: json["confirm"] == null ? null : json["confirm"],
      );

  Map<String, dynamic> toJson() => {
        "unconfirm": unconfirm == null ? null : unconfirm,
        "confirm": confirm == null ? null : confirm,
      };
}
