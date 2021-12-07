import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_src/model/trend_model.dart';
import 'package:flutter_src/model/user_model.dart';
import 'package:flutter_src/trend/brief.dart';
import 'package:flutter_src/trend/detail.dart';
import 'package:flutter_src/utils.dart';
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

  @override
  void initState() {
    super.initState();
    updateIDList(context);
  }

  var _idList = [];
  void updateIDList(BuildContext context) {
    Future(() => Provider.of<TrendModel>(context, listen: false).updateAllTrendList(context));
  }


  Widget buildBriefUI(String username, String nickname, String content, List<Widget> imageList, ImageProvider avatar) {
    return BriefUI(
      name: nickname,
      content: content,
      images: imageList,
      avatar: avatar,
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return DetailUI(
            nickname: nickname,
            username: username,
            content: content,
            images: imageList,
            avatar: avatar,
            onTapImage: (i) { print("Detail OnTapImage $i"); },
          );
        }));
      },
    );
  }

  final ScrollController _scrollController = ScrollController();
  final List _itemList = [];
  @override
  Widget build(BuildContext context) {
    return Consumer<TrendModel>(
      builder: (context, model, child) {
        _idList = model.trendIDList;

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
                Future(() async {
                  TrendDetail detail = await model.getTrendDetail(context, _idList[index]);
                  final List<Widget> images = [];
                  detail.imgIDList.forEach((imageId) async {
                    var image = await model.getImageById(context, imageId);
                    images.add(
                        Image(
                          width: _imageSize, height: _imageSize,
                          image: image,
                          fit: BoxFit.cover,
                        )
                        );
                  });

                  var item = buildBriefUI(
                      detail.sendUsername,
                      detail.sendNickname,
                      detail.content,
                      images,
                      const AssetImage("assets/logo.jpg")
                  );
                  if (_itemList.length > index) {
                    _itemList[index] = item;
                  }
                  else {
                    _itemList.add(item);
                  }
                  setState(() { });
                });
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
              return _itemList[_itemList.length - index - 1];
            }
          },
          separatorBuilder: (context, index) {
            return const Divider();
          },
          itemCount: _itemList.length + 1,
        );
      },
    );
  }
}
