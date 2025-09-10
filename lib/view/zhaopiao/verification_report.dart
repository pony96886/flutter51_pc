import 'package:bot_toast/bot_toast.dart';
import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/loading.dart';
import 'package:chaguaner2023/components/page_title_bar.dart';
import 'package:chaguaner2023/components/starrating.dart';
import 'package:chaguaner2023/components/tab/tab_nav.dart';
import 'package:chaguaner2023/components/upload/start_upload.dart';
import 'package:chaguaner2023/components/upload/upload_resouce.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:chaguaner2023/utils/pageviewmixin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class VerificationReportPage extends StatefulWidget {
  final String? id;
  final int? agent;
  final int? index;
  final bool? isReport;
  VerificationReportPage({Key? key, this.id, this.agent, this.isReport = false, this.index}) : super(key: key);
  @override
  State<StatefulWidget> createState() => VerificationReportState();
}

class VerificationReportState extends State<VerificationReportPage> {
  Map<String, String> editImg = {};
  String? editId;
  bool _tabState = true;
  bool loading = true;
  Map showIma = {};
  bool isEdit = false;
  String? videoEditUrl;
  List updateList = [
    {'title': '周围环境', 'topic': '(场所附近建筑或门面照)', 'img': 'surroundings'},
    {'title': '室内环境', 'topic': '', 'img': 'area'},
    {'title': '妹子照片', 'topic': '(可以遮挡脸部)', 'img': 'chatRecord'},
    {'title': '支付凭证截图', 'topic': '(自行涂抹隐私信息)', 'img': 'payScreenshot'}
  ];
  truePost(Map fileData) async {
    var imageData = [];

    updateList.forEach((element) {
      if (fileData[element['img']] != null) {
        imageData.add({'url': fileData[element['img']][0]['url'], 'type': getType(element['img'])});
      } else {
        Uri _url = Uri.parse(UploadFileList.allFile[element['img']]!.originalUrls[0].path);
        imageData.add({'url': _url.path, 'type': getType(element['img'])});
      }
    });
    if (fileData['video'] != null) {
      imageData.add({'url': fileData['video'][0]['url'], 'type': 5});
    }
    var reqFunc = isEdit ? editConfirmInfo : submitConfirmInfo;
    var quitGroup = await reqFunc(
        flowerName,
        price,
        verificationTime,
        location,
        figure,
        similarValues,
        cup,
        descriptionControllerTrue.text,
        faceValueStar,
        serviceQualityStar,
        surroundings,
        isEdit ? editId : widget.id,
        imageData);
    if (quitGroup!['status'] != 0) {
      Navigator.of(context).pop(widget.index);
      String repoo = '投诉';
      String bbb = '报告';
      String sunbbm = _tabState ? bbb : repoo;
      BotToast.showText(text: '您的$sunbbm已提交成功～', align: Alignment(0, 0));
      context.go('/home');
      AppGlobal.appRouter
          ?.push(CommonUtils.getRealHash('resourcesDetailPage/false/' + widget.id.toString() + '/null/null/null'));
    } else {
      BotToast.showText(text: quitGroup!['msg'], align: Alignment(0, 0));
    }
  }

  getType(String type) {
    if (type == 'surroundings') {
      return 1;
    }
    if (type == 'area') {
      return 2;
    }
    if (type == 'chatRecord') {
      return 3;
    }
    if (type == 'payScreenshot') {
      return 4;
    }
  }

  //妹子花名
  String flowerName = '';
  //报告价格
  String price = '';
  //验证时间
  String verificationTime = '';
  //所在位置
  String location = '';
  //身高身材
  String figure = '';
  //颜值相似
  String similarValues = '';
  //胸器罩杯
  String cup = '';
  //妹子颜值打分
  double faceValueStar = 0.0;
  //服务质量打分
  double serviceQualityStar = 0.0;
  //环境设备打分
  double surroundings = 0.0;
  @override
  void initState() {
    super.initState();
    if (widget.isReport!) {
      setState(() {
        _tabState = false;
      });
    }
    getBaogao(int.parse(widget.id!)).then((res) {
      if (res!['status'] != 0) {
        if (res['data'] != null) {
          flowerName = res['data']['girl_name'];
          price = res['data']['price'].toString();
          verificationTime = res['data']['time'];
          location = res['data']['address'];
          figure = res['data']['girl_body'];
          similarValues = res['data']['girl_face_like'];
          cup = res['data']['girl_cup'];
          faceValueStar = double.parse(res['data']['girl_face'].toString());
          serviceQualityStar = double.parse(res!['data']['girl_service'].toString());
          surroundings = double.parse(res['data']['env'].toString());
          descriptionControllerTrue.text = res['data']['girl_service_detail'];
          editId = res['data']['id'].toString();
          isEdit = true;
          List photoAlbum = res['data']['photo_album'];
          photoAlbum.forEach((img) {
            if (img['type'] == 1) {
              editImg['surroundings'] = img['img_url'];
            }
            if (img['type'] == 2) {
              editImg['area'] = img['img_url'];
            }
            if (img['type'] == 3) {
              editImg['chatRecord'] = img['img_url'];
            }
            if (img['type'] == 4) {
              editImg['payScreenshot'] = img['img_url'];
            }
            if (img['type'] == 5) {
              videoEditUrl = img['img_url'];
            }
          });
          loading = false;
          setState(() {});
        } else {
          setState(() {
            loading = false;
          });
        }
      }
    });
  }

//之前没想过编辑，后面优化
  getNumType(String type) {
    if (type == 'surroundings') {
      return 1;
    }
    if (type == 'area') {
      return 2;
    }
    if (type == 'chatRecord') {
      return 3;
    }
    if (type == 'payScreenshot') {
      return 4;
    }
  }

  _verification() async {
    var formData = [
      flowerName,
      verificationTime,
      location,
      figure,
      similarValues,
      cup,
      descriptionControllerTrue.text,
      faceValueStar,
      serviceQualityStar,
      surroundings
    ];
    if (_tabState) {
      for (var i = 0; i < formData.length; i++) {
        if (formData[i] == '' || formData[i] == 0.0) {
          return BotToast.showText(text: '请完整填写表单～', align: Alignment(0, 0));
        }
      }
      formData.insert(1, price); //加入价格
      bool isUpload = true;
      updateList.forEach((element) {
        if ((UploadFileList.allFile[element['img']]!.originalUrls.length +
                UploadFileList.allFile[element['img']]!.urls.length) ==
            0) {
          isUpload = false;
        }
      });
      if (!isUpload) {
        return BotToast.showText(text: '必须按要求上传四张图片', align: Alignment(0, 0));
      }
      if (UploadFileList.allFile['falsePic'] != null && UploadFileList.allFile['falsePic']!.urls.length != 0) {
        UploadFileList.allFile['falsePic']!.urls = [];
      }
      setState(() {});
      StartUploadFile.upload().then((value) {
        CommonUtils.debugPrint('验证');
        truePost(value!);
      });
    } else {
      if (falseType == null) {
        return BotToast.showText(text: '请选择其中一项', align: Alignment(0, 0));
      } else if (descriptionControllerFalse.text == '') {
        return BotToast.showText(text: '请填写具体内容', align: Alignment(0, 0));
      }
      if (falseType == 3 && UploadFileList.allFile['falsePic']!.urls.length == 0) {
        return BotToast.showText(text: '选择投诉骗子请提供图片证明', align: Alignment(0, 0));
      }
      if (UploadFileList.allFile['video'] != null && UploadFileList.allFile['video']!.urls.length != 0) {
        UploadFileList.allFile['video']!.urls = [];
      }
      updateList.forEach((element) {
        if (UploadFileList.allFile[element['img']] != null &&
            UploadFileList.allFile[element['img']]!.urls.length != 0) {
          UploadFileList.allFile[element['img']]!.urls = [];
        }
      });
      setState(() {});
      if (UploadFileList.allFile['falsePic']!.urls.length == 0) {
        onSendData({'falseType': 1});
      } else {
        StartUploadFile.upload().then((value) {
          CommonUtils.debugPrint('投诉');
          onSendData(value!);
        });
      }
    }
  }

  onSendData(Map fileData) async {
    if (fileData == null) {
      CommonUtils.showText('图片上传失败,请重新上传');
      return;
    }
    List _img;
    if (fileData['falseType'] != null) {
      _img = [];
    } else {
      _img = fileData['falsePic'].map((e) {
        return e['url'];
      }).toList();
    }

    var fakeInfo = await submitFakeInfo(falseType!, descriptionControllerFalse.text, widget.id!, _img);
    String repString = '报告';
    if (fakeInfo!['status'] != 0) {
      Navigator.of(context).pop(widget.index);
      String submm = _tabState ? repString : '投诉';
      BotToast.showText(text: '您的$submm已提交成功～', align: Alignment(0, 0));
      context.go('/home');
      AppGlobal.appRouter
          ?.push(CommonUtils.getRealHash('resourcesDetailPage/false/' + widget.id.toString() + '/null/null/null'));
    } else {
      BotToast.showText(text: fakeInfo!['msg'], align: Alignment(0, 0));
    }
  }

  int? falseType;
  List _radioList = [
    {'value': '无效联系方式', 'state': 1},
    {'value': '骗子', 'state': 3},
    {'value': '帖子内容与分类不符', 'state': 6}
  ];
  _startList() {
    return [
      {
        'title': '妹子颜值',
        'star': faceValueStar,
        'setvalue': (val) {
          setState(() {
            faceValueStar = val;
          });
        }
      },
      {
        'title': '服务质量',
        'star': serviceQualityStar,
        'setvalue': (val) {
          setState(() {
            serviceQualityStar = val;
          });
        }
      },
      {
        'title': '环境设备',
        'star': surroundings,
        'setvalue': (val) {
          setState(() {
            surroundings = val;
          });
        }
      }
    ];
  }

  _formList() {
    var renderList = [
      {
        'title': '妹子花名',
        'topic': '妹子编号',
        'setvalue': (val) {
          setState(() {
            flowerName = val;
          });
        },
        'value': flowerName
      },
      {
        'title': '品茶时间',
        'topic': '输入实际去品茶的时间',
        'setvalue': (val) {
          setState(() {
            verificationTime = val;
          });
        },
        'value': verificationTime
      },
      {
        'title': '所在位置',
        'topic': '什么区，什么地铁站附近',
        'setvalue': (val) {
          setState(() {
            location = val;
          });
        },
        'value': location
      },
      {
        'title': '身高身材',
        'topic': '输入身高身材',
        'setvalue': (val) {
          setState(() {
            figure = val;
          });
        },
        'value': figure
      },
      {
        'title': '颜值水平',
        'topic': '对妹子颜值简单评价',
        'setvalue': (val) {
          setState(() {
            similarValues = val;
          });
        },
        'value': similarValues
      },
      {
        'title': '胸器罩杯',
        'topic': '输入妹子的胸器信息',
        'setvalue': (val) {
          setState(() {
            cup = val;
          });
        },
        'value': cup
      }
    ];
    if (widget.agent == 4) {
      renderList.insert(1, {
        'title': '报告价格',
        'topic': '请输入报告价格(元宝）',
        'isAgent': true,
        'isNum': true,
        'setvalue': (val) {
          setState(() {
            price = val;
          });
        },
        'value': price
      });
    }
    return renderList;
  }

  TextEditingController descriptionControllerTrue = TextEditingController();
  TextEditingController descriptionControllerFalse = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: HeaderContainer(
        child: Stack(
          children: <Widget>[
            Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: Colors.transparent,
              appBar: PreferredSize(
                  child: PageTitleBar(
                    title: '验证茶帖',
                  ),
                  preferredSize: Size(double.infinity, 44.w)),
              body: loading
                  ? Loading()
                  : Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          TabNav(
                            rightWidth: 140,
                            setTabState: (val) {
                              _tabState = val;
                              setState(() {});
                            },
                            initTab: widget.isReport,
                            leftWidth: 140,
                            leftTitle: '验茶报告',
                            rightTitle: '我要投诉',
                            rightChild: PageViewMixin(
                              child: Container(child: _falseDetail()),
                            ),
                            leftChild: PageViewMixin(
                              child: Container(
                                child: _trueDetail(),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: _verification,
                            child: Container(
                              padding: new EdgeInsets.only(top: 30.w, bottom: 30.w + ScreenUtil().bottomBarHeight),
                              child: LocalPNG(
                                url: 'assets/images/submit-bottom.png',
                                height: 50.w,
                                width: 275.w,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _radeoItem(String title, int state) {
    return GestureDetector(
      onTap: () {
        setState(() {
          falseType = falseType == state ? null : state;
        });
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          falseType == state
              ? LocalPNG(
                  url: 'assets/images/checkd-selected.png',
                  height: 15.w,
                )
              : LocalPNG(
                  url: 'assets/images/checkd-unselected.png',
                  height: 15.w,
                ),
          Container(
            padding: new EdgeInsets.only(left: 10.5.w),
            child: Text(title, style: TextStyle(fontSize: 15.sp, color: StyleTheme.cTitleColor)),
          )
        ],
      ),
    );
  }

  Widget _falseDetail() {
    return Container(
      padding: new EdgeInsets.symmetric(
        horizontal: 15.w,
      ),
      margin: new EdgeInsets.only(top: 40.w),
      height: double.infinity,
      child: ListView(
        shrinkWrap: true,
        children: [
          Wrap(
            runSpacing: 20.w,
            spacing: 50.w,
            direction: Axis.horizontal,
            children: [
              for (var item in _radioList) _radeoItem(item['value'], item['state']),
              Text(
                "* 恶意投诉者，核实后平台将对其进行永久封号处理！",
                style: TextStyle(color: StyleTheme.cDangerColor, fontSize: 14.sp),
              ),
              Text(
                "* 加不上联系方式的话，可能对方已经休息，如24小时后仍未加上再投诉，谢谢！",
                style: TextStyle(color: StyleTheme.cDangerColor, fontSize: 14.sp),
              ),
              Text(
                "* 有的骗子会使用语音和电话行骗，无法进行截图，这种情况可以随便传一张图，在描述里面说明情况就行，平台会有专人处理",
                style: TextStyle(color: StyleTheme.cDangerColor, fontSize: 14.sp),
              ),
              _inputDetail('请输入具体原因', descriptionControllerFalse)
            ],
          ),
          SizedBox(height: 30.w),
          RichText(
              text: TextSpan(
                  text: "照片 ",
                  style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 18.sp, fontWeight: FontWeight.w500),
                  children: <TextSpan>[
                TextSpan(
                    text: ' (请提供图片证明，越详细越好)',
                    style: TextStyle(color: StyleTheme.cDangerColor, fontSize: 14.sp, fontWeight: FontWeight.w400))
              ])),
          DefaultTextStyle(
              style: TextStyle(height: 1.5, color: StyleTheme.cDangerColor, fontSize: 14.sp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('为了尽快为您处理，请务必提供：'),
                  Text('1、带有联系方式的截图（联系方式需和解锁的联系方式一致）'),
                  Text('2、关键的聊天截图（人跑了联系茶老板的聊天记录、未见到人收取服务费的聊天截图）'),
                ],
              )),
          SizedBox(height: 20.w),
          UploadResouceWidget(
            parmas: 'falsePic',
            uploadType: 'image',
            maxLength: 10,
          )
        ],
      ),
    );
  }

  Widget _trueDetail() {
    return Container(
        height: double.infinity,
        child: Column(
          children: [
            Expanded(
                child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: 15.w,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  for (var itemText in _formList())
                    _inputItem(itemText['title'], itemText['topic'], itemText['setvalue'], itemText['isNum'] != null,
                        itemText['value']),
                  Container(
                    child: Text(
                      '服务详情',
                      style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 14.sp),
                    ),
                    padding: new EdgeInsets.only(top: 19.5.w, bottom: 15.w),
                  ),
                  _inputDetail('具体写整个服务过程、感受（尤其特点）', descriptionControllerTrue),
                  for (var starItem in _startList())
                    _starItem(starItem['title'], starItem['star'], starItem['setvalue']),
                  Container(
                    child: Text('真实图片信息',
                        style: TextStyle(color: StyleTheme.cTitleColor, fontWeight: FontWeight.bold, fontSize: 18.sp)),
                    padding: new EdgeInsets.only(top: 19.5.w, bottom: 15.w),
                  ),
                  Text.rich(
                    TextSpan(
                      text: '必须按要求上传四张图片，',
                      style: TextStyle(color: StyleTheme.cDangerColor, fontSize: 14.sp),
                      children: <TextSpan>[TextSpan(text: '审核通过后图片信息会公开', style: TextStyle(color: Color(0xFF969696)))],
                    ),
                  ),
                  Center(
                    child: Wrap(
                      spacing: 35.w,
                      children: [for (var upItem in updateList) _upItem(upItem)],
                    ),
                  ),
                  widget.agent == 3 || widget.agent == 4
                      ? Container(
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(
                                height: 15.w,
                              ),
                              RichText(
                                  text: TextSpan(
                                      text: "视频 ",
                                      style: TextStyle(
                                          color: StyleTheme.cTitleColor, fontSize: 18.sp, fontWeight: FontWeight.bold),
                                      children: <TextSpan>[
                                    TextSpan(text: ' (选填)', style: TextStyle(color: Color(0xFFB4B4B4), fontSize: 14.sp))
                                  ])),
                              SizedBox(
                                height: 20.w,
                              ),
                              UploadResouceWidget(
                                  parmas: 'video',
                                  uploadType: 'video',
                                  maxLength: 1,
                                  disabled: videoEditUrl != null,
                                  initResouceList: videoEditUrl == null
                                      ? null
                                      : [FileInfo(editImg[videoEditUrl], 0, 1, videoEditUrl, 'video', null, 0, 0)]),
                            ],
                          ),
                        )
                      : Container()
                ],
              ),
            )),
          ],
        ));
  }

  Widget _inputDetail(String topic, dynamic value) {
    return Card(
        margin: EdgeInsets.zero,
        shadowColor: Colors.transparent,
        color: Color(0xFFF5F5F5),
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: TextField(
            controller: value,
            textInputAction: TextInputAction.done,
            autofocus: false,
            maxLines: 8,
            style: TextStyle(fontSize: 15.sp, color: StyleTheme.cTitleColor),
            decoration: InputDecoration.collapsed(
                hintStyle: TextStyle(fontSize: 15.sp, color: StyleTheme.cBioColor), hintText: topic),
          ),
        ));
  }

  Widget _upItem(Map item) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 20.w, bottom: 9.5.w),
            height: 140.w,
            width: 140.w,
            child: UploadResouceWidget(
                parmas: item['img'],
                uploadType: 'image',
                maxLength: 1,
                isIndependent: true,
                initResouceList: editImg[item['img']] == null
                    ? null
                    : [FileInfo(editImg[item['img']], 0, 1, item['img'], 'image', null, 0, 0)]),
          ),
          Text(item['title'],
              style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 15.sp, fontWeight: FontWeight.w500)),
          Text(
            item['topic'],
            style: TextStyle(color: Color(0xFF969696), fontSize: 12.sp, height: 2),
          )
        ],
      ),
    );
  }

  Widget _inputItem(String title, String topic, Function setVelue, bool isNum, String value) {
    return Container(
      height: 54.w,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: StyleTheme.textbgColor1, width: 1, style: BorderStyle.solid)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 14.sp, color: StyleTheme.cTitleColor),
          ),
          Container(
            width: 180.w,
            child: TextFormField(
              initialValue: value,
              keyboardType: isNum ? TextInputType.number : TextInputType.text,
              textAlign: TextAlign.right,
              onChanged: (val) {
                setVelue(val);
              },
              decoration: InputDecoration.collapsed(
                  hintStyle: TextStyle(fontSize: 15.sp, color: StyleTheme.cBioColor), hintText: topic),
            ),
          )
        ],
      ),
    );
  }

  Widget _starItem(String title, double star, Function setStar) {
    return Container(
      height: 54.w,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 14.sp, color: StyleTheme.cTitleColor),
          ),
          Container(
            width: 180.w,
            child: StarRating(
              rating: star,
              onRatingChanged: (value) {
                setStar(value);
              },
            ),
          )
        ],
      ),
    );
  }
}
