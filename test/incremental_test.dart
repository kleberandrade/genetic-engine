import 'package:genetic_engine/genetic_engine.dart';
import 'package:test/test.dart';

void main() {
  GeneticAlgorithm<List<bool>> engine(void Function() evaluated) =>
      GeneticAlgorithm(
        factory: CallbackGenomeFactory(
            (r) => List.unmodifiable(List.generate(16, (_) => r.nextBool()))),
        evaluator: CallbackFitnessEvaluator((g) {
          evaluated();
          return g.where((b) => b).length.toDouble();
        }),
        selection: TournamentSelection(),
        crossover: const SinglePointCrossover(),
        mutation: const BitFlipMutation(),
        seed: 19,
        populationSize: 20,
        maxGenerations: 8,
      );

  test('incremental traversal is lazy and matches synchronous run', () {
    var evaluations = 0;
    final ga = engine(() => evaluations++);
    final iterator = ga.generations().iterator;
    expect(evaluations, 0);
    expect(iterator.moveNext(), isTrue);
    expect(evaluations, 20);
    final first = iterator.current;
    final actual = [first];
    while (iterator.moveNext()) {
      actual.add(iterator.current);
    }
    final expected = <Generation<List<bool>>>[];
    ga.run(onGeneration: expected.add);
    expect(
        actual.map((g) => g.best.genome), expected.map((g) => g.best.genome));
    expect(
        actual.map((g) => g.meanFitness), expected.map((g) => g.meanFitness));
    expect(first.index, 0);
    expect(actual.last.index, 8);
  });

  test('cancellation prevents breeding and independent iterators restart seed',
      () {
    var evaluations = 0;
    var cancelled = false;
    final ga = engine(() => evaluations++);
    final iterator = ga.generations(shouldStop: () => cancelled).iterator;
    iterator.moveNext();
    final genome = iterator.current.best.genome;
    cancelled = true;
    expect(iterator.moveNext(), isFalse);
    expect(evaluations, 20);
    expect(ga.generations().first.best.genome, genome);
  });
}
