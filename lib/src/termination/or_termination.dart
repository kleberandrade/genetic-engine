import '../contracts/termination.dart';
import '../domain/evolution_state.dart';

/// Stops when any child condition is met. Children are copied and must be stateless.
final class OrTermination implements Termination {
  final List<Termination> conditions;
  OrTermination(Iterable<Termination> conditions)
      : conditions = List.unmodifiable(conditions) {
    if (this.conditions.isEmpty) {
      throw ArgumentError('At least one condition is required');
    }
  }
  @override
  bool isMet(EvolutionState state) =>
      conditions.any((condition) => condition.isMet(state));
}
