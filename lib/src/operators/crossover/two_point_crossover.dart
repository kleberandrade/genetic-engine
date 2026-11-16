import 'dart:math';
import '../../contracts/crossover.dart';
import 'validate_parents.dart';

/// Replaces a nonempty contiguous segment of first with second's genes.
/// Fixed-length lists only; this does not preserve permutations.
final class TwoPointCrossover<T> implements Crossover<List<T>> {
  const TwoPointCrossover();
  @override
  List<T> cross(List<T> a, List<T> b, Random random) {
    validateParents(a, b);
    final start = random.nextInt(a.length);
    final end = start + 1 + random.nextInt(a.length - start);
    return List.unmodifiable(
        List.generate(a.length, (i) => i >= start && i < end ? b[i] : a[i]));
  }
}
