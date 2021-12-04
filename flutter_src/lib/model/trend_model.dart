import 'dart:collection';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_src/utils.dart';

import '../global.dart';

class TrendDetail {
  final String _sendUsername;
  final int _imgNum;
  final List<int> _imgIDList;
  final String _content;
  final String _location;
  final String _time;

  TrendDetail(this._sendUsername, this._imgNum, this._imgIDList, this._content, this._location, this._time);


}

class TrendModel extends ChangeNotifier {
  List<int> _tlist = [];

  List<int> get trendIDList => _tlist;

  Future<TrendModel> updateAllTrendList(BuildContext context) async {
    Response resp = await postResponseFromServer(context, "/dongtai", { "method": "checkall"});
    List<dynamic> newList = json.decode(resp.data)["idlist"];
    _tlist = newList.map((e) {
      return e as int;
    }).toList();
    notifyListeners();
    return this;
  }
}