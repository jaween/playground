import 'dart:ui';

import 'package:flutter/material.dart' hide Image;
import 'package:flutter/scheduler.dart';

/// Takes input drawing pointer events and schedules painting each frame.
class DrawingHandler {
  static const drawingSize = Size(64, 64);

  final Function onImageReady;

  Path _path;
  Image _completeImage;
  Image _workingImage;
  bool _scheduled = false;

  DrawingHandler({@required this.onImageReady});

  void init() async {
    final pictureRecorder = PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    canvas.drawColor(Colors.orange, BlendMode.dst);
    final picture = pictureRecorder.endRecording();
    _completeImage = await picture.toImage(
        drawingSize.width.toInt(), drawingSize.height.toInt());
    _workingImage = _completeImage;
    onImageReady(_workingImage);
  }

  void start(Offset p) {
    _path = Path();
    _path.moveTo(p.dx, p.dy);
    _maybeScheduleDraw();
  }

  void move(Offset p) {
    _path.lineTo(p.dx, p.dy);
    _maybeScheduleDraw();
  }

  void end() {
    // TODO: If we end the touch gesture before the most recent drawing is
    // complete, we lose the last segment of the drawing path
    _completeImage = _workingImage;
  }

  void _maybeScheduleDraw() {
    if (!_scheduled) {
      final clonedPath = Path.from(_path);
      SchedulerBinding.instance.addPostFrameCallback((_) async {
        final image = await _draw(Path.from(clonedPath), _completeImage);
        _workingImage = image;
        _scheduled = false;
        onImageReady(_workingImage);
      });
      SchedulerBinding.instance.scheduleFrame();
      _scheduled = true;
    }
  }

  Future<Image> _draw(Path path, Image previousImage) async {
    final pictureRecorder = PictureRecorder();
    final canvas = Canvas(pictureRecorder);

    if (previousImage != null) {
      canvas.drawImage(previousImage, Offset.zero, Paint());
    } else {
      print("${DateTime.now()} Image is null");
    }

    canvas.drawPath(
      path,
      Paint()
        ..isAntiAlias = true
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    return await pictureRecorder
        .endRecording()
        .toImage(drawingSize.width.toInt(), drawingSize.height.toInt());
  }
}

Future<Image> _clone(Image image) async {
  final clone = await image.toByteData(format: ImageByteFormat.png);
  final codec = await instantiateImageCodec(clone.buffer.asUint8List());
  final frame = await codec.getNextFrame();
  return frame.image;
}
