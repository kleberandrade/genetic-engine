import 'dart:math';
import '../../contracts/batch_selection.dart';
import '../../domain/candidate.dart';
import 'selection_weights.dart';

/// Fitness-proportionate stochastic universal sampling (SUS).
/// Uses one random offset and equally spaced pointers for the entire batch.
/// Explicit weights must be finite and nonnegative, regardless of objective.
/// All-zero weights use equal masses. Results follow population order; the
/// engine shuffles a copy before pairing, preserving the sampled multiplicities.
final class StochasticUniversalSamplingSelection<T>
    implements BatchSelection<T> {
  final double Function(Candidate<T>) weight;
  const StochasticUniversalSamplingSelection({required this.weight});

  @override
  List<T> selectMany(List<Candidate<T>> ranked, int count, Random random) {
    if (count < 0) throw ArgumentError.value(count, 'count', 'Must be >= 0');
    if (count == 0) return List<T>.unmodifiable([]);
    final weights = selectionWeights(ranked, weight);
    if (weights.every((w) => w == 0)) {
      weights.fillRange(0, weights.length, 1);
    }
    final total = weights.reduce((a, b) => a + b);
    final step = total / count;
    final start = random.nextDouble() * step;
    final lastPositive = weights.lastIndexWhere((w) => w > 0);
    var index = 0;
    var cumulative = weights.first;
    return List<T>.unmodifiable(List<T>.generate(count, (i) {
      final pointer = start + i * step;
      // Half-open intervals exclude zero masses, including at offset zero.
      while (index < lastPositive && pointer >= cumulative) {
        cumulative += weights[++index];
      }
      return ranked[index].genome;
    }));
  }
}
