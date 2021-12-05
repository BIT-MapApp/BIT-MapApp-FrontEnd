import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_src/global.dart';
import 'package:flutter_src/utils.dart';

class UserModel extends ChangeNotifier {
  String _localUsername = "";
  String? _localNickname;
  String get localUsername => _localUsername;
  String get localNickname => _localNickname ?? "";

  final Map<String, String> _nicknameCache = {};

  Future<String> getNicknameByUsername(String username) async {
    if (_nicknameCache.containsKey(username)) return _nicknameCache[username] ?? "";
    Dio dio = Dio();
    Map<String,dynamic> mmap = { "user": username, };

    String url = Global.url + "/search";
    Response resp;
    resp = await dio.post(url, data: mmap);
    String ret = json.decode(resp.data.toString())["nickname"];
    _nicknameCache.addAll({username: ret});
    return ret;
  }

  Future<void> _fetchNickname() async {
    _localNickname = await getNicknameByUsername(localUsername);
  }

  Future<void> setUsername(String username) async {
    _localUsername = username;
    _fetchNickname();
    notifyListeners();
  }
}