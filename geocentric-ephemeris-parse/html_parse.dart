import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';

void main() async {
  final dir = Directory('./files');
  final paths = dir.listSync().map((f) => f.path).toList();
  paths.sort();

  for (final path in paths) {
    final year = basename(path).replaceAll('.html', '');
    final file = File(path);
    await parse(file, year);
    // await parse(File('files/1999.html'), '1999');
  }
}

Future<void> parse(File file, String year) {
  final completer = Completer<void>();
  final contentsStream = file.openRead();

  final regex = RegExp(
      "(<p>(.*)|(Su.*)|(Su.*)|(Mo.*)|(Tu.*)|(We.*)|(Th.*)|(Fr.*)|(Sa.*))");

  int month = 0;
  final sub = contentsStream
      .transform(utf8.decoder)
      .transform(LineSplitter())
      .listen((line) {
    if (!line.contains(regex)) {
      return;
    }

    line = line.replaceAll('<p>', '');
    line = line.replaceAll('</p>', '');
    line = line.replaceAll('<pre>', '');
    line = line.replaceAll('</pre>', '');

    final tokens = line.split(' ');
    if (tokens[0].isEmpty) {
      tokens.removeAt(0);
    }
    final day = tokens[1];
    if (day == '01') {
      month++;
    }

    final monthString = '$month'.padLeft(2, '0');
    print("$year-$monthString-$day ${tokens.sublist(3).join(' ')}");
  });
  sub.onDone(() => completer.complete());

  return completer.future;
}
