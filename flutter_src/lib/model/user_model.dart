import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_src/global.dart';
import 'package:flutter_src/utils.dart';
import 'package:provider/provider.dart';

class UserModel extends ChangeNotifier {
  String _localUsername = "";
  String? _localNickname;
  String get localUsername => _localUsername;
  String get localNickname => _localNickname ?? "";

  final Map<String, String> _nicknameCache = {};

  Future<String> getNicknameByUsername(BuildContext context, String username) async {
    if (_nicknameCache.containsKey(username)) return _nicknameCache[username] ?? "";
    Response resp = await postResponseFromServer(context, "search", { "user": username, });
    String ret = json.decode(resp.data.toString())["nickname"];
    _nicknameCache.addAll({username: ret});
    return ret;
  }

  Future<void> _fetchNickname(BuildContext context) async {
    _localNickname = await getNicknameByUsername(context, localUsername);
    notifyListeners();
  }

  Future<void> setUsername(BuildContext context, String username) async {
    _localUsername = username;
    _fetchNickname(context);
    notifyListeners();
  }
}