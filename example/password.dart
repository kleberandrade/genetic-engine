import 'dart:math';
import 'package:genetic_engine/genetic_engine.dart';

const target = 'GENETIC';
const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

/// A problem-specific mutation keeps genes within the allowed alphabet.
final class LetterMutation implements Mutation<List<int>> {
  const LetterMutation();
  @override
  List<int> mutate(List<int> genome, Random random) {
    final child = genome.toList();
    child[random.nextInt(child.length)] = random.nextInt(alphabet.length);
    return List.unmodifiable(child);
  }
}

EvolutionResult<List<int>> solvePassword({int seed = 42}) {
  final expected = target.codeUnits.map((c) => c - 65).toList();
  return GeneticAlgorithm<List<int>>(
    factory: CallbackGenomeFactory((r) => List.unmodifiable(
        List.generate(expected.length, (_) => r.nextInt(alphabet.length)))),
    evaluator: CallbackFitnessEvaluator((g) =>
        List.generate(g.length, (i) => g[i] == expected[i] ? 1 : 0)
            .fold(0.0, (a, b) => a + b)),
    batchSelection:
        StochasticUniversalSamplingSelection(weight: (c) => c.fitness + 1),
    crossover: const UniformCrossover(),
    mutation: const LetterMutation(),
    populationSize: 200,
    mutationRate: 0.7,
    maxGenerations: 1000,
    targetFitness: expected.length.toDouble(),
    seed: seed,
  ).run();
}

void main() {
  final result = solvePassword();
  print('Text: ${result.best.genome.map((i) => alphabet[i]).join()}; '
      'matches: ${result.best.fitness}/${target.length}; stop: ${result.reason.name}');
}
