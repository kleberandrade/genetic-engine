import 'dart:math';
import 'package:genetic_engine/genetic_engine.dart';

/// One row per column, with unique rows: only diagonal conflicts remain.
int diagonalConflicts(List<int> rows) {
  var conflicts = 0;
  for (var a = 0; a < rows.length; a++) {
    for (var b = a + 1; b < rows.length; b++) {
      if ((rows[a] - rows[b]).abs() == b - a) conflicts++;
    }
  }
  return conflicts;
}

EvolutionResult<List<int>> solveEightQueens({int seed = 42}) =>
    GeneticAlgorithm<List<int>>(
      factory: CallbackGenomeFactory((Random r) =>
          List.unmodifiable(List.generate(8, (i) => i)..shuffle(r))),
      evaluator:
          CallbackFitnessEvaluator((g) => diagonalConflicts(g).toDouble()),
      batchSelection: StochasticUniversalSamplingSelection(
          weight: (c) => 1 / (1 + c.fitness)),
      crossover: const PartiallyMappedCrossover(),
      mutation: const SwapMutation(),
      objective: Objective.minimize,
      populationSize: 150,
      mutationRate: 0.5,
      targetFitness: 0,
      maxGenerations: 1000,
      seed: seed,
    ).run();

void main() {
  final result = solveEightQueens();
  print('Rows by column: ${result.best.genome}; '
      'diagonal conflicts: ${result.best.fitness}; stop: ${result.reason.name}');
  // Print the actual result even if another configuration reaches the cap.
  for (var row = 0; row < 8; row++) {
    print(List.generate(8, (col) => result.best.genome[col] == row ? 'Q' : '.')
        .join(' '));
  }
}
