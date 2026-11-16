import 'dart:math';
import '../../contracts/selection.dart';
import '../../domain/candidate.dart';

/// Fitness-proportionate selection with explicit nonnegative weights.
/// Supply a suitable transformation for negative fitness or minimization.
/// Weights are evaluated once, normalized to avoid overflow, and all-zero
/// weights fall back to uniform selection. This is not rank selection.
final class RouletteWheelSelection<T> implements Selection<T> {
  final double Function(Candidate<T>) weight;
  const RouletteWheelSelection({required this.weight});
  @override
  T select(List<Candidate<T>> ranked, Random random) {
    if (ranked.isEmpty) throw ArgumentError('Population cannot be empty');
    final weights = ranked.map(weight).toList();
    if (weights.any((w) => !w.isFinite || w < 0)) {
      throw ArgumentError('Weights must be finite and nonnegative');
    }
    final scale = weights.reduce(max);
    if (scale == 0) return ranked[random.nextInt(ranked.length)].genome;
    final normalized = weights.map((w) => w / scale).toList();
    var pointer = random.nextDouble() * normalized.reduce((a, b) => a + b);
    for (var i = 0; i < normalized.length; i++) {
      pointer -= normalized[i];
      if (pointer < 0) return ranked[i].genome;
    }
    // Rounding can leave the pointer at a tiny positive value.
    return ranked[weights.lastIndexWhere((w) => w > 0)].genome;
  }
}
