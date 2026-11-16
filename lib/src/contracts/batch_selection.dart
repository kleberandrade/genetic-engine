import 'dart:math';
import '../domain/candidate.dart';

/// Selects exactly `count` parents from a population ranked best first.
/// Implementations must not mutate candidates or retain state between calls.
/// Count zero returns an empty list; a positive count needs a nonempty population.
abstract interface class BatchSelection<T> {
  List<T> selectMany(List<Candidate<T>> ranked, int count, Random random);
}
