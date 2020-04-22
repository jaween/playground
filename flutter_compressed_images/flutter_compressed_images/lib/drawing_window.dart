import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart' hide Image;
import 'package:flutter_compressed_images/drawing_handler.dart';
import 'package:flutter_compressed_images/image_holder.dart';
import 'package:flutter_compressed_images/main.dart';

class DrawingWindow extends StatefulWidget {
  final ImageHolder imageHolder;
  final Function onUpdate;

  DrawingWindow({@required this.imageHolder, @required this.onUpdate});

  @override
  _DrawingWindowState createState() => _DrawingWindowState();
}

class _DrawingWindowState extends State<DrawingWindow> {
  ui.Image _image;
  DrawingHandler handler;

  @override
  void initState() {
    newImageHolder();
    super.initState();
  }

  @override
  void didUpdateWidget(DrawingWindow oldWidget) {
    if (oldWidget.imageHolder != widget.imageHolder) {
      newImageHolder();
    }
    super.didUpdateWidget(oldWidget);
  }

  void newImageHolder() {
    widget.imageHolder.image().then((image) async {
      setState(() {
        _image = image;
        handler = DrawingHandler(
          image: image,
          onImageReady: (newImage) async {
            setState(() => _image = newImage);
            final pngData = await _image.toByteData(format: ui.ImageByteFormat.png);
            widget.onUpdate(pngData.buffer.asUint8List());
          },
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      color: _image == null ? Colors.grey : null,
      child: _image == null
          ? null
          : GestureDetector(
              onPanDown: (p) =>
                  handler.start(p.localPosition / 200 * ImageHolder.size.width),
              onPanUpdate: (p) =>
                  handler.move(p.localPosition / 200 * ImageHolder.size.height),
              onPanEnd: (d) => handler.end(),
              child: CustomPaint(
                painter: ImagePainter(image: _image),
              ),
            ),
    );
  }
}
