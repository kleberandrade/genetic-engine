import '../contracts/fitness_evaluator.dart';

/// Adapts a function to [FitnessEvaluator].
final class CallbackFitnessEvaluator<T> implements FitnessEvaluator<T> {
  final double Function(T genome) callback;
  const CallbackFitnessEvaluator(this.callback);
  @override
  double evaluate(T genome) => callback(genome);
}
