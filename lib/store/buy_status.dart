import 'package:flutter/material.dart';

class VideoStatus {
  VideoStatus({this.isBuy, this.isSubscription, this.type});
  int? isBuy; //购买
  int? isSubscription; //订阅
  int? type; //1 帖子操作(购买)   2 用户操作（如关注,订阅） type区分防止帖子id跟用户id重复
}

class ArticleStatus extends ChangeNotifier {
  final Map<int, VideoStatus> userOperation = {};

  init() {
    userOperation.clear();
    notifyListeners();
  }

// id 帖子iD || 用户 aff    type用来区分是帖子还是用户
  void setVideoStatus(int id, VideoStatus status) {
    if (userOperation[id] == null) {
      userOperation[id] = status;
    } else {
      userOperation[id] = VideoStatus(
        type: userOperation[id]!.type != status.type
            ? status.type
            : userOperation[id]!.type,
        isBuy: userOperation[id]!.isBuy != status.isBuy
            ? status.isBuy
            : userOperation[id]!.isBuy,
        isSubscription:
            userOperation[id]!.isSubscription != status.isSubscription
                ? status.isSubscription
                : userOperation[id]!.isSubscription,
      );
    }
    notifyListeners();
  }
}
