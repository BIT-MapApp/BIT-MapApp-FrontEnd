import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_src/trend/brief.dart';

class News extends StatefulWidget {
  const News({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _News();
  }
}

// 动态面板的动态
class _News extends State<News> {
  static const double _imageSize = 50;
  List<Widget> testContainers = [
    Container( width: _imageSize, height: _imageSize, color: Colors.red, ),
    Container( width: _imageSize, height: _imageSize, color: Colors.blue, ),
    Container( width: _imageSize, height: _imageSize, color: Colors.green, ),
    Container( width: _imageSize, height: _imageSize, color: Colors.yellow, ),
    Container( width: _imageSize, height: _imageSize, color: Colors.purple, ),
    Container( width: _imageSize, height: _imageSize, color: Colors.cyan, ),
    Container( width: _imageSize, height: _imageSize, color: Colors.red, ),
    Container( width: _imageSize, height: _imageSize, color: Colors.blue, ),
    Container( width: _imageSize, height: _imageSize, color: Colors.green, ),
    Container( width: _imageSize, height: _imageSize, color: Colors.yellow, ),
    Container( width: _imageSize, height: _imageSize, color: Colors.purple, ),
    Container( width: _imageSize, height: _imageSize, color: Colors.cyan, ),
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            BriefUI(
              name: "wuzirui",
              content: "Content " * 20,
              images: testContainers,
            ),

          ],
        ));
  }
}
