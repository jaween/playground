import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:async/async.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ImageHolder {
  static const size = Size(1500, 1500);

  Uint8List _pngBytes;
  ui.Image _image;
  CancelableCompleter<ui.Image> _decodeCompleter;
  CancelableCompleter<Uint8List> _encodeCompleter;
  bool _dirty = false;

  ImageHolder._({@required Uint8List pngBytes}) : _pngBytes = pngBytes {
    _encodeCompleter = CancelableCompleter<Uint8List>();
    _encodeCompleter.complete(_pngBytes);
  }

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

  _ImgState _state = _ImgState.encoded;

  bool get decoded => _state == _ImgState.decoded;

  bool get decoding => _state == _ImgState.decoding;

  bool get encoded => _state == _ImgState.encoded;

  bool get encoding => _state == _ImgState.encoding;

  Uint8List get pngBytes => _pngBytes;

  Future<ui.Image> get uiImage =>
      _decodeCompleter?.operation?.value ?? Future.value(_image);

  Future<void> beginEditing() {
    if (_state == _ImgState.encoding) {
      // Quick exit
      _encodeCompleter?.operation?.cancel();
      _decodeCompleter = CancelableCompleter<ui.Image>();
      _state = _ImgState.decoded;
      _decodeCompleter.complete(_image);
      return _decodeCompleter.operation.value;
    } else if (_state == _ImgState.decoded || _state == _ImgState.decoding) {
      return _decodeCompleter.operation.value;
    }

    final completer = CancelableCompleter<ui.Image>();
    _decodeCompleter = completer;
    _begin(completer);
    return _decodeCompleter.operation.value;
  }

  void _begin(CancelableCompleter<ui.Image> completer) async {
    _state = _ImgState.decoding;
    final codec = await instantiateImageCodec(_pngBytes);
    final frame = await codec.getNextFrame();

    if (!completer.isCanceled) {
      _image = frame.image;
      _state = _ImgState.decoded;
      completer.complete(_image);
    }
  }

  Future<void> endEditing() {
    if (_state == _ImgState.decoding) {
      // Quick exit
      _decodeCompleter?.operation?.cancel();
      _encodeCompleter = CancelableCompleter<Uint8List>();
      _state = _ImgState.encoded;
      _encodeCompleter.complete(_pngBytes);
      return _encodeCompleter.operation.value;
    } else if (_state == _ImgState.encoded || _state == _ImgState.encoding) {
      return _encodeCompleter.operation.value;
    }

    final completer = CancelableCompleter<Uint8List>();
    _encodeCompleter = completer;
    _end(completer);
    return _encodeCompleter.operation.value;
  }

  void _end(CancelableCompleter<Uint8List> completer) async {
    _state = _ImgState.encoding;
    if (dirty) {
      final pngByteData = await _image.toByteData(format: ImageByteFormat.png);
      if (!completer.isCanceled) {
        _pngBytes = pngByteData.buffer.asUint8List();
        _dirty = false;
        _state = _ImgState.encoded;

        completer.complete(_pngBytes);
      }
    } else {
      _state = _ImgState.encoded;
      completer.complete(_pngBytes);
    }
  }

  void edited({@required ui.Image edited}) async {
    if (_state != _ImgState.decoded) {
      assert(false, 'Not decdoded!');
      return;
    }

    _image = edited;
    _dirty = true;

    _decodeCompleter = CancelableCompleter<ui.Image>();
    _decodeCompleter.complete(edited);
  }
}

enum _ImgState {
  encoded,
  encoding,
  decoded,
  decoding,
}
