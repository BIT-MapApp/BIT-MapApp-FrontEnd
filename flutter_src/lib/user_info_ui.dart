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
        child: Column(
          children: [
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
                  prefixIcon: Icon(Icons.lock),
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
                constraints: const BoxConstraints.expand(height: 30.0),
                child: ElevatedButton(
                  onPressed: () {},
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
}
