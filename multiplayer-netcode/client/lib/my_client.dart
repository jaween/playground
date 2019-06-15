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
  static final double height = 600;
  double x = width / 2;
  double y = height / 2;

  WebSocketManager _webSocketManager;
  List<dynamic> _objects = [];
  List<dynamic> authWorldStates = [];
  Timer _updateTickTimer;
  bool _readyToInterpolate = false;

  int serverSendRate;
  int clientTick;
  int tickMs;
  static const int clientTickRate = 16;
  DateTime lastReceivedTime = DateTime.now();

  bool _canInterpolate = true;

  @override
  void initState() {
    super.initState();
    _webSocketManager = WebSocketManager(onMessage: (data) {
      final decoded = jsonDecode(data);
      tickMs = decoded['tickMs'];
      serverSendRate = decoded['serverSendRate'];
      authWorldStates.add(decoded);
      while (authWorldStates.length > 32) {
        authWorldStates.removeAt(0);
      }
      clientTick ??= decoded['worldTick'];
      lastReceivedTime = DateTime.now();
    });

    _updateTickTimer =
        Timer.periodic(Duration(milliseconds: clientTickRate), (_) {
      clientTick++;
      if (authWorldStates.length < 3) {
        return;
      }

      // Please simulate from serverSendRate / clientTickRate ms ago (the
      // scale means we're seeing older things happening, but it'll deal
      // with dropped packets better)
      final scale = 1.5;
      final simulateFromTime = scale * serverSendRate / clientTickRate;
      final simulationTick = clientTick - simulateFromTime;
      var fromState;
      var toState;
      for (var i = 1; i < authWorldStates.length; i++) {
        final prev = authWorldStates[i - 1];
        final curr = authWorldStates[i];
        if (prev['worldTick'] <= simulationTick &&
            curr['worldTick'] >= simulationTick) {
          fromState = prev;
          toState = curr;
          break;
        }
      }

      if (fromState == null || toState == null) {
        setState(() => _canInterpolate = false);
        return;
      }
      setState(() => _canInterpolate = true);

      final ratio = (simulationTick - fromState['worldTick']) /
          (toState['worldTick'] - fromState['worldTick']);

      final objects = _interpolate(fromState, toState, ratio);
      setState(() => _objects = objects);

      if (!_readyToInterpolate) {
        setState(() => _readyToInterpolate = true);
      }
    });
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

  @override
  void dispose() {
    _updateTickTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8),
            child: Center(
              child: _readyToInterpolate
                  ? CustomPaint(
                      size: Size(width, height),
                      painter: MyCustomPainter(
                        _objects,
                        authObjects: authWorldStates?.last['objects'],
                        canInterpolate: _canInterpolate,
                      ),
                    )
                  : Text("Waiting for enough data"),
            ),
          ),
          RaisedButton(
            child: Text("Send"),
            onPressed: () => _webSocketManager.send("Hello from Flutter"),
          ),
        ],
      ),
    );
  }
}

class MyCustomPainter extends CustomPainter {
  final List<dynamic> objects;
  final List<dynamic> authObjects;
  final bool canInterpolate;

  MyCustomPainter(this.objects, {this.authObjects, this.canInterpolate});

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

    if (authObjects != null) {
      for (var object in authObjects) {
        canvas.drawCircle(
            Offset(object['x'], object['y']),
            10,
            Paint()
              ..color = Colors.orange.shade800.withAlpha(50)
              ..strokeWidth = 2
              ..style = PaintingStyle.stroke);
      }
    }

    for (var object in objects) {
      canvas.drawCircle(
          Offset(object['x'], object['y']), 10, Paint()..color = Colors.orange);
    }

    canvas.drawCircle(Offset(50, 50), 25,
        Paint()..color = canInterpolate == true ? Colors.green : Colors.red);
  }
}
