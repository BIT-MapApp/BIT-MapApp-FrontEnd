import 'package:flutter/material.dart';
import 'package:flutter_baidu_mapapi_map/flutter_baidu_mapapi_map.dart';
import 'package:flutter_baidu_mapapi_base/flutter_baidu_mapapi_base.dart';
import 'package:flutter_src/model/sites_model.dart';
import 'package:provider/provider.dart';

class SiteBarController {
  int _chosenId = -1;
  int get chosenId => _chosenId;
  set chosenId(val) {
    _chosenId = val;
    if (updateCallback != null) updateCallback!();
  }
  VoidCallback? updateCallback;
}

class SiteBar extends StatefulWidget {
  final double size;
  final Function? mapController;
  final SiteBarController controller;

  const SiteBar({Key? key, required this.size, required this.mapController, required this.controller}) : super(key: key);

  @override
  _SiteBarState createState() => _SiteBarState();
}

class _SiteBarState extends State<SiteBar> {
  int _chosenId = -1;

  @override
  void initState() {
    super.initState();
    widget.controller.updateCallback = updated;
    _chosenId = widget.controller.chosenId;
  }

  void updated() {
    setState(() {
      _chosenId = widget.controller.chosenId;
    });
  }

  Widget _siteBox(int id, String name, BMFCoordinate coordinate, bool chosen) {
    return GestureDetector(
      onTap: () {
        if (widget.mapController != null) {
          (widget.mapController!() as BMFMapController).setCenterCoordinate(coordinate, true);
        }
        widget.controller.chosenId = id;
      },
      child: Container(
        decoration: BoxDecoration(
          color: chosen ? Colors.lightGreen : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Column(
            children: [
              Icon(
                Icons.room,
                color: chosen ? Colors.white : Colors.teal,
              ),
              Text(
                name,
                style: TextStyle(
                  color: chosen ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SitesModel>(
      builder: (context, model, child) {
        var list = model.SitesId;
        return Container(
          decoration: const BoxDecoration(
            boxShadow: [
              BoxShadow(color: Colors.black12, offset: Offset(1, 0), blurRadius: 1, spreadRadius: 2),
              BoxShadow(color: Colors.white, offset: Offset(0, 0), blurRadius: 1, spreadRadius: 0),
            ],
            borderRadius: BorderRadius.all(Radius.circular(5)),
          ),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: List<Widget>.generate(model.size, (index) {
              return _siteBox(index, model.getSiteName(list[index]), model.getCoordinate(list[index]), index == widget.controller.chosenId);
            }),
          ),
        );
      },
    );
  }
}
