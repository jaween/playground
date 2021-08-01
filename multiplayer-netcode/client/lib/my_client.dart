import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'web_socket_manager.dart';

class MyClient extends StatefulWidget {
  @override
  _MyClientState createState() => _MyClientState();
}

class _MyClientState extends State<MyClient> {
  static final double width = 300;
  static final double height = 400;
  double x = width / 2;
  double y = height / 2;

  WebSocketManager _webSocketManager;
  List<dynamic> _interpolatedObjects = [];
  List<dynamic> _players = [];
  Map<int, dynamic> serverWorldStates = {};
  Timer _updateTickTimer;
  bool _interpolationDone = false;

  int serverStatePublishMs;
  int clientTick;
  int initialClientTick;
  int serverStateUpdateMs;
  static const int clientTickRate = 16;
  DateTime lastReceivedTime = DateTime.now();

  bool _receivingTimelyUpdates = true;

  int playerId;
  final Map<int, DateTime> _awaitingAck = {};
  final Map<int, List<String>> pastActions = {};

  List<double> rtts = [];

  Map<dynamic, double> player = {};

  final inputState = {
    'left': false,
    'up': false,
    'right': false,
    'down': false,
  };

  double ahead = 0;

  @override
  void initState() {
    super.initState();
    final address = "ws://192.168.1.117:8081";

    // Start listening after delay to avaid startup timing issues
    Timer(Duration(seconds: 4), () {
      _webSocketManager = WebSocketManager(address, onMessage: _onMessage);
    });

    int lastTick = 0;
    _updateTickTimer =
        Timer.periodic(Duration(milliseconds: clientTickRate), (t) {
      while (lastTick != t.tick) {
        _onTick();
        lastTick++;
      }
    });
  }

  @override
  void dispose() {
    _updateTickTimer?.cancel();
    super.dispose();
  }

  void _onMessage(dynamic data) {
    final receiveTime = DateTime.now();
    final decoded = jsonDecode(data);

    switch (decoded['type']) {
      case 'connect':
        playerId = decoded['playerId'];
        clientTick = decoded['worldTick'];
        initialClientTick = clientTick;
        print("Joined as player $playerId at tick $clientTick");
        break;
      case 'ack':
        final ackTick = decoded['clientTick'];
        final waitTimeMs = decoded['waitTimeUs'] / 1000;
        final sendTime = _awaitingAck[ackTick];
        if (sendTime == null) {
          print("Received ack for tick $ackTick, but it's missing");
          return;
        }
        final roundTripTime =
            receiveTime.difference(sendTime).inMilliseconds - waitTimeMs;
        _awaitingAck.remove(ackTick);
        rtts.add(roundTripTime);
        if (rtts.length > 10) {
          rtts.removeAt(0);
        }
        //print("RTT is ${roundTripTime.toStringAsFixed(0)} ms");
        break;
      case 'state':
        serverStateUpdateMs = decoded['serverStateUpdateMs'];
        serverStatePublishMs = decoded['serverStatePublishMs'];

        final worldTick = decoded['worldTick'];
        //print("received tick $worldTick");

        // Keeps the world state from up to 100 ticks ago
        serverWorldStates[worldTick] = decoded;
        serverWorldStates.removeWhere((tick, state) => tick <= worldTick - 100);

        lastReceivedTime = DateTime.now();
        _players = decoded['players'];
        final player = _findPlayer(playerId, _players);

        //print("replaying ${clientTick - worldTick} ticks");
        for (var i = worldTick; i < clientTick; i++) {
          final actions = pastActions[worldTick];
          _updatePlayerWithActions(player, actions);
          _simulatePlayer(player);
        }
        // Never need to replay these actions again
        pastActions.remove(worldTick);

        // Player updated
        setState(() => {});
        break;
      default:
        print("Unknown message $data");
    }
  }

  int initialTimerTick;
  int lastTimerTick = 0;
  void _onTick() {
    if (clientTick != null) {
      clientTick++;
    }
    if (serverWorldStates.length < 3) {
      return;
    }

    // Send actions to the server
    var actions = <String>[];
    for (var entry in inputState.entries) {
      if (entry.value) {
        actions.add(entry.key);
      }
    }
    final rtt = rtts.isEmpty ? 0 : rtts.last;
    //rtts.fold<double>(0.0, (p, e) => p + e) / (rtts.length == 0 ? 1 : rtts.length);
    final rttInServerSideTicks = (rtt / serverStateUpdateMs).ceil();
    final ticksInTheFuture = rttInServerSideTicks + 7;
    final predictedTick = clientTick + ticksInTheFuture;
    // print("$clientTick) RTT is ${rtt.toStringAsFixed(1).padLeft(4, '0')} ms "
    //     "(${rttInServerSideTicks.toStringAsFixed(1)} server-side ticks), "
    //     "sending action as tick $predictedTick)");
    pastActions[predictedTick] = actions;
    final actionsObject = {
      'type': 'userCommand',
      'clientTick': predictedTick,
      'actions': actions,
    };
    _awaitingAck[predictedTick] = DateTime.now();
    _webSocketManager.send(jsonEncode(actionsObject));

    final player = _findPlayer(playerId, _players);
    _updatePlayerWithActions(player, actions);
    _simulatePlayer(player);

    // Please simulate from serverStatePublishMs / clientTickRate ms ago (the
    // scale means we're seeing older things happening, but it'll deal
    // with dropped packets better)
    final scale = 3;
    final ticksToStepBackBy =
        (scale * serverStatePublishMs / clientTickRate).ceil();
    final simulationTick = clientTick - ticksToStepBackBy;

    final lowerBoundary =
        simulationTick - (serverStatePublishMs / clientTickRate).floor();
    final upperBoundary =
        simulationTick + 2 * (serverStatePublishMs / clientTickRate).floor();

    // If we are simulating tick 32, and the server publishes every 10th tick,
    // we're looking for world states for tick 30 and 40, or 30 and 50
    int sourceTick;
    int destTick;
    try {
      sourceTick = serverWorldStates.keys
          .lastWhere((tick) => tick >= lowerBoundary && tick <= simulationTick);
    } catch (e) {}
    try {
      destTick = serverWorldStates.keys
          .firstWhere((tick) => tick > simulationTick && tick <= upperBoundary);
    } catch (e) {}

    if (sourceTick == null && destTick == null || sourceTick == null) {
      final ticksAhead = clientTick - serverWorldStates.keys.last;
      print(
          "Could not interpolote: client at $clientTick, wanted to generate tick $simulationTick, ${ticksAhead / clientTickRate}ms ahead");
      setState(() => _receivingTimelyUpdates = false);
      return;
    }
    setState(() => _receivingTimelyUpdates = true);

    if (sourceTick == simulationTick) {
      // We have an authoratative state matching the tick we want to simulate
      _interpolatedObjects = serverWorldStates[sourceTick]['objects'];
    } else {
      // Interpolate between two states
      final fromState = serverWorldStates[sourceTick];
      final toState = serverWorldStates[destTick];
      final ratio = (simulationTick - fromState['worldTick']) /
          (toState['worldTick'] - fromState['worldTick']);

      final interpolated = _interpolate(fromState, toState, ratio);
      setState(() => _interpolatedObjects = interpolated);
    }

    if (!_interpolationDone) {
      setState(() => _interpolationDone = true);
    }
  }

  dynamic _findPlayer(int playerId, List<dynamic> players) {
    return players
        .firstWhere((player) => player['playerId'] == playerId)['data'];
  }

  dynamic _interpolate(dynamic stateA, dynamic stateB, double ratio) {
    var objects = [];
    for (int i = 0; i < stateB['objects'].length; i++) {
      final a = stateA['objects'][i];
      final b = stateB['objects'][i];
      objects.add({
        'x': a['x'] + (b['x'] - a['x']) * ratio,
        'y': a['y'] + (b['y'] - a['y']) * ratio,
      });
    }
    return objects;
  }

  void _updatePlayerWithActions(dynamic player, List<String> actions) {
    if (actions == null) {
      return;
    }
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
    player['x'] += player['speedX'] * serverStateUpdateMs / 1000;
    player['y'] += player['speedY'] * serverStateUpdateMs / 1000;
    player['speedX'] = 0;
    player['speedY'] = 0;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(rtts.isNotEmpty
              ? "RTT ${rtts.last.toStringAsFixed(0).padLeft(2, '0')} ms"
              : ""),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Center(
              child: _interpolationDone
                  ? CustomPaint(
                      size: Size(width, height),
                      painter: MyCustomPainter(
                        players: _players,
                        interpolatedObjects: _interpolatedObjects,
                        nonInterpolatedObjects:
                            serverWorldStates?.entries?.last?.value['objects'],
                        receivingTimelyUpdates: _receivingTimelyUpdates,
                      ),
                    )
                  : Text("Waiting for enough data"),
            ),
          ),
          _button("▲", "up"),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _button("◀", "left"),
              _button("▼", "down"),
              _button("▶", "right"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _button(String label, String action) {
    return Listener(
      child: InkWell(
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: SizedBox(
            width: 80,
            height: 60,
            child: Center(
              child: Text(label, style: Theme.of(context).textTheme.headline),
            ),
          ),
        ),
        onTap: () {},
      ),
      onPointerDown: (_) => _action(true, action),
      onPointerUp: (_) => _action(false, action),
      onPointerCancel: (_) => _action(false, action),
    );
  }

  void _action(bool pressed, String dir) => inputState[dir] = pressed;
}

class MyCustomPainter extends CustomPainter {
  final List<dynamic> players;
  final List<dynamic> interpolatedObjects;
  final List<dynamic> nonInterpolatedObjects;
  final bool receivingTimelyUpdates;

  MyCustomPainter({
    this.players = const [],
    this.interpolatedObjects = const [],
    this.nonInterpolatedObjects = const [],
    this.receivingTimelyUpdates = false,
  });

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..color = Colors.grey
        ..style = PaintingStyle.stroke,
    );

    if (nonInterpolatedObjects != null) {
      for (var object in nonInterpolatedObjects) {
        canvas.drawCircle(
            Offset(object['x'], object['y']),
            10,
            Paint()
              ..color = Colors.orange.shade800.withAlpha(50)
              ..strokeWidth = 2
              ..style = PaintingStyle.stroke);
      }
    }

    for (var object in interpolatedObjects) {
      canvas.drawCircle(
        Offset(object['x'], object['y']),
        10,
        Paint()..color = Colors.orange,
      );
    }

    for (var p in players) {
      final player = p['data'];
      canvas.drawCircle(
        Offset(player['x'], player['y']),
        10,
        Paint()..color = Colors.blue,
      );
    }

    canvas.drawCircle(
        Offset(32, 32),
        16,
        Paint()
          ..color = receivingTimelyUpdates
              ? Colors.green.withAlpha(100)
              : Colors.red.withAlpha(100));
  }
}
