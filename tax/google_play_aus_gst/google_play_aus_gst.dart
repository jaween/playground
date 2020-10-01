import 'dart:io';

import 'package:csv/csv.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;

void main(List<String> arguments) async {
  final dirPath = arguments.first;
  final dir = Directory(dirPath);
  final items = await dir
      .list()
      .where((e) => e is File)
      .map<File>((f) => f)
      .where((f) => path.extension(f.path) == '.csv')
      .asyncMap((f) => f.readAsString())
      .map<List<Item>>((csv) => _parseCsv(csv))
      .expand((items) => items)
      .toList();

  items.forEach(print);
}

List<Item> _parseCsv(String csv) {
  final converter = CsvToListConverter();
  return converter
      .convert(csv, shouldParseNumbers: false, allowInvalid: true, eol: '\n')
      .skip(1)
      .where((line) => line.isNotEmpty)
      .map<Item>(_parseLine)
      .toList();
}

Item _parseLine(List<dynamic> tokens) {
  final id = tokens[0];
  final date = tokens[1];
  final refund = tokens[5].isNotEmpty;
  final country = tokens[11];
  final amount = int.parse(tokens.last.replaceFirst('.', ''));
  return Item(
    id: id,
    date: date,
    refund: refund,
    country: country,
    amount: amount,
  );
}

// List<Item> _salesWithoutGoogleFees(List<Item> items) {
//   final idsToItemList = <String, List<Item>>{};
//   items.forEach((item) {
//     idsToItemList.update(
//       item.id,
//       (list) => list..add(item),
//       ifAbsent: () => [item],
//     );
//   });
// }

class Item {
  final String id;
  final String date;
  final bool refund;
  final String country;
  final int amount;

  Item({
    @required this.id,
    @required this.date,
    @required this.refund,
    @required this.country,
    @required this.amount,
  });

  @override
  String toString() => '$id: $date $country $amount $refund';
}
