import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_baidu_mapapi_map/flutter_baidu_mapapi_map.dart';
import 'package:flutter_baidu_mapapi_base/flutter_baidu_mapapi_base.dart';
import 'package:flutter_src/utils.dart';

// 地点信息的数据模型
class SitesModel extends ChangeNotifier {
  final List<int> _sitesId = []; // 存储地点id
  final Map<int, BMFCoordinate> _location = {}; // 存储地点坐标
  final Map<int, String> _name = {}; // 存储地点title

  int get size => _sitesId.length;
  List<int> get SitesId => _sitesId;

  BMFCoordinate getCoordinate(int id) {
    if (!_sitesId.contains(id)) throw Exception("No such site");
    return _location[id]!;
  }

  String getSiteName(int id) {
    if (!_sitesId.contains(id)) throw Exception("No such site");
    return _name[id]!;
  }

  // 从服务端获取所有地标
  Future<void> fetchMap(BuildContext context) async {
    _sitesId.clear();
    var response = await postResponseFromServer(context, "place", { "method": "checkall" });
    var jmap = json.decode(response.data);

    // 所有地标的id列表
    var tmplist = (jmap["idlist"] as List<dynamic>).map((e) => e as int).toList();
    for(int i = 0; i < tmplist.length; i++) {
      _name[tmplist[i]] = jmap["placelist"][i];
      // 查询第i个地标的详情
      response = await postResponseFromServer(context, "place", { "method": "checkidif", "id": tmplist[i] });
      var place = json.decode(response.data);
      _location[tmplist[i]] = BMFCoordinate(double.parse(place["latitude"]), double.parse(place["longtitude"]));
    }
    _sitesId.addAll(tmplist);
    notifyListeners();
  }

}