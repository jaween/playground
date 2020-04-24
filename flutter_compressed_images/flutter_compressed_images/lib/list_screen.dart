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
  int _selected;

  @override
  void initState() {
    _addNewImageHolder().then((_) {
      if (mounted) {
        setState(() {
          setState(() {
            _selected = 0;
            _images[_selected].beginEditing().then((_) => setState(() => {}));
          });
        });
      }
    });

    super.initState();
  }

  Future<void> _addNewImageHolder() async {
    final image = await ImageHolder.create();
    if (mounted) {
      setState(() => _images.add(image));
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
                  return ListTile(
                    onTap: () async {
                      // TODO: Maybe make end then begin more robust to not need this check
                      if (_selected == index) {
                        return;
                      }

                      _images[_selected]
                          .endEditing()
                          .then((_) => setState(() {}));
                      setState(() {
                        _selected = index;
                        _images[_selected]
                            .beginEditing()
                            .then((_) => setState(() {
                                  print("Editing ready");
                                }));
                      });
                    },
                    title: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: _selected == index ? 10 : 1,
                        ),
                      ),
                      child: ImageDisplay(
                        imageHolder: _images[index],
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
                final channel = MethodChannel('com.jaween.test');
                final info = await channel.invokeMethod('getMemoryInfo');
                print(info);
              },
            ),
          ],
        ),
      ),
    );
  }
}
