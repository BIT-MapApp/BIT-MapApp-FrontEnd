import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_src/user_info_ui.dart';

import 'map_ui.dart';
import 'news.dart';
import 'user_info_ui.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const appName = 'BIT Map';
    return MaterialApp(
      title: appName,
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
  final List<Widget> _page = <Widget> [MapUI(), News(), UserInfo()]; // 面板

  Widget _getUI() {
    // 获得当前选中的面板
    return _page[_selectedItem];
  }

  @override
  Widget build(BuildContext context) {
    // 主页面脚手架的搭建，包含顶栏和底部的面板导航栏
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: _getUI(),
      // 导航栏
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.map), label: '地图'),
          BottomNavigationBarItem(icon: Icon(Icons.art_track), label: '动态'),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: '个人信息')
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
