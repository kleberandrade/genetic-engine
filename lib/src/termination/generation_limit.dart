import '../contracts/termination.dart';
import '../domain/evolution_state.dart';

/// Stops at the given generation index, including zero.
final class GenerationLimit implements Termination {
  final int limit;
  GenerationLimit(this.limit) {
    if (limit < 0) throw ArgumentError.value(limit);
  }
  @override
  bool isMet(EvolutionState state) => state.generation >= limit;
}
