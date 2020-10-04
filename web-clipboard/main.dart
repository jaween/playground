@JS()
library clipboard;

import 'dart:async';
import 'dart:html';

import 'package:js/js.dart';
import 'package:js/js_util.dart';

StreamSubscription focusSubscription;

void onFocus(Event e) async {
  focusSubscription?.cancel();
  _paste();
  focusSubscription = window.onFocus.listen(onFocus);
}

void main() {
  print('hello123');

  focusSubscription = window.onFocus.listen(onFocus);

  final copy = document.querySelector('#copy');
  copy.onClick.listen((event) async {
    final blob = await requestBlob();
    await promiseToFuture(writeImage(blob));
    print('Copied');
  });

  final paste = document.querySelector('#paste');
  paste.onClick.listen((event) => _paste());
}

void _paste() async {
  final blob = await promiseToFuture(readImage());
  if (blob == null) {
    print('No image');
  }
  displayImage(blob);
}

void displayImage(Blob blob) {
  String url;
  if (blob == null) {
    url = '';
  } else {
    url = Url.createObjectUrl(blob);
  }
  document.querySelector('#image').attributes['src'] = url;
}

Future<Blob> requestBlob() async {
  const url = 'http://localhost:8080/image.png';
  final request = await HttpRequest.request(url, responseType: 'blob');
  return request.response as Blob;
}

@JS()
external Future<void> writeImage(Blob blob);

@JS()
external Future<Blob> readImage();
