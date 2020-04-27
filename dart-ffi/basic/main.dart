import 'dart:ffi' as ffi;

typedef native_hello_world = ffi.Void Function();
typedef HelloWorld = void Function();

void main() {
  print('Dart: Hello from Dart');

  // Loads the dynamic library into memory
  final lib = ffi.DynamicLibrary.open('./hello_library/bin/libhello.so');

  // Creates a referecne to the native function
  final nativeHelloPointer =
      lib.lookup<ffi.NativeFunction<native_hello_world>>('hello_world');
  print(
      'Dart: Native function address is ${nativeHelloPointer.address.toRadixString(16)}');
  final HelloWorld helloFunction = nativeHelloPointer.asFunction();

  // Executes the native function
  final start = DateTime.now();
  helloFunction();
  final duration = DateTime.now().difference(start);
  print('Dart: Execution took ${duration.inMicroseconds} microseconds');
}
