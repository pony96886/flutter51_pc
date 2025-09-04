import 'dart:convert';
import 'dart:typed_data';
import 'package:chaguaner2023/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ImageCode extends StatefulWidget {
  ImageCode({Key? key}) : super(key: key);

  @override
  _ImageCodeState createState() => _ImageCodeState();
}

class _ImageCodeState extends State<ImageCode> {
  Uint8List? imageCode;
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    getImageCode();
  }

  getImageCode() {
    setState(() {
      isLoading = true;
    });
    getImgCaptcha().then((res) {
      if (res!['status'] != 0) {
        imageCode =
            Base64Decoder().convert(res['data']['captcha_pic'].split(',')[1]);
        isLoading = false;
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 44.w,
        child: isLoading
            ? Center(
                child: Text(
                  '正在加载图形码',
                  style: TextStyle(color: Color(0xff808080), fontSize: 14.w),
                ),
              )
            : GestureDetector(
                onTap: getImageCode,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                        child: Image.memory(
                      imageCode!,
                      fit: BoxFit.fitWidth,
                    )),
                    SizedBox(
                      width: 18.w,
                    ),
                    Text(
                      '点击刷新图片',
                      style:
                          TextStyle(color: Color(0xff808080), fontSize: 14.sp),
                    )
                  ],
                ),
              ));
  }
}
