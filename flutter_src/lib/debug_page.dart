import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'model/trend_model.dart';

class DebugPage extends StatefulWidget {
  const DebugPage({Key? key}) : super(key: key);

  @override
  _DebugPageState createState() => _DebugPageState();
}

class _DebugPageState extends State<DebugPage> {
  final ScrollController _controller = ScrollController();
  final int _maxNumberOfTrendsOnLoading = 10; // 初始加载的动态数量
  final _items =[];
  var _mPage = 0;

  @override
  void initState() {
    super.initState();
    fillData();
    //给_controller添加监听
    _controller.addListener((){
      //判断是否滑动到了页面的最底部
      if(_controller.position.pixels == _controller.position.maxScrollExtent){
        //如果不是最后一页数据，则生成新的数据添加到list里面
        if(_mPage < 4){
          _retrieveData();
        }
      }
    });
  }

  void fillData() {
    //初始数据源
    for (int i=0;i<20;i++){
      _items.insert(_items.length, "第${_items.length}条原始数据");
      print(_items[i]);
    }
    _items.clear();

  }

  void _retrieveData() {
    //上拉加载新的数据
    _mPage++;
    Future.delayed(const Duration(seconds: 2)).then((e){
      for (int i=0;i<20;i++){
        _items.insert(_items.length, "这是新加载的第${_items.length}条数据");
      }
      setState(() { });
    });
  }

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(seconds: 2)).then((e){
      setState(() {
        _mPage = 0;
        _items.clear();
        for (int i=0;i<20;i++){
          _items.insert(_items.length, "第${_items.length}条下拉刷新后的数据");
        }
      });
    });
  }

  @override
  void dispose() {
    //移除监听，防止内存泄漏
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      builder: (context, AsyncSnapshot<ImageProvider> snap) {
        if (snap.hasData) {
          return Column(
            children: [
              Image(image: snap.data!)
            ],
          );
        }
        else {
          return Container(color: Colors.black,);
        }
      },
      future: Provider.of<TrendModel>(context).getImageById(context, 1).then((value) {
        print("fetched");
        return value;
      }),
    );
    // return RefreshIndicator(
    //   onRefresh: _onRefresh,
    //   child: ListView.separated(
    //       controller: _controller,
    //       physics: const BouncingScrollPhysics(),
    //       itemBuilder: (context,index){
    //         //判断是否构建到了最后一条item
    //         if(index == _items.length){
    //           //判断是不是最后一页
    //           if(_mPage < 4){
    //             //不是最后一页，返回一个loading窗
    //             return Container(
    //               padding: const EdgeInsets.all(16.0),
    //               alignment: Alignment.center,
    //               child: const SizedBox(
    //                 width: 24.0,
    //                 height: 24.0,
    //                 child: CircularProgressIndicator(strokeWidth: 2.0,),
    //               ),
    //             );
    //           }else{
    //             //是最后一页，显示我是有底线的
    //             return Container(
    //               padding: const EdgeInsets.all(16.0),
    //               alignment: Alignment.center,
    //               child: const Text('我是有底线的!!!',style:TextStyle(color: Colors.blue),),
    //             );
    //           }
    //         }else{
    //           return ListTile(title:Text('${_items[index]}'));
    //         }
    //       },
    //       //分割线构造器
    //       separatorBuilder: (context,index){
    //         return const Divider(color: Colors.blue,);
    //       },
    //       //_items.length + 1是为了给最后一行的加载loading留出位置
    //       itemCount: _items.length + 1
    //   ),
    // );
  }
}
