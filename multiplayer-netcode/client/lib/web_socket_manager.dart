import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

class WebSocketManager {
  WebSocketChannel channel;

  WebSocketManager({void onMessage(data)}) {
    print("connecting");
    channel = IOWebSocketChannel.connect("ws://192.168.1.117:8081");
    channel.stream.listen(onMessage);
  }

  void send(dynamic data) {
    channel?.sink?.add(data);
  }

  void dispose() {
    channel.sink.close();
    channel = null;
  }
}
