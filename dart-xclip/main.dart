import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

void main() async {
  // Timer.periodic(Duration(milliseconds: 500), (_) {
  //   _check();
  // });

  // Timer.periodic(Duration(seconds: 1), (_) async {
  //   final data = await _get();
  //   _put(data);
  // });

  //final data = await _get();
  final data = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAC6klEQVRYw73XS2hcVRzH8c/cGcnDYLCmrRQfJanWPjK1tQ8uKiJImyC4EhTUWmjdqkwLinVRUYpIvSgoiiDVbtRuRFEaCbpRGETwcamklgStIBptKtWY1jgkbmZkmtxpbubhb3nO/5zv7zzuuf9/Rkrli4VLsQO3YxtWYmm5ewLf4wt8jI/iMJpMM28mBfg67MP96Ezpdwpv4VAcRifqMpAvFjqxH3vRpj6VcAhPx2E0ldpAvli4Fu9hg+boW9wZh9GpBQ3ki3vXMTuEqzRXv+KuOIw+r2mgvPLPWgCv6Ddsqd6JzJwzLyKvtRrB5sqdCKo69v8PcFiDpy7YgXyxcD3iBm77YjWLdXEYjVR2YF+z4fd13+jwqt22d/bW+voeh0y+WOjC+CIemQW1s3ujR1bfKxfknCud98yJN30weXJu2DmsCLC9VXDoyLV78oYHDXT2zQ3twGCAO1oF/4+Ua7frmoGkITsCbGklvKKvfz+Z1Lw+QF+tSR/tuc3DPbc2DH/31CeeHR9ONJDD5Uk9h1fttqlnLejv7vPQ2Bt1ww/8/GEt723BQnDYurTfa727mg1XeQnPVjfcc1n+AnhF25b1e7V3Z1PhmM5hFDdVWn6aPqM0U0qcOFy2wSuzDyieOd4MOBzPLt8Tbq428GPpD+cnJ2y9Yq0gM/+Eru66UtjTLxtkG4XDcIB51/PI2a+8+N3bSjOl5DQqk2kGvGIgM1TO4RZlognwaRwL4vD5P3E0KSKtiTrgcDQOo4nKIT+HmXpM1AmHg5CF8deLp5fvCbtwc1LkN3//kngxG4C/FIfRkbkZ0YFyuiTNTjQAH8VjF0tKv8SSWqPDthW6sx2GpsbqgU9iYxxGoxdJywu34P1a/4gG9BcG4zD6NE1hshJDWN0k+BgGqlde/S+YpziMfsAmvNAE+MvIJ8HTFqdr8ATuRntK6D94BwfjMBppqDquMrIEg+Uccj36cUlVERqXa8BhHIvD6HSaef8F6KgfMJTEvCMAAAAASUVORK5CYII=');
  print(data.length);
  await _put(data);
}

Future<bool> _check() async {
  final targetsResult = await Process.run(
      'xclip', ['-selection', 'clipboard', '-t', 'TARGETS', '-o']);
  final targets = targetsResult.stdout as String;
  final png = targets.contains('image/png');
  final jpg = targets.contains('image/jpg') || targets.contains('image/jpeg');
  return png || jpg;
}

Future<Uint8List> _get() async {
  final result = await Process.run(
      'xclip', ['-selection', 'clipboard', '-t', 'image/png', '-o'],
      stdoutEncoding: null);
  return Uint8List.fromList(result.stdout);
}

Future<void> _put(Uint8List imageBytes) async {
  final process = await Process.start(
      'xclip', ['-selection', 'clipboard', '-t', 'image/png']);
  process.stdin.add(imageBytes);
  process.stdin.close();
}
