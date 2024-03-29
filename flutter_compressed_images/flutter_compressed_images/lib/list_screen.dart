import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compressed_images/image_display.dart';
import 'package:flutter_compressed_images/drawing_canvas.dart';
import 'package:flutter_compressed_images/image_holder.dart';

class ListScreen extends StatefulWidget {
  ListScreen();

  @override
  _ListScreenState createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  final _images = <ImageHolder>[];
  final _keys = <GlobalKey>[];
  int _selected;

  @override
  void initState() {
    MethodChannel('com.jaween.memory').setMethodCallHandler((call) {
      switch (call.method) {
        case 'onTrimMemory':
          print(
              "##### On low  memory call recieved from Java, level ${call.arguments}");
          break;
        default:
          print('Unknown method ${call.method}');
      }
      return Future.value();
    });
    _addNewImageHolder().then((_) {
      if (mounted) {
        setState(() {
          _selected = 0;
          _images[_selected].beginEditing().then((_) => setState(() => {}));
        });
      }
    });

    super.initState();
  }

  Future<void> _addNewImageHolder() async {
    final imageHolder = await _createImageHolder(width: 1500, height: 1500);
    if (mounted) {
      setState(() {
        _keys.add(GlobalKey());
        _images.add(imageHolder);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            if (_selected != null)
              DrawingCanvas(
                imageHolder: _images[_selected],
                onImageModified: (uiImage) {
                  setState(() {
                    _images[_selected].edited(edited: uiImage);
                  });
                },
              ),
            Expanded(
              child: ListView.builder(
                itemCount: _images.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () async {
                      // TODO: Maybe make end then begin more robust to not need this check
                      if (_selected == index) {
                        return;
                      }

                      final prevSelected = _selected;
                      setState(() {
                        _selected = index;
                        _images[_selected]
                            .beginEditing()
                            .then((_) {
                              // TODO: This might be risky! prevSelected might be selected again at this point? Maybe just ensure _selected != prevSelected?
                              setState(() {
                                  _images[prevSelected]
                                      .endEditing()
                                      .then((_) => setState(() {}));
                                });
                            });
                      });
                    },
                    child: Container(
                      height: 100,
                      color: _selected == index ? Colors.black : null,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ImageDisplay(
                          key: _keys[index],
                          imageHolder: _images[index],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            RaisedButton(
              child: Text("Add image"),
              onPressed: _addNewImageHolder,
            ),
            RaisedButton(
              child: Text("Get Memory Info"),
              onPressed: () async {
                final channel = MethodChannel('com.jaween.meminfo');
                final info = await channel.invokeMethod('getMemoryInfo');
                print("########## Memory info at ${_images.length} images");
                print(info);
              },
            ),
          ],
        ),
      ),
    );
  }
}

Future<ImageHolder> _createImageHolder({
  @required int width,
  @required int height,
}) async {
  final pictureRecorder = PictureRecorder();
  final canvas = Canvas(pictureRecorder);
  const colorList = [
    Colors.orange,
    Colors.blue,
    Colors.pink,
    Colors.purple,
    Colors.green,
    Colors.amber,
    Colors.brown,
    Colors.cyan,
    Colors.lightGreen,
    Colors.lightBlue
  ];
  final random = Random();
  final index = random.nextInt(colorList.length);
  canvas.drawColor(colorList[index], BlendMode.color);
  final picture = pictureRecorder.endRecording();
  final image = await picture.toImage(width, height);
  final pngBytes = await image.toByteData(format: ImageByteFormat.png);
  return ImageHolder(
    size: Size(width.toDouble(), height.toDouble()),
    pngBytes: pngBytes.buffer.asUint8List(),
  );
}
