// To parse this JSON data, do
//
//     final mineOder = mineOderFromJson(jsonString);

import 'dart:convert';

MineOder mineOderFromJson(String str) => MineOder.fromJson(json.decode(str));

String mineOderToJson(MineOder data) => json.encode(data.toJson());

class MineOder {
  MineOder({
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

  factory MineOder.fromJson(Map<String, dynamic> json) => MineOder(
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
      {this.id,
      this.aff,
      this.infoId,
      this.status,
      this.freezeMoney,
      this.createdAt,
      this.updatedAt,
      this.nickname,
      this.thumb,
      this.title,
      this.cityName,
      this.resources,
      this.uuid,
      this.nnum,
      this.discount,
      this.desc,
      this.type});

  int? id;
  int? aff;
  int? infoId;
  int? status;
  int? freezeMoney;
  String? createdAt;
  String? updatedAt;
  String? nickname;
  String? thumb;
  String? title;
  String? cityName;
  String? uuid;
  List<Resource>? resources;
  int? nnum;
  int? discount;
  String? desc;
  int? type;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"] == null ? null : json["id"],
        aff: json["aff"] == null ? null : json["aff"],
        infoId: json["info_id"] == null ? null : json["info_id"],
        status: json["status"] == null ? null : json["status"],
        freezeMoney: json["freeze_money"] == null ? null : json["freeze_money"],
        createdAt:
            json["created_at"] == null ? null : json["created_at"].toString(),
        updatedAt:
            json["updated_at"] == null ? null : json["updated_at"].toString(),
        nickname: json["nickname"] == null ? null : json["nickname"],
        thumb: json["thumb"] == null ? null : json["thumb"],
        title: json["title"] == null ? null : json["title"],
        cityName: json["cityName"] == null ? null : json["cityName"],
        resources: json["resources"] == null
            ? null
            : List<Resource>.from(
                json["resources"].map((x) => Resource.fromJson(x))),
        uuid: json['uuid'] == null ? null : json['uuid'],
        nnum: json['num'] == null ? null : json['num'],
        discount: json['discount'] == null ? null : json['discount'],
        desc: json['desc'] == null ? null : json['desc'],
        type: json['type'] == null ? null : json['type'],
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "aff": aff == null ? null : aff,
        "info_id": infoId == null ? null : infoId,
        "status": status == null ? null : status,
        "freeze_money": freezeMoney == null ? null : freezeMoney,
        "created_at": createdAt == null ? null : createdAt,
        "updated_at": updatedAt == null ? null : updatedAt,
        "nickname": nickname == null ? null : nickname,
        "thumb": thumb == null ? null : thumb,
        "title": title == null ? null : title,
        "cityName": cityName == null ? null : cityName,
        "resources": resources == null
            ? null
            : List<dynamic>.from(resources!.map((x) => x.toJson())),
        "uuid": uuid == null ? null : uuid,
        "nnum": nnum == null ? null : nnum,
        "discount": discount == null ? null : discount,
        "desc": desc == null ? null : desc,
        "type": type == null ? null : type,
      };
}

class Resource {
  Resource({
    this.id,
    this.url,
    this.infoId,
    this.type,
    this.sort,
    this.createdAt,
  });

  int? id;
  String? url;
  int? infoId;
  int? type;
  int? sort;
  String? createdAt;

  factory Resource.fromJson(Map<String, dynamic> json) => Resource(
        id: json["id"] == null ? null : json["id"],
        url: json["url"] == null ? null : json["url"],
        infoId: json["info_id"] == null ? null : json["info_id"],
        type: json["type"] == null ? null : json["type"],
        sort: json["sort"] == null ? null : json["sort"],
        createdAt:
            json["created_at"] == null ? null : json["created_at"].toString(),
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "url": url == null ? null : url,
        "info_id": infoId == null ? null : infoId,
        "type": type == null ? null : type,
        "sort": sort == null ? null : sort,
        "created_at": createdAt == null ? null : createdAt,
      };
}
