import 'dart:math';
import 'package:genetic_engine/genetic_engine.dart';

void main() {
  // Eight cities on a unit circle; the genome is a permutation of city indices.
  final cities =
      List.generate(8, (i) => Point(cos(i * pi / 4), sin(i * pi / 4)));
  double distance(List<int> tour) {
    var total = 0.0;
    for (var i = 0; i < tour.length; i++) {
      total += cities[tour[i]].distanceTo(cities[tour[(i + 1) % tour.length]]);
    }
    return total;
  }

  final result = GeneticAlgorithm<List<int>>(
    factory: CallbackGenomeFactory((r) =>
        List.unmodifiable(List.generate(cities.length, (i) => i)..shuffle(r))),
    evaluator: CallbackFitnessEvaluator(distance),
    selection: const RankSelection(),
    crossover: const PartiallyMappedCrossover(),
    mutation: const ReverseSequenceMutation(),
    elitePolicy: FractionalElitism(0.1),
    objective: Objective.minimize,
    mutationRate: 0.3,
    termination:
        OrTermination([StagnationLimit(40), TimeLimit(Duration(seconds: 2))]),
    maxGenerations: 500,
    seed: 42,
  ).run();
  print('Tour: ${result.best.genome}; distance: ${result.best.fitness}; '
      'stop: ${result.reason.name}');
}
