import 'dart:ffi' as ffi;

typedef _c_init_dart_dynamic_linking = ffi.Void Function(
  ffi.Pointer<ffi.Void> data,
);

typedef _dart_init_dart_dynamic_linking = void Function(
  ffi.Pointer<ffi.Void> data,
);

typedef _c_register_finaliser = ffi.Pointer<ffi.Uint32> Function(
  ffi.Handle handle,
  ffi.IntPtr length,
);

typedef _dart_register_finaliser = ffi.Pointer<ffi.Uint32> Function(
  Object object,
  int length,
);

void main() {
  final lib = ffi.DynamicLibrary.open('./libmylib.so');
  final init = lib.lookupFunction<_c_init_dart_dynamic_linking,
      _dart_init_dart_dynamic_linking>('init_dart_dynamic_linking');
  init(ffi.NativeApi.initializeApiDLData);

  String objectWhichNeedsAFinaliser = "I need a finaliser";
  final registerFinaliser =
      lib.lookupFunction<_c_register_finaliser, _dart_register_finaliser>(
          'register_finaliser');
  const length = 5;
  final nativeDataPointer =
      registerFinaliser(objectWhichNeedsAFinaliser, length);
  final list = nativeDataPointer.asTypedList(length);
  print('Native data is $list');
}
