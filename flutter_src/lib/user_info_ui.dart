import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_src/login_page.dart';
import 'register_page.dart';
import 'global.dart';

class UserPage extends StatefulWidget {
  const UserPage({Key? key, required this.username}) : super(key: key);

  final String username;

  @override
  State<StatefulWidget> createState() {
    return _UserInfo();
  }
}

// 用户信息面板的状态
class _UserInfo extends State<UserPage> {
  String _username = "";

  @override
  void initState() {
    _username = widget.username;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Padding(
        padding: const EdgeInsets.all(16.0),
          child: NotificationListener<LoggedIn>(
            onNotification: (notification) {
              setState(() {
                _username = notification.username;
              });
              return false;
            },
            child: _username != "" ? const UserInfoPage() : const LoginForm(),
          ),
    ));
  }

}

class UserInfoPage extends StatefulWidget {
  const UserInfoPage({Key? key}) : super(key: key);

  @override
  _UserInfoPageState createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.black,);
  }
}
