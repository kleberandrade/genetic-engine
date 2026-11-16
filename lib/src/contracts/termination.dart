import '../domain/evolution_state.dart';

/// A stateless stopping predicate; per-run observations live in [EvolutionState].
abstract interface class Termination {
  bool isMet(EvolutionState state);
}
