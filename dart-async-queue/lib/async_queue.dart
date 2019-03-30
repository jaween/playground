import 'dart:async';

typedef Event = Future<void> Function();

class AsyncQueue {
  var _eventController = StreamController<Event>();
  Sink<Event> get eventSink => _eventController.sink;

  var _progressController = StreamController<double>.broadcast();
  Stream<double> get progressStream => _progressController.stream;

  final _events = <Event>[];
  bool _running = false;
  bool useAsyncQueue = true;

  AsyncQueue() {
    _run();
  }

  void dispose() {
    _eventController.close();
    _progressController.close();
  }

  void _run() {
    _eventController.stream.listen((Event event) async {
      if (!useAsyncQueue) {
        event();
        return;
      }

      _events.add(event);

      // UI progress bar
      _progressController.add(1/(_events.length + 1));

      // This event may have been added while other events are being executed
      while (!_running && _events.isNotEmpty) {
        // Execute event
        _running = true;
        await _events.first();
        _events.removeAt(0);
        _running = false;

        // UI progress bar
        _progressController.add(1/(_events.length + 1));
      }
    });
  }
}
