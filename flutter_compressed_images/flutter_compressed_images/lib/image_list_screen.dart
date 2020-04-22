import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compressed_images/drawing_window.dart';
import 'package:flutter_compressed_images/image_holder.dart';
import 'package:flutter_compressed_images/main.dart';

class ImageListScreen extends StatefulWidget {
  final bool png;

  ImageListScreen({@required this.png});

  @override
  _ImageListScreenState createState() => _ImageListScreenState();
}

class _ImageListScreenState extends State<ImageListScreen> {
  final images = <ImageHolder>[];
  int _selected;

  @override
  void initState() {
    _addImage();

    super.initState();
  }

  void _addImage() {
    final image = ImageHolder();
    image.createImage(() {
      if (mounted) {
        setState(() {
          _selected = 0;
          images.add(image);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            if (_selected != null)
              DrawingWindow(
                imageHolder: images[_selected],
                onUpdate: (pngBytes) {
                  setState(() => images[_selected] = ImageHolder.fromPng(pngBytes));
                },
              ),
            Expanded(
              child: ListView.builder(
                itemCount: images.length,
                itemBuilder: (context, index) {
                  final image = images[index];
                  return ListTile(
                    onTap: () {
                      setState(() {
                        _selected = index;
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
                      child: widget.png
                          ? _buildPngImage(image)
                          : _buildBytesImage(image),
                    ),
                  );
                },
              ),
            ),
            RaisedButton(
              child: Text("Add image"),
              onPressed: _addImage,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBytesImage(ImageHolder image) {
    return FutureBuilder<ui.Image>(
      future: image.image(),
      initialData: null,
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          return Container(
            color: Colors.blue,
          );
        }
        return CustomPaint(
          painter: ImagePainter(image: snapshot.data),
        );
      },
    );
  }

  Widget _buildPngImage(ImageHolder image) {
    return Image.memory(
      image.pngBytes(),
      fit: BoxFit.fill,
      filterQuality: FilterQuality.none,
    );
  }
}
