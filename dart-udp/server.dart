import 'dart:io';

void main() {
  print("Hello I am the server");
  setupServer();
}

void setupServer() async {
  final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 4444);
  print("Ready to receive on ${socket.address.address}:${socket.port}");
  socket.listen((RawSocketEvent e) {
    final datagram = socket.receive();
    if (datagram != null) {
      print("Socket event $e");
      final message = String.fromCharCodes(datagram.data).trim();
      print("From ${datagram.address.address}:${datagram.port} '$message'");
      socket.send(message.codeUnits, datagram.address, datagram.port);
    }
  });
}