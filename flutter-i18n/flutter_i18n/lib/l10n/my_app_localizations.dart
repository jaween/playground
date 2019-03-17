import 'package:intl/intl.dart';

/// Holds the app-specific localizable values.
///
/// Used with the intl_translation package to generate a translatable ARB file.
class MyAppLocalizations {
  String get appTitle {
    return Intl.message(
      "Internationalization",
      name: "appTitle",
      desc: "Name of the application (for the App Switcher/Recent Apps)",
    );
  }

  String get pageTitle {
    return Intl.message(
      "Language example",
      name: "pageTitle",
      desc: "Title in the top app bar of the page",
    );
  }

  String get bodyText {
    return Intl.message(
      "I am writing",
      name: "bodyText",
      desc: "Message which displays in the main body of the app",
    );
  }

  String gooseCount(int howMany) {
    return Intl.plural(
      howMany,
      zero: "No geese",
      one: "$howMany goose",
      two: "$howMany geese",
      few: "$howMany geese",
      many: "$howMany geese",
      other: "$howMany geese",
      args: [howMany],
      name: "gooseCount",
      desc: "Message which displays in the main body of the app",
    );
  }

  String welcome(String name) {
    return Intl.message(
      "Hi $name!",
      args: [name],
      name: "welcome",
      desc: "Greeting message for the user",
      examples: const { "Bob" : "Hi Bob!"},
    );
  }
}
