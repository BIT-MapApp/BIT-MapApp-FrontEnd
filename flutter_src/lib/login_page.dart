import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_src/register_page.dart';

import 'global.dart';

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
          Text(
            loginResponse,
            style: TextStyle(
              color: socketOK ? Colors.black : Colors.red,
            ),
          ),
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
    Dio dio = Dio();
    Map<String, dynamic> mmap = Map();
    mmap["user"] = _usernameField.text;
    mmap["password"] = _pwdField.text;
    // String url = Global.url + "/login";
    String url = "http://172.21.149.26:5000" + "/login";
    print(url);
    Response resp;
    try {
      resp = await dio.post(url, data: mmap);
      setState(() {
        loginResponse = resp.data.toString();
        socketOK = true;
      });
    }
    on DioError catch (_) {
      loginResponse = "Error " + _.message;
      socketOK = false;
    }
    finally {
      print(loginResponse);
    }
  }
}
