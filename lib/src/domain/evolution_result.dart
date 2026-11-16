import 'candidate.dart';
import 'generation.dart';
import 'stop_reason.dart';

final class EvolutionResult<T> {
  final Candidate<T> best;
  final Generation<T> lastGeneration;
  final StopReason reason;
  const EvolutionResult(this.best, this.lastGeneration, this.reason);
}
