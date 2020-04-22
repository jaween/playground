import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ImageHolder {
  static const size = Size(16, 16);

  Uint8List _pngBytes;

  ImageHolder();

  ImageHolder.fromPng(Uint8List pngBytes) : _pngBytes = pngBytes;

  Future<void> createImage(VoidCallback onImageReady) async {
    final pictureRecorder = PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    const colorList = [Colors.orange, Colors.blue, Colors.pink, Colors.purple];
    final random = Random();
    final index = random.nextInt(colorList.length);
    canvas.drawColor(colorList[index], BlendMode.color);
    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(

      size.width.toInt(),
      size.height.toInt(),
    );
    final bytes = await image.toByteData(format: ImageByteFormat.png);
    _pngBytes = bytes.buffer.asUint8List();
    onImageReady();
  }

  Uint8List pngBytes() => _pngBytes;

  Future<ui.Image> image() async {
    if (_pngBytes == null) {
      return null;
    }
    final bytes = _pngBytes;
    final codec = await instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }
}
