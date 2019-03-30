import 'dart:ui' as Ui;

import 'package:event_queue_flutter/event_queue_test.dart';
import 'package:event_queue_flutter/shared_data.dart';
import 'package:meta/meta.dart';

class UndoLogic {
  SharedData sharedData;
  Sink<Event> eventSink;
  Sink<Ui.Image> imageSink;
  Sink<Ui.Image> completeImageSink;
  List<Ui.Image> undoImages = [];
  List<Ui.Image> redoImages = [];
  bool _ignoreNext = false;

  UndoLogic({
    @required this.sharedData,
    @required this.eventSink,
    @required this.imageSink,
    @required this.completeImageSink,
    @required Stream<Ui.Image> completeImageStream,
  }) {
    completeImageStream.listen((image) {
      if (_ignoreNext) {
        _ignoreNext = false;
        return;
      }

      undoImages.add(image);
      redoImages.clear();
      if (undoImages.length > 200) {
        undoImages.removeAt(0);
      }
    });
  }

  void undo() => eventSink.add(() => _undo());

  void redo() => eventSink.add(() => _redo());

  Future<void> _undo() async {
    if (undoImages.length < 2) {
      return Future.value(null);
    }

    // Artificial delay
    await Future.delayed(Duration(milliseconds: 350));

    redoImages.add(undoImages.removeLast());
    final image = undoImages.last;
    _ignoreNext = true;
    sharedData.image = image;
    imageSink.add(image);
    completeImageSink.add(image);
  }

  Future<void> _redo() async {
    if (redoImages.length == 0) {
      return Future.value(null);
    }

    // Artificial delay
    await Future.delayed(Duration(milliseconds: 350));

    final image = redoImages.removeLast();
    undoImages.add(image);
    _ignoreNext = true;
    sharedData.image = image;
    imageSink.add(image);
    completeImageSink.add(image);
  }
}