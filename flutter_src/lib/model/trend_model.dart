import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_src/model/user_model.dart';
import 'package:flutter_src/utils.dart';
import 'package:provider/provider.dart';

import '../global.dart';

class TrendDetail {
  final String sendUsername;
  final String sendNickname;
  final List<int> imgIDList;
  final String content;
  final String location;
  final String time;

  TrendDetail(this.sendUsername, this.imgIDList, this.content, this.location, this.time, this.sendNickname);
}

class TrendModel extends ChangeNotifier {
  List<int> _tlist = []; // 动态id的列表

  List<int> get trendIDList => _tlist;

  Future<TrendModel> updateAllTrendList(BuildContext context) async {
    Response resp = await postResponseFromServer(context, "dongtai", { "method": "checkall"});
    List<dynamic> newList = json.decode(resp.data)["idlist"];
    _tlist = newList.map((e) { return e as int; }).toList();
    notifyListeners();
    return this;
  }

  final Map<int, TrendDetail> _trendCache = {};
  Future<TrendDetail> getTrendDetail(BuildContext context, int id) async {
    if (_trendCache.containsKey(id)) {
      return _trendCache[id]!;
    }
    Response resp = await postResponseFromServer(context, "dongtai", {
      "method": "check", "id": id.toString()
    });
    var result = json.decode(resp.data);
    print(result.toString());
    var originImageList = result["pics"] as List;
    final List<int> imageIdList = [];
    if (originImageList.isNotEmpty) {
      for (var element in originImageList) {
        if (element.runtimeType == int) {
          imageIdList.add(element);
        } else if (element.runtimeType == String) {
          imageIdList.add(int.parse(element));
        }
      }}

    _trendCache[id] = TrendDetail(
      result["user"] as String,
      imageIdList,
      result["txt"] as String,
      result["place"] as String,
      result["time"] as String,
      await Provider.of<UserModel>(context, listen: false).getNicknameByUsername(context, result["user"]),
    );
    return _trendCache[id]!;
  }

  final Map<int, ImageProvider> _imageCache = {};
  Future<ImageProvider> getImageById(BuildContext context, int id) async {
    if (_imageCache.containsKey(id)) return _imageCache[id]!;
    var resp = await getImageFromServer(context, "getpic", id);
    _imageCache[id] = resp;
    print("finish fetching image $id");
    notifyListeners();
    return resp;
  }

}