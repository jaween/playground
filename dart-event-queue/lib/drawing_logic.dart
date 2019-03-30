import 'dart:ui';
import 'dart:ui' as Ui;

import 'package:event_queue_flutter/event_queue_test.dart';
import 'package:event_queue_flutter/shared_data.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

class DrawingLogic {
  Subject<TouchEvent> _touchEventController = BehaviorSubject<TouchEvent>();

  Sink<TouchEvent> get touchEventSink => _touchEventController;

  final SharedData sharedData;

  final Sink<Ui.Image> imageSink;

  final Sink<Ui.Image> completeImageSink;

  TouchEvent _previousEvent;

  double _hue = 0;

  DrawingLogic({
    @required this.sharedData,
    @required Sink<Event> eventSink,
    this.imageSink,
    this.completeImageSink,
  }) {
    _touchEventController.listen((coord) {
      eventSink.add(() => _draw(coord));
    });
  }

  Future<void> _draw(TouchEvent event) async {
    switch (event.type) {
      case EventType.Start:
        _previousEvent = event;
        break;
      case EventType.Update:
        final gradient = _createGradient(_previousEvent.offset, event.offset);

        final pictureRecorder = PictureRecorder();
        final canvas = Canvas(pictureRecorder);
        canvas.drawImage(sharedData.image, Offset.zero, Paint());
        canvas.drawLine(
          _previousEvent.offset,
          event.offset,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 8
            ..shader = gradient
            ..isAntiAlias = false
            ..strokeCap = StrokeCap.round,
        );
        final picture = pictureRecorder.endRecording();
        sharedData.image = await picture.toImage(
          sharedData.image.width,
          sharedData.image.height,
        );
        imageSink.add(sharedData.image);
        _previousEvent = event;
        break;
      case EventType.End:
        completeImageSink.add(sharedData.image);
        break;
    }
  }

  Ui.Gradient _createGradient(Offset from, Offset to) {
    const stopDegrees = 360 / 36;
    final colors = <Color>[_colorFromHsl(_hue)];
    final colorStops = <double>[0.0];
    final segmentLength = (to - from).distance;
    var remainingLength = segmentLength;
    while (true) {
      final nextStopHue =
          _hue + ((_hue + stopDegrees) ~/ stopDegrees) * stopDegrees;
      if (_hue + remainingLength < nextStopHue) {
        _hue = (_hue + remainingLength) % 360;
        colors.add(_colorFromHsl(_hue));
        colorStops.add(1.0);
        break;
      } else {
        _hue = nextStopHue % 360;
        remainingLength -= stopDegrees;
        colors.add(_colorFromHsl(_hue));
        colorStops.add(1 - remainingLength / segmentLength);
      }
    }

    return Ui.Gradient.linear(
      from,
      to,
      colors,
      colorStops,
    );
  }

  Color _colorFromHsl(double hue) =>
      HSLColor.fromAHSL(1.0, hue, 1.0, 0.5).toColor();

  void dispose() {
    _touchEventController.close();
  }
}
