@JS()
library my_dart_js_interop_lib;

import 'package:js/js.dart';

@JS()
class MyLib {
  external factory MyLib();
  external void myMethod();
}