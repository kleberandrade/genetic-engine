import 'package:genetic_engine/genetic_engine.dart';

const items = <({String name, int weight, int value})>[
  (name: 'A', weight: 2, value: 6),
  (name: 'B', weight: 2, value: 10),
  (name: 'C', weight: 3, value: 12),
  (name: 'D', weight: 5, value: 18),
  (name: 'E', weight: 4, value: 14),
  (name: 'F', weight: 1, value: 3),
];
const capacity = 10;

({int weight, int value}) totals(List<bool> chosen) {
  var weight = 0;
  var value = 0;
  for (var i = 0; i < items.length; i++) {
    if (chosen[i]) {
      weight += items[i].weight;
      value += items[i].value;
    }
  }
  return (weight: weight, value: value);
}

EvolutionResult<List<bool>> solveKnapsack({int seed = 42}) =>
    GeneticAlgorithm<List<bool>>(
      factory: CallbackGenomeFactory((r) =>
          List.unmodifiable(List.generate(items.length, (_) => r.nextBool()))),
      evaluator: CallbackFitnessEvaluator((g) {
        final bag = totals(g);
        // All item values are positive: infeasible bags rank below feasible ones.
        return bag.weight > capacity ? -1 : bag.value.toDouble();
      }),
      selection: TournamentSelection(),
      crossover: const SinglePointCrossover(),
      mutation: const BitFlipMutation(),
      mutationRate: 0.4,
      maxGenerations: 100,
      seed: seed,
    ).run();

void main() {
  final result = solveKnapsack();
  final bag = totals(result.best.genome);
  final names = [
    for (var i = 0; i < items.length; i++)
      if (result.best.genome[i]) items[i].name,
  ];
  print('Items: $names; weight: ${bag.weight}/$capacity; value: ${bag.value}; '
      'feasible: ${bag.weight <= capacity}');
}
