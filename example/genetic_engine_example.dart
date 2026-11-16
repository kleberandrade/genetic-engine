import 'package:genetic_engine/genetic_engine.dart';

void main() {
  // OneMax: find a binary genome containing 32 true values.
  final engine = GeneticAlgorithm<List<bool>>(
    create: (random) =>
        List.unmodifiable(List.generate(32, (_) => random.nextBool())),
    fitness: (genome) => genome.where((bit) => bit).length.toDouble(),
    select: tournamentSelection(),
    crossover: singlePointCrossover,
    mutate: bitFlipMutation,
    mutationRate: 0.3,
    maxGenerations: 200,
    targetFitness: 32,
    seed: 42,
  );
  final result = engine.run();
  print('Best: ${result.best.fitness}; '
      'generation: ${result.lastGeneration.index}; stop: ${result.reason.name}');
}
