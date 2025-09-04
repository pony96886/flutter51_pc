import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/pagetitlebar.dart';
import 'package:chaguaner2023/utils/pageviewmixin.dart';
import 'package:chaguaner2023/view/cooperate/IntentionSheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class XiaoerOser extends StatefulWidget {
  XiaoerOser({Key? key}) : super(key: key);

  @override
  _XiaoerOserState createState() => _XiaoerOserState();
}

class _XiaoerOserState extends State<XiaoerOser> {
  @override
  Widget build(BuildContext context) {
    return HeaderContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
            child: PageTitleBar(
              title: '茶小二抢单',
            ),
            preferredSize: Size(double.infinity, 44.w)),
        body: PageViewMixin(
          child: IntentionSheetPage(),
        ),
      ),
    );
  }
}
