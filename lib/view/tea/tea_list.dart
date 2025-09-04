import 'dart:async';
import 'package:bot_toast/bot_toast.dart';
import 'package:chaguaner2023/components/headerContainer.dart';
import 'package:chaguaner2023/store/sharedPreferences.dart';
import 'package:chaguaner2023/theme/style_theme.dart';
import 'package:chaguaner2023/utils/app_global.dart';
import 'package:chaguaner2023/utils/index.dart';
import 'package:chaguaner2023/utils/local_png.dart';
import 'package:chaguaner2023/view/tea/tea_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class TeaListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => TeaListState();
}

class TeaListState extends State<TeaListPage> {
  int clickFrequency = 0; //记录点击次数
  int maxFrequency = 7; //控制点击次数
  DateTime lastPopTime = DateTime.now();
  Timer? _clearClick; //时间间隔
  clearClick() {
    _clearClick = Timer.periodic(Duration(milliseconds: 10000), (t) {
      setState(() {
        clickFrequency = 0;
      });
      t.cancel();
    });
  }

  _clickToHome() {
    _clearClick?.cancel();
    setState(() {
      clickFrequency++;
    });
    if (clickFrequency == maxFrequency) {
      context.pop();
      setState(() {
        clickFrequency = 0;
      });
      _clearClick?.cancel();
      EventBus().emit('checkLine');
    }
    clearClick();
  }

  showFloat() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => ShadowBox(),
      ).then((value) => {
            if (value == true) {Navigator.pop(context)}
          });
      return;
    });
  }

  BuildContext? teaContext;
  @override
  void dispose() {
    super.dispose();
    if (_clearClick != null && _clearClick!.isActive) {
      _clearClick?.cancel();
    }
  }

  @override
  void initState() {
    super.initState();
    PersistentState.getState('initApp').then((initapp) => {
          //第一次使用APP
          if (initapp == null) {showFloat()}
        });
  }

  List teaList = [
    {
      'image': 'assets/images/tea/per.jpeg',
      'name': '普洱茶',
      'price': '35',
      'buy': '412',
      'decs':
          '普洱茶主要产于云南省的西双版纳、临沧、普洱等地区。普洱茶讲究冲泡技巧和品饮艺术，其饮用方法丰富，既可清饮，也可混饮。普洱茶茶汤橙黄浓厚，香气高锐持久，香型独特，滋味浓醇，经久耐泡。'
    },
    {
      'image': 'assets/images/tea/tgy.jpeg',
      'name': '铁观音',
      'price': '85',
      'buy': '953',
      'decs':
          '铁观音含有较高的氨基酸、维生素、矿物质、茶多酚和生物碱，有多种营养和药效成分，具有养生保健的功能。于民国八年自福建安溪引进木栅区试种，分“红心铁观音”及“青心铁观音”两种，主要产区在文山期树属横张型，枝干粗硬，叶较稀松，芽少叶厚，产量不高，但制包种茶品质高，产期较青心乌龙晚。其树形稍，叶呈椭圆形，叶厚肉多。叶片平坦展开。'
    },
    {
      'image': 'assets/images/tea/lj.jpeg',
      'name': '龙井茶',
      'price': '468',
      'buy': '685',
      'decs':
          '春茶中的特级西湖龙井、浙江龙井外形扁平光滑，苗锋尖削，芽长于叶，色泽嫩绿，体表无茸毛；汤色嫩绿（黄）明亮；清香或嫩栗香，但有部分茶带高火香；滋味清爽或浓醇；叶底嫩绿，尚完整。其余各级龙井茶随着级别的下降，外形色泽由嫩绿一青绿一墨绿，茶身由小到大，茶条由光滑至粗糙；香味由嫩爽转向浓粗，四级茶开始有粗味；叶底由嫩芽转向对夹叶，色泽由嫩黄一青绿一黄褐。夏秋龙井茶，色泽暗绿或深绿，茶身较大，体表无茸毛，汤色黄亮，有清香但较粗糙，滋味浓略涩，叶底黄亮，总体品质比同级春茶差得多。机制龙井茶，当前有全用多功能机炒制的，也有用机器和手工辅助相结合炒制的。机制龙井茶外形大多呈棍棒状的扁形，欠完整，色泽暗绿，在同等条件下总体品质比手工炒制的差。'
    },
    {
      'image': 'assets/images/tea/dhp.jpeg',
      'name': '大红袍',
      'price': '888',
      'buy': '156',
      'decs':
          '大红袍，产于福建武夷山，属乌龙茶，品质优异。中国特种名茶。其外形条索紧结，色泽绿褐鲜润，冲泡后汤色橙黄明亮，叶片红绿相间。品质最突出之处是香气馥郁有兰花香，香高而持久，“岩韵”明显。除与一般茶叶具有提神益思，消除疲劳、生津利尿、解热防暑、杀菌消炎、解毒防病、消食去腻、减肥健美等保健功能外，还具有防癌症、降血脂、抗衰老、等特殊功效。大红袍很耐冲泡，冲泡七、八次仍有香味。品饮“大红袍”茶，必须按“工夫茶”小壶小杯细品慢饮的程式，才能真正品尝到岩茶之颠的禅茶韵味。注重活 、甘、清、香。'
    },
    {
      'image': 'assets/images/tea/mj.jpeg',
      'name': '毛尖',
      'price': '588',
      'buy': '365',
      'decs':
          '毛尖具体又分沩山毛尖，信阳毛尖（信阳毛尖,亦称"豫毛峰".因条索细圆,紧直有锋芒,又产于河南信阳,故取名"信阳毛尖",信阳毛尖是河南知名品牌），茅坪毛尖，都匀毛尖，秀山毛尖，黄山毛尖等。另有拥有悠久茶文化历史的产茶大县竹溪出产的竹溪毛尖，是湖北省茶文化的一大奇葩。'
    },
    {
      'image': 'assets/images/tea/zyq.jpeg',
      'name': '竹叶青',
      'price': '388',
      'buy': '662',
      'decs':
          '春季是竹叶青采摘的最佳期间，春季新发出的嫩芽，嫩芽肥厚含有富厚的营养成分，春茶是一年之中最好的茶叶，在清明节前夕峨眉山的茶农开始采摘新茶，春茶以清明，谷雨前采摘的茶叶最好。竹叶青茶在春季开始采摘，采摘的新叶经过筛分一芽一叶，采摘的新叶经过杀青，揉捻，烘培等工艺制作而成，成品茶以绿色调为主，含有较多的叶绿素，竹叶青茶按照成品茶的颜色和制茶工艺，竹叶青茶属于绿茶的烘青类茶。'
    },
    {
      'image': 'assets/images/tea/hc.jpeg',
      'name': '红茶',
      'price': '888',
      'buy': '156',
      'decs':
          '红茶属全发酵茶，是以适宜的茶树新牙叶为原料，经萎凋、揉捻（切）、发酵、干燥等一系列工艺过程精制而成的茶。萎凋是红茶初制的重要工艺，红茶在初制时称为“乌茶”。红茶因其干茶冲泡后的茶汤和叶底色呈红色而得名。中国红茶品种主要有：日照红茶、 [1]  祁红、昭平红、霍红、滇红、越红、泉城红、泉城绿、苏红、川红、英红、东江楚云仙红茶等，2013年湖南东江楚云仙红茶喜获“中茶杯”特等奖。'
    }
  ];
  int popCount = 0; // 跟踪侧滑操作的次数
  bool closeOnConfirm() {
    // 点击返回键的操作
    if (lastPopTime == null ||
        DateTime.now().difference(lastPopTime) > Duration(seconds: 2)) {
      lastPopTime = DateTime.now();
      BotToast.showText(text: '再按一下退出茶馆～', align: Alignment(0, 0));
      return false;
    } else {
      lastPopTime = DateTime.now();
      // 退出app
      return true;
    }
  }

  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (_) async {
        if (_) {
          return;
        }
        if (closeOnConfirm()) {
          // 系统级别导航栈 退出程序
          await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        }
      },
      child: HeaderContainer(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            padding: new EdgeInsets.only(
                top: ScreenUtil().statusBarHeight,
                bottom: ScreenUtil().bottomBarHeight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                InkWell(
                  onTap: () {
                    _clickToHome();
                  },
                  child: Container(
                    padding: new EdgeInsets.symmetric(
                        vertical: 12.w, horizontal: 15.w),
                    child: LocalPNG(
                      url: 'assets/images/tea/tea-list-bg.png',
                      width: 345.w,
                      height: 140.w,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(18))),
                  padding: new EdgeInsets.only(
                      top: 15.w, left: 15.5.w, right: 15.5.w),
                  child: Text(
                    '最新茶叶',
                    style: TextStyle(
                        color: StyleTheme.cTitleColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 18.sp),
                  ),
                ),
                Expanded(
                    child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, childAspectRatio: 0.87),
                  itemCount: teaList.length,
                  itemBuilder: (context, index) {
                    return Center(
                      child: _teaCard(index),
                    );
                  },
                ))
              ],
            ),
          ),
        ),
      ),
    );
  }

  _teaCard(index) {
    return Container(
      width: 165.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                new MaterialPageRoute(
                    builder: (_) => new TeaDetailPage(data: teaList[index])),
              );
            },
            child: Container(
              height: 150.w,
              margin: new EdgeInsets.only(bottom: 5.w),
              decoration: new BoxDecoration(
                color: Color(0xFFC8C8C8),
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              child: LocalPNG(
                  height: 150.w,
                  url: teaList[index]['image'],
                  fit: BoxFit.cover),
            ),
          ),
          Container(
            margin: new EdgeInsets.only(bottom: 5.w),
            child: Text(
              teaList[index]['name'],
              style: TextStyle(
                  fontSize: 15.sp,
                  color: StyleTheme.cTitleColor,
                  fontWeight: FontWeight.w500),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '¥' + teaList[index]['price'],
                style: TextStyle(
                    fontSize: 15.w,
                    color: StyleTheme.cDangerColor,
                    fontWeight: FontWeight.w500),
              ),
              Text(
                teaList[index]['buy'] + '人购买',
                style: TextStyle(
                    fontSize: 12.sp,
                    color: Color(0xFF969696),
                    fontWeight: FontWeight.w500),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class ShadowBox extends StatelessWidget {
  const ShadowBox({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          GestureDetector(
            onTap: () {},
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 15, vertical: 12.w),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(10)),
              padding:
                  new EdgeInsets.symmetric(vertical: 10.w, horizontal: 10.w),
              child: LocalPNG(
                url: 'assets/images/tea/tea-list-bg.png',
                width: 345.w,
                height: 140.w,
              ),
            ),
          ),
          Container(
            width: double.infinity,
            child: Center(
              child: LocalPNG(
                height: 225.w,
                url: 'assets/images/tea/tea-float.png',
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Container(
                width: double.infinity,
                padding: new EdgeInsets.only(left: 40.w, right: 40.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    GestureDetector(
                      onTap: () {
                        AppGlobal.isPrivacy.value = false;
                        context.pop();
                        context.pop();
                      },
                      child: LocalPNG(
                        width: 135.w,
                        height: 50.w,
                        url: 'assets/images/tea/tea-float-canel.png',
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        PersistentState.saveState('initApp', '1');
                        PersistentState.saveState('isPrivacy', '1');
                        AppGlobal.isPrivacy.value = true;
                        context.pop();
                      },
                      child: LocalPNG(
                        width: 135.w,
                        height: 50.w,
                        url: 'assets/images/tea/tea-float-open.png',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
