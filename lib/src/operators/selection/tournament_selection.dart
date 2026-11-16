import 'dart:math';
import '../../contracts/selection.dart';
import '../../domain/candidate.dart';

/// Samples with replacement and picks the best-ranked contestant.
final class TournamentSelection<T> implements Selection<T> {
  final int size;
  TournamentSelection({this.size = 3}) {
    if (size < 1) throw ArgumentError.value(size, 'size');
  }
  @override
  T select(List<Candidate<T>> ranked, Random random) {
    if (ranked.isEmpty) throw ArgumentError('Population cannot be empty');
    var winner = random.nextInt(ranked.length);
    for (var i = 1; i < size; i++) {
      winner = min(winner, random.nextInt(ranked.length));
    }
    return ranked[winner].genome;
  }
}
