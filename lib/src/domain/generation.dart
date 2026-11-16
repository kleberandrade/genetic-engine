import 'candidate.dart';

/// Immutable population statistics. Generation zero is the initial population.
final class Generation<T> {
  final int index;
  final List<Candidate<T>> population;
  Candidate<T> get best => population.first;
  double get meanFitness => population.fold<double>(
      0, (sum, candidate) => sum + candidate.fitness / population.length);
  Generation(this.index, List<Candidate<T>> population)
      : population = List.unmodifiable(population);
}
