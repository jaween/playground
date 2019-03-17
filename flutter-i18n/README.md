# flutter_i18n

A toy app to learn the Dart [`intl_translations`](https://pub.dartlang.org/packages/intl_translation) package and how to structure a Flutter app for internationalisation.

Should be straightforward to decouple from Flutter and use in a cross-platform way (should only be tightly coupled in `lib/l10n/locales.dart`).

## Steps to localise values

1. Add defaults for localisable values to `lib/l10n/my_app_localizations.dart`.

2. Run `./generate_arbs.sh` to create the translations [ARB](https://github.com/googlei18n/app-resource-bundle/wiki/ApplicationResourceBundleSpecification) file at `assets/l10n/intl_messages.arb`

3. Give copies of this file to translators for localisation.

4. Place the translated files in `assets/l10n/intl_XX_YY.arb`
(where `XX` is the [language code](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes) and `YY` is an optional [country code](https://en.wikipedia.org/wiki/ISO_3166-1), ex. `intl_ar.arb` for Arabic or `intl_en_AU.arb` for Australian English).

5. Run `./arb_to_dart.sh` to generate Dart files containing the localisations in `lib/l10n/localizations`
