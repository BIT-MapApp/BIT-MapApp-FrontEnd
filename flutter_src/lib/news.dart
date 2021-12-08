import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_src/image_full_screen.dart';
import 'package:flutter_src/model/trend_model.dart';
import 'package:flutter_src/model/user_model.dart';
import 'package:flutter_src/trend/brief.dart';
import 'package:flutter_src/trend/detail.dart';
import 'package:flutter_src/utils.dart';
import 'package:provider/provider.dart';

// 动态面板的入口
class News extends StatefulWidget {
  const News({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _News();
  }
}

// 动态面板的状态
class _News extends State<News> {
  static const double _imageSize = 50;

  @override
  void initState() {
    super.initState();
    updateIDList(context);
  }

  var _idList = [];
  void updateIDList(BuildContext context) {
    // 后台更新动态id列表
    Future(() => Provider.of<TrendModel>(context, listen: false).updateAllTrendList(context));
  }

  // 点击图片的事件
  void onImageTap(int trendId, int imageIndex) async {
    var p = Provider.of<TrendModel>(context, listen: false);
    TrendDetail trendData = await p.getTrendDetail(context, trendId);
    final List<ImageProvider> imageList = [];
    for (int imageId in trendData.imgIDList) {
      ImageProvider img = await p.getImageById(context, imageId);
      imageList.add(img);
    }
    Navigator.of(context).push(MaterialPageRoute(builder: (context){
      return Scaffold(
        body: ImageFullscreenPage(imageList: imageList, index: imageIndex,),
      );
    }));
  }

  Future<Widget> buildBriefUI(TrendDetail detail, List<int> imageList) async {
    var avatar = await Provider.of<TrendModel>(context, listen: false).getAvatarByUsername(detail.sendUsername);
    return BriefUI(
      name: detail.sendNickname,
      content: detail.content,
      images: imageList,
      avatar: avatar,
      onTapImage: (i) => onImageTap(detail.trendId, i),
      voteCnt: detail.voteCount,
      commentCnt: detail.commentIdList.length,
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return DetailUI(
            nickname: detail.sendNickname,
            username: detail.sendUsername,
            content: detail.content,
            images: imageList,
            avatar: avatar,
            onTapImage: (i) => onImageTap(detail.trendId, i),
            voteCnt: detail.voteCount,
            commentIdList: detail.commentIdList,
          );
        }));
      },
    );
  }

  Future<void> loadTrend(int index) async {
    var model = Provider.of<TrendModel>(context, listen: false);

    TrendDetail detail = await model.getTrendDetail(context, _idList[index]);

    var item = await buildBriefUI( detail, detail.imgIDList );
    if (_itemList.length > index) {
      _itemList[index] = item;
    }
    else {
      _itemList.add(item);
    }
    setState(() { });
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
                Future(() => loadTrend(index));
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
      },
    );
  }
}
