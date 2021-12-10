import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_src/global.dart';
import 'package:flutter_src/utils.dart';
import 'package:provider/provider.dart';

// 用户数据模型
class UserModel extends ChangeNotifier {
  String _localUsername = "";
  String? _localNickname;
  // 当前已登录的用户名，如果未登录则为""
  String get localUsername => _localUsername;
  String get localNickname => _localNickname ?? "";

  // 昵称的缓存，其实从服务器获取也很快，只不过因为昵称一般不会改变，并且经常会用到，所以干脆缓存下来了
  final Map<String, String> _nicknameCache = {};

  // 获取用户昵称
  Future<String> getNicknameByUsername(BuildContext context, String username) async {
    if (_nicknameCache.containsKey(username)) {
      return _nicknameCache[username]!;
    }
    Response resp = await postResponseFromServer(context, "search", { "user": username, });
    String ret = json.decode(resp.data.toString())["nickname"];
    _nicknameCache.addAll({username: ret});
    return ret;
  }

  // 获取当前用户的昵称
  Future<void> _fetchNickname(BuildContext context) async {
    _localNickname = await getNicknameByUsername(context, localUsername);
    notifyListeners();
  }

  // 设置登录状态
  Future<void> setUsername(BuildContext context, String username) async {
    _localUsername = username;
    _fetchNickname(context);
    // 会通知所有界面进行刷新
    notifyListeners();
  }
}