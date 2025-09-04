import 'package:chaguaner2023/utils/local_png.dart';
import 'package:flutter/material.dart';

class HeaderContainer extends StatefulWidget {
  final String? image;
  final Widget? child;
  final BoxFit fit;
  HeaderContainer({Key? key, this.child, this.image, this.fit = BoxFit.cover})
      : super(key: key);
  @override
  _HeaderContainerState createState() => _HeaderContainerState();
}

class _HeaderContainerState extends State<HeaderContainer> {
  String containeSrea = "assets/images/container-bg-1.png";
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.white,
          child: Stack(
            children: [
              LocalPNG(
                width: double.infinity,
                url: widget.image == null
                    ? containeSrea
                    : widget.image as String,
                fit: widget.fit,
                alignment: Alignment.topCenter,
              ),
              widget.child!
            ],
          )),
    );
  }
}
