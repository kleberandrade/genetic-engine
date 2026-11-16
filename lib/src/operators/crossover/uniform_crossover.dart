import 'dart:math';
import '../../contracts/crossover.dart';
import 'validate_parents.dart';

/// Chooses each gene independently from either parent.
final class UniformCrossover<T> implements Crossover<List<T>> {
  const UniformCrossover();
  @override
  List<T> cross(List<T> a, List<T> b, Random random) {
    validateParents(a, b);
    return List.unmodifiable(
        List.generate(a.length, (i) => random.nextBool() ? a[i] : b[i]));
  }
}
