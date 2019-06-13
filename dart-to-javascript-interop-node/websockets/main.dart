import 'comms.dart';
import 'comms_server_js.dart';

void main() {
  final port = 8081;
  CommsServerJs(port, onConnection);
  print("WebSockets server running on $port");
}

void onConnection(Socket socket, ClientInfo client) {
  print("Connected to ${client.address}:${client.port}");
  socket.send("Hello from Dart!!!");
}
