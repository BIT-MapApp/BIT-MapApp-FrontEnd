import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_src/expandable_text.dart';
import 'package:flutter_src/utils.dart';

typedef ImageDetailCallback = void Function(int index);

class DetailUI extends StatefulWidget {
  final String nickname;
  final String username;
  final String content;
  final List<Widget> images;
  final ImageProvider avatar;
  final ImageDetailCallback? onTapImage;
  final int voteCnt;
  final List<int> commentIdList;

  const DetailUI({
    Key? key,
    required this.nickname,
    required this.username,
    required this.content,
    required this.images,
    required this.avatar,
    this.onTapImage,
    required this.voteCnt,
    required this.commentIdList
  }) : super(key: key);

  @override
  _DetailUIState createState() => _DetailUIState();
}

class _DetailUIState extends State<DetailUI> {
  final double _imageSize = 100.0;
  final double _avatarSize = 55.0;
  static const int _normalBrightness = 243;
  static const int _chosenBrightness = 233;

  Widget getContentTextWidget() =>
    CommonRichText(
      text: widget.content,
      shrinkText: "更多",
      expandText: "收起",
      textStyle: const TextStyle(fontSize: 14, decoration: TextDecoration.none),
    );

  Widget getGallery() =>
      SizedBox(
        child: galleryGridBuilder(),
        height: (widget.images.length ~/ 3) * _imageSize,
      );

  Widget galleryGridBuilder() =>
    GridView.count(
      crossAxisCount: 3,
      padding: const EdgeInsets.all(3.0),
      crossAxisSpacing: 3.0,
      mainAxisSpacing: 3.0,
      children: widget.images.asMap().keys.map((e) {
        return GestureDetector(
          child: widget.images[e],
          onTap: () { if(widget.onTapImage != null) widget.onTapImage!(e); },
        );
      }).toList(),
    );


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detail"),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            getAvatar(widget.avatar, _avatarSize),
            const SizedBox(width: 5,),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  getNicknameTextWidget(widget.nickname),
                  getUsernameTextWidget(widget.username),
                  getContentTextWidget(),
                  const SizedBox(height: 5),
                  getGallery(),
                  const SizedBox(height: 5),
                  Row( children: [
                    getVoteWidget(widget.voteCnt, true),
                    const SizedBox(width: 20,),
                    getCommentWidget(widget.commentIdList.length, () {print("I want to comment!");}),
                  ], ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

