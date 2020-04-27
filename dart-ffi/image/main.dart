import 'dart:ffi';
import 'package:ffi/ffi.dart' as ffi;

typedef native_image_modification = Void Function(
  Pointer<Uint32> image,
  Uint16 width,
  Uint16 height,
);
typedef ImageModification = void Function(
  Pointer<Uint32> image,
  int width,
  int height,
);

void main() {
  print('Dart: Hello from Dart');

  // Loads the dynamic library into memory
  final lib = DynamicLibrary.open('./image_library/bin/libimage.so');

  // Creates a referecne to the native function
  final imageDart2C = lib
      .lookup<NativeFunction<native_image_modification>>('image_modification')
      .asFunction<ImageModification>();

  final width = 1024;
  final height = 1024;
  final imagePointer = ffi.allocate<Uint32>(count: width * height);

  // Executes the native function
  final start = DateTime.now();
  imageDart2C(imagePointer, width, height);
  final duration = DateTime.now().difference(start);
  print('Dart: Execution took ${duration.inMicroseconds} microseconds');

  final data = imagePointer.asTypedList(width * height);
  print('Dart: Data type is ${data.runtimeType} with ${data.length} pixels');

  ffi.free(imagePointer);
}
