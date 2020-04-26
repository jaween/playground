import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_compressed_images/image_holder.dart';

/// Displays the image based on which mode it is in.
class ImageDisplay extends StatefulWidget {
  final ImageHolder imageHolder;

  ImageDisplay({
    Key key,
    this.imageHolder,
  }) : super(key: key);

  @override
  _ImageDisplayState createState() => _ImageDisplayState();
}

class _ImageDisplayState extends State<ImageDisplay> {
  ui.Image _cachedImage;

  @override
  void initState() {
    print("init");
    super.initState();
  }

  @override
  void didUpdateWidget(ImageDisplay oldWidget) {
    if (widget.imageHolder != null) {
      if (widget.imageHolder.decoded) {
        print(
            "${widget.imageHolder.hashCode} Image is decoded, so will cache it...");
        widget.imageHolder.uiImage.then((image) {
          setState(() => _cachedImage = image);
          print("${widget.imageHolder.hashCode} Cache updated");
        });
      } else if (widget.imageHolder.encoded) {
        print("${widget.imageHolder.hashCode} Cache is stale, discarding");
        setState(() => _cachedImage = null);
      }
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Builder(
          builder: (context) {
            if (widget.imageHolder.decoded || widget.imageHolder.encoding) {
              return FutureBuilder<ui.Image>(
                future: widget.imageHolder.uiImage,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    if (_cachedImage != null) {
                      print(
                          "${widget.imageHolder.hashCode} UI using cached image");
                      return _buildDartUiImage(_cachedImage);
                    }
                    print("${widget.imageHolder.hashCode} UI using PNG");
                    return _buildImageFromPngBytes(widget.imageHolder.pngBytes);
                  }
                  print("${widget.imageHolder.hashCode} UI using future image");
                  return _buildDartUiImage(snapshot.data);
                },
              );
            } else {
              return _buildImageFromPngBytes(widget.imageHolder.pngBytes);
            }
          },
        ),
        ..._buildDecodeEncodeStateText(
          context: context,
          imageHolder: widget.imageHolder,
        ),
      ],
    );
  }

  Widget _buildDartUiImage(ui.Image image) {
    return CustomPaint(
      painter: ImagePainter(image: image),
    );
  }

  Widget _buildImageFromPngBytes(Uint8List bytes) {
    return Image.memory(
      bytes,
      fit: BoxFit.fill,
      filterQuality: FilterQuality.none,
      gaplessPlayback: true,
    );
  }

  List<Widget> _buildDecodeEncodeStateText({
    @required BuildContext context,
    @required ImageHolder imageHolder,
  }) {
    return [
      if (imageHolder.decoded || imageHolder.decoding)
        Padding(
          padding: const EdgeInsets.only(left: 8.0, top: 0),
          child: Text(
            imageHolder.decoded ? "UNCOMPRESSED" : "UNCOMPRESSING",
            style: Theme.of(context)
                .textTheme
                .bodyText2
                .copyWith(color: Colors.white),
          ),
        ),
      if (imageHolder.encoded || imageHolder.encoding)
        Padding(
          padding: const EdgeInsets.only(left: 8.0, top: 20),
          child: Text(
            imageHolder.encoded ? "COMPRESSED" : "COMPRESSING",
            style: Theme.of(context)
                .textTheme
                .bodyText2
                .copyWith(color: Colors.white),
          ),
        ),
      if (imageHolder.dirty)
        Padding(
          padding: const EdgeInsets.only(left: 8.0, top: 40),
          child: Text(
            "DIRTY",
            style: Theme.of(context)
                .textTheme
                .bodyText2
                .copyWith(color: Colors.white),
          ),
        ),
    ];
  }
}

class ImageDisplayOnlyDecoded extends StatelessWidget {
  final ui.Image image;

  ImageDisplayOnlyDecoded({@required this.image});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ImagePainter(image: image),
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
