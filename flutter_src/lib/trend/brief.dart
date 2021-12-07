import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';

import 'detail.dart';
import '../utils.dart';

class BriefUI extends StatefulWidget {
  final String name;
  final String content;
  final List<Widget> images;
  final ImageProvider avatar;
  final GestureTapCallback? onTap;
  final ImageDetailCallback? onTapImage;
  final int commentCnt;
  final int voteCnt;

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


  Widget getContentTextWidget() =>
    Expanded( child: Text( // content of the brief
      widget.content,
      maxLines: 2,
      style: const TextStyle(fontSize: 14, decoration: TextDecoration.none),
      overflow: TextOverflow.ellipsis,
    ));

  Widget getGallery() =>
    SizedBox(
      height: _imageSize,
      child: galleryListBuilder(),
    );

  Widget galleryListBuilder() =>
    ListView.builder(
      itemBuilder: (context, i) {
        if (i % 2 == 0) {
          return GestureDetector(
            child: widget.images[i ~/ 2],
            onTap: () {
              if (widget.onTapImage != null) {
                widget.onTapImage!(i ~/ 2);
              }
            },
          );
        }
        return const SizedBox( width: 5, );
      },
      scrollDirection: Axis.horizontal,
      itemCount: widget.images.length * 2,
    );

  Widget getBody() =>
    GestureDetector(
      child: getWidgetBody(),
      onTapDown: (detail) { setState(() { _brightness = _chosenBrightness; }); },
      onTapCancel: () { setState(() { _brightness = _normalBrightness; }); },
      onTapUp: (detail) { setState(() { _brightness = _normalBrightness; }); },
      onTap: () { if (widget.onTap != null) { widget.onTap!(); }
      },
    );


  Widget getWidgetBody() {
    return Container(
      color: Color.fromRGBO(_brightness, _brightness, _brightness, 1), // 整体的灰度背景
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: IntrinsicHeight(   // 用于给出垂直方向上的最大高度，如果不加会报错
          child: Row( children: <Widget>[
              getAvatar(widget.avatar, _avatarSize),        // 头像
              const SizedBox(width: 10,), // 头像与内容之间的间距
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    getNicknameTextWidget(widget.name),
                    getContentTextWidget(),
                    getGallery(),
                    const SizedBox(height: 5),
                    Row( children: [
                        getVoteWidget(widget.voteCnt, true),
                        const SizedBox(width: 20,),
                        getCommentWidget(widget.commentCnt, () {print("I want to comment!");}),
                      ], ),
                  ],
                ),
              )
            ], ),
        ),
      ),
    );
  }

}
