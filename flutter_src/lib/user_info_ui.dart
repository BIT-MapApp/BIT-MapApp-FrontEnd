import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_src/login_page.dart';
import 'register_page.dart';
import 'global.dart';

class UserInfo extends StatefulWidget {
  const UserInfo({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _UserInfo();
  }
}

// 用户信息面板的状态
class _UserInfo extends State<UserInfo> {

  @override
  Widget build(BuildContext context) {
    return const Center(
        child: Padding(
        padding: EdgeInsets.all(16.0),
          child: LoginForm(),
    ));
  }

}
