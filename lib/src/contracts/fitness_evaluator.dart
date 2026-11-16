/// Scores a genome. Return a finite value; negative scores are allowed.
abstract interface class FitnessEvaluator<T> {
  double evaluate(T genome);
}
