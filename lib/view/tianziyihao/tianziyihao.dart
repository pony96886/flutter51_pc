import 'package:bot_toast/bot_toast.dart';
import 'package:chaguaner2023/components/cgDialog.dart';
import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/store/global.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class TianZiYiHaoPage extends StatefulWidget {
  final dynamic vipClub;
  TianZiYiHaoPage({Key? key, this.vipClub}) : super(key: key);

  @override
  _TianZiYiHaoPageState createState() => _TianZiYiHaoPageState();
}

class _TianZiYiHaoPageState extends State<TianZiYiHaoPage> {
  bool isAdd = false;
  int money = 0;
  int days = 1;
  String? vipClub;
  Map? info;
  Map? joinInfo;
  getInfo() async {
    var data = await getTianziyihaoInfo();
    if (data!['data'] != null) {
      var endDate = new DateTime.now();

      var _days = endDate
          .difference(DateTime.parse(data['data']['club']['created_at']))
          .inDays;
      this.setState(() {
        info = data;
        isAdd = true;
        vipClub = data['data']['club']['id_str'];
        days = _days == 0 ? 1 : _days;
      });
    }
  }

  getMoney() {
    getProfilePage().then((data) {
      if (data!['data'] != null) {
        money = int.parse(data['data']['money'].toString());
        setState(() {});
      }
    });
  }

  join() async {
    var data = await jointianziyihao();
    if (data!['status'] == 1) {
      getInfo();
      var _number = await getProfilePage();
      Provider.of<GlobalState>(context, listen: false)
          .setProfile(_number!['data']);
    }
    showText(data['msg']);
  }

  void showText(text) {
    BotToast.showText(text: '$text', align: Alignment(0, 0));
  }

  @override
  void initState() {
    super.initState();
    this.setState(() {
      vipClub = widget.vipClub;
    });
    getMoney();
    if (widget.vipClub != '0') {
      getInfo();
    }
  }

  @override
  Widget build(BuildContext context) {
    var profileDatas = Provider.of<GlobalState>(context).profileData;
    String tzOne = '天字一号房';
    return HeaderContainer(
        child: Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 30.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    width: double.infinity,
                    height: 620.w,
                    color: Colors.black,
                    child: Stack(
                      children: [
                        LocalPNG(
                          width: double.infinity,
                          height: 620.w,
                          url: "assets/images/tzyh/banner.png",
                          fit: BoxFit.fitWidth,
                          alignment: Alignment.topLeft,
                        ),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                              horizontal: 30.5.w, vertical: 45.5.w),
                          height: 620.w,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isAdd ? '欢迎您，' : tzOne,
                                style: TextStyle(
                                    color: Color(0xffffbf75),
                                    fontSize: 24.sp,
                                    fontWeight: FontWeight.w700),
                              ),
                              SizedBox(
                                height: 29.5.w,
                              ),
                              isAdd
                                  ? Container(
                                      height: 100.w,
                                      width: 315.w,
                                      child: Stack(
                                        children: [
                                          LocalPNG(
                                            height: 100.w,
                                            width: 315.w,
                                            fit: BoxFit.cover,
                                            url:
                                                'assets/images/tzyh/vip_banner.png',
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 17.5.w),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text.rich(
                                                  TextSpan(
                                                      text: '尊贵的',
                                                      children: [
                                                        TextSpan(
                                                            text: '$vipClub号',
                                                            style: TextStyle(
                                                                color: Color(
                                                                    0xffffbf75),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700)),
                                                        TextSpan(
                                                          text: '俱乐部成员',
                                                        )
                                                      ]),
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 18.sp),
                                                ),
                                                SizedBox(
                                                  height: 13.w,
                                                ),
                                                Text.rich(
                                                  TextSpan(
                                                      text: '您已加入俱乐部 ',
                                                      children: [
                                                        TextSpan(
                                                            text: '$days',
                                                            style: TextStyle(
                                                                color: Color(
                                                                    0xffffbf75),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700)),
                                                        TextSpan(
                                                          text: ' 天',
                                                        )
                                                      ]),
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 18.w),
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Text(
                                      '依托遍布全国34个省份，美、澳、英、法、加、日、韩等40余个国家，超2百万用户的基础，茶馆已经成长为国内顶尖的服务平台。然而我们发现平台已经顶尖，但顶尖的用户还未享受够顶尖的服务。特此茶馆专门面向高端用户，推出“天字一号房”定制化俱乐部。俱乐部专门服务于高端商务人士，定期推送伴游美女、外围模特等最新精品资源，并满足您私人定制服务需求，为您带来一场永恒的浪漫冒险。',
                                      style: TextStyle(
                                          color: Color(0xffdeb682),
                                          fontSize: 12.sp),
                                    )
                            ],
                          ),
                        ),
                      ],
                    )),
                isAdd
                    ? Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30.w),
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '如果您有服务需求，敬请联络：',
                                style: TextStyle(
                                    color: Color(0xffdeb682), fontSize: 15.sp),
                              ),
                              SizedBox(
                                height: 20.w,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  LocalPNG(
                                    url: 'assets/images/tzyh/potato.png',
                                    height: 60.w,
                                    fit: BoxFit.fitHeight,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      CommonUtils.launchURL(
                                          info!['data']['potato']);
                                    },
                                    child: Container(
                                      margin: new EdgeInsets.only(
                                          left: CommonUtils.getWidth(20)),
                                      padding: new EdgeInsets.symmetric(
                                          vertical: CommonUtils.getWidth(12),
                                          horizontal: CommonUtils.getWidth(34)),
                                      decoration: BoxDecoration(
                                          color: StyleTheme.cDangerColor,
                                          borderRadius: BorderRadius.circular(
                                              CommonUtils.getWidth(60))),
                                      child: Text(
                                        '立即联系',
                                        style: TextStyle(
                                          fontSize: CommonUtils.getWidth(26),
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  )
                                  // SizedBox(
                                  //   width: 21.w,
                                  // ),
                                  // Flexible(
                                  //     child: Text(
                                  //   info['data']['potato'],
                                  //   style: TextStyle(
                                  //       color: Colors.white, fontSize: 18.sp),
                                  //   maxLines: 1,
                                  //   overflow: TextOverflow.ellipsis,
                                  // ))
                                ],
                              ),
                              SizedBox(
                                height: 20.w,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  LocalPNG(
                                    url: 'assets/images/tzyh/tg.png',
                                    height: 60.w,
                                    fit: BoxFit.fitHeight,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      CommonUtils.launchURL(
                                          info!['data']['tg']);
                                    },
                                    child: Container(
                                      margin: new EdgeInsets.only(
                                          left: CommonUtils.getWidth(20)),
                                      padding: new EdgeInsets.symmetric(
                                          vertical: CommonUtils.getWidth(12),
                                          horizontal: CommonUtils.getWidth(34)),
                                      decoration: BoxDecoration(
                                          color: StyleTheme.cDangerColor,
                                          borderRadius: BorderRadius.circular(
                                              CommonUtils.getWidth(60))),
                                      child: Text(
                                        '立即联系',
                                        style: TextStyle(
                                          fontSize: CommonUtils.getWidth(26),
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  )
                                  // SizedBox(
                                  //   width: 21.w,
                                  // ),
                                  // Flexible(
                                  //     child: Text(
                                  //   info['data']['tg'],
                                  //   style: TextStyle(
                                  //       color: Colors.white, fontSize: 18.sp),
                                  //   maxLines: 1,
                                  //   overflow: TextOverflow.ellipsis,
                                  // ))
                                ],
                              ),
                              SizedBox(
                                height: 50.w,
                              ),
                              Text(
                                '联络工具下载地址：',
                                style: TextStyle(
                                    color: Color(0xffdeb682), fontSize: 15.sp),
                              ),
                              SizedBox(
                                height: 19.5.sp,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      if (info!['data']['potato_download']
                                          .isNotEmpty) {
                                        CommonUtils.launchURL(
                                            info!['data']['potato_download']);
                                      }
                                    },
                                    child: LocalPNG(
                                      url: 'assets/images/tzyh/potato_src.png',
                                      height: 45.w,
                                      fit: BoxFit.fitHeight,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      if (info!['data']['tg_download']
                                          .isNotEmpty) {
                                        CommonUtils.launchURL(
                                            info!['data']['tg_download']);
                                      }
                                    },
                                    child: LocalPNG(
                                      url: 'assets/images/tzyh/tg_src.png',
                                      height: 45.w,
                                      fit: BoxFit.fitHeight,
                                    ),
                                  )
                                ],
                              )
                            ]),
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 29.5.w),
                            child: LocalPNG(
                              url: 'assets/images/tzyh/julebu.png',
                              height: 49.w,
                              fit: BoxFit.fitHeight,
                            ),
                          ),
                          SizedBox(
                            height: 20.w,
                          ),
                          containerWidget(
                              image: '1',
                              title: '高端：',
                              content:
                                  '加入俱乐部之后，您将收到您的专属会员编号，作为俱乐部尊贵成员的唯一标识。俱乐部定期推送新下水的一手高端精品资源：包括伴游女郎，外围嫩模，清纯校花等各色美女。俱乐部推送的资料，均经过精心挑选，支持伴游出行、party聚会或长期包养。我们介绍的美女，绝对正儿八经的恋人体验，不止颜值出众，更有温柔帖心。'),
                          containerWidget(
                              image: '2',
                              title: '好玩：',
                              content:
                                  '俱乐部会定期组织会员party一起嗨。核心会员更有机会参与每年定期举办的游艇、别墅、海岛等大型线下趴。您可以在聚会中结交好友，认识同道中人，撩拨美女，或是展开一段美妙的恋情。不过，party最重要的，还是要嗨翻天！'),
                          containerWidget(
                              image: '3',
                              title: '私人定制：',
                              content:
                                  '我们认为只有人，才更了解人。茶馆专业的团队直接对接您的高度私人化、定制化的需求，为您量身定制，选择最合适的人，满足您一切需要她的场合：陪逛街，陪出游，陪旅行，陪宴会，陪酒会，陪应酬，陪PARTY......\n只要您想，温柔美丽大方的她，会陪您渡过每一天，每一夜。'),
                          SizedBox(height: 30.w),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 29.5.w),
                            child: LocalPNG(
                              url: 'assets/images/tzyh/fangfa.png',
                              height: 49.w,
                              fit: BoxFit.fitHeight,
                            ),
                          ),
                          SizedBox(
                            height: 20.w,
                          ),
                          Container(
                            height: 70.w,
                            margin: EdgeInsets.symmetric(
                                vertical: 20.w, horizontal: 30.w),
                            child: Stack(
                              children: [
                                LocalPNG(
                                    width: double.infinity,
                                    height: 70.w,
                                    url: 'assets/images/tzyh/tzyh_banner.png',
                                    fit: BoxFit.fill),
                                Container(
                                  height: 70.w,
                                  padding: EdgeInsets.only(
                                      left: 84.5.w, right: 10.w, top: 15.w),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          LocalPNG(
                                            url:
                                                'assets/images/tzyh/tzyh_text.png',
                                            height: 20.w,
                                            fit: BoxFit.fitHeight,
                                          ),
                                          Text(
                                            '俱乐部入会费' +
                                                profileDatas!['club_price']
                                                    .toString() +
                                                '元',
                                            style: TextStyle(
                                                fontSize: 12.sp,
                                                color: Colors.white),
                                          )
                                        ],
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          if (money <
                                              profileDatas['club_price']) {
                                            CgDialog.cgShowDialog(
                                                context,
                                                '提示',
                                                '元宝不足，请先充值！',
                                                ['去充值'], callBack: () {
                                              AppGlobal.appRouter?.push(
                                                  CommonUtils.getRealHash(
                                                      'ingotWallet'));
                                            });
                                          } else {
                                            join();
                                          }
                                        },
                                        behavior: HitTestBehavior.translucent,
                                        child: LocalPNG(
                                          url: 'assets/images/tzyh/ruhui.png',
                                          height: 30.w,
                                          fit: BoxFit.fitHeight,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 30.w),
                            child: Text(
                              '只需缴纳一次性俱乐部入会费即可，无任何后续消费内容：入会后会有专职客服接待您，进行身份确认与后续手续办理',
                              style: TextStyle(
                                  color: Color(0xffdeb682), fontSize: 12.sp),
                            ),
                          )
                        ],
                      )
              ],
            ),
          ),
          Positioned(
              top: ScreenUtil().statusBarHeight,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15.w),
                height: 44.w,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: LocalPNG(
                        url: 'assets/images/tzyh/back.png',
                        width: 20.w,
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                    Container()
                  ],
                ),
              ))
        ],
      ),
    ));
  }

  containerWidget({String? image, String? title, String? content}) {
    return Container(
      margin: EdgeInsets.only(bottom: 19.5.sp),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LocalPNG(
            url: 'assets/images/tzyh/banner_$image.png',
            width: double.infinity,
            fit: BoxFit.fitWidth,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 30.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 19.5.sp),
                  child: Text(
                    title!,
                    style: TextStyle(
                        color: Color(0xffffbf75),
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                Text(
                  content!,
                  style: TextStyle(color: Color(0xffdeb682), fontSize: 12.sp),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
