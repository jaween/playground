import 'dart:ffi' as ffi;

import 'dart:isolate';

void main() {
  final lib = ffi.DynamicLibrary.open('./libmylib.so');

  final init = lib.lookupFunction<ffi.Void Function(ffi.Pointer<ffi.Void>),
      void Function(ffi.Pointer<ffi.Void>)>('init_dart_dynamic_linking');
  init(ffi.NativeApi.initializeApiDLData);

  generate().listen((_) => print('Dart Work'));

  final receivePort = ReceivePort()..listen(_portListener);
  final nativePort = receivePort.sendPort.nativePort;

  final executeWork = lib.lookupFunction<ffi.Void Function(ffi.Int64 sendPort),
      void Function(int sendPort)>('execute_work');
  print('Dart About to execute native function');
  executeWork(nativePort);
  print('Dart Waiting for native result');
}

void _portListener(dynamic message) {
  print('Dart Message received $message');
}

Stream<void> generate() async* {
  for (int i = 0; i < 5; i++) {
    await Future.delayed(Duration(milliseconds: 200));
    yield null;
  }
}
