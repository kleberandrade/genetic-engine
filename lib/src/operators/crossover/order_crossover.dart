import 'dart:math';
import '../../contracts/crossover.dart';
import 'validate_parents.dart';

/// Permutation-safe order crossover. Parents must contain the same unique genes.
final class OrderCrossover<T> implements Crossover<List<T>> {
  const OrderCrossover();
  @override
  List<T> cross(List<T> a, List<T> b, Random random) {
    validateParents(a, b);
    final genes = a.toSet();
    if (genes.length != a.length ||
        b.toSet().length != b.length ||
        !genes.containsAll(b)) {
      throw ArgumentError(
          'Parents must be permutations of the same unique genes');
    }
    final start = random.nextInt(a.length);
    final end = start + 1 + random.nextInt(a.length - start);
    final segment = a.sublist(start, end);
    final remaining = b.where((gene) => !segment.contains(gene)).iterator;
    return List.unmodifiable(List.generate(a.length, (i) {
      if (i >= start && i < end) return a[i];
      remaining.moveNext();
      return remaining.current;
    }));
  }
}
