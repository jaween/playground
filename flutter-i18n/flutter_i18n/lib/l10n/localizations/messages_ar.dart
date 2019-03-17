// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ar locale. All the
// messages from the main program should be duplicated here with the same
// function name.

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

// ignore: unnecessary_new
final messages = new MessageLookup();

// ignore: unused_element
final _keepAnalysisHappy = Intl.defaultLocale;

// ignore: non_constant_identifier_names
typedef MessageIfAbsent(String message_str, List args);

class MessageLookup extends MessageLookupByLibrary {
  get localeName => 'ar';

  static m0(howMany) => "${Intl.plural(howMany, zero: 'لا الأوز', one: '${howMany} أوزة', two: '${howMany} الأوز', few: '${howMany} الأوز', many: '${howMany} الأوز', other: '${howMany} الأوز')}";

  static m1(name) => "مرحبًا ${name} !";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "appTitle" : MessageLookupByLibrary.simpleMessage("تدويل"),
    "bodyText" : MessageLookupByLibrary.simpleMessage("وأنا أكتب"),
    "gooseCount" : m0,
    "pageTitle" : MessageLookupByLibrary.simpleMessage("مثال اللغة"),
    "welcome" : m1
  };
}
