/// A scored genome. Custom genomes must be immutable.
final class Candidate<T> {
  final T genome;
  final double fitness;
  const Candidate(this.genome, this.fitness);
}
