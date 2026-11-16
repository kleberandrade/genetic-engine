import 'dart:math';
import '../../contracts/selection.dart';
import '../../domain/candidate.dart';

/// Samples uniformly from ceil(fraction * populationSize) best-ranked parents.
final class TruncationSelection<T> implements Selection<T> {
  final double fraction;
  TruncationSelection({this.fraction = 0.5}) {
    if (!fraction.isFinite || fraction <= 0 || fraction > 1) {
      throw ArgumentError.value(fraction, 'fraction', 'Must be in (0, 1]');
    }
  }
  @override
  T select(List<Candidate<T>> ranked, Random random) {
    if (ranked.isEmpty) throw ArgumentError('Population cannot be empty');
    final count = (ranked.length * fraction).ceil();
    return ranked[random.nextInt(count)].genome;
  }
}
