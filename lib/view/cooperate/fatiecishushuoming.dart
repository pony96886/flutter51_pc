import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/loading.dart';
import 'package:chaguaner2023/components/pagetitlebar.dart';
import 'package:chaguaner2023/store/homeConfig.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/agent_item.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class FaTieCiShuShuoMingPage extends StatefulWidget {
  @override
  _FaTieCiShuShuoMingPageState createState() => _FaTieCiShuShuoMingPageState();
}

class _FaTieCiShuShuoMingPageState extends State<FaTieCiShuShuoMingPage> {
  Map? _faTieCiShuEntity;

  @override
  void initState() {
    super.initState();
    _getData();
  }

  _getData() async {
    _faTieCiShuEntity = await numberIntro();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return HeaderContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
            child: PageTitleBar(
              title: '发帖次数说明',
            ),
            preferredSize: Size(double.infinity, 44.w)),
        body: _faTieCiShuEntity == null
            ? Loading()
            : Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.w),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _firstWidget(),
                      Container(
                        height: 15.w,
                      ),
                      _secondWidget(),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.w),
                        child: Text(
                          "发帖规则",
                          style: TextStyle(
                            color: StyleTheme.cTitleColor,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _thirdWidget(),
                      AppGlobal.publishPostType == 0
                          ? const SizedBox()
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10.w),
                                  child: Text(
                                    "初始发帖次数",
                                    style: TextStyle(
                                      color: StyleTheme.cTitleColor,
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                InitNumber(
                                  title: "· VIP用户：",
                                  value: (_faTieCiShuEntity!['data']
                                              ['init_vip_post_num'] ??
                                          0)
                                      .toString(),
                                ),
                                InitNumber(
                                  title: "· 茶女郎：",
                                  value: (_faTieCiShuEntity!['data']
                                              ['init_girl_post_num'] ??
                                          0)
                                      .toString(),
                                ),
                                InitNumber(
                                  title: "· 茶小二：",
                                  value: (_faTieCiShuEntity!['data']
                                              ['init_auth_post_num'] ??
                                          0)
                                      .toString(),
                                ),
                                InitNumber(
                                  title: "· 茶老板：",
                                  value: (_faTieCiShuEntity!['data']
                                              ['init_agent_post_num'] ??
                                          0)
                                      .toString(),
                                ),
                              ],
                            )
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  _firstWidget() {
    dynamic agentValue = _faTieCiShuEntity != null
        ? AgentItem.name(_faTieCiShuEntity!['data']['agent'])
        : "";
    String useravatar =
        Provider.of<HomeConfig>(context).member.thumb; //KyGlobal.avatar;
    String usernickname = Provider.of<HomeConfig>(context).member.nickname!;

    ///KyGlobal.nickname;
    return Container(
      height: 75.w,
      width: double.infinity,
      // color: Colors.blue,
      child: Row(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(60.w),
            child: LocalPNG(
              url: "assets/images/common/$useravatar.png",
              width: 60.w,
              height: 60.w,
            ),
          ),
          SizedBox(width: 10.w),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "$usernickname",
                style: TextStyle(
                    color: StyleTheme.cTitleColor,
                    fontSize: 16.w,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 7.5.w),
              Text(
                "$agentValue",
                style: TextStyle(
                  color: StyleTheme.cBioColor,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _secondWidget() {
    String max_post_num = (AppGlobal.publishPostType == 0
        ? 'max_store_post_num'
        : 'max_post_num');
    String now_post_num = (AppGlobal.publishPostType == 0
        ? 'now_store_post_num'
        : 'now_post_num');
    int exp = _faTieCiShuEntity!['data']
            [AppGlobal.publishPostType == 0 ? 'exp1' : 'exp'] ??
        0;
    int levelUpNum = _faTieCiShuEntity!['data']['level_up_num'] ?? 200;
    int addNum = exp ~/ levelUpNum + 1;
    double alljindutiao = 1.sw - 70.w;
    double curjindutiao = (exp / levelUpNum - exp ~/ levelUpNum) * alljindutiao;
    int maxPostNum = _faTieCiShuEntity!['data'][max_post_num] ?? 0;
    int nowPostNum = _faTieCiShuEntity!['data'][now_post_num] ?? 0;
    int fatienum = maxPostNum - nowPostNum;
    int cishuLe = _faTieCiShuEntity!['data']['level_up_num'] ?? 0;
    dynamic leveladn = levelUpNum * addNum;
    String expValue = '$exp/$leveladn';
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.w),
      decoration: BoxDecoration(
        boxShadow: [
          //阴影
          BoxShadow(
              color: Colors.black12,
              offset: Offset(0, 0.5.w),
              blurRadius: 2.5.w)
        ],
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 75.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text(
                      "$maxPostNum",
                      style: TextStyle(
                          color: StyleTheme.cTitleColor,
                          fontSize: 24.w,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 7.5.w),
                    Text(
                      "累计发帖上限",
                      style: TextStyle(
                        color: StyleTheme.cBioColor,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      (fatienum < 0 ? 0 : fatienum).toString(),
                      style: TextStyle(
                          color: StyleTheme.cTitleColor,
                          fontSize: 24.w,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 7.5.w),
                    Text(
                      "剩余发帖次数",
                      style: TextStyle(
                        color: StyleTheme.cBioColor,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          Text.rich(
            TextSpan(
                text: '积分 ',
                style: TextStyle(
                    color: StyleTheme.cTitleColor,
                    fontSize: 32.sp,
                    fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                    text: '(每增加' + cishuLe.toString() + '积分，发帖上限+1)',
                    style: TextStyle(
                      color: Color.fromRGBO(220, 76, 61, 1.0),
                      fontSize: 12.sp,
                    ),
                  ),
                ]),
          ),
          Container(
            height: 10.w,
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 25.w),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(7.w),
                  child: Container(
                    height: 12.w,
                    width: alljindutiao,
                    color: Color.fromRGBO(245, 245, 245, 1.0),
                    alignment: Alignment.topLeft,
                    child: UnconstrainedBox(
                      child: Container(
                        width: curjindutiao,
                        height: 12.w,
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(220, 76, 61, 1.0),
                          borderRadius: BorderRadius.circular(7.5.w),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                child: Container(
                  width: 50.w,
                  height: 22.w,
                  // color: Colors.amber,
                  child: Stack(
                    children: [
                      LocalPNG(
                        url: "assets/images/v8/exp.png",
                        width: 50.w,
                        height: 22.w,
                      ),
                      Positioned(
                        child: Center(
                          child: Text(
                            // '100/200',
                            expValue,
                            style:
                                TextStyle(color: Colors.white, fontSize: 10.sp),
                          ),
                        ),
                        top: 7.5.w,
                        left: 0,
                        right: 0,
                      ),
                    ],
                  ),
                ),
                top: 17.5.w,
                left: curjindutiao - 25.w,
              ),
            ],
          )
        ],
      ),
    );
  }

  _thirdWidget() {
    dynamic unlockNum = _faTieCiShuEntity!['data']['exp_unlock_add_num'] ?? 0;
    dynamic expNum = _faTieCiShuEntity!['data']['exp_complain_sub_num'] ?? 0;
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Color.fromRGBO(245, 245, 245, 1.0),
        borderRadius: BorderRadius.circular(10.w),
      ),
      child: DefaultTextStyle(
          style: TextStyle(
            color: StyleTheme.cTitleColor,
            fontSize: 14.sp,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "1、用户使用元宝解锁你的茶贴，积分+" + unlockNum.toString(),
              ),
              Text("2、VIP用户或者花费元宝解锁者的投诉，发帖者积分-" + expNum.toString()),
              Text(
                  "(仅骗子和无效${AppGlobal.publishPostType == 1 ? '联系方式' : '地址'}的投诉类型才会扣分，如遇恶意投诉者可通过“消息”-“在线客服”向平台申诉)"),
              Text(
                  "3、不可发布漏点图片及未成年人信息${AppGlobal.publishPostType == 1 ? '，联系方式请按正常格式发布，不可转加联系方式。' : ''}"),
              Text("4、禁止私下收取用户定金、路费等，收取请走平台品茶宝（茶小二）"),
            ],
          )),
    );
  }
}

class InitNumber extends StatelessWidget {
  const InitNumber({Key? key, this.title, this.value}) : super(key: key);
  final String? title;
  final String? value;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 5.w),
      child: Text(
        '$title $value次',
        style: TextStyle(
          color: StyleTheme.cTextColor,
          fontSize: 12.sp,
        ),
      ),
    );
  }
}
