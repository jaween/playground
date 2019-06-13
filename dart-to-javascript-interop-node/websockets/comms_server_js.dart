import 'package:js/js.dart';
import 'comms.dart';
import 'websocket_impl.dart';

/// Implementation of network communications for JavaScript (WebSockets for
/// Node server and browser client).
class CommsServerJs implements CommsServer {
  WebSocketServer _webSocketServer;

  CommsServerJs(int port, void onConnection(Socket socket, ClientInfo client))
      : _webSocketServer = WebSocketServer(port, allowInterop(onConnection));

  @override
  void close() => _webSocketServer.close();
}
