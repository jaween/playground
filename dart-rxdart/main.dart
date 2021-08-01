import 'dart:async';
import 'package:rxdart/rxdart.dart';

final a = BehaviorSubject<String>();
final b = BehaviorSubject<String>();

// void main() async {
//   print('Hello');
//   start();

//   gen();
//   genMinute();

//   final joined = Rx.merge([a, b]).shareValue();

//   final c = await joined.first;
//   print(c);

//   await Future.delayed(Duration(seconds: 2));
//   await for (var val in joined) {
// 	print('Val is $val');
//   }
// }

// void start() async {
//   await Future.delayed(Duration(seconds: 2));
// }

// void gen() async {
// 	a.add('Second: ${DateTime.now().second}');
// 	for (int i = 0; i < 5; i++) {
// 		await Future.delayed(Duration(seconds: 3));
// 		a.add('Second: ${DateTime.now().second}');
// 	}
// }

// void genMinute() async {
// 	for (int i = 0; i < 10; i++) {
// 		await Future.delayed(Duration(seconds: 4));
// 		b.add('Minute: ${DateTime.now().minute}');
// 	}
// }

void main() async {
  final commands = PublishSubject<int>();
  final buffer = ReplaySubject<int>(onListen: () {
    print('hello');
  });

  dynamic input = buffer;
  final stream = commands.stream.doOnListen(() async {
    while (buffer.isNotEmpty) {
      commands.add(buffer.removeAt(0));
      await Future.delayed(Duration.zero);
    }
    input = commands;
    input.add(5);
  });

  input.add(1);
  input.add(2);
  input.add(3);

  stream.listen((i) => print('First $i'));

  stream.listen((i) => print('Second $i'));
  input.add(4);
  await Future.delayed(Duration.zero);
  await Future.delayed(Duration.zero);
  await Future.delayed(Duration.zero);
  stream.listen((i) => print('Third $i'));
  await Future.delayed(Duration.zero);
  input.add(6);
  stream.listen((i) => print('Fourth $i'));
}
