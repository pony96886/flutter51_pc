import 'dart:convert';

import 'package:chaguaner2023/model/basic.dart';
import 'package:chaguaner2023/model/confirmVipInfo.dart';
import 'package:chaguaner2023/model/getlotteryuserdetail.dart';
import 'package:chaguaner2023/model/homedata.dart';
import 'package:chaguaner2023/model/lotterylist.dart';
import 'package:chaguaner2023/model/lotteryresult.dart';
import 'package:chaguaner2023/model/mineOder.dart';
import 'package:chaguaner2023/model/oderCount.dart';
import 'package:chaguaner2023/store/global.dart';
import 'package:chaguaner2023/store/homeConfig.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/encdecrypt.dart';
import 'package:chaguaner2023/utils/http.dart';
import 'package:chaguaner2023/utils/log_utils.dart';
import 'package:chaguaner2023/utils/network_http.dart';
import 'package:chaguaner2023/view/im/im.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

//获取全局config接口
Future getHomeConfig(BuildContext context) async {
  Response<dynamic> res = await NetworkHttp.instance.post('/api/home/config');
  print(res);
  if (res.data['data']!['cityCode'].toString().length >= 10) {
    context.read<GlobalState>().setCityCode(res.data['data']['cityInfo']['cityCode']);
    context.read<GlobalState>().setCityName(res.data['data']['cityInfo']['name']);
  } else {
    context.read<GlobalState>().setCityCode(res.data['data']['cityInfo']['id']);
    context.read<GlobalState>().setCityName(res.data['data']['cityInfo']['areaname']);
  }
  AppGlobal.shouApp = res.data['data']['showApp'] == 1;
  AppGlobal.popAppAds = res.data['data']['pop_app_ads'] ?? [];
  AppGlobal.popAds = res.data['data']['popAds'];
  AppGlobal.publishRule = res.data['data']['post_rule'] ?? new Map();
  AppGlobal.useCopperCoinsTips = res.data['data']['use_copper_coins_tips'] ?? new Map();
  AppGlobal.VipList = res.data['data']['vip_list'];
  AppGlobal.userPrivilege = res.data['data']['user_privilege'];
  AppGlobal.enableGirlChat = res.data['data']['enable_girl_chat'];
  AppGlobal.switchFavoriteTab = res.data['data']['switch_favorite_tab'] ?? 0;
  // LogUtilS.d('权限:${AppGlobal.userPrivilege}');
  HomeDataModel result = HomeDataModel.fromJson(res.data);
  if (result.status != 0) {
    // AppGlobal.appBox.put('api_lines', []);
    Provider.of<HomeConfig>(context, listen: false).setConfig(res.data['data']);
    AppGlobal.uploadVideoKey = result.data!.config!.uploadMp4Key!;
    AppGlobal.uploadVideoUrl = result.data!.config!.mobileMp4UploadUrl!;
    AppGlobal.uploadBigVideoUrl = result.data!.config!.mobileMp4UploadUrl!;
    AppGlobal.uploadBigVideoKey = result.data!.config!.uploadMp4Key!;
    AppGlobal.vipLevel = result.data!.member!.vipLevel!;
    AppGlobal.bannerImgBase = result.data!.config!.imgBase!;
    AppGlobal.uploadImgKey = result.data!.config!.uploadImgKey ?? "";
    AppGlobal.uploadImgUrl = result.data!.config!.imgUploadUrl!;
    AppGlobal.officeSite = result.data!.config!.officeSite!;
    WebSocketUtility.uuid = result.data!.member!.uuid!;
    WebSocketUtility.avatar = result.data!.member!.thumb!;
    WebSocketUtility.phone = result.data!.member!.username!;
    WebSocketUtility.nickname = result.data!.member!.nickname!;
    WebSocketUtility.aff = result.data!.member!.aff!;
    WebSocketUtility.gender = result.data!.member!.gender!;
    WebSocketUtility.agent = result.data!.member!.authStatus!;
    WebSocketUtility.vipLevel = result.data!.member!.vipLevel!;
    AppGlobal.appDb!.getAccountContact();
    CommonUtils.getImPath(context, isHomeconfig: true);
    CommonUtils.getUnreadMsg();
    List lineList = result.data!.config!.line!;
    EncDecrypt.encryptLine(lineList.join(',')).then((linelist) {
      AppGlobal.appBox!.put('api_lines', linelist);
    });
  }
  return res.data;
}

// 获取im
Future<Map?> getIm(status) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/user/getIm", data: {'no_check_privilege': status});
    return data.data;
  } catch (e) {
    return null;
  }
}

//系统消息
Future getSystemNotice() async {
  try {
    Response<dynamic> res = await NetworkHttp.instance.post('/api/message/getUnreadCount');
    return res.data;
  } catch (e) {
    return null;
  }
}

// 大视频上传
Future uploadvideo() async {
  try {
    Response<dynamic> res = await NetworkHttp.instance.post('/api/article/getUploadAddress');
    return res.data;
  } catch (e) {
    return null;
  }
}

// 填写邀请码
Future onInvitation(dynamic affCode) async {
  try {
    Response<dynamic> data = await NetworkHttp.instance.post("/api/user/invitation", data: {"aff_code": affCode});
    return data.data;
  } catch (e) {
    return null;
  }
}

// 首页=>tab菜单
Future getTabList() async {
  try {
    Response<dynamic> data = await NetworkHttp.instance.post("/api/info/getInfoType");
    return data.data;
  } catch (e) {
    return null;
  }
}

// 个人中心发布、资源、铜板数
Future<Map?> getProfilePage() async {
  try {
    Response<dynamic> data = await NetworkHttp.instance.post("/api/user/userinfo");
    UserInfo.isMerchant = data.data['data']['is_merchant'];
    return data.data;
  } catch (e) {
    return null;
  }
}

// 获取城市列表
Future getAbroadCity() async {
  try {
    Response<dynamic> data = await NetworkHttp.instance.post("/api/info/getAbroadCity");
    return data.data;
  } catch (e) {
    return null;
  }
}

//专属客服
Future getCustomerService() async {
  try {
    Response data = await NetworkHttp.instance.post("/api/user/getCustomerService");
    return data.data;
  } catch (e) {
    return null;
  }
}

Future getMenuList() async {
  try {
    Response data = await NetworkHttp.instance.post("/api/home/getTab");
    return data.data;
  } catch (e) {
    return null;
  }
}

//游戏余额
Future<Map?> getBalance() async {
  try {
    Response data = await NetworkHttp.instance.post("/api/game/balance");
    return data.data;
  } catch (e) {
    return null;
  }
}

//应用中心
Future getApplicationCenter() async {
  try {
    Response data = await NetworkHttp.instance.post("/api/home/appCenter");
    return data.data;
  } catch (e) {
    return null;
  }
}

Future appClick(int id) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/home/appclick");
    return data.data;
  } catch (e) {
    return null;
  }
}

//获取广告图
Future getDetail_ad(int position) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/home/getAds", data: {'position': position});
    return data.data;
  } catch (e) {
    return null;
  }
}

//认证推荐
Future listAuth() async {
  try {
    Response data = await NetworkHttp.instance.post("/api/goods/listAuth");
    return data.data;
  } catch (e) {
    return null;
  }
}

//认证推荐
Future listGuarantee() async {
  try {
    Response data = await NetworkHttp.instance.post("/api/goods/listGuarantee");
    return data.data;
  } catch (e) {
    return null;
  }
}

// 茶女郎茶铺列表
Future getFilterChapuList(int page, int limit, int type, String score, int order) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/goods/listFilter",
        data: {'page': page, 'limit': limit, 'type': type, 'score': score, 'order': order});
    return data.data;
  } catch (e) {
    return null;
  }
}

// 验证报告列表
Future reportConfirmList(int page, int limit, int? auth) async {
  try {
    Response data =
        await NetworkHttp.instance.post("/api/info/confirmList", data: {"page": page, 'limit': limit, 'auth': auth});
    return data.data;
  } catch (e) {
    return null;
  }
}

// 首页tab列表=>
Future getHomeTabList(int page, int limit, int type, int authentication, int filter, int isMoney) async {
  var params = {'page': page, 'limit': limit, 'filter': filter, 'authentication': authentication, 'is_money': isMoney};
  if (type != 0) {
    params['type'] = type;
  }
  try {
    Response data = await NetworkHttp.instance.post("/api/info/getInfoList", data: params);
    return data.data;
  } catch (e) {
    return null;
  }
}

// 茶友分享广告位
Future getAds() async {
  try {
    Response data = await NetworkHttp.instance.post("/api/home/getADsByPositionAndCityCode", data: {'position': 2});
    return data.data;
  } catch (e) {
    return null;
  }
}

// 首页tab列表未购买资源列表
Future getInfoList(int page, int limit, int type, int authentication) async {
  var params = {
    'page': page,
    'limit': limit,
    'authentication': authentication,
  };
  if (type != 0) {
    params['type'] = type;
  }
  try {
    Response data = await NetworkHttp.instance.post("/api/goods/getInfoList", data: params);
    return data.data;
  } catch (e) {
    return null;
  }
}

// 设置地区
Future<Map?> setArea(dynamic areaCode) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/user/setArea", data: {"areaCode": areaCode});
    return data.data;
  } catch (e) {
    return null;
  }
}

// 删除未审核通过的作品
Future deleteFailInfo(dynamic id) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/info/deleteFailInfo", data: {"id": id});
    return data.data;
  } catch (e) {
    return null;
  }
}

// 资源详情页=>收藏
Future collectResources(dynamic id) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/user/favorite", data: {"info_id": id});
    return data.data;
  } catch (e) {
    return null;
  }
}

// 雅间筛选选项
Future<Map?> getFilterOption() async {
  try {
    Response data = await NetworkHttp.instance.post("/api/info/getFilterOption");
    return data.data;
  } catch (e) {
    return null;
  }
}

// 雅间标签列表
Future<Map?> getTags() async {
  try {
    Response data = await NetworkHttp.instance.post("/api/info/getTags");
    return data.data;
  } catch (e) {
    return null;
  }
}

// 雅间的预约数量
Future<Map?> getMyAppointmentNum() async {
  try {
    Response data = await NetworkHttp.instance.post("/api/user/getMyAppointmentNum");
    return data.data;
  } catch (e) {
    return null;
  }
}

//雅间城市列表
Future<Map?> getVipCityListc() async {
  try {
    Response data = await NetworkHttp.instance.post("/api/info/getVipCityList");
    return data.data;
  } catch (e) {
    return null;
  }
}

Future<Map?> filterVipInfo({
  int? page,
  int? limit,
  int? postType,
  String? cityCode,
  String? age,
  String? height,
  String? cup,
  String? price,
  List? tags,
  String? videoValid,
}) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/info/filterVipInfo", data: {
      'page': page,
      'limit': limit,
      'cityCode': cityCode,
      'post_type': postType,
      'age': age,
      'height': height,
      'cup': cup,
      'price': price,
      'tags': tags,
      'video_valid': videoValid
    });
    return data.data;
  } catch (e) {
    return null;
  }
}

Future<Map?> filterVipInfoByRule({
  int? page,
  int? limit,
  int? postType,
  String? cityCode,
  String? age,
  String? height,
  String? cup,
  String? price,
  List? tags,
  String? videoValid,
  String? rule,
}) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/info/filterVipInfoByRule", data: {
      'page': page,
      'limit': limit,
      'cityCode': cityCode,
      'post_type': postType,
      'age': age,
      'height': height,
      'cup': cup,
      'price': price,
      'tags': tags,
      'video_valid': videoValid,
      'rule': rule
    });
    return data.data;
  } catch (e) {
    return null;
  }
}

// 获取当前意向单状态
Future<Map?> getCurrentRequireStatus() async {
  try {
    Response data = await NetworkHttp.instance.post("/api/user/getCurrentRequireStatus");
    return data.data;
  } catch (e) {
    return null;
  }
}

Future getInfoByUUID(String uuid) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/user/getInfoByUUID", data: {"uuid": uuid});
    return data.data;
  } catch (e) {
    return null;
  }
}

// 删除雅间资源
Future<Map?> deleteVipInfo(String infoId) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/info/deleteVipInfo", data: {'info_id': infoId});
    return data.data;
  } catch (e) {
    return null;
  }
}

Future<Map?> changeStatusVipInfo(int infoId) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/info/changeStatusVipInfo", data: {'info_id': infoId});
    return data.data;
  } catch (e) {
    return null;
  }
}

//获取充值信息
Future<Map?> rechargeValue() async {
  try {
    Response data = await NetworkHttp.instance.post("/api/game/rechargeValueNew");
    return data.data;
  } catch (e) {
    return null;
  }
}

// 游戏主页
Future<Map?> getGameList() async {
  try {
    Response data = await NetworkHttp.instance.post("/api/game/index");
    return data.data;
  } catch (e) {
    return null;
  }
}

//进入游戏
Future<Map?> enterGame(int id) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/game/enter", data: {'id': id});
    return data.data;
  } catch (e) {
    return null;
  }
}

// 茶老板日常尬谈列表
Future getChatList(int page, int limit) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/home/chatList", data: {'page': page, 'limit': limit});
    return data.data;
  } catch (e) {
    return null;
  }
}

Future getPrelist() async {
  try {
    Response data = await NetworkHttp.instance.post("/api/talk/pre_list", data: {});
    return data.data;
  } catch (e) {
    return null;
  }
}

Future getTalkList(int page, int limit, String cateId) async {
  try {
    Response data =
        await NetworkHttp.instance.post("/api/talk/list", data: {'page': page, 'limit': limit, 'cate_id': cateId});
    return data.data;
  } catch (e) {
    return null;
  }
}

// 茶老板日常尬谈详情
Future getChatDetail(int id) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/home/chatDetail", data: {'id': id});
    return data.data;
  } catch (e) {
    return null;
  }
}

// new 茶老板日常尬谈详情 /api/talk/detail
Future gettalkDetail(int id) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/talk/detail", data: {'id': id});
    return data.data;
  } catch (e) {
    return null;
  }
}

// 报告详情页=>获取报告详情
Future<Map?> getConfirmDetail(int id) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/info/confirmDetail", data: {'id': id});
    return data.data;
  } catch (e) {
    return null;
  }
}

// 购买报告
Future<Map?> userBuyConfirm({String? id, int? useCoin}) async {
  try {
    Response data =
        await NetworkHttp.instance.post("/api/info/userBuyConfirm", data: {'confirm_id': id, "useCoin": useCoin});
    return data.data;
  } catch (e) {
    return null;
  }
}

// 黑榜列表
Future<Map?> getBlackList(int page, int limit, String cityCode) async {
  try {
    Response data = await NetworkHttp.instance
        .post("/api/black/getList", data: {'page': page, 'limit': limit, 'cityCode': cityCode});
    return data.data;
  } catch (e) {
    return null;
  }
}

// 黑榜发布
Future<Map?> getBlackType() async {
  try {
    Response data = await NetworkHttp.instance.post("/api/black/getType");
    return data.data;
  } catch (e) {
    return null;
  }
}

// 待验证资源页=>待验证列表
Future<Map?> getUnconfirmList(int page, int limit) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/info/unconfirmList", data: {'page': page, 'limit': limit});
    return data.data;
  } catch (e) {
    return null;
  }
}

//设置密码
Future<Map?> setPassword(String password, String passwordConfirm) async {
  try {
    Response data = await NetworkHttp.instance
        .post("/api/account/setPassword", data: {'password': password, 'passwordConfirm': passwordConfirm});
    return data.data;
  } catch (e) {
    return null;
  }
}

//获取验证码
Future<Map?> getCaptcha(String phone, String phonePrefix, int type, String code) async {
  try {
    Response data = await NetworkHttp.instance
        .post("/api/home/send", data: {'phone': phone, 'phonePrefix': phonePrefix, 'type': type, 'code': code});
    return data.data;
  } catch (e) {
    return null;
  }
}

Future<Map?> sendEmailCode(String email) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/account/sendEmailCode", data: {'email': email});
    return data.data;
  } catch (e) {
    return null;
  }
}

Future<Map?> bindEmail(String email, String code) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/account/bindEmail", data: {'email': email, 'code': code});
    return data.data;
  } catch (e) {
    return null;
  }
}

//手机登录
Future<Map?> loginByPhone(String phone, String phonePrefix, String code) async {
  try {
    Response data = await NetworkHttp.instance
        .post("/api/account/loginByPhone", data: {'phone': phone, 'phonePrefix': phonePrefix, 'code': code});
    return data.data;
  } catch (e) {
    return null;
  }
}

//密码登录
Future<Map?> loginByPassword(String username, String password) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/account/loginByPassword", data: {
      'username': username,
      'password': password,
    });
    return data.data;
  } catch (e) {
    return null;
  }
}

//手机注册
Future<Map?> registerByPhone(String phone, String phonePrefix, String code, String invitedAff) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/account/registerByPhone",
        data: {'phone': phone, 'phonePrefix': phonePrefix, 'code': code, 'invitedAff': invitedAff});
    return data.data;
  } catch (e) {
    return null;
  }
}

//密码注册
Future<Map?> registerByPassword(
    String username, String password, String confirmpwd, String invitedAff, String email, String code) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/account/registerByPassword", data: {
      'username': username,
      'password': password,
      'confirm_pwd': confirmpwd,
      'invitedAff': invitedAff,
      'email': email,
      'code': code,
    });
    return data.data;
  } catch (e) {
    return null;
  }
}

//获取图像验证码
Future<Map?> getImgCaptcha() async {
  try {
    Response data = await NetworkHttp.instance.post("/api/home/getCaptcha");
    return data.data;
  } catch (e) {
    return null;
  }
}

//验证用户名
Future<Map?> validateUsername(String username) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/account/validateUsername", data: {'username': username});
    return data.data;
  } catch (e) {
    return null;
  }
}

//验证用户名
Future<Map?> forgetPassword(
    String username, String password, String passwordConfirm, String phone, String phonePrefix, String code) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/account/forgetPassword", data: {
      'username': username,
      'password': password,
      'passwordConfirm': passwordConfirm,
      'phone': phone,
      'phonePrefix': phonePrefix,
      'code': code
    });
    return data.data;
  } catch (e) {
    return null;
  }
}

// 修改头像
Future<Map?> upDateUserAvatar(dynamic thumb) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/user/updateUserInfo", data: {'thumb': thumb});
    return data.data;
  } catch (e) {
    return null;
  }
}

// 修改头像
Future<Map?> upDateUserNickname(dynamic nickname) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/user/updateUserInfo", data: {'nickname': nickname});
    return data.data;
  } catch (e) {
    return null;
  }
}

// 兑换会员
Future<Map?> postExchange(dynamic cdk) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/home/exchange", data: {'cdk': cdk});
    return data.data;
  } catch (e) {
    return null;
  }
}

// 绑定手机
Future<Map?> bindPhone(String phone, String phonePrefix, String code) async {
  try {
    Response data = await NetworkHttp.instance
        .post("/api/account/bindPhone", data: {'phone': phone, 'phonePrefix': phonePrefix, 'code': code});
    return data.data;
  } catch (e) {
    return null;
  }
}

// 绑定手机
Future<Map?> changePhone(
    String oldPhone, String oldPhonePrefix, String oldCode, String phone, String phonePrefix, String code) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/account/changePhone", data: {
      'oldPhone': oldPhone,
      'oldPhonePrefix': oldPhonePrefix,
      'oldCode': oldCode,
      'phone': phone,
      'phonePrefix': phonePrefix,
      'code': code
    });
    return data.data;
  } catch (e) {
    return null;
  }
}

// 商品列表
Future<Map?> getProductListOfCard(int type) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/order/goodsList", data: {'type': type});
    return data.data;
  } catch (e) {
    return null;
  }
}

//元宝兑换会员
Future<Map?> vipExchange(int id) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/order/exchange", data: {'product_id': id});
    return data.data;
  } catch (e) {
    return null;
  }
}

//订单列表
Future<Map?> onCreatePay(String way, String type, dynamic id, {String? code}) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/order/createPaying",
        data: {'pay_way': way, 'pay_type': type, 'product_id': id, 'sdk': 1, 'code': code});
    return data.data;
  } catch (e) {
    return null;
  }
}

//是否图像验证码
Future<Map?> isCaptcha(int type) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/home/isCaptcha", data: {'type': type});
    return data.data;
  } catch (e) {
    return null;
  }
}

//获取天字一号房信息
Future<Map?> getTianziyihaoInfo() async {
  try {
    Response data = await NetworkHttp.instance.post("/api/club/info");
    return data.data;
  } catch (e) {
    return null;
  }
}

//加入天字一号房信息
Future<Map?> jointianziyihao() async {
  try {
    Response data = await NetworkHttp.instance.post("/api/club/join");
    return data.data;
  } catch (e) {
    return null;
  }
}

//订单记录 1vip 2元宝
Future<Map?> getOrderList(int type, int page) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/order/orderList", data: {'type': type, 'page': page});
    return data.data;
  } catch (e) {
    return null;
  }
}

//在线客服=>发送消息
Future<Map?> sendFeeding(String content, int type, int helpType) async {
  try {
    Response data = await NetworkHttp.instance
        .post("/api/message/feeding", data: {'content': content, 'type': type, 'helpType': helpType});
    return data.data;
  } catch (e) {
    return null;
  }
}

//在线客服=>消息列表
Future<Map?> getFeedbackList(int page) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/message/feedback", data: {'page': page});
    return data.data;
  } catch (e) {
    return null;
  }
}

//品茶宝列表
// {
//    page:1
//limit:50
//type:income收入|spend支出
//}
Future<Map?> pcbList({int page = 1, String? type}) async {
  try {
    String typeStr = type!.isEmpty ? 'spend' : type;
    Response data = await NetworkHttp.instance
        .post("/api/transaction/tranList", data: {"page": page, "limit": 10, "type": typeStr});
    return data.data;
  } catch (e) {
    return null;
  }
}

// 品茶宝取消
Future<Map?> pcbCancel(dynamic id) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/transaction/tranCancel", data: {"id": id});
    return data.data;
  } catch (e) {
    return null;
  }
}

// 品茶宝确认
Future<Map?> pcbConfirm(dynamic id) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/transaction/tranConfirm", data: {"id": id});
    return data.data;
  } catch (e) {
    return null;
  }
}

// 品茶宝确认
Future<Map?> withdrawMoney(String account, String name, String amount, {int type = 0}) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/order/withdraw",
        data: {'account': account, 'name': name, 'amount': double.parse(amount), 'type_money': type});
    return data.data;
  } catch (e) {
    return null;
  }
}

// 提现记录
Future<Map?> getListWithdraw(int page, {int type = 0}) async {
  try {
    Response data =
        await NetworkHttp.instance.post("/api/order/listWithdraw", data: {'page': page, 'type_money': type});
    return data.data;
  } catch (e) {
    return null;
  }
}

// 获取提现账号
Future<Map?> getListAccount() async {
  try {
    Response data = await NetworkHttp.instance.post("/api/user/listAccount");
    return data.data;
  } catch (e) {
    return null;
  }
}

// 添加提现账号
Future<Map?> addAccount(String account, String name) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/user/addAccount", data: {'account': account, 'name': name});
    return data.data;
  } catch (e) {
    return null;
  }
}

// 删除提现账号
Future<Map?> delAccount(int id) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/user/delAccount", data: {'id': id});
    return data.data;
  } catch (e) {
    return null;
  }
}

// 推广信息
Future<Map?> getProxyNewInfo() async {
  try {
    Response data = await NetworkHttp.instance.post("/api/proxy/info");
    return data.data;
  } catch (e) {
    return null;
  }
}

// 推广列表
Future<Map?> getListInvition(int page, int limit) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/user/listInvition", data: {"page": page, 'limit': limit});
    return data.data;
  } catch (e) {
    return null;
  }
}

// 支付
Future<Map?> payGame(String amount, int type, String code) async {
  try {
    Response data =
        await NetworkHttp.instance.post("/api/game/pay", data: {'amount': amount, 'type': type, 'code': code});
    return data.data;
  } catch (e) {
    return null;
  }
}

// 划转
Future<Map?> transferPay({String? amount, int? direction}) async {
  try {
    Response data =
        await NetworkHttp.instance.post("/api/game/transfer", data: {'amount': amount, 'direction': direction});
    return data.data;
  } catch (e) {
    return null;
  }
}

// 充值记录
Future<Map?> getGemeOrder(int page) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/game/orderList", data: {'page': page});
    return data.data;
  } catch (e) {
    return null;
  }
}

//提现记录
Future<Map?> getWithdrawList(int page) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/game/withdrawList", data: {'page': page});
    return data.data;
  } catch (e) {
    return null;
  }
}

//获取优惠券
Future<Map?> getYouhuiquan(int page, int limit, String filter) async {
  try {
    Response data = await NetworkHttp.instance
        .post("/api/coupon/getUserCouponList", data: {'page': page, 'limit': limit, 'filter': filter});
    return data.data;
  } catch (e) {
    return null;
  }
}

// 资源详情页=>购买
Future<Map?> buyResources(String id, int useCoin) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/info/userBuyInfo", data: {"info_id": id, "useCoin": useCoin});
    return data.data;
  } catch (e) {
    return null;
  }
}

// 资源详情页=>获取资源详情
Future<Map?> checkerGetInfoDetail(String id) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/info/checkerGetInfoDetail", data: {"id": id});
    return data.data;
  } catch (e) {
    return null;
  }
}

// 资源详情页=>获取资源详情
Future<Map?> getResourcesInfo(String id) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/info/getInfo", data: {"id": id});
    return data.data;
  } catch (e) {
    return null;
  }
}

// 资源详情页=>获取真实信息列表
Future<Map?> getConfirmList(String id, int page, int limit) async {
  try {
    Response data = await NetworkHttp.instance
        .post("/api/info/getConfirmList", data: {"info_id": id, 'page': page, 'limit': limit});
    return data.data;
  } catch (e) {
    return null;
  }
}

// 资源详情页=>获取真实信息列表
Future<Map?> deleteUserBuy(String id) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/user/deleteUserBuy", data: {"id": id});
    return data.data;
  } catch (e) {
    return null;
  }
}

// 品茶宝托管
Future<Map?> pcbManage(String id, String count) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/transaction/add", data: {"info_id": id, "money": count});
    return data.data;
  } catch (e) {
    return null;
  }
}

// 编辑意向单
Future<Map?> editRequire(
    {int? id,
    String? cityName,
    String? cityCode,
    String? latestTime,
    String? costWay,
    String? serviceType,
    String? highestPrice,
    String? serviceTag,
    String? comment}) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/info/editRequire", data: {
      'id': id,
      'cityName': cityName,
      'cityCode': cityCode,
      'latestTime': latestTime,
      'costWay': costWay,
      'serviceType': serviceType,
      'highestPrice': highestPrice,
      'comment': comment,
      'serviceTag': serviceTag
    });
    return data.data;
  } catch (e) {
    return null;
  }
}

// 提交意向单
Future<Map?> postRequire(
    {String? cityName,
    String? cityCode,
    String? latestTime,
    String? costWay,
    String? serviceType,
    String? highestPrice,
    String? serviceTag,
    String? comment,
    int? couponId}) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/info/postRequire", data: {
      'cityName': cityName,
      'cityCode': cityCode,
      'latestTime': latestTime,
      'costWay': costWay,
      'serviceType': serviceType,
      'highestPrice': highestPrice,
      'comment': comment,
      'serviceTag': serviceTag,
      'coupon_id': couponId
    });
    return data.data;
  } catch (e) {
    return null;
  }
}

// 获取当前意向单状态
Future<Map?> getEditRequire(int id) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/info/getEditRequire", data: {"id": id});
    return data.data;
  } catch (e) {
    return null;
  }
}

// 雅间资源详情
Future<Map?> getVipInfoDetail(String id, {int type = 0}) async {
  try {
    Response data =
        await NetworkHttp.instance.post("/api/info/getVipInfoDetail", data: {"id": id, "notRequiredPrivilege": type});
    return data.data;
  } catch (e) {
    return null;
  }
}

// 预约
Future<Map?> isAppointment(String infoId, int? couponId) async {
  try {
    Response data =
        await NetworkHttp.instance.post("/api/user/appointment", data: {'info_id': infoId, 'couponId': couponId});
    return data.data;
  } catch (e) {
    return null;
  }
}

// 雅间资源详情-验证列表
Future<Map?> getVipInfoConfirm(int page, int limit, String infoId) async {
  try {
    Response data = await NetworkHttp.instance
        .post("/api/info/getVipInfoConfirm", data: {'page': page, 'limit': limit, 'info_id': infoId});
    return data.data;
  } catch (e) {
    return null;
  }
}

// 雅间资源详情-验证列表
Future<Map?> favoriteVip(String id) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/user/favoriteVip", data: {"info_id": id});
    return data.data;
  } catch (e) {
    return null;
  }
}

// 茶女郎收藏
Future<Map?> favoriteGilr(String id) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/goods/favorite", data: {"infoId": id});
    return data.data;
  } catch (e) {
    return null;
  }
}

//花魁阁楼资源
Future<Map?> huoKuiGeLou(int page) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/vvip/filterInfo", data: {"page": page});
    return data.data;
  } catch (e) {
    return null;
  }
}

//获取配置
Future<Map?> getSetting(String key) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/home/getSetting", data: {"name": key});
    return data.data;
  } catch (e) {
    return null;
  }
}

//探花视频详情
Future<Map?> tanhuaDetailData(String id) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/mv/getDetail", data: {'mvId': id});
    return data.data;
  } catch (e) {
    return null;
  }
}

// 一元春宵
Future<GetLottery?> getLottery() async {
  try {
    Response data = await NetworkHttp.instance.post("/api/lottery/list");
    return GetLottery.fromJson(data.data);
  } catch (e) {
    return null;
  }
}

// 一元春宵中奖轮播
Future<Lotteryresult?> getLotteryResult() async {
  try {
    Response data = await NetworkHttp.instance.post("/api/lottery/getLotteryResult");
    return Lotteryresult.fromJson(data.data);
  } catch (e) {
    return null;
  }
}

// 一元春宵 投入元宝
Future<Basic?> postLotteryAction(int id, String investment) async {
  try {
    Response data =
        await NetworkHttp.instance.post("/api/lottery/lottery", data: {'lottery_id': id, 'investment': investment});
    return Basic.fromJson(data.data);
  } catch (e) {
    return null;
  }
}

// 投注记录
Future<GetLotteryUserDetail?> getLotteryUserDetail({int page = 1, int limit = 10, int? id}) async {
  try {
    Response data = await NetworkHttp.instance
        .post("/api/lottery/getLotteryUserDetail", data: {"page": page, "limit": limit, "id": id});
    return GetLotteryUserDetail.fromJson(data.data);
  } catch (e) {
    return null;
  }
}

// 签到
Future<Basic?> onSignUpSubmit() async {
  try {
    Response data = await NetworkHttp.instance.post("/api/user/signUp");
    return Basic.fromJson(data.data);
  } catch (e) {
    return null;
  }
}

// 我的预约count
Future<OderCount?> getOderCount() async {
  try {
    Response data = await NetworkHttp.instance.post("/api/user/countMyAppointment");
    return OderCount.fromJson(data.data);
  } catch (e) {
    return null;
  }
}

//客户预约count
Future<OderCount?> getUserOderCount() async {
  try {
    Response data = await NetworkHttp.instance.post("/api/user/countClientAppointment");
    return OderCount.fromJson(data.data);
  } catch (e) {
    return null;
  }
}

// 官方预约单
Future<OderCount?> myAppointmentOfficialList() async {
  try {
    Response data = await NetworkHttp.instance.post("/api/user/myAppointmentOfficialList");
    return OderCount.fromJson(data.data);
  } catch (e) {
    return null;
  }
}

//确认交易
Future<Basic?> confirmAppointment(int id) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/user/confirmAppointment", data: {'id': id});
    return Basic.fromJson(data.data);
  } catch (e) {
    return null;
  }
}

//我的预约单
Future<MineOder?> getMyOder(int page, int limit, int type) async {
  try {
    Response data =
        await NetworkHttp.instance.post("/api/user/myAppointment", data: {'page': page, 'limit': limit, 'type': type});
    return MineOder.fromJson(data.data);
  } catch (e) {
    return null;
  }
}

//我的预约单
Future<MineOder?> getUserOder(int page, int limit, int type) async {
  try {
    Response data = await NetworkHttp.instance
        .post("/api/user/clientAppointment", data: {'page': page, 'limit': limit, 'type': type});
    return MineOder.fromJson(data.data);
  } catch (e) {
    return null;
  }
}

//取消预约
Future<Basic?> cancelAppointment(int id) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/user/cancelAppointment", data: {'id': id});
    return Basic.fromJson(data.data);
  } catch (e) {
    return null;
  }
}

//雅间用户评价
Future<ConfirmVipInfo?> userEvaluation({
  required int id,
  required int girlFace,
  required int girlService,
  required int isReal,
  required String desc,
  required List medias,
  required List tag_ids,
}) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/user/confirmVipInfo", data: {
      'id': id,
      'girl_face': girlFace,
      'girl_service': girlService,
      'is_real': isReal,
      'desc': desc,
      'medias': medias,
      'tag_ids': tag_ids
    });
    LogUtilS.d(data.data);
    return ConfirmVipInfo.fromJson(data.data);
  } catch (e) {
    return null;
  }
}

// 取消 预约 意向单
Future<Map?> setOder(int id, int status) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/info/updatePickStatus", data: {"id": id, 'status': status});
    return data.data;
  } catch (e) {
    return null;
  }
}

// 取消 预约 意向单
Future<Map?> confirmRequire(int id) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/info/confirmRequire", data: {"id": id});
    return data.data;
  } catch (e) {
    return null;
  }
}

// 取消 预约 意向单
Future<Map?> cancelRequire(int id) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/info/cancelRequire", data: {"id": id});
    return data.data;
  } catch (e) {
    return null;
  }
}

// 茶女郎审核状态
Future<Map?> getPerson() async {
  try {
    Response data = await NetworkHttp.instance.post("/api/goods/getPerson");
    return data.data;
  } catch (e) {
    return null;
  }
}

// 上传妹子数量
Future<Map?> getVipInfoCount(int? cityCode, {String? aff}) async {
  try {
    Response data =
        await NetworkHttp.instance.post("/api/user/myVipInfoCount", data: {'cityCode': cityCode, 'aff': aff});
    return data.data;
  } catch (e) {
    return null;
  }
}

// 工作台列表
Future<Map?> myVipInfo(int? page, int? limit, int? status, int? cityCode, String? search) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/user/myVipInfo",
        data: {'page': page, 'limit': limit, 'status': status, 'cityCode': cityCode, 'search': search});
    return data.data;
  } catch (e) {
    return null;
  }
}

// 发布雅间资源
Future<Map?> publishVipInfo(Map datas) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/info/postVipInfo", data: {...datas});
    return data.data;
  } catch (e) {
    return null;
  }
}

// 编辑雅间资源
Future<Map?> editVipInfo(Map datas) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/info/editVipInfo", data: {...datas});
    return data.data;
  } catch (e) {
    return null;
  }
}

// 编辑时获取大厅详情信息
Future<Map?> geteditInfo(int? id) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/info/geteditInfo", data: {"id": id});
    return data.data;
  } catch (e) {
    return null;
  }
}

// 获取联系方式类型
Future<Map?> getContactType() async {
  try {
    Response data = await NetworkHttp.instance.post("/api/v150/getContactType");
    return data.data;
  } catch (e) {
    return null;
  }
}

// 发布资源
Future<Map?> publishInfo(
    String title,
    int type,
    int cityCode,
    String girlNum,
    String girlAge,
    int girlFace,
    int girlService,
    int env,
    String girlServiceType,
    String businessHours,
    String fee,
    String desc,
    String address,
    String phone,
    List pic,
    String tranFlag,
    // String isMoney,
    String price,
    int postType,
    String contactInfo,
    List screenshot) async {
  try {
    Response data = await NetworkHttp.instance.post(
      "/api/info/postInfo",
      data: {
        "title": title,
        "type": type,
        "cityCode": cityCode,
        "girl_num": girlNum,
        "girl_age": girlAge,
        "girl_face": girlFace,
        "girl_service": girlService,
        "env": env,
        "girl_service_type": girlServiceType,
        "business_hours": businessHours,
        "fee": fee,
        "desc": desc,
        "address": address,
        "phone": phone,
        "pic": List<dynamic>.from(pic.map((x) => x)),
        "tran_flag": int.parse(tranFlag),
        // "is_money": isMoney,
        "price": price,
        "post_type": postType,
        "contact_info": contactInfo,
        "screenshot": screenshot
      },
    );
    return data.data;
  } catch (e) {
    return null;
  }
}

// 编辑大厅帖子信息
Future<Map?> editInfo(
    int id,
    String fee,
    String desc,
    String address,
    String phone,
    List pic,
    String girlNum,
    String girlAge,
    int girlFace,
    int girlService,
    int env,
    String girlServiceType,
    String businessHours,
    String tranFlag,
    String price,
    int postType,
    String contactInfo,
    List screenshot) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/info/editInfo", data: {
      'id': id,
      'fee': fee,
      'desc': desc,
      'address': address,
      'phone': phone,
      'pic': pic,
      'girl_num': girlNum,
      'girl_age': girlAge,
      'girl_face': girlFace,
      'girl_service': girlService,
      'env': env,
      'girl_service_type': girlServiceType,
      'business_hours': businessHours,
      'tran_flag': int.parse(tranFlag),
      'price': price,
      "post_type": postType,
      "contact_info": contactInfo,
      "screenshot": screenshot
    });
    return data.data;
  } catch (e) {
    return null;
  }
}

// 随机用户
Future<Map?> getRewardUser() async {
  try {
    Response data = await NetworkHttp.instance.post("/api/v150/getRewardUser");
    return data.data;
  } catch (e) {
    return null;
  }
}

// 随机用户
Future<Map?> numberIntro() async {
  try {
    Response data = await NetworkHttp.instance.post("/api/user/userInfo");
    return data.data;
  } catch (e) {
    return null;
  }
}

// 获取茶铺信息
Future<Map?> getChapuStore() async {
  try {
    Response data = await NetworkHttp.instance.post("/api/goods/getStore");
    return data.data;
  } catch (e) {
    return null;
  }
}

// 发铺茶铺
Future<Map?> releaseChapu(Map<String, dynamic> reqData) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/goods/postStore", data: reqData);
    return data.data;
  } catch (e) {
    return null;
  }
}

// 修改茶铺
Future<Map?> editChapuStore(Map<String, dynamic> reqData) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/goods/editStore", data: reqData);
    return data.data;
  } catch (e) {
    return null;
  }
}

// 茶女郎编辑
Future<Map?> editGirl(Map reqData) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/goods/editGirl", data: reqData);
    return data.data;
  } catch (e) {
    return null;
  }
}

// 茶女郎发布
Future<Map?> postGirl(Map reqData) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/goods/postGirl", data: reqData);
    return data.data;
  } catch (e) {
    return null;
  }
}

// 修改茶女郎工作状态
Future<Map?> setGirlWorkingStatus(int status) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/goods/setGirlWorkingStatus", data: {'status': status});
    return data.data;
  } catch (e) {
    return null;
  }
}

// 修改茶女郎工作状态
Future<Map?> setGirlChatStatus(int status) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/goods/setChatStatus", data: {'status': status});
    return data.data;
  } catch (e) {
    return null;
  }
}

// 茶女郎详情
Future<Map?> getChaGirlDetail(int id) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/goods/getPersonDetail", data: {'id': id});
    return data.data;
  } catch (e) {
    return null;
  }
}

// 茶铺详情
Future<Map?> getChapuDetail(int id) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/goods/getStoreDetail", data: {'id': id});
    return data.data;
  } catch (e) {
    return null;
  }
}

// 黑榜发布
Future<Map?> blackPostInfo(String title, String content, int type, String cityCode, List pic) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/black/post",
        data: {'title': title, 'content': content, 'type': type, 'cityCode': cityCode, 'pic': pic});
    return data.data;
  } catch (e) {
    return null;
  }
}

//验证资源页=》真实信息   编辑
Future<Map?> editConfirmInfo(
    String girlName,
    String price,
    String time,
    String address,
    String girlBody,
    String girlFaceLike,
    String girlCup,
    String girlServiceDetail,
    double girlFace,
    double girlService,
    double env,
    String? id,
    List pic) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/info/editConfirm", data: {
      "girl_name": girlName,
      "price": price,
      "time": time,
      "address": address,
      "girl_body": girlBody,
      "girl_face_like": girlFaceLike,
      "girl_cup": girlCup,
      "girl_service_detail": girlServiceDetail,
      "girl_face": girlFace,
      "girl_service": girlService,
      "env": env,
      "id": id,
      "pic": pic
    });
    return data.data;
  } catch (e) {
    return null;
  }
}

Future<Map?> submitConfirmInfo(
    String girlName,
    String price,
    String time,
    String address,
    String girlBody,
    String girlFaceLike,
    String girlCup,
    String girlServiceDetail,
    double girlFace,
    double girlService,
    double env,
    String? infoId,
    List pic) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/info/confirm", data: {
      "girl_name": girlName,
      "price": price,
      "time": time,
      "address": address,
      "girl_body": girlBody,
      "girl_face_like": girlFaceLike,
      "girl_cup": girlCup,
      "girl_service_detail": girlServiceDetail,
      "girl_face": girlFace,
      "girl_service": girlService,
      "env": env,
      "info_id": infoId,
      "pic": pic
    });
    return data.data;
  } catch (e) {
    return null;
  }
}

// 获取验证报告状态
Future<Map?> getBaogao(int id) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/info/getConfirmStatus", data: {'info_id': id});
    return data.data;
  } catch (e) {
    return null;
  }
}

//验证资源页=》虚假信息
Future<Map?> submitFakeInfo(int type, String detail, String infoId, List pic) async {
  try {
    Response data = await NetworkHttp.instance
        .post("/api/info/fakeInfo", data: {"type": type, "detail": detail, "info_id": infoId, "pic": pic});
    return data.data;
  } catch (e) {
    return null;
  }
}

// 获取用户发帖数
Future<Map?> getUserPostNum(String aff) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/v150/getUserPostNum", data: {'aff': aff});
    return data.data;
  } catch (e) {
    return null;
  }
}

//获取聊天双方意向单详情
Future<Map?> getBothRequire(String? agentUuid, String? clientUuid) async {
  try {
    Response data = await NetworkHttp.instance
        .post("/api/info/getBothRequire", data: {"agentUuid": agentUuid, "clientUuid": clientUuid});
    return data.data;
  } catch (e) {
    return null;
  }
}

//预约单详情
Future<Map?> getRequireDetail(String id) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/info/getRequireDetail", data: {"id": id});
    return data.data;
  } catch (e) {
    return null;
  }
}

//抢单
Future<Map?> gradOder(int id) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/info/pick", data: {"id": id});
    return data.data;
  } catch (e) {
    return null;
  }
}

//获取聊天记录
Future<Map?> getImHistory({int page = 1, String? uuid}) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/Chat/getHistory", data: {
      "limit": 50,
      "page": page,
      "from_uuid": uuid,
    });
    return data.data;
  } catch (e) {
    return null;
  }
}

//游戏提现
Future<Map?> drawGame(String bankcard, String name, String amount) async {
  try {
    Response data =
        await NetworkHttp.instance.post("/api/game/draw", data: {'bankcard': bankcard, 'name': name, 'amount': amount});
    return data.data;
  } catch (e) {
    return null;
  }
}

//更改密码
Future<Map?> updatePassword(String password, String newPassword, String newPasswordConfirm) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/account/updatePassword",
        data: {'password': password, 'newPassword': newPassword, 'newPasswordConfirm': newPasswordConfirm});
    return data.data;
  } catch (e) {
    return null;
  }
}

//审核帖子
Future<Map?> checkerCheck(String id, int status, String? reason) async {
  try {
    Response data =
        await NetworkHttp.instance.post("/api/user/checkerCheck", data: {"id": id, "status": status, "reason": reason});
    return data.data;
  } catch (e) {
    return null;
  }
}

//鉴茶师领取任务
Future<Map?> checkerPick(String id) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/user/checkerPick", data: {"id": id});
    return data.data;
  } catch (e) {
    return null;
  }
}

//广告点击统计
Future<Map?> popAdsChick(String id) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/home/popAdsChick", data: {"id": id});
    return data.data;
  } catch (e) {
    return null;
  }
}

// 优惠券列表
Future<Map?> getCouponList({int page = 1, int type = 2}) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/coupon/list", data: {
      "limit": 10,
      "page": page,
      "type": type,
    });
    return data.data;
  } catch (e) {
    return null;
  }
}

// 兑换优惠券
Future<Map?> onExChangeCoupon({int? id}) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/coupon/exchange", data: {"coupon_id": id});
    return data.data;
  } catch (e) {
    return null;
  }
}

// 优惠卷兑换会员
Future<Map?> onCouponExchange({int? id, String? idList}) async {
  try {
    Response data =
        await NetworkHttp.instance.post("/api/order/couponExchange", data: {"product_id": id, "my_coupon_ids": idList});
    return data.data;
  } catch (e) {
    return null;
  }
}

// 优惠卷兑换临时会员
Future<Map?> onExchangeTempVip({dynamic id}) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/coupon/exchangeTempVip", data: {"my_coupon_ids": id});
    return data.data;
  } catch (e) {
    return null;
  }
}

// 官方预约单
Future<Map?> onOfficialAppointment({int? money}) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/user/officialAppointment", data: {"money": money});
    return data.data;
  } catch (e) {
    return null;
  }
}

// 群发消息列表
Future<Map?> getGroupNoticeList({int page = 1, int limit = 10}) async {
  try {
    Response data =
        await NetworkHttp.instance.post("/api/message/getGroupNoticeList", data: {"page": page, "limit": limit});
    return data.data;
  } catch (e) {
    return null;
  }
}

// 确认官方预约单
Future<Map?> confrimAppointmentOfficial({String orderNum = ""}) async {
  try {
    Response data =
        await NetworkHttp.instance.post("/api/user/confrimAppointmentOfficial", data: {"order_no": orderNum});
    return data.data;
  } catch (e) {
    return null;
  }
}

// 官方置顶
Future<Map?> getTopList() async {
  try {
    Response data = await NetworkHttp.instance.post("/api/info/getTeaGirlTopList", data: {"page": 1});
    return data.data;
  } catch (e) {
    return null;
  }
}

// 雅间置顶
Future<Map?> getVipTopList({String citycode = '110100', int postType = 1}) async {
  try {
    Response data =
        await NetworkHttp.instance.post("/api/info/getVipTopList", data: {"cityCode": citycode, "post_type": postType});
    return data.data;
  } catch (e) {
    return null;
  }
}

// 雅间置顶
Future<Map?> categoriesList() async {
  try {
    Response data = await NetworkHttp.instance.post("/api/product/types_list", data: {"page": 1, 'limit': 21});
    return data.data;
  } catch (e) {
    return null;
  }
}

// 排行榜
Future<Map?> rankList() async {
  try {
    Response data = await NetworkHttp.instance.post("/api/ranking/pre_list", data: {});
    return data.data;
  } catch (e) {
    return null;
  }
}

// 商品详情
Future<Map?> productList(id) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/product/detail", data: {"id": id});
    return data.data;
  } catch (e) {
    return null;
  }
}

// 评论列表
Future<Map?> productConmentList({int? id, int? page, int? limit}) async {
  try {
    Response data = await NetworkHttp.instance
        .post("/api/product/comment_list", data: {"product_id": id, "page": page, "limit": limit});
    return data.data;
  } catch (e) {
    return null;
  }
}

Future<Map?> talkCommentList({int? id, int? page, int? limit}) async {
  try {
    Response data =
        await NetworkHttp.instance.post("/api/talk/comment_list", data: {"id": id, "page": page, "limit": limit});
    return data.data;
  } catch (e) {
    return null;
  }
}

// 评论点赞/收藏
Future<Map?> favoriteToggle(int id, type) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/product/favorite_toggle", data: {"id": id, "type": type});
    return data.data;
  } catch (e) {
    return null;
  }
}

// 投诉页面内容
Future<Map?> preComplaint() async {
  try {
    Response data = await NetworkHttp.instance.post("/api/product/pre_complaint");
    return data.data;
  } catch (e) {
    return null;
  }
}

// 投诉
Future<Map?> productComplaint({int? product_id, String? types, String? content, String? img}) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/product/complaint",
        data: {'product_id': product_id, 'types': types, 'content': content, 'img': img});
    return data.data;
  } catch (e) {
    return null;
  }
}

// 评价
Future<Map?> productEvaluation({int? order_id, String? content}) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/product/comment", data: {
      'order_id': order_id,
      'content': content,
    });
    return data.data;
  } catch (e) {
    return null;
  }
}

// 发布
Future<Map?> publishMall(
    {int? goods_type_id,
    String? title,
    int? price,
    String? content,
    List? videos,
    List? image_cover,
    List? image_detail,
    List? tags,
    int? itemType}) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/product/post", data: {
      'goods_type_id': goods_type_id,
      'title': title,
      'price': price,
      'content': content,
      'videos': jsonEncode(videos),
      'image_cover': jsonEncode(image_cover),
      'image_detail': jsonEncode(image_detail),
      'tags': tags,
      'item_type': itemType
    });
    return data.data;
  } catch (e) {
    return null;
  }
}

// 购买商品
Future<Map?> productBuy(
    {int? product_id, int? qty, String? contact_info, String? shipping_address, String? remark}) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/product/buy", data: {
      'product_id': product_id,
      'qty': qty,
      'contact_info': contact_info,
      'shipping_address': shipping_address,
      'remark': remark,
    });
    return data.data;
  } catch (e) {
    return null;
  }
}

// 投诉
Future<Map?> productCategoryDetail(int id) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/product/goods_type_detail", data: {
      'id': id,
    });
    return data.data;
  } catch (e) {
    return null;
  }
}

// 修改订单状态
Future<Map?> updateOrderStatus(int id, int status, String shippingRemark, List shippingScreenshot) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/product/update_order_status", data: {
      'order_id': id,
      'status': status,
      'shipping_remark': shippingRemark,
      'shipping_screenshot': shippingScreenshot
    });
    return data.data;
  } catch (e) {
    return null;
  }
}

// 删除
Future<Map?> productDelete(int id) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/product/delete", data: {
      'id': id,
    });
    return data.data;
  } catch (e) {
    return null;
  }
}

// 一元春宵往期记录明细
Future<Map?> lotteryRecordTab() async {
  try {
    Response data = await NetworkHttp.instance.post("/api/lottery/tab_list");
    return data.data;
  } catch (e) {
    return null;
  }
}

// 发送系统消息
Future<Map?> sendImMsg(String uuid, {int type = 1}) async {
  try {
    Response data = await NetworkHttp.instance
        .post("/api/message/sendMessage", data: {'customer_service_uuid': uuid, 'message_type': type});
    return data.data;
  } catch (e) {
    return null;
  }
}

// 探花好片Tab
Future<Map?> tanhuaNavList() async {
  try {
    Response data = await NetworkHttp.instance.post("/api/mv/nav_list");
    return data.data;
  } catch (e) {
    return null;
  }
}

// 探花好片列表[在列表组件中请求带参数 这里就不写了]
Future<Map?> tanhuaMvList() async {
  try {
    Response data = await NetworkHttp.instance.post("/api/mv/getList");
    return data.data;
  } catch (e) {
    return null;
  }
}

//探花收藏
Future<Map?> tanhuaFavoriteToggle({related_id, type //1 视频 2评论
    }) async {
  try {
    Response data =
        await NetworkHttp.instance.post("/api/mv/favorite_toggle", data: {'related_id': related_id, 'type': type ?? 1});
    return data.data;
  } catch (e) {
    return null;
  }
}

//探花评论
Future<Map?> tanhuaMvComment({mv_id, content}) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/mv/comment", data: {'mv_id': mv_id, 'content': content});
    return data.data;
  } catch (e) {
    return null;
  }
}

//大厅评论回复
Future<Map?> replyComment({content, confirmId}) async {
  try {
    Response data =
        await NetworkHttp.instance.post("/api/info/replyConfirm", data: {'content': content, 'confirmId': confirmId});
    return data.data;
  } catch (e) {
    return null;
  }
}

//Vip资源评论回复
Future<Map?> replyVipComment({content, confirmId}) async {
  try {
    Response data = await NetworkHttp.instance
        .post("/api/info/replyVipInfoConfirm", data: {'content': content, 'confirmId': confirmId});
    return data.data;
  } catch (e) {
    return null;
  }
}

//茶老板联系方式
Future<Map?> setStoreContact({tel, wechat, qq}) async {
  try {
    Response data =
        await NetworkHttp.instance.post("/api/goods/setStoreContact", data: {'tel': tel, 'wechat': wechat, 'qq': qq});
    return data.data;
  } catch (e) {
    return null;
  }
}

//茶老板联系方式
Future<Map?> getStoreContact() async {
  try {
    Response data = await NetworkHttp.instance.post("/api/goods/getStoreContact");
    return data.data;
  } catch (e) {
    return null;
  }
}

//茶老板联系方式
Future<Map?> bossSendMessage(id) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/message/bossSendMessage", data: {'info_id': id});
    return data.data;
  } catch (e) {
    return null;
  }
}

//裸聊Tab
Future<Map?> getGirlchatTab() async {
  try {
    Response data = await NetworkHttp.instance.post(
      "/api/girlchat/pre_list",
    );
    return data.data;
  } catch (e) {
    return null;
  }
}

//裸聊详情
Future<Map?> getGirlchatDetail(id) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/girlchat/detail", data: {'id': id});
    return data.data;
  } catch (e) {
    return null;
  }
}

//裸聊收藏
Future<Map?> getGirlchatFavorite(id) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/girlchat/toggle_favorite", data: {'id': id});
    return data.data;
  } catch (e) {
    return null;
  }
}

//裸聊购买
Future<Map?> getGirlchatBuy({int? girl_chat_id, String? user_contact, int? time_set_id, List? addition_ids}) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/girlchat/buy", data: {
      'girl_chat_id': girl_chat_id,
      'user_contact': user_contact,
      'time_set_id': time_set_id,
      'addition_ids': addition_ids
    });
    return data.data;
  } catch (e) {
    return null;
  }
}

//裸聊确认交易
Future<Map?> girlchatConfirm(id) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/girlchat/confirm", data: {
      'id': id,
    });
    return data.data;
  } catch (e) {
    return null;
  }
}

//裸聊评价
Future<Map?> girlchatEvaluation({int? id, double? face, double? service, String? comment}) async {
  try {
    Response data = await NetworkHttp.instance
        .post("/api/girlchat/evaluation", data: {'id': id, 'face': face, 'service': service, 'comment': comment});
    return data.data;
  } catch (e) {
    return null;
  }
}

//裸聊举报
Future<Map?> getGirlchatComplaint() async {
  try {
    Response data = await NetworkHttp.instance.post("/api/girlchat/pre_complaint");
    return data.data;
  } catch (e) {
    return null;
  }
}

//裸聊举报
Future<Map?> girlchatComplaint({dynamic id, List? types, String? content, List? img}) async {
  try {
    Response data = await NetworkHttp.instance
        .post("/api/girlchat/complaint", data: {'id': id, 'types': types, 'content': content, 'img': img});
    return data.data;
  } catch (e) {
    return null;
  }
}

//裸聊发布信息
Future<Map?> girlchatPreRlease() async {
  try {
    Response data = await NetworkHttp.instance.post("/api/girlchat/pre_release");
    return data.data;
  } catch (e) {
    return null;
  }
}

//裸聊发布
Future<Map?> girlchatRlease({
  @required String? title,
  @required List? girlTagIds,
  @required num? girlAge,
  @required num? girlHeight,
  @required num? girlWeight,
  @required String? girlCup,
  @required num? pricePerMinute,
  @required String? phone,
  @required List? serviceItemIds,
  @required List? additionItemIds,
  @required List? photo,
  @required int? showFace,
}) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/girlchat/release", data: {
      'title': title,
      'girl_tag_ids': girlTagIds,
      'girl_age': girlAge,
      'girl_height': girlHeight,
      'girl_weight': girlWeight,
      'girl_cup': girlCup,
      'price_per_minute': pricePerMinute,
      'phone': phone,
      'service_item_ids': serviceItemIds,
      'addition_item_ids': additionItemIds,
      'photo': photo,
      'show_face': showFace
    });
    return data.data;
  } catch (e) {
    return null;
  }
}

// 会员升级-商品列表
Future<Map?> getProductUpgrade() async {
  try {
    Response data = await NetworkHttp.instance.post("/api/order/pre_upgrade");
    return data.data;
  } catch (e) {
    return null;
  }
}

// 会员升级-支付
Future<Map?> vipUpgradePay(dynamic product_id) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/order/upgrade", data: {'product_id': product_id});
    return data.data;
  } catch (e) {
    return null;
  }
}

//视频解锁
Future<Map?> mvUnlock(dynamic id) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/mv/unlock", data: {'id': id});
    return data.data;
  } catch (e) {
    return null;
  }
}

//原创申请页
Future<Map?> preApply() async {
  try {
    Response data = await NetworkHttp.instance.post("/api/mv/pre_apply");
    return data.data;
  } catch (e) {
    return null;
  }
}

//原创申请
Future<Map?> upApply() async {
  try {
    Response data = await NetworkHttp.instance.post("/api/mv/apply");
    return data.data;
  } catch (e) {
    return null;
  }
}

//视频发布数据请求
Future<Map?> videpPreRelease() async {
  try {
    Response data = await NetworkHttp.instance.post("/api/mv/pre_release");
    return data.data;
  } catch (e) {
    return null;
  }
}

//视频发布
Future<Map?> mvRelease(
    {List? categoryIds, List? tagIds, String? title, num? coins, String? cover, String? video}) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/mv/release", data: {
      "category_ids": categoryIds,
      "tag_ids": tagIds,
      "title": title,
      "coins": coins,
      "cover": cover,
      "video": video
    });
    return data.data;
  } catch (e) {
    return null;
  }
}

//上架下架视频
Future<Map?> hideShowMv(int id) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/mv/hide_show", data: {'mvId': id});
    return data.data;
  } catch (e) {
    return null;
  }
}

//身份过期检测
Future<Map?> verifyIdentityExpired() async {
  try {
    Response data = await NetworkHttp.instance.post("/api/user/verifyIdentityExpired");
    return data.data;
  } catch (e) {
    return null;
  }
}

// 包养筛选
Future<Map?> getAdoptPreList() async {
  try {
    Response data = await NetworkHttp.instance.post("/api/keep/pre_list");
    return data.data;
  } catch (e) {
    return null;
  }
}

// 包养列表
Future<Map?> getAdoptList(int page, int limit, String order, String girlPrice) async {
  try {
    Response data = await NetworkHttp.instance
        .post("/api/keep/list", data: {'page': page, 'limit': limit, 'order': order, 'girl_price': girlPrice});
    return data.data;
  } catch (e) {
    return null;
  }
}

// 包养详情
Future<Map?> getAdoptDetail(String id) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/keep/detail", data: {'id': id});
    return data.data;
  } catch (e) {
    return null;
  }
}

// 我的包养
Future<Map?> getAdoptMyList(int status, int page, int limit) async {
  try {
    Response data =
        await NetworkHttp.instance.post("/api/keep/my_list", data: {'status': status, 'page': page, 'limit': limit});
    return data.data;
  } catch (e) {
    return null;
  }
}

// 提交包养订单
Future<Map?> getAdoptOrder(dynamic id) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/keep/order", data: {'id': id});
    return data.data;
  } catch (e) {
    return null;
  }
}

// 包养订单
Future<Map?> getAdoptMyOrderList(int page, int limit) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/keep/my_order", data: {'page': page, 'limit': limit});
    return data.data;
  } catch (e) {
    return null;
  }
}

// 包养订单
Future<Map?> getAdoptOrderList(int page, int limit) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/keep/order_list", data: {'page': page, 'limit': limit});
    return data.data;
  } catch (e) {
    return null;
  }
}

// 包养收藏
Future<Map?> getAdoptMyFavorite(int page, int limit) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/keep/my_favorite", data: {'page': page, 'limit': limit});
    return data.data;
  } catch (e) {
    return null;
  }
}

// 包养收藏操作
Future onSubmitFavorite(dynamic id) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/keep/favorite_toggle", data: {'id': id});
    return data.data;
  } catch (e) {
    return null;
  }
}

// 茶谈收藏
Future talkFavorite(dynamic id) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/talk/favorite_toggle", data: {'id': id});
    return data.data;
  } catch (e) {
    return null;
  }
}

// 搜索包养
Future<Map?> searchAdopt(String keyword, int page, int limit) async {
  try {
    Response data =
        await NetworkHttp.instance.post("/api/keep/search", data: {'keyword': keyword, 'page': page, 'limit': limit});
    return data.data;
  } catch (e) {
    return null;
  }
}

// 包养发布筛选
Future<Map?> getAdoptReleaseFilter() async {
  try {
    Response data = await NetworkHttp.instance.post("/api/keep/pre_release");
    return data.data;
  } catch (e) {
    return null;
  }
}

// 包养发布
Future<Map?> releaseAdopt(
    String girl_name,
    String age,
    String height,
    String weight,
    String city_code,
    String self_assessment, // 验证自评
    String cup, // 罩杯
    String job, // 职业说明
    String education, // 学历介绍
    String aunt_time, // 姨妈时间
    int is_plastic_surgery, // 是否整容
    int virginity, //是否处女
    int can_stay_overnight, //可否过夜
    int can_live_together, // 可否同居
    int sex_allowed,
    int sm_allowed,
    int internal_ejaculation_allowed,
    String smoke_or_tattoo, // 是否吸烟或纹身
    String thunder_point, // 雷点（不能接受）
    String monthly_companion_day, // 月可陪伴天数
    String fastest_meet_time, // 最快见面时间
    String fly_to_other_province, // 可否飞往外省
    String can_go_abroad, // 可否出国
    String girl_price, // 到手价格
    String number_of_payment_times, // 费用支付次数
    String contact, // 联系方式
    String description, // 详细介绍
    String auth_num, // 随机验证数字
    String auth_video, // 视频认证
    String video, // 上传视频
    List images // 照片
    ) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/keep/release", data: {
      "girl_name": girl_name, // 妹子花名
      "age": age, // 年龄(岁)
      "height": height, // 身高(cm)
      "weight": weight, // 体重(kg)
      "city_code": city_code, // 所在城市
      "self_assessment": self_assessment, // 验证自评
      "cup": cup, // 罩杯
      "job": job, // 职业说明
      "education": education, // 学历介绍
      "aunt_time": aunt_time, // 姨妈时间
      "is_plastic_surgery": is_plastic_surgery, // 是否整容
      "virginity": virginity, //是否处女
      "can_stay_overnight": can_stay_overnight, //可否过夜
      "can_live_together": can_live_together, // 可否同居
      "sex_allowed": sex_allowed, // 可否口交
      "sm_allowed": sm_allowed, // 可否SM
      "internal_ejaculation_allowed": internal_ejaculation_allowed, // 可否内射
      "smoke_or_tattoo": smoke_or_tattoo, // 是否吸烟或纹身
      "thunder_point": thunder_point, // 雷点（不能接受）
      "monthly_companion_day": monthly_companion_day, // 月可陪伴天数
      "fastest_meet_time": fastest_meet_time, // 最快见面时间
      "fly_to_other_province": fly_to_other_province, // 可否飞往外省
      "can_go_abroad": can_go_abroad, // 可否出国
      "girl_price": girl_price, // 到手价格
      "number_of_payment_times": number_of_payment_times, // 费用支付次数
      "contact": contact, // 联系方式
      "description": description, // 详细介绍
      "auth_num": auth_num, // 随机验证数字
      "auth_video": auth_video, // 视频认证
      "video": video, // 上传视频
      "images": images // 照片
    });
    return data.data;
  } catch (e) {
    return null;
  }
}

// 雅间评论tag列表
Future<Basic?> getVipCommentTag() async {
  try {
    Response data = await NetworkHttp.instance.post("/api/home/getTag");
    return Basic.fromJson(data.data);
  } catch (e) {
    return null;
  }
}

// 包养投诉选项
Future<Basic?> getAdoptPreComplaint() async {
  try {
    Response data = await NetworkHttp.instance.post("/api/keep/pre_complaint");
    return Basic.fromJson(data.data);
  } catch (e) {
    return null;
  }
}

// 包养投诉
Future<Basic?> adoptComplaint({
  required String keep_id,
  required List option,
  required String content,
  required List medias,
}) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/keep/complaint",
        data: {"keep_id": keep_id, "option": option, "content": content, "medias": medias});
    return Basic.fromJson(data.data);
  } catch (e) {
    return null;
  }
}

// 曝光详情
Future<Basic?> blackDetail({
  required String black_id,
}) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/black/getDetail", data: {"black_id": black_id});
    return Basic.fromJson(data.data);
  } catch (e) {
    return null;
  }
}

// 曝光评论
Future<Basic?> blackCreateComment({
  required dynamic black_id,
  dynamic p_id,
  required String content,
  required List medias,
}) async {
  try {
    Map parmas = {"black_id": black_id, "content": content, "medias": medias};
    if (p_id != null) {
      parmas["p_id"] = p_id;
    }
    Response data = await NetworkHttp.instance.post("/api/black/createComment", data: parmas);
    return Basic.fromJson(data.data);
  } catch (e) {
    return null;
  }
}

// 曝光评论点赞
Future<Basic?> blackLikeToggle({required dynamic comment_id}) async {
  try {
    Response data = await NetworkHttp.instance.post("/api/black/likeToggle", data: {'comment_id': comment_id});
    return Basic.fromJson(data.data);
  } catch (e) {
    return null;
  }
}

Future<Basic?> favoriteCollectToggle(dynamic status) async {
  try {
    Response<dynamic> data = await NetworkHttp.instance.post("/api/home/favorite_tab_toggle", data: {"status": status});
    return Basic.fromJson(data.data);
  } catch (e) {
    return null;
  }
}

// 茶谈评论
Future<Basic?> talkComment(dynamic id, dynamic content, dynamic p_id) async {
  try {
    Response<dynamic> data =
        await NetworkHttp.instance.post("/api/talk/comment", data: {"id": id, "content": content, "p_id": p_id});
    return Basic.fromJson(data.data);
  } catch (e) {
    return null;
  }
}
