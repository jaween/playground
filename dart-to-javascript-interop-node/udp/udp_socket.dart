import 'dart:js';
import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:js/js.dart';
import 'udp.dart';

class UdpSocket {
  final Udp _udp;

  UdpSocket() : _udp = Udp();

  void listen(int port,
      {@required onListening(String address, int port),
      @required onMessage(Uint8List message, RInfo rinfo),
      void onError(err)}) {
    _udp.listen(
      port,
      allowInterop(onListening),
      allowInterop((Uint8List message, RInfo rinfo) =>
          onMessage(Uint8List.fromList(message), rinfo)),
      allowInterop(onError),
    );
  }

  void send(Uint8List message, String address, int port) {
    _udp.send(message, address, port);
  }

  void close() => _udp.close();
}