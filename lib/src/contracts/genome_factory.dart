import 'dart:math';

/// Builds an immutable genome using the run-specific random source.
abstract interface class GenomeFactory<T> {
  T create(Random random);
}
