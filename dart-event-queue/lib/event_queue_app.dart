import 'dart:ui' as Ui;

import 'package:event_queue_flutter/drawing_logic.dart';
import 'package:event_queue_flutter/event_queue_test.dart';
import 'package:event_queue_flutter/shared_data.dart';
import 'package:event_queue_flutter/surface.dart';
import 'package:event_queue_flutter/undo_logic.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class EventQueueApp extends StatefulWidget {
  @override
  _EventQueueAppState createState() => _EventQueueAppState();
}

class _EventQueueAppState extends State<EventQueueApp> {
  final _sharedData = SharedData();
  Subject<Ui.Image> _imageController;
  Subject<Ui.Image> _completeImageController;
  EventQueue _eventQueue;
  DrawingLogic _drawingLogic;
  UndoLogic _undoLogic;

  @override
  void initState() {
    super.initState();

    _imageController = BehaviorSubject();
    _completeImageController = BehaviorSubject();
    _eventQueue = EventQueue();
    _drawingLogic = DrawingLogic(
      sharedData: _sharedData,
      eventSink: _eventQueue.eventSink,
      imageSink: _imageController.sink,
      completeImageSink: _completeImageController.sink,
    );
    _undoLogic = UndoLogic(
      sharedData: _sharedData,
      eventSink: _eventQueue.eventSink,
      imageSink: _imageController.sink,
      completeImageSink: _completeImageController.sink,
      completeImageStream: _completeImageController.stream,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      var pictureRecorder = Ui.PictureRecorder();
      var canvas = Canvas(pictureRecorder);
      canvas.drawColor(Colors.white, BlendMode.clear);
      var picture = pictureRecorder.endRecording();
      var image = await picture.toImage(
        context.size.width.toInt(),
        context.size.height.toInt(),
      );
      _sharedData.image = image;
      _imageController.add(image);
      _completeImageController.add(image);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _imageController.close();
    _completeImageController.close();
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
        Align(
          alignment: Alignment.bottomCenter,
          child: Material(
            type: MaterialType.transparency,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.undo),
                  onPressed: () => _undoLogic.undo(),
                ),
                IconButton(
                  icon: Icon(Icons.redo),
                  onPressed: () => _undoLogic.redo(),
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.topLeft,
          child: SafeArea(
            child: Row(
              children: <Widget>[
                Checkbox(
                  onChanged: (value) => setState(() => _eventQueue.useEventQueue = value),
                  value: _eventQueue.useEventQueue,
                ),
                Text("Use EventQueue"),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
