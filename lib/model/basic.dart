// To parse this JSON data, do
//
//     final basic = basicFromJson(jsonString);

import 'dart:convert';

Basic basicFromJson(String str) => Basic.fromJson(json.decode(str));

String basicToJson(Basic data) => json.encode(data.toJson());

class Basic {
  Basic({
    this.data,
    this.status,
    this.msg,
    this.crypt,
    this.isVip,
  });

  dynamic data;
  int? status;
  String? msg;
  bool? crypt;
  bool? isVip;

  factory Basic.fromJson(Map<String, dynamic> json) => Basic(
        data: json["data"] == null ? null : json["data"],
        status: json["status"] == null ? null : json["status"],
        msg: json["msg"] == null ? null : json["msg"],
        crypt: json["crypt"] == null ? null : json["crypt"],
        isVip: json["isVip"] == null ? null : json["isVip"],
      );

  Map<String, dynamic> toJson() => {
        "data": data == null ? null : data,
        "status": status == null ? null : status,
        "msg": msg == null ? null : msg,
        "crypt": crypt == null ? null : crypt,
        "isVip": isVip == null ? null : isVip,
      };
}
