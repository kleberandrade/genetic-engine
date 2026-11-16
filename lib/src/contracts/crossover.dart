import 'dart:math';

/// Combines immutable parents into a child without changing either parent.
abstract interface class Crossover<T> {
  T cross(T first, T second, Random random);
}
