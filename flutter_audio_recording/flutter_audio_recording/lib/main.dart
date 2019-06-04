import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_sound/android_encoder.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:intl/intl.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Home(),
    );
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Audio recording"),
      ),
      body: Center(
        child: FlutterSoundContainer(),
      ),
    );
  }
}

class FlutterSoundContainer extends StatefulWidget {
  @override
  _FlutterSoundContainerState createState() => _FlutterSoundContainerState();
}

class _FlutterSoundContainerState extends State<FlutterSoundContainer> {
  FlutterSound _flutterSound;
  StreamSubscription _recorderSubscription;
  bool _isRecording = false;
  String _recordingText = "";
  String _mostRecentPath;

  @override
  void initState() {
    super.initState();
    _flutterSound = FlutterSound();
  }

  @override
  void dispose() {
    super.dispose();
    _recorderSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text("Recording $_isRecording"),
        Text(_recordingText),
        RaisedButton(
          child: Text(_isRecording ? "Stop" : "Record"),
          onPressed: _isRecording ? _stop : _record,
        ),
      ],
    );
  }

  void _record() async {
    final path = await _flutterSound.startRecorder(
      null,
      sampleRate: 44100 * 4,
      bitRate: 10000,
      androidEncoder: AndroidEncoder.VORBIS,
    );
    print("Path is $path");
    _recorderSubscription =
        _flutterSound.onRecorderStateChanged.listen((status) {
      print("Recording status is $status");
      if (status != null) {
        final date =
            DateTime.fromMillisecondsSinceEpoch(status.currentPosition.toInt());
        final text = DateFormat('mm:ss:SS', 'en_US').format(date);
        setState(() {
          _isRecording = true;
          _recordingText = text.substring(0, 8);
          _mostRecentPath = path;
        });
      }
    });
    print("Recording started");
  }

  void _stop() async {
    final result = await _flutterSound.stopRecorder();
    print("Stop result: $result");
    Scaffold.of(context).showSnackBar(
      SnackBar(
        content: Text("Saved to $_mostRecentPath"),
      ),
    );
    _recorderSubscription?.cancel();
    _recorderSubscription = null;
    setState(() => _isRecording = false);
  }
}
