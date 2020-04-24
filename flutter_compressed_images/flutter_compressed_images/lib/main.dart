import 'package:flutter/material.dart';

import 'list_screen.dart';

void main() {
  runApp(AppMenu());
}

class AppMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: 'menu',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case 'image':
            return MaterialPageRoute(
              settings: settings,
              builder: (context) => ListScreen(),
            );
            break;
          case 'png':
            return MaterialPageRoute(
              settings: settings,
              builder: (context) => ListScreen(),
            );
            break;
          case 'menu':
            return MaterialPageRoute(
              settings: settings,
              builder: (context) {
                return Scaffold(
                  body: Builder(
                    builder: (context) {
                      return Center(
                        child: Container(
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              RaisedButton(
                                child: Text("Use uncompressed"),
                                onPressed: () =>
                                    Navigator.of(context).pushNamed('image'),
                              ),
                              RaisedButton(
                                child: Text("Use compressed (PNG)"),
                                onPressed: () =>
                                    Navigator.of(context).pushNamed('png'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
            break;
          default:
            return null;
        }
      },
    );
  }
}
