import 'dart:math';

/// Produces a mutated genome without changing its input.
abstract interface class Mutation<T> {
  T mutate(T genome, Random random);
}
