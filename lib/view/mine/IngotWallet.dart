import 'dart:io';
import 'package:bot_toast/bot_toast.dart';
import 'package:chaguaner2023/components/VerticalModalSheet.dart';
import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/imageCode.dart';
import 'package:chaguaner2023/components/loading.dart';
import 'package:chaguaner2023/components/networkErr.dart';
import 'package:chaguaner2023/components/pagetitlebar.dart';
import 'package:chaguaner2023/components/popupbox.dart';
import 'package:chaguaner2023/mixins/pay_mixin.dart';
import 'package:chaguaner2023/store/global.dart';
import 'package:chaguaner2023/store/homeConfig.dart';
import 'package:chaguaner2023/store/sharedPreferences.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:chaguaner2023/utils/netimage_tool.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import "package:universal_html/html.dart" as html;

class IngotWallet extends StatefulWidget {
  IngotWallet({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => IngotWalletState();
}

class IngotWalletState extends State<IngotWallet> with PayMixin {
  bool loading = true;
  bool networkErr = false;
  List? products;
  List? channels;
  Function? closeShow;
  getdata() {
    setState(() {
      networkErr = false;
    });
    getProductListOfCard(2).then((res) {
      if (res!['status'] != 0) {
        products = res['data']['product'];
        channels = res['data']['channel'];
        loading = false;
        setState(() {});
      } else {
        setState(() {
          networkErr = true;
        });
        return;
      }
    });
  }

  @override
  void initState() {
    getdata();
    getProfilePage().then((val) => {
          if (val!['status'] != 0)
            {
              Provider.of<HomeConfig>(context, listen: false)
                  .setMoney(val['data']['money']),
              Provider.of<GlobalState>(context, listen: false)
                  .setFreezeMoney(val['data']['freeze_money'])
            }
        });
    if (!kIsWeb) {
      PersistentState.getState('ZhiFu').then((value) => {
            if (Platform.isAndroid && value == null)
              {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  VerticalModalSheet.show(
                    context: context,
                    isBtnClose: false,
                    closeShow: (e) {
                      closeShow = e;
                    },
                    child: Container(
                      color: Colors.white,
                      padding: EdgeInsets.only(
                        bottom: 15.w,
                        top: ScreenUtil().statusBarHeight,
                      ),
                      child: Column(
                        children: <Widget>[
                          LocalPNG(
                            width: double.infinity,
                            url: 'assets/images/android-zhifu.png',
                          ),
                          Container(
                            child: GestureDetector(
                              onTap: () {
                                closeShow!();
                                PersistentState.saveState('ZhiFu', '1');
                              },
                              child: Container(
                                margin: new EdgeInsets.only(top: 15.w),
                                height: 50.w,
                                width: 200.w,
                                child: Stack(
                                  children: [
                                    LocalPNG(
                                      height: 50.w,
                                      width: 200.w,
                                      url: 'assets/images/mymony/money-img.png',
                                      fit: BoxFit.fill,
                                    ),
                                    Center(
                                        child: Text(
                                      '我知道了',
                                      style: TextStyle(
                                          fontSize: 15.sp, color: Colors.white),
                                    )),
                                  ],
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    direction: VerticalModalSheetDirection.TOP,
                  );
                })
              }
          });
    }
    super.initState();
  }

  Widget yuanbaoItem(String title, String _num) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _num,
          style: TextStyle(color: StyleTheme.cTitleColor, fontSize: 18.sp),
        ),
        Text(
          title,
          style: TextStyle(color: Color(0xff969696), fontSize: 12.sp),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var money = Provider.of<HomeConfig>(context).member.money;
    var freezeMoney = Provider.of<GlobalState>(context).freezeMoney;
    String moneyStr =
        CommonUtils.renderFixedNumber(double.parse(money.toString()));
    String freezeMoneyStr =
        CommonUtils.renderFixedNumber(double.parse(freezeMoney.toString()));
    return HeaderContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
            child: PageTitleBar(
              title: '元宝钱包',
              rightWidget: GestureDetector(
                  onTap: () {
                    AppGlobal.appRouter
                        ?.push(CommonUtils.getRealHash('rechargeRecord/2'));
                  },
                  child: Center(
                    child: Container(
                      margin: new EdgeInsets.only(right: 15.w),
                      child: Text(
                        '订单记录',
                        style: TextStyle(
                            color: StyleTheme.cTitleColor,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  )),
            ),
            preferredSize: Size(double.infinity, 44.w)),
        body: networkErr
            ? NetworkErr(
                errorRetry: () {
                  getdata();
                },
              )
            : (loading
                ? Loading()
                : Padding(
                    padding: new EdgeInsets.symmetric(
                      vertical: 10.w,
                    ),
                    child: Column(
                      children: <Widget>[
                        Container(
                            margin: new EdgeInsets.symmetric(
                              horizontal: 15.w,
                            ),
                            height: 180.w,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15.w),
                              boxShadow: [
                                //阴影
                                BoxShadow(
                                    color: Colors.black12,
                                    offset: Offset(0, 0.5.w),
                                    blurRadius: 2.5.w)
                              ],
                            ),
                            child: Stack(
                              children: [
                                LocalPNG(
                                  width: double.infinity,
                                  height: 180.w,
                                  url:
                                      'assets/images/nigotwallet/money-bg-2.png',
                                  fit: BoxFit.cover,
                                ),
                                Padding(
                                  padding: new EdgeInsets.all(15.w),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: double.infinity,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: <Widget>[
                                            Text(
                                              '元宝余额',
                                              style: TextStyle(
                                                color: StyleTheme.cTextColor,
                                                fontSize: 15.sp,
                                              ),
                                            ),
                                            SizedBox(width: 10.w),
                                            Text(
                                              CommonUtils.renderFixedNumber(
                                                  double.parse(
                                                      money.toString())),
                                              style: TextStyle(
                                                  color: StyleTheme.cTitleColor,
                                                  fontSize: 30.sp,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 10.w),
                                      Expanded(
                                          child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Column(
                                            children: [
                                              Text(
                                                '$moneyStr',
                                                style: TextStyle(
                                                  color: StyleTheme.cTitleColor,
                                                  fontSize: 15.sp,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                '可用元宝',
                                                style: TextStyle(
                                                  color: StyleTheme.cTextColor,
                                                  fontSize: 15.sp,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              Text(
                                                '$freezeMoneyStr',
                                                style: TextStyle(
                                                  color: StyleTheme.cTitleColor,
                                                  fontSize: 15.sp,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                '冻结元宝',
                                                style: TextStyle(
                                                  color: StyleTheme.cTextColor,
                                                  fontSize: 15.sp,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ],
                                      )),
                                      Container(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: <Widget>[
                                            GestureDetector(
                                              onTap: () {
                                                AppGlobal.appRouter?.push(
                                                    CommonUtils.getRealHash(
                                                        'withdrawPage/0'));
                                              },
                                              child: LocalPNG(
                                                height: 50.w,
                                                width: 134.5.w,
                                                url:
                                                    "assets/images/mymony/withdraw.png",
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                AppGlobal.appRouter?.push(
                                                    CommonUtils.getRealHash(
                                                        'ingotsDetailPage'));
                                              },
                                              child: LocalPNG(
                                                height: 50.w,
                                                width: 134.5.w,
                                                url:
                                                    "assets/images/mymony/recording.png",
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )),
                        GestureDetector(
                          onTap: () {
                            AppGlobal.appRouter?.push(
                                CommonUtils.getRealHash('exchangemember'));
                          },
                          child: Container(
                              margin: new EdgeInsets.all(15.w),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15.w),
                                boxShadow: [
                                  //阴影
                                  BoxShadow(
                                      color: Colors.black12,
                                      offset: Offset(0, 0.5.w),
                                      blurRadius: 2.5.w)
                                ],
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(15.w),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '兑换会员',
                                      style: TextStyle(
                                        color: StyleTheme.cTextColor,
                                        fontSize: 15.sp,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Icon(Icons.keyboard_arrow_right,
                                        color: StyleTheme.cTextColor),
                                  ],
                                ),
                              )),
                        ),
                        Container(
                          margin: new EdgeInsets.only(top: 15.w, bottom: 20.w),
                          child: Center(
                            child: LocalPNG(
                              height: 16.5.w,
                              width: 157.w,
                              url: 'assets/images/nigotwallet/money-title.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView(
                            // physics: ClampingScrollPhysics(),
                            children: <Widget>[
                              Center(
                                child: Wrap(
                                  spacing: 15.w,
                                  runSpacing: 15.w,
                                  children: <Widget>[
                                    for (var item in products!) monyCart(item)
                                  ],
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  )),
      ),
    );
  }

  Widget monyCart(Map item) {
    String promoPrice = double.parse(item['promo_price']).toInt().toString();
    return GestureDetector(
      onTap: () {
        showPay(item);
      },
      child: Container(
        height: 90.w,
        width: 105.w,
        decoration: BoxDecoration(
            color: Color(0xFFFDF8E5),
            borderRadius: BorderRadius.circular(10.w),
            border: Border.all(width: 1.w, color: Color(0xFFFEE7DF))),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              item['pname'].toString(),
              style: TextStyle(color: Color(0xFF505050), fontSize: 15.sp),
            ),
            item['description'] != '' && item['description'] != null
                ? Text(
                    item['description'],
                    style: TextStyle(
                        color: StyleTheme.cDangerColor, fontSize: 12.sp),
                  )
                : Container(),
            Text(
              '¥$promoPrice',
              style: TextStyle(
                  color: Color(0xFF505050),
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }
}

class RechargeModel extends StatefulWidget {
  final Map? product;
  final List<dynamic>? channel;
  RechargeModel({Key? key, this.product, this.channel}) : super(key: key);

  @override
  _RechargeModelState createState() => _RechargeModelState();
}

class _RechargeModelState extends State<RechargeModel> {
  TextEditingController _codeController = TextEditingController();
  dynamic selectChannelInfo;
  dynamic selectItem;
  int currentSelect = 0;
  Map? payResult;

  // 回调的渠道和支付方式
  void onInformation(channel, item, index) {
    setState(() {
      selectChannelInfo = channel;
      selectItem = item;
      currentSelect = index;
    });
  }

  // 当前激活的tabs
  void onTabs(int index) {
    setState(() {
      currentSelect = index;
    });
  }

  // 提交数据
  Future onSubmit() async {
    html.WindowBase? winRef;
    dynamic origin = (html.window.location.origin ?? '') + '/';
    Map channelInfo;
    Map channelItem;
    if (selectChannelInfo == null) {
      channelInfo = widget.channel![currentSelect];
      channelItem = widget.channel![currentSelect]['pay_way'][currentSelect];
    } else {
      channelInfo = selectChannelInfo;
      channelItem = selectItem;
    }
    BotToast.showLoading();
    var result = await onCreatePay(
        channelItem['channel'], channelInfo['name'], widget.product!['id'],
        code: UserInfo.imageCode);
    BotToast.closeAllLoading();
    if (result == null) {
      BotToast.showText(text: '网络异常');
      UserInfo.imageCode = null;
      return;
    }
    if (result['status'] != 1) {
      BotToast.showText(text: result['msg']);
      UserInfo.imageCode = null;
      return;
    } else {
      UserInfo.imageCode = null;
      Navigator.pop(context);
      if (kIsWeb) {
        winRef = html.window.open('${origin}waiting.html', "_blank");
      }
      var res = await onCreatePay(
          channelItem['channel'], channelInfo['name'], widget.product!['id'],
          code: UserInfo.imageCode);
      UserInfo.imageCode = null;
      BotToast.closeAllLoading();
      if (res!['data'] != null && res['data']['payUrl'] != null) {
        _showDialog();
        if (kIsWeb) {
          winRef!.location.href = res['data']['payUrl'];
        } else {
          CommonUtils.launchURL(res['data']['payUrl']);
        }
      } else if (res['msg'] != null) {
        if (kIsWeb) {
          winRef!.close();
        }
        CommonUtils.showText(res['msg']);
      } else {
        if (kIsWeb) {
          winRef!.close();
        }
        CommonUtils.showText('创建订单失败，请稍后重试');
      }
    }
  }

  void _showDialog() {
    PopupBox.showText(BackButtonBehavior.none,
        title: '温馨提示',
        text:
            '1、充值高峰期间到账可能存在延迟，请稍作等待；\n2、如遇充值多次失败、长时间未到账且消费金额未返还情况，请在“充值记录”中选择该订单说明情况，我们会尽快处理。',
        confirmtext: '知道了',
        tapMaskClose: true);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.54 +
          ScreenUtil().bottomBarHeight,
      color: Colors.transparent,
      child: Container(
        padding: EdgeInsets.only(
          top: 10.w,
          bottom: MediaQuery.of(context).padding.bottom,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10)),
        ),
        child: Column(children: <Widget>[
          Expanded(
              child: ChannelContainer(
            channel: widget.channel!,
            selectChannel: onInformation,
            onTabs: onTabs,
          )),
          GestureDetector(
            onTap: () {
              // onSubmit();
              isCaptcha(1).then((res) {
                if (res!['status'] == 1) {
                  if (res['data']['is_captcha'] == 1) {
                    showImgCode().then((value) {
                      if (value != '') {
                        UserInfo.imageCode = value;
                        onSubmit();
                      }
                      _codeController.clear();
                    });
                  } else {
                    onSubmit();
                  }
                } else {
                  CommonUtils.showText(res['msg']);
                }
              });
            },
            child: Container(
              width: double.infinity,
              height: 50.w,
              // padding: EdgeInsets.only(bottom:GVScreenUtil.setWidth(20)),
              margin: EdgeInsets.only(top: 10.w),

              child: Stack(
                children: [
                  LocalPNG(
                    width: double.infinity,
                    height: 50.w,
                    url: "assets/images/pment/submit.png",
                    alignment: Alignment.center,
                    fit: BoxFit.contain,
                  ),
                  Center(
                    child: Text(
                      '购买' + widget.product!['pname'].toString(),
                      style: TextStyle(color: Colors.white, fontSize: 15.sp),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10.w,
          )
        ]),
      ),
    );
  }

  Future<String?> showImgCode() {
    return showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 300.w,
            padding: new EdgeInsets.symmetric(vertical: 15.w, horizontal: 25.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Center(
                      child: Text(
                        '图形码验证',
                        style: TextStyle(
                            color: StyleTheme.cTitleColor,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      height: 21.5.w,
                    ),
                    ImageCode(),
                    SizedBox(height: 17.w),
                    Container(
                      height: 44.w,
                      decoration: BoxDecoration(
                          color: Color(0xfff5f5f5),
                          border: Border.all(
                              width: 0.5.w, color: Color(0xffe6e6e6))),
                      child: Center(
                        child: TextField(
                          controller: _codeController,
                          onChanged: (value) {},
                          keyboardType: TextInputType.text,
                          style: TextStyle(
                              color: Color(0xff808080), fontSize: 15.sp),
                          decoration: InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.only(
                                  left: 10, right: 10, top: 5, bottom: 5),
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                  color: Color(0xFF969696), fontSize: 15.sp),
                              hintText: "请输入图形验证码",
                              hoverColor: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.w,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: double.infinity,
                        height: 40.w,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.w),
                            gradient: LinearGradient(
                              colors: [Color(0xfffbad3e), Color(0xffffedb5)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            )),
                        child: Center(
                          child: Text(
                            '确定',
                            style: TextStyle(
                                color: Color(0xff903600), fontSize: 14.sp),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: LocalPNG(
                        width: 30.w,
                        height: 30.w,
                        url: 'assets/images/mymony/close.png',
                        fit: BoxFit.cover,
                      )),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ChannelContainer extends StatefulWidget {
  final List<dynamic>? channel;
  // 选择的渠道
  final Function? selectChannel;
  final Function? onTabs;

  ChannelContainer({Key? key, this.channel, this.selectChannel, this.onTabs})
      : super(key: key);

  @override
  _ChannelContainerState createState() => _ChannelContainerState();
}

class _ChannelContainerState extends State<ChannelContainer>
    with SingleTickerProviderStateMixin {
  TabController? controller;
  int _index = 0;
  @override
  void initState() {
    super.initState();
    controller = new TabController(
        vsync: this, length: widget.channel!.length, initialIndex: 0);
    controller!.addListener(() {
      setState(() {
        _index = controller!.index;
      });
      widget.onTabs!(controller!.index);
    });
  }

  // 回调选择的渠道和支付方式
  void selectChannel(Map? channelItem) {
    widget.selectChannel!(widget.channel![_index], channelItem, _index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 0,
        title: TabBar(
            controller: controller,
            indicatorPadding: EdgeInsets.all(0),
            labelPadding: EdgeInsets.all(0),
            indicatorColor: Colors.transparent,
            tabs: widget.channel!
                .asMap()
                .keys
                .map((key) => CustomTab(
                    tabIndex: _index,
                    keyIndex: key,
                    channelItem: widget.channel![key]))
                .toList()),
      ),
      backgroundColor: Colors.white,
      body: TabBarView(
          controller: controller,
          children: widget.channel!
              .asMap()
              .keys
              .map((key) => ListViewTile(
                    payway: widget.channel![key]['pay_way'],
                    onTap: (e) {
                      selectChannel(e);
                    },
                  ))
              .toList()),
    );
  }
}

class CustomTab extends StatelessWidget {
  final int? tabIndex;
  final int? keyIndex;
  final Map? channelItem;
  const CustomTab({Key? key, this.tabIndex, this.keyIndex, this.channelItem})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Positioned(
              bottom: 0,
              child: LocalPNG(
                url: 'assets/images/tab-underline-long.png',
                alignment: Alignment.center,
                fit: BoxFit.fitHeight,
                height: tabIndex == keyIndex ? 9.w : 0,
              )),
          Text(
            channelItem!['ch_name'].toString(),
            style: TextStyle(
              color: StyleTheme.cTitleColor,
              fontSize: tabIndex == keyIndex ? 18.sp : 14.sp,
            ),
          )
        ],
      ),
    );
  }
}

class ListViewTile extends StatefulWidget {
  final List? payway;
  final Function(Map? _)? onTap;

  ListViewTile({Key? key, this.payway, this.onTap}) : super(key: key);

  @override
  _ListViewTileState createState() => _ListViewTileState();
}

class _ListViewTileState extends State<ListViewTile>
    with AutomaticKeepAliveClientMixin {
  int selectIndex = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
  }

  void selectPay(int index, Map? callbackValue) {
    setState(() {
      selectIndex = index;
    });
    widget.onTap!(callbackValue);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView.builder(
        itemCount: widget.payway!.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              selectPay(index, widget.payway![index]);
            },
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.all(15.w),
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 40.w,
                    height: 40.w,
                    child: NetImageTool(
                      url:
                          widget.payway![index]['img_url'].indexOf('http') == -1
                              ? AppGlobal.bannerImgBase +
                                  widget.payway![index]['img_url']
                              : widget.payway![index]['img_url'],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.only(left: 10.5.w),
                      child: Text(
                        widget.payway![index]['name'],
                        style: TextStyle(
                            color: StyleTheme.cTitleColor, fontSize: 15.sp),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: selectIndex == index
                        ? LocalPNG(url: 'assets/images/pment/radio-active.png')
                        : LocalPNG(url: 'assets/images/pment/radio.png'),
                  )
                ],
              ),
            ),
          );
        });
  }
}
