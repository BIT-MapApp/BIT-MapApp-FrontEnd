import 'package:flutter/material.dart';

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

Widget getAvatar(avatar, size) {
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
