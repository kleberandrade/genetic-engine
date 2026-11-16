/// Chooses how many best-ranked candidates survive unchanged.
/// Policies must be deterministic and return 0 <= count < populationSize.
abstract interface class Elitism {
  int survivorCount(int populationSize);
}
