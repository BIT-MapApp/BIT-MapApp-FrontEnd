import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class MapUI extends StatefulWidget {
  const MapUI({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _mapUI();
  }
}

// 地图面板的状态
class _mapUI extends State<MapUI> {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('with background',
                style: Theme.of(context).textTheme.caption),
            Text('Main selected', style: Theme.of(context).textTheme.caption)
          ],
        ));
  }
}
