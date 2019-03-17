// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ja locale. All the
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
  get localeName => 'ja';

  static m0(howMany) => "${Intl.plural(howMany, zero: 'ガチョウはいません', one: 'ガチョウ${howMany}羽', two: 'ガチョウ${howMany}羽', few: '${howMany} geese', many: '${howMany} geese', other: 'ガチョウ${howMany}羽')}";

  static m1(name) => "${name}、こんにちは ！";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "appTitle" : MessageLookupByLibrary.simpleMessage("国際化"),
    "bodyText" : MessageLookupByLibrary.simpleMessage("書いています"),
    "gooseCount" : m0,
    "pageTitle" : MessageLookupByLibrary.simpleMessage("言語の例"),
    "welcome" : m1
  };
}
