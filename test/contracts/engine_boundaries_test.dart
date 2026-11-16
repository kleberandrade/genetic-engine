import 'package:genetic_engine/genetic_engine.dart';
import 'package:test/test.dart';

GeneticAlgorithm<int> engine(
        {int populationSize = 4,
        int elitism = 1,
        double mutationRate = 1,
        double crossoverRate = 0,
        double? target,
        int? stagnation,
        int generations = 10,
        double Function(int)? score,
        void Function()? crossed}) =>
    GeneticAlgorithm.withCallbacks(
      create: (_) => 5,
      fitness: score ?? (g) => g.toDouble(),
      select: (ranked, _) => ranked.first.genome,
      crossover: (a, b, _) {
        crossed?.call();
        return a;
      },
      mutate: (g, _) => g - 1,
      populationSize: populationSize,
      elitism: elitism,
      mutationRate: mutationRate,
      crossoverRate: crossoverRate,
      targetFitness: target,
      stagnationLimit: stagnation,
      maxGenerations: generations,
    );

void main() {
  test('configuration boundaries reject illegal inputs', () {
    expect(() => engine(populationSize: 1), throwsArgumentError);
    expect(() => engine(elitism: -1), throwsArgumentError);
    for (final rate in [-0.1, 1.1, double.nan, double.infinity]) {
      expect(() => engine(mutationRate: rate), throwsArgumentError);
      expect(() => engine(crossoverRate: rate), throwsArgumentError);
    }
    expect(() => engine(score: (_) => double.nan).run(), throwsStateError);
  });
  test('zero rates skip operators, full crossover always runs', () {
    var calls = 0;
    final unchanged = engine(
            mutationRate: 0,
            crossoverRate: 0,
            crossed: () => calls++,
            generations: 2)
        .run();
    expect(calls, 0);
    expect(unchanged.lastGeneration.population.map((c) => c.genome),
        everyElement(5));
    engine(crossoverRate: 1, crossed: () => calls++, generations: 2).run();
    expect(calls, 6); // (populationSize - elitism) * generations
  });
  test('stop priority and progress-triggered cancellation are deterministic',
      () {
    expect(engine(target: 5).run(shouldStop: () => true).reason,
        StopReason.targetFitness);
    var cancelled = false;
    final result = engine().run(
      onGeneration: (g) {
        if (g.index == 2) cancelled = true;
      },
      shouldStop: () => cancelled,
    );
    expect(result.reason, StopReason.cancelled);
    expect(result.lastGeneration.index, 2);
    expect(engine(stagnation: 1, generations: 1).run().reason,
        StopReason.stagnation);
  });
  test('mean, negative targets and objective comparison follow direction', () {
    expect(Generation(0, [Candidate(1, -2), Candidate(2, -4)]).meanFitness, -3);
    expect(Objective.minimize.isBetter(-5, -2), isTrue);
    expect(Objective.maximize.isBetter(-2, -5), isTrue);
    expect(Objective.maximize.isBetter(5, 5), isFalse);
  });
}
