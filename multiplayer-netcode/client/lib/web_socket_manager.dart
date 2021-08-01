import 'dart:async';
import 'dart:io';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

class WebSocketManager {
  WebSocketChannel channel;

  WebSocketManager(String address, {void onMessage(data)}) {
    print("Connecting...");
    _setup(address, onMessage);
  }

  void _setup(String address, void onMessage(data)) {
    Timer timer;
    timer = Timer.periodic(Duration(seconds: 2), (_) async {
      try {
        final socket = await WebSocket.connect(address);
        channel = IOWebSocketChannel(socket);
        channel.stream.listen(onMessage);
        timer.cancel();
      } on SocketException catch (e) {
        print("Could not connect to socket, $e");
      } on TimeoutException catch (e) {
        print("Colud not connect, timeout $e");
      }
    });
  }

  void send(dynamic data) {
    channel?.sink?.add(data);
  }

  void dispose() {
    channel?.sink?.close();
    channel = null;
  }
}
