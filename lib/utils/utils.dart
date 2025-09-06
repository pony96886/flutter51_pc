// ignore_for_file: prefer_function_declarations_over_variables, prefer_final_fields

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:bot_toast/bot_toast.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:common_utils/common_utils.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:universal_html/html.dart' as html;

class Utils {
  //随机字符串
  static String randomId(int range) {
    String str = "";
    List<String> arr = [
      "0",
      "1",
      "2",
      "3",
      "4",
      "5",
      "6",
      "7",
      "8",
      "9",
      "a",
      "b",
      "c",
      "d",
      "e",
      "f",
      "g",
      "h",
      "i",
      "j",
      "k",
      "l",
      "m",
      "n",
      "o",
      "p",
      "q",
      "r",
      "s",
      "t",
      "u",
      "v",
      "w",
      "x",
      "y",
      "z",
      "A",
      "B",
      "C",
      "D",
      "E",
      "F",
      "G",
      "H",
      "I",
      "J",
      "K",
      "L",
      "M",
      "N",
      "O",
      "P",
      "Q",
      "R",
      "S",
      "T",
      "U",
      "V",
      "W",
      "X",
      "Y",
      "Z"
    ];
    for (int i = 0; i < range; i++) {
      int pos = Random().nextInt(arr.length - 1);
      str += arr[pos];
    }
    return str;
  }
}
