import '../contracts/termination.dart';
import '../domain/evolution_state.dart';

/// Uses an inclusive target and the objective supplied by the engine.
final class FitnessTarget implements Termination {
  final double target;
  FitnessTarget(this.target) {
    if (!target.isFinite) throw ArgumentError.value(target);
  }
  @override
  bool isMet(EvolutionState state) =>
      !state.objective.isBetter(target, state.bestFitness);
}
