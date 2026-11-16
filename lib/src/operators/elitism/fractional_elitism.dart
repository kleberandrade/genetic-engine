import '../../contracts/elitism.dart';

/// Keeps floor(populationSize * fraction) elites. No rounding up is applied.
final class FractionalElitism implements Elitism {
  final double fraction;
  FractionalElitism(this.fraction) {
    if (!fraction.isFinite || fraction < 0 || fraction >= 1) {
      throw ArgumentError.value(fraction, 'fraction', 'Must be in [0, 1)');
    }
  }
  @override
  int survivorCount(int populationSize) {
    if (populationSize < 2) throw ArgumentError.value(populationSize);
    return (populationSize * fraction).floor();
  }
}
