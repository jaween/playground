import 'dart:ffi';
import 'package:ffi/ffi.dart';

import 'package:finalizers_example/lib_bindings.dart';
import 'package:flutter/material.dart';

class Example extends StatefulWidget {
  @override
  _ExampleState createState() => _ExampleState();
}

class _ExampleState extends State<Example> {
  ExampleLibraryBindings _bindings;

  DynamicLibrary lib;

  @override
  void initState() {
    print(
        'Dart VM API version ${NativeApi.majorVersion}.${NativeApi.minorVersion}');

    lib = DynamicLibrary.open('./example_library/libmylib.so');
    _bindings = ExampleLibraryBindings(lib);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Text('example'),
          RaisedButton(
            child: Text('Init Dart VM API'),
            onPressed: () {
              _bindings.initDartVmApi(NativeApi.initializeApiDLData);
              print('Setup complete');
            },
          ),
          RaisedButton(
            child: Text('Register finalizer'),
            onPressed: () {
              final obj = MyObject();
              final registerFinaliser = lib.lookupFunction<
                  Void Function(Handle, Pointer<Uint32>, IntPtr),
                  void Function(
                      Object, Pointer<Uint32>, int)>("registerFinaliser");
              registerFinaliser(obj, obj.data, 2);
              print('Done');
            },
          ),
          RaisedButton(
            child: Text('Print'),
            onPressed: () {
              print('${DateTime.now()}');
            },
          ),
        ],
      ),
    );
  }
}

class MyObject {
  Pointer<Uint32> data;
  MyObject() {
    data = allocate<Uint32>(count: 2);
    final list = data.asTypedList(2).buffer.asUint32List();
    list[0] = 0xCAFEBABE;
    list[1] = 0xDECAFBAD;
  }
}
