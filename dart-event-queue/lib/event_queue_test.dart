import 'dart:async';
import 'dart:math';

typedef Event = Future<void> Function();

class EventQueue {
  var _eventController = StreamController<Event>();
  Sink<Event> get eventSink => _eventController.sink;
  final _events = <Event>[];
  bool running = false;

  EventQueue() {
    _run();
  }

  void dispose() {
    _eventController.close();
  }

  void _run() {
    _eventController.stream.listen((Event event) async {
      _events.add(event);
      while (!running && _events.isNotEmpty) {
        final now = DateTime.now();
        print("Starting event $now");
        running = true;
        await _events.first();
        _events.removeAt(0);
        running = false;
        print("Received done $now");
      }
    });
  }
}
