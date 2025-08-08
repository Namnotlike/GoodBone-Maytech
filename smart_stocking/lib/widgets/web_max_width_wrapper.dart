import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

class WebMaxWidthWrapper extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const WebMaxWidthWrapper({
    Key? key,
    required this.child,
    this.maxWidth = 900,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return child; // Chỉ áp dụng trên web

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
