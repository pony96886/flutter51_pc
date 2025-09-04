import 'dart:convert';

InternationalCity internationalCityFromJson(String str) =>
    InternationalCity.fromJson(json.decode(str));

String internationalCityToJson(InternationalCity data) =>
    json.encode(data.toJson());

class InternationalCity {
  InternationalCity({
    this.data,
    this.status,
    this.msg,
    this.crypt,
    this.isVip,
    this.line,
  });

  CityData? data;
  int? status;
  String? msg;
  bool? crypt;
  bool? isVip;
  String? line;

  factory InternationalCity.fromJson(Map<String, dynamic> json) =>
      InternationalCity(
        data: json["data"] == null ? null : CityData.fromJson(json["data"]),
        status: json["status"] == null ? null : json["status"],
        msg: json["msg"] == null ? null : json["msg"],
        crypt: json["crypt"] == null ? null : json["crypt"],
        isVip: json["isVip"] == null ? null : json["isVip"],
        line: json["line"] == null ? null : json["line"],
      );

  Map<String, dynamic> toJson() => {
        "data": data == null ? null : data!.toJson(),
        "status": status == null ? null : status,
        "msg": msg == null ? null : msg,
        "crypt": crypt == null ? null : crypt,
        "isVip": isVip == null ? null : isVip,
        "line": line == null ? null : line,
      };
}

class CityData {
  CityData({
    this.abroad,
    this.internal,
  });

  List<Abroad>? abroad;
  List<Internal>? internal;

  factory CityData.fromJson(Map<String, dynamic> json) => CityData(
        abroad: json["abroad"] == null
            ? null
            : List<Abroad>.from(json["abroad"].map((x) => Abroad.fromJson(x))),
        internal: json["internal"] == null
            ? null
            : List<Internal>.from(
                json["internal"].map((x) => Internal.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "abroad": abroad == null
            ? null
            : List<dynamic>.from(abroad!.map((x) => x.toJson())),
        "internal": internal == null
            ? null
            : List<dynamic>.from(internal!.map((x) => x.toJson())),
      };
}

class Abroad {
  Abroad({
    this.id,
    this.name,
    this.country,
    this.cityCode,
  });

  int? id;
  String? name;
  String? country;
  int? cityCode;

  factory Abroad.fromJson(Map<String, dynamic> json) => Abroad(
        id: json["id"] == null ? null : json["id"],
        name: json["name"] == null ? null : json["name"],
        country: json["country"] == null ? null : json["country"],
        cityCode: json["cityCode"] == null ? null : json["cityCode"],
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "name": name == null ? null : name,
        "country": country == null ? null : country,
        "cityCode": cityCode == null ? null : cityCode,
      };
}

class Internal {
  Internal({
    this.id,
    this.areaname,
    this.parentid,
    this.shortname,
    this.lng,
    this.lat,
    this.level,
    this.position,
    this.sort,
  });

  int? id;
  String? areaname;
  int? parentid;
  String? shortname;
  String? lng;
  String? lat;
  int? level;
  String? position;
  int? sort;

  factory Internal.fromJson(Map<String, dynamic> json) => Internal(
        id: json["id"] == null ? null : json["id"],
        areaname: json["areaname"] == null ? null : json["areaname"],
        parentid: json["parentid"] == null ? null : json["parentid"],
        shortname: json["shortname"] == null ? null : json["shortname"],
        lng: json["lng"] == null ? null : json["lng"],
        lat: json["lat"] == null ? null : json["lat"],
        level: json["level"] == null ? null : json["level"],
        position: json["position"] == null ? null : json["position"],
        sort: json["sort"] == null ? null : json["sort"],
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "areaname": areaname == null ? null : areaname,
        "parentid": parentid == null ? null : parentid,
        "shortname": shortname == null ? null : shortname,
        "lng": lng == null ? null : lng,
        "lat": lat == null ? null : lat,
        "level": level == null ? null : level,
        "position": position == null ? null : position,
        "sort": sort == null ? null : sort,
      };
}
