import 'package:chaguaner2023/utils/local_png.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Avatar extends StatelessWidget {
  final double? radius;
  final String? type;
  final VoidCallback? onPress;

  Avatar({this.radius = 5, this.type, this.onPress});

  @override
  Widget build(BuildContext context) {
    var path;
    var viplevel;
    if (['', null, false].contains(type)) {
      path = 1;
    } else {
      if (type!.contains(',')) {
        List<String> typeList = type!.split(',');
        path = typeList[0];
        viplevel = typeList[1];
      } else {
        path = type;
      }
    }
    return GestureDetector(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius!),
        child: Container(
          decoration: BoxDecoration(color: Color(0xFFF5F5F5)),
          child: Stack(
            children: <Widget>[
              Container(
                  padding:
                      viplevel == "4" ? EdgeInsets.all(5.w) : EdgeInsets.zero,
                  child: LocalPNG(
                    url: 'assets/images/common/$path.png',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  )),
              viplevel == "4"
                  ? LocalPNG(
                      url: 'assets/images/common/vip5.png',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    )
                  : SizedBox()
            ],
          ),
        ),
      ),
      onTap: onPress,
    );
  }
}
