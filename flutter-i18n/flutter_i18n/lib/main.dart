import 'package:flutter/material.dart';
import 'package:flutter_i18n/l10n/locales.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        AppLocalizationDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
      ],
      supportedLocales: supportedLocales.map((locale) {
        return Locale(locale.item1, locale.item2);
      }),
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).pageTitle),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(AppLocalizations.of(context).welcome("Fred")),
            Text(AppLocalizations.of(context).welcome("Olivia")),
            Text(AppLocalizations.of(context).welcome("")),
            Text(AppLocalizations.of(context).bodyText),
            Text(AppLocalizations.of(context).gooseCount(0)),
            Text(AppLocalizations.of(context).gooseCount(1)),
            Text(AppLocalizations.of(context).gooseCount(2)),
            Text(AppLocalizations.of(context).gooseCount(3)),
          ],
        ),
      ),
    );
  }
}
