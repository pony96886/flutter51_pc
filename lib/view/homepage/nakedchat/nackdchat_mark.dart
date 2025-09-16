import 'package:bot_toast/bot_toast.dart';
import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/page_title_bar.dart';
import 'package:chaguaner2023/components/starrating.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:chaguaner2023/utils/netimage_tool.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../utils/cache/image_net_tool.dart';

class NackdChatMark extends StatefulWidget {
  final Map? data;

  const NackdChatMark({Key? key, this.data}) : super(key: key);

  @override
  State<NackdChatMark> createState() => _NackdChatMarkState();
}

class _NackdChatMarkState extends State<NackdChatMark> {
  TextEditingController content = TextEditingController();
  Map? data;
  List servers = [];
  double girlFace = 1;
  double serverMass = 1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    data = widget.data;
    data!['additions'].forEach((item) {
      servers.add('${item['name']}/${item['gold']}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return HeaderContainer(
        child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Column(
              children: [
                PageTitleBar(
                  title: '评价',
                  rightWidget: GestureDetector(
                    onTap: () {
                      AppGlobal.appRouter?.push(CommonUtils.getRealHash('nakedchatComplain'), extra: {
                        'id': widget.data!['id'],
                      });
                    },
                    child: Text(
                      '投诉',
                      style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 14.sp),
                    ),
                  ),
                ),
                _buildBody(),
                _buildBottomBtn(),
                SizedBox(
                  height: 83.w,
                )
              ],
            )));
  }

  Widget _buildBody() {
    return Expanded(
        child: ListView(
      children: [
        Container(
          margin: EdgeInsets.only(left: 15.w, right: 15.w, top: 10.w),
          color: Colors.white,
          child: Row(
            children: [
              Container(
                height: 160.w,
                width: 120.w,
                margin: EdgeInsets.only(right: 15.5.w),
                child: ImageNetTool(url: data!['girl_chat']['cover']),
              ),
              Expanded(
                  child: SizedBox(
                height: 160.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${data!['girl_chat']['title']}',
                      style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 15.sp, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      'ID：${data!['girl_chat']['id']}',
                      style: TextStyle(
                        color: Color.fromRGBO(150, 150, 150, 1),
                        fontSize: 12.sp,
                      ),
                    ),
                    SizedBox(
                      height: 10.w,
                    ),
                    Text(
                      '附加项目：${servers.isEmpty ? '--' : servers.join('、')}',
                      style: TextStyle(
                        color: Color.fromRGBO(100, 100, 100, 1),
                        fontSize: 12.sp,
                      ),
                    ),
                    Spacer(),
                    Text(
                      '支付金额：${data!['total_amount']}元宝',
                      style: TextStyle(
                        color: Color.fromRGBO(100, 100, 100, 1),
                        fontSize: 12.sp,
                      ),
                    ),
                    // Text(
                    //   '联系方式：${data['user_contact']}',
                    //   style: TextStyle(
                    //     color: Color.fromRGBO(100, 100, 100, 1),
                    //     fontSize: 12.sp,
                    //   ),
                    // )
                  ],
                ),
              ))
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: new EdgeInsets.only(top: 9.5.w),
                child: Row(
                  children: [
                    Text(
                      '妹子颜值:',
                      style: TextStyle(fontSize: 14.sp, color: StyleTheme.cTitleColor),
                    ),
                    StarRating(
                      onRatingChanged: (rating) {
                        girlFace = rating;
                        setState(() {});
                      },
                      rating: girlFace,
                      size: 12.w,
                      spacing: 5.w,
                    )
                  ],
                ),
              ),
              Container(
                margin: new EdgeInsets.only(top: 9.5.w),
                child: Row(
                  children: [
                    Text(
                      '服务质量:',
                      style: TextStyle(fontSize: 14.sp, color: StyleTheme.cTitleColor),
                    ),
                    StarRating(
                      rating: serverMass,
                      onRatingChanged: (rating) {
                        serverMass = rating;
                        setState(() {});
                      },
                      size: 12.w,
                      spacing: 5.w,
                    )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 20.w, top: 15.w),
                height: 151.w,
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(5.w), color: Color(0xfff5f5f5)),
                child: TextField(
                  maxLines: 999,
                  maxLength: 300,
                  controller: content,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.zero,
                    hintText: '说说你对本次体验的想法吧',
                    counterStyle: TextStyle(color: Color(0xffb4b4b4), fontSize: 15.sp),
                    hintStyle: TextStyle(color: Color(0xffb4b4b4), fontSize: 15.sp),
                    labelStyle: TextStyle(color: Color(0xff1e1e1e), fontSize: 15.sp),
                    border: InputBorder.none, // Removes the default border
                  ),
                ),
              )
            ],
          ),
        )
      ],
    ));
  }

  Widget _buildBottomBtn() {
    return Center(
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          if (content.text.isEmpty) {
            CommonUtils.showText('请输入您的体验评价');
            return;
          }
          BotToast.showLoading();
          girlchatEvaluation(id: data!['id'], face: girlFace, service: serverMass, comment: content.text).then((res) {
            if (res!['status'] != 0) {
              CommonUtils.showText(res['msg']);
              context.pop();
            } else {
              CommonUtils.showText(res['msg']);
            }
          }).whenComplete(() {
            BotToast.closeAllLoading();
          });
        },
        child: Stack(
          children: [
            LocalPNG(
              width: 275.w,
              height: 50.w,
              url: 'assets/images/mymony/money-img.png',
            ),
            Positioned.fill(
                child: Center(
                    child: Text(
              '提交',
              style: TextStyle(fontSize: 15.w, color: Colors.white),
            ))),
          ],
        ),
      ),
    );
  }
}
