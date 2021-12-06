import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_src/trend/post_trend.dart';
import 'package:flutter_src/user_info_ui.dart';
import 'package:flutter_baidu_mapapi_map/flutter_baidu_mapapi_map.dart';
import 'package:flutter_baidu_mapapi_base/flutter_baidu_mapapi_base.dart';
import 'package:flutter_baidu_mapapi_search/flutter_baidu_mapapi_search.dart';
import 'package:provider/provider.dart';

import 'debug_page.dart';
import 'login_page.dart';
import 'map_ui.dart';
import 'model/sites_model.dart';
import 'model/trend_model.dart';
import 'model/user_model.dart';
import 'news.dart';
import 'user_info_ui.dart';
import 'global.dart';

// void main() => runApp(const MyApp());
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isIOS) {
    BMFMapSDK.setApiKeyAndCoordType('none', BMF_COORD_TYPE.BD09LL);
  } else if (Platform.isAndroid) {
// Android 目前不支持接口设置Apikey,
// 请在主工程的Manifest文件里设置，详细配置方法请参考[https://lbs.baidu.com/ 官网][https://lbs.baidu.com/)demo
    BMFMapSDK.setCoordType(BMF_COORD_TYPE.BD09LL);
  }
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider( create: (context) => UserModel(), ),
      ChangeNotifierProvider( create: (context) => TrendModel(), ),
      ChangeNotifierProvider( create: (context) => SitesModel(), ),
      ChangeNotifierProvider( create: (context) => Global(), ),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const appName = 'BIT 校景地图';
    return MaterialApp(
      title: appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.lightGreen[900],
        colorScheme:
            ColorScheme.fromSwatch().copyWith(secondary: Colors.yellow),
      ),
      home: const Pages(title: appName),
    );
  }
}

class Pages extends StatefulWidget {
  final String title;

  const Pages({Key? key, required this.title}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _Pages();
  }
}

class _Pages extends State<Pages> {
  int _selectedItem = 0; // 当前选中的面板编号

  @override
  void initState() {
    var provider = Provider.of<Global>(context, listen: false);
    if (provider.debugMode) _selectedItem = 2;
    super.initState();
  }

  Widget _getUI() {
    // 获得当前选中的面板
    switch (_selectedItem) {
      case 0:
        return const MapUI();
      case 1:
        return const News();
      case 2:
        return const UserPage();
      case 3:
        return const DebugPage();
    }
    return const MapUI();
  }

  @override
  Widget build(BuildContext context) {

    var global = Provider.of<Global>(context, listen: false);
    Future(() async => Provider.of<SitesModel>(context, listen: false).fetchMap()).then((value) =>
      Provider.of<TrendModel>(context, listen: false).updateAllTrendList(context)).then((value) async {
    }).then((value) {
    });
    // 主页面脚手架的搭建，包含顶栏和底部的面板导航栏
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: _getUI(),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (Provider.of<UserModel>(context, listen: false).localUsername == "") {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("请登录后发表动态")));
            setState(() {
              _selectedItem = 2;
            });
          }
          else {
            Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) { return PostTrendPage(); }));
          }
        },
        child: const Icon(Icons.camera),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      // 导航栏
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.map), label: '地图'),
          BottomNavigationBarItem(icon: Icon(Icons.art_track), label: '动态'),
          BottomNavigationBarItem( icon: Icon(Icons.account_circle), label: '个人信息'),
        ],
        currentIndex: _selectedItem,
        onTap: (int index) {
          setState(() {
            // 切换到对应的面板
            _selectedItem = index;
          });
        },
      ),
    );
  }
}
