import 'dart:convert';

import 'package:flutter/material.dart';

class Global extends ChangeNotifier {
  String? lastLogin;
  bool debugMode = true;
  String url = "http://172.21.147.74:5000/";
}