import 'package:bot_toast/bot_toast.dart';
import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/page_title_bar.dart';
import 'package:chaguaner2023/components/starrating.dart';
import 'package:chaguaner2023/components/upload/start_upload.dart';
import 'package:chaguaner2023/components/upload/upload_resouce.dart';
import 'package:chaguaner2023/input/InputDailog.dart';
import 'package:chaguaner2023/store/global.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FinishPublish extends StatefulWidget {
  final Map? editInfoData;
  final Map<String, String>? publishdata;
  final PageController? controller;
  FinishPublish({Key? key, this.publishdata, this.editInfoData, this.controller});

  @override
  State<StatefulWidget> createState() => FinishPublishState();
}

class FinishPublishState extends State<FinishPublish> {
  // 详细描述
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _addreensController = TextEditingController();
  String? _businesshours;
  String? _consumption;
  double _environmental = 0.0;
  String? _phonenumber;
  String contactInfo = ''; //备用联系方式
  String? _minPrice;
  bool isEditImg = false;
  int activeContactType = 0;
  TextInputType contactInputType = TextInputType.number;
  String contactString = "电话";
  int fileSizeTotal = 0;
  int fileSizeCount = 0;
  double progress = 0.0;
  bool isUpload = false;
  Map<String, bool> alreadyLogoImg = {}; //已打水印的图片
  Map<String, int> fileSizeList = {};
  List _contactType = [];
  List fileArr = [];
  String ppTips = '1p 500 2p800 包夜1600';
  String _regExpWeChat = r"^[a-zA-Z]([-_a-zA-Z0-9]{5,19})+$";
  String _regNumberss = "[^0-9]";
  String _regExpPrice =
      r"(http|ftp|https):\/\/[\w\-_]+(\.[\w\-_]+)+([\w\-\.,@?^=%&amp;:/~\+#]*[\w\-\@?^=%&amp;/~\+#])?";
  String? _selectedValue;
  final List<String> _dropdownItems = ['电话', '微信', 'QQ'];

  @override
  void initState() {
    super.initState();
    initContactType();

    if (widget.editInfoData != null) {
      _businesshours = widget.editInfoData?['business_hours'];
      _minPrice = widget.editInfoData?['price'].toString();
      _consumption = widget.editInfoData?['fee'];
      _environmental = widget.editInfoData?['env'].toDouble();
      _addreensController.text = widget.editInfoData?['address'] ?? '';
      _descriptionController.text = widget.editInfoData!['desc'];
      _phonenumber = AppGlobal.publishPostType == 1
          ? widget.editInfoData!['phone'].substring(2, widget.editInfoData!['phone'].length)
          : '';
      List _connect = (widget.editInfoData!['contact_info'] as String).split(':');
      if (_connect.length > 1) {
        _selectedValue = _connect[0];
        contactInfo = _connect[1];
      }
    }
  }

  initContactType() async {
    var contactList = await getContactType();
    if (contactList!['status'] != 0) {
      for (var i = 0; i < contactList['data'].length; i++) {
        _contactType.add({
          'value': i,
          'title': contactList['data'][i],
        });
      }
    }
    for (var j = 0; j < _contactType.length; j++) {
      dynamic titles = _contactType[j]['title'];
      if (widget.editInfoData?['phone'] != null && widget.editInfoData?['phone'].indexOf(titles) > -1) {
        activeContactType = j;
        contactString = titles;
      }
    }
    setState(() {});
  }

  void showText(text) {
    BotToast.showText(text: '$text', align: Alignment(0, 0));
  }

  Future onSendData(Map fileMap) async {
    dynamic qualityDy = widget.publishdata!['quality'];
    var qualityDouble = double.parse(qualityDy);
    int qualityValue = qualityDouble.toInt();
    List screenshot = []; //验证截图
    var serviceDouble = double.parse(qualityDy);
    int serviceValue = serviceDouble.toInt();
    //原图片列表（包括编辑过）
    List _image = (UploadFileList.allFile['pic']?.originalUrls ?? []).map((e) {
      return Uri.parse(e.path).path;
    }).toList();
    //新增的图片列表
    List _newImage = (fileMap['pic'] ?? []).map((e) {
      return e['url'];
    }).toList();
    List piclist = [..._image, ..._newImage];
    if (piclist.isEmpty) {
      CommonUtils.showText('请上传图片资源');
      return;
    }
    if (AppGlobal.publishPostType == 0) {
      List _Oimage = (UploadFileList.allFile['screenshot']?.originalUrls ?? []).map((e) {
        return Uri.parse(e.path).path;
      }).toList();
      List _nImage = (fileMap['screenshot'] ?? []).map((e) {
        return e['url'];
      }).toList();

      screenshot = _nImage.isEmpty ? _Oimage : _nImage;
    }
    if (widget.editInfoData == null) {
      var result = await publishInfo(
          widget.publishdata!['title']!,
          int.parse(widget.publishdata!['type']!),
          int.parse(widget.publishdata!['city']!),
          widget.publishdata!['girlnumber']!,
          widget.publishdata!['girlage']!,
          qualityValue,
          serviceValue,
          _environmental.round(),
          widget.publishdata!['serviceitems']!,
          _businesshours!,
          _consumption!,
          _descriptionController.text,
          _addreensController.text,
          contactString + _phonenumber!,
          piclist,
          widget.publishdata!['tranFlag']!,
          // widget.publishdata['resourceunlock'],
          _minPrice!,
          AppGlobal.publishPostType,
          contactInfo.isEmpty ? '' : '$_selectedValue:$contactInfo',
          screenshot);
      if (result == null) {
        return BotToast.showText(text: '网络错误,请稍后再试～');
      }
      if (result['status'] != 0) {
        //todo:更新profile信息
        getProfilePage().then((val) {
          if (val!['status'] != 0) {
            // Provider.read<GlobalState>().setProfile(val.data);
            Provider.of<GlobalState>(context, listen: false).setProfile(val['data']);
          }
        });
        AppGlobal.appRouter?.push(CommonUtils.getRealHash('waitingaudit/2'));
      } else {
        BotToast.showText(text: result['msg']);
      }
    } else {
      editInfo(
              widget.editInfoData!['id'],
              _consumption!,
              _descriptionController.text,
              _addreensController.text,
              contactString + _phonenumber!,
              piclist,
              widget.publishdata!['girlnumber']!,
              widget.publishdata!['girlage']!,
              qualityValue,
              serviceValue,
              _environmental.round(),
              widget.publishdata!['serviceitems']!,
              _businesshours!,
              widget.publishdata!['tranFlag'].toString(),
              _minPrice!,
              AppGlobal.publishPostType,
              contactInfo,
              screenshot)
          .then((res) {
        if (res!['status'] != 0) {
          AppGlobal.appRouter?.push(CommonUtils.getRealHash('waitingaudit/2'));
          showText('编辑成功');
        } else {
          BotToast.showText(text: res['msg']);
        }
      });
    }
  }

  void onSubmit() {
    if (_businesshours == null) {
      showText("请输入营业时间");
      return;
    }
    if (_minPrice == null) {
      showText("请输入最低价格");
      return;
    }

    try {
      if (int.parse(_minPrice!) < 50) {
        showText("最低价格不能小于50");
        return;
      }
    } catch (e) {
      showText("最低价格只能是数字且不大于1500");
      return;
    }
    if (_consumption == null) {
      showText("请输入消费情况");
      return;
    }
    if (_environmental == 0.0) {
      showText("请对环境设备进行评级");
      return;
    }
    if (_descriptionController.text.isEmpty) {
      showText("请填写详细描述");
      return;
    }
    if (_addreensController.text.isEmpty) {
      showText("请输入详细地址");
      return;
    }
    if (_addreensController.text.length < 8) {
      showText("详细地址信息过少，请重新输入");
      return;
    }
    if (AppGlobal.publishPostType == 1) {
      if (_phonenumber == null) {
        showText("请输入联系方式");
        return;
      }
      if (activeContactType == 0) {
        if (RegExp(_regNumberss).hasMatch(_phonenumber!)) {
          showText("手机号只能是数字");
          return;
        }
        if (_phonenumber!.length > 16) {
          showText("手机号长度大于16位数");
          return;
        }
      }
      if (activeContactType == 1) {
        if (RegExp(_regExpWeChat).hasMatch(_phonenumber!) == false) {
          showText("输入的微信号不符合微信规则，需包含字母、数字或下划线和减号");
          return;
        }
      }
      if (activeContactType == 2) {
        try {
          int.parse(_phonenumber!);
        } catch (e) {
          showText("QQ号只能输入数字");
          return;
        }
      }
    }

    if (((UploadFileList.allFile['pic']?.originalUrls ?? []).length +
            (UploadFileList.allFile['pic']?.urls ?? []).length) ==
        0) {
      CommonUtils.showText('请上传最新妹子照片');
      return;
    }
    if (AppGlobal.publishPostType == 0) {
      //店家发布
      if (((UploadFileList.allFile['screenshot']?.originalUrls ?? []).length +
              (UploadFileList.allFile['screenshot']?.urls ?? []).length) ==
          0) {
        CommonUtils.showText('请上传最验证截图');
        return;
      }
    }
    StartUploadFile.upload().then((value) {
      if (value == null) {
        return CommonUtils.showText('资源上传错误,请重新上传');
      }
      // LogUtilS.d('***************$value');
      onSendData(value);
    });
  }

  Future<bool> handleTipsUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String tokenState = prefs.getString("photo")!;
    if (['', null, false].contains(tokenState)) {
      return false;
    } else {
      return true;
    }
  }

  void loginOut(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(
            "温馨提示",
            style: TextStyle(fontSize: 16.sp),
          ),
          content: new Text(
              "iOS14的用户请注意，为了您更好的上传体验，请允许茶馆儿访问所有照片，如果您是通过“选择照片...”去选择，那么下次上传时就只能选择你勾选的那一部分照片了，卸载重装可以修复“无法选择所有图片”这个问题。"),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
          actions: <Widget>[
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "取消",
                style: TextStyle(fontSize: 14.sp),
              ),
            ),
            GestureDetector(
              onTap: () {
                prefs.setString("photo", "1");
                Navigator.of(context).pop();
              },
              child: Text(
                "知道了",
                style: TextStyle(color: StyleTheme.cDangerColor, fontSize: 14.sp),
              ),
            )
          ],
        );
      },
    );
  }

  Widget contactType() {
    List<Widget> tiles = [];
    Widget content;
    for (int i = 0; i < _contactType.length; i++) {
      dynamic titleValue = _contactType[i]['title'];
      tiles.add(
        GestureDetector(
          onTap: () {
            setState(() {
              activeContactType = i;
              contactString = titleValue;
              _phonenumber = null;
              if (i == 1) {
                contactInputType = TextInputType.text;
              } else {
                contactInputType = TextInputType.number;
              }
            });
          },
          child: Container(
            decoration: BoxDecoration(
                color: activeContactType == i ? StyleTheme.cDangerColor : Colors.transparent,
                borderRadius: BorderRadius.circular(15.w)),
            padding: EdgeInsets.symmetric(vertical: 2.w, horizontal: 11.5.w),
            child: Text(titleValue,
                style:
                    TextStyle(color: activeContactType == i ? Colors.white : StyleTheme.cTitleColor, fontSize: 12.sp)),
          ),
        ),
      );
    }
    content = new Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: tiles,
    );
    return content;
  }

  @override
  void dispose() {
    UploadFileList.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HeaderContainer(
      child: Stack(children: <Widget>[
        Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.transparent,
          appBar: PreferredSize(
              child: PageTitleBar(
                onback: () {
                  widget.controller!.jumpToPage(0);
                },
                title: '发布',
              ),
              preferredSize: Size(double.infinity, 44.w)),
          body: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: Container(
              width: double.infinity,
              height: double.infinity,
              child: ListView(children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 15.5.w, horizontal: 15.5.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text("场所信息",
                          textAlign: TextAlign.left,
                          style:
                              TextStyle(color: StyleTheme.cTitleColor, fontSize: 18.sp, fontWeight: FontWeight.w500)),
                      SizedBox(height: 10.w),
                      ListTile(
                        onTap: () {
                          InputDialog.show(context, '营业时间', limitingText: 16).then((value) {
                            setState(() {
                              _businesshours = value;
                            });
                          });
                        },
                        contentPadding: EdgeInsets.only(left: 0, right: 0),
                        title: Text('营业时间', style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 14.sp)),
                        trailing: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                          Text(_businesshours == null ? '早9点～晚5点' : _businesshours.toString(),
                              style: TextStyle(
                                  fontSize: 14.sp,
                                  color: _businesshours == null ? StyleTheme.cBioColor : StyleTheme.cTitleColor)),
                        ]),
                      ),
                      BottomLine(),
                      ListTile(
                        onTap: () {
                          InputDialog.show(context, '最低价格', limitingText: 16, boardType: TextInputType.number)
                              .then((value) {
                            setState(() {
                              _minPrice = value;
                            });
                          });
                        },
                        contentPadding: EdgeInsets.only(left: 0, right: 0),
                        title: Text('最低价格', style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 14.sp)),
                        trailing: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                          Text(_minPrice == null ? '输入价格（元)' : _minPrice.toString(),
                              style: TextStyle(
                                  fontSize: 14.sp,
                                  color: _minPrice == null ? StyleTheme.cBioColor : StyleTheme.cTitleColor)),
                        ]),
                      ),
                      BottomLine(),
                      ListTile(
                        onTap: () {
                          InputDialog.show(context, '消费情况', limitingText: 20).then((value) {
                            setState(() {
                              _consumption = value;
                            });
                          });
                        },
                        contentPadding: EdgeInsets.only(left: 0, right: 0),
                        title: Text('消费情况', style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 14.sp)),
                        trailing: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                          Text(_consumption == null ? ppTips : "$_consumption",
                              style: TextStyle(
                                  fontSize: 14.sp,
                                  color: _consumption == null ? StyleTheme.cBioColor : StyleTheme.cTitleColor)),
                        ]),
                      ),
                      BottomLine(),
                      ListTile(
                        contentPadding: EdgeInsets.only(left: 0, right: 0),
                        title: Text("环境设备", style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 14.sp)),
                        trailing: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                          StarRating(
                            rating: _environmental,
                            onRatingChanged: (value) {
                              setState(() {
                                _environmental = value;
                              });
                            },
                          ),
                        ]),
                      ),
                      BottomLine(),
                      ListTile(
                        contentPadding: EdgeInsets.only(left: 0, right: 0),
                        title: Text('详细描述', style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 14.sp)),
                      ),
                      Card(
                          margin: EdgeInsets.zero,
                          shadowColor: Colors.transparent,
                          color: Color(0xFFF5F5F5),
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: TextField(
                              controller: _descriptionController,
                              textInputAction: TextInputAction.done,
                              autofocus: false,
                              maxLines: 8,
                              style: TextStyle(fontSize: 14.sp, color: StyleTheme.cTitleColor),
                              decoration: InputDecoration.collapsed(
                                  hintStyle: TextStyle(fontSize: 14.sp, color: StyleTheme.cBioColor),
                                  hintText: "请阐述真实过程，字数不得少于30个字。字数越多，图片质量越好，管理员审核后所标价的铜钱越高。"),
                            ),
                          )),
                      widget.editInfoData != null || AppGlobal.publishPostType == 0
                          ? Container()
                          : SizedBox(
                              height: 30.w,
                            ),
                      widget.editInfoData != null || AppGlobal.publishPostType == 0
                          ? Container()
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Expanded(
                                  child: Text("联系信息",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          color: StyleTheme.cTitleColor, fontSize: 18.sp, fontWeight: FontWeight.w500)),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      color: Color(0xFFFDF0E4), borderRadius: BorderRadius.circular(15.w)),
                                  child: contactType(),
                                ),
                              ],
                            ),
                      ListTile(
                        contentPadding: EdgeInsets.only(left: 0, right: 0),
                        title: Text('详细地址', style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 14.sp)),
                        trailing: Container(
                          width: 200.w,
                          child: TextField(
                            controller: _addreensController,
                            textInputAction: TextInputAction.done,
                            autofocus: false,
                            textAlign: TextAlign.right,
                            maxLines: 1,
                            style: TextStyle(fontSize: 14.sp, color: StyleTheme.cTitleColor),
                            decoration: InputDecoration.collapsed(
                                hintStyle: TextStyle(fontSize: 14.sp, color: StyleTheme.cBioColor), hintText: "输入详细地址"),
                          ),
                        ),
                      ),
                      widget.editInfoData != null
                          ? Container()
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                BottomLine(),
                                ListTile(
                                  onTap: () {
                                    InputDialog.show(context, '联系$contactString',
                                            limitingText: 20, boardType: contactInputType)
                                        .then((value) {
                                      setState(() {
                                        _phonenumber = value;
                                      });
                                    });
                                  },
                                  contentPadding: EdgeInsets.only(left: 0, right: 0),
                                  title: Text('联系' + contactString,
                                      style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 14.sp)),
                                  trailing: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                                    Text(_phonenumber == null ? '输入联系' + contactString : _phonenumber.toString(),
                                        style: TextStyle(
                                            fontSize: 14.sp,
                                            color:
                                                _phonenumber == null ? StyleTheme.cBioColor : StyleTheme.cTitleColor)),
                                  ]),
                                ),
                                BottomLine(),
                                SizedBox(height: 5.w),
                                Text.rich(
                                    TextSpan(text: '备用联系方式', children: [
                                      TextSpan(
                                          text: '（备用、非必填）',
                                          style: TextStyle(color: StyleTheme.cDangerColor, fontSize: 12.sp))
                                    ]),
                                    style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 14.sp)),
                                SizedBox(height: 5.w),
                                GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: () {
                                    if ((_selectedValue ?? '').isEmpty) {
                                      return CommonUtils.showText('请选择备用联系方式');
                                    }
                                    InputDialog.show(context, '联系方式', limitingText: 20, boardType: TextInputType.text)
                                        .then((value) {
                                      setState(() {
                                        contactInfo = value!;
                                      });
                                    });
                                  },
                                  child: Row(
                                    children: [
                                      DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                        dropdownColor: Colors.black38,
                                        value: _selectedValue,
                                        hint: Text(
                                          '选择联系方式',
                                        ),
                                        // 当用户选择一个选项时的回调
                                        onChanged: (String? newValue) {
                                          _selectedValue = newValue;
                                          setState(() {});
                                        },
                                        alignment: Alignment.center,
                                        // 将选项列表转换为 DropdownMenuItem 列表
                                        items: _dropdownItems.map<DropdownMenuItem<String>>((String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  border:
                                                      Border(bottom: BorderSide(width: 1.w, color: Colors.white12))),
                                              alignment: Alignment.center,
                                              child: Text(
                                                value,
                                                style: TextStyle(color: Colors.white, fontSize: 14.sp),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                        selectedItemBuilder: (BuildContext context) {
                                          return _dropdownItems.map<Widget>((String value) {
                                            return Container(
                                              alignment: Alignment.center,
                                              child: Text(
                                                value,
                                                style: TextStyle(color: Colors.black, fontSize: 14.w),
                                              ),
                                            );
                                          }).toList();
                                        },
                                      )),
                                      Expanded(
                                          child: Container(
                                        alignment: Alignment.centerRight,
                                        child: Text(contactInfo.isEmpty ? '输入备用联系方式' : contactInfo.toString(),
                                            style: TextStyle(
                                                fontSize: 14.sp,
                                                color: contactInfo.isEmpty
                                                    ? StyleTheme.cBioColor
                                                    : StyleTheme.cTitleColor)),
                                      ))
                                    ],
                                  ),
                                ),
                              ],
                            ),
                      BottomLine(),
                      Container(
                        margin: EdgeInsets.only(top: 10.w),
                        child: Center(
                          child: Text(
                            '发帖大忌：\n禁止将联系方式和地址填写在联系信息之外的地方，并禁止填写QQ群，否则平台将直接封号删帖。',
                            style: TextStyle(color: StyleTheme.cDangerColor, fontSize: 12.sp),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 30.w,
                      ),
                      Text("照片",
                          textAlign: TextAlign.left,
                          style:
                              TextStyle(color: StyleTheme.cTitleColor, fontSize: 18.sp, fontWeight: FontWeight.w500)),
                      SizedBox(height: 5.w),
                      UploadResouceWidget(
                        parmas: 'pic',
                        uploadType: 'image',
                        maxLength: 10,
                        initResouceList: widget.editInfoData == null
                            ? null
                            : (widget.editInfoData!['photos'] ?? []).map<FileInfo>((e) {
                                return FileInfo(e['url'], 0, 1, 'pic', 'image', null, 0, 0);
                              }).toList(),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10.w),
                        child: Center(
                          child: Text(
                            '温馨提示：\n请上传门店外部，内部环境照片，技师照片，如涉及店名、门牌、个人信息请打码处理',
                            style: TextStyle(color: StyleTheme.cDangerColor, fontSize: 12.sp),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 30.w,
                      ),
                      AppGlobal.publishPostType == 0
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text("验证截图",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        color: StyleTheme.cTitleColor, fontSize: 18.sp, fontWeight: FontWeight.w500)),
                                SizedBox(height: 5.w),
                                UploadResouceWidget(
                                  parmas: 'screenshot',
                                  uploadType: 'image',
                                  maxLength: 1,
                                  initResouceList: widget.editInfoData == null
                                      ? null
                                      : (widget.editInfoData!['screenshot'] ?? []).map<FileInfo>((e) {
                                          return FileInfo(e['url'], 0, 1, 'screenshot', 'image', null, 0, 0);
                                        }).toList(),
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: 10.w),
                                  child: Center(
                                    child: Text(
                                      '*需上传街道门牌照片，门店外部、内部照片，技师照片，个人消费记录照片。\n*若上传除此以外（沟通截图）的图片一律不予通过，请勿浪费时间。\n*该验证截图不会被显示，审核专用。',
                                      style: TextStyle(color: StyleTheme.cDangerColor, fontSize: 12.sp),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : SizedBox(),
                      SizedBox(
                        height: 15.sp,
                      ),
                      GestureDetector(
                        onTap: () {
                          onSubmit();
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 15.5.w),
                          height: 50.w,
                          child: LocalPNG(
                            url: "assets/images/publish/publish.png",
                            height: 50.w,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 30.w,
                      )
                    ],
                  ),
                )
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}

class BottomLine extends StatelessWidget {
  const BottomLine({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFEEEEEE),
        border: Border(
          top: BorderSide.none,
          left: BorderSide.none,
          right: BorderSide.none,
          bottom: BorderSide(width: 0.5, color: Color(0xFFEEEEEE)),
        ),
      ),
    );
  }
}
