import 'dart:math';
import 'package:genetic_engine/genetic_engine.dart';
import 'package:test/test.dart';

final class Cuts implements Random {
  final List<int> values;
  var index = 0;
  Cuts(this.values);
  @override
  int nextInt(int max) {
    final value = values[index++];
    if (value < 0 || value >= max) throw StateError('Invalid test cut');
    return value;
  }

  @override
  bool nextBool() => throw UnimplementedError();
  @override
  double nextDouble() => throw UnimplementedError();
}

void main() {
  test('PMX resolves mapping conflicts, not just permutation validity', () {
    final a = [1, 2, 3, 4, 5, 6, 7, 8];
    final b = [4, 5, 2, 1, 8, 7, 6, 3];
    expect(PartiallyMappedCrossover<int>().cross(a, b, Cuts([2, 2])),
        [1, 8, 3, 4, 5, 7, 6, 2]);
  });
  test('CX alternates whole cycles and retains positional inheritance', () {
    expect(
        CycleCrossover<int>().cross(
            [1, 2, 3, 4, 5, 6, 7, 8], [2, 1, 4, 3, 6, 5, 8, 7], Random(0)),
        [1, 2, 4, 3, 5, 6, 8, 7]);
  });
  test('two-point copies a selected interval', () {
    expect(
        TwoPointCrossover<int>()
            .cross([1, 2, 3, 4, 5], [6, 7, 8, 9, 10], Cuts([1, 2])),
        [1, 7, 8, 9, 5]);
  });
  test('reverse and insertion apply the defined transformation', () {
    expect(ReverseSequenceMutation<int>().mutate([1, 2, 3, 4, 5], Cuts([1, 1])),
        [1, 4, 3, 2, 5]);
    expect(InsertionMutation<int>().mutate([1, 2, 3, 4, 5], Cuts([1, 2])),
        [1, 3, 4, 2, 5]);
  });
  test('new mutations preserve multiset, length and immutable parents', () {
    final r = Random(19);
    for (final mutation in <Mutation<List<int>>>[
      ReverseSequenceMutation(),
      InsertionMutation(),
      PartialShuffleMutation(),
    ]) {
      for (var n = 1; n < 30; n++) {
        final g = List.generate(n, (i) => i);
        final result = mutation.mutate(g, r);
        expect(result.length, n);
        expect(result.toSet(), g.toSet());
        expect(g, List.generate(n, (i) => i));
        expect(() => result.add(1), throwsUnsupportedError);
      }
      expect(() => mutation.mutate([], r), throwsArgumentError);
    }
  });
  test(
      'permutation strategies reject invalid parents and support nullable genes',
      () {
    for (final cross in <Crossover<List<int?>>>[
      CycleCrossover(),
      PartiallyMappedCrossover(),
    ]) {
      expect(() => cross.cross([1, 1], [1, 2], Random(1)), throwsArgumentError);
      expect(() => cross.cross([1], [1, 2], Random(1)), throwsArgumentError);
      expect(() => cross.cross([], [], Random(1)), throwsArgumentError);
      expect(cross.cross([null, 1, 2], [2, null, 1], Random(1)).toSet(),
          {null, 1, 2});
    }
  });
  test('roulette handles huge weights and rejects invalid transformations', () {
    final population = [Candidate(1, 0), Candidate(2, 0)];
    for (final invalid in [double.nan, double.infinity, -1.0]) {
      expect(
          () => RouletteWheelSelection<int>(weight: (_) => invalid)
              .select(population, Random(2)),
          throwsArgumentError);
    }
    final zero = RouletteWheelSelection<int>(weight: (_) => 0);
    expect(zero.select(population, Random(2)), anyOf(1, 2));
    final huge = RouletteWheelSelection<int>(weight: (_) => double.maxFinite);
    expect(huge.select(population, Random(2)), anyOf(1, 2));
  });
  test('selection strategies reject empty input and fractions are validated',
      () {
    for (final selection in <Selection<int>>[
      EliteSelection(),
      RankSelection(),
      TruncationSelection(),
      RouletteWheelSelection(weight: (_) => 1),
    ]) {
      expect(() => selection.select([], Random(0)), throwsArgumentError);
    }
    for (final f in [0.0, -1.0, 1.1, double.nan]) {
      expect(() => TruncationSelection<int>(fraction: f), throwsArgumentError);
    }
    for (final f in [-1.0, 1.0, double.nan]) {
      expect(() => FractionalElitism(f), throwsArgumentError);
    }
    expect(() => FixedElitism(-1), throwsArgumentError);
    expect(() => FixedElitism(2).survivorCount(2), throwsArgumentError);
    expect(FixedElitism(0).survivorCount(2), 0);
  });
}
