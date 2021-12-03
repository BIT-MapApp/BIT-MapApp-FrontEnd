import 'dart:convert';

import 'package:flutter/material.dart';

class Global {
  static String? lastLogin;
  static bool debugMode = true;
  static String _url = "";
  static Future<String> url(context) async {
    if (_url != "") return _url;
    String jsonStr = await DefaultAssetBundle.of(context).loadString("assets/config.json");
    _url = json.decode(jsonStr)["Server Url"];
    return _url;
  }
}