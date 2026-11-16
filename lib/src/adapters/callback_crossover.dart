import 'dart:math';
import '../contracts/crossover.dart';

/// Adapts a function to [Crossover].
final class CallbackCrossover<T> implements Crossover<T> {
  final T Function(T first, T second, Random random) callback;
  const CallbackCrossover(this.callback);
  @override
  T cross(T first, T second, Random random) => callback(first, second, random);
}
