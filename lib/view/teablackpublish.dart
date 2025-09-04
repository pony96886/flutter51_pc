import 'package:bot_toast/bot_toast.dart';
import 'package:chaguaner2023/components/citypickers/CommonCity_pickers.dart';
import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/pagetitlebar.dart';
import 'package:chaguaner2023/components/upload/start_upload.dart';
import 'package:chaguaner2023/components/upload/upload_resouce.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TeaBlackPublish extends StatefulWidget {
  TeaBlackPublish({Key? key}) : super(key: key);

  @override
  _TeaBlackPublishState createState() => _TeaBlackPublishState();
}

class _TeaBlackPublishState extends State<TeaBlackPublish> {
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _titleController = TextEditingController();

  List _typeValueList = [];
  String? _type;
  int? _typeValue;
  List _contactType = [];
  String? cityName;
  int cityCode = 0;
  void showText(text) {
    BotToast.showText(text: '$text', align: Alignment(0, 0));
  }

  setBlackType() {
    AppGlobal.blackList.forEach((key, value) {
      _typeValueList.add({'title': value, 'id': int.parse(key)});
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    setBlackType();
  }

  void onSubmit() {
    if (_type == null) {
      showText("请选择资源类型");
      return;
    }
    if (cityCode == 0) {
      showText("请选择城市");
      return;
    }
    if (_titleController.text.trim().isEmpty) {
      showText("请填写标题内容");
      return;
    }
    if (_descriptionController.text.trim().isEmpty) {
      showText("请填写文字描述");
      return;
    }
    if (UploadFileList.allFile['pic']!.urls.length == 0) {
      showText("请上传至少一张图片");
      return;
    }
    // String cityCode = Provider.of<GlobalState>(context, listen: false).cityCode;
    StartUploadFile.upload().then((value) {
      if (value != null) {
        List _img = value['pic'].map((e) {
          return e['url'];
        }).toList();
        blackPostInfo(_titleController.text, _descriptionController.text, _typeValue!, cityCode.toString(), _img)
            .then((res) {
          if (res!['status'] != 0) {
            CommonUtils.showText('上传成功，请耐心等待官方审核');
            AppGlobal.appRouter?.replace(CommonUtils.getRealHash('waittingStatusPage'));
          } else {
            CommonUtils.showText(res['msg']);
          }
        });
      } else {}
    });
  }

  @override
  void dispose() {
    UploadFileList.dispose();
    super.dispose();
  }

  Widget simpleTypeOption() {
    List<Widget> tiles = [];
    Widget content;
    for (int i = 0; i < _typeValueList.length; i++) {
      String titlss = _typeValueList[i]['title'];
      int ids = _typeValueList[i]['id'];
      tiles.add(SimpleDialogOption(
          child: Center(
            child: Text(titlss, style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 14.sp)),
          ),
          onPressed: () {
            Navigator.pop(context);
            setState(() {
              _type = titlss;
              _typeValue = ids;
            });
            // print(_typeValue);
          }));
      if (i + 1 != _typeValueList.length) {
        tiles.add(BottomLine());
      }
    }

    content = new SimpleDialog(
        shape: RoundedRectangleBorder(
            side: BorderSide(
              style: BorderStyle.none,
            ),
            borderRadius: BorderRadius.circular(10)),
        contentPadding: EdgeInsets.symmetric(vertical: 15.w, horizontal: 15.w),
        children: tiles);

    return content;
  }

  Future<bool> handleTipsUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? tokenState = prefs.getString("photo");
    if (['', null, false].contains(tokenState)) {
      return false;
    } else {
      return true;
    }
  }

  _showCityPickers(BuildContext context) async {
    dynamic result =
        await Navigator.push(context, new MaterialPageRoute(builder: (context) => CommonCityPickers()));
    if (result != null) {
      setState(() {
        cityName = result.city;
      });
      var setAreaResult = await setArea(result.code);
      if (setAreaResult!['status'] == 1) {
        print(result.code);
        print(result.city);
        cityName = result.city;
        cityCode = result.code;
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String asdid3 = '请选择';
    return HeaderContainer(
        child: Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: PreferredSize(
            child: PageTitleBar(
              title: '茶馆黑榜',
            ),
            preferredSize: Size(double.infinity, 44.w),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                    padding: EdgeInsets.only(left: 15.5.w, right: 15.5.w),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          ListTile(
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return simpleTypeOption();
                                  });
                            },
                            contentPadding: EdgeInsets.only(left: 0, right: 0),
                            title: Text('资源类型', style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 14.sp)),
                            trailing: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                              Text(_type == null ? asdid3 : _type.toString(),
                                  style: TextStyle(
                                      fontSize: 14.sp,
                                      color: _type == null ? StyleTheme.cBioColor : StyleTheme.cTitleColor)),
                              Icon(Icons.keyboard_arrow_right, color: StyleTheme.cBioColor),
                            ]),
                          ),
                          Container(
                            width: double.infinity,
                            height: 1,
                            decoration: BoxDecoration(
                                color: Color(0xFFEEEEEE), borderRadius: BorderRadius.all(Radius.circular(8))),
                          ),
                          ListTile(
                            onTap: () async {
                              await _showCityPickers(context);
                            },
                            contentPadding: EdgeInsets.only(left: 0, right: 0),
                            title: Text('选择城市', style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 14.sp)),
                            trailing: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                              Text(cityName ?? '选择所在城市',
                                  style: TextStyle(
                                      fontSize: 14.sp,
                                      color: cityName == null ? StyleTheme.cBioColor : StyleTheme.cTitleColor)),
                              Icon(Icons.keyboard_arrow_right, color: StyleTheme.cBioColor),
                            ]),
                          ),
                          Container(
                            width: double.infinity,
                            height: 1,
                            decoration: BoxDecoration(
                                color: Color(0xFFEEEEEE), borderRadius: BorderRadius.all(Radius.circular(8))),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 20.w),
                            child: Text('黑榜标题', style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 14.sp)),
                          ),
                          Container(
                            height: 35.w,
                            padding: EdgeInsets.symmetric(horizontal: 11.w),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.w),
                              color: Color(0xFFF5F5F5),
                            ),
                            child: TextField(
                              controller: _titleController,
                              textInputAction: TextInputAction.done,
                              autofocus: false,
                              maxLength: 50,
                              style: TextStyle(fontSize: 14.sp, color: StyleTheme.cTitleColor),
                              decoration: InputDecoration.collapsed(
                                      hintStyle: TextStyle(fontSize: 14.sp, color: StyleTheme.cBioColor),
                                      hintText: "把最重要的槽点作为标题")
                                  .copyWith(
                                counterText: "",
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 20.w),
                            child: Text('详细描述', style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 14.sp)),
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
                                      hintText: "输入文字描述说明要曝光的黑店。"),
                                ),
                              )),
                          SizedBox(
                            height: 20.w,
                          ),
                          Text("图片",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  color: StyleTheme.cTitleColor, fontSize: 18.sp, fontWeight: FontWeight.w500)),
                          SizedBox(height: 5.w),
                          SizedBox(
                            height: 5.w,
                          ),
                          UploadResouceWidget(
                            parmas: 'pic',
                            uploadType: 'image',
                            maxLength: 10,
                          ),
                          SizedBox(
                            height: 50.w,
                          ),
                          GestureDetector(
                            onTap: () {
                              onSubmit();
                            },
                            child: Center(
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 15.5.w),
                                height: 50.w,
                                child: LocalPNG(url: "assets/images/publish/publish.png"),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 30.w,
                          )
                        ]))
              ],
            ),
          ),
        ),
      ],
    ));
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

class WaittingStatusPage extends StatelessWidget {
  const WaittingStatusPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HeaderContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
          child: PageTitleBar(
            onback: () {
              context.go('/home');
              context.push('/teaBlackList');
            },
            title: '黑榜审核',
          ),
          preferredSize: Size(double.infinity, 44.w),
        ),
        body: Column(
          children: [
            SizedBox(
              height: 25.w,
            ),
            Center(
              child: Container(
                width: 150.w,
                height: 150.w,
                child: LocalPNG(
                  width: 150.w,
                  height: 150.w,
                  url: "assets/images/publish/waitingicon.png",
                ),
              ),
            ),
            Center(
                child: Text('正在审核，请耐心等待',
                    style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 18.sp, fontWeight: FontWeight.w500))),
          ],
        ),
      ),
    );
  }
}
