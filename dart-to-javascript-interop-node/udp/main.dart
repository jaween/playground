import 'dart:typed_data';

import 'udp_socket.dart';
import 'udp.dart';

void main() {
  print("Hello from Dart main()");
  final udpSocket = UdpSocket();

  udpSocket.listen(
    4444,
    onListening: (String address, int port) {
      print("Listeoueoning on $address:$port");
    },
    onMessage: (Uint8List message, RInfo rinfo) {
      //final list = Uint8List.fromList(message);
      final stringMessage = String.fromCharCodes(message);
      print("Messaoeueouge from ${rinfo.address}:${rinfo.port}: ${stringMessage}");
    },
    onError: (err) {
      print("Error $err");
    }
  );
}
