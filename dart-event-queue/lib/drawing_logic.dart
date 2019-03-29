import 'dart:ui';
import 'dart:ui' as Ui;

import 'package:event_queue_flutter/event_queue_test.dart';
import 'package:event_queue_flutter/shared_data.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

class DrawingLogic {
  Subject<Offset> _touchEventController = BehaviorSubject<Offset>();

  Sink<Offset> get touchEventSink => _touchEventController;

  final SharedData sharedData;

  final Sink<Ui.Image> imageSink;

  final EventQueue eventQueue;

  Offset previous;

  DrawingLogic({@required this.sharedData, this.imageSink, this.eventQueue}) {
    _touchEventController.listen((coord) {
      //eventQueue.eventSink.add(() {
        _draw(coord);
      //});
    });
  }

  void _draw(Offset coord) async {
    if (previous != null && coord != null) {
      final pictureRecorder = PictureRecorder();
      final canvas = Canvas(pictureRecorder);
      canvas.drawImage(sharedData.image, Offset.zero, Paint());
      canvas.drawLine(previous, coord, Paint()
        ..strokeWidth = 4);
      final picture = pictureRecorder.endRecording();
      sharedData.image = await picture.toImage(
        sharedData.image.width,
        sharedData.image.height,
      );
      imageSink.add(sharedData.image);
    }

    previous = coord;
  }

  void dispose() {
    _touchEventController.close();
  }
}
