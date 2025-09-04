import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/loading.dart';
import 'package:chaguaner2023/components/pagetitlebar.dart';
import 'package:chaguaner2023/input/InputDailog.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../upload/publishPage.dart';

class BossConnect extends StatefulWidget {
  const BossConnect({Key? key}) : super(key: key);

  @override
  State<BossConnect> createState() => _BossConnectState();
}

class _BossConnectState extends State<BossConnect> {
  String phone = '';
  String wechat = '';
  String qq = '';
  bool loading = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getStoreContact().then((res) {
      if (res!['status'] != 0) {
        Map _data = res!['data'];
        phone = _data['tel'];
        wechat = _data['wechat'];
        qq = _data['qq'];
        loading = false;
        setState(() {});
      } else {
        CommonUtils.showText(res['msg']);
      }
    });
  }

  Widget inputItem(Map item) {
    String itemValueStr = item['value'].toString();
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ListTile(
            onTap: () {
              InputDialog.show(context, item['title'],
                      limitingText: 16,
                      boardType: item['isNumber']
                          ? TextInputType.phone
                          : TextInputType.text)
                  .then((value) {
                item['callBack'](value);
              });
            },
            contentPadding: EdgeInsets.only(left: 0, right: 0),
            title: Text(item['title'],
                style:
                    TextStyle(color: StyleTheme.cTitleColor, fontSize: 14.sp)),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
              Container(
                constraints: BoxConstraints(maxWidth: 250.w),
                child: Text(
                    item['value'] == null || item['value'] == ''
                        ? item['hintText']
                        : itemValueStr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                        color: item['value'] == null || item['value'] == ''
                            ? StyleTheme.cBioColor
                            : StyleTheme.cTitleColor)),
              ),
            ]),
          ),
          BottomLine(),
        ],
      ),
    );
  }

  onSubmit() {
    if (phone.isEmpty && wechat.isEmpty && qq.isEmpty) {
      return CommonUtils.showText('请至少填写一种联系方式');
    }
    setStoreContact(tel: phone, wechat: wechat, qq: qq).then((res) {
      CommonUtils.showText(res!['msg']);
    });
  }

  @override
  Widget build(BuildContext context) {
    return HeaderContainer(
        child: Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
          child: PageTitleBar(
            title: '联系方式',
          ),
          preferredSize: Size(double.infinity, 44.w)),
      body: loading
          ? Loading()
          : Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 30.w,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 15.5.w),
                      child: Text(
                        '联系方式',
                        style: TextStyle(
                            color: StyleTheme.cTitleColor, fontSize: 18.sp),
                      ),
                    ),
                    inputItem({
                      'title': '电话',
                      'value': phone,
                      'isNumber': true,
                      'callBack': (value) {
                        if (value != null) {
                          phone = value;
                          setState(() {});
                        }
                      },
                      'hintText': '输入联系电话'
                    }),
                    inputItem({
                      'title': '微信',
                      'value': wechat,
                      'isNumber': false,
                      'callBack': (value) {
                        if (value != null) {
                          wechat = value;
                          setState(() {});
                        }
                      },
                      'hintText': '输入联系微信'
                    }),
                    inputItem({
                      'title': 'QQ',
                      'value': qq,
                      'isNumber': true,
                      'callBack': (value) {
                        if (value != null) {
                          qq = value;
                          setState(() {});
                        }
                      },
                      'hintText': '输入联系QQ'
                    })
                  ],
                ),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      onSubmit();
                    },
                    child: Container(
                      width: 275.w,
                      height: 50.w,
                      margin: EdgeInsets.only(
                          bottom: ScreenUtil().bottomBarHeight + 15.w),
                      child: Stack(
                        children: [
                          LocalPNG(
                            width: double.infinity,
                            height: 50.w,
                            url: "assets/images/mine/black_button.png",
                          ),
                          Center(
                              child: Text("保存",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 15.sp))),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
    ));
  }
}
