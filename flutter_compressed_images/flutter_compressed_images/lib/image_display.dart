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
  bool _memoryImageReady = false;
  MemoryImage _memoryImage;
  ui.Image _cachedImage;

  @override
  void initState() {
    if (widget.imageHolder.decoded) {
      _loadUiImage();
    } else {
      _loadPng();
    }
    super.initState();
  }

  @override
  void didUpdateWidget(ImageDisplay oldWidget) {
    final hashCode = widget.imageHolder.hashCode;
    if (widget.imageHolder.decoded) {
      print("$hashCode Image is decoded, so will cache it...");
      _loadUiImage();
    } else if (widget.imageHolder.encoded) {
      if (_memoryImageReady == false) {
        print("$hashCode Waiting for PNG decode before discarding cache");
        _loadPng();
      }
    }

    super.didUpdateWidget(oldWidget);
  }

  void _loadPng() {
    setState(() => _memoryImage = MemoryImage(widget.imageHolder.pngBytes));
    _memoryImage.resolve(ImageConfiguration.empty).addListener(
          ImageStreamListener(
            (imageInfo, synchronousCall) {
              final hashCode = widget.imageHolder.hashCode;
              final stillNecessary =
                  widget.imageHolder.encoded || widget.imageHolder.decoding;
              if (mounted && stillNecessary) {
                print("$hashCode PNG ready, discarding cache");
                setState(() {
                  _memoryImageReady = true;
                  _cachedImage = null;
                });
              }
            },
            onError: (error, stackTrace) {
              print("Image load error: $error");
              print(stackTrace);
            },
          ),
        );
  }

  void _loadUiImage() {
    widget.imageHolder.uiImage.then((image) {
      final stillNecessary = widget.imageHolder.decoded ||
          widget.imageHolder.encoding ||
          !_memoryImageReady;
      if (mounted && stillNecessary) {
        setState(() {
          _memoryImageReady = false;
          _memoryImage = null;
          _cachedImage = image;
        });
      }
      print("$hashCode Cache updated");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        _buildImage(),
        ..._buildDecodeEncodeStateText(
          context: context,
          imageHolder: widget.imageHolder,
        ),
      ],
    );
  }

  Widget _buildImage() {
    if (_memoryImageReady) {
      return Image(
        image: _memoryImage,
        fit: BoxFit.fill,
        filterQuality: FilterQuality.none,
        gaplessPlayback: true,
      );
    } else {
      if (_cachedImage == null) {
        return Container(
          color: Colors.transparent,
        );
      } else {
        return CustomPaint(
          painter: ImagePainter(image: _cachedImage),
        );
      }
    }
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
