import 'dart:async';

typedef Event = Future<void> Function();

class EventQueue {
  var _eventController = StreamController<Event>();
  Sink<Event> get eventSink => _eventController.sink;
  final _events = <Event>[];
  bool _running = false;
  bool useEventQueue = true;

  EventQueue() {
    _run();
  }

  void dispose() {
    _eventController.close();
  }

  void _run() {
    _eventController.stream.listen((Event event) async {
      if (!useEventQueue) {
        event();
        return;
      }

      _events.add(event);
      while (!_running && _events.isNotEmpty) {
        final now = DateTime.now();
        print("Starting event $now");
        _running = true;
        await _events.first();
        _events.removeAt(0);
        _running = false;
        print("Received done $now");
      }
    });
  }
}
