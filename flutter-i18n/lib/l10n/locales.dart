import 'package:flutter/material.dart';
import 'package:flutter_i18n/l10n/localizations/messages_all.dart';
import 'package:flutter_i18n/l10n/my_app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:tuple/tuple.dart';

/// List of supported locales in the format <language code, region code>.
///
/// Must be kept up to date with localization .arb files.
const supportedLocales = <Tuple2<String, String>>[
  Tuple2('en', ''),
  Tuple2('ar', ''),
  Tuple2('en', 'AU'),
  Tuple2('ja', ''),
];

/// Provides access to app-specific localizations below [MaterialApp].
class AppLocalizations extends MyAppLocalizations {
  static Future<AppLocalizations> load(Locale locale) {
    final name =
        locale.countryCode.isEmpty ? locale.languageCode : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);

    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      return AppLocalizations();
    });
  }

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }
}

/// Provides app-specific localizations to the [MaterialApp].
class AppLocalizationDelegate extends LocalizationsDelegate<AppLocalizations> {
  String _localeTupleToString(Tuple2<String, String> locale) =>
      "${locale.item1}${locale.item2.isEmpty ? "" : "_${locale.item2}"}";

  @override
  bool isSupported(Locale locale) => supportedLocales
        .map(_localeTupleToString)
        .contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return AppLocalizations.load(locale);
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) => false;
}
