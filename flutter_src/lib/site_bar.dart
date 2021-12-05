import 'package:flutter/material.dart';
import 'package:flutter_baidu_mapapi_map/flutter_baidu_mapapi_map.dart';
import 'package:flutter_baidu_mapapi_base/flutter_baidu_mapapi_base.dart';
import 'package:flutter_src/model/sites_model.dart';
import 'package:provider/provider.dart';

class SiteBar extends StatefulWidget {
  final double size;
  final Function mapController;

  const SiteBar({Key? key, required this.size, required this.mapController}) : super(key: key);

  @override
  _SiteBarState createState() => _SiteBarState();
}

class _SiteBarState extends State<SiteBar> {

  Widget _siteBox(int id, String name, BMFCoordinate coordinate, bool chosen) {
    return GestureDetector(
      onTap: () {
        (widget.mapController() as BMFMapController).setCenterCoordinate(coordinate, true);
        setState(() {
          chosenId = id;
        });
      },
      child: Column(
        children: [
          Container(
            width: widget.size, height: widget.size,
            decoration: const BoxDecoration(
              image: DecorationImage(image: AssetImage("assets/pin.png")) ,
            ),
          ),
          Text(
            name,
            style: TextStyle(
              color: chosen ? Theme.of(context).primaryColor : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  int chosenId = -1;
  @override
  Widget build(BuildContext context) {
    return Consumer<SitesModel>(
      builder: (context, model, child) {
        var list = model.SitesId;
        return ListView(
          scrollDirection: Axis.horizontal,
          children: List<Widget>.generate(model.size, (index) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: _siteBox(index, model.getSiteName(list[index]), model.getCoordinate(list[index]), index == chosenId),
            );
          }),
        );
      },
    );
  }
}
