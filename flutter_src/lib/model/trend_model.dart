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

// 一条动态的详情
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

// 一条评论的详情
class CommentDetail {
  final int commendId;
  final String content;
  final String sendUsername;
  final String time;
  final int trendId;

  CommentDetail(this.commendId, this.content, this.sendUsername, this.time, this.trendId);
}

// 所有动态的数据模型
class TrendModel extends ChangeNotifier {
  List<int> _tlist = []; // 动态id的列表

  List<int> get trendIDList => _tlist;

  // 更新动态id列表
  Future<TrendModel> updateAllTrendList(BuildContext context) async {
    Response resp = await postResponseFromServer(context, "dongtai", { "method": "checkall"});
    List<dynamic> newList = json.decode(resp.data)["idlist"];
    _tlist = newList.map((e) { return e as int; }).toList().reversed.toList();
    notifyListeners();
    return this;
  }

  // 给某条动态点赞的总数
  Future<int> getVoteCount(BuildContext context, int trendId) async {
    var resp = await postResponseFromServer(context, "dianzan", {
      "method": "checkall",
      "id": trendId,
    });
    var jmap = json.decode(resp.data) as Map<String, dynamic>;
    if (jmap.containsKey("result")  && jmap["result"]!.runtimeType == String) return 0;
    return jmap["result"] as int;
  }

  // 发送点赞请求，返回真表示成功
  Future<bool> sendVoteRequest(BuildContext context, String username, int trendId) async {
    var resp = await postResponseFromServer(context, "dianzan", {
      "method": "add", "user": username, "id": trendId,
    });
    var jmap = json.decode(resp.data) as Map<String, dynamic>;
    if (jmap.containsKey("result")  && jmap["result"]! == "success") return true;
    return false;
  }

  // 当前用户是否已点赞
  Future<bool> isVoted(BuildContext context, String username, int trendId) async {
    if (username == "") return false;
    await Future.delayed(const Duration(milliseconds: 100));
    var map = {
      "method": "checkone", "user": username, "id": trendId,
    };
    var resp = await postResponseFromServer(context, "dianzan", map);

    var jmap = json.decode(resp.data) as Map<String, dynamic>;
    if (jmap.containsKey("result")  && jmap["result"]! == "exist") return true;
    return false;
  }

  // 发送取消点赞请求，返回真表示成功
  Future<bool> sendRemoveVoteRequest(BuildContext context, String username, int trendId) async {
    var resp = await postResponseFromServer(context, "dianzan", {
      "method": "delete", "user": username, "id": trendId,
    });
    var jmap = json.decode(resp.data) as Map<String, dynamic>;
    if (jmap.containsKey("result")  && jmap["result"]! == "success") return true;
    return false;
  }

  // 向某一条动态添加评论
  Future<bool> addComment(BuildContext context, int trendId, String content) async {
    var username = Provider.of<UserModel>(context, listen: false).localUsername;
    var resp = await postResponseFromServer(context, "pinglun", {
      "method": "add", "dongtai": trendId, "txt": content, "user": username,
      "time": "now",
    });
    var jmap = json.decode(resp.data) as Map<String, dynamic>;
    if (jmap.containsKey("result") && jmap["result"] == "fail") return false;
    return true;
  }

  // 直接从缓存中获取评论列表，如果未缓存直接报错
  List<int> getCommentListFromCache(int trendId) {
    if (!_trendCache.containsKey(trendId)) throw Exception("缓存未命中");
    return _trendCache[trendId]!.commentIdList;
  }

  // 更新某条动态的评论列表，会同时更新动态信息
  Future<void> updateCommentList(BuildContext context, int trendId) async {
    TrendDetail detail = await getTrendDetail(context, trendId, forceUpdate: true);
    notifyListeners();
  }

  // 动态数据缓存
  final Map<int, TrendDetail> _trendCache = {};
  // 获取动态详情
  Future<TrendDetail> getTrendDetail(BuildContext context, int id, { bool forceUpdate=false, }) async {
    if (_trendCache.containsKey(id) && !forceUpdate) {
      return _trendCache[id]!;
    }
    Response resp = await postResponseFromServer(context, "dongtai", {
      "method": "check", "id": id.toString()
    });
    var result = json.decode(resp.data);
    var originImageList = result["pics"] as List;
    final List<int> imageIdList = [];
    // 获取图片id列表
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

  // 图片缓存
  final Map<int, ImageProvider> _imageCache = {};
  // 获取图片
  Future<ImageProvider> getImageById(BuildContext context, int id) async {
    if (_imageCache.containsKey(id)) {
      return _imageCache[id]!;
    }
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

  // 获取用户头像，现在是写死的
  Future<ImageProvider> getAvatarByUsername(String username) async {
    return const AssetImage("assets/logo.jpg");
  }

  // 评论缓存
  final Map<int, CommentDetail> _commentCache = {};
  // 获取某一条评论
  Future<CommentDetail> getCommentDetail(BuildContext context, int id) async {
    if (_commentCache.containsKey(id)) {
      return _commentCache[id]!;
    }
    Response resp = await postResponseFromServer(context, "pinglun", {
      "method": "check", "id": id.toString()
    });
    var result = json.decode(resp.data);
    _commentCache[id] = CommentDetail(
      id,
      result["txt"] as String,
      result["user"] as String,
      result["time"] as String,
      result["dongtai"] as int
    );
    return _commentCache[id]!;
  }

}