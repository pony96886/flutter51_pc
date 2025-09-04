import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/components/list/public_list.dart';
import 'package:chaguaner2023/components/pagetitlebar.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/cgprivilege.dart';
import 'package:chaguaner2023/utils/common.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:chaguaner2023/utils/netimage_tool.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TanhuaListPage extends StatefulWidget {
  final String? type;
  TanhuaListPage({Key? key, this.type}) : super(key: key);

  @override
  _TanhuaListPageState createState() => _TanhuaListPageState();
}

class _TanhuaListPageState extends State<TanhuaListPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return HeaderContainer(
        child: Scaffold(
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
          child: PageTitleBar(
            title: '探花',
          ),
          preferredSize: Size(double.infinity, 44.w)),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        child: PublicList(
          cacheExtent: 5.sh,
          api: '/api/mv/getLIst',
          data: {},
          isShow: true,
          nullText: '还没有资源哦～',
          itemBuild: (context, index, data, page, limit, getListData) {
            return _videoCard(data);
          },
        ),
      ),
    ));
  }

  _videoCard(Map item) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.w),
      padding: EdgeInsets.only(bottom: 10.w),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xffeeeeee)))),
      child: GestureDetector(
        onTap: () {
          if (CgPrivilege.getPrivilegeStatus(
              PrivilegeType.infoMv, PrivilegeType.privilegeView)) {
            var _id = item['id'];
            AppGlobal.appRouter?.push(
                CommonUtils.getRealHash('tanhuaDetailPage/' + _id.toString()));
          } else {
            CommonUtils.showVipDialog(context,
                PrivilegeType.infoMvString + PrivilegeType.privilegeViewString);
          }
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6.w),
                    child: Container(
                      width: 167.5.w,
                      height: 96.w,
                      child: NetImageTool(
                        url: item['thumb_cover'],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                      right: 5.w,
                      bottom: 6.w,
                      child: Container(
                        decoration: BoxDecoration(
                            color: Color.fromRGBO(0, 0, 0, 0.4),
                            borderRadius: BorderRadius.circular(8.5.w)),
                        height: 17.w,
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: Center(
                          child: Text(
                            CommonUtils.secondsToString(item['duration']),
                            style:
                                TextStyle(color: Colors.white, fontSize: 11.sp),
                          ),
                        ),
                      ))
                ],
              ),
            ),
            SizedBox(
              width: 10.5.w,
            ),
            Expanded(
              child: Text(
                item['title'] ?? '',
                style: TextStyle(color: Color(0xff333333), fontSize: 13.sp),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<bool?> showToVip() {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 280.w,
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
                        '成为会员',
                        style: TextStyle(
                            color: StyleTheme.cTitleColor,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                        margin: new EdgeInsets.only(top: 20.w),
                        child: Text(
                          '开通会员即可无限观看',
                          style: TextStyle(
                              fontSize: 14.sp, color: StyleTheme.cTitleColor),
                        )),
                    GestureDetector(
                        onTap: () => {
                              Navigator.of(context).pop(true),
                            },
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop(true);
                            AppGlobal.appRouter?.push(
                                CommonUtils.getRealHash('memberCardsPage'));
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
                                  '立即开通',
                                  style: TextStyle(
                                      fontSize: 15.sp, color: Colors.white),
                                )),
                              ],
                            ),
                          ),
                        ))
                  ],
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(true),
                      child: LocalPNG(
                          width: 30.w,
                          height: 30.w,
                          url: 'assets/images/mymony/close.png',
                          fit: BoxFit.cover)),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
