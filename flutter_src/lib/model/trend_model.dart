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
  
  Future<TrendDetail> getTrendDetail(BuildContext context, int id) async {
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

    return TrendDetail(
      result["user"] as String,
      imageIdList,
      result["txt"] as String,
      result["place"] as String,
      result["time"] as String,
      await Provider.of<UserModel>(context, listen: false).getNicknameByUsername(context, result["user"]),
    );
  }

  Uint8List consolidateHttpClientResponseBytes(List<int> data) {
    // response.contentLength is not trustworthy when GZIP is involved
    // or other cases where an intermediate transformer has been applied
    // to the stream.
    final List<List<int>> chunks = <List<int>>[];
    int contentLength = 0;
    chunks.add(data);
    contentLength += data.length;
    final Uint8List bytes = Uint8List(contentLength);
    int offset = 0;
    for (List<int> chunk in chunks) {
      bytes.setRange(offset, offset + chunk.length, chunk);
      offset += chunk.length;
    }
    return bytes;
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