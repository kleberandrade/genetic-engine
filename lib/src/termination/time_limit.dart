import '../contracts/termination.dart';
import '../domain/evolution_state.dart';

/// Cooperative elapsed-time limit; cannot interrupt an individual evaluation.
final class TimeLimit implements Termination {
  final Duration limit;
  TimeLimit(this.limit) {
    if (limit.isNegative) throw ArgumentError.value(limit);
  }
  @override
  bool isMet(EvolutionState state) => state.elapsed >= limit;
}
