
import 'dart:developer';
import 'dart:math';

import 'package:flutter/material.dart';

class PostTrendPage extends StatefulWidget {
  const PostTrendPage({Key? key}) : super(key: key);

  @override
  _PostTrendPageState createState() => _PostTrendPageState();
}

class _PostTrendPageState extends State<PostTrendPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("发表动态"),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: getBody(),
      ),
    );
  }

  final TextEditingController _textEditingController = TextEditingController();
  final GlobalKey _key = GlobalKey<FormState>();

  int contentLength = 0;
  final maxLength = 500;

  int imageCount = 4;

  Widget getBody() {
    Size screenSize = MediaQuery.of(context).size;
    return SizedBox(
      width: screenSize.width,
      height: screenSize.height,
      child: Column(
        children: [
          Expanded( flex: 4,
            child: Form( key: _key,
              child: Column(
                children: [
                  TextFormField(
                    maxLines: 10,
                    controller: _textEditingController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.short_text),
                      labelText: "内容 (可选)",
                      counter: Text(
                        contentLength.toString() + "/ " + maxLength.toString(),
                        style: const TextStyle( color: Colors.blueGrey, ),
                      ),
                    ),
                    validator: (v) {
                      if (v != null && v.length > maxLength) { return "字数过多。"; }
                    },
                    onChanged: (v) { setState(() { contentLength = v.length; }); },
                  )
                ],
              ),
              autovalidateMode: AutovalidateMode.always,
            ),
          ),
          Expanded( flex: 5,
            child: GridView.count(
              crossAxisCount: 3,
              padding: const EdgeInsets.all(3.0),
              crossAxisSpacing: 3.0,
              mainAxisSpacing: 3.0,
              children: getImages(),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> testList = List.filled(10,Container(color: Colors.green,width: 50,height: 50,));
  List<Widget> getImages() {
    int cnt = min(imageCount + 1, 9);
    return List<Widget>.generate(imageCount + 1, (index) {
      if (index == cnt - 1 && imageCount < 9) {
        return Container(width: 50, height: 50, color: Colors.black,);
      }
      return testList[index];
    });

  }
}
