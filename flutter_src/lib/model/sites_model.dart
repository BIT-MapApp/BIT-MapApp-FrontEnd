import 'package:flutter/cupertino.dart';
import 'package:flutter_baidu_mapapi_map/flutter_baidu_mapapi_map.dart';
import 'package:flutter_baidu_mapapi_base/flutter_baidu_mapapi_base.dart';

class SitesModel extends ChangeNotifier {
  final List<int> _sitesId = [0, 1, 2];
  final Map<int, BMFCoordinate> _location = {};
  final Map<int, String> _name = {};

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

  Future<void> fetchMap() async {
    _location.addAll({
      0: BMFCoordinate(39.74059333434651, 116.17627056793135),
      1: BMFCoordinate(39.737839954962354, 116.1829270117603),
      2: BMFCoordinate(39.73814512086165, 116.17729463621274),
    });
    _name.addAll({
      0: "北湖", 1: "良乡体育馆", 2: "徐特立图书馆"
    });
    notifyListeners();
  }

}