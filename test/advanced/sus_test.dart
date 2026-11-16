import 'dart:math';
import 'package:genetic_engine/genetic_engine.dart';
import 'package:test/test.dart';

final class OffsetRandom implements Random {
  final double offset;
  OffsetRandom(this.offset);
  @override
  double nextDouble() => offset;
  @override
  int nextInt(int max) => 0;
  @override
  bool nextBool() => false;
}

final class RecordingBatch implements BatchSelection<int> {
  final sizes = <int>[];
  @override
  List<int> selectMany(List<Candidate<int>> ranked, int count, Random random) {
    sizes.add(count);
    return List.filled(count, ranked.first.genome);
  }
}

void main() {
  final population = List.generate(4, (i) => Candidate(i, (i + 1).toDouble()));
  Map<int, int> counts(List<int> values) => {
        for (var i = 0; i < 4; i++) i: values.where((v) => v == i).length,
      };
  test('SUS preserves integral quotas for every start offset', () {
    final sus =
        StochasticUniversalSamplingSelection<int>(weight: (c) => c.fitness);
    for (final offset in [0.0, 0.01, 0.5, 0.999999]) {
      expect(counts(sus.selectMany(population, 10, OffsetRandom(offset))),
          {0: 1, 1: 2, 2: 3, 3: 4});
    }
  });
  test('SUS gives floor or ceiling of expected copies and is repeatable', () {
    final sus =
        StochasticUniversalSamplingSelection<int>(weight: (c) => c.fitness);
    for (var seed = 0; seed < 100; seed++) {
      final selected = sus.selectMany(population, 7, Random(seed));
      expect(selected, sus.selectMany(population, 7, Random(seed)));
      for (var i = 0; i < 4; i++) {
        final expected = 7 * (i + 1) / 10;
        expect(counts(selected)[i],
            inInclusiveRange(expected.floor(), expected.ceil()));
      }
    }
    expect(population.map((c) => c.genome), [0, 1, 2, 3]);
  });
  test('uniformly spaced offsets reproduce expected allocation across batches',
      () {
    final sus =
        StochasticUniversalSamplingSelection<int>(weight: (c) => c.fitness);
    final aggregate = List.filled(4, 0);
    for (var sample = 0; sample < 1000; sample++) {
      for (final parent in sus.selectMany(
          population, 7, OffsetRandom((sample + 0.5) / 1000))) {
        aggregate[parent]++;
      }
    }
    expect(aggregate, [700, 1400, 2100, 2800]);
  });
  test('engine uses the complete shuffled pool when crossover is certain', () {
    final observed = <int>[];
    var created = 0;
    final engine = GeneticAlgorithm<int>(
      factory: CallbackGenomeFactory((r) => created++),
      evaluator: CallbackFitnessEvaluator((g) => (g + 1).toDouble()),
      batchSelection:
          StochasticUniversalSamplingSelection(weight: (c) => c.fitness),
      crossover: CallbackCrossover((a, b, r) {
        observed.addAll([a, b]);
        return a;
      }),
      mutation: CallbackMutation((g, r) => g),
      populationSize: 5,
      elitism: 0,
      maxGenerations: 1,
      crossoverRate: 1,
      mutationRate: 0,
      seed: 4,
    );
    engine.run();
    expect(observed.length, 10);
    for (var i = 0; i < 5; i++) {
      final expected = 10 * (i + 1) / 15;
      expect(observed.where((g) => g == i).length,
          inInclusiveRange(expected.floor(), expected.ceil()));
    }
  });
  test('no batch is requested after stopping at generation zero', () {
    final batch = RecordingBatch();
    GeneticAlgorithm<int>(
      factory: CallbackGenomeFactory((r) => 1),
      evaluator: CallbackFitnessEvaluator((g) => g.toDouble()),
      batchSelection: batch,
      crossover: CallbackCrossover((a, b, r) => a),
      mutation: CallbackMutation((g, r) => g),
      maxGenerations: 0,
    ).run();
    expect(batch.sizes, isEmpty);
  });
  test('zero weights are excluded, all zero uses equally spaced uniform masses',
      () {
    final sus = StochasticUniversalSamplingSelection<int>(
        weight: (c) => c.genome == 2 ? 1 : 0);
    expect(sus.selectMany(population, 20, Random(3)), everyElement(2));
    final uniform = StochasticUniversalSamplingSelection<int>(weight: (_) => 0);
    expect(counts(uniform.selectMany(population, 8, Random(3))),
        {0: 2, 1: 2, 2: 2, 3: 2});
  });
  test('normalization handles huge weights and weights are evaluated once', () {
    var calls = 0;
    final sus = StochasticUniversalSamplingSelection<int>(weight: (_) {
      calls++;
      return 1e308;
    });
    final selected = sus.selectMany(population, 8, Random(2));
    expect(calls, 4);
    expect(counts(selected), {0: 2, 1: 2, 2: 2, 3: 2});
    expect(() => selected.add(99), throwsUnsupportedError);
  });
  test('invalid counts, empty population and invalid weights are rejected', () {
    final sus =
        StochasticUniversalSamplingSelection<int>(weight: (c) => c.fitness);
    expect(sus.selectMany([], 0, Random(1)), isEmpty);
    expect(
        () => sus.selectMany(population, -1, Random(1)), throwsArgumentError);
    expect(() => sus.selectMany([], 1, Random(1)), throwsArgumentError);
    for (final invalid in [-1.0, double.nan, double.infinity]) {
      final invalidSus =
          StochasticUniversalSamplingSelection<int>(weight: (_) => invalid);
      expect(() => invalidSus.selectMany(population, 2, Random(1)),
          throwsArgumentError);
    }
  });
  test('engine samples one batch per generation and retains elites', () {
    final batch = RecordingBatch();
    final engine = GeneticAlgorithm<int>(
      factory: CallbackGenomeFactory((r) => r.nextInt(100)),
      evaluator: CallbackFitnessEvaluator((g) => g.toDouble()),
      batchSelection: batch,
      crossover: CallbackCrossover((a, b, r) => a),
      mutation: CallbackMutation((g, r) => g - 1),
      populationSize: 5,
      elitism: 1,
      maxGenerations: 3,
      crossoverRate: 0,
      mutationRate: 1,
      seed: 3,
    );
    final first = engine.run();
    expect(batch.sizes, [8, 8, 8]);
    expect(first.lastGeneration.population.first.fitness, first.best.fitness);
    expect(engine.run().best.fitness, first.best.fitness);
  });
  test('engine rejects missing, ambiguous or malformed selection strategies',
      () {
    GeneticAlgorithm<int> build(
            {Selection<int>? single, BatchSelection<int>? batch}) =>
        GeneticAlgorithm<int>(
            factory: CallbackGenomeFactory((r) => 1),
            evaluator: CallbackFitnessEvaluator((g) => g.toDouble()),
            selection: single,
            batchSelection: batch,
            crossover: CallbackCrossover((a, b, r) => a),
            mutation: CallbackMutation((g, r) => g),
            maxGenerations: 1);
    expect(() => build(), throwsArgumentError);
    expect(() => build(single: const EliteSelection(), batch: RecordingBatch()),
        throwsArgumentError);
    expect(() => build(batch: ShortBatch()).run(), throwsStateError);
  });
}

final class ShortBatch implements BatchSelection<int> {
  @override
  List<int> selectMany(List<Candidate<int>> ranked, int count, Random random) =>
      [];
}
