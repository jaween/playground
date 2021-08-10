import 'dart:convert';
import 'dart:io';

final signs = [
  'CP',
  'AQ',
  'PI',
  'AR',
  'TA',
  'GE',
  'CN',
  'LE',
  'VI',
  'LI',
  'SC',
  'SG',
];

void main(List<String> args) {
  if (args.length < 1) {
    print("USAGE:\n  dart compute.dart <NUMBER>");
    return;
  }

  const sunIndex = 1;
  final planetIndex = int.tryParse(args[0]);
  if (planetIndex < 2 || planetIndex > 11) {
    print("Error: Number must be between 2 and 11");
    return;
  }

  final file = File('data.txt');
  final contentsStream = file.openRead();

  print(
      "Date,Previous day sun position,Sun position,Previous day planet position,Planet position,Unlikely");

  Pos prevPlanetPos;
  Pos prevSunPos;
  contentsStream
      .transform(utf8.decoder)
      .transform(LineSplitter())
      .listen((line) {
    final tokens = line.split(' ');
    final date = tokens[0];
    final sunPos = parse(tokens[sunIndex]);
    final planetPos = parse(tokens[planetIndex]);
    //print("$date: $sunPos $planetPos $prevPlanetPos");

    // if (!date.startsWith('1994')) {
    //   return;
    // }

    if (prevPlanetPos != null) {
      final prevSignIndex = signs.indexOf(prevPlanetPos.sign);
      final currSignIndex = signs.indexOf(planetPos.sign);
      final sunSignIndex = signs.indexOf(sunPos.sign);

      final planetIsDecreasing = planetPos.value < prevPlanetPos.value;
      if (sunPos.sign == planetPos.sign && planetIsDecreasing) {
        if ( //currSignIndex <= sunSignIndex &&
            planetPos.value <= sunPos.value &&
                //prevSignIndex >= sunSignIndex &&
                prevPlanetPos.value >= sunPos.value) {
          // print(
          //     "$date ${sunSignIndex}:${sunPos.value} ${prevSignIndex}:${prevPlanetPos.value}");
          // print(
          //     "$date ${sunSignIndex}:${sunPos.value} ${currSignIndex}:${planetPos.value}");
          // print(date);
        }
      }

      if (planetPos.combined <= sunPos.combined &&
          prevPlanetPos.combined >= prevSunPos.combined) {
        if (prevPlanetPos.combined - planetPos.combined > 5) {
          print(
              "$date,${prevSunPos.source},${sunPos.source},${prevPlanetPos.source},${planetPos.source},Unlikely");
        } else {
          print(
              "$date,${prevSunPos.source},${sunPos.source},${prevPlanetPos.source},${planetPos.source}");
        }
      }
    }
    prevPlanetPos = planetPos;
    prevSunPos = sunPos;
  });
}

Pos parse(String source) {
  final sign = source.substring(2, 4);
  final deg = int.tryParse(source.substring(0, 2));
  final min = int.tryParse(source.substring(4, 6));
  return Pos(source: source, sign: sign, deg: deg, min: min);
}

class Pos {
  final String source;
  final String sign;
  final int deg;
  final int min;

  Pos({
    this.source,
    this.sign,
    this.deg,
    this.min,
  });

  double get value => double.tryParse("$deg.${min.toString().padLeft(2, '0')}");

  double get combined {
    final value =
        "${signs.indexOf(sign) + 1}${deg.toString().padLeft(2, '0')}.${min.toString().padLeft(2, '0')}";
    return double.tryParse(value);
  }

  @override
  String toString() => "$sign $deg.$min";
}
