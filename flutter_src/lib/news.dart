import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class News extends StatefulWidget {
  const News({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _News();
  }
}

// 动态面板的动态
class _News extends State<News> {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('with background',
                style: Theme.of(context).textTheme.caption),
            Text('News selected', style: Theme.of(context).textTheme.caption)
          ],
        ));
  }
}
