import 'dart:math';
import '../domain/candidate.dart';

/// Selects a genome from a nonempty population ranked best first.
abstract interface class Selection<T> {
  T select(List<Candidate<T>> ranked, Random random);
}
