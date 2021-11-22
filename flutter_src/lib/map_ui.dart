import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_baidu_mapapi_map/flutter_baidu_mapapi_map.dart';
import 'package:flutter_baidu_mapapi_base/flutter_baidu_mapapi_base.dart';
import 'package:flutter_baidu_mapapi_search/flutter_baidu_mapapi_search.dart';

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

  @override
  void initState() {
    super.initState();
  }

  /// 创建完成回调
  void onBMFMapCreated(BMFMapController controller) {
    mapController = controller;

    /// 地图加载回调
    mapController?.setMapDidLoadCallback(callback: () {
      print('mapDidLoad-地图加载完成!!!');
    });
  }
  /// 设置地图参数
  BMFMapOptions initMapOptions() {
    BMFMapOptions mapOptions = BMFMapOptions(
      center: BMFCoordinate(39.917215, 116.380341),
      zoomLevel: 12,
      changeCenterWithDoubleTouchPointEnabled:true,
      gesturesEnabled:true ,
      scrollEnabled:true ,
      zoomEnabled: true ,
      rotateEnabled :true,
      compassPosition :BMFPoint(0,0) ,
      showMapScaleBar:false ,
      maxZoomLevel:15,
      minZoomLevel:8,
//      mapType: BMFMapType.Satellite
    );
    return mapOptions;
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return SizedBox(
      width: screenSize.width,
      height: screenSize.height,
      child: BMFMapWidget(
        onBMFMapCreated: (controller) {
          onBMFMapCreated(controller);
        },
        mapOptions: initMapOptions(),
      ),
    );
  }
}
