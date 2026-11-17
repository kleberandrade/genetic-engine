import 'package:flutter_test/flutter_test.dart';
import 'package:genetic_engine_lab/lab_model.dart';

void main() {
  test('all scenarios replay a seed and preserve valid representations', () {
    for (final problem in Problem.values) {
      final config = LabConfig(problem: problem);
      final a = config.engine().generations().toList();
      final b = config.engine().generations().toList();
      expect(a.map((g) => g.best.genome), b.map((g) => g.best.genome));
      expect(a.last.best.fitness, lessThanOrEqualTo(a.first.best.fitness));
      for (final g in a) {
        expect(g.population.length, 100);
        for (final candidate in g.population) {
          if (problem == Problem.oneMax) {
            expect(candidate.genome.every((i) => i == 0 || i == 1), isTrue);
          } else {
            expect(candidate.genome.toSet().length, 8);
          }
        }
      }
    }
  });
  test('every exposed operator combination produces finite fitness', () {
    for (final problem in Problem.values) {
      for (final selection in ParentSelection.values) {
        for (final alternative in [false, true]) {
          final generations = LabConfig(
            problem: problem,
            selection: selection,
            alternative: alternative,
          ).engine().generations().take(5);
          expect(generations.last.meanFitness.isFinite, isTrue);
        }
      }
    }
  });
}
