import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'global.dart';

class UserInfo extends StatefulWidget {
  const UserInfo({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _UserInfo();
  }
}

// 用户信息面板的状态
class _UserInfo extends State<UserInfo> {
  bool _showPassword = false;
  GlobalKey _formKey = GlobalKey<FormState>();
  bool _nameAutoFocus = true;

  final TextEditingController _usernameField = TextEditingController();
  final TextEditingController _pwdField = TextEditingController();

  String loginResponse = "No response yet";

  @override
  void initState() {
    if (Global.lastLogin != null) {
      _nameAutoFocus = false;
      _usernameField.text = Global.lastLogin!;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        // autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          children: [
            Text(
              loginResponse
            ),
            TextFormField(
              autofocus: _nameAutoFocus,
              controller: _usernameField,
              decoration: const InputDecoration(
                  labelText: '用户名', prefixIcon: Icon(Icons.person)),
              validator: (val) {
                return val!.trim().isNotEmpty ? null : "用户名不能为空";
              },
            ),
            TextFormField(
              autofocus: !_nameAutoFocus,
              controller: _pwdField,
              decoration: InputDecoration(
                  labelText: '密码',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _showPassword = !_showPassword;
                        });
                      },
                      icon: Icon(_showPassword
                          ? Icons.visibility_off
                          : Icons.visibility))),
              obscureText: !_showPassword,
              validator: (val) {
                return val!.trim().isNotEmpty ? null : "不能为空";
              },
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints.expand(height: 45.0),
                child: ElevatedButton(
                  onPressed: _tryLogin,
                  style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).primaryColor),
                  child: const Text("Log In"),
                ),
              ),
            )
          ],
        ),
      ),
    ));
  }

  void _tryLogin() async {
    if (!(_formKey.currentState as FormState).validate()) return;
    print(_usernameField.text + " " + _pwdField.text);
    Dio dio = Dio();
    Map<String, dynamic> mmap = Map();
    mmap["user"] = _usernameField.text;
    String url = Global.url + "/queryNickname";
    print(url);
    Response resp = await dio.post(url, data: mmap);
    setState(() {
      loginResponse = resp.data.toString();
    });
    print(loginResponse);
  }
}
