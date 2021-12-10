import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_src/model/sites_model.dart';
import 'package:flutter_src/model/trend_model.dart';
import 'package:flutter_src/model/user_model.dart';
import 'package:provider/provider.dart';

import 'detail.dart';
import '../utils.dart';

// 一条动态的简略信息面板，显示在动态列表里面
class BriefUI extends StatefulWidget {
  final String name;
  final int trendId;
  final String content;
  final List<int> images;
  final ImageProvider avatar;
  final GestureTapCallback? onTap;
  final ImageDetailCallback? onTapImage;
  final int commentCnt;
  final int voteCnt;
  final String location;

  const BriefUI({
    Key? key,
    required this.name,
    required this.content,
    required this.images,
    required this.avatar,
    required this.commentCnt,
    required this.voteCnt,
    this.onTap,
    this.onTapImage,
    required this.trendId, required this.location,
  }) : super(key: key);

  @override
  _BriefUIState createState() => _BriefUIState();
}

class _BriefUIState extends State<BriefUI> {
  final double _imageSize = 50.0;
  final double _avatarSize = 50.0;
  static const int _normalBrightness = 243;
  static const int _chosenBrightness = 233;
  int _brightness = _normalBrightness;

  @override
  Widget build(BuildContext context) {
    return getBody();
  }

  // 获取动态文本组件
  Widget getContentTextWidget() => Expanded(
          child: Text(
        widget.content,
        maxLines: 2,
        style: const TextStyle(fontSize: 14, decoration: TextDecoration.none),
        overflow: TextOverflow.ellipsis,
      ));

  // 获取图片组件
  Widget getGallery() => SizedBox(
        height: _imageSize,
        child: galleryListBuilder(),
      );

  // 图片网格的builder
  Widget galleryListBuilder() => ListView.builder(
        itemBuilder: (context, i) {
          if (i % 2 == 0) {
            return Consumer<TrendModel>(builder: (context, model, child) {
              return FutureBuilder(
                // 后台获取图片，在取得图片之前显示loading
                  future: model.getImageById(context, widget.images[i ~/ 2]),
                  builder: (context, snap) => GestureDetector(
                        child: snap.hasData
                            ? Image(
                                width: _imageSize,
                                height: _imageSize,
                                image: snap.data! as ImageProvider,
                                fit: BoxFit.cover,
                              )
                            : getLoadingBox(_imageSize),
                        onTap: () {
                          if (widget.onTapImage != null) {
                            // 点击展开大图
                            widget.onTapImage!(i ~/ 2);
                          }
                        },
                      ));
            });
          }
          return const SizedBox(
            width: 5,
          );
        },
        scrollDirection: Axis.horizontal,
        itemCount: widget.images.length * 2,
      );

  Widget getBody() => GestureDetector(
        child: getWidgetBody(),
        onTapDown: (detail) {
          setState(() {
            _brightness = _chosenBrightness;
          });
        },
        onTapCancel: () {
          setState(() {
            _brightness = _normalBrightness;
          });
        },
        onTapUp: (detail) {
          setState(() {
            _brightness = _normalBrightness;
          });
        },
        onTap: () {
          if (widget.onTap != null) {
            widget.onTap!();
          }
        },
      );

  // 点赞
  Future<void> onVoteTap() async {
      var username = Provider.of<UserModel>(context, listen: false).localUsername;
      var model = Provider.of<TrendModel>(context, listen: false);
      if (_voteWidgetController.voteStatus) {
        var result =
        await model.sendRemoveVoteRequest(
            context,
            username,
            widget.trendId);
        if (result) {
          _voteWidgetController.voteStatus = false;
        }
      } else {
        var result =
        await model.sendVoteRequest(
            context,
            username,
            widget.trendId);
        if (result) {
          _voteWidgetController.voteStatus = true;
        }
      }
      _voteWidgetController.voteCnt = await model.getVoteCount(context, widget.trendId);
    }

  // 点赞组件的控制器
  final VoteWidgetController _voteWidgetController = VoteWidgetController();
  Widget getWidgetBody() {
    return Container(
      color:
          Color.fromRGBO(_brightness, _brightness, _brightness, 1), // 整体的灰度背景
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: IntrinsicHeight(
          // 用于给出垂直方向上的最大高度，如果不加会报错
          child: Row(
            children: <Widget>[
              getAvatar(widget.avatar, _avatarSize), // 头像
              const SizedBox(
                width: 10,
              ), // 头像与内容之间的间距
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    getNicknameTextWidget(widget.name),
                    getContentTextWidget(),
                    widget.images.isNotEmpty ? getGallery() : Container(),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Consumer<TrendModel>(
                          builder: (context, model, child) {
                            // 获取点赞状态
                            Future(() async {
                              var username = Provider.of<UserModel>(context, listen: false).localUsername;
                              bool voted = await model.isVoted(context, username, widget.trendId);
                              _voteWidgetController.voteStatus = voted;
                              _voteWidgetController.voteCnt = await model.getVoteCount(context, widget.trendId);
                            });
                            return VoteWidget(
                                trendId: widget.trendId,
                                voteCount: widget.voteCnt,
                                controller: _voteWidgetController,
                                onTap: onVoteTap);
                          },
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Consumer<TrendModel>(
                          builder: (context, model, child) =>
                          // 评论组件
                              getCommentWidget(model.getCommentListFromCache(widget.trendId).length, () { }),
                        ),
                        const SizedBox(width: 20,),
                        const Icon(Icons.location_pin),
                        Text(widget.location),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
