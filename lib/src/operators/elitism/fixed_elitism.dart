import '../../contracts/elitism.dart';

/// Keeps a fixed number of elites; zero disables elitism.
final class FixedElitism implements Elitism {
  final int count;
  FixedElitism(this.count) {
    if (count < 0) throw ArgumentError.value(count, 'count');
  }
  @override
  int survivorCount(int populationSize) {
    if (populationSize < 2 || count >= populationSize) {
      throw ArgumentError('Elites must leave at least one offspring slot');
    }
    return count;
  }
}
