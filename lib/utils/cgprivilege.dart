import 'package:chaguaner2023/utils/app_global.dart';

class PrivilegeType {
  // ------------------------功能---------------------------
  static String infoStore = 'info_store'; //店家分享
  static String infoPersonal = 'info_personal'; //个人分享
  static String infoVip = 'info_vip'; //雅间
  static String infoVipGirl = 'info_vip_girl'; //茶女郎
  static String infoVipStore = 'info_vip_store'; //茶店铺
  static String infoVipVvip = 'info_vip_vvip'; //花魁閣樓
  static String infoRequire = 'require'; //要求
  static String infoMv = 'mv'; //视频
  static String infoMallProduct = 'mall_product'; //茶葉商城產品
  static String infoSystem = 'system'; //系统
  static String infoConfirm = 'confirm'; //验茶报告
  static String infoGirlChat = 'girl_chat'; //裸聊
  //------------------------权限----------------------------
  static String privilegeCreate = 'create'; //发表
  static String privilegeUpdate = 'update'; //修改
  static String privilegeView = 'view'; //观看
  static String privilegeUnlock = 'unlock'; //免费解锁
  static String privilegeDiscount = 'discount'; //折扣
  static String privilegeAppointment = 'appointment'; //預約
  static String privilegeSetInfo = 'set_info'; //设置个人信息
  static String privilegeIm = 'im'; //IM消息
  static String privilegeDedicated = 'dedicate'; //茶小歪
  static String privilegeComment = 'comment';
  //-------------------------对应文字------------------------------
  static String infoStoreString = '店家分享';
  static String infoPersonalString = '个人分享';
  static String infoVipString = '雅间';
  static String infoVipGirlString = '茶女郎';
  static String infoVipStoreString = '茶店铺';
  static String infoVipVvipString = '花魁阁楼';
  static String infoRequireString = '意向单';
  static String infoMvString = '视频';
  static String infoMallProductString = '茶馆商城';
  static String infoSysteString = '系统';

  static String privilegeCreateString = '发布';
  static String privilegeUpdateString = '修改';
  static String privilegeViewString = '观看';
  static String privilegeUnlockString = '免费解锁';
  static String privilegeDiscountString = '折扣';
  static String privilegeAppointmentString = '预约';
  static String privilegeSetInfoString = '设置个人信息';
  static String privilegeImString = '聊天功能';
  static String privilegeCommentString = '评论';
}

class CgPrivilege {
  //是否有权限
  static bool getPrivilegeStatus(String type, String privilege) {
    return AppGlobal.userPrivilege[type][privilege]['status'] == 1;
  }

  //获取权限次数
  static int getPrivilegeNumber(String type, String privilege) {
    return AppGlobal.userPrivilege[type][privilege]['value'];
  }

  //消耗权限
  static int setPrivilegeNumber(String type, String privilege) {
    return AppGlobal.userPrivilege[type][privilege]['value']--;
  }
}
