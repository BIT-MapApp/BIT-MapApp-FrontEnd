import 'package:flutter/material.dart';

class SiteBar extends StatefulWidget {
  final double size;

  const SiteBar({Key? key, required this.size}) : super(key: key);

  @override
  _SiteBarState createState() => _SiteBarState();
}

class _SiteBarState extends State<SiteBar> {

  Widget _siteBox(Widget child) {
    return Container(
      width: widget.size,
      height: widget.size,
      child: Center(child: child),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color.fromRGBO(100, 100, 100, 50),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [_siteBox(const Text("1"))],
    );
  }
}
