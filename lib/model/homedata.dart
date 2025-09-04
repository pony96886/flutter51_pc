// To parse this JSON data, do
//
//     final homeDataModel = homeDataModelFromJson(jsonString);

import 'dart:convert';

HomeDataModel homeDataModelFromJson(String str) =>
    HomeDataModel.fromJson(json.decode(str));

String homeDataModelToJson(HomeDataModel data) => json.encode(data.toJson());

class HomeDataModel {
  HomeDataModel({
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

  factory HomeDataModel.fromJson(Map<String, dynamic> json) => HomeDataModel(
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
  Data(
      {this.versionMsg,
      this.timestamp,
      this.ads,
      this.notice,
      this.help,
      this.bossChat,
      this.cityCode,
      this.config,
      this.forceChangeDomain,
      this.isStore,
      this.member,
      this.rechargeTips,
      this.useCopperCoinsTips});

  VersionMsg? versionMsg;
  int? timestamp;
  Ads? ads;
  Notice? notice;
  List<Help>? help;
  BossChat? bossChat;
  String? cityCode;
  Config? config;
  bool? forceChangeDomain;
  bool? isStore;
  Member? member;
  String? rechargeTips;
  Map? useCopperCoinsTips;
  factory Data.fromJson(Map<String, dynamic> json) => Data(
        versionMsg: VersionMsg.fromJson(json["versionMsg"]),
        timestamp: json["timestamp"],
        ads: Ads.fromJson(json["ads"]),
        notice: json["notice"] == null ? null : Notice.fromJson(json["notice"]),
        help: List<Help>.from(json["help"].map((x) => Help.fromJson(x))),
        bossChat: BossChat.fromJson(json["boss_chat"]),
        cityCode: json["cityCode"],
        config: Config.fromJson(json["config"]),
        forceChangeDomain: json["force_change_domain"],
        isStore: json["is_store"],
        member: Member.fromJson(json["member"]),
        rechargeTips: json["recharge_tips"] ?? '',
        useCopperCoinsTips: json["use_copper_coins_tips"] ?? new Map(),
      );

  Map<String, dynamic> toJson() => {
        "versionMsg": versionMsg!.toJson(),
        "timestamp": timestamp,
        "ads": ads!.toJson(),
        "notice": notice!.toJson(),
        "help": List<dynamic>.from(help!.map((x) => x.toJson())),
        "boss_chat": bossChat!.toJson(),
        "cityCode": cityCode,
        "config": config!.toJson(),
        "force_change_domain": forceChangeDomain,
        "is_store": isStore,
        "member": member!.toJson(),
        "recharge_tips": rechargeTips ?? "",
        "use_copper_coins_tips": useCopperCoinsTips ?? ""
      };
}

class Ads {
  Ads({
    this.id,
    this.title,
    this.description,
    this.imgUrl,
    this.url,
    this.position,
    this.androidDownUrl,
    this.iosDownUrl,
    this.type,
    this.status,
    this.oauthType,
    this.mvM3U8,
    this.channel,
    this.createdAt,
  });

  int? id;
  String? title;
  String? description;
  String? imgUrl;
  String? url;
  int? position;
  String? androidDownUrl;
  String? iosDownUrl;
  int? type;
  int? status;
  int? oauthType;
  String? mvM3U8;
  String? channel;
  String? createdAt;

  factory Ads.fromJson(Map<String, dynamic> json) => Ads(
        id: json["id"],
        title: json["title"],
        description: json["description"],
        imgUrl: json["img_url"],
        url: json["url"],
        position: json["position"],
        androidDownUrl: json["android_down_url"],
        iosDownUrl: json["ios_down_url"],
        type: json["type"],
        status: json["status"],
        oauthType: json["oauth_type"],
        mvM3U8: json["mv_m3u8"],
        channel: json["channel"],
        createdAt: json["created_at"].toString(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "img_url": imgUrl,
        "url": url,
        "position": position,
        "android_down_url": androidDownUrl,
        "ios_down_url": iosDownUrl,
        "type": type,
        "status": status,
        "oauth_type": oauthType,
        "mv_m3u8": mvM3U8,
        "channel": channel,
        "created_at": createdAt,
      };
}

class Config {
  Config(
      {this.imgUploadUrl,
      this.mp4UploadUrl,
      this.mobileMp4UploadUrl,
      this.uploadImgKey,
      this.uploadMp4Key,
      this.uuid,
      this.github,
      this.officialGroup,
      this.share,
      this.imgBase,
      this.line,
      this.officeSite,
      this.publishLevel,
      this.transactionPriceText,
      this.transactionPriceMax});

  String? imgUploadUrl;
  String? mp4UploadUrl;
  String? mobileMp4UploadUrl;
  String? uploadImgKey;
  String? uploadMp4Key;
  String? uuid;
  String? github;
  String? officialGroup;
  Share? share;
  String? imgBase;
  List<dynamic>? line;
  String? officeSite;
  int? publishLevel;
  String? transactionPriceText;
  String? transactionPriceMax;

  factory Config.fromJson(Map<String, dynamic> json) => Config(
        imgUploadUrl: json["img_upload_url"],
        mp4UploadUrl: json["mp4_upload_url"],
        mobileMp4UploadUrl: json["mobile_mp4_upload_url"],
        uploadImgKey: json["upload_img_key"],
        uploadMp4Key: json["upload_mp4_key"],
        uuid: json["uuid"],
        github: json["github"],
        officialGroup: json["official_group"],
        share: Share.fromJson(json["share"]),
        imgBase: json["img_base"],
        line: List<dynamic>.from(json["line"].map((x) => x)),
        officeSite: json["office_site"],
        publishLevel: json["publishLevel"],
        transactionPriceText: json["transaction_price_text"],
        transactionPriceMax: json["transaction_price_max"],
      );

  Map<String, dynamic> toJson() => {
        "img_upload_url": imgUploadUrl,
        "mp4_upload_url": mp4UploadUrl,
        "mobile_mp4_upload_url": mobileMp4UploadUrl,
        "upload_img_key": uploadImgKey,
        "upload_mp4_key": uploadMp4Key,
        "uuid": uuid,
        "github": github,
        "official_group": officialGroup,
        "share": share!.toJson(),
        "img_base": imgBase,
        "line": List<dynamic>.from(line!.map((x) => x)),
        "office_site": officeSite,
        "publishLevel": publishLevel,
        "transaction_price_text": transactionPriceText,
        "transaction_price_max": transactionPriceMax
      };
}

class Share {
  Share({
    this.affUrlCopy,
    this.affCode,
    this.affUrl,
  });

  AffUrlCopy? affUrlCopy;
  String? affCode;
  String? affUrl;

  factory Share.fromJson(Map<String, dynamic> json) => Share(
        affUrlCopy: AffUrlCopy.fromJson(json["aff_url_copy"]),
        affCode: json["aff_code"],
        affUrl: json["aff_url"],
      );

  Map<String, dynamic> toJson() => {
        "aff_url_copy": affUrlCopy!.toJson(),
        "aff_code": affCode,
        "aff_url": affUrl,
      };
}

class AffUrlCopy {
  AffUrlCopy({
    this.code,
    this.url,
  });

  String? code;
  String? url;

  factory AffUrlCopy.fromJson(Map<String, dynamic> json) => AffUrlCopy(
        code: json["code"],
        url: json["url"],
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "url": url,
      };
}

class Help {
  Help({
    this.items,
    this.type,
    this.name,
  });

  List<Item>? items;
  int? type;
  String? name;

  factory Help.fromJson(Map<String, dynamic> json) => Help(
        items: List<Item>.from(json["items"].map((x) => Item.fromJson(x))),
        type: json["type"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "items": List<dynamic>.from(items!.map((x) => x.toJson())),
        "type": type,
        "name": name,
      };
}

class Item {
  Item({
    this.id,
    this.question,
    this.answer,
    this.status,
    this.type,
    this.views,
    this.createdAt,
    this.updatedAt,
  });

  int? id;
  String? question;
  String? answer;
  int? status;
  int? type;
  int? views;
  String? createdAt;
  String? updatedAt;

  factory Item.fromJson(Map<String, dynamic> json) => Item(
        id: json["id"],
        question: json["question"],
        answer: json["answer"],
        status: json["status"],
        type: json["type"],
        views: json["views"] == null ? null : json["views"],
        createdAt:
            json["created_at"] == null ? null : json["created_at"].toString(),
        updatedAt:
            json["updated_at"] == null ? null : json["updated_at"].toString(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "question": question,
        "answer": answer,
        "status": status,
        "type": type,
        "views": views == null ? null : views,
        "created_at": createdAt == null ? null : createdAt,
        "updated_at": updatedAt == null ? null : updatedAt,
      };
}

class BossChat {
  BossChat({
    this.id,
    this.title,
    this.content,
    this.image,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  int? id;
  String? title;
  String? content;
  String? image;
  int? status;
  String? createdAt;
  String? updatedAt;

  factory BossChat.fromJson(Map<String, dynamic> json) => BossChat(
        id: json["id"],
        title: json["title"],
        content: json["content"],
        image: json["image"],
        status: json["status"],
        createdAt: json["created_at"].toString(),
        updatedAt: json["updated_at"].toString(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "content": content,
        "image": image,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
      };
}

class Member {
  Member(
      {this.uid,
      this.uuid,
      this.username,
      this.createdAt,
      this.updatedAt,
      this.roleId,
      this.gender,
      this.regip,
      this.regdate,
      this.lastip,
      this.lastvisit,
      this.expiredAt,
      this.lastpost,
      this.oltime,
      this.pageviews,
      this.score,
      this.aff,
      this.invitedBy,
      this.invitedNum,
      this.newCommentReply,
      this.newTopicReply,
      this.loginCount,
      this.appVersion,
      this.validate,
      this.share,
      this.isLogin,
      this.nickname,
      this.thumb,
      this.coins,
      this.fansCount,
      this.followedCount,
      this.videosCount,
      this.fabulousCount,
      this.likesCount,
      this.commentCount,
      this.vipLevel,
      this.personSignnatrue,
      this.birthday,
      this.stature,
      this.interest,
      this.city,
      this.photoAlbum,
      this.buyCount,
      this.newsNum,
      this.buildId,
      this.authStatus,
      this.exp,
      this.isVirtual,
      this.chatUid,
      this.phone,
      this.phonePrefix,
      this.freeViewCnt,
      this.lastactivity,
      this.money,
      this.agent,
      this.channel,
      this.oldVip,
      this.isSetPassword,
      this.email,
      this.vipInfo,
      this.vipUpgrade,
      this.isOriginalBlogger,
      this.allOriginalBloggerMoney,
      this.originalBloggerMoney,
      this.originalBloggerWithdrawCharge,
      this.originalCertifiedShare,
      this.isKeepAuth});
  int? uid;
  String? uuid;
  String? username;
  String? createdAt;
  String? updatedAt;
  int? roleId;
  int? gender;
  String? regip;
  int? regdate;
  String? lastip;
  int? lastvisit;
  int? expiredAt;
  int? lastpost;
  int? oltime;
  int? pageviews;
  int? score;
  String? aff;
  dynamic? invitedBy;
  int? invitedNum;
  int? newCommentReply;
  int? newTopicReply;
  int? loginCount;
  String? appVersion;
  int? validate;
  int? share;
  int? isLogin;
  String? nickname;
  dynamic? thumb;
  dynamic? coins;
  int? fansCount;
  int? followedCount;
  int? videosCount;
  int? fabulousCount;
  int? likesCount;
  int? commentCount;
  int? vipLevel;
  String? personSignnatrue;
  int? birthday;
  int? stature;
  String? interest;
  String? city;
  int? photoAlbum;
  int? buyCount;
  int? newsNum;
  int? buildId;
  int? authStatus;
  int? exp;
  String? isVirtual;
  String? chatUid;
  dynamic? phone;
  dynamic? phonePrefix;
  int? freeViewCnt;
  int? lastactivity;
  dynamic? money;
  int? agent;
  String? channel;
  int? oldVip;
  int? isSetPassword;
  String? email;
  Map? vipInfo;
  bool? vipUpgrade;
  int? isOriginalBlogger;
  num? allOriginalBloggerMoney;
  num? originalBloggerMoney;
  num? originalBloggerWithdrawCharge;
  num? originalCertifiedShare;
  int? isKeepAuth;
  factory Member.fromJson(Map<String, dynamic> json) => Member(
      uid: json["uid"],
      uuid: json["uuid"],
      username: json["username"],
      createdAt: json["created_at"].toString(),
      updatedAt: json["updated_at"].toString(),
      roleId: json["role_id"],
      gender: json["gender"],
      regip: json["regip"],
      regdate: json["regdate"],
      lastip: json["lastip"],
      lastvisit: json["lastvisit"],
      expiredAt: json["expired_at"],
      lastpost: json["lastpost"],
      oltime: json["oltime"],
      pageviews: json["pageviews"],
      score: json["score"],
      aff: json["aff"],
      invitedBy: json["invited_by"],
      invitedNum: json["invited_num"],
      newCommentReply: json["new_comment_reply"],
      newTopicReply: json["new_topic_reply"],
      loginCount: json["login_count"],
      appVersion: json["app_version"],
      validate: json["validate"],
      share: json["share"],
      isLogin: json["is_login"],
      nickname: json["nickname"],
      thumb: json["thumb"],
      coins: json["coins"],
      fansCount: json["fans_count"],
      followedCount: json["followed_count"],
      videosCount: json["videos_count"],
      fabulousCount: json["fabulous_count"],
      likesCount: json["likes_count"],
      commentCount: json["comment_count"],
      vipLevel: json["vip_level"],
      personSignnatrue: json["person_signnatrue"],
      birthday: json["birthday"],
      stature: json["stature"],
      interest: json["interest"],
      city: json["city"],
      photoAlbum: json["photo_album"],
      buyCount: json["buy_count"],
      newsNum: json["news_num"],
      buildId: json["build_id"],
      authStatus: json["auth_status"],
      exp: json["exp"],
      isVirtual: json["is_virtual"],
      chatUid: json["chat_uid"],
      phone: json["phone"] == null ? '' : json["phone"],
      phonePrefix: json["phone_prefix"] == null ? '' : json["phone_prefix"],
      freeViewCnt: json["free_view_cnt"],
      lastactivity: json["lastactivity"],
      money: json["money"] == null ? null : json["money"],
      agent: json["agent"] == null ? null : json["agent"],
      channel: json["channel"] == null ? null : json["channel"],
      oldVip: json["old_vip"],
      isSetPassword:
          json["is_set_password"] == null ? 0 : json["is_set_password"],
      email: json["email"] == null ? '' : json["email"],
      vipInfo: json["vip_info"] == null ? {} : json["vip_info"],
      vipUpgrade: json["vip_upgrade"] == null ? false : json["vip_upgrade"],
      isOriginalBlogger:
          json["is_original_blogger"] == null ? 0 : json["is_original_blogger"],
      allOriginalBloggerMoney: json["all_original_blogger_money"] == null
          ? 0
          : json["all_original_blogger_money"],
      originalBloggerMoney: json["original_blogger_money"] == null
          ? 0
          : json["original_blogger_money"],
      originalBloggerWithdrawCharge:
          json["original_blogger_withdraw_charge"] == null
              ? 0
              : json["original_blogger_withdraw_charge"],
      originalCertifiedShare: json["original_certified_share"] == null
          ? 0
          : json["original_certified_share"],
      isKeepAuth: json["is_keep_auth"]);

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "uuid": uuid,
        "username": username,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "role_id": roleId,
        "gender": gender,
        "regip": regip,
        "regdate": regdate,
        "lastip": lastip,
        "lastvisit": lastvisit,
        "expired_at": expiredAt,
        "lastpost": lastpost,
        "oltime": oltime,
        "pageviews": pageviews,
        "score": score,
        "aff": aff,
        "invited_by": invitedBy,
        "invited_num": invitedNum,
        "new_comment_reply": newCommentReply,
        "new_topic_reply": newTopicReply,
        "login_count": loginCount,
        "app_version": appVersion,
        "validate": validate,
        "share": share,
        "is_login": isLogin,
        "nickname": nickname,
        "thumb": thumb,
        "coins": coins,
        "fans_count": fansCount,
        "followed_count": followedCount,
        "videos_count": videosCount,
        "fabulous_count": fabulousCount,
        "likes_count": likesCount,
        "comment_count": commentCount,
        "vip_level": vipLevel,
        "person_signnatrue": personSignnatrue,
        "birthday": birthday,
        "stature": stature,
        "interest": interest,
        "city": city,
        "photo_album": photoAlbum,
        "buy_count": buyCount,
        "news_num": newsNum,
        "build_id": buildId,
        "auth_status": authStatus,
        "exp": exp,
        "is_virtual": isVirtual,
        "chat_uid": chatUid,
        "phone": phone,
        "phone_prefix": phonePrefix,
        "free_view_cnt": freeViewCnt,
        "lastactivity": lastactivity,
        "money": money,
        "agent": agent,
        "channel": channel,
        "old_vip": oldVip,
        "is_set_password": isSetPassword == null ? 0 : isSetPassword,
        "email": email ?? '',
        "vip_info": vipInfo ?? {},
        "vip_upgrade": vipUpgrade,
        "is_original_blogger": isOriginalBlogger,
        "all_original_blogger_money": allOriginalBloggerMoney,
        "original_blogger_money": originalBloggerMoney,
        "original_blogger_withdraw_charge": originalBloggerWithdrawCharge,
        "original_certified_share": originalCertifiedShare,
        "is_keep_auth": isKeepAuth
      };
}

class Notice {
  Notice({this.id, this.title, this.content, this.createdAt, this.type});

  int? id;
  String? title;
  String? content;
  String? createdAt;
  String? type;

  factory Notice.fromJson(Map<String, dynamic> json) => Notice(
        id: json["id"] == null ? null : json["id"],
        title: json["title"] == null ? null : json["title"],
        content: json["content"] == null ? null : json["content"],
        createdAt:
            json["created_at"] == null ? null : json["created_at"].toString(),
        type: json["type"] == null ? null : json["type"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "content": content,
        "created_at": createdAt,
        "type": type,
      };
}

class VersionMsg {
  VersionMsg({
    this.id,
    this.version,
    this.type,
    this.apk,
    this.tips,
    this.must,
    this.createdAt,
    this.status,
    this.message,
    this.mstatus,
    this.channel,
  });

  int? id;
  String? version;
  String? type;
  String? apk;
  String? tips;
  int? must;
  String? createdAt;
  int? status;
  String? message;
  int? mstatus;
  String? channel;

  factory VersionMsg.fromJson(Map<String, dynamic> json) => VersionMsg(
        id: json["id"],
        version: json["version"],
        type: json["type"],
        apk: json["apk"],
        tips: json["tips"],
        must: json["must"],
        createdAt: json["created_at"].toString(),
        status: json["status"],
        message: json["message"],
        mstatus: json["mstatus"],
        channel: json["channel"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "version": version,
        "type": type,
        "apk": apk,
        "tips": tips,
        "must": must,
        "created_at": createdAt,
        "status": status,
        "message": message,
        "mstatus": mstatus,
        "channel": channel,
      };
}
