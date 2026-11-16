import 'dart:math';
import '../../contracts/crossover.dart';
import 'validate_parents.dart';

/// Alternates complete position cycles between two permutation parents (CX).
/// Does not consume randomness; each gene retains a position from a parent.
final class CycleCrossover<T> implements Crossover<List<T>> {
  const CycleCrossover();
  @override
  List<T> cross(List<T> a, List<T> b, Random random) {
    validatePermutationParents(a, b);
    final position = {for (var i = 0; i < a.length; i++) a[i]: i};
    final visited = <int>{};
    final child = a.toList();
    var fromFirst = true;
    for (var start = 0; start < a.length; start++) {
      if (visited.contains(start)) continue;
      var i = start;
      do {
        visited.add(i);
        child[i] = fromFirst ? a[i] : b[i];
        i = position[b[i]]!;
      } while (i != start);
      fromFirst = !fromFirst;
    }
    return List.unmodifiable(child);
  }
}
