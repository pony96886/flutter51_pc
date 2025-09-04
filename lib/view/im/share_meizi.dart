import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/view/cooperate/meizi_mange.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ShareMeiziPage extends StatefulWidget {
  ShareMeiziPage({Key? key}) : super(key: key);

  @override
  _ShareMeiziPageState createState() => _ShareMeiziPageState();
}

class _ShareMeiziPageState extends State<ShareMeiziPage> {
  @override
  @override
  Widget build(BuildContext context) {
    return HeaderContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: StyleTheme.cTitleColor,
          ),
          title: Text(
            '分享妹子',
            style: TextStyle(
                color: StyleTheme.cTitleColor,
                fontSize: 18.sp,
                fontWeight: FontWeight.w500),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
        body: Container(
            width: double.infinity,
            height: double.infinity,
            child: MeiziManage(
              isShare: true,
            )),
      ),
    );
  }
}
