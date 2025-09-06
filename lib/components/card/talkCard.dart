import 'package:chaguaner2023/store/homeConfig.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:chaguaner2023/utils/netimage_tool.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../utils/cache/image_net_tool.dart';

class TalkCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool shareIcon;

  const TalkCard({
    Key? key,
    required this.item,
    this.shareIcon = true,
  });

  String _formatTs(int seconds) {
    final dt = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
    return DateFormat('yyyy-MM-dd HH:mm').format(dt);
  }

  String _imgBase(BuildContext context) =>
      Provider.of<HomeConfig>(context, listen: false).config.imgBase ?? '';
  String get idStr => (item['id'] ?? '').toString();
  String get title => (item['title'] ?? '').toString();
  String get image => (item['image'] ?? '').toString();
  int get createdAtSec =>
      int.tryParse(item['created_at']?.toString() ?? '') ?? 0;

  int get viewCount => int.tryParse(item['view_count']?.toString() ?? '') ?? 0;
  int get commentCount =>
      int.tryParse(item['comment_count']?.toString() ?? '') ?? 0;
  int get favoriteCount =>
      int.tryParse(item['favorite_count']?.toString() ?? '') ?? 0;

  List get media => (item['media'] as List?) ?? const [];

  bool get hasVideo {
    try {
      return media.any((e) {
        if (e is Map) {
          final type = e['type'];
          if (type is int) return type == 1;
          if (type is String) return int.tryParse(type) == 1;
        }
        return false;
      });
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            AppGlobal.appRouter?.push(
              CommonUtils.getRealHash('tackDetailPage/$idStr'),
            );
          },
          child: Container(
            width: double.infinity,
            margin: EdgeInsets.all(10.w),
            padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 15.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.w),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  offset: Offset(0, 0.5.w),
                  blurRadius: 2.5.w,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                SizedBox(height: 10.w),
                Container(
                  width: double.infinity,
                  height: 180.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.w),
                  ),
                  child: Stack(
                    children: [
                      ImageNetTool(
                        url: _composeImgUrl(_imgBase(context), image),
                        fit: BoxFit.cover,
                        radius: BorderRadius.circular(5.w),
                      ),
                      if (hasVideo)
                        Positioned.fill(
                          child: Container(
                            color: Colors.black26,
                            child: Center(
                              child: LocalPNG(
                                url: 'assets/images/detail/play-icon.png',
                                width: 30.w,
                                height: 30.w,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (createdAtSec > 0)
                  Padding(
                    padding: EdgeInsets.only(top: 10.w),
                    child: Text(
                      _formatTs(createdAtSec),
                      style: TextStyle(
                          color: const Color(0xff464646), fontSize: 12.sp),
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 5.w),
                  child: const BottomLine(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconAndText(
                      icons: 'assets/images/detail/view.png',
                      text: viewCount.toString(),
                      onTap: () {},
                    ),
                    IconAndText(
                      icons: 'assets/images/detail/comment.png',
                      text: commentCount.toString(),
                      onTap: () {},
                    ),
                    IconAndText(
                      icons: 'assets/images/detail/collo.png',
                      text: favoriteCount.toString(),
                      onTap: () {},
                    ),
                    Visibility(
                      visible: shareIcon,
                      child: IconAndText(
                        icons: 'assets/images/detail/share.png',
                        text: '分享',
                        onTap: () {
                          AppGlobal.appRouter?.push(
                              CommonUtils.getRealHash('shareQRCodePage'));
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static String _composeImgUrl(String base, String path) {
    if (path.isEmpty) return path;
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    if (base.isEmpty) return path;
    if (base.endsWith('/') && path.startsWith('/')) {
      return base + path.substring(1);
    }
    if (!base.endsWith('/') && !path.startsWith('/')) {
      return '$base/$path';
    }
    return base + path;
  }
}

class BottomLine extends StatelessWidget {
  const BottomLine({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(
        top: 10.w,
        bottom: 10.w,
      ),
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

class IconAndText extends StatelessWidget {
  final String icons;
  final String text;
  final void Function()? onTap;
  const IconAndText(
      {Key? key, required this.icons, required this.text, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            icons,
            height: 15.w,
          ),
          SizedBox(width: 5.w),
          Text(
            text,
            style: TextStyle(color: Color(0xff1e1e1e), fontSize: 12.sp),
          ),
        ],
      ),
    );
  }
}
