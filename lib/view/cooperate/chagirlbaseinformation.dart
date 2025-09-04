import 'dart:async';
import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:chaguaner2023/components/citypickers/CommonCity_pickers.dart';
import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/page_status.dart';
import 'package:chaguaner2023/components/pagetitlebar.dart';
import 'package:chaguaner2023/components/upload/start_upload.dart';
import 'package:chaguaner2023/components/upload/upload_resouce.dart';
import 'package:chaguaner2023/input/InputDailog.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChaGirlBaseInformation extends StatefulWidget {
  final Map? editInfoData;
  final List? editVideo;
  final List? editImage;
  final String? authvideo;
  final String? voicenumber;
  ChaGirlBaseInformation({
    Key? key,
    this.editInfoData,
    this.authvideo,
    this.voicenumber,
    this.editVideo,
    this.editImage,
  }) : super(key: key);

  @override
  _ChaGirlBaseInformationState createState() => _ChaGirlBaseInformationState();
}

class _ChaGirlBaseInformationState extends State<ChaGirlBaseInformation> {
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _addreensController = TextEditingController();
  String? _teagirlname;
  String? _reservationfee;
  String? _city;
  String? _cityCode;
  String? _girlage; //年龄
  String? _girlHeight; //身高
  String? _girlCup; //罩杯
  String? _pricerange; // 价格范围
  int activeContactType = 0;
  TextInputType contactInputType = TextInputType.number;
  String contactString = "电话";
  String? _phonenumber;
  List _contactType = [];
  bool isEditImg = false;
  bool isEditVideo = false;
  int? _girlCupValue;
  int fileSizeTotal = 0;
  int fileSizeCount = 0;
  double progress = 0.0;
  List tagItems = [];
  List<int> _serviceItems = [];
  bool isEdit = false; //是否是编辑状态
  String _regExpWeChat = r"^[a-zA-Z]([-_a-zA-Z0-9]{5,19})+$";
  String _regPhoneNumber = r"^1([38][0-9]|4[579]|5[0-3,5-9]|6[6]|7[0135678]|9[89])\d{8}$";
  @override
  void initState() {
    super.initState();
    getFileSise(widget.authvideo ?? '').then((value) {
      UploadFileList.allFile['authvideo'] =
          UploadData('video', [FileInfo(widget.authvideo, value, 0, 'authvideo', 'video', null, 0, 0)], value, []);
    });
    initContactType();
    getTags().then((tags) {
      if (tags!['data'] != null) {
        if (!mounted) return;
        setState(() {
          tagItems = tags['data'];
        });
      }
    });
    initWidgetState();
  }

  @override
  void dispose() {
    AppGlobal.girlParmas = {};
    super.dispose();
  }

  initWidgetState() {
    if (['', null, false].contains(widget.editInfoData)) {
      setState(() {
        isEdit = false;
      });
    } else {
      var base = widget.editInfoData;
      List<int> cartags = [];
      base!['tags'].forEach((item) {
        cartags.add(item['id']);
      });
      setState(() {
        isEdit = true;
        _teagirlname = base['title'];
        _reservationfee = base['fee'].toString();
        _city = base['cityName'];
        _cityCode = base['cityCode'].toString();
        _girlage = base['girl_age_num'].toString();
        _girlHeight = base['girl_height'].toString();
        _girlCup = base['girl_cup_str'];
        _girlCupValue = base['girl_cup'];
        _pricerange = base['price'];
        _serviceItems = cartags;
        _descriptionController.text = base['desc'];
        _addreensController.text = base['address'];
        _phonenumber = base['phone'];
      });
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
      if (widget.editInfoData != null && widget.editInfoData!['phone'].indexOf(_contactType[j]['title']) > -1) {
        activeContactType = j;
        contactString = _contactType[j]['title'];
        _phonenumber = widget.editInfoData!['phone'].replaceAll(_contactType[j]['title'], '');
      }
    }
    setState(() {});
  }

  inputBaseInfo() {
    return [
      {
        "type": "input",
        "title": "茶女郎花名",
        "isNumber": false,
        "hintText": "输入你的花名",
        "value": _teagirlname,
        'callBack': (val) {
          setState(() {
            _teagirlname = val;
          });
        }
      },
      {
        "type": "input",
        "title": "缴纳预约金（元宝）",
        "isNumber": true,
        "hintText": "预约金最低100，最高500",
        "value": _reservationfee,
        'callBack': (val) {
          setState(() {
            _reservationfee = val;
          });
        }
      },
      {
        "type": "select",
        "title": "选择城市",
        "hintText": "选择所在城市",
        "onTap": _showCityPickers,
        "value": _city,
        'callBack': (val) {
          setState(() {
            _city = val;
          });
        }
      },
      {
        'type': 'input',
        'title': '年龄(岁)',
        'isNumber': true,
        'hintText': '输入目前年龄',
        'value': _girlage,
        'callBack': (val) {
          setState(() {
            _girlage = val;
          });
        }
      },
      {
        'type': 'input',
        'title': '身高(cm)',
        'isNumber': true,
        'hintText': '输入妹子身高',
        'value': _girlHeight,
        'callBack': (val) {
          setState(() {
            _girlHeight = val;
          });
        }
      },
      {
        'type': 'select',
        'title': '罩杯',
        'onTap': _showSelectCup,
        'hintText': '选择妹子罩杯',
        'value': _girlCup,
        'callBack': (val) {
          setState(() {
            _girlCup = val;
          });
        }
      },
      {
        'type': 'input',
        'title': '消费情况',
        'isNumber': false,
        'hintText': '(例子：500～2000元)',
        'value': _pricerange,
        'callBack': (val) {
          setState(() {
            _pricerange = val;
          });
        }
      }
    ];
  }

  _showSelectCup() {
    showDialog(
        context: context,
        builder: (context) {
          return new SimpleDialog(
            shape: RoundedRectangleBorder(
                side: BorderSide(
                  style: BorderStyle.none,
                ),
                borderRadius: BorderRadius.circular(10)),
            contentPadding: EdgeInsets.symmetric(vertical: 15.w, horizontal: 15.w),
            children: <Widget>[for (var item in CommonUtils.getCupList()) cupItem(item['title'], item['id'])],
          );
        });
  }

  cupItem(String title, int id) {
    return Container(
      child: Column(
        children: <Widget>[
          SimpleDialogOption(
            child: Center(
              child: Text(title, style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 14.sp)),
            ),
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _girlCup = title;
                _girlCupValue = id;
              });
            },
          ),
          BottomLine(),
        ],
      ),
    );
  }

  _showCityPickers() async {
    dynamic resultCity =
        await Navigator.push(context, new MaterialPageRoute(builder: (context) => CommonCityPickers()));
    if (resultCity != null) {
      setState(() {
        _city = resultCity.city;
        _cityCode = resultCity.code.toString();
      });
    }
  }

  bool isNumeric(string) => int.tryParse(string) != null;

  void showText(text) {
    BotToast.showText(text: '$text', align: Alignment(0, 0));
  }

  getReqTags() {
    return tagItems.where((item) => _serviceItems.indexOf(item['id']) != -1).toList();
  }

  Future<int> getFileSise(String path) async {
    File file = new File(path);
    int fileLength = await file.length();
    return fileLength;
  }

  void sendData(Map value) async {
    List _oimage = UploadFileList.allFile['image']!.originalUrls.map((e) {
      return {'url': Uri.parse(e.path).path, "cover": "${e.width},${e.height}"};
    }).toList();
    List _image = (value['image'] ?? []).map((e) {
      return {'url': e['url'], "cover": e['w'].toString() + "," + e['h'].toString()};
    }).toList();
    PageStatus.showLoading();
    try {
      if (widget.editInfoData != null) {
        String? _video;
        if (UploadFileList.allFile['video']!.originalUrls.isNotEmpty) {
          Uri v = Uri.parse(UploadFileList.allFile['video']!.originalUrls[0].path);
          _video = v.path;
        } else {
          if (value['video'] != null) {
            _video = Uri.parse(value['video'][0]['url']).path;
          }
        }

        var pramas = {
          "info_id": widget.editInfoData!['id'],
          "title": _teagirlname,
          "cityCode": _cityCode,
          "girl_age_num": _girlage,
          "fee": _reservationfee,
          "girl_height": _girlHeight,
          "girl_cup": _girlCupValue,
          "cast_way": _pricerange,
          "price": _pricerange,
          "desc": _descriptionController.text,
          "address": _addreensController.text,
          "phone": contactString + _phonenumber!,
          "tags": getReqTags(),
          "image": [..._oimage, ..._image],
          "video": _video
        };
        var data = await editGirl(pramas).whenComplete(() {
          PageStatus.closeLoading();
        });
        if (data!['status'] == 1) {
          var resule = await getPerson();
          BotToast.closeAllLoading();
          if (resule!['status'] == 1) {
            AppGlobal.appRouter?.push(CommonUtils.getRealHash('chagirlReview'));
          } else {
            BotToast.showText(text: resule['msg']);
          }
        } else {
          BotToast.showText(text: data['msg']);
        }
      } else {
        String _video = value['video'] == null ? '' : value['video'][0]['url'];
        String _authvideo = value['authvideo'] == null ? '' : value['authvideo'][0]['url'];
        var pramas = {
          "title": _teagirlname,
          "cityCode": _cityCode,
          "girl_age_num": _girlage,
          "fee": _reservationfee,
          "girl_height": _girlHeight,
          "girl_cup": _girlCupValue,
          "cast_way": _pricerange,
          "price": _pricerange,
          "address": _addreensController.text,
          "phone": contactString + _phonenumber!,
          "desc": _descriptionController.text,
          "tags": getReqTags(),
          "image": [..._oimage, ..._image],
          "video": _video,
          "auth_video": _authvideo,
          "auth_num": widget.voicenumber
        };
        var data = await postGirl(pramas).whenComplete(() {
          PageStatus.closeLoading();
        });
        if (data!['status'] == 1) {
          AppGlobal.appRouter?.push(CommonUtils.getRealHash('chagirlReview'));
        } else {
          showText(data['msg']);
        }
      }
    } catch (e) {
      PageStatus.closeLoading();
      CommonUtils.showText('上传出现错误');
    }
  }

  void saveParam() {
    for (var item in inputBaseInfo()) {
      dynamic hintStr = item['hintText'];
      if (['', null, false].contains(item['value'])) {
        return showText("请$hintStr");
      } else {
        if (item['type'] == 'input') {
          if (item['isNumber']) {
            if (!isNumeric(item['value'])) {
              return showText("请正确$hintStr");
            }
          }
        }
      }
    }
    if (RegExp(r'(\d)').hasMatch(_reservationfee!) == false) {
      return showText("预约金只能输入数字");
    }
    if (int.parse(_reservationfee!) < 100 || int.parse(_reservationfee!) > 500) {
      return showText("预约金最低100，最高500");
    }
    if (RegExp(r'(\d)').hasMatch(_girlage!) == false) {
      return showText("年龄只能输入数字");
    }
    if (int.parse(_girlage!) < 18) {
      return showText("禁止未成年，请确认输入的年龄");
    }
    if (_serviceItems.length <= 0) {
      return showText("服务项目至少选择一项");
    }
    if (_addreensController.text.isEmpty) {
      showText("请输入详细地址");
      return;
    }
    if (_addreensController.text.length < 8) {
      showText("详细地址信息过少，请重新输入");
      return;
    }
    if (_phonenumber == null) {
      showText("请输入联系方式");
      return;
    }

    if (activeContactType == 0) {
      if (RegExp(_regPhoneNumber).hasMatch(_phonenumber!) == false) {
        showText("手机号输入不正确");
        return;
      }
    }
    if (activeContactType == 1) {
      if (RegExp(_regExpWeChat).hasMatch(_phonenumber!) == false) {
        showText("输入的微信号不符合微信规则，需包含数字、字母或下划线和减号");
        return;
      }
    }
    if (activeContactType == 2) {
      if (RegExp(r'(\d)').hasMatch(_phonenumber!) == false) {
        showText("QQ号只能输入数字");
        return;
      }
    }
    if (UploadFileList.allFile['image']!.originalUrls.length + UploadFileList.allFile['image']!.urls.length == 0) {
      return showText("至少上传一张照片");
    }
    StartUploadFile.upload().then((value) {
      if (value == null) {
        return CommonUtils.showText('资源上传错误,请重新上传');
      }
      sendData(value);
    });
  }

  Widget contactType() {
    List<Widget> tiles = [];
    Widget content;
    for (int i = 0; i < _contactType.length; i++) {
      tiles.add(
        GestureDetector(
          onTap: () {
            setState(() {
              activeContactType = i;
              contactString = _contactType[i]['title'];
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
                borderRadius: BorderRadius.circular(15.sp)),
            padding: EdgeInsets.symmetric(vertical: 2.w, horizontal: 11.5.w),
            child: Text(_contactType[i]['title'],
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
  Widget build(BuildContext context) {
    return HeaderContainer(
      child: Stack(
        children: <Widget>[
          Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.transparent,
            appBar: PreferredSize(
                child: PageTitleBar(
                  title: '茶女郎认证',
                ),
                preferredSize: Size(double.infinity, 44.w)),
            body: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
              },
              child: ListView(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(15.w),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          TitleTile(title: "基本信息"),
                          SizedBox(height: 10.w),
                          for (var item in inputBaseInfo()) inputItem(item),
                          SizedBox(height: 25.w),
                          Row(
                            children: <Widget>[
                              TitleTile(title: "服务项目"),
                              SizedBox(width: 12.w),
                              Text(
                                '*勾选的项目必须要有，最少一项',
                                style: TextStyle(color: StyleTheme.cDangerColor, fontSize: 11.sp),
                              ),
                            ],
                          ),
                          SizedBox(height: 15.sp),
                          Wrap(
                            spacing: 10.w,
                            runSpacing: 10.w,
                            children: <Widget>[for (var item in tagItems) tagItemWidget(item['name'], item['id'])],
                          ),
                          SizedBox(height: 25.w),
                          TitleTile(title: "详细描述（选填）"),
                          SizedBox(height: 15.w),
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
                                      hintText: "可以详细描述妹子的优势特征，或补充基础、消费信息"),
                                ),
                              )),
                          SizedBox(height: 15.w),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Expanded(
                                child: Text("联系信息",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        color: StyleTheme.cTitleColor, fontSize: 18.sp, fontWeight: FontWeight.w500)),
                              ),
                              Container(
                                decoration:
                                    BoxDecoration(color: Color(0xFFFDF0E4), borderRadius: BorderRadius.circular(15.w)),
                                child: contactType(),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 5.w,
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
                                    hintStyle: TextStyle(fontSize: 14.sp, color: StyleTheme.cBioColor),
                                    hintText: "输入详细地址"),
                              ),
                            ),
                          ),
                          BottomLine(),
                          ListTile(
                            onTap: () {
                              InputDialog.show(context, '联系$contactString',
                                      limitingText: 20, boardType: contactInputType)
                                  .then((value) {
                                _phonenumber = value;
                                setState(() {});
                              });
                            },
                            contentPadding: EdgeInsets.only(left: 0, right: 0),
                            title: Text('联系$contactString',
                                style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 14.sp)),
                            trailing: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                              Text(_phonenumber == null ? '输入联系$contactString' : _phonenumber.toString(),
                                  style: TextStyle(
                                      fontSize: 14.sp,
                                      color: _phonenumber == null ? StyleTheme.cBioColor : StyleTheme.cTitleColor)),
                            ]),
                          ),
                          SizedBox(height: 25.w),
                          Row(
                            children: <Widget>[
                              TitleTile(title: "照片"),
                              SizedBox(width: 5.w),
                              Text(
                                '(第一张将作为封面展示)',
                                style: TextStyle(color: StyleTheme.cBioColor, fontSize: 15.sp),
                              ),
                            ],
                          ),
                          SizedBox(height: 15.w),
                          UploadResouceWidget(
                            parmas: 'image',
                            uploadType: 'image',
                            maxLength: 10,
                            initResouceList: widget.editImage == null
                                ? null
                                : (widget.editImage ?? []).map<FileInfo>((e) {
                                    return FileInfo(e['url'], 0, 1, 'pic', 'image', null, 0, 0);
                                  }).toList(),
                          ),
                          SizedBox(height: 15.w),
                          Row(
                            children: <Widget>[
                              TitleTile(title: "视频"),
                              SizedBox(width: 5.w),
                              Text(
                                '(选填)',
                                style: TextStyle(color: StyleTheme.cBioColor, fontSize: 15.sp),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 5.w,
                          ),
                          UploadResouceWidget(
                            parmas: 'video',
                            uploadType: 'video',
                            maxLength: 1,
                            initResouceList: widget.editVideo == null
                                ? null
                                : widget.editVideo!.map<FileInfo>((e) {
                                    return FileInfo(e['url'], 0, 1, 'video', 'video', null, 0, 0);
                                  }).toList(),
                          ),
                          SizedBox(
                            height: 30.w,
                          ),
                          GestureDetector(
                              onTap: () {
                                saveParam();
                              },
                              child: SizedBox(
                                height: 40.w,
                                child: Stack(
                                  children: [
                                    Center(
                                      child: LocalPNG(
                                        height: 40.w,
                                        fit: BoxFit.fitHeight,
                                        url: "assets/images/mymony/money-img.png",
                                      ),
                                    ),
                                    Center(
                                      child: Text(
                                        "提交审核",
                                        style: TextStyle(color: Colors.white, fontSize: 15.w),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                          SizedBox(
                            height: 25.w,
                          ),
                        ]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget inputItem(Map item) {
    bool itemValueCheck = item['value'] == null;
    String valueStr = item['value'].toString();
    return Container(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
      ListTile(
        onTap: () {
          if (item['type'] == 'select') {
            item['onTap']();
          } else if (item['type'] == 'input') {
            InputDialog.show(context, item['title'],
                    limitingText: 16, boardType: item['isNumber'] ? TextInputType.number : TextInputType.text)
                .then((value) {
              item['callBack'](value);
            });
          } else {
            item['callBack']();
          }
        },
        contentPadding: EdgeInsets.only(left: 0, right: 0),
        title: Text(item['title'], style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 14.sp)),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
          Container(
            constraints: BoxConstraints(maxWidth: 175.w),
            child: Text(itemValueCheck ? item['hintText'] : valueStr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: itemValueCheck ? StyleTheme.cBioColor : StyleTheme.cTitleColor)),
          ),
          item['type'] == 'select'
              ? (itemValueCheck ? Icon(Icons.keyboard_arrow_right, color: StyleTheme.cBioColor) : Container())
              : Container()
        ]),
      ),
      BottomLine()
    ]));
  }

  Widget tagItemWidget(String title, int id) {
    return GestureDetector(
      onTap: () {
        if (_serviceItems.indexOf(id) > -1) {
          setState(() {
            _serviceItems.remove(id);
          });
        } else {
          setState(() {
            _serviceItems.add(id);
          });
        }
      },
      child: Container(
          padding: EdgeInsets.symmetric(horizontal: 11.w),
          height: 25.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: _serviceItems.indexOf(id) > -1 ? Color(0xFFFDF0E4) : StyleTheme.bottomappbarColor,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                title,
                style: TextStyle(
                    fontSize: 12.sp,
                    color: _serviceItems.indexOf(id) > -1 ? StyleTheme.cDangerColor : StyleTheme.cTitleColor),
              ),
            ],
          )),
    );
  }
}

class TitleTile extends StatelessWidget {
  final String? title;
  const TitleTile({
    Key? key,
    this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(title!,
        textAlign: TextAlign.left,
        style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 18.sp, fontWeight: FontWeight.bold));
  }
}

class CellListTile extends StatelessWidget {
  const CellListTile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {},
      contentPadding: EdgeInsets.only(left: 0, right: 0),
      title: Text('信息标题', style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 14.sp)),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
        Text('输入信息标题', style: TextStyle(fontSize: 14.sp, color: StyleTheme.cBioColor)),
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
