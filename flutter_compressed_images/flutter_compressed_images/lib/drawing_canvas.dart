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
  DrawingHandler _handler;
  ui.Image _image;

  @override
  void initState() {
    // widget.imageHolder.beginEditing().then((_) {
    if (widget.imageHolder.uiImage != null) {
      print("NEW IMAGE INIT");
      setState(() =>  _image = widget.imageHolder.uiImage);
      onImageHolderChanged();
    }
    //});
    super.initState();
  }

  @override
  void didUpdateWidget(DrawingCanvas oldWidget) {
    print("old image is ${oldWidget.imageHolder.uiImage}, image is ${widget.imageHolder.uiImage}");
    if ((_image == null && widget.imageHolder.uiImage != null) || (oldWidget.imageHolder != widget.imageHolder)) {
      print("NEW IMAGE");
      setState(() =>  _image = widget.imageHolder.uiImage);
      onImageHolderChanged();
      // });
    }
    super.didUpdateWidget(oldWidget);
  }

  void onImageHolderChanged() {
    if (_image == null) {
      return;
    }
    print("changed");
    final imageHolderAtStart = widget.imageHolder;
    if (mounted) {
      setState(() {
        _handler = DrawingHandler(
          image: _image,
          onImageReady: (newImage) async {
            // Image holder has since been changed, discard this drawing
            if (widget.imageHolder != imageHolderAtStart) {
              return;
            }
            if (widget.imageHolder.decompressed) {
              widget.onImageModified(newImage);
              setState(() {});
            }
          },
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !widget.imageHolder.decompressed || _image == null,
      child: Container(
        width: 200,
        height: 200,
        child: GestureDetector(
          onPanDown: (p) => _handler
              .start(p.localPosition / 200 * widget.imageHolder.size.width),
          onPanUpdate: (p) => _handler
              .move(p.localPosition / 200 * widget.imageHolder.size.height),
          onPanEnd: (d) => _handler.end(),
          child: ImageDisplay(imageHolder: widget.imageHolder),
        ),
      ),
    );
  }
}
