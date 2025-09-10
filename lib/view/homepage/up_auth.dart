import 'package:chaguaner2023/components/page_status.dart';
import 'package:chaguaner2023/components/page_title_bar.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UpAuthPage extends StatefulWidget {
  const UpAuthPage({Key? key}) : super(key: key);

  @override
  State<UpAuthPage> createState() => _UpAuthPageState();
}

class _UpAuthPageState extends State<UpAuthPage> {
  Map infoData = {};
  bool loading = true;
  itemFc({String? ic, String? content, bool? status}) {
    return Container(
      height: 40.w,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 19.5.w),
      decoration:
          BoxDecoration(image: DecorationImage(fit: BoxFit.fill, image: AssetImage('assets/images/mine/work_bgb.png'))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          LocalPNG(
            width: 28.w,
            height: 28.w,
            url: 'assets/images/mine/$ic.png',
          ),
          Expanded(
              child: Center(
            child: Text(content!, style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 14.sp)),
          )),
          Text(
            status! ? '已完成' : '未达标',
            style: TextStyle(color: status ? StyleTheme.cDangerColor : StyleTheme.cTitleColor, fontSize: 14.sp),
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    preApply().then((res) {
      if (res!['status'] != 0) {
        infoData = res['data'];
        loading = false;
        setState(() {});
      } else {
        CommonUtils.showText(res['msg'] ?? '系统错误');
      }
    });
  }

  String getText(int status) {
    String text = '';
    switch (status) {
      case -1:
        text = '立即申请';
        break;
      case 0:
        text = '待审核';
        break;
      case 1:
        text = '已认证';
        break;
      default:
    }
    return text;
  }

  Widget titleFc(String title) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 25.w,
          padding: EdgeInsets.symmetric(horizontal: 9.5.w),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.5.w),
              gradient: LinearGradient(
                colors: [Color(0xfff3ab7d), Color(0xffd38651)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              )),
          child: Text(
            title,
            style: TextStyle(color: Colors.white, fontSize: 14.sp),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
              child: Image.asset(
            'assets/images/mine/up_auth_bg.png',
            fit: BoxFit.fitWidth,
            alignment: Alignment.topCenter,
          )),
          Positioned(
              bottom: 23.w + ScreenUtil().bottomBarHeight,
              right: 12.5.w,
              left: 12.5.w,
              child: loading
                  ? PageStatus.loading(true)
                  : Column(
                      children: [
                        Container(
                          padding: EdgeInsets.only(left: 37.5.w, right: 37.5.w, bottom: 18.5.w),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.w),
                              color: Colors.white,
                              border: Border.all(width: 0.5.w, color: Color(0XFFf1aa7a))),
                          width: double.infinity,
                          child: Column(
                            children: [
                              LocalPNG(
                                width: 170.w,
                                height: 25.w,
                                url: 'assets/images/mine/up_auth_t.png',
                              ),
                              SizedBox(
                                height: 16.w,
                              ),
                              Text(
                                '请通过以下方式添加官方审核账号：',
                                style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 14.sp),
                              ),
                              SizedBox(
                                height: 15.w,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () {
                                      CommonUtils.launchURL(infoData['tg_link']);
                                    },
                                    child: Column(
                                      children: [
                                        LocalPNG(
                                          width: 40.w,
                                          height: 40.w,
                                          url: 'assets/images/mine/tg.png',
                                        ),
                                        SizedBox(
                                          height: 15.w,
                                        ),
                                        Text(
                                          'Telegram',
                                          style: TextStyle(color: Colors.black, fontSize: 16.sp),
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 100.w,
                                  ),
                                  GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () {
                                      CommonUtils.launchURL(infoData['pt_link']);
                                    },
                                    child: Column(
                                      children: [
                                        LocalPNG(
                                          width: 40.w,
                                          height: 40.w,
                                          url: 'assets/images/mine/pt.png',
                                        ),
                                        SizedBox(
                                          height: 15.w,
                                        ),
                                        Text(
                                          'Potato',
                                          style: TextStyle(color: Colors.black, fontSize: 16.sp),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(
                                width: double.infinity,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 10.w,
                                    ),
                                    titleFc('需要满足以下条件'),
                                    SizedBox(
                                      height: 15.w,
                                    ),
                                    itemFc(ic: 'ic_auth_a', content: '提现≥1000人民币', status: infoData['withdraw_verify']),
                                    SizedBox(
                                      height: 10.w,
                                    ),
                                    itemFc(ic: 'ic_auth_b', content: '视频需要举牌、水印', status: infoData['video_verify']),
                                    SizedBox(
                                      height: 15.w,
                                    ),
                                    titleFc('入驻说明'),
                                    SizedBox(
                                      height: 15.w,
                                    ),
                                    Text(
                                      (infoData['instruction_tips'] as String).replaceAll('\n', '\n'),
                                      style: TextStyle(color: Colors.black, fontSize: 14.sp),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 16.5.w,
                        ),
                        GestureDetector(
                          onTap: () {
                            if (infoData['apply_status'] == -1) {
                              upApply().then((res) {
                                if (res!['status'] != 0) {
                                  CommonUtils.showText(res['msg']);
                                  infoData['apply_status'] = 0;
                                  setState(() {});
                                } else {
                                  CommonUtils.showText(res['msg']);
                                }
                              });
                            }
                          },
                          child: Container(
                            height: 55.w,
                            width: 162.w,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage(
                                      'assets/images/mine/${infoData['apply_status'] == -1 ? 'auth_btn_1' : 'auth_btn_0'}.png',
                                    ),
                                    fit: BoxFit.fill)),
                            child: Text(
                              getText(
                                infoData['apply_status'],
                              ),
                              style: TextStyle(
                                  fontSize: 14.sp,
                                  color: infoData['apply_status'] == -1 ? Color(0xff9b450b) : Color(0XFF6c6c6c)),
                            ),
                          ),
                        )
                      ],
                    )),
          Positioned(
              top: 0,
              right: 0,
              left: 0,
              child: PageTitleBar(
                title: '原创博主',
              ))
        ],
      ),
    );
  }
}
