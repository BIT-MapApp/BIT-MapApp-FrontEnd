import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_src/image_full_screen.dart';
import 'package:flutter_src/model/trend_model.dart';
import 'package:flutter_src/trend/brief.dart';
import 'package:flutter_src/trend/detail.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

// 动态面板的入口
class News extends StatefulWidget {
  const News({Key? key, required this.refreshController, this.location}) : super(key: key);
  final RefreshController refreshController;
  final String? location; // 用于指定过滤器，只显示对应地点的动态

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
    // 先要刷新一下所有动态的id
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
        // 显示一个全屏image，这个FullscreenPage是从csdn上扒的
        body: ImageFullscreenPage(imageList: imageList, index: imageIndex,),
      );
    }));
  }


  // build一个动态的简略版
  Future<Widget> buildBriefUI(TrendDetail detail, List<int> imageList) async {
    var avatar = await Provider.of<TrendModel>(context, listen: false).getAvatarByUsername(detail.sendUsername);
    // 如果当前页面是从地图面板进来的，需要判断一下是否和选中的地点相同，如果不同，就不显示。
    if (widget.location != null && detail.location != widget.location) return Container();
    return BriefUI(
      name: detail.sendNickname,
      content: detail.content,
      images: imageList,
      avatar: avatar,
      onTapImage: (i) => onImageTap(detail.trendId, i),
      voteCnt: detail.voteCount,
      commentCnt: detail.commentIdList.length,
      trendId: detail.trendId,
      location: detail.location,
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          // 动态详情页面
          return DetailUI(
            trendId: detail.trendId,
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

  // 加载动态
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

    // 加载之后需要刷新页面
    setState(() { });
  }

  // 强制刷新页面
  Future<void> refresh() async {
    _itemList.clear();
    await Provider.of<TrendModel>(context, listen: false).updateAllTrendList(context);
    setState(() { });
  }

  Future<void> _onRefresh() async {
    await refresh();
    widget.refreshController.refreshCompleted();
  }

  // 页面滚动控制器
  final ScrollController _scrollController = ScrollController();
  // 当前已加载的所有动态
  final List _itemList = [];
  @override
  Widget build(BuildContext context) {
    return Consumer<TrendModel>(
      builder: (context, model, child) {
        _idList = model.trendIDList;

        return SmartRefresher(
          enablePullDown: true,
          enablePullUp: false,
          header: const WaterDropHeader(), // 刷新的ui
          controller: widget.refreshController,
          onRefresh: _onRefresh,
          child: ListView.separated(
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
          ),
        );
      },
    );
  }
}

