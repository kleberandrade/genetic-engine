import 'dart:math';
import '../../contracts/selection.dart';
import '../../domain/candidate.dart';

/// Linear descending rank weights n, n-1, ..., 1. Works for both objectives
/// without transforming raw fitness. Ties follow the engine's ranked order.
final class RankSelection<T> implements Selection<T> {
  const RankSelection();
  @override
  T select(List<Candidate<T>> ranked, Random random) {
    if (ranked.isEmpty) throw ArgumentError('Population cannot be empty');
    final n = ranked.length;
    var pointer = random.nextDouble() * (n * (n + 1) / 2);
    for (var i = 0; i < n; i++) {
      pointer -= n - i;
      if (pointer < 0) return ranked[i].genome;
    }
    return ranked.last.genome;
  }
}
