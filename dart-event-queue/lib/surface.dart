import 'dart:ui' as Ui;

import 'package:flutter/material.dart';

class Surface extends StatelessWidget {
  final Stream<Ui.Image> imageStream;
  final Sink<Offset> touchEventSink;

  Surface({
    @required this.imageStream,
    @required this.touchEventSink,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Ui.Image>(
      stream: imageStream,
      initialData: null,
      builder: (context, snapshot) {
        final image = snapshot.data;
        if (image == null) {
          return Center(
            child: Text("Image is null"),
          );
        }
        return GestureDetector(
          onPanStart: (details) => touchEventSink.add(details.globalPosition),
          onPanUpdate: (details) => touchEventSink.add(details.globalPosition),
          onPanEnd: (details) => touchEventSink.add(null),
          child: CustomPaint(
            painter: ImagePainter(image: image),
          ),
        );
      },
    );
  }
}

class ImagePainter extends CustomPainter {
  final Ui.Image image;

  ImagePainter({@required this.image});

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  @override
  void paint(Ui.Canvas canvas, Ui.Size size) {
    var imageSize = Size(image.width.toDouble(), image.height.toDouble());
    var src = Offset.zero & imageSize;
    var dst = Offset.zero & size;
    canvas.drawImageRect(image, src, dst, Paint());
  }
}
