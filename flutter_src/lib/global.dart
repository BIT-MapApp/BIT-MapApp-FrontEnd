import 'dart:convert';

import 'package:flutter/material.dart';

// 公共数据
class Global extends ChangeNotifier {
  String? lastLogin;
  bool debugMode = false;
  String url = "http://172.24.71.251:5000/";

  void changeUrl(String ip) {
    url = "http://" + ip + ":5000/";
  }
}