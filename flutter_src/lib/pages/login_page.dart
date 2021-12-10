import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_src/pages/register_page.dart';
import 'package:flutter_src/utils.dart';
import 'package:provider/provider.dart';

import '../global.dart';
import '../model/user_model.dart';

// 登录页
class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool _showPassword = false;
  final GlobalKey _formKey = GlobalKey<FormState>();

  // 用户名和密码的输入控制器
  final TextEditingController _usernameField = TextEditingController();
  final TextEditingController _pwdField = TextEditingController();

  String loginResponse = "No response yet";
  bool socketOK = true;

  @override
  void initState() {
    // 这里暂时没有用，是计划用来添加记忆登录的
    // 虽然根据YAGNI原则应该删掉，但是明天就要交活了就懒得改了
    var provider = Provider.of<Global>(context, listen: false);
    if (provider.lastLogin != null) {
      _usernameField.text = provider.lastLogin!;
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
                    // 显示密码
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
              // 跳转到注册界面
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
    try {
      Response resp = await postResponseFromServer(context, "login", {
        "user": _usernameField.text,
        "password": _pwdField.text,
      });
      setState(() {
        loginResponse = resp.data.toString();
        socketOK = true;
      });
      var result = json.decode(loginResponse)["result"];
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      // 如果登录成功，弹出提示
      if (result == "success") {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("登录成功!"),
        ));
        Provider.of<UserModel>(context, listen: false).setUsername(context, _usernameField.text);
      }
      else {
        // 其实这里这么写不太负责，不过后端也没有给具体会导致fail的原因
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("用户名或密码错误"),
        ));

      }
    }
    on DioError catch (_) {
    }
  }
}
