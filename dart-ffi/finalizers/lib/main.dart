import 'package:flutter/material.dart';

import 'example.dart';

void main() {
  runApp(ExampleApp());
}

class ExampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Example(),
        ),
      ),
    );
  }
}
