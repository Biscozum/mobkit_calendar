import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class Foo extends SingleChildRenderObjectWidget {
  final int index;

  const Foo({Widget? child, required this.index, Key? key}) : super(child: child, key: key);

  @override
  Foo2 createRenderObject(BuildContext context) {
    return Foo2()..index = index;
  }

  @override
  void updateRenderObject(BuildContext context, Foo2 renderObject) {
    renderObject.index = index;
  }
}

class Foo2 extends RenderProxyBox {
  late int index;
}
