import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_compressed_images/image_holder.dart';

/// Displays the image based on which mode it is in.
class ImageDisplay extends StatelessWidget {
  final ImageHolder imageHolder;
  final ui.Image image;

  ImageDisplay({
    this.imageHolder,
    this.image,
  }) : assert(imageHolder != null || image != null);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Builder(
          builder: (context) {
            if (image != null) {
              return _buildDartUiImage(image);
            } else if (imageHolder.editMode) {
              return FutureBuilder<ui.Image>(
                future: imageHolder.uiImage,
                initialData: null,
                builder: (context, snapshot) {
                  if (snapshot.data == null) {
                    return Container(
                      color: Colors.black,
                    );
                  }
                  return _buildDartUiImage(snapshot.data);
                },
              );
            } else {
              return _buildImageFromPngBytes(imageHolder);
            }
          },
        ),
        if (imageHolder?.editMode == true)
          Text(
            "UNCOMPRESSED",
            style: Theme.of(context)
                .textTheme
                .bodyText2
                .copyWith(color: Colors.white),
          ),
        if (imageHolder?.dirty == true)
          Text(
            "\nDIRTY",
            style: Theme.of(context)
                .textTheme
                .bodyText2
                .copyWith(color: Colors.white),
          ),
      ],
    );
  }

  Widget _buildDartUiImage(ui.Image image) {
    return CustomPaint(
      painter: ImagePainter(image: image),
    );
  }

  Widget _buildImageFromPngBytes(ImageHolder image) {
    return Image.memory(
      image.pngBytes,
      fit: BoxFit.fill,
      filterQuality: FilterQuality.none,
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
