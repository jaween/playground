import 'dart:ui' as Ui;

import 'package:async_queue_flutter/drawing_logic.dart';
import 'package:async_queue_flutter/async_queue.dart';
import 'package:async_queue_flutter/shared_data.dart';
import 'package:async_queue_flutter/surface.dart';
import 'package:async_queue_flutter/undo_logic.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class AsyncQueueApp extends StatefulWidget {
  @override
  _AsyncQueueAppState createState() => _AsyncQueueAppState();
}

class _AsyncQueueAppState extends State<AsyncQueueApp> {
  final _sharedData = SharedData();
  Subject<Ui.Image> _imageController;
  Subject<Ui.Image> _completeImageController;
  AsyncQueue _asyncQueue;
  DrawingLogic _drawingLogic;
  UndoLogic _undoLogic;

  @override
  void initState() {
    super.initState();

    _imageController = BehaviorSubject();
    _completeImageController = BehaviorSubject();
    _asyncQueue = AsyncQueue();
    _drawingLogic = DrawingLogic(
      sharedData: _sharedData,
      eventSink: _asyncQueue.eventSink,
      imageSink: _imageController.sink,
      completeImageSink: _completeImageController.sink,
    );
    _undoLogic = UndoLogic(
      sharedData: _sharedData,
      eventSink: _asyncQueue.eventSink,
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
          alignment: Alignment.topCenter,
          child: SafeArea(
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    _buildLoadingSpinner(),
                    Expanded(
                      child: _buildCheckbox(),
                    ),
                  ],
                ),
                _buildLoadingBar(),
              ],
            ),
          ),
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
      ],
    );
  }

  Widget _buildCheckbox() {
    return CheckboxListTile(
      title: Text("Use AsyncQueue"),
      onChanged: (value) =>
          setState(() => _asyncQueue.useAsyncQueue = value),
      value: _asyncQueue.useAsyncQueue,
    );
  }

  Widget _buildLoadingSpinner() {
    return StreamBuilder<double>(
      stream: _asyncQueue.progressStream,
      initialData: 1.0,
      builder: (context, snapshot) {
        final processing = snapshot.data != 1;
        final visible = processing && _asyncQueue.useAsyncQueue;
        return Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Opacity(
            opacity: visible ? 1.0 : 0.0,
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  Widget _buildLoadingBar() {
    return StreamBuilder<double>(
      stream: _asyncQueue.progressStream,
      initialData: 1,
      builder: (context, snapshot) {
        return LinearProgressIndicator(
          value: snapshot.data,
        );
      },
    );
  }
}
