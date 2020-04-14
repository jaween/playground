import 'dart:ui';

import 'package:flutter/material.dart' hide Image;
import 'package:flutter/scheduler.dart';

/// Takes input drawing pointer events and schedules painting each frame.
class DrawingHandler {
  static const drawingSize = Size(512, 512);

  final Function onImageReady;

  Path _path;
  Image _image;
  Image _working;
  bool _scheduled = false;

  DrawingHandler({@required this.onImageReady});

  void init() async {
    final pictureRecorder = PictureRecorder();
    Canvas(pictureRecorder);
    final picture = pictureRecorder.endRecording();
    _image = await picture.toImage(
        drawingSize.width.toInt(), drawingSize.height.toInt());
    _working = _image;
    onImageReady(_working);
  }

  void start(Offset p) {
    _path = Path();
    _path.moveTo(p.dx, p.dy);
    if (!_scheduled) {
      final clonedPath = Path.from(_path);
      SchedulerBinding.instance.addPostFrameCallback((duration) {
        _draw(Path.from(clonedPath), _image).then((image) {
          _working = image;
          onImageReady(_working);
          _scheduled = false;
        });
      });
      SchedulerBinding.instance.scheduleFrame();
      _scheduled = true;
    }
  }

  void move(Offset p) {
    _path.lineTo(p.dx, p.dy);
    if (!_scheduled) {
      final clonedPath = Path.from(_path);
      SchedulerBinding.instance.addPostFrameCallback((duration) {
        _draw(Path.from(clonedPath), _image).then((image) {
          _working = image;
          onImageReady(_working);
          _scheduled = false;
        });
      });
      SchedulerBinding.instance.scheduleFrame();
      _scheduled = true;
    }
  }

  Future<Image> _draw(Path path, Image image) async {
    final pictureRecorder = PictureRecorder();
    final canvas = Canvas(pictureRecorder);

    canvas.drawImage(_image, Offset.zero, Paint());
    canvas.drawPath(
      path,
      Paint()
        ..isAntiAlias = true
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8,
    );

    return await pictureRecorder
        .endRecording()
        .toImage(drawingSize.width.toInt(), drawingSize.height.toInt());
  }

  void end() {
    // TODO: If we end the touch gesture before the most recent drawing is
    // complete, we lose the last segment of the drawing path
    _image = _working;
  }
}
