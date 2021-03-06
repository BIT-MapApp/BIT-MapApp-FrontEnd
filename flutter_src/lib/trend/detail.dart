import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_src/expandable_text.dart';
import 'package:flutter_src/model/trend_model.dart';
import 'package:flutter_src/model/user_model.dart';
import 'package:flutter_src/utils.dart';
import 'package:provider/provider.dart';

typedef ImageDetailCallback = void Function(int index);

class Comment extends StatefulWidget {
  final int commentId;

  const Comment({Key? key, required this.commentId}) : super(key: key);

  @override
  State<Comment> createState() => _CommentState();
}

class _CommentState extends State<Comment> {
  CommentDetail? detail;

  @override
  Widget build(BuildContext context) {
    return Consumer<TrendModel>(builder: (context, model, child) {
      return FutureBuilder(
          future:
              Future(() => model.getCommentDetail(context, widget.commentId))
                  .then((value) async {
            detail = value;
            return await Provider.of<UserModel>(context, listen: false)
                .getNicknameByUsername(context, value.sendUsername);
          }),
          builder: (context, snap) {
            if (!snap.hasData) return Container();
            return Row(
              children: [
                Text(
                  snap.data as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(
                  width: 3,
                ),
                Text(detail!.content),
              ],
            );
          });
    });
  }
}



class DetailUI extends StatefulWidget {
  final int trendId;
  final String nickname;
  final String username;
  final String content;
  final List<int> images;
  final ImageProvider avatar;
  final ImageDetailCallback? onTapImage;
  final int voteCnt;
  final List<int> commentIdList;

  const DetailUI(
      {Key? key,
      required this.trendId,
      required this.nickname,
      required this.username,
      required this.content,
      required this.images,
      required this.avatar,
      this.onTapImage,
      required this.voteCnt,
      required this.commentIdList})
      : super(key: key);

  @override
  _DetailUIState createState() => _DetailUIState();
}

class _DetailUIState extends State<DetailUI> {
  final double _imageSize = 100.0;
  final double _avatarSize = 55.0;
  static const int _normalBrightness = 243;
  static const int _chosenBrightness = 233;

  Widget getContentTextWidget() => CommonRichText(
        text: widget.content,
        shrinkText: "??????",
        expandText: "??????",
        textStyle:
            const TextStyle(fontSize: 14, decoration: TextDecoration.none),
      );

  Widget getGallery() => SizedBox(
        child: galleryGridBuilder(),
        height: (widget.images.length / 3).ceil() * _imageSize,
      );

  Widget galleryGridBuilder() => GridView.count(
        crossAxisCount: 3,
        padding: const EdgeInsets.all(3.0),
        crossAxisSpacing: 3.0,
        mainAxisSpacing: 3.0,
        children: widget.images.map((e) {
          return Consumer<TrendModel>(
            builder: (context, model, child) => FutureBuilder(
              future: model.getImageById(context, e),
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
                  if (widget.onTapImage != null) widget.onTapImage!(e);
                },
              ),
            ),
          );
        }).toList(),
      );

  Future<void> onVoteTap() async {
    var username = Provider.of<UserModel>(context, listen: false).localUsername;
    var model = Provider.of<TrendModel>(context, listen: false);
    if (_voteWidgetController.voteStatus) {
      var result =
          await model.sendRemoveVoteRequest(context, username, widget.trendId);
      if (result) {
        _voteWidgetController.voteStatus = false;
      }
    } else {
      var result =
          await model.sendVoteRequest(context, username, widget.trendId);
      if (result) {
        _voteWidgetController.voteStatus = true;
      }
    }
    _voteWidgetController.voteCnt =
        await model.getVoteCount(context, widget.trendId);
  }

  final VoteWidgetController _voteWidgetController = VoteWidgetController();
  final TextEditingController _commentController = TextEditingController();

  Future<void> onComment() async {
    bool result = await Provider.of<TrendModel>( context, listen: false)
        .addComment(context, widget.trendId,
        _commentController.text);
    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();
    if (result) {
      ScaffoldMessenger.of(context) .showSnackBar(const SnackBar( content: Text("????????????")));
      var model = Provider.of<TrendModel>( context, listen: false);
      await model.getTrendDetail(context, widget.trendId, forceUpdate: true);
      widget.commentIdList.clear();
      widget.commentIdList.addAll(model.getCommentListFromCache(widget.trendId));
      finishComment();
      Provider.of<TrendModel>(context, listen: false).updateCommentList(context, widget.trendId);
    } else {
      ScaffoldMessenger.of(context) .showSnackBar(const SnackBar( content: Text("????????????")));
    }
  }

  void finishComment() {
    setState(() {
      _commentStatus = false;
      _commentController.text = "";
    });
  }

  // ????????????????????????
  bool _commentStatus = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail"),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            getAvatar(widget.avatar, _avatarSize),
            const SizedBox(
              width: 5,
            ),
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
                  Row(
                    children: [
                      Consumer<TrendModel>(
                        builder: (context, model, child) {
                          Future(() async {
                            var username =
                                Provider.of<UserModel>(context, listen: false)
                                    .localUsername;
                            bool voted = await model.isVoted(
                                context, username, widget.trendId);
                            _voteWidgetController.voteStatus = voted;
                            _voteWidgetController.voteCnt = await model
                                .getVoteCount(context, widget.trendId);
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
                        builder: (context, model, child) {
                          widget.commentIdList.clear();
                          widget.commentIdList.addAll(model.getCommentListFromCache(widget.trendId));
                          return getCommentWidget(widget.commentIdList.length, () {
                            print("I want to comment!");
                            var username =
                                Provider
                                    .of<UserModel>(context, listen: false)
                                    .localUsername;
                            if (username == "") {
                              ScaffoldMessenger.of(context)
                                  .hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("????????????????????????")));
                              return;
                            }
                            setState(() {
                              _commentStatus = !_commentStatus;
                            });
                          });
                        }
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Column(
                    children:
                        List.generate(widget.commentIdList.length, (index) {
                      return Comment(commentId: widget.commentIdList[index]);
                    }),
                    mainAxisAlignment: MainAxisAlignment.start,
                  ),
                  Column(
                    children: _commentStatus ? [
                            Form(
                              child: TextFormField(
                                controller: _commentController,
                                autofocus: true,
                                decoration: const InputDecoration(
                                  hintText: "????????? ",
                                ),
                              ),
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: onComment,
                                child: const Text("Send"),
                                style: ElevatedButton.styleFrom(
                                    primary: Theme.of(context).primaryColor),
                              ),
                            ),
                          ]
                        : [],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
