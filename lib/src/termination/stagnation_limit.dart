import '../contracts/termination.dart';
import '../domain/evolution_state.dart';

/// Stops after consecutive generations without strict improvement.
final class StagnationLimit implements Termination {
  final int limit;
  StagnationLimit(this.limit) {
    if (limit < 1) throw ArgumentError.value(limit);
  }
  @override
  bool isMet(EvolutionState state) => state.stagnantGenerations >= limit;
}
