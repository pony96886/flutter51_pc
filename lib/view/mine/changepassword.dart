import 'package:bot_toast/bot_toast.dart';
import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/pagetitlebar.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChangePassword extends StatefulWidget {
  final bool isSetting;
  ChangePassword({Key? key, this.isSetting = false}) : super(key: key);

  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  TextEditingController _basepassword = TextEditingController();
  TextEditingController _newpassword = TextEditingController();
  TextEditingController _repeatpassword = TextEditingController();
  String setPasStr = "设置密码";

  void showText(text) {
    BotToast.showText(text: '$text');
  }

  void handleSubmit() async {
    if (widget.isSetting == false) {
      if (_basepassword.text.isEmpty) {
        return showText("请输入原密码");
      }
      if (_basepassword.text.length < 6) {
        return showText("原密码长度不符合规则（6～20位）");
      }
    }
    if (_newpassword.text.isEmpty) {
      return showText("请输入新密码");
    }
    if (_newpassword.text.length < 6) {
      return showText("您输入的密码太短(6~20位)");
    }
    if (_repeatpassword.text.isEmpty) {
      return showText("请再次输入新密码");
    }
    if (_newpassword.text != _repeatpassword.text) {
      return showText("两次输入的密码不一致");
    }
    BotToast.showLoading();
    if (widget.isSetting) {
      var result = await setPassword(_newpassword.text, _repeatpassword.text);
      BotToast.closeAllLoading();
      if (result!['status'] == 1) {
        showText("设置成功");
        _getNumInfo();
      } else {
        showText("网络错误,请稍后重试");
      }
    } else {
      var result = await updatePassword(
          _basepassword.text, _newpassword.text, _repeatpassword.text);
      BotToast.closeAllLoading();
      if (result!['status'] == 1) {
        showText("更改成功");
        _getNumInfo();
      } else {
        showText(result['msg'] ?? "您已设置过密码，或网络错误");
      }
    }
  }

  _getNumInfo() async {
    await getHomeConfig(context);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return HeaderContainer(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            PageTitleBar(
              title: '',
            ),
            Expanded(
                child: Padding(
              padding: EdgeInsets.all(40.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(widget.isSetting ? setPasStr : "修改密码",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          color: StyleTheme.cTitleColor,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 30.w),
                  widget.isSetting
                      ? SizedBox()
                      : EditTextField(
                          editingController: _basepassword,
                          hintText: "输入原密码",
                        ),
                  SizedBox(height: widget.isSetting ? 0 : 20.w),
                  EditTextField(
                    editingController: _newpassword,
                    hintText: "请输入新密码",
                  ),
                  SizedBox(height: 20.w),
                  EditTextField(
                    editingController: _repeatpassword,
                    hintText: "请再次输入新密码",
                  ),
                  SizedBox(height: 80.w),
                  GestureDetector(
                      onTap: handleSubmit,
                      child: Container(
                          width: double.infinity,
                          height: 55.w,
                          margin: EdgeInsets.only(
                            top: 40.w,
                          ),
                          child: Stack(
                            children: [
                              LocalPNG(
                                width: double.infinity,
                                height: 55.w,
                                url: "assets/images/mymony/money-img.png",
                                alignment: Alignment.center,
                                fit: BoxFit.contain,
                              ),
                              Center(
                                child: Text(
                                    widget.isSetting ? setPasStr : "修改密码",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 15.sp)),
                              ),
                            ],
                          )))
                ],
              ),
            ))
          ],
        ),
      ),
    );
  }
}

class EditTextField extends StatelessWidget {
  final String? hintText;
  final TextEditingController? _editingController;

  const EditTextField({
    Key? key,
    @required TextEditingController? editingController,
    this.hintText,
  })  : _editingController = editingController,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 45.w,
      padding: EdgeInsets.only(left: 20.w, right: 20.w),
      decoration: BoxDecoration(
        color: Color(0xFFEEEEEE),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _editingController,
              autocorrect: false,
              obscureText: true,
              inputFormatters: <TextInputFormatter>[
                LengthLimitingTextInputFormatter(20),
              ],
              style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 15.sp),
              decoration: InputDecoration(
                  isDense: true,
                  contentPadding:
                      EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                  border: InputBorder.none,
                  hintStyle:
                      TextStyle(color: Color(0xFFB4B4B4), fontSize: 15.sp),
                  hintText: hintText,
                  hoverColor: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
