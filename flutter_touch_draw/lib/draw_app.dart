import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart' hide Image;
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

class DrawApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          DrawCanvas(),
        ],
      ),
    );
  }
}

class DrawCanvas extends StatefulWidget {
  @override
  _DrawCanvasState createState() => _DrawCanvasState();
}

class _DrawCanvasState extends State<DrawCanvas> {
  Image _image;
  Handler _handler;
  bool scheduled = false;

  @override
  void initState() {
    _handler = Handler((image) {
      if (mounted) {
        setState(() => _image = image);
      }
    });

    _handler.init();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanDown: (p) => _handler.start(p.globalPosition),
      onPanUpdate: (p) => _handler.start(p.globalPosition),
      onPanEnd: (d) => _handler.end(),
      child: CustomPaint(
        painter: MyPainter(image: _image),
      ),
    );
  }
}

class Handler {
  final Function _onImage;
  Offset _previousPixel;
  Image _image;

  Handler(this._onImage);

  void init() async {
    final pictureRecorder = PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    canvas.drawColor(Colors.pink, BlendMode.src);
    final picture = pictureRecorder.endRecording();
    _image = await picture.toImage(512, 512);
    _onImage(_image);
  }


  bool scheduled = false;
  void start(Offset p) {
    if (!scheduled) {
      SchedulerBinding.instance.addPostFrameCallback((duration) {
        scheduled = false;
        _drawStart(p);
      });
      SchedulerBinding.instance.scheduleFrame();
    }
    scheduled = true;
  }

  void move(Offset p) {
    if (!scheduled) {
      SchedulerBinding.instance.addPostFrameCallback((duration) {
        scheduled = false;
        _drawMove(p);
      });
      SchedulerBinding.instance.scheduleFrame();
    }
    scheduled = true;
  }

  void _drawStart(Offset p) async {
    final pictureRecorder = PictureRecorder();
    final canvas = Canvas(pictureRecorder);

    //canvas.drawImage(_image, Offset.zero, Paint());
    canvas.drawCircle(p, 50, Paint());
    canvas.drawPoints(PointMode.points, [p], Paint());

    _previousPixel = p;
    final out = await pictureRecorder.endRecording().toImage(512, 512);
    _image = out;
    _onImage(_image);
  }

  void _drawMove(Offset p) async {
    final pictureRecorder = PictureRecorder();
    final canvas = Canvas(pictureRecorder);

    //canvas.drawImage(_image, Offset.zero, Paint());
    canvas.drawCircle(p, 50, Paint());
    canvas.drawLine(_previousPixel, p, Paint());

    _previousPixel = p;
    final out = await pictureRecorder.endRecording().toImage(512, 512);
    _image = out;
    _onImage(_image);
  }

  void end() {}

  Future<Image> clone(Image image) async {
    final data = await image.toByteData(format: ImageByteFormat.png);
    final codec = await instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: 512,
      targetHeight: 512,
    );
    final frame = await codec.getNextFrame();
    return frame.image;
  }
}

class MyPainter extends CustomPainter {
  final Image image;

  MyPainter({@required this.image});

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  @override
  void paint(Canvas canvas, Size size) {
    if (image != null) {
      canvas.drawImage(image, Offset.zero, Paint());
    }
  }
}
