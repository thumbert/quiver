import 'package:signals_flutter/signals_flutter.dart';

final s = signal(0);
// var e1 = effect(() => print('counter: ${s.value}'));

env() {
  effect(() => print('counter: ${s.value}'));
}

void main() {
  final name = signal('Jane');
  effect(() => print(name.value));

  env();

  s.value = 10;
  // e1();

  s.value = 20;
  // e1();
}
