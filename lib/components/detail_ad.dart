import 'package:card_swiper/card_swiper.dart';
import 'package:chaguaner2023/store/homeConfig.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/netimage_tool.dart';
import 'package:chaguaner2023/utils/pageviewmixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:bot_toast/bot_toast.dart';

class Detail_ad extends StatelessWidget {
  final List? data;
  final double? width;
  final double? height;
  final double? radius;
  final bool app_layout;
  Detail_ad(
      {Key? key,
      this.data,
      this.height,
      this.width,
      this.radius = 0,
      this.app_layout = false});
  @override
  Widget build(BuildContext context) {
    if (data!.length == 0) {
      return SizedBox();
    }
    if (app_layout) {
      var pagelist = CommonUtils.chunkList(data!, 10);
      return SizedBox(
          width: double.infinity,
          height: height != null ? height : 175.w,
          child: Swiper(
            loop: pagelist.length > 1,
            itemCount: pagelist.length,
            itemBuilder: (BuildContext context, int index) {
              final pageBanners = pagelist[index];
              return LayoutBuilder(
                builder: (context, constraints) {
                  return SizedBox(
                    height: constraints.maxHeight,
                    child: GridView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: pageBanners.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 0.8,
                        ),
                        itemBuilder: (context, i) {
                          return GestureDetector(
                            onTap: () {
                              var members = Provider.of<HomeConfig>(context,
                                      listen: false)
                                  .member;
                              var aff = members.aff;
                              var chaid = members.uuid;
                              var _adsUrl = pageBanners[i]["url"];
                              var type = pageBanners[i]["type"];
                              if (['', null, false].contains(_adsUrl)) {
                                BotToast.showText(
                                    text: '未配置跳转链接', align: Alignment(0, 0));
                                return;
                              }
                              switch (type) {
                                case 1:
                                  // 内部路由
                                  AppGlobal.appRouter?.push(
                                      CommonUtils.getRealHash('$_adsUrl'));
                                  break;
                                case 2:
                                  // WebViewPage
                                  var urls = '$_adsUrl?aff=$aff&chaid=$chaid';
                                  AppGlobal.appRouter?.push(CommonUtils.getRealHash(
                                      'activityPage/${Uri.encodeComponent(urls)}'));

                                  break;
                                case 3:
                                  // 外部浏览器
                                  CommonUtils.launchURL(
                                      "$_adsUrl?aff=$aff&chaid=$chaid");
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
                            },
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(5.w),
                                  child: SizedBox(
                                    width: 55.w,
                                    height: 55.w,
                                    child: NetImageTool(
                                      url: pageBanners[i]["img_url"] ?? "",
                                    ),
                                  ),
                                ),
                                SizedBox(height: 5.w),
                                Text(
                                  pageBanners[i]['title'] ?? '',
                                  style: TextStyle(fontSize: 12.sp),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          );
                        }),
                  );
                },
              );
            },
          ));
    }
    return SizedBox(
      width: width != null ? width : 1.sw,
      height: height != null ? height : 1.sw * 0.24,
      child: Swiper(
          onTap: (index) {
            var members =
                Provider.of<HomeConfig>(context, listen: false).member;
            var aff = members.aff;
            var chaid = members.uuid;
            var _adsUrl = data![index]["url"];
            var type = data![index]["type"];
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
                var urls = '$_adsUrl?aff=$aff&chaid=$chaid';
                AppGlobal.appRouter?.push(CommonUtils.getRealHash(
                    'activityPage/${Uri.encodeComponent(urls)}'));

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
          },
          itemWidth: width != null ? width : 1.sw,
          itemHeight: height != null ? height : 1.sw * 0.24,
          itemBuilder: (BuildContext context, int index) {
            return PageViewMixin(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(radius!),
                    child: SizedBox(
                      width: width != null ? width : 1.sw,
                      height: height != null ? height : 1.sw * 0.24,
                      child: NetImageTool(
                        url: data![index]["img_url"] ?? "",
                      ),
                    ),
                  ),
                  Positioned(
                      right: 22.w,
                      bottom: 20.w,
                      child: data![index]["is_ads"] == 1
                          ? Image.asset(
                              'assets/images/cg_320/icon_gg.png',
                              width: 74.w,
                              fit: BoxFit.fitWidth,
                            )
                          : Container())
                ],
              ),
            );
          },
          itemCount: data!.length,
          autoplay: data!.length > 1,
          pagination: data!.length > 1
              ? SwiperCustomPagination(
                  builder: (BuildContext context, SwiperPluginConfig config) {
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
                })
              : null),
    );
  }
}
