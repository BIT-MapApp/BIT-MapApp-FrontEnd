import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

// 显示一个全屏image，这个FullscreenPage是从csdn上扒的
class ImageFullscreenPage extends StatefulWidget {
  final List<ImageProvider> imageList;
  final int index;
  const ImageFullscreenPage({Key? key, required this.imageList, required this.index});
  @override
  _ImageFullscreenPageState createState() => _ImageFullscreenPageState();
}

class _ImageFullscreenPageState extends State<ImageFullscreenPage> {
  int currentIndex = 0;
  late int initialIndex; //初始index
  late int length;
  late int title;
  @override
  void initState() {
    currentIndex = widget.index;
    initialIndex = widget.index;
    length = widget.imageList.length;
    title = initialIndex + 1;
    super.initState();
  }

  void onPageChanged(int index) {
    setState(() {
      currentIndex = index;
      title = index + 1;
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${title} / ${length}'),
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
      ),
      body: Container(
          decoration: const BoxDecoration(
            color: Colors.black,
          ),
          constraints: BoxConstraints.expand(
            height: MediaQuery.of(context).size.height,
          ),
          child: Stack(
            alignment: Alignment.bottomRight,
            children: <Widget>[
              PhotoViewGallery.builder(
                scrollDirection: Axis.horizontal,
                scrollPhysics: const BouncingScrollPhysics(),
                builder: (BuildContext context, int index) {
                  return PhotoViewGalleryPageOptions(
                    imageProvider: widget.imageList[index], //NetworkImage(widget.photoList[index]['image']),
                    initialScale: PhotoViewComputedScale.contained * 1,
                  );
                },
                itemCount: widget.imageList.length,
                // loadingChild: widget.loadingChild,
                backgroundDecoration: const BoxDecoration(
                  color: Colors.black,
                ),
                pageController: PageController(initialPage: initialIndex), //点进去哪页默认就显示哪一页
                onPageChanged: onPageChanged,
              ),
              Container(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  "Image ${currentIndex + 1}",
                  style: const TextStyle(color: Colors.white, fontSize: 17.0, decoration: null),
                ),
              )
            ],
          )),
    );
  }
}
