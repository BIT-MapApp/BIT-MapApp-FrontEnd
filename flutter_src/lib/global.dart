import 'dart:convert';

import 'package:flutter/material.dart';

class Global extends ChangeNotifier {
  String? lastLogin;
  bool debugMode = false;
  String url = "http://172.24.71.251:5000/";
}