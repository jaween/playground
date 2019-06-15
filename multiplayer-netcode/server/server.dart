import 'dart:async';
import 'dart:convert';
import 'dart:io';

var objects = [
  {'x': 30.0, 'y': 20.0, 'speedX': 10.0, 'speedY': 7.0},
  {'x': 300.0, 'y': 500.0, 'speedX': -8.0, 'speedY': -6.0},
  {'x': 250.0, 'y': 200.0, 'speedX': -3.0, 'speedY': 8.0},
];
var players = [];
var playerActions = <int, List<dynamic>>{};
var worldTick = 0;
var serverSendRate = 100;
var tickMs = 16;

var connectedSockets = <WebSocket>[];

void main() {
  WebSocketManager(onConnected: _onConnected);

  final updateDuration = Duration(milliseconds: tickMs);
  Timer.periodic(updateDuration, (t) => _updateWorldState(updateDuration));
  Timer.periodic(
      Duration(milliseconds: serverSendRate), (_) => _sendWorldState());
}

void _updateWorldState(Duration updateDuration) {
  for (var object in objects) {
    object['x'] += object['speedX'] * updateDuration.inMilliseconds / 1000;
    object['y'] += object['speedY'] * updateDuration.inMilliseconds / 1000;
  }

  worldTick++;
}

void _sendWorldState() {
  final world = {
    'worldTick': worldTick,
    'serverSendRate': serverSendRate,
    'tickMs': tickMs,
    'objects': objects,
  };
  for (final socket in connectedSockets) {
    socket.add(json.encode(world));
  }
}

void _onConnected(WebSocket socket) {
  print("Connected");

  socket.listen((data) {});
}

class WebSocketManager {
  WebSocketManager({void onConnected(WebSocket socket)}) {
    _setup(onConnected: onConnected);
  }

  void _setup({void onConnected(WebSocket socket)}) async {
    final httpServer = await HttpServer.bind(InternetAddress.anyIPv4, 8081);
    final webSocketStream = httpServer.transform(WebSocketTransformer());
    webSocketStream.listen(onConnected);
  }
}
