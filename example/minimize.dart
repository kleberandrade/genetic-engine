import 'package:genetic_engine/genetic_engine.dart';

void main() {
  // Minimize x² + y² within [-5, 5].
  final result = GeneticAlgorithm<List<double>>.withCallbacks(
    create: (r) =>
        List.unmodifiable(List.generate(2, (_) => r.nextDouble() * 10 - 5)),
    fitness: (g) => g.fold(0, (sum, x) => sum + x * x),
    objective: Objective.minimize,
    select: tournamentSelection(),
    crossover: uniformCrossover,
    mutate: realResetMutation(min: -5, max: 5),
    mutationRate: 0.5,
    maxGenerations: 500,
    targetFitness: 0.001,
    seed: 42,
  ).run();
  print(
      '${result.best.genome}: ${result.best.fitness} (${result.reason.name})');
}
