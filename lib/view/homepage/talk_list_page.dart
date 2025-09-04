import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:chaguaner2023/components/list/public_list.dart';
import 'package:chaguaner2023/components/nodata.dart';
import 'package:chaguaner2023/store/homeConfig.dart';
import 'package:chaguaner2023/components/card/talkCard.dart';


class TalkDataListPage extends StatefulWidget {
  final int? id;
  const TalkDataListPage({Key? key, this.id}) : super(key: key);

  @override
  State<TalkDataListPage> createState() => _TalkDataListPageState();
}

class _TalkDataListPageState extends State<TalkDataListPage> {
  late final DateFormat _fmt = DateFormat('yyyy-MM-dd HH:mm');
  String get _imgBase => context.read<HomeConfig>().config.imgBase ?? '';
  String _formatTs(int seconds) {
    final dt = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
    return _fmt.format(dt);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PublicList(
        api: '/api/talk/list',
        noController: true,
        data: {
          "cate_id": widget.id,
        },
        isShow: true,
        noData: NoData(
          text: '还没有茶谈哦～',
        ),
        itemBuild: (context, index, data, page, limit, getListData) {
          return TalkCard(item: data);
        });
  }
}

class BottomLine extends StatelessWidget {
  const BottomLine({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
