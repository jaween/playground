import 'dart:io';

import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;

final dateRegisteredForGst = DateTime(2020, 02, 16);

void main(List<String> arguments) async {
  if (arguments.isEmpty) {
    print('Usage \'dart google_play_aus_gst.dart DIRECTORY\'');
    return;
  }

  // Parse Google Play reports
  final dirPath = arguments.first;
  final dir = Directory(dirPath);
  final items = await dir
      .list()
      .where((e) => e is File)
      .map<File>((f) => f as File)
      .where((f) => path.extension(f.path) == '.csv')
      .asyncMap((f) => f.readAsString())
      .map<List<Item>>((csv) => _parseCsv(csv))
      .expand((items) => items)
      .toList();
  items.sort((a, b) => a.date.compareTo(b.date));

  // Group related transactions
  final transactionGroups = <String, List<Item>>{};
  items.forEach((item) {
    final items = transactionGroups.putIfAbsent(item.id, () => <Item>[]);
    items.add(item);
  });

  // Generate a CSV invoice for Zoho Books
  final invoiceCsv = _generateZohoBooksInvoice(transactionGroups);
  final invoicePath =
      './zoho_books_import_${DateTime.now().toIso8601String()}.csv';
  _writeToFile(invoiceCsv, invoicePath);
  print('Written invoice to $invoicePath');

  // Total revenue
  final sumCents = items.fold<int>(0, (p, e) => p + e.amount);
  print(
      'Total revenue \$${sumCents / 100} from ${transactionGroups.length} sales');
}

String _generateZohoBooksInvoice(Map<String, List<Item>> transactionGroups) {
  final transactions = Map.of(transactionGroups)
    ..removeWhere((key, value) {
      final hasRefund = (value.where((element) {
        return element.transaction == Transaction.chargeRefund;
      })).isNotEmpty;
      return hasRefund;
    });

  final buffer = StringBuffer();
  buffer.write(
      '"Customer Name","Invoice Number","Estimate Number","PurchaseOrder","Invoice Date","Due Date","Expected Payment Date","Payment Terms","Payment Terms Label","Invoice Status","Currency Code","Exchange Rate","Sales person","Is Inclusive Tax","Item Name","SKU","Item Desc","Quantity","Project Name","Usage unit","Item Price","Item Tax","Item Tax Type","Item Tax %","Item Tax Exemption Reason","Expense Reference ID","Discount","Discount Amount","Discount Type","Is Discount Before Tax","Entity Discount Percent","Entity Discount Amount","Shipping Charge","Shipping Charge Tax Name","Shipping Charge Tax %","Shipping Charge Tax Type","Shipping Charge Tax Exemption Code","Adjustment","Adjustment Description","Invoice Level Tax","Invoice Level Tax Type","Invoice Level Tax %","Invoice Level Tax Exemption Reason","Notes","Terms & Conditions","Partial Payments","PayPal","Authorize.Net","Payflow Pro","Stripe","2Checkout","Braintree","Square","Template Name","Account"');
  buffer.write('\n');
  final dateFormat = DateFormat('y-MM-dd');
  for (var transaction in transactions.entries) {
    final charge = transaction.value
        .firstWhere((item) => item.transaction == Transaction.charge);
    final saleId = charge.id;
    final australia = charge.country == 'AU';
    final amountAfterFees =
        transaction.value.fold<int>(0, (p, e) => p + e.amount);
    final usesGst = australia && charge.date.isAfter(dateRegisteredForGst);
    final String itemName;
    if (charge.sku == 'upgrade_unlimited_layers') {
      itemName = 'Upgrade Unlimited Layers (Pixel Brush)';
    } else if (charge.sku == 'feature_image_import') {
      itemName = 'Image Import (Pixel Brush)';
    } else {
      throw 'No name for sku ${charge.sku}';
    }
    buffer
      ..write('Google Play') // Customer name
      ..write(',')
      ..write('autogenerate_${saleId}') // Invoice number
      ..write(',')
      ..write('') // Estimate number
      ..write(',')
      ..write(saleId) // Purchase order
      ..write(',')
      ..write(dateFormat.format(charge.date)) // Invoice date
      ..write(',')
      ..write('') // Due date
      ..write(',')
      ..write('') // Expected Payment Date
      ..write(',')
      ..write('') // Payment Terms
      ..write(',')
      ..write('') // Payment Terms Label
      ..write(',')
      ..write('Paid') // Invoice Status
      ..write(',')
      ..write('AUD') // Currency Code
      ..write(',')
      ..write('1') // Exchange Rate
      ..write(',')
      ..write('') // Sales person
      ..write(',')
      ..write(usesGst ? 'true' : 'false') // Is Inclusive Tax
      ..write(',')
      ..write(itemName) // Item Name
      ..write(',')
      ..write(charge.sku) // SKU
      ..write(',')
      ..write(charge.productTitle) // Item Desc
      ..write(',')
      ..write('1') // Quantity
      ..write(',')
      ..write('') // Project Name
      ..write(',')
      ..write('') // Usage unit
      ..write(',')
      ..write(amountAfterFees / 100) // Item Price
      ..write(',')
      ..write(usesGst ? 'GST' : '') // Item Tax
      ..write(',')
      ..write('') // Item Tax Type
      ..write(',')
      ..write(usesGst ? '10' : '') // Item Tax %
      ..write(',')
      ..write(usesGst ? '' : 'GST FREE') // Item Tax Exemption Reason
      ..write(',')
      ..write('') // Expense Reference ID
      ..write(',')
      ..write('0') // Discount
      ..write(',')
      ..write('') // Discount Amount
      ..write(',')
      ..write('') // Discount Type
      ..write(',')
      ..write('') // Is Discount Before Tax
      ..write(',')
      ..write('') // Entity Discount Percent
      ..write(',')
      ..write('') // Entity Discount Amount
      ..write(',')
      ..write('') // Shipping Charge
      ..write(',')
      ..write('') // Shipping Charge Tax Name
      ..write(',')
      ..write('') // Shipping Charge Tax %
      ..write(',')
      ..write('') // Shipping Charge Tax Type
      ..write(',')
      ..write('') // Shipping Charge Tax Exemption Code
      ..write(',')
      ..write('') // Adjustment
      ..write(',')
      ..write('') // Adjustment Description
      ..write(',')
      ..write(usesGst ? 'GST' : '') // Invoice Level Tax
      ..write(',')
      ..write('') // Invoice Level Tax Type
      ..write(',')
      ..write(usesGst ? '10' : '') // Invoice Level Tax %
      ..write(',')
      ..write(usesGst ? '' : 'GST FREE') // Invoice Level Tax Exemption Reason
      ..write(',')
      ..write('') // Notes
      ..write(',')
      ..write('') // Terms & Conditions
      ..write(',')
      ..write('') // Partial Payments
      ..write(',')
      ..write('') // PayPal
      ..write(',')
      ..write('') // Authorize.Net
      ..write(',')
      ..write('') // Payflow Pro
      ..write(',')
      ..write('') // Stripe
      ..write(',')
      ..write('') // 2Checkout
      ..write(',')
      ..write('') // Braintree
      ..write(',')
      ..write('') // Square
      ..write(',')
      ..write('Classic') // Template Name
      ..write(',')
      ..write('Sales') // Extra: Account
      ..write('\n');
  }
  return buffer.toString();
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
  final dateString = tokens[1];
  final timeString = tokens[2];
  final dateFormat = DateFormat('MMM d, yyyy hh:mm:ss a zzz');
  final date = dateFormat.parse('$dateString $timeString');
  final taxType = _parseTaxType(tokens[3]);
  final transaction = _parseTransaction(tokens[4]);
  final refund = tokens[5].isNotEmpty;
  final productTitle = tokens[6];
  final sku = tokens[9];
  final country = tokens[11];
  final state = tokens[12];
  final amount = int.parse(tokens[18].replaceFirst('.', ''));
  return Item(
    id: id,
    date: date,
    taxType: taxType,
    transaction: transaction,
    refund: refund,
    productTitle: productTitle,
    sku: sku,
    country: country,
    state: state,
    amount: amount,
    tokens: tokens,
  );
}

Transaction _parseTransaction(String transaction) {
  if (transaction == 'Charge') {
    return Transaction.charge;
  } else if (transaction == 'Charge refund') {
    return Transaction.chargeRefund;
  } else if (transaction == 'Google fee') {
    return Transaction.googleFee;
  } else if (transaction == 'Google fee refund') {
    return Transaction.googleFeeRefund;
  } else if (transaction == 'Tax') {
    return Transaction.tax;
  } else if (transaction == 'Tax refund') {
    return Transaction.taxRefund;
  } else {
    throw 'Unknown transaction type \'$transaction\'';
  }
}

TaxType _parseTaxType(String taxType) {
  if (taxType.isEmpty) {
    return TaxType.none;
  } else if (taxType == 'Brazil CIDE Withholding Tax') {
    return TaxType.brazilCideWitholdingTax;
  } else if (taxType == 'Brazil IRRF Withholding Tax') {
    return TaxType.brazilIrrfWithholdingTax;
  } else {
    throw 'Unknown taxType type \'$taxType\'';
  }
}

Future<void> _writeToFile(String content, String path) async {
  final file = File(path);
  await file.create();
  await file.writeAsString(content);
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
  final DateTime date;
  final TaxType taxType;
  final Transaction transaction;
  final bool refund;
  final String productTitle;
  final String sku;
  final String country;
  final String state;
  final int amount;
  final List<dynamic> tokens;

  Item({
    required this.id,
    required this.date,
    required this.taxType,
    required this.transaction,
    required this.refund,
    required this.productTitle,
    required this.sku,
    required this.country,
    required this.state,
    required this.amount,
    required this.tokens,
  });

  @override
  String toString() =>
      '$id: ${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} $country $amount ${refund ? 'REFUND' : ''}';
}

enum Transaction {
  charge,
  chargeRefund,
  googleFee,
  googleFeeRefund,
  tax,
  taxRefund
}

enum TaxType { none, brazilCideWitholdingTax, brazilIrrfWithholdingTax }
