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

class SharedData {
  List<int> values = [];
}

class Worker {
  final Sink<Event> eventQueue;
  final SharedData sharedData;

  StreamController<int> _controller = StreamController<int>.broadcast();

  Sink<int> get sink => _controller.sink;

  Worker(this.eventQueue, this.sharedData) {
    _controller.stream.listen((value) {
      eventQueue.add(() async {
        final random = Random();
        var delayMs = random.nextInt(40) + 20;
        await Future.delayed(Duration(milliseconds: delayMs));
        sharedData.values.add(value);
      });
    });
  }

  void dispose() {
    _controller.close();
  }
}

void main() async {
  final eventQueue = EventQueue();
  final sharedData = SharedData();
  final worker1 = Worker(eventQueue.eventSink, sharedData);
  final worker2 = Worker(eventQueue.eventSink, sharedData);
  final values = [];
  int number = 0;
  for (var i = 0; i < 3; i++) {
    eventQueue.eventSink.add(() {
      values.add(number);
      worker1.sink.add(number);
      number++;
    });
  }
  for (var i = 0; i < 3; i++) {
    eventQueue.eventSink.add(() {
      values.add(number);
      worker2.sink.add(number);
      number++;
    });
  }

  await Future.delayed(Duration(milliseconds: 1000));
  print("Values should be $values");
  print("Values was       ${sharedData.values}");

  worker1.dispose();
  worker2.dispose();
  eventQueue.dispose();
}