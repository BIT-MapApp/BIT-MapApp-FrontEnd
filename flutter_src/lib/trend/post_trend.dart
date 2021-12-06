import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:flutter_src/model/sites_model.dart';
import 'package:flutter_src/model/user_model.dart';
import 'package:flutter_src/site_bar.dart';
import 'package:flutter_src/utils.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../global.dart';

class PostTrendPage extends StatefulWidget {
  const PostTrendPage({Key? key}) : super(key: key);

  @override
  _PostTrendPageState createState() => _PostTrendPageState();
}

class _PostTrendPageState extends State<PostTrendPage> {

  @override
  void initState() {
    super.initState();
    _siteBarController.chosenId = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("发表动态"),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(onPressed: () {
            if (imageCount == 0) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("您需要至少添加一张图片才可以发送动态")));
              return ;
            }
            var chosen = _siteBarController.chosenId;
            var content = _textEditingController.text;
            var siteId = Provider.of<SitesModel>(context, listen: false).SitesId[chosen];
            Future(() => postResponseFromServer(context, "dongtai", {
              "method": "add",
              "user": Provider.of<UserModel>(context, listen: false).localUsername,
              "txt": content,
              "place": siteId + 1,
              "time": DateTime.now().toString(),
            })).then((response) async {
              Map<String, dynamic> jmap = json.decode(response.data);
              if (jmap.containsKey("result") && jmap["result"] == "fail") {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("发送失败")));
                return;
              }
              if (!jmap.containsKey("id")) {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("网络连接错误")));
                return;
              }

              int id = -1;
              if (jmap["id"].runtimeType == String) {
                id = int.parse(jmap["id"]);
              }
              else {
                id = jmap["id"];
              }

              // 创建动态成功，下面需要把图片上传到服务器
              // 如果上传成功，则动态发表成功，否则删除动态
              var status = await Permission.storage.status;
              for (int time = 0; time < 5 && !status.isGranted; time++) {
                Permission.storage.request();
              }
              var f = File(imagePaths[0]);
              Map<String, dynamic> imageMap = {};
              for (int i = 0; i < images.length; i++) {
                var key = id.toString() + "pic" + (i + 1).toString();
                imageMap[key] = MultipartFile.fromBytes(images[i].toList());
                // imageMap[key] = MultipartFile.fromFile(path.dirname(imagePaths[i]), filename: path.split(imagePaths[i]).last);
              }
              var provider = Provider.of<Global>(context, listen: false);
              String url = provider.url + "addpic";
              var uri = Uri.parse(url);
              var request = http.MultipartRequest("POST", uri);
              for (int i = 0; i < images.length; i++) {
                var key = id.toString() + "pic" + (i + 1).toString();
                request.files.add(http.MultipartFile.fromString(key, base64Encode(images[i].toList())));
              }
              http.StreamedResponse httpResponse = await request.send();
              jmap = json.decode(await httpResponse.stream.transform(const Utf8Decoder()).join());

              print(jmap.toString());

              if (jmap.containsKey("result") && jmap["result"] == "fail") {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("发送失败")));
                await postResponseFromServer(context, "dongtai", {
                  "method": "delete",
                  "id": id,
                });
                return;
              }

              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("发送成功")));
              Navigator.of(context).pop();
            });

          }, icon: const Icon(Icons.check)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: getBody(),
      ),
    );
  }

  final TextEditingController _textEditingController = TextEditingController();
  final SiteBarController _siteBarController = SiteBarController();
  final GlobalKey _key = GlobalKey<FormState>();

  int contentLength = 0;
  final maxLength = 500;

  int imageCount = 0;

  Widget getBody() {
    Size screenSize = MediaQuery.of(context).size;
    const size = 70.0;
    return SizedBox(
      width: screenSize.width,
      height: screenSize.height,
      child: Column(
        children: [
          Expanded(
            flex: 4,
            child: Form(
              key: _key,
              child: Column(
                children: [
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      maxLines: 10,
                      controller: _textEditingController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.short_text),
                        labelText: "内容 (可选)",
                        counter: Text(
                          contentLength.toString() +
                              "/ " +
                              maxLength.toString(),
                          style: const TextStyle(
                            color: Colors.blueGrey,
                          ),
                        ),
                      ),
                      validator: (v) {
                        if (v != null && v.length > maxLength) {
                          return "字数过多。";
                        }
                      },
                      onChanged: (v) {
                        setState(() {
                          contentLength = v.length;
                        });
                      },
                    ),
                  )
                ],
              ),
              autovalidateMode: AutovalidateMode.always,
            ),
          ),
          Expanded(
            flex: 5,
            child: GridView.count(
              crossAxisCount: 3,
              padding: const EdgeInsets.all(3.0),
              crossAxisSpacing: 3.0,
              mainAxisSpacing: 3.0,
              children: getImages(),
            ),
          ),
          Container(
            height: size,
            constraints: const BoxConstraints(maxHeight: size, minHeight: size),
            child: SiteBar(
                size: 40, mapController: null, controller: _siteBarController),
          ),
        ],
      ),
    );
  }

  Future<String> saveImage(Uint8List image) async {
    var status = await Permission.storage.status;
    for (int time = 0; time < 5 && !status.isGranted; time++) {
      Permission.storage.request();
    }
    final result = await ImageGallerySaver.saveImage(image);

    if (result["isSuccess"]) {
      return result["filePath"];
    }
    throw Exception("save failure");
  }

  List<Uint8List> images = [];
  List<String> imagePaths = [];
  List<Widget> getImages() {
    int cnt = min(imageCount + 1, 9);
    return List<Widget>.generate(cnt, (index) {
      if (index == cnt - 1 && imageCount < 9) {
        return ElevatedButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (context) => SizedBox(
                height: 100,
                child: Column(
                  children: [
                    Expanded(
                      child: SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: () async {
                              final imagePicker = ImagePicker();
                              var image = await imagePicker.pickImage(
                                  source: ImageSource.gallery);
                              if (image != null) {
                                images.add(await image.readAsBytes());
                                imagePaths.add(image.path);
                                setState(() {
                                  imageCount++;
                                });
                                Navigator.of(context).pop();
                              }
                            },
                            child: const Text("从相册中选择"),
                            style: TextButton.styleFrom(
                                primary: Theme.of(context).primaryColor),
                          )),
                    ),
                    Expanded(
                      child: SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: () async {
                              final imagePicker = ImagePicker();
                              var image = await imagePicker.pickImage(
                                  source: ImageSource.camera);
                              if (image != null) {
                                images.add(await image.readAsBytes());
                                imagePaths.add(await saveImage(images.last));
                                setState(() {
                                  imageCount++;
                                });
                                Navigator.of(context).pop();
                              }
                            },
                            child: const Text("相机"),
                            style: TextButton.styleFrom(
                                primary: Theme.of(context).primaryColor),
                          )),
                    ),
                  ],
                ),
              ),
            );
          },
          child: const Icon(Icons.add),
          style: ElevatedButton.styleFrom(primary: Colors.grey),
        );
      }
      return Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: MemoryImage(images[index]),
                fit: BoxFit.cover,)),
      );
    });
  }
}
