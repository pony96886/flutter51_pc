import 'package:chaguaner2023/components/cgDialog.dart';
import 'package:chaguaner2023/components/page_status.dart';
import 'package:chaguaner2023/components/upload/start_upload.dart';
import 'package:chaguaner2023/components/upload/upload_resouce.dart';
import 'package:chaguaner2023/input/InputDailog.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:chaguaner2023/utils/netimage_tool.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class MallOrderCard extends StatefulWidget {
  const MallOrderCard(
      {Key? key, this.isEvaluation = false, this.data, this.isEller = false});
  final bool? isEvaluation;
  final bool? isEller; //是否是商家
  final Map? data;
  @override
  State<MallOrderCard> createState() => _MallOrderCardState();
}

class _MallOrderCardState extends State<MallOrderCard> {
  int status = 0;
  bool isTap = false;
  TextEditingController content = TextEditingController();
  getTime() {
    DateTime dateTime = DateTime.parse(widget.data!['created_at']);
    // 获取日期部分并格式化
    String formattedDate =
        "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
    return formattedDate;
  }

  updateStatus({List? pic}) {
    if (isTap) {
      CommonUtils.showText('请勿频繁操作');
      return;
    }
    isTap = true;
    int _status = status + 1;
    PageStatus.showLoading();
    updateOrderStatus(widget.data!['id'], _status, content.text, pic ?? [])
        .then((res) {
      if (res!['status'] != 0) {
        status = _status;
        content.text = '';
        setState(() {});
        CommonUtils.showText('订单状态已变更,下拉刷新查看');
      } else {
        CommonUtils.showText(res['msg'] ?? '操作失败');
      }
    }).whenComplete(() {
      isTap = false;
      PageStatus.closeLoading();
    });
  }

  Future showEdetOrdernumber() {
    return showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setBottomSheetState) {
            return Container(
              height: 295.5 + ScreenUtil().bottomBarHeight,
              padding: EdgeInsets.only(
                  bottom: ScreenUtil().bottomBarHeight + 32.w,
                  left: 15.w,
                  right: 15.w),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(5.w))),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 25.w, bottom: 5),
                    child: Text(
                      '填写单号',
                      style: TextStyle(
                          color: StyleTheme.cTitleColor, fontSize: 18.sp),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      child: GestureDetector(
                        onTap: () {
                          InputDialog.show(context, '填写单号：如申通1654114987465135',
                                  limitingText: 30)
                              .then((value) async {
                            content.text = (await value)!;
                            setBottomSheetState(() {});
                          });
                        },
                        child: Container(
                          alignment: Alignment.center,
                          height: 35.w,
                          decoration: BoxDecoration(
                              color: Color.fromRGBO(245, 245, 245, 1),
                              borderRadius: BorderRadius.circular(10.w)),
                          child: content.text.isEmpty
                              ? Text(
                                  "填写单号：如申通1654114987465135",
                                  style: TextStyle(
                                      color: Color.fromRGBO(180, 180, 180, 1),
                                      fontSize: 14.sp),
                                )
                              : Text(
                                  content.text,
                                  style: TextStyle(
                                      color: StyleTheme.cTitleColor,
                                      fontSize: 14.sp),
                                ),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (content.text.isEmpty) {
                        CommonUtils.showText('请填写快递单号');
                        return;
                      }
                      Navigator.pop(context);
                      updateStatus();
                    },
                    child: Stack(
                      children: [
                        LocalPNG(
                          width: 275.w,
                          height: 50.w,
                          url: 'assets/images/mymony/money-img.png',
                        ),
                        Positioned.fill(
                            child: Center(
                                child: Text(
                          '确认',
                          style: TextStyle(fontSize: 15.w, color: Colors.white),
                        ))),
                      ],
                    ),
                  ),
                ],
              ),
            );
          });
        });
  }

  Future showUploadImage() {
    return showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setBottomSheetState) {
            return Container(
              height: 440.5 + ScreenUtil().bottomBarHeight,
              padding: EdgeInsets.only(
                  bottom: ScreenUtil().bottomBarHeight + 32.w,
                  left: 15.w,
                  right: 15.w),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(5.w))),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 25.w, bottom: 5),
                    child: Text(
                      '上传图片',
                      style: TextStyle(
                          color: StyleTheme.cTitleColor, fontSize: 18.sp),
                    ),
                  ),
                  SizedBox(
                    height: 21.w,
                  ),
                  Expanded(
                      child: ListView(
                    padding: EdgeInsets.all(0),
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '详细描述',
                            style: TextStyle(
                                color: StyleTheme.cTitleColor, fontSize: 18.sp),
                          ),
                          Container(
                            margin: EdgeInsets.only(bottom: 20.w, top: 20.w),
                            height: 65.w,
                            padding: EdgeInsets.all(10.w),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.w),
                                color: Color(0xfff5f5f5)),
                            child: TextField(
                              maxLines: 999,
                              maxLength: 300,
                              controller: content,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (value) {
                                FocusManager.instance.primaryFocus?.unfocus();
                              },
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.zero,
                                hintText: '文字描述',
                                counterStyle: TextStyle(
                                    color: Color(0xffb4b4b4), fontSize: 15.sp),
                                hintStyle: TextStyle(
                                    color: Color(0xffb4b4b4), fontSize: 15.sp),
                                labelStyle: TextStyle(
                                    color: Color(0xff1e1e1e), fontSize: 15.sp),
                                border: InputBorder
                                    .none, // Removes the default border
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                '截图照片',
                                style: TextStyle(
                                    color: StyleTheme.cTitleColor,
                                    fontSize: 18.sp),
                              ),
                              Text(
                                '（不超过5张）',
                                style: TextStyle(
                                    color: StyleTheme.cDangerColor,
                                    fontSize: 12.sp),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20.w,
                          ),
                          UploadResouceWidget(
                            parmas: 'pic',
                            uploadType: 'image',
                            maxLength: 5,
                            initResouceList: [],
                          )
                        ],
                      )
                    ],
                  )),
                  GestureDetector(
                    onTap: () {
                      if (content.text.isEmpty) {
                        CommonUtils.showText('请填写描述');
                        return;
                      }
                      if (UploadFileList.allFile['pic']!.urls.length == 0) {
                        CommonUtils.showText('请上传截图照片');
                      } else {
                        StartUploadFile.upload().then((value) {
                          Navigator.pop(context);
                          if (value != null) {
                            List _img = value['pic'].map((e) {
                              return e['url'];
                            }).toList();
                            updateStatus(pic: _img);
                          } else {}
                        });
                      }
                    },
                    child: Stack(
                      children: [
                        LocalPNG(
                          width: 275.w,
                          height: 50.w,
                          url: 'assets/images/mymony/money-img.png',
                        ),
                        Positioned.fill(
                            child: Center(
                                child: Text(
                          '确认',
                          style: TextStyle(fontSize: 15.w, color: Colors.white),
                        ))),
                      ],
                    ),
                  ),
                ],
              ),
            );
          });
        });
  }

  _btn({bool isTap = true, String text = ''}) {
    return GestureDetector(
      onTap: () {
        if (widget.data!['status'] >= 2) return;
        if (widget.isEller!) {
          if (widget.data!['goods']['item_type'] == 1) {
            showEdetOrdernumber();
          } else if (widget.data!['goods']['item_type'] == 2) {
            showUploadImage();
          } else {
            showEdetOrdernumber();
          }
        } else {
          updateStatus();
        }

        // if (!isTap) return;
        // CgDialog.cgShowDialog(
        //     context, '提示', widget.isEller ? '是否确认发货?' : '是否确认收货?', ['取消', '确定'],
        //     callBack: () {
        //   updateStatus();
        // });
      },
      child: Stack(
        children: [
          Positioned.fill(
              child: LocalPNG(
            url: 'assets/images/shuimo_${isTap ? 'hei' : 'hui'}.png',
            fit: BoxFit.fill,
          )),
          Container(
            width: 123.5.w,
            height: 40.w,
            alignment: Alignment.center,
            child: Text(
              text,
              style: TextStyle(color: Colors.white, fontSize: 14.sp),
            ),
          )
        ],
      ),
    );
  }

  getBtnStatus() {
    //status 0 待发货 1 已发货 2 已收获 3 已评价
    if (widget.isEller!) {
      switch (status) {
        case 0:
          return _btn(isTap: true, text: '确认发货');
          break;
        case 1:
          return _btn(isTap: false, text: '已发货');
          break;
        case 2:
          return _btn(isTap: false, text: '已收货');
          break;
        case 3:
          return _btn(isTap: false, text: '已评价');
          break;
        default:
      }
    } else {
      switch (status) {
        case 0:
          return _btn(isTap: false, text: '待发货');
          break;
        case 1:
          return _btn(isTap: true, text: '确认收货');
          break;
        case 2:
          return _btn(isTap: false, text: '已收货');
          break;
        case 3:
          return _btn(isTap: false, text: '已收货');
          break;
        default:
      }
    }
  }

  @override
  void initState() {
    super.initState();
    status = widget.data!['status'];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 9.5.w, horizontal: 15.w),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.5.w),
      decoration: BoxDecoration(
          image: DecorationImage(
            image:
                AssetImage('assets/images/home/mallorderbg.png'), // 替换为你的图片路径
            fit: BoxFit.fill,
          ),
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
                color: Colors.black12,
                offset: Offset(0, 0.5.w),
                blurRadius: 2.5.w)
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.w),
                    child: SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: LocalPNG(
                        width: double.infinity,
                        height: double.infinity,
                        url:
                            'assets/images/common/${widget.data!['seller']['thumb']}.png',
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 7.6.w,
                  ),
                  Text(
                    widget.data!['seller']['nickname'],
                    style: TextStyle(color: Color(0xff1e1e1e), fontSize: 12.sp),
                  )
                ],
              ),
              Text.rich(
                TextSpan(
                    text: '价格：',
                    children: [
                      TextSpan(
                          text:
                              '${double.parse(widget.data!['amount']).toInt()}元宝',
                          style: TextStyle(
                            color: Color(0xffff4149),
                          )),
                    ],
                    style:
                        TextStyle(color: Color(0xffb4b4b4), fontSize: 12.sp)),
              )
            ],
          ),
          Container(
            height: 1.w,
            color: Color(0xffeeeeee),
            margin: EdgeInsets.only(top: 9.5.w, bottom: 11.w),
          ),
          GestureDetector(
            onTap: () {
              int _id = widget.data!['goods']['id'];
              if (_id == null) {
                CommonUtils.showText('商品已被下架');
                return;
              }
              AppGlobal.appRouter
                  ?.push(CommonUtils.getRealHash('commodityDetail/$_id'));
            },
            child: Row(
              children: [
                widget.data!['goods'] == null
                    ? SizedBox()
                    : SizedBox(
                        width: 80.2.w,
                        height: 80.2.w,
                        child: NetImageTool(
                          url: widget.data!['goods']['cover_images'][0]
                              ['media_url_full'],
                          radius: BorderRadius.circular(5.w),
                        ),
                      ),
                SizedBox(
                  width: 13.5.w,
                ),
                Expanded(
                    child: SizedBox(
                  height: 80.2.w,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.data!['goods'] == null
                              ? ''
                              : widget.data!['goods']['title'],
                          style: TextStyle(
                              color: Color(0xff1e1e1e),
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('下单时间：${getTime()}',
                                style: TextStyle(
                                  color: Color(0xffb4b4b4),
                                  fontSize: 12.sp,
                                )),
                            Text('x${widget.data!['qty']}',
                                style: TextStyle(
                                  color: Color(0xffb4b4b4),
                                  fontSize: 12.sp,
                                ))
                          ],
                        ),
                      ],
                    ),
                  ),
                ))
              ],
            ),
          ),
          widget.isEvaluation!
              ? SizedBox()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 1.w,
                      color: Color(0xffeeeeee),
                      margin: EdgeInsets.symmetric(vertical: 15.w),
                    ),
                    Text(
                      '联系方式: ${widget.data!['contact_info']}',
                      style:
                          TextStyle(color: Color(0xff1e1e1e), fontSize: 12.sp),
                    ),
                    SizedBox(
                      height: 10.w,
                    ),
                    Text('收货地址: ${widget.data!['shipping_address'].trim()}',
                        style: TextStyle(
                            color: Color(0xff1e1e1e), fontSize: 12.sp)),
                    SizedBox(
                      height: 10.w,
                    ),
                    Text(
                        '备注: ${widget.data!['remark'].length == 0 ? '无' : widget.data!['remark']}',
                        style: TextStyle(
                            color: Color(0xff1e1e1e), fontSize: 12.sp)),
                    widget.data!['shipping_remark'] != null &&
                            widget.data!['shipping_remark'].isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              if (widget.data!['goods']['item_type'] == 1) {
                                CgDialog.cgShowDialog(context, '订单详情',
                                    widget.data!['shipping_remark'], ['知道了']);
                              } else {
                                CgDialog.cgShowDialog(
                                    context, '订单详情', '', ['知道了'],
                                    width: 345,
                                    contentWidget: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 15.w),
                                          child: Text(
                                            '详细描述',
                                            style: TextStyle(
                                                color: StyleTheme.cTitleColor,
                                                fontSize: 18.sp),
                                          ),
                                        ),
                                        Text(widget.data!['shipping_remark'],
                                            style: TextStyle(
                                                color: StyleTheme.cTextColor,
                                                fontSize: 14.sp)),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 15.w),
                                          child: Text(
                                            '截图照片',
                                            style: TextStyle(
                                                color: StyleTheme.cTitleColor,
                                                fontSize: 18.sp),
                                          ),
                                        ),
                                        widget.data!['shipping_screenshot'] !=
                                                    null &&
                                                widget
                                                    .data![
                                                        'shipping_screenshot']
                                                    .isNotEmpty
                                            ? GridView.builder(
                                                itemCount: widget
                                                    .data![
                                                        'shipping_screenshot']
                                                    .length,
                                                physics:
                                                    NeverScrollableScrollPhysics(),
                                                shrinkWrap: true,
                                                padding: EdgeInsets.zero,
                                                gridDelegate:
                                                    SliverGridDelegateWithFixedCrossAxisCount(
                                                        childAspectRatio: 0.8,
                                                        crossAxisCount: 3,
                                                        mainAxisSpacing: 5.w,
                                                        crossAxisSpacing: 5.w),
                                                itemBuilder: (context, index) {
                                                  List screenshot = widget
                                                          .data![
                                                      'shipping_screenshot'];
                                                  return GestureDetector(
                                                    onTap: () {
                                                      AppGlobal.picMap = {
                                                        'resources': screenshot
                                                            .map((e) =>
                                                                {'url': e})
                                                            .toList(),
                                                        'index': index
                                                      };
                                                      context.push(
                                                          '/teaViewPicPage');
                                                    },
                                                    child: Container(
                                                      child: NetImageTool(
                                                        url: screenshot[index],
                                                      ),
                                                    ),
                                                  );
                                                })
                                            : SizedBox()
                                      ],
                                    ));
                              }
                            },
                            behavior: HitTestBehavior.translucent,
                            child: Padding(
                              padding: EdgeInsets.only(top: 10.w),
                              child: Text(
                                '订单详情>>',
                                style: TextStyle(
                                    color: StyleTheme.cDangerColor,
                                    fontSize: 14.sp),
                              ),
                            ),
                          )
                        : SizedBox(),
                    Container(
                      height: 1.w,
                      color: Color(0xffeeeeee),
                      margin: EdgeInsets.symmetric(vertical: 15.w),
                    ),
                    widget.isEller!
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [getBtnStatus()],
                          )
                        : (status == 0 || status == 1
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [getBtnStatus()],
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  getBtnStatus(),
                                  GestureDetector(
                                    onTap: () {
                                      if (status != 2) return;
                                      AppGlobal.mallOrder = widget.data!;
                                      context.push(CommonUtils.getRealHash(
                                          'commodityEvaluate/${widget.data!['id']}'));
                                    },
                                    child: Stack(
                                      children: [
                                        Positioned.fill(
                                            child: LocalPNG(
                                          url:
                                              'assets/images/shuimo_${status == 2 ? 'hei' : 'hui'}.png',
                                          fit: BoxFit.fill,
                                        )),
                                        Container(
                                          width: 123.5.w,
                                          height: 40.w,
                                          alignment: Alignment.center,
                                          child: Text(
                                            status == 2 ? '评价' : '已评价',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14.sp),
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ))
                  ],
                )
        ],
      ),
    );
  }
}
