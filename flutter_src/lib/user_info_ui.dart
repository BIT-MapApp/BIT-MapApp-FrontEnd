import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class UserInfo extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _UserInfo();
  }
}

// 用户信息面板的状态
class _UserInfo extends State<UserInfo> {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('with background',
                style: Theme.of(context).textTheme.caption),
            Text('UserInfo selected', style: Theme.of(context).textTheme.caption)
          ],
        ));
  }
}
