import 'dart:math';

import 'package:bot_toast/bot_toast.dart';
import 'package:chaguaner2023/components/citypickers/CommonCity_pickers.dart';
import 'package:chaguaner2023/components/page_status.dart';
import 'package:chaguaner2023/components/upload/start_upload.dart';
import 'package:chaguaner2023/components/upload/upload_resouce.dart';
import 'package:chaguaner2023/input/InputDailog.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/loading.dart';
import 'package:chaguaner2023/components/pagetitlebar.dart';

class AdoptReleasePage extends StatefulWidget {
  const AdoptReleasePage({Key? key}) : super(key: key);

  @override
  State<AdoptReleasePage> createState() => _AdoptReleasePageState();
}

class _AdoptReleasePageState extends State<AdoptReleasePage> {
  bool loading = true;
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _addreensController = TextEditingController();
  final List<String> _authNum =
      Random().nextInt(10000).toString().padLeft(4, '0').split('');
  List _contactType = [];
  int activeContactType = 0;
  String? _girlCupValue;
  TextInputType contactInputType = TextInputType.number;
  String contactString = "电话";
  String? _phonenumber;
  List _cupList = [
    {'title': 'A罩杯', 'value': "A"},
    {'title': 'B罩杯', 'value': "B"},
    {'title': 'C罩杯', 'value': "C"},
    {'title': 'D罩杯', 'value': "D"},
    {'title': 'E罩杯', 'value': "E"},
    {'title': 'F+', 'value': "F"},
  ];
  String _regExpWeChat = r"^[a-zA-Z]([-_a-zA-Z0-9]{5,19})+$";
  String _regNumberss = "[^0-9]";
  //第一部分 基本信息
  String? _girlName; //妹子花名
  String? _girlAge; //妹子年龄
  String? _girlHeight; //妹子身高
  String? _girlweight; //妹子体重
  String? _girlCup; //罩杯
  String? _city; //选择城市
  String? _cityCode;
  String? _assessment; //自评
  String? _girlJob; //妹子工作
  String? _girlEducation; //妹子学历
  String? _girlPeriod; //妹子月经
  bool isPlastic = false; // 整形
  bool isVirginity = false; // 处女
  bool _overnight = false; // 过夜
  bool _cohabitation = false; // 同居
  bool _sex_allowed = false; // 口交
  bool _sm_allowed = false; // SM
  bool _internal_ejaculation = false; // 内射
  String? _smoke_or_tattoo; // 吸烟和纹身
  String? _thunder_point; // 雷点
  String? _monthly_companion_day; // 包月天数
  String? _fastest_meet_time; // 见面时间
  String? _fly_to_other_province; // 可送外省
  String? _can_go_abroad; // 可出国
  String? _girl_price; // 包养价格
  String? _number_of_payment_times; // 分期

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
    loading = false;
    setState(() {});
  }

  basicInfo() {
    return [
      {
        'type': 'input',
        'title': '妹子花名',
        'onTop': null,
        'isNumber': false,
        'inputInfo': '输入妹子花名或者编号',
        'value': _girlName,
        'callBack': (val) {
          _girlName = val;
          setState(() {});
        }
      },
      {
        'type': 'input',
        'title': '年龄(岁)',
        'onTop': null,
        'isNumber': true,
        'inputInfo': '输入年龄，如:18',
        'value': _girlAge,
        'callBack': (val) {
          _girlAge = val;
          setState(() {});
        }
      },
      {
        'type': 'input',
        'title': '身高(cm)',
        'onTop': null,
        'isNumber': true,
        'inputInfo': '输入身高cm，如:168',
        'value': _girlHeight,
        'callBack': (val) {
          _girlHeight = val;
          setState(() {});
        }
      },
      {
        'type': 'input',
        'title': '体重(kg)',
        'onTop': null,
        'isNumber': true,
        'inputInfo': '输入体重kg，如:50',
        'value': _girlweight,
        'callBack': (val) {
          _girlweight = val;
          setState(() {});
        }
      },
      {
        'type': 'select', //是否需要选择
        'title': '罩杯',
        'isNumber': false,
        'onTop': showSelectCup,
        'inputInfo': '选择妹子罩杯',
        'value': _girlCup,
        'callBack': (val) {
          setState(() {
            _girlCup = val;
          });
        }
      },
      {
        'type': 'select', //是否需要选择
        'title': '选择城市',
        'isNumber': false,
        'onTop': _showCityPickers,
        'inputInfo': '选择所在城市',
        'value': _city,
        'callBack': (val) {
          _city = val;
          setState(() {});
        }
      },
      {
        'type': 'input',
        'title': '验证自评',
        'onTop': null,
        'isNumber': false,
        'inputInfo': '请评论自身颜值',
        'value': _assessment,
        'callBack': (val) {
          _assessment = val;
          setState(() {});
        }
      },
      {
        'type': 'input',
        'title': '职业说明',
        'onTop': null,
        'isNumber': false,
        'inputInfo': '请输入当前职业',
        'value': _girlJob,
        'callBack': (val) {
          _girlJob = val;
          setState(() {});
        }
      },
      {
        'type': 'input',
        'title': '学历介绍',
        'onTop': null,
        'isNumber': false,
        'inputInfo': '请输入最高学历',
        'value': _girlEducation,
        'callBack': (val) {
          _girlEducation = val;
          setState(() {});
        }
      },
      {
        'type': 'input',
        'title': '姨妈时间',
        'onTop': null,
        'isNumber': false,
        'inputInfo': '请输入每月姨妈大概时间',
        'value': _girlPeriod,
        'callBack': (val) {
          _girlPeriod = val;
          setState(() {});
        }
      },
      {
        'type': 'radio',
        'title': '是否整容',
        'onTop': null,
        'isNumber': false,
        'inputInfo': '是否整容',
        'value': isPlastic,
        'callBack': () {
          isPlastic = !isPlastic;
          setState(() {});
        }
      },
      {
        'type': 'radio',
        'title': '是否处女',
        'onTop': null,
        'isNumber': false,
        'inputInfo': '是否处女',
        'value': isVirginity,
        'callBack': () {
          isVirginity = !isVirginity;
          setState(() {});
        }
      },
      {
        'type': 'radio',
        'title': '可否过夜',
        'onTop': null,
        'isNumber': false,
        'inputInfo': '可否过夜',
        'value': _overnight,
        'callBack': () {
          _overnight = !_overnight;
          setState(() {});
        }
      },
      {
        'type': 'radio',
        'title': '可否同居',
        'onTop': null,
        'isNumber': false,
        'inputInfo': '可否同居',
        'value': _cohabitation,
        'callBack': () {
          _cohabitation = !_cohabitation;
          setState(() {});
        }
      },
      {
        'type': 'radio',
        'title': '可否口交',
        'onTop': null,
        'isNumber': false,
        'inputInfo': '可否口交',
        'value': _sex_allowed,
        'callBack': () {
          _sex_allowed = !_sex_allowed;
          setState(() {});
        }
      },
      {
        'type': 'radio',
        'title': '可否SM',
        'onTop': null,
        'isNumber': false,
        'inputInfo': '可否SM',
        'value': _sm_allowed,
        'callBack': () {
          _sm_allowed = !_sm_allowed;
          setState(() {});
        }
      },
      {
        'type': 'radio',
        'title': '可否内射',
        'onTop': null,
        'isNumber': false,
        'inputInfo': '可否内射',
        'value': _internal_ejaculation,
        'callBack': () {
          _internal_ejaculation = !_internal_ejaculation;
          setState(() {});
        }
      },
      {
        'type': 'input',
        'title': '是否吸烟或纹身',
        'onTop': null,
        'isNumber': false,
        'inputInfo': '请输入是否吸烟或者纹身',
        'value': _smoke_or_tattoo,
        'callBack': (val) {
          _smoke_or_tattoo = val;
          setState(() {});
        }
      },
      {
        'type': 'input',
        'title': '雷点（不能接受）',
        'onTop': null,
        'isNumber': false,
        'inputInfo': '不能接受什么',
        'value': _thunder_point,
        'callBack': (val) {
          _thunder_point = val;
          setState(() {});
        }
      },
      {
        'type': 'input',
        'title': '月可陪伴天数',
        'onTop': null,
        'isNumber': false,
        'inputInfo': '请输入1个月可陪伴天数',
        'value': _monthly_companion_day,
        'callBack': (val) {
          _monthly_companion_day = val;
          setState(() {});
        }
      },
      {
        'type': 'input',
        'title': '最快见面时间',
        'onTop': null,
        'isNumber': false,
        'inputInfo': '最快见面时间',
        'value': _fastest_meet_time,
        'callBack': (val) {
          _fastest_meet_time = val;
          setState(() {});
        }
      },
      {
        'type': 'input',
        'title': '可否飞往外省',
        'onTop': null,
        'isNumber': false,
        'inputInfo': '可否飞往外省',
        'value': _fly_to_other_province,
        'callBack': (val) {
          _fly_to_other_province = val;
          setState(() {});
        }
      },
      {
        'type': 'input',
        'title': '可否出国',
        'onTop': null,
        'isNumber': false,
        'inputInfo': '可否出国',
        'value': _can_go_abroad,
        'callBack': (val) {
          _can_go_abroad = val;
          setState(() {});
        }
      },
      {
        'type': 'input',
        'title': '到手价格',
        'onTop': null,
        'isNumber': true,
        'inputInfo': '到手价格',
        'value': _girl_price,
        'callBack': (val) {
          _girl_price = val;
          setState(() {});
        }
      },
      {
        'type': 'input',
        'title': '费用支付次数',
        'onTop': null,
        'isNumber': true,
        'inputInfo': '费用支付次数',
        'value': _number_of_payment_times,
        'callBack': (val) {
          _number_of_payment_times = val;
          setState(() {});
        }
      },
    ];
  }

  void showText(text) {
    BotToast.showText(text: '$text', align: Alignment(0, 0));
  }

  void onSubmit() {
    if (_girlName == null) {
      showText("请输入妹子花名或者编号");
      return;
    }
    if (_girlAge == null) {
      showText("请输入年龄，如:18");
      return;
    }
    try {
      int.parse(_girlAge!);
    } catch (e) {
      showText("年龄必须是数字");
      return;
    }
    if (_girlHeight == null) {
      showText("请输入身高cm，如:168");
      return;
    }
    try {
      int.parse(_girlHeight!);
    } catch (e) {
      showText("身高必须是数字");
      return;
    }
    if (_girlweight == null) {
      showText("请输入体重kg，如:50");
      return;
    }
    try {
      int.parse(_girlweight!);
    } catch (e) {
      showText("体重必须是数字");
      return;
    }
    if (_girlCup == null) {
      showText("请选择妹子罩杯");
      return;
    }
    if (_city == null) {
      showText("请选择所在城市");
      return;
    }
    if (_assessment == null) {
      showText("请评论自身颜值");
      return;
    }
    if (_girlJob == null) {
      showText("请输入当前职业");
      return;
    }
    if (_girlEducation == null) {
      showText("请输入最高学历");
      return;
    }
    if (_girlPeriod == null) {
      showText("请输入每月姨妈大概时间");
      return;
    }
    if (_smoke_or_tattoo == null) {
      showText("请输入是否吸烟或者纹身");
      return;
    }
    if (_thunder_point == null) {
      showText("请输入不能接受什么");
      return;
    }
    if (_monthly_companion_day == null) {
      showText("请输入1月可陪伴天数");
      return;
    }
    if (_fastest_meet_time == null) {
      showText("请输入最快见面时间");
      return;
    }
    if (_fly_to_other_province == null) {
      showText("请输入可否飞往外省");
      return;
    }
    if (_can_go_abroad == null) {
      showText("请输入可否出国");
      return;
    }
    if (_girl_price == null) {
      showText("请输入到手价格");
      return;
    }
    try {
      int.parse(_girl_price!);
    } catch (e) {
      showText("到手价格必须是数字");
      return;
    }
    if (_number_of_payment_times == null) {
      showText("请输入费用支付次数");
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
    if (_descriptionController.text.isEmpty) {
      showText("请填写详细介绍");
      return;
    }
    if (((UploadFileList.allFile['adoptimage']?.originalUrls ?? []).length +
            (UploadFileList.allFile['adoptimage']?.urls ?? []).length) ==
        0) {
      CommonUtils.showText('请上传照片');
      return;
    }
    if ((UploadFileList.allFile['adoptauthVideo']?.urls ?? []).length == 0) {
      CommonUtils.showText('请上传认证视频');
      return;
    }
    StartUploadFile.upload().then((value) {
      if (value == null) {
        return CommonUtils.showText('资源上传错误,请重新上传');
      } else {
        PageStatus.showLoading();
      }
      onSendData(value);
    });
  }

  Future onSendData(Map fileData) async {
    //原图片列表（包括编辑过）
    List _image =
        (UploadFileList.allFile['adoptimage']?.originalUrls ?? []).map((e) {
      return {
        'media_url': Uri.parse(e.path).path,
        'img_width': "${e.width}",
        'img_height': "${e.height}"
      };
    }).toList();
    //新增的图片列表
    List _newImage = (fileData['adoptimage'] ?? []).map((e) {
      return {
        'media_url': e['url'],
        'img_width': e['w'].toString(),
        'img_height': e['h'].toString()
      };
    }).toList();
    //原视频列表（包括编辑过）
    List _video =
        (UploadFileList.allFile['adoptvideo']?.originalUrls ?? []).map((e) {
      return Uri.parse(e.path).path;
    }).toList();
    //新增的视频列表
    List _newVideo = (fileData['adoptvideo'] ?? []).map((e) {
      return e['url'];
    }).toList();
    //认证视频
    List authVideo = (fileData['adoptauthVideo'] ?? []).map((e) {
      return e['url'];
    }).toList();
    List video = [..._video, ..._newVideo];
    List image = [..._image, ..._newImage];
    PageStatus.showLoading();
    try {
      var result = await releaseAdopt(
              _girlName!,
              _girlAge!,
              _girlHeight!,
              _girlweight!,
              _cityCode!,
              _assessment!,
              _girlCupValue!,
              _girlJob!,
              _girlEducation!,
              _girlPeriod!,
              isPlastic ? 1 : 0,
              isVirginity ? 1 : 0,
              _overnight ? 1 : 0,
              _cohabitation ? 1 : 0,
              _sex_allowed ? 1 : 0,
              _sm_allowed ? 1 : 0,
              _internal_ejaculation ? 1 : 0,
              _smoke_or_tattoo!,
              _thunder_point!,
              _monthly_companion_day!,
              _fastest_meet_time!,
              _fly_to_other_province!,
              _can_go_abroad!,
              _girl_price!,
              _number_of_payment_times!,
              contactString + _phonenumber!,
              _descriptionController.text,
              _authNum.join(''),
              authVideo.isEmpty ? null : authVideo[0],
              video.isEmpty ? null : video[0],
              image)
          .whenComplete(() {
        PageStatus.closeLoading();
      });
      if (result!['status'] != 0) {
        Navigator.of(context).pop();
        CommonUtils.showText(result['msg']);
      } else {
        CommonUtils.showText(result['msg']);
      }
    } catch (e) {
      PageStatus.closeLoading();
    }
  }

  _showCityPickers() async {
    dynamic resultCity = await Navigator.push(context,
        new MaterialPageRoute(builder: (context) => CommonCityPickers()));
    if (resultCity != null) {
      setState(() {
        _city = resultCity.city;
        _cityCode = resultCity.code.toString();
      });
    }
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
                color: activeContactType == i
                    ? StyleTheme.cDangerColor
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(15.w)),
            padding: EdgeInsets.symmetric(vertical: 2.w, horizontal: 11.5.w),
            child: Text(titleValue,
                style: TextStyle(
                    color: activeContactType == i
                        ? Colors.white
                        : StyleTheme.cTitleColor,
                    fontSize: 12.sp)),
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

  cupItem(String title, String value) {
    return Container(
      child: Column(
        children: <Widget>[
          SimpleDialogOption(
            child: Center(
              child: Text(title,
                  style: TextStyle(
                      color: StyleTheme.cTitleColor, fontSize: 14.sp)),
            ),
            onPressed: () {
              Navigator.pop(context);
              _girlCup = title;
              _girlCupValue = value;
              setState(() {});
            },
          ),
          BottomLine(),
        ],
      ),
    );
  }

  showSelectCup() {
    showDialog(
        context: context,
        builder: (context) {
          return new SimpleDialog(
            shape: RoundedRectangleBorder(
                side: BorderSide(
                  style: BorderStyle.none,
                ),
                borderRadius: BorderRadius.circular(10)),
            contentPadding:
                EdgeInsets.symmetric(vertical: 15.w, horizontal: 15.w),
            children: <Widget>[
              for (var item in _cupList) cupItem(item['title'], item['value'])
            ],
          );
        });
  }

  Widget inputItem(Map item) {
    dynamic values = item['value'];
    String selectStr = 'select';
    String noseleasidh = 'unselect';
    String selectUrl = item['type'] == 'radio'
        ? (values ? selectStr : noseleasidh)
        : noseleasidh;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ListTile(
          onTap: () {
            if (item['type'] == 'select') {
              item['onTop']();
            } else if (item['type'] == 'input') {
              InputDialog.show(context, item['title'],
                      limitingText: 16,
                      boardType: item['isNumber']
                          ? TextInputType.number
                          : TextInputType.text)
                  .then((value) {
                item['callBack'](value);
              });
            } else {
              item['callBack']();
            }
          },
          contentPadding: EdgeInsets.only(left: 0, right: 0),
          title: Text(item['title'],
              style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 14.sp)),
          trailing: item['type'] == 'radio'
              ? GestureDetector(
                  onTap: item['callBack'],
                  behavior: HitTestBehavior.translucent,
                  child: Container(
                    width: 15.w,
                    height: 15.w,
                    margin: EdgeInsets.only(right: 5.5.sp),
                    child: LocalPNG(
                      width: 15.w,
                      height: 15.w,
                      url: 'assets/images/card/$selectUrl.png',
                    ),
                  ),
                )
              : Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                  Container(
                    constraints: BoxConstraints(maxWidth: 175.w),
                    child: Text(
                        item['value'] == null
                            ? item['inputInfo']
                            : values.toString(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w500,
                            color: item['value'] == null
                                ? StyleTheme.cBioColor
                                : StyleTheme.cTitleColor)),
                  ),
                  item['type'] == 'select'
                      ? (item['value'] == null
                          ? Icon(Icons.keyboard_arrow_right,
                              color: StyleTheme.cBioColor)
                          : Container())
                      : Container()
                ]),
        ),
        item['prompt'] == null
            ? Container()
            : (item['prompt'] is List
                ? Container(
                    margin: EdgeInsets.only(bottom: 20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var item in item['prompt'])
                          Text(
                            item,
                            style: TextStyle(
                                color: StyleTheme.cBioColor, fontSize: 12.sp),
                          )
                      ],
                    ),
                  )
                : Container(
                    margin: EdgeInsets.only(bottom: 20.w),
                    child: Text(
                      item['prompt'],
                      style: TextStyle(
                          color: StyleTheme.cBioColor, fontSize: 12.sp),
                    ),
                  )),
        BottomLine(),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    initContactType();
  }

  Future<bool> _onWillPop() async {
    bool shouldPop = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('确认退出'),
            content: Text('是否确认放弃当前所填内容？'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('确认'),
              ),
            ],
          ),
        ) ??
        false;
    return shouldPop;
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
        onWillPop: _onWillPop,
        child: HeaderContainer(
            child: Scaffold(
                backgroundColor: Colors.transparent,
                appBar: PreferredSize(
                    child: PageTitleBar(title: '发布包养'),
                    preferredSize: Size(double.infinity, 44.w)),
                body: loading
                    ? Loading()
                    : SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.all(15.w),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("基本信息",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        color: StyleTheme.cTitleColor,
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.bold)),
                                for (var item in basicInfo()) inputItem(item),
                                SizedBox(
                                  height: 15.w,
                                ),
                                Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Expanded(
                                        child: Text("联系信息",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                color: StyleTheme.cTitleColor,
                                                fontSize: 18.sp,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                            color: Color(0xFFFDF0E4),
                                            borderRadius:
                                                BorderRadius.circular(15.w)),
                                        child: contactType(),
                                      ),
                                    ]),
                                SizedBox(
                                  height: 15.w,
                                ),
                                ListTile(
                                  contentPadding:
                                      EdgeInsets.only(left: 0, right: 0),
                                  title: Text('详细地址',
                                      style: TextStyle(
                                          color: StyleTheme.cTitleColor,
                                          fontSize: 14.sp)),
                                  trailing: Container(
                                    width: 200.w,
                                    child: TextField(
                                      controller: _addreensController,
                                      textInputAction: TextInputAction.done,
                                      autofocus: false,
                                      textAlign: TextAlign.right,
                                      maxLines: 1,
                                      style: TextStyle(
                                          fontSize: 14.sp,
                                          color: StyleTheme.cTitleColor),
                                      decoration: InputDecoration.collapsed(
                                          hintStyle: TextStyle(
                                              fontSize: 14.sp,
                                              color: StyleTheme.cBioColor),
                                          hintText: "输入详细地址"),
                                    ),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    BottomLine(),
                                    ListTile(
                                      onTap: () {
                                        InputDialog.show(
                                                context, '联系$contactString',
                                                limitingText: 20,
                                                boardType: contactInputType)
                                            .then((value) {
                                          setState(() {
                                            _phonenumber = value;
                                          });
                                        });
                                      },
                                      contentPadding:
                                          EdgeInsets.only(left: 0, right: 0),
                                      title: Text('联系' + contactString,
                                          style: TextStyle(
                                              color: StyleTheme.cTitleColor,
                                              fontSize: 14.sp)),
                                      trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Text(
                                                _phonenumber == null
                                                    ? '输入联系' + contactString
                                                    : _phonenumber.toString(),
                                                style: TextStyle(
                                                    fontSize: 14.sp,
                                                    color: _phonenumber == null
                                                        ? StyleTheme.cBioColor
                                                        : StyleTheme
                                                            .cTitleColor)),
                                          ]),
                                    ),
                                    BottomLine(),
                                    SizedBox(height: 5.w),
                                  ],
                                ),
                                ListTile(
                                  contentPadding:
                                      EdgeInsets.only(left: 0, right: 0),
                                  title: Text('详细介绍',
                                      style: TextStyle(
                                          color: StyleTheme.cTitleColor,
                                          fontSize: 14.sp)),
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
                                        style: TextStyle(
                                            fontSize: 14.sp,
                                            color: StyleTheme.cTitleColor),
                                        decoration: InputDecoration.collapsed(
                                            hintStyle: TextStyle(
                                                fontSize: 14.sp,
                                                color: StyleTheme.cBioColor),
                                            hintText: "请阐述包养的详细介绍，字数不得少于30个字。"),
                                      ),
                                    )),
                                SizedBox(
                                  height: 15.w,
                                ),
                                Text("照片",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        color: StyleTheme.cTitleColor,
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.bold)),
                                SizedBox(height: 5.w),
                                UploadResouceWidget(
                                  parmas: 'adoptimage',
                                  maxLength: 10,
                                  initResouceList: [],
                                ),
                                SizedBox(
                                  height: 15.w,
                                ),
                                Text("上传视频",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        color: StyleTheme.cTitleColor,
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.bold)),
                                SizedBox(
                                  height: 5.w,
                                ),
                                UploadResouceWidget(
                                  parmas: 'adoptvideo',
                                  uploadType: 'video',
                                  maxLength: 1,
                                  initResouceList: [],
                                ),
                                Padding(
                                    padding: EdgeInsets.only(
                                        bottom: 10.w, top: 30.w),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        RichText(
                                            text: TextSpan(
                                                text: "认证视频 ",
                                                style: TextStyle(
                                                    color:
                                                        StyleTheme.cTitleColor,
                                                    fontSize: 18.sp,
                                                    fontWeight:
                                                        FontWeight.bold),
                                                children: <TextSpan>[
                                              TextSpan(
                                                  text: ' (必填)',
                                                  style: TextStyle(
                                                      color: Color(0xFFB4B4B4),
                                                      fontSize: 14.sp))
                                            ])),
                                        SizedBox(
                                          height: 15.w,
                                        ),
                                        Row(
                                          children: [
                                            Text('随机验证数字 :',
                                                style: TextStyle(
                                                    color: Color(0xff1e1e1e),
                                                    fontSize: 15.sp,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Container(
                                                height: 42.w,
                                                margin:
                                                    EdgeInsets.only(left: 15.w),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5.w),
                                                    color: Color(0xfff5f5f5)),
                                                alignment: Alignment.center,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: _authNum
                                                      .asMap()
                                                      .keys
                                                      .map((e) {
                                                    return Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 5.w),
                                                      child: Text(_authNum[e],
                                                          style: TextStyle(
                                                              color: Color(
                                                                  0xff1e1e1e),
                                                              fontSize: 15.sp)),
                                                    );
                                                  }).toList(),
                                                ))
                                          ],
                                        )
                                      ],
                                    )),
                                UploadResouceWidget(
                                  parmas: 'adoptauthVideo',
                                  uploadType: 'video',
                                  maxLength: 1,
                                ),
                                SizedBox(
                                  height: 30.w,
                                ),
                                Center(
                                  child: GestureDetector(
                                    onTap: () {
                                      onSubmit();
                                    },
                                    child: Container(
                                      margin: EdgeInsets.symmetric(
                                          horizontal: 15.5.w),
                                      height: 50.w,
                                      child: LocalPNG(
                                        height: 50.w,
                                        url:
                                            "assets/images/publish/publish.png",
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 30.w,
                                ),
                              ]),
                        ),
                      ))));
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
