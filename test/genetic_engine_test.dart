import 'dart:math';
import 'package:genetic_engine/genetic_engine.dart';
import 'package:test/test.dart';

GeneticAlgorithm<List<bool>> binary({int? seed = 42}) => GeneticAlgorithm(
      create: (r) => List.unmodifiable(List.generate(20, (_) => r.nextBool())),
      fitness: (g) => g.where((b) => b).length.toDouble(),
      select: tournamentSelection(),
      crossover: singlePointCrossover,
      mutate: bitFlipMutation,
      mutationRate: 0.5,
      seed: seed,
      maxGenerations: 200,
      targetFitness: 20,
    );

GeneticAlgorithm<int> constant(
        {Objective objective = Objective.maximize,
        double? target,
        int? stagnation,
        int generations = 10,
        double Function(int)? fitness,
        int elitism = 1}) =>
    GeneticAlgorithm(
      create: (_) => 5,
      fitness: fitness ?? (g) => g.toDouble(),
      select: tournamentSelection(),
      crossover: (a, b, _) => a,
      mutate: (g, _) => g - 1,
      mutationRate: 1,
      crossoverRate: 0,
      objective: objective,
      targetFitness: target,
      stagnationLimit: stagnation,
      maxGenerations: generations,
      populationSize: 4,
      elitism: elitism,
    );

void main() {
  test('OneMax reaches known optimum and seeded runs repeat', () {
    final engine = binary();
    final a = engine.run();
    final b = engine.run();
    expect(a.best.fitness, 20);
    expect(a.reason, StopReason.targetFitness);
    expect(a.best.genome, b.best.genome);
    expect(a.lastGeneration.index, b.lastGeneration.index);
  });
  test('elitism preserves best, population size and sorted order', () {
    var previous = double.negativeInfinity;
    binary().run(onGeneration: (g) {
      expect(g.population.length, 100);
      expect(g.best.fitness, greaterThanOrEqualTo(previous));
      previous = g.best.fitness;
      for (var i = 1; i < g.population.length; i++) {
        expect(g.population[i].fitness,
            lessThanOrEqualTo(g.population[i - 1].fitness));
      }
      expect(() => g.population.clear(), throwsUnsupportedError);
    });
  });
  test('minimization uses correct ranking and target direction', () {
    final r = constant(objective: Objective.minimize, target: 0).run();
    expect(r.best.fitness, 0);
    expect(r.reason, StopReason.targetFitness);
  });
  test('initial target, generation zero, stagnation and cancellation', () {
    expect(constant(target: 5).run().lastGeneration.index, 0);
    expect(constant(generations: 0).run().reason, StopReason.generationLimit);
    final stopped = constant(stagnation: 3).run();
    expect(stopped.reason, StopReason.stagnation);
    expect(stopped.lastGeneration.index, 3);
    expect(constant().run(shouldStop: () => true).reason, StopReason.cancelled);
  });
  test('best-ever retained without elitism', () {
    final r = constant(elitism: 0).run();
    expect(r.best.fitness, 5);
    expect(r.lastGeneration.best.fitness, -5);
  });
  test('rejects invalid parameters and non-finite fitness', () {
    expect(() => constant(generations: -1), throwsArgumentError);
    expect(() => constant(stagnation: 0), throwsArgumentError);
    expect(() => constant(elitism: 4), throwsArgumentError);
    expect(() => constant(target: double.nan), throwsArgumentError);
    expect(() => constant(fitness: (_) => double.infinity).run(),
        throwsStateError);
    expect(() => tournamentSelection<int>(size: 0), throwsArgumentError);
  });
  test('operators preserve parents, length, gene domains and permutations', () {
    final random = Random(7);
    final a = [0, 1, 2, 3, 4];
    final b = a.reversed.toList();
    for (var i = 0; i < 200; i++) {
      expect(orderCrossover(a, b, random).toSet(), a.toSet());
      expect(swapMutation(a, random).toSet(), a.toSet());
      expect(singlePointCrossover(a, b, random).length, 5);
      expect(uniformCrossover(a, b, random).length, 5);
      final real = realResetMutation(min: -1, max: 1)([0, 0], random);
      expect(real.every((x) => x >= -1 && x <= 1), isTrue);
    }
    expect(a, [0, 1, 2, 3, 4]);
    final bits = [false, false];
    expect(bitFlipMutation(bits, random).where((b) => b).length, 1);
    expect(bits, [false, false]);
    expect(() => orderCrossover([1, 1], [1, 2], random), throwsArgumentError);
    expect(
        () => singlePointCrossover([1], <int>[], random), throwsArgumentError);
    expect(singlePointCrossover([1], [2], random), [1]);
  });
  test('callback exceptions propagate', () {
    expect(() => constant().run(onGeneration: (_) => throw StateError('test')),
        throwsStateError);
  });
}
