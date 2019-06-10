import 'dart:io';

void main() {
  print("Hello I am a client");
  setupClient();
}

void setupClient() async {
  final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
  final destinationPort = 4444;
  print("Sending on socket ${socket.address.address}:${socket.port}");
  socket.send('hello!'.codeUnits, InternetAddress.anyIPv4, destinationPort);
}