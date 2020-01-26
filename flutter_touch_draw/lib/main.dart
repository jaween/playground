import 'package:flutter/material.dart';
import 'package:flutter_touch_draw/draw_app.dart';

void main() => runApp(MyApp());


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DrawApp(),
    );
  }
}
