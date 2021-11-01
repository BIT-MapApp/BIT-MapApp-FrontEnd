import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    const appName = 'BIT Map';
    return MaterialApp(
      title: appName,
      theme: ThemeData(
          brightness: Brightness.light,
          primaryColor: Colors.lightGreen[900],
          backgroundColor: Colors.yellow,
      ),
      home: HomePage(title: appName),
    );
  }
}

class HomePage extends StatelessWidget {
  final String title;

  HomePage({Key? key, required this.title}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Center(
        child: Container(
          color: Theme.of(context).secondaryHeaderColor,
          child: Text(
            'with background',
            style: Theme.of(context).textTheme.caption
          ),
        )
      ),
      floatingActionButton: Theme(
        data: Theme.of(context).copyWith(colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.grey)),
        child: const FloatingActionButton(onPressed: null, child: Icon(Icons.computer))
      ),
    );
  }

}

