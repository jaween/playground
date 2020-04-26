import 'package:async/async.dart';
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
                              Checker(),
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

class Checker extends StatefulWidget {
  @override
  _CheckerState createState() => _CheckerState();
}

class _CheckerState extends State<Checker> {
  CancelableCompleter<DateTime> completer;

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      child: Text("Start or cancel"),
      onPressed: () async {
        if (completer != null) {
          print(
              "op completed? ${completer.isCompleted}, cancelled? ${completer.isCanceled}, value ${completer.operation.value}");
          completer.operation.cancel().then((v) {
            print("canel res $v");
          });
        } else {
          print("no existing op");
        }
        final c = CancelableCompleter<DateTime>();
        completer = c;
        final task = Future.microtask(() async {
          print("starting ");
          await Future.delayed(Duration(seconds: 2));
          print("done");
          return DateTime.now();
        });
        task.then((v) => c.complete(v));
        print("Result value is ${await completer.operation.value}");
        print("Next");
      },
    );
  }
}
