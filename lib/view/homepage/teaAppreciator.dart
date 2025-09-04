import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/pagetitlebar.dart';
import 'package:chaguaner2023/store/homeConfig.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class TeaAppreciator extends StatefulWidget {
  TeaAppreciator({Key? key}) : super(key: key);

  @override
  _TeaAppreciatorState createState() => _TeaAppreciatorState();
}

class _TeaAppreciatorState extends State<TeaAppreciator> {
  @override
  Widget build(BuildContext context) {
    var agent = Provider.of<HomeConfig>(context).member.agent;
    return HeaderContainer(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
            child: PageTitleBar(
              title: '鉴茶师介绍',
            ),
            preferredSize: Size(double.infinity, 44.w)),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(15.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(bottom: 15.w),
                child: Text(
                    "鉴茶师分为实习和正式两个阶段，每月的考核指标完成了，实习才能转正，如果正式鉴茶师当月未完成考核任务，那么也会由正式转为实习。",
                    style: TextStyle(
                        color: StyleTheme.cTitleColor,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500)),
              ),
              Container(
                child: Text("考核标准分为初中高三个级别，考核要求会在鉴茶师群里公布，考核范围如下：",
                    style: TextStyle(
                        color: StyleTheme.cTitleColor,
                        fontSize: 13.w,
                        fontWeight: FontWeight.w500)),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 15.w),
                child: Text(
                    "1. 每月提交验茶报告数量\n2. 分享真实资源或推广经纪人/茶女郎入驻的数量\n3. 完成平台发布任务数量",
                    style: TextStyle(
                        color: StyleTheme.cDangerColor,
                        fontSize: 13.sp,
                        height: 1.5)),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 15.w),
                child: Text("平台每月考核数据，达到相应条件的，会有相应权益",
                    style: TextStyle(
                        color: StyleTheme.cTitleColor,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500)),
              ),
              Container(
                child: Text("正式鉴茶师所有拥有的特殊权益如下：",
                    style: TextStyle(
                        color: StyleTheme.cTitleColor,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500)),
              ),
              Container(
                child: Text("1.拥有鉴茶师身份标签\n2.发布付费的验茶报告，赚取解锁收益\n3.领取平台悬赏任务",
                    style: TextStyle(
                      height: 1.5,
                      color: StyleTheme.cDangerColor,
                      fontSize: 13.sp,
                    )),
              ),
              SizedBox(height: 50.w),
              agent == 4 || agent == 5
                  ? SizedBox()
                  : GestureDetector(
                      onTap: () {
                        AppGlobal.appRouter?.push('/onlineServicePage');
                      },
                      child: Center(
                        child: SizedBox(
                          width: 325.w,
                          height: 50.w,
                          child: Stack(
                            children: [
                              LocalPNG(
                                url: "assets/images/pment/submit.png",
                                width: 325.w,
                                height: 50.w,
                              ),
                              Center(
                                child: Text("申请认证",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16.sp)),
                              ),
                            ],
                          ),
                        ),
                      )),
            ],
          ),
        ),
      ),
    );
  }
}
