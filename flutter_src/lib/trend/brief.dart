import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';

class BriefUI extends StatefulWidget {
  final String name;
  final String content;
  final List<Widget> images;

  const BriefUI({Key? key, required this.name, required this.content,
    required this.images}) : super(key: key);

  @override
  _BriefUIState createState() => _BriefUIState();
}

class _BriefUIState extends State<BriefUI> {
  final double _imageSize = 50.0;
  final double _avatarSize = 50.0;
  final int _brightness = 243;

  @override
  Widget build(BuildContext context) {
    return getBody();
  }

  Widget getUsernameTextWidget() =>
    Text(         // username
      widget.name,
      style: const TextStyle(
        fontWeight: FontWeight.bold, fontSize: 16,
        fontFamily: "Roboto",
      ),
    );

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
          return widget.images[i ~/ 2];
        }
        return const SizedBox( width: 5, );
      },
      scrollDirection: Axis.horizontal,
      itemCount: widget.images.length * 2,
    );

  Widget getBody() {
    return Container(
      color: Color.fromRGBO(_brightness, _brightness, _brightness, 1), // 整体的灰度背景
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: IntrinsicHeight(   // 用于给出垂直方向上的最大高度，如果不加会报错
          child: Row( children: <Widget>[
              getAvatar(),        // 头像
              const SizedBox(width: 10,), // 头像与内容之间的间距
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    getUsernameTextWidget(),
                    getContentTextWidget(),
                    const SizedBox( height: 10, ),
                    getGallery(),
                  ],
                ),
              )
            ], ),
        ),
      ),
    );
  }

  Widget getAvatar() {
    return Column(
      children: <Widget>[
        Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(image: AssetImage("./assets/logo.jpg")),
          ),
          height: _avatarSize,
          width: _avatarSize,
        ),
      ],
    );
  }
}
