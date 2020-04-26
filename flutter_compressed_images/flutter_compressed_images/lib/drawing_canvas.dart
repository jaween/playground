import 'dart:ui' as ui;

import 'package:flutter/material.dart' hide Image;
import 'package:flutter_compressed_images/image_display.dart';
import 'package:flutter_compressed_images/drawing_handler.dart';
import 'package:flutter_compressed_images/image_holder.dart';

typedef void ImageModifiedCallback(ui.Image image);

class DrawingCanvas extends StatefulWidget {
  final ImageHolder imageHolder;
  final ImageModifiedCallback onImageModified;

  DrawingCanvas({@required this.imageHolder, @required this.onImageModified});

  @override
  _DrawingCanvasState createState() => _DrawingCanvasState();
}

class _DrawingCanvasState extends State<DrawingCanvas> {
  ui.Image _image;
  DrawingHandler _handler;

  @override
  void initState() {
    onImageHolderChanged();
    super.initState();
  }

  @override
  void didUpdateWidget(DrawingCanvas oldWidget) {
    if (oldWidget.imageHolder != widget.imageHolder) {
      onImageHolderChanged();
    }
    super.didUpdateWidget(oldWidget);
  }

  void onImageHolderChanged() {
    widget.imageHolder.uiImage.then((image) async {
      setState(() {
        _image = image;
        _handler = DrawingHandler(
          image: image,
          onImageReady: (newImage) async {
            widget.onImageModified(newImage);
            setState(() => _image = newImage);
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
              onPanDown: (p) => _handler
                  .start(p.localPosition / 200 * ImageHolder.size.width),
              onPanUpdate: (p) => _handler
                  .move(p.localPosition / 200 * ImageHolder.size.height),
              onPanEnd: (d) => _handler.end(),
              child: ImageDisplayOnlyDecoded(image: _image),
            ),
    );
  }
}
