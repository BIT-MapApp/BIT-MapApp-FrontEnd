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
  final int trendId;
  final String sendUsername;
  final String sendNickname;
  final List<int> imgIDList;
  final String content;
  final String location;
  final String time;
  final List<int> commentIdList;
  final int voteCount;

  TrendDetail(this.trendId, this.sendUsername, this.imgIDList,
      this.content, this.location, this.time, this.sendNickname,
      this.commentIdList, this.voteCount);
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
      id,
      result["user"] as String,
      imageIdList,
      result["txt"] as String,
      result["place"] as String,
      result["time"] as String,
      await Provider.of<UserModel>(context, listen: false).getNicknameByUsername(context, result["user"]),
      (result["pinglun"] as List).map((e) => e as int).toList(),
      result["zans"] as int,
    );
    return _trendCache[id]!;
  }

  final Map<int, ImageProvider> _imageCache = {};
  Future<ImageProvider> getImageById(BuildContext context, int id) async {
    if (_imageCache.containsKey(id)) return _imageCache[id]!;
    Dio dio = Dio();
    dio.options.responseType = ResponseType.bytes;
    var provider = Provider.of<Global>(context, listen: false);
    String url = provider.url + "getpic";
    Response ret;
    try {
      ret = await dio.post(url, data: { "id": id },
          options: Options(
              followRedirects: true,
              validateStatus: (code) { if (code != null) return code < 500; return false; } )
      );
      print("finish fetching image $id");
      var loc = ret.headers.map["location"]!.first;
      ret = await dio.get(loc, options: Options(headers: {HttpHeaders.connectionHeader: 'keep-alive'}));
      var image = MemoryImage(ret.data);
      _imageCache[id] = image;
      notifyListeners();
      return image;
    } on Exception catch(_) {
      print("recursive call");
      return await getImageById(context, id);
    }
  }

  Future<ImageProvider> getAvatarByUsername(String username) async {
    return AssetImage("assets/logo.jpg");
  }

}