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
    if (widget.imageHolder.decompressed) {
      _cacheUiImage();
    } else {
      _loadPng();
    }
    super.initState();
  }

  @override
  void didUpdateWidget(ImageDisplay oldWidget) {
    final hashCode = widget.imageHolder.hashCode;
    if (widget.imageHolder.decompressed) {
      _cacheUiImage();
    } else if (widget.imageHolder.compressed) {
      if (_memoryImageReady == false) {
        print(
            "$hashCode Waiting for PNG decompression before discarding cache");
        _loadPng();
      }
    }

    super.didUpdateWidget(oldWidget);
  }

  void _cacheUiImage() {
    setState(() {
      _memoryImageReady = false;
      _memoryImage = null;
      _cachedImage = widget.imageHolder.uiImage;
    });
  }

  void _loadPng() {
    setState(() => _memoryImage = MemoryImage(widget.imageHolder.pngBytes));
    _memoryImage.resolve(ImageConfiguration.empty).addListener(
          ImageStreamListener(
            (imageInfo, synchronousCall) {
              final hashCode = widget.imageHolder.hashCode;
              final stillNecessary = widget.imageHolder.compressed ||
                  widget.imageHolder.decompressing;
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        _buildImage(),
        ..._buildCompressionStateText(
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

  List<Widget> _buildCompressionStateText({
    @required BuildContext context,
    @required ImageHolder imageHolder,
  }) {
    return [
      if (imageHolder.decompressed || imageHolder.decompressing)
        Padding(
          padding: const EdgeInsets.only(left: 8.0, top: 0),
          child: Text(
            imageHolder.decompressed ? "UNCOMPRESSED" : "UNCOMPRESSING",
            style: Theme.of(context)
                .textTheme
                .bodyText2
                .copyWith(color: Colors.white),
          ),
        ),
      if (imageHolder.compressed || imageHolder.compressing)
        Padding(
          padding: const EdgeInsets.only(left: 8.0, top: 20),
          child: Text(
            imageHolder.compressed ? "COMPRESSED" : "COMPRESSING",
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

class ImageDisplayOnlyDecompressed extends StatelessWidget {
  final ui.Image image;

  ImageDisplayOnlyDecompressed({@required this.image});

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
