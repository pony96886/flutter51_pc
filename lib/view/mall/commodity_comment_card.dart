import 'package:chaguaner2023/components/datetime/src/date_format.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CommodityCommentCard extends StatefulWidget {
  const CommodityCommentCard({Key? key, this.data}) : super(key: key);
  final Map? data;

  @override
  State<CommodityCommentCard> createState() => _CommodityCommentCardState();
}

class _CommodityCommentCardState extends State<CommodityCommentCard> {
  int likeNum = 0;
  bool liked = false;
  bool isTap = false;
  getTime() {
    DateTime dateTime = DateTime.parse(widget.data!['created_at']);

    // 获取日期部分并格式化
    String formattedDate =
        "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
    return formattedDate;
  }

  @override
  void initState() {
    super.initState();
    likeNum = widget.data!['like_num'];
    liked = widget.data!['liked'];
  }

  onLike() {
    if (isTap) {
      CommonUtils.showText('请勿频繁操作');
      return;
    }
    isTap = true;
    liked = !liked;
    if (liked) {
      likeNum++;
    } else {
      likeNum--;
    }
    setState(() {});
    favoriteToggle(widget.data!['id'], 2).then((res) {
      if (res!['status'] == 0) {
        liked = !liked;
        if (liked) {
          likeNum++;
        } else {
          likeNum--;
        }
        setState(() {});
      } else {
        CommonUtils.showText(res['msg'] == null || res['msg'] == ''
            ? (liked ? '点赞成功' : '取消点赞成功')
            : res['msg']);
      }
    }).whenComplete(() {
      isTap = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Map? user = widget.data!['user'];
    if (user == null) {
      return Container();
    }
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20.w),
                child: SizedBox(
                  width: 40.w,
                  height: 40.w,
                  child: LocalPNG(
                    width: double.infinity,
                    height: double.infinity,
                    url: 'assets/images/common/${user['thumb']}.png',
                  ),
                ),
              ),
              SizedBox(
                width: 10.w,
              ),
              Expanded(
                  child: SizedBox(
                height: 40.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user['nickname'],
                      style:
                          TextStyle(color: Color(0XFF1e1e1e), fontSize: 16.sp),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                      Text(getTime(),
                        style: TextStyle(
                            color: Color(0XFFb4b4b4), fontSize: 12.sp)),
                            if (widget.data!['time_str'] != null && widget.data!['time_str'].trim().isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(left: 6.w),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                alignment: Alignment.center,
                                height: 13.w,
                                padding: EdgeInsets.symmetric(horizontal: 6.w),
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                        colors: [Color.fromRGBO(255, 144, 0, 1), Color.fromRGBO(255, 194, 30, 1)]),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(6.5.w),
                                      bottomLeft: Radius.circular(6.5.w),
                                      bottomRight: Radius.circular(6.5.w),
                                    )),
                                child: Text(
                                  "${widget.data!['time_str']}",
                                  style: TextStyle(color: Color.fromRGBO(248, 253, 255, 1), fontSize: 8.sp),
                                ),
                              )
                            ],
                          ),
                        ),
                    ],)
                  ],
                ),
              )),
              SizedBox(
                width: 10.w,
              ),
              GestureDetector(
                onTap: onLike,
                behavior: HitTestBehavior.translucent,
                child: Column(
                  children: [
                    LocalPNG(
                      url:
                          'assets/images/${liked ? 'icon_like' : 'icon_unlike'}.png',
                      width: 17.5.w,
                      fit: BoxFit.fitWidth,
                    ),
                    SizedBox(
                      height: 5.w,
                    ),
                    Text(likeNum.toString(),
                        style: TextStyle(
                            color:
                                liked ? Color(0XFFff4149) : Color(0xffb4b4b4),
                            fontSize: 12.sp))
                  ],
                ),
              )
            ],
          ),
          Padding(
            padding: EdgeInsets.only(left: 50.7.w, top: 0.w, bottom: 16.w),
            child: Text(
              widget.data!['content'],
              style: TextStyle(color: Color(0xff1e1e1e), fontSize: 14.sp),
            ),
          )
        ],
      ),
    );
  }
}
