import 'dart:ui' as Ui;

class SharedData {
  Ui.Image image;
}

enum EventType {
  Start, Update, End
}

class TouchEvent {
  EventType type;
  Ui.Offset offset;
}
