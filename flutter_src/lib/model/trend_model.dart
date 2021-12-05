import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_src/utils.dart';

import '../global.dart';

class TrendDetail {
  final String _sendUsername;
  final List<int> _imgIDList;
  final String _content;
  final String _location;
  final String _time;

  TrendDetail(this._sendUsername, this._imgIDList, this._content, this._location, this._time);


}

class TrendModel extends ChangeNotifier {
  List<int> _tlist = []; // 动态id的列表

  List<int> get trendIDList => _tlist;

  Future<TrendModel> updateAllTrendList(BuildContext context) async {
    Response resp = await postResponseFromServer(context, "/dongtai", { "method": "checkall"});
    List<dynamic> newList = json.decode(resp.data)["idlist"];
    _tlist = newList.map((e) { return e as int; }).toList();
    notifyListeners();
    return this;
  }
  
  Future<TrendDetail> getTrendDetail(BuildContext context, int id) async {
    Response resp = await postResponseFromServer(context, "/dongtai", {
      "method": "check", "id": id.toString()
    });
    var result = json.decode(resp.data);
    return TrendDetail(
      result["user"] as String,
      (result["pics"] as List<String>).map((e) => int.parse(e)).toList(),
      result["txt"] as String,
      result["where"] as String,
      result["time"] as String
    );
  }

  Uint8List consolidateHttpClientResponseBytes(List<int> data) {
    // response.contentLength is not trustworthy when GZIP is involved
    // or other cases where an intermediate transformer has been applied
    // to the stream.
    print(1);
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
    Dio dio = Dio();
    dio.options.responseType = ResponseType.bytes;
    Response resp;
    try {
      resp = await getImageFromServer(context, "pic", 0);
    } on DioError catch(_) {
      print(_.message);
      rethrow;
    }
    print("got image");
    // final result = BytesBuilder();
    // var r = await (resp.data as ResponseBody).stream.forEach((element) {
    //   print(1);
    //   result.add(element);
    // }).then((value) {print ("123");return MemoryImage(result.takeBytes());});
    var bytes = consolidateHttpClientResponseBytes(resp.data);
    print(1);
    return MemoryImage(bytes);
  }

}