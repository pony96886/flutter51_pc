import 'package:bot_toast/bot_toast.dart';
import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/loading.dart';
import 'package:chaguaner2023/components/nodata.dart';
import 'package:chaguaner2023/components/pagetitlebar.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/api.dart';
import 'package:chaguaner2023/utils/index.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class WithdrawAccountPage extends StatefulWidget {
  final String? selectId;
  WithdrawAccountPage({Key? key, this.selectId}) : super(key: key);

  @override
  _WithdrawAccountPageState createState() => _WithdrawAccountPageState();
}

class _WithdrawAccountPageState extends State<WithdrawAccountPage> {
  int? selectID;
  bool loading = true;
  Map? inputStatr;
  List? _accountList;
  // 获取账户列表
  getAccountList() async {
    var accountList = await getListAccount();
    if (accountList!['status'] != 0) {
      setState(() {
        _accountList = accountList['data'] == null ? [] : accountList['data'];
        loading = false;
      });
    }
  }

//添加账户
  addUserAccount(String account, String name) async {
    await addAccount(account, name).then((res) {
      if (res!['status'] != 0) {
        BotToast.showText(text: '账户添加成功～', align: Alignment(0, 0));
        getAccountList();
      } else {
        BotToast.showText(text: res['msg'], align: Alignment(0, 0));
      }
    });
  }

//删除账户
  deleteAccout(int id) async {
    await delAccount(id).then((res) {
      {
        BotToast.showText(text: '账户删除成功～', align: Alignment(0, 0));
        getAccountList();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getAccountList();
    if (widget.selectId != 'null') {
      setState(() {
        selectID = int.parse(widget.selectId.toString());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return HeaderContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
            child: PageTitleBar(
              title: '提现账户',
              rightWidget: GestureDetector(
                  // ignore: missing_return
                  onTap: () async {
                    if (_accountList!.length == 5) {
                      BotToast.showText(
                          text: '最多只能添加五个账户哦～', align: Alignment(0, 0));
                      return;
                    }
                    await showAddDialog();
                    addUserAccount(
                        inputStatr!['cardCode'], inputStatr!['cardName']);
                  },
                  child: Center(
                    child: Container(
                      margin: new EdgeInsets.only(right: 15.w),
                      child: Text(
                        '添加',
                        style: TextStyle(
                            color: StyleTheme.cTitleColor,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  )),
            ),
            preferredSize: Size(double.infinity, 44.w)),
        body: loading
            ? Loading()
            : (_accountList!.length == 0
                ? NoData(
                    text: '您还没有添加提现账户哦～',
                  )
                : Container(
                    padding: EdgeInsets.only(
                        top: 10.w, bottom: 10.w + ScreenUtil().statusBarHeight),
                    child: ListView.separated(
                        itemCount: _accountList!.length,
                        physics: ClampingScrollPhysics(),
                        separatorBuilder: (BuildContext context, int index) =>
                            Divider(
                              color: Colors.transparent,
                              height: 24.w,
                            ),
                        itemBuilder: (BuildContext context, int index) {
                          return _accountRadio(
                              _accountList![index]['id'],
                              _accountList![index]['name'],
                              _accountList![index]['account']);
                        }),
                  )),
      ),
    );
  }

  Widget _accountRadio(int id, String name, String account) {
    String idSelect = 'assets/images/mymony/select.png';
    String unsse = 'assets/images/mymony/unselect.png';
    String idUrl = id == selectID ? idSelect : unsse;
    return InkWell(
        onTap: () {
          setState(() {
            selectID = id;
          });
          EventBus().emit('changeAcount', {
            'accountName': name,
            'accountId': account,
            'selectId': id.toString(),
            'selectUser': true
          });
        },
        child: Container(
          padding: new EdgeInsets.only(left: 15.w, right: 15.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    LocalPNG(
                      width: 20.w,
                      height: 20.w,
                      url: idUrl,
                    ),
                    SizedBox(
                      width: 22.5.w,
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          name,
                          style: TextStyle(
                              color: StyleTheme.cTitleColor,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w500),
                        ),
                        Container(
                          margin: new EdgeInsets.only(top: 9.5.w),
                          child: Text(
                            account,
                            style: TextStyle(
                                color: StyleTheme.cTitleColor, fontSize: 12.sp),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
              GestureDetector(
                onTap: () async {
                  showDeleteDialog().then((value) {
                    if (value!) {
                      print('---$id-------_$selectID');
                      if (id == selectID) {
                        EventBus().emit('changeAcount', {
                          'accountName': null,
                          'accountId': '',
                          'selectId': null,
                          'selectUser': false
                        });
                      }
                      deleteAccout(id);
                    }
                  });
                },
                child: Text(
                  '删除',
                  style: TextStyle(
                      color: StyleTheme.cDangerColor, fontSize: 15.sp),
                ),
              )
            ],
          ),
        ));
  }

  TextEditingController cardCode = TextEditingController();
  TextEditingController cardName = TextEditingController();
  // 弹出对话框
  Future<bool?> showDeleteDialog() {
    return showDialog<bool>(
        context: context,
        builder: (context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              width: 250.w,
              padding:
                  new EdgeInsets.symmetric(vertical: 15.w, horizontal: 25.w),
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
                          '提示',
                          style: TextStyle(
                              color: StyleTheme.cTitleColor,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                          margin: new EdgeInsets.only(top: 30.w),
                          child: Text(
                            '确定删除该账户吗？',
                            style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: StyleTheme.cTitleColor),
                          )),
                      GestureDetector(
                        onTap: () {
                          context.pop();
                        },
                        child: Container(
                          margin: new EdgeInsets.only(top: 30.w),
                          height: 50.w,
                          width: 200.w,
                          child: Stack(
                            children: [
                              LocalPNG(
                                height: 50.w,
                                width: 200.w,
                                url: 'assets/images/mymony/money-img.png',
                              ),
                              Center(
                                  child: Text(
                                '删除',
                                style: TextStyle(
                                    fontSize: 15.sp, color: Colors.white),
                              )),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: GestureDetector(
                        onTap: () => context.pop(),
                        child: LocalPNG(
                          width: 30.w,
                          height: 30.w,
                          url: 'assets/images/mymony/close.png',
                          fit: BoxFit.cover,
                        )),
                  )
                ],
              ),
            ),
          );
        });
  }

  Future<Map?> showAddDialog() {
    return showDialog<Map>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 325.w,
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
                        '添加提现账户',
                        style: TextStyle(
                            color: StyleTheme.cTitleColor,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      margin: new EdgeInsets.only(top: 30.w),
                      padding: new EdgeInsets.symmetric(
                          horizontal: 10.w, vertical: 8.w),
                      decoration: BoxDecoration(
                          color: StyleTheme.bottomappbarColor,
                          borderRadius: BorderRadius.circular(22.5.w)),
                      child: TextField(
                        keyboardType: TextInputType.number,
                        controller: cardCode,
                        decoration: InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.only(
                                left: 10, right: 10, top: 5, bottom: 5),
                            border: InputBorder.none,
                            hintStyle: TextStyle(
                                color: StyleTheme.cBioColor, fontSize: 16.sp),
                            hintText: "输入银行卡号"),
                      ),
                    ),
                    Container(
                      margin: new EdgeInsets.only(top: 30.w),
                      padding: new EdgeInsets.symmetric(
                          horizontal: 10.w, vertical: 8.w),
                      decoration: BoxDecoration(
                          color: StyleTheme.bottomappbarColor,
                          borderRadius: BorderRadius.circular(22.5.w)),
                      child: TextField(
                        controller: cardName,
                        decoration: InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.only(
                                left: 10, right: 10, top: 5, bottom: 5),
                            border: InputBorder.none,
                            hintStyle: TextStyle(
                                color: StyleTheme.cBioColor, fontSize: 16.sp),
                            hintText: "输入持卡人姓名"),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (cardName.text == '') {
                          BotToast.showText(
                              text: '请输入正确的持卡人姓名～', align: Alignment(0, 0));
                        } else {
                          if (cardCode.text.length > 10) {
                            inputStatr = {
                              'cardCode': cardCode.text,
                              'cardName': cardName.text
                            };
                            context.pop();
                            cardCode.text = '';
                            cardName.text = '';
                          } else {
                            BotToast.showText(
                                text: '请输入正确的银行卡号～', align: Alignment(0, 0));
                          }
                          ;
                        }
                        ;
                      },
                      child: Container(
                        margin: new EdgeInsets.only(top: 30.w),
                        height: 50.w,
                        width: 275.w,
                        child: Stack(
                          children: [
                            LocalPNG(
                              height: 50.w,
                              width: 225.w,
                              url: 'assets/images/mymony/money-img.png',
                              fit: BoxFit.cover,
                            ),
                            Center(
                                child: Text(
                              '确认添加',
                              style: TextStyle(
                                  fontSize: 15.sp, color: Colors.white),
                            )),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: GestureDetector(
                      onTap: () => context.pop(),
                      child: LocalPNG(
                        width: 30.w,
                        height: 30.w,
                        url: 'assets/images/mymony/close.png',
                        fit: BoxFit.cover,
                      )),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
