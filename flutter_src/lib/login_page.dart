import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_src/register_page.dart';

import 'global.dart';

class LoggedIn extends Notification {
  final String username;

  LoggedIn(this.username);
}

class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool _showPassword = false;
  final GlobalKey _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameField = TextEditingController();
  final TextEditingController _pwdField = TextEditingController();

  String loginResponse = "No response yet";
  bool socketOK = true;

  @override
  void initState() {
    if (Global.lastLogin != null) {
      _usernameField.text = Global.lastLogin!;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            autofocus: false,
            controller: _usernameField,
            decoration: const InputDecoration(
                labelText: '用户名', prefixIcon: Icon(Icons.person)),
            validator: (val) {
              return val!.trim().isNotEmpty ? null : "用户名不能为空";
            },
          ),
          TextFormField(
            autofocus: false,
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
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) {
                    return const RegisterPage();
                  }
                  )
              );
            },
            child: const Text("Register Now!"),
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
    );
  }

  void _tryLogin() async {
    if (!(_formKey.currentState as FormState).validate()) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("正在尝试登录..."),
    ));
    Dio dio = Dio();
    Map<String, dynamic> mmap = {
      "user": _usernameField.text,
      "password": _pwdField.text,
    };
    String url = await Global.url(context) + "/login";
    Response resp;
    try {
      resp = await dio.post(url, data: mmap);
      setState(() {
        loginResponse = resp.data.toString();
        socketOK = true;
      });
      var result = json.decode(loginResponse)["result"];
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      if (result == "success") {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("登录成功!"),
        ));
        LoggedIn(_usernameField.text).dispatch(context);
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("用户名或密码错误"),
        ));

      }
    }
    on DioError catch (_) {
      loginResponse = "Error " + _.message;
      socketOK = false;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("登录失败: " + loginResponse),
      ));
    }
  }
}
