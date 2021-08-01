import 'dart:async';
import 'dart:convert';
import 'dart:io';

var objects = [
  {'x': 30.0, 'y': 20.0, 'speedX': 15.0, 'speedY': 10.0},
  {'x': 300.0, 'y': 500.0, 'speedX': -12.0, 'speedY': -8.0},
  {'x': 250.0, 'y': 200.0, 'speedX': -4.0, 'speedY': 12.0},
];
Map<int, dynamic> players = {};

// { clientTick : { playerId: <String>[actions] }
var worldTick = 0;
var playerActions = <int, Map<int, List<dynamic>>>{};
final serverStatePublishRate = const Duration(milliseconds: 100);
final serverStateUpdateRate = const Duration(milliseconds: 16);

var connectedSockets = <WebSocket>[];

void main() {
  WebSocketManager(onConnected: _onConnected);

  int lastTick = 0;
  Timer.periodic(serverStateUpdateRate, (t) {
    while (lastTick != t.tick) {
      _updateWorldState(serverStateUpdateRate);
      lastTick++;
    }
  });
  Timer.periodic(serverStatePublishRate, (_) => _sendWorldState());
}

void _updateWorldState(Duration updateDuration) {
  if (players.isEmpty) {
    return;
  }

  // Apply actions onto players
  final actionsAtTick = playerActions[worldTick];
  if (actionsAtTick != null) {
    for (var playerIdToActions in actionsAtTick.entries) {
      final playerId = playerIdToActions.key;
      final actions = playerIdToActions.value;
      if (actions.isNotEmpty) {
        print(
            "$worldTick) actions for player $playerId at tick $worldTick  $actions");
      }
      final player = players[playerId];
      if (actions.isNotEmpty) {
        _updatePlayerWithActions(player, actions);
      }
    }
  }

  // Simulate entities
  for (var object in objects) {
    object['x'] += object['speedX'] * updateDuration.inMilliseconds / 1000;
    object['y'] += object['speedY'] * updateDuration.inMilliseconds / 1000;
  }

  // Simulate players
  for (var player in players.values) {
    _simulatePlayer(player);
  }

  // Never need the actions at this tick again
  playerActions.remove(worldTick);

  worldTick++;
}

void _updatePlayerWithActions(dynamic player, List<dynamic> actions) {
  for (var action in actions) {
    switch (action) {
      case "left":
        player['speedX'] = -50;
        break;
      case "up":
        player['speedY'] = -50;
        break;
      case "right":
        player['speedX'] = 50;
        break;
      case "down":
        player['speedY'] = 50;
        break;
    }
  }
}

void _simulatePlayer(dynamic player) {
  player['x'] += player['speedX'] * serverStateUpdateRate.inMilliseconds / 1000;
  player['y'] += player['speedY'] * serverStateUpdateRate.inMilliseconds / 1000;
  player['speedX'] = 0;
  player['speedY'] = 0;
}

void _sendWorldState() {
  final playersList = players.entries
      .map((entry) => {'playerId': entry.key, 'data': entry.value})
      .toList(growable: false);
  final world = {
    'type': 'state',
    'worldTick': worldTick,
    'serverStatePublishMs': serverStatePublishRate.inMilliseconds,
    'serverStateUpdateMs': serverStateUpdateRate.inMilliseconds,
    'objects': objects,
    'players': playersList,
  };
  final json = jsonEncode(world);
  for (final socket in connectedSockets) {
    socket.add(json);
  }
}

void _onConnected(WebSocket socket) {
  final playerId = players.length;
  print("Player $playerId connected at tick $worldTick");
  players[playerId] = {'x': 250.0, 'y': 300.0, 'speedX': 0, 'speedY': 0};
  connectedSockets.add(socket);

  final data = jsonEncode(
      {'type': 'connect', 'playerId': playerId, 'worldTick': worldTick});
  socket.add(data);

  socket.listen((data) => _onMessage(socket, playerId, data));
}

void _onMessage(WebSocket socket, int playerId, dynamic data) {
  final receiveTime = DateTime.now();
  final decoded = jsonDecode(data);
  final type = decoded['type'];
  switch (type) {
    case 'userCommand':
      final clientTick = decoded['clientTick'];
      final actions = decoded['actions'];
      playerActions.putIfAbsent(clientTick, () => {});
      if (clientTick < worldTick) {
        print(
            "$worldTick) Received actions late by ${worldTick - clientTick} ticks: $actions");
      }
      playerActions[clientTick][playerId] = actions;
      socket.add(jsonEncode({
        'type': 'ack',
        'clientTick': clientTick,
        'waitTimeUs': DateTime.now().difference(receiveTime).inMicroseconds
      }));
      break;
    default:
      print("Unknown message $data");
  }
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
