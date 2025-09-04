import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CardCountdown extends StatefulWidget {
  final dynamic timer;
  CardCountdown({Key? key, this.timer}) : super(key: key);

  @override
  _CardCountdownState createState() => _CardCountdownState();
}

class _CardCountdownState extends State<CardCountdown> {
  Timer? _timer;
  bool? isExpired;
  setTime(int t) {
    return '0$t';
  }

  String countTime = '000:00';
  @override
  void initState() {
    super.initState();
    var curTime = new DateTime.now().millisecondsSinceEpoch;
    var timeDiff = (widget.timer * 1000 - curTime) / 1000;
    var minute = timeDiff ~/ 60;
    setState(() {
      isExpired = (widget.timer * 1000 - curTime) <= 0; //意向单是否已过期
      countTime = minute.toString();
    });
    // startCardCountdownTimer();
  }

  getTime() {
    if (int.parse(countTime) > 60) {
      dynamic hours = (int.parse(countTime) / 60).floor();
      return '$hours小时后失效';
    } else {
      dynamic minite = int.parse(countTime);
      return '$minite分钟后失效';
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (_timer!.isActive) {
      _timer!.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Text(
        isExpired! ? '已失效' : getTime(),
        style: TextStyle(fontSize: 10.sp, color: Colors.white),
      ),
    );
  }
}
