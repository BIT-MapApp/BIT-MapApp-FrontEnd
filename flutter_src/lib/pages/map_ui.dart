import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_baidu_mapapi_map/flutter_baidu_mapapi_map.dart';
import 'package:flutter_baidu_mapapi_base/flutter_baidu_mapapi_base.dart';
import 'package:flutter_baidu_mapapi_search/flutter_baidu_mapapi_search.dart';
import 'package:flutter_src/model/sites_model.dart';
import 'package:flutter_src/site_bar.dart';
import 'package:flutter_src/utils.dart';
import 'package:provider/provider.dart';

import '../global.dart';

class MapUI extends StatefulWidget {
  const MapUI({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _mapUI();
  }
}

// 地图面板的状态
class _mapUI extends State<MapUI> {
  BMFMapController? mapController;
  BMFMapController? getController() => mapController;

  @override
  void initState() {
    super.initState();
  }

  final posCenter = BMFCoordinate(39.73731978267623, 116.17906429806739);

  /// 创建完成回调
  void onBMFMapCreated(BMFMapController controller) {
    mapController = controller;

    /// 地图加载回调
    mapController?.setMapDidLoadCallback(callback: () {
      print('mapDidLoad-地图加载完成!!!');
      Future(() {
        var provider = Provider.of<SitesModel>(context, listen: false);
        provider.fetchMap(context).then((value) {
          for (var index in provider.SitesId) {
            var pos = provider.getCoordinate(index);
            var text = provider.getSiteName(index);
            mapController?.addMarker(BMFMarker( position: pos,
                icon: "assets/pin.png", scaleX: 0.5, scaleY: 0.5,
                title: text));
            mapController?.addText(BMFText(position: pos,
              text: text,
              fontColor: Colors.blueGrey,
              fontSize: 30,
              typeFace: BMFTypeFace( familyName: BMFFamilyName.sMonospace,
                  textStype: BMFTextStyle.BOLD_ITALIC),
              alignY: BMFVerticalAlign.ALIGN_TOP,
              alignX: BMFHorizontalAlign.ALIGN_CENTER_HORIZONTAL,
            ));
          }
        });
      });
    });

    mapController?.setMapOnClickedMapPoiCallback(callback: (poi) {
      var text = poi.text ?? "";
      print("clicked " +
          text +
          " latitude, longitude = " +
          poi.pt!.latitude.toString() +
          ", " +
          poi.pt!.longitude.toString());
    });
    mapController?.setMapOnClickedMapBlankCallback(callback: (coordinate) {
      print("click latitude= " +
          coordinate.latitude.toString() +
          " , longitude= " +
          coordinate.longitude.toString());
    });
  }

  /// 设置地图参数
  BMFMapOptions initMapOptions() {
    var provider = Provider.of<Global>(context, listen: false);
    BMFMapOptions mapOptions = BMFMapOptions(
      center: posCenter,
      zoomLevel: 17,
      changeCenterWithDoubleTouchPointEnabled: true,
      gesturesEnabled: true,
      scrollEnabled: true,
      zoomEnabled: true,
      rotateEnabled: false,
      compassPosition: BMFPoint(0, 0),
      showMapScaleBar: true,
      showMapPoi: provider.debugMode,
      maxZoomLevel: 20,
      minZoomLevel: 3,
    );
    return mapOptions;
  }

  final SiteBarController _siteBarController = SiteBarController();

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return SizedBox(
      width: screenSize.width,
      height: screenSize.height,
      child: Flex(
        direction: Axis.vertical,
        children: [
          Expanded(
            flex: 7,
            child: Center(
              child: SiteBar(
                size: 40,
                mapController: getController,
                controller: _siteBarController,
              ),
            ),
          ),
          Expanded(
            flex: 60,
            child: BMFMapWidget(
              onBMFMapCreated: (controller) {
                onBMFMapCreated(controller);
              },
              mapOptions: initMapOptions(),
            ),
          ),
        ],
      ),
    );
  }
}
