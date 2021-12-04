import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_src/global.dart';

class UserModel extends ChangeNotifier {
  String _username = "";
  String? _nickname;
  String get username => _username;
  String get nickname => _nickname ?? "";

  Future<void> _fetchNickname() async {
    Dio dio = Dio();
    Map<String,dynamic> mmap = { "user": username, };

    String url = Global.url + "/search";
    Response resp;
    resp = await dio.post(url, data: mmap);
    _nickname = json.decode(resp.data.toString())["nickname"];
  }

  Future<void> setUsername(String username) async {
    _username = username;
    notifyListeners();
    _fetchNickname();
  }
}