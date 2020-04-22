import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart' hide Image;
import 'package:flutter/rendering.dart';
import 'package:flutter_touch_draw/drawing_handler.dart';

class DrawApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DrawCanvas(),
    );
  }
}

class DrawCanvas extends StatefulWidget {
  @override
  _DrawCanvasState createState() => _DrawCanvasState();
}

class _DrawCanvasState extends State<DrawCanvas> {
  Image _image;
  DrawingHandler _handler;

  @override
  void initState() {
    _initHandler();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const canvasSize = Size(400, 400);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _image?.dispose();
      setState(() {
        _image = null;
      });
    });
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Center(
          child: Container(
            width: canvasSize.width,
            height: canvasSize.height,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.pink),
            ),
            child: GestureDetector(
              onLongPress: () => _initHandler(),
              onPanDown: (p) => _handler.start(p.localPosition /
                  canvasSize.width *
                  DrawingHandler.drawingSize.width),
              onPanUpdate: (p) => _handler.move(p.localPosition /
                  canvasSize.height *
                  DrawingHandler.drawingSize.height),
              onPanEnd: (d) => _handler.end(),
              child: CustomPaint(
                painter: DrawingPainter(image: _image),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _initHandler() {
    setState(() => _image?.dispose());

    final handler = DrawingHandler(
      onImageReady: (image) {
        if (mounted) {
          // New image ready to display
          setState(() {
            _image?.dispose();
            _image = image;
          });
        }
      },
    );
    setState(() => _handler = handler);
    _handler.init();
  }
}

/// Displays out image in a square aspect ratio.
class DrawingPainter extends CustomPainter {
  final Image image;

  DrawingPainter({@required this.image});

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  @override
  void paint(Canvas canvas, Size size) {
    if (image != null) {
      final src =
          Offset.zero & Size(image.width.toDouble(), image.height.toDouble());

      final minDimension = min(size.width, size.height);
      final dst = Offset.zero & Size(minDimension, minDimension);
      canvas.drawImageRect(image, src, dst, Paint());
    }
  }
}
