import 'dart:html';
import 'dart:indexed_db';

import 'dart:typed_data';

void main() async {
  if (!IdbFactory.supported) {
    print('IndexedDB not supported');
    return;
  }

  print('IndexedDB is supported');

  print('Opening database');
  final database = await window.indexedDB.open(
    'jaween',
    version: 2,
    onBlocked: (e) => print('IndexedDB blocked $e'),
    onUpgradeNeeded: _initialiseDatabase,
  );
  print('Database ready');

  // print('adding data');
  // await addImage(database);
  // print('done');

  print('Requesting image from database');
  await getImage(database);
}

Future<void> addMap(Database db) async {
  final transaction = db.transaction('my_data', 'readwrite');
  final store = transaction.objectStore('my_data');
  final res = await store.add(
    {'example': 'test 123', 'id': 5},
  );
  print('Added with result $res');
  return transaction.completed;
}

Future<void> addImage(Database db) async {
  const url = 'https://picsum.photos/50';
  final request = await HttpRequest.request(url, responseType: 'blob');
  final Blob blob = request.response;
  print('Image size ${blob.size}');
  print('Image: ${request.status} ${request.statusText}');
  final transaction = db.transaction('my_data', 'readwrite');
  final store = transaction.objectStore('my_data');
  await store.add({'id': 21, 'image': blob});
  return transaction.completed;
}

Future<void> getImage(Database db) async {
  final transaction = db.transaction('my_data', 'readonly');
  final store = transaction.objectStore('my_data');
  final data = await store.getObject(21);
  final Blob blob = data['image'];
  print('Blob ready');

  final reader = FileReader();
  reader.readAsArrayBuffer(blob);
  await reader.onLoadEnd.first;
  final Uint8List result = reader.result;
  print('${result.length} bytes');

  final url = Url.createObjectUrl(blob);
  document.querySelector('#image').attributes['src'] = url;
  return transaction.completed;
}

void _initialiseDatabase(VersionChangeEvent event) {
  final Database database = event.target.result;
  print('Database ${database.name}, version ${database.version}');
  print('Has object stores: ${database.objectStoreNames}');
  if (!database.objectStoreNames.contains('my_data')) {
    database.createObjectStore('my_data', keyPath: 'id');
  }
  print('Database initialised');
}
