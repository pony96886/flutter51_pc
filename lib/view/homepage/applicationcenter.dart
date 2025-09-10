import 'package:bot_toast/bot_toast.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/loading.dart';
import 'package:chaguaner2023/components/page_title_bar.dart';
import 'package:chaguaner2023/components/starrating.dart';
import 'package:chaguaner2023/store/homeConfig.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/netimage_tool.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../utils/cache/image_net_tool.dart';

class ApplicationCenter extends StatefulWidget {
  ApplicationCenter({Key? key}) : super(key: key);

  @override
  _ApplicationCenterState createState() => _ApplicationCenterState();
}

class _ApplicationCenterState extends State<ApplicationCenter> {
  bool isLoadding = true;
  List bannerAd = [];
  List appList = [];

  @override
  void initState() {
    super.initState();
    initApplicationData();
  }

  initApplicationData() async {
    var result = await getApplicationCenter();
    if (result != null && result['data'] != null) {
      setState(() {
        isLoadding = false;
        bannerAd = result['data']['banner'];
        appList = result['data']['apps'];
      });
    }
  }

  Widget applicationColumn() {
    List<Widget> tiles = [];
    Widget content;
    for (int i = 0; i < appList.length; i++) {
      tiles.add(
        ApplicationItem(
          id: appList[i]['id'],
          appname: appList[i]['title'],
          iconurl: appList[i]['img_url'],
          des: appList[i]['description'],
          clicked: appList[i]['clicked'],
          link: appList[i]['link_url'],
        ),
      );
    }
    if (appList.length == 0) {
      tiles.add(Container(
        color: Color(0xFFEEEEEE),
        margin: EdgeInsets.only(top: 10.w),
        padding: EdgeInsets.all(20.w),
        child: Center(
          child: Text(
            '应用列表为空',
            style: TextStyle(color: StyleTheme.cBioColor),
          ),
        ),
      ));
    }
    content = new Column(
      children: tiles,
    );
    return content;
  }

  @override
  Widget build(BuildContext context) {
    return HeaderContainer(
        child: Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
          child: PageTitleBar(
            title: '应用中心',
          ),
          preferredSize: Size(double.infinity, 44.w)),
      body: isLoadding
          ? Loading()
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwiperContainer(
                    banner: bannerAd,
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 20.w),
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Text(
                      "宅男福利APP推荐",
                      style:
                          TextStyle(color: Color(0xFF1E1E1E), fontSize: 15.w),
                    ),
                  ),
                  applicationColumn()
                ],
              ),
            ),
    ));
  }
}

class ApplicationItem extends StatefulWidget {
  final int? id;
  final String? appname;
  final String? iconurl;
  final String? des;
  final int? clicked;
  final String? link;
  ApplicationItem(
      {Key? key,
      this.appname,
      this.iconurl,
      this.des,
      this.link,
      this.clicked,
      this.id})
      : super(key: key);

  @override
  _ApplicationItemState createState() => _ApplicationItemState();
}

class _ApplicationItemState extends State<ApplicationItem> {
  dynamic clickNumber;

  renderFixedNumber(num value) {
    var tips;
    if (value >= 10000) {
      var newvalue = (value / 1000) / 10.round();
      tips = formatNum(newvalue, 2) + "万";
    } else if (value >= 1000) {
      var newvalue = (value / 100) / 10.round();
      tips = formatNum(newvalue, 2) + "千";
    } else {
      tips = value.toString();
    }
    return tips;
  }

  formatNum(double number, int postion) {
    if ((number.toString().length - number.toString().lastIndexOf(".") - 1) <
        postion) {
      //小数点后有几位小数
      return number
          .toStringAsFixed(postion)
          .substring(0, number.toString().lastIndexOf(".") + postion + 1)
          .toString();
    } else {
      return number
          .toString()
          .substring(0, number.toString().lastIndexOf(".") + postion + 1)
          .toString();
    }
  }

  @override
  void initState() {
    super.initState();
    clickNumber = renderFixedNumber(widget.clicked! * 1.0);
  }

  _onTapSwiper() {
    var _adsUrl = widget.link;
    if (['', null, false].contains(_adsUrl)) {
      BotToast.showText(text: '未配置跳转链接', align: Alignment(0, 0));
      return;
    }
    CommonUtils.launchURL(_adsUrl!);
    // 外部浏览器
    appClick(widget.id!);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _onTapSwiper();
      },
      behavior: HitTestBehavior.translucent,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        child: Row(
          children: [
            Container(
              width: 55.w,
              height: 55.w,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(14.5.w))),
              child: ImageNetTool(
                url: (widget.iconurl!.contains('http')
                    ? widget.iconurl
                    : AppGlobal.bannerImgBase + widget.iconurl!) as String,
                fit: BoxFit.fitWidth,
              ),
            ),
            Expanded(
                child: Container(
              margin: EdgeInsets.only(left: 10.w),
              padding: EdgeInsets.symmetric(vertical: 15.w),
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          width: 0.5, color: StyleTheme.textbgColor1))),
              child: Row(
                children: [
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.appname!,
                        style: TextStyle(
                            color: Color(0xFF1E1E1E), fontSize: 16.sp),
                      ),
                      Row(
                        children: [
                          StarRating(
                            rating: 5,
                            disable: true,
                            size: 5.sp,
                            spacing: 5.sp,
                          ),
                          SizedBox(width: 10.5.w),
                          Text("$clickNumber人下载",
                              style: TextStyle(
                                  color: Color(0xFFB4B4B4), fontSize: 12.sp))
                        ],
                      ),
                      SizedBox(height: 1.5.w),
                      Text('${widget.des}',
                          style: TextStyle(
                              color: Color(0xFF969696), fontSize: 12.sp))
                    ],
                  )),
                  Container(
                    width: 55.w,
                    padding: EdgeInsets.symmetric(
                        vertical: 2.5.w, horizontal: 7.5.w),
                    decoration: BoxDecoration(
                        color: Color(0xFFFF4149),
                        borderRadius: BorderRadius.all(Radius.circular(25))),
                    child: Text(
                      '下载',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 14.sp),
                    ),
                  )
                ],
              ),
            ))
          ],
        ),
      ),
    );
  }
}

class SwiperContainer extends StatefulWidget {
  final List? banner;
  SwiperContainer({Key? key, this.banner}) : super(key: key);

  @override
  _SwiperContainerState createState() => _SwiperContainerState();
}

class _SwiperContainerState extends State<SwiperContainer> {
  List _banner = [];
  @override
  void initState() {
    super.initState();
    _banner = widget.banner!;
  }

  _onTapSwiper(int index) {
    if (_banner.length == 0) return;
    var item = _banner[index];
    var members = Provider.of<HomeConfig>(context, listen: false).member;
    var aff = members.aff;
    var chaid = members.uuid;
    var type = item['type'];
    var _adsUrl = item['link'] ?? item['url'];
    if (['', null, false].contains(_adsUrl)) {
      BotToast.showText(text: '未配置跳转链接', align: Alignment(0, 0));
      return;
    }
    switch (type) {
      case 1:
        // 内部路由
        AppGlobal.appRouter?.push(CommonUtils.getRealHash('$_adsUrl'));
        break;
      case 2:
        // WebViewPage
        var _url = '$_adsUrl?aff=$aff&chaid=$chaid';
        AppGlobal.appRouter?.push(CommonUtils.getRealHash(
            'activityPage/${Uri.encodeComponent(_url)}'));
        break;
      case 3:
        // 外部浏览器
        CommonUtils.launchURL("$_adsUrl?aff=$aff&chaid=$chaid");
        break;
      case 4:
        // 外部浏览器
        CommonUtils.launchURL("$_adsUrl");
        break;
      case 5:
        // WebViewPage
        AppGlobal.appRouter?.push(CommonUtils.getRealHash(
            'activityPage/${Uri.encodeComponent(_adsUrl)}'));
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _banner.length > 1
          ? SizedBox(
              height: 150.w,
              child: Swiper(
                  onTap: (index) {
                    _onTapSwiper(index);
                  },
                  itemBuilder: (BuildContext context, int index) {
                    return ImageNetTool(
                      url: _banner[index]['img_url'].contains('http')
                          ? _banner[index]['img_url']
                          : AppGlobal.bannerImgBase + _banner[index]['img_url'],
                      fit: BoxFit.fitWidth,
                    );
                  },
                  itemCount: _banner.length,
                  autoplay: _banner.length > 1,
                  pagination: new SwiperCustomPagination(builder:
                      (BuildContext context, SwiperPluginConfig config) {
                    List<Widget> list = [];
                    int itemCount = config.itemCount;
                    int activeIndex = config.activeIndex;

                    for (int i = 0; i < itemCount; ++i) {
                      bool active = i == activeIndex;
                      list.add(Container(
                        key: Key("pagination_$i"),
                        margin: EdgeInsets.all(3.0),
                        child: ClipOval(
                          child: Container(
                            color: active
                                ? Colors.white
                                : Color.fromRGBO(255, 255, 255, 0.5),
                            width: 7.w,
                            height: 7.w,
                          ),
                        ),
                      ));
                    }
                    return Align(
                      alignment: Alignment.bottomCenter,
                      child: new Row(
                        mainAxisSize: MainAxisSize.min,
                        children: list,
                      ),
                    );
                  })),
            )
          : Container(
              width: double.infinity,
              height: _banner.length == 1 ? 150.w : 0,
              child: _banner.length == 1
                  ? ImageNetTool(
                      url: _banner[0]['img_url'].contains('http')
                          ? _banner[0]['img_url']
                          : AppGlobal.bannerImgBase + _banner[0]['img_url'],
                      fit: BoxFit.fitWidth,
                    )
                  : SizedBox(),
            ),
    );
  }
}
