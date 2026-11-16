import 'dart:math';
import '../../contracts/crossover.dart';
import 'validate_parents.dart';

/// One-point crossover for fixed-length binary, integer, or real genomes.
final class SinglePointCrossover<T> implements Crossover<List<T>> {
  const SinglePointCrossover();
  @override
  List<T> cross(List<T> a, List<T> b, Random random) {
    validateParents(a, b);
    final point = a.length == 1 ? 1 : 1 + random.nextInt(a.length - 1);
    return List.unmodifiable([...a.take(point), ...b.skip(point)]);
  }
}
