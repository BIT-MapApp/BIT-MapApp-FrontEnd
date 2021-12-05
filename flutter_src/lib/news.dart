import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_src/model/trend_model.dart';
import 'package:flutter_src/trend/brief.dart';
import 'package:flutter_src/trend/detail.dart';
import 'package:provider/provider.dart';

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
  void initState() {
    super.initState();
    fillIdList(context);
  }

  var _idList = [];
  void fillIdList(BuildContext context) {
    Future(() => Provider.of<TrendModel>(context, listen: false).updateAllTrendList(context)).then((value) {
      _idList = value.trendIDList;
    }).then((value) => print(_idList));
  }

  final ScrollController _scrollController = ScrollController();
  final List _itemList = List.filled(3, Text("123"), growable: true);
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      controller: _scrollController,

      itemBuilder: (context, index) {
        if (index == _itemList.length) {
          // 当前已加载全部的动态
          if (index == _idList.length) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              alignment: Alignment.center,
              child: const Text('我是有底线的!!!', style: TextStyle(color: Colors.green), ),
            );
          }
          else {
            // 未加载完，需要获取现在还没有加载的动态，并显示一个正在加载的图标
            return Container(
              padding: const EdgeInsets.all(16.0),
              alignment: Alignment.center,
              child: const SizedBox(
                width: 24.0,
                height: 24.0,
                child: CircularProgressIndicator(strokeWidth: 2.0,),
              ),
            );
          }
        }
        else {
          // 当前不是最后一条
          return _itemList[index];
        }
      },
      separatorBuilder: (context, index) {
        return const Divider();
      },
      itemCount: _itemList.length + 1,
    );
    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            BriefUI(
              name: "wuzirui",
              content: "Content " * 20,
              images: testContainers,
              avatar: const AssetImage("./assets/logo.jpg"),
              onTap: () {
                print("OnTap");
                Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                  return DetailUI(
                    nickname: "Wu Zirui",
                    username: "real_wuzirui",
                    content: "Content " * 20,
                    images: testContainers,
                    avatar: const AssetImage("./assets/logo.jpg"),
                    onTapImage: (i) { print("Detail OnTapImage $i"); },
                  );
                }));
              },
              onTapImage: (i) => print("Tap $i"),
            ),

          ],
        ));
  }
}
