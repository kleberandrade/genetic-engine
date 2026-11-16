import 'dart:math';
import '../../contracts/selection.dart';
import '../../domain/candidate.dart';

/// Always selects the best-ranked parent. Unlike elitism, this does not preserve
/// that parent as an unchanged survivor; it only chooses reproduction inputs.
final class EliteSelection<T> implements Selection<T> {
  const EliteSelection();
  @override
  T select(List<Candidate<T>> ranked, Random random) {
    if (ranked.isEmpty) throw ArgumentError('Population cannot be empty');
    return ranked.first.genome;
  }
}
