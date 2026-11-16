import '../contracts/termination.dart';
import '../domain/evolution_state.dart';

/// Stops only when every child condition is met. Children are copied and must be stateless.
final class AndTermination implements Termination {
  final List<Termination> conditions;
  AndTermination(Iterable<Termination> conditions)
      : conditions = List.unmodifiable(conditions) {
    if (this.conditions.isEmpty) {
      throw ArgumentError('At least one condition is required');
    }
  }
  @override
  bool isMet(EvolutionState state) =>
      conditions.every((condition) => condition.isMet(state));
}
