import 'dart:io';
import 'package:bot_toast/bot_toast.dart';
import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/page_title_bar.dart';
import 'package:chaguaner2023/components/updateModel.dart';
import 'package:chaguaner2023/input/InputDailog.dart';
import 'package:chaguaner2023/model/homedata.dart';
import 'package:chaguaner2023/store/global.dart';
import 'package:chaguaner2023/store/homeConfig.dart';
import 'package:chaguaner2023/store/sharedPreferences.dart';
import 'package:chaguaner2023/store/signInConfig.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:chaguaner2023/view/im/im.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

class MineSettingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MineSettingPageState();
}

class MineSettingPageState extends State<MineSettingPage> {
  BackButtonBehavior backButtonBehavior = BackButtonBehavior.none;
  int _selectedIndex = 0;
  dynamic _avatarType;
  int _isSetPassword = 0;
  String? _nickname;
  bool? privacyState;
  String version = '0.0.0';
  bool showUpdateStatus = false;
  String? _redemptioncode;
  dynamic _invitationcode;
  String _cacheSizeStr = '0';
  String bindphoneT = '绑定账号';
  String setPassw = '设置密码';
  String noset = '未设置';
  List _avatars = [
    {'name': '1'},
    {'name': '2'},
    {'name': '3'},
    {'name': '4'},
    {'name': '5'},
    {'name': '6'},
    {'name': '7'},
    {'name': '8'},
    {'name': '9'},
    {'name': '10'},
    {'name': '11'},
    {'name': '12'},
  ];
  @override
  void initState() {
    super.initState();
    PersistentState.getState('isPrivacy').then((val) {
      AppGlobal.isPrivacy.value = val == '1';
    });
  }

  getVersion() {
    // HomeConfig data = Provider.of<HomeConfig>(context, listen: false);
    return 'v' + AppGlobal.appinfo!['version'];
  }

  Widget _avatarBox(Function state, int index) {
    int indexss = index + 1;
    return GestureDetector(
      onTap: () {
        state(() {
          _selectedIndex = index;
        });
      },
      child: Stack(
        children: <Widget>[
          ClipOval(
            child: Container(
              width: 65.w,
              height: 65.w,
              color: Color(0xFFC8C8C8),
              child: LocalPNG(
                url: "assets/images/common/$indexss.png",
                fit: BoxFit.cover,
                width: 65.w,
                height: 65.w,
              ),
            ),
          ),
          Container(
            width: 65.w,
            height: 65.w,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
                border: _selectedIndex == index
                    ? Border.all(color: StyleTheme.cDangerColor, width: 3)
                    : Border.all(color: Colors.transparent, width: 3)),
          ),
        ],
      ),
    );
  }

  Future<void> onSetAvatar() async {
    var result = await upDateUserAvatar(_selectedIndex + 1);
    if (result!['status'] == 1) {
      Provider.of<HomeConfig>(context, listen: false).setAvatar(_selectedIndex + 1);
      BotToast.showText(text: "修改成功");
    }
  }

  Future<void> onSetNickname(context, String nickname) async {
    var result = await upDateUserNickname(nickname);
    if (result!['status'] == 1) {
      Provider.of<HomeConfig>(context, listen: false).setNickname(nickname);
      setState(() {
        _nickname = nickname;
      });
      BotToast.showText(text: "修改成功");
    } else {
      BotToast.showText(text: result['msg'].toString());
    }
  }

  Future<void> onSetInvitation(context, dynamic invitation) async {
    var result = await onInvitation(invitation);
    CommonUtils.debugPrint(result);
    if (result != null && result["status"] == 1) {
      Provider.of<HomeConfig>(context, listen: false).setInvitation(invitation);
      setState(() {
        _invitationcode = invitation;
      });
      BotToast.showText(text: "填写成功");
    } else {
      BotToast.showText(text: "${result['msg']}");
    }
  }

  void _clearCache() async {
    AppGlobal.imageCacheBox!.clear();
    BotToast.showCustomText(
        toastBuilder: (_) => Container(
              alignment: Alignment.center,
              margin: EdgeInsets.symmetric(horizontal: 29.w),
              height: 62.w,
              decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.42),
                  border: Border.all(color: Colors.white.withOpacity(0.12), width: 0.5.w),
                  borderRadius: const BorderRadius.all(Radius.circular(10))),
              child: Text(
                "缓存清除成功",
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500, color: Colors.white),
              ),
            ),
        align: Alignment(0.0, 0.0),
        duration: Duration(seconds: 3));
  }

  Future<void> checkVersion() async {
    try {
      final PackageInfo info = await PackageInfo.fromPlatform();
      var _versionLocal = Platform.isIOS ? '${info.version}.${info.buildNumber}' : info.version;
      VersionMsg versionMsg = Provider.of<HomeConfig>(context, listen: false).versionMsg;
      var targetVersion = versionMsg.version!.replaceAll('.', '');
      var currentVersion = _versionLocal.replaceAll('.', '');
      // 线上版本大于当前版本才更新
      var needUpdate = int.parse(targetVersion) > int.parse(currentVersion);
      if (needUpdate) {
        // 需要更新
        showUpdate();
      } else {
        BotToast.showText(text: '当前已经是最新版本');
      }
    } catch (e) {
      // print(e);
    }
  }

  // 更新提示
  void showUpdate() async {
    if (showUpdateStatus == true) return;
    VersionMsg versionMsg = Provider.of<HomeConfig>(context, listen: false).versionMsg;
    Config config = Provider.of<HomeConfig>(context, listen: false).config;
    UpdateModel.showUpdateDialog(backButtonBehavior, cancel: () {
      BotToast.showText(text: '取消更新');
      setState(() {
        showUpdateStatus = false;
      });
    }, confirm: () {
      if (Platform.isAndroid) {
        CommonUtils.launchURL(config.officeSite!);
        // UpdateModel.androidUpdate(backButtonBehavior,
        //     version: version, url: versionMsg.apk);
      } else {
        CommonUtils.launchURL(versionMsg.apk!);
      }
      Provider.of<SignInConfig>(context, listen: false).setShow(false);
    }, version: "茶馆儿v.${versionMsg.version}", mustupdate: versionMsg.must == 1, text: '${versionMsg.tips}');
    setState(() {
      showUpdateStatus = true;
    });
  }

  void showAvatarList() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context1, state) {
              return Container(
                color: Colors.transparent,
                child: Container(
                  padding: EdgeInsets.only(
                    top: 20.w,
                    bottom: MediaQuery.of(context).padding.bottom,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                  ),
                  child: Column(children: <Widget>[
                    Text(
                      '选择一个你喜欢的头像',
                      style: TextStyle(color: Color(0xFF323232), fontSize: 15.sp),
                    ),
                    SizedBox(
                      height: 15.w,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Wrap(
                          spacing: 25.w,
                          runSpacing: 25.w,
                          children: _avatars.asMap().entries.map((MapEntry map) => _avatarBox(state, map.key)).toList(),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15.w,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        onSetAvatar();
                      },
                      child: Container(
                        width: double.infinity,
                        height: 50.w,
                        // padding: EdgeInsets.only(bottom:GVScreenUtil.setWidth(20)),
                        margin: EdgeInsets.only(top: 10.w),
                        child: LocalPNG(
                            width: double.infinity,
                            height: 50.w,
                            url: "assets/images/mine/save-avatar.png",
                            alignment: Alignment.center,
                            fit: BoxFit.contain),
                      ),
                    ),
                    SizedBox(
                      height: 15.w,
                    ),
                  ]),
                ),
              );
            },
          );
        });
  }

  Future<void> redemptionCode(dynamic value) async {
    var result = await postExchange(value);
    if (result!['status'] == 1) {
      BotToast.showText(text: "兑换成功", align: Alignment(0, 0));
      setState(() {
        _redemptioncode = '已兑换';
      });
    } else {
      BotToast.showText(text: result['msg'].toString());
    }
  }

  _handleSafeLoginOut() async {
    Box box = AppGlobal.appBox!;
    box.delete('apiToken');
    AppGlobal.apiToken.value = '';
    _getNumInfo();
  }

  _getNumInfo() async {
    BotToast.showLoading();
    var _number = await getProfilePage();
    await getHomeConfig(context);
    WebSocketUtility().closeSocket();
    BotToast.closeAllLoading();
    try {
      Provider.of<GlobalState>(context, listen: false).setProfile(_number!['data']);
      context.pop();
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    var _phonenumbers;
    var _phonePrefix;
    var memberInfo = Provider.of<HomeConfig>(context).member;
    if (memberInfo != null) {
      _avatarType = memberInfo.thumb;
      _nickname = memberInfo.nickname;
      _isSetPassword = memberInfo.isSetPassword!;
      _phonePrefix = memberInfo.phonePrefix;
      if (['', null, false].contains(memberInfo.phone)) {
        _phonenumbers = null;
      } else {
        var mobilephone = memberInfo.phone.toString();
        String d4Sds = r'\d{4}';
        _phonenumbers = mobilephone.length > 4 ? mobilephone.replaceFirst(new RegExp(d4Sds), '****', 3) : null;
      }
      _invitationcode = memberInfo.invitedBy == 0 ? null : memberInfo.invitedBy;
    } else {
      _avatarType = 1;
      _isSetPassword = 0;
      _nickname = 'Guest';
      _phonenumbers = null;
      _phonePrefix = "+86";
    }
    return HeaderContainer(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
            child: PageTitleBar(
              title: '设置',
            ),
            preferredSize: Size(double.infinity, 44.w)),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          child: SingleChildScrollView(
            child: Column(
                // mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    onTap: () {
                      showAvatarList();
                    },
                    title: Text('头像', style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 16.sp)),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                      CircleAvatar(
                        child: ClipOval(
                          child: LocalPNG(
                            width: double.infinity,
                            height: double.infinity,
                            url: "assets/images/common/$_avatarType.png",
                          ),
                        ),
                      ),
                      Icon(Icons.keyboard_arrow_right, color: StyleTheme.cBioColor),
                    ]),
                  ),
                  ListTile(
                    onTap: () {
                      InputDialog.show(context, '昵称', limitingText: 14).then((value) {
                        if (value != '' && value != null) {
                          onSetNickname(context, value ?? '');
                        }
                      });
                    },
                    title: Text('昵称', style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 16.sp)),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                      Text(_nickname == null ? "输入昵称" : _nickname.toString(),
                          style: TextStyle(
                              fontSize: 14.sp, color: _nickname == null ? StyleTheme.cBioColor : Color(0xFF323232))),
                      Icon(Icons.keyboard_arrow_right,
                          color: _nickname == null ? StyleTheme.cBioColor : StyleTheme.cTitleColor),
                    ]),
                  ),
                  AppGlobal.apiToken.value != ""
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            ListTile(
                                onTap: () {
                                  if (_phonenumbers == null) {
                                    AppGlobal.appRouter?.push(CommonUtils.getRealHash('loginPage/2'));
                                  }
                                },
                                title: Text(_phonenumbers == null ? bindphoneT : '账号',
                                    style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 16.sp)),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Text(_phonenumbers == null ? '去注册' : _phonenumbers.toString(),
                                        style: TextStyle(
                                            fontSize: 14.sp,
                                            color:
                                                _phonenumbers == null ? StyleTheme.cBioColor : StyleTheme.cTitleColor)),
                                    Icon(Icons.keyboard_arrow_right, color: StyleTheme.cTitleColor),
                                  ],
                                )),
                            // ListTile(
                            //     onTap: () {
                            //       if (_isSetPassword == 0) {
                            //         AppGlobal.appRouter
                            //             .push('/changePassword/true');
                            //       } else {
                            //         AppGlobal.appRouter
                            //             .push('/changePassword/null');
                            //       }
                            //     },
                            //     title: Text(
                            //         _isSetPassword == 0 ? setPassw : '修改密码',
                            //         style: TextStyle(
                            //             color: StyleTheme.cTitleColor,
                            //             fontSize: 16.sp)),
                            //     trailing: Row(
                            //       mainAxisSize: MainAxisSize.min,
                            //       children: <Widget>[
                            //         Text(_isSetPassword == 0 ? noset : '已设置',
                            //             style: TextStyle(
                            //                 fontSize: 14.sp,
                            //                 color: _isSetPassword == 0
                            //                     ? StyleTheme.cBioColor
                            //                     : StyleTheme.cTitleColor)),
                            //         Icon(Icons.keyboard_arrow_right,
                            //             color: StyleTheme.cTitleColor),
                            //       ],
                            //     )),
                          ],
                        )
                      : SizedBox(),
                  ValueListenableBuilder(
                      valueListenable: AppGlobal.isPrivacy,
                      builder: (context, bool value, child) {
                        return SwitchListTile(
                          title: Text('隐私保护', style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 16.sp)),
                          value: value,
                          activeColor: Color(0xFFE32C33),
                          onChanged: (bool value) {
                            PersistentState.getState('initApp').then((initapp) {
                              //第一次使用App
                              if (initapp == null) {
                                context.push(CommonUtils.getRealHash('tealist'));
                              } else {
                                PersistentState.saveState('isPrivacy', value ? '1' : '0');
                                AppGlobal.isPrivacy.value = value;
                              }
                            });
                          },
                        );
                      }),
                  ListTile(
                    onTap: () {
                      InputDialog.show(context, '兑换码', limitingText: 40).then((value) {
                        if (value != '' && value != null) {
                          redemptionCode(value);
                        }
                      });
                    },
                    title: Text('填写兑换码', style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 16.sp)),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                      Text(_redemptioncode == null ? "输入兑换码" : _redemptioncode.toString(),
                          style: TextStyle(
                              fontSize: 14.sp,
                              color: _redemptioncode == null ? StyleTheme.cBioColor : Color(0xFF323232))),
                      Icon(Icons.keyboard_arrow_right, color: StyleTheme.cTitleColor)
                    ]),
                  ),
                  ListTile(
                    onTap: () {
                      InputDialog.show(context, '邀请码', limitingText: 6).then((value) {
                        if (value != '' && value != null) {
                          onSetInvitation(context, value);
                        }
                      });
                    },
                    enabled: _invitationcode == null || _invitationcode == 0,
                    title: Text('填写邀请码', style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 16.sp)),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                      Text(_invitationcode == null ? "输入邀请码" : _invitationcode.toString(),
                          style: TextStyle(
                              fontSize: 14.sp,
                              color: _invitationcode == null ? StyleTheme.cBioColor : Color(0xFF323232))),
                      Icon(Icons.keyboard_arrow_right, color: StyleTheme.cTitleColor)
                    ]),
                  ),
                  ListTile(
                    onTap: () {
                      if (memberInfo.email!.isEmpty) {
                        AppGlobal.appRouter?.push(CommonUtils.getRealHash('bindPhone'));
                      } else {
                        BotToast.showText(text: '已绑定邮箱', align: Alignment(0, 0));
                      }
                    },
                    title: Text('绑定邮箱', style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 16.sp)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(memberInfo.email!.isEmpty ? '去绑定' : memberInfo.email!,
                            style: TextStyle(color: StyleTheme.cBioColor, fontSize: 14.sp)),
                        Icon(Icons.keyboard_arrow_right, color: StyleTheme.cTitleColor)
                      ],
                    ),
                  ),
                  ListTile(
                    onTap: () {
                      _clearCache();
                    },
                    title: Text('清除缓存', style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 16.sp)),
                  ),
                  ListTile(
                    onTap: () {
                      checkVersion();
                    },
                    title: Text('版本号', style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 16.sp)),
                    trailing: Text(getVersion(), style: TextStyle(fontSize: 14.sp, color: Color(0xFF323232))),
                  ),
                  LoginOutButton(
                    onTap: () {
                      _handleSafeLoginOut();
                    },
                  )
                ]),
          ),
        ),
      ),
    );
  }
}

class LoginOutButton extends StatelessWidget {
  final Function? onTap;
  const LoginOutButton({Key? key, this.onTap}) : super(key: key);

  void loginOut(context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(
            "温馨提示",
            style: TextStyle(fontSize: 16.sp),
          ),
          content: new Text("确定要退出账号吗？"),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, elevation: 0),
              onPressed: () {
                context.pop();
              },
              child: Text(
                "取消",
                style: TextStyle(fontSize: 14.sp, color: StyleTheme.cDangerColor),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, elevation: 0),
              onPressed: () {
                Navigator.of(context).pop();
                onTap!.call();
              },
              child: Text(
                "退出账号",
                style: TextStyle(fontSize: 14.sp, color: StyleTheme.cDangerColor),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isLogin = false;
    if (['', null, false].contains(Provider.of<HomeConfig>(context).member.phone)) {
      isLogin = false;
    } else {
      isLogin = true;
    }
    return AppGlobal.apiToken.value != ""
        ? GestureDetector(
            onTap: (() {
              loginOut(context);
            }),
            child: Container(
                width: double.infinity,
                height: 50.w,
                margin: EdgeInsets.only(
                  top: 40.w,
                ),
                child: Stack(
                  children: [
                    LocalPNG(
                      width: double.infinity,
                      height: 50.w,
                      url: "assets/images/mymony/money-img.png",
                      alignment: Alignment.center,
                      fit: BoxFit.contain,
                    ),
                    Container(
                      width: double.infinity,
                      height: 50.w,
                      padding: EdgeInsets.only(left: 40.w, right: 40.w),
                      child: Center(
                        child: Text("安全退出", style: TextStyle(color: Colors.white, fontSize: 15.sp)),
                      ),
                    ),
                  ],
                )))
        : SizedBox();
  }
}
