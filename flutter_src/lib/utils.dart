import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import 'global.dart';

Widget getNicknameTextWidget(name) =>
    Text(         // username
      name,
      style: const TextStyle(
        fontWeight: FontWeight.bold, fontSize: 16,
      ),
    );

Widget getUsernameTextWidget(name) =>
    Text(         // username
      "@" + name,
      style: const TextStyle(
        fontSize: 16,
        fontFamily: "RobotoThin",
      ),
    );

Widget getAvatar(ImageProvider avatar, double size) {
  return Column(
    children: <Widget>[
      Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(image: avatar),
        ),
        height: size,
        width: size,
      ),
    ],
  );
}

class WebError extends Notification {
  final String msg;

  WebError(this.msg);
}

Future<Response> postResponseFromServer(BuildContext context, String route, Map<String, dynamic> request, {bool form = false}) async {
  Dio dio = Dio();
  var provider = Provider.of<Global>(context, listen: false);
  String url = provider.url + route;
  Response ret;
  try {
    if (form) {
      ret = await dio.post(url, data: FormData.fromMap(request));
    }
    else {
      ret = await dio.post(url, data: request);
    }
  } on DioError catch(_) {
    WebError(_.message).dispatch(context);
    rethrow;
  }
  return ret;
}

Future<ImageProvider> getImageFromServer(BuildContext context, String route, int id) async {
  Dio dio = Dio();
  dio.options.responseType = ResponseType.bytes;
  var provider = Provider.of<Global>(context, listen: false);
  String url = provider.url + route;
  Response ret;
  try {
    // ret = await dio.request(url, data: { "id": id} );
    ret = await dio.post(url, data: { "id": id },
      options: Options(
        followRedirects: true,
        validateStatus: (code) { if (code != null) return code < 500; return true; } )
    );
    var loc = ret.headers.map["location"]!.first;
    // return NetworkImage(loc, headers: {HttpHeaders.connectionHeader: 'keep-alive'});
    ret = await dio.get(loc, options: Options(headers: {HttpHeaders.connectionHeader: 'keep-alive'}));
    return MemoryImage(ret.data);
  } on Exception catch(_) {
    // WebError(_.message).dispatch(context);
    print("recursive call");
    return await getImageFromServer(context, route, id);
  }
}
