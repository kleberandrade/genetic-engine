import 'dart:math';
import 'package:genetic_engine/genetic_engine.dart';
import 'package:test/test.dart';

final class Decrement implements Mutation<int> {
  @override
  int mutate(int genome, Random random) => genome - 1;
}

void main() {
  test('users compose interface strategies without inheriting the engine', () {
    final result = GeneticAlgorithm<int>(
      factory: CallbackGenomeFactory((_) => 5),
      evaluator: CallbackFitnessEvaluator((g) => g.toDouble()),
      selection: TournamentSelection(),
      crossover: CallbackCrossover((a, b, _) => a),
      mutation: Decrement(),
      objective: Objective.minimize,
      populationSize: 4,
      mutationRate: 1,
      targetFitness: 0,
      seed: 9,
    ).run();
    expect(result.best.fitness, 0);
    expect(result.reason, StopReason.targetFitness);
  });

  test('callback adapter constructor and class constructor agree', () {
    final result = GeneticAlgorithm<int>.withCallbacks(
      create: (_) => 5,
      fitness: (g) => g.toDouble(),
      select: (ranked, _) => ranked.first.genome,
      crossover: (a, b, _) => a,
      mutate: (g, _) => g - 1,
      objective: Objective.minimize,
      populationSize: 4,
      mutationRate: 1,
      targetFitness: 0,
    ).run();
    expect(result.best.fitness, 0);
  });

  test('built-in strategies satisfy their contracts', () {
    final Crossover<List<int>> cross = SinglePointCrossover<int>();
    final Mutation<List<int>> mutate = SwapMutation<int>();
    final Selection<int> select = TournamentSelection<int>(size: 1);
    final r = Random(2);
    expect(cross.cross([1, 2], [3, 4], r), [1, 4]);
    expect(mutate.mutate([1, 2], r), [2, 1]);
    expect(select.select([Candidate(7, -5)], r), 7);
  });
}
