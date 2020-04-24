import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ImageHolder {
  static const size = Size(1500, 1500);

  Uint8List _pngBytes;
  ui.Image _image;
  Completer<ui.Image> _pngDecodeCompleter;
  bool _editMode = false;
  bool _dirty = false;

  ImageHolder._({@required Uint8List pngBytes}): _pngBytes = pngBytes;

  static Future<ImageHolder> create() async {
    final pictureRecorder = PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    const colorList = [
      Colors.orange,
      Colors.blue,
      Colors.pink,
      Colors.purple,
      Colors.green,
      Colors.amber,
      Colors.brown,
      Colors.cyan,
      Colors.lightGreen,
      Colors.lightBlue
    ];
    final random = Random();
    final index = random.nextInt(colorList.length);
    canvas.drawColor(colorList[index], BlendMode.color);
    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(
      size.width.toInt(),
      size.height.toInt(),
    );
    final bytes = await image.toByteData(format: ImageByteFormat.png);
    return ImageHolder._(pngBytes: bytes.buffer.asUint8List());
  }

  Future<void> createImage({@required VoidCallback onImageReady}) async {

    onImageReady();
  }

  bool get dirty => _dirty;

  bool get editMode => _editMode;

  Uint8List get pngBytes => _pngBytes;

  Future<ui.Image> get uiImage => _pngDecodeCompleter.future;

  Future<void> beginEditing() {
    if (editMode) {
      return _pngDecodeCompleter.future;
    }

    _editMode = true;
    _pngDecodeCompleter = Completer<ui.Image>();
    final decode = () async {
      final codec = await instantiateImageCodec(_pngBytes);
      final frame = await codec.getNextFrame();
      _image = frame.image;
      _pngDecodeCompleter?.complete(_image);
    };
    decode();
    return _pngDecodeCompleter.future;
  }

  void edited({@required ui.Image edited}) async {
    assert(editMode);
    _image = edited;
    _dirty = true;
    _pngDecodeCompleter = Completer<ui.Image>();
    _pngDecodeCompleter.complete(edited);
  }

  Future<void> endEditing() async {
    assert(editMode);

    if (dirty) {
      final pngByteData = await _image.toByteData(format: ImageByteFormat.png);
      _pngBytes = pngByteData.buffer.asUint8List();
    }

    _editMode = false;
    _pngDecodeCompleter = null;
    _image = null;
    _dirty = false;
  }
}

/**
    Uint8List _pngBytes;
    ui.Image _image;
    Completer<ui.Image> _imageCompleter;

    bool get editMode;

    Uint8List get readOnlyImage {
    assert(!editMode);
    return _pngBytes;
    }

    Future<ui.Image> beginEditing() async {
    if (editMode) {
    return Future.value(_image);
    }

    final decode = () async {
    final codec = await instantiateImageCodec(_pngBytes);
    final frame = await codec.getNextFrame();
    _image = frame.image;
    editMode = true;
    _imageCompleter.completer(_image);
    };
    decode();
    return _imageCompleter.future;
    }

    Future<void> completeEditing({ui.Image image}) async {
    assert(editMode);
    if (_editMode && image != null && image != _image) {
    _pngData = await image.toByteData(format: PNG);
    _image = null;
    }
    _editMode = false;
    }
 */
