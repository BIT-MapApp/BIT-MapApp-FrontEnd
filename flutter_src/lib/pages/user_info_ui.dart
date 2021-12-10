import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_src/pages/login_page.dart';
import 'package:provider/provider.dart';
import '../global.dart';
import '../model/user_model.dart';

// 用户信息页面，现在没放什么太多东西
class UserPage extends StatefulWidget {
  const UserPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _UserInfo();
  }
}

// 用户信息面板的状态
class _UserInfo extends State<UserPage> {

  @override
  void initState() {
    super.initState();
  }

  final TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Padding(
        padding: const EdgeInsets.all(16.0),
          // Consumer 获取一个UserModel对象，获取username，并订阅其更新。如果登录状态改变，将会重画界面
          child: Consumer<Global>(
            builder: (context, global, child) => Consumer<UserModel>(
              builder: (context, model, child) {
                return Column(
                  children: [
                    model.localUsername == "" ? const LoginForm() : child ?? const Text("fatal error"),
                    Form(
                      child: TextFormField(
                        controller: _controller,
                        onChanged: (val) {
                          print("changed ip to $val");
                          global.changeUrl(val);
                        }
                ),
                )

                  ],
                );
              },
              child: const UserInfoPage(),
    ),
          )));
  }

}

class UserInfoPage extends StatefulWidget {
  const UserInfoPage({Key? key}) : super(key: key);

  @override
  _UserInfoPageState createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserModel>(
      builder: (context, model, child) {
        return Text("Welcome, " + model.localNickname);
      },
      child: null,
    );
  }
}
