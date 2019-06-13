@JS()
library udp;

import 'dart:typed_data';

import 'package:js/js.dart';

@JS()
class Udp {
  external factory Udp();
  external void listen(int port, Function onListening, Function onMessage, Function onError);
  external void send(Uint8List message, String address, int port);
  external void close();
}

@JS()
@anonymous
class RInfo {
  external String get address;
  external String get family;
  external int get port;
  external int get size;

  external factory RInfo({
    String address,
    String family,
    int port,
    int size,
  });
}
