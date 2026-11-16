import 'dart:math';
import 'package:genetic_engine/genetic_engine.dart';
import 'package:test/test.dart';

void main() {
  test('fractional elitism preserves the requested fraction of the population',
      () {
    final engine = GeneticAlgorithm<int>.withCallbacks(
      create: (_) => 5,
      fitness: (x) => x.toDouble(),
      select: (ranked, _) => ranked.first.genome,
      crossover: (a, b, _) => a,
      mutate: (g, _) => g - 1,
      elitePolicy: FractionalElitism(0.5),
      populationSize: 10,
      mutationRate: 1,
      maxGenerations: 1,
    );
    expect(engine.effectiveElitism, 5);
    final result = engine.run();
    expect(result.lastGeneration.population.where((c) => c.fitness == 5).length,
        5);
  });
  test('termination policies compose with AND and OR without timing sleeps',
      () {
    final state = EvolutionState(
        generation: 5,
        bestFitness: 10,
        stagnantGenerations: 2,
        objective: Objective.maximize,
        elapsed: Duration(seconds: 3));
    expect(AndTermination([GenerationLimit(5), FitnessTarget(10)]).isMet(state),
        isTrue);
    expect(AndTermination([GenerationLimit(6), FitnessTarget(10)]).isMet(state),
        isFalse);
    expect(OrTermination([GenerationLimit(6), StagnationLimit(2)]).isMet(state),
        isTrue);
    expect(TimeLimit(Duration(seconds: 2)).isMet(state), isTrue);
  });
  test('engine honors custom termination and retains hard generation cap', () {
    final engine = GeneticAlgorithm<int>.withCallbacks(
      create: (_) => 5,
      fitness: (x) => x.toDouble(),
      select: (ranked, _) => ranked.first.genome,
      crossover: (a, b, _) => a,
      mutate: (g, _) => g,
      termination: GenerationLimit(2),
      maxGenerations: 5,
    );
    expect(engine.run().reason, StopReason.customTermination);
    expect(engine.run().lastGeneration.index, 2);
  });
  test('additional permutation crossovers preserve all genes', () {
    final r = Random(9);
    for (final crossover in <Crossover<List<int>>>[
      CycleCrossover(),
      PartiallyMappedCrossover(),
    ]) {
      for (var n = 1; n < 25; n++) {
        final a = List.generate(n, (i) => i);
        for (var trial = 0; trial < 20; trial++) {
          final b = a.toList()..shuffle(r);
          final child = crossover.cross(a, b, r);
          expect(child.length, n);
          expect(child.toSet(), a.toSet());
          expect(a, List.generate(n, (i) => i));
        }
      }
    }
  });
  test('new selection strategies operate on best-first rank', () {
    final p = [Candidate('a', -1), Candidate('b', -5), Candidate('c', -9)];
    final r = Random(10);
    expect(EliteSelection<String>().select(p, r), 'a');
    expect(TruncationSelection<String>(fraction: 0.2).select(p, r), 'a');
    final rank = RankSelection<String>();
    final draws = List.generate(6000, (_) => rank.select(p, r));
    expect(draws.where((g) => g == 'a').length,
        greaterThan(draws.where((g) => g == 'c').length));
    final roulette =
        RouletteWheelSelection<String>(weight: (c) => c.genome == 'c' ? 1 : 0);
    expect(roulette.select(p, r), 'c');
  });
}
