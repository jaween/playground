import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:async/async.dart';
import 'package:flutter/foundation.dart';

/// Contains the image data that is stored as a PNG (compressed) for reduced
/// memory usage and viewing, or as raw ARGB values (decompressed) for editing.
///
/// While decompressed, the compressed PNG data is still available.
class ImageHolder {
  Size _size;
  Uint8List _pngBytes;
  Image _image;
  bool _dirty = false;

  _CompressionState _state = _CompressionState.compressed;
  CancelableCompleter<Image> _decompressCompleter;
  CancelableCompleter<Uint8List> _compressCompleter;

  ImageHolder({
    @required Size size,
    @required Uint8List pngBytes,
  })  : _size = size,
        _pngBytes = pngBytes {
    _compressCompleter = CancelableCompleter<Uint8List>();
    _compressCompleter.complete(_pngBytes);
  }

  Size get size => _size;

  bool get dirty => _dirty;

  bool get decompressed => _state == _CompressionState.decompressed;

  bool get decompressing => _state == _CompressionState.decompressing;

  bool get compressed => _state == _CompressionState.compressed;

  bool get compressing => _state == _CompressionState.compressing;

  Uint8List get pngBytes => _pngBytes;

  Image get uiImage => _image;

  /// Decompresses the image if it isn't already. Access the ARGB values via
  /// [uiImage].
  Future<void> beginEditing() {
    if (_state == _CompressionState.compressing) {
      // Quick exit
      _compressCompleter?.operation?.cancel();
      _decompressCompleter = CancelableCompleter<Image>();
      _state = _CompressionState.decompressed;
      _decompressCompleter.complete(_image);
      return _decompressCompleter.operation.value;
    } else if (_state == _CompressionState.decompressed ||
        _state == _CompressionState.decompressing) {
      return _decompressCompleter.operation.value;
    }

    final completer = CancelableCompleter<Image>();
    _decompressCompleter = completer;
    _begin(completer);
    return _decompressCompleter.operation.value;
  }

  void _begin(CancelableCompleter<Image> completer) async {
    _state = _CompressionState.decompressing;
    final codec = await instantiateImageCodec(_pngBytes);
    final frame = await codec.getNextFrame();

    if (!completer.isCanceled) {
      _image = frame.image;
      _state = _CompressionState.decompressed;
      completer.complete(_image);
    }
  }

  /// Compresses the image if the drawing is decompressed and has been edited
  /// (is [dirty]). Access the PNG bytes via [pngBytes].
  Future<void> endEditing() {
    if (_state == _CompressionState.decompressing) {
      // Quick exit
      _decompressCompleter?.operation?.cancel();
      _compressCompleter = CancelableCompleter<Uint8List>();
      _state = _CompressionState.compressed;
      _compressCompleter.complete(_pngBytes);
      return _compressCompleter.operation.value;
    } else if (_state == _CompressionState.compressed ||
        _state == _CompressionState.compressing) {
      return _compressCompleter.operation.value;
    }

    final completer = CancelableCompleter<Uint8List>();
    _compressCompleter = completer;
    _end(completer);
    return _compressCompleter.operation.value;
  }

  void _end(CancelableCompleter<Uint8List> completer) async {
    _state = _CompressionState.compressing;
    if (dirty) {
      final pngByteData = await _image.toByteData(format: ImageByteFormat.png);
      if (!completer.isCanceled) {
        _pngBytes = pngByteData.buffer.asUint8List();
        _image = null;
        _dirty = false;
        _state = _CompressionState.compressed;

        completer.complete(_pngBytes);
      }
    } else {
      _state = _CompressionState.compressed;
      completer.complete(_pngBytes);
    }
  }

  /// Update the image when it is in the uncompressed state.
  void edited({@required Image edited}) async {
    if (_state != _CompressionState.decompressed) {
      assert(false, 'Not ready for editing, currently is $_state!');
      return;
    }

    if (edited.width != size.width || edited.height != size.height) {
      assert(
        false,
        'Edited size of ${edited.width}x${edited.height} is not image size of $size',
      );
    }

    _image = edited;
    _dirty = true;

    _decompressCompleter = CancelableCompleter<Image>();
    _decompressCompleter.complete(edited);
  }
}

enum _CompressionState {
  compressed,
  compressing,
  decompressed,
  decompressing,
}
