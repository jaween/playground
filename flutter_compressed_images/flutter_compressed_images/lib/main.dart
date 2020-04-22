import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_compressed_images/image_holder.dart';

import 'image_list_screen.dart';

void main() {
  runApp(AppMenu());
}

class AppMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: 'menu',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case 'image':
            return MaterialPageRoute(
              settings: settings,
              builder: (context) => ImageListScreen(png: false),
            );
            break;
          case 'png':
            return MaterialPageRoute(
              settings: settings,
              builder: (context) => ImageListScreen(png: true),
            );
            break;
          case 'menu':
            return MaterialPageRoute(
              settings: settings,
              builder: (context) {
                return Scaffold(
                  body: Builder(
                    builder: (context) {
                      return Center(
                        child: Container(
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              RaisedButton(
                                child: Text("Use uncompressed"),
                                onPressed: () =>
                                    Navigator.of(context).pushNamed('image'),
                              ),
                              RaisedButton(
                                child: Text("Use compressed (PNG)"),
                                onPressed: () =>
                                    Navigator.of(context).pushNamed('png'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
            break;
          default:
            return null;
        }
      },
    );
  }
}

class ImagePainter extends CustomPainter {
  final ui.Image image;

  ImagePainter({@required this.image});

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    final src = Rect.fromLTWH(
      0,
      0,
      image.width.toDouble(),
      image.height.toDouble(),
    );
    final dst = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawImageRect(image, src, dst, Paint());
  }
}
