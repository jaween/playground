import 'dart:ui' as Ui;

import 'package:event_queue_flutter/drawing_logic.dart';
import 'package:event_queue_flutter/event_queue_test.dart';
import 'package:event_queue_flutter/shared_data.dart';
import 'package:event_queue_flutter/surface.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class EventQueueApp extends StatefulWidget {
  @override
  _EventQueueAppState createState() => _EventQueueAppState();
}

class _EventQueueAppState extends State<EventQueueApp> {
  final _sharedData = SharedData();
  Subject<Ui.Image> _imageController;
  EventQueue _eventQueue;
  DrawingLogic _drawingLogic;

  @override
  void initState() {
    super.initState();

    _imageController = BehaviorSubject();
    _eventQueue = EventQueue();
    _drawingLogic = DrawingLogic(
      sharedData: _sharedData,
      imageSink: _imageController.sink,
      eventQueue: _eventQueue,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      var pictureRecorder = Ui.PictureRecorder();
      var canvas = Canvas(pictureRecorder);
      canvas.drawColor(Colors.orange, BlendMode.color);
      var picture = pictureRecorder.endRecording();
      var image = await picture.toImage(
        context.size.width.toInt(),
        context.size.height.toInt(),
      );
      _sharedData.image = image;
      _imageController.add(image);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _imageController.close();
    _drawingLogic.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Surface(
          imageStream: _imageController.stream,
          touchEventSink: _drawingLogic.touchEventSink,
        ),
      ],
    );
  }
}
