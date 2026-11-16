import 'objective.dart';

/// Read-only observations supplied to stateless stopping policies.
final class EvolutionState {
  final int generation;
  final double bestFitness;
  final int stagnantGenerations;
  final Objective objective;
  final Duration elapsed;
  const EvolutionState(
      {required this.generation,
      required this.bestFitness,
      required this.stagnantGenerations,
      required this.objective,
      required this.elapsed});
}
