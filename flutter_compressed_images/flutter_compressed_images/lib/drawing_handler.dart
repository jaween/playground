import 'dart:ui';

import 'package:flutter/material.dart' hide Image;
import 'package:flutter/scheduler.dart';

/// Takes input drawing pointer events and schedules painting each frame.
class DrawingHandler {
  final Image image;
  final Function onImageReady;

  Path _path;
  Image _completeImage;
  Image _workingImage;
  bool _scheduled = false;

  DrawingHandler({@required this.image, @required this.onImageReady})
      : _completeImage = image;

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
        ..strokeWidth = 25,
    );

    return await pictureRecorder
        .endRecording()
        .toImage(image.width, image.height);
  }
}
