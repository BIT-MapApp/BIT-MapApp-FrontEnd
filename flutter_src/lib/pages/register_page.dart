import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_src/utils.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text("Register"),
      ),
      body: SizedBox(
        height: screenSize.height,
        width: screenSize.width,
        child: Column(
          children: const [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: RegisterForm(),
            )
          ],
        ),
      ),
    );
  }
}

class RegisterForm extends StatefulWidget {
  const RegisterForm({Key? key}) : super(key: key);

  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final GlobalKey _key = GlobalKey<FormState>();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _nickname = TextEditingController();
  final TextEditingController _pass = TextEditingController();
  final TextEditingController _passAgain = TextEditingController();
  // final TextEditingController _email = TextEditingController();
  // final TextEditingController _sure = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _username.dispose();
    _pass.dispose();
    _nickname.dispose();
    _passAgain.dispose();
    // _email.dispose(); _sure.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _key,
      child: Column(
        children: [
          TextFormField(
            controller: _username,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.add),
              labelText: "用户名",
              hintText: "请输入用户名",
            ),
            validator: (v) {
              if (v == null || v.isEmpty) {
                return "必须输入用户名！";
              }
            },
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _nickname,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.add),
              labelText: "昵称",
              hintText: "请输入昵称",
            ),
            validator: (v) {
              if (v == null || v.isEmpty) {
                return "必须输入昵称！";
              }
            },
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _pass,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.add),
              labelText: "密码",
              hintText: "请输入密码",
            ),
            obscureText: true,
            validator: (v) {
              if (v == null || v.isEmpty) {
                return "必须输入密码！";
              }
            },
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _passAgain,
            decoration: const InputDecoration(
              labelText: "确认密码",
              prefixIcon: Icon(Icons.add),
              hintText: "请确认密码",
            ),
            obscureText: true,
            validator: (v) {
              if (v == null || v.isEmpty) {
                return "必须输入确认密码！";
              }
              if (v != _pass.text) {
                return "两次输入的密码不相同";
              }
            },
          ),
          const SizedBox(height: 8),
          // TextFormField(
          //   controller: _email,
          //   decoration: InputDecoration(
          //     prefixIcon: Icon(Icons.add),
          //     labelText: "邮箱",
          //     hintText: "请输入邮箱",
          //     //textInputAction:TextInputAction.send,
          //   ),
          //   obscureText: true,
          //   validator:(v){
          //     if(v==null||v.isEmpty){
          //       return "必须输入邮箱！";
          //     }
          //   },
          // ),
          // SizedBox(height: 8),
          // TextFormField(
          //   controller: _sure,
          //   decoration: InputDecoration(
          //     prefixIcon: Icon(Icons.add),
          //     labelText: "验证码",
          //     hintText: "请输入验证码",
          //     //textInputAction:TextInputAction.send,
          //   ),
          //   obscureText: true,
          //   validator:(v){
          //     if(v==null||v.isEmpty){
          //       return "必须输入验证码！";
          //     }
          //   },
          // ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              if (!(_key.currentState as FormState).validate()) { return; }
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("正在尝试注册..."),
              ));
              Future(() async {
                var resp = await postResponseFromServer(context, "register", {
                  "user": _username.text,
                  "nickname": _nickname.text,
                  "password": _pass.text,
                });
                var jmap = json.decode(resp.data);
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                if (jmap["result"] == "success") {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar( content: Text("注册成功！"), ));
                  Navigator.of(context).pop();
                }
                else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar( content: Text("用户名已使用"), ));
                }
              });
            },
            child: const Text("验证注册"),
          )
        ],
      ),
    );
    return const Scaffold();
  }
}
