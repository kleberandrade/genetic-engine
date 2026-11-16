import 'package:genetic_engine/genetic_engine.dart';

// Small noiseless observations for y = slope*x + intercept.
const observations = <({double x, double y})>[
  (x: -2, y: -3),
  (x: -1, y: -1),
  (x: 0, y: 1),
  (x: 1, y: 3),
  (x: 2, y: 5),
];

double meanSquaredError(List<double> coefficients) {
  var sum = 0.0;
  for (final point in observations) {
    final residual = coefficients[0] * point.x + coefficients[1] - point.y;
    sum += residual * residual;
  }
  return sum / observations.length;
}

EvolutionResult<List<double>> fitLine({int seed = 42}) =>
    GeneticAlgorithm<List<double>>(
      factory: CallbackGenomeFactory((r) =>
          List.unmodifiable(List.generate(2, (_) => r.nextDouble() * 10 - 5))),
      evaluator: CallbackFitnessEvaluator(meanSquaredError),
      selection: const RankSelection(),
      crossover: const UniformCrossover(),
      mutation: RealResetMutation(min: -5, max: 5),
      objective: Objective.minimize,
      populationSize: 150,
      mutationRate: 0.5,
      targetFitness: 0.01,
      maxGenerations: 1000,
      seed: seed,
    ).run();

void main() {
  final result = fitLine();
  print('y = ${result.best.genome[0]} * x + ${result.best.genome[1]}; '
      'MSE: ${result.best.fitness}; stop: ${result.reason.name}');
}
