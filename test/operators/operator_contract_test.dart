import 'dart:math';
import 'package:genetic_engine/genetic_engine.dart';
import 'package:test/test.dart';

void main() {
  test('each crossover only copies genes from parents and leaves inputs intact',
      () {
    final random = Random(10);
    final a = List.generate(12, (i) => i);
    final b = List.generate(12, (i) => i + 20);
    for (final op in <Crossover<List<int>>>[
      SinglePointCrossover(),
      UniformCrossover(),
    ]) {
      for (var trial = 0; trial < 50; trial++) {
        final child = op.cross(a, b, random);
        for (var i = 0; i < child.length; i++) {
          expect(child[i], anyOf(a[i], b[i]));
        }
        expect(() => child.add(1), throwsUnsupportedError);
      }
    }
    expect(a, List.generate(12, (i) => i));
    expect(b, List.generate(12, (i) => i + 20));
  });
  test('order crossover preserves exact multiset over many permutations', () {
    final random = Random(11);
    final op = OrderCrossover<int>();
    for (var size = 1; size < 20; size++) {
      final a = List.generate(size, (i) => i);
      final b = a.toList()..shuffle(random);
      final child = op.cross(a, b, random);
      expect(child.length, size);
      expect(child.toSet(), a.toSet());
    }
    expect(() => op.cross([1, 2], [1, 3], random), throwsArgumentError);
    expect(() => op.cross([], [], random), throwsArgumentError);
  });
  test('mutation strategies handle boundaries without changing parents', () {
    final random = Random(12);
    expect(const BitFlipMutation().mutate([false], random), [true]);
    expect(SwapMutation<int>().mutate([1], random), [1]);
    expect(RealResetMutation(min: 2, max: 2).mutate([0], random), [2]);
    expect(
        () => const BitFlipMutation().mutate([], random), throwsArgumentError);
    expect(() => SwapMutation<int>().mutate([], random), throwsArgumentError);
    expect(() => RealResetMutation(min: 0, max: 1).mutate([], random),
        throwsArgumentError);
    for (final bounds in [
      [2.0, 1.0],
      [double.nan, 1.0],
      [0.0, double.infinity]
    ]) {
      expect(() => RealResetMutation(min: bounds[0], max: bounds[1]),
          throwsArgumentError);
    }
  });
  test('tournament chooses the best rank among sampled indices', () {
    final actualRandom = Random(14);
    final expectedRandom = Random(14);
    final population = [
      Candidate('best', -100),
      Candidate('second', -200),
      Candidate('last', -300)
    ];
    final op = TournamentSelection<String>(size: 4);
    for (var i = 0; i < 50; i++) {
      final winner =
          List.generate(4, (_) => expectedRandom.nextInt(3)).reduce(min);
      expect(op.select(population, actualRandom), population[winner].genome);
    }
    expect(() => op.select([], actualRandom), throwsArgumentError);
  });
}
