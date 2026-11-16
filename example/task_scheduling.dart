import 'dart:math';
import 'package:genetic_engine/genetic_engine.dart';

const durations = [9, 8, 7, 6, 5, 4, 3, 2, 1];
const machineCount = 3;

List<int> machineLoads(List<int> assignments) {
  final loads = List.filled(machineCount, 0);
  for (var job = 0; job < durations.length; job++) {
    loads[assignments[job]] += durations[job];
  }
  return loads;
}

/// Job positions are fixed; each gene chooses a machine, so duplicates are valid.
final class MachineAssignmentMutation implements Mutation<List<int>> {
  const MachineAssignmentMutation();
  @override
  List<int> mutate(List<int> genome, Random random) {
    final child = genome.toList();
    final index = random.nextInt(child.length);
    // Draw a different machine without rejection sampling.
    child[index] =
        (child[index] + 1 + random.nextInt(machineCount - 1)) % machineCount;
    return List.unmodifiable(child);
  }
}

EvolutionResult<List<int>> solveSchedule({int seed = 42}) {
  final lowerBound = (durations.reduce((a, b) => a + b) / machineCount).ceil();
  return GeneticAlgorithm<List<int>>(
    factory: CallbackGenomeFactory((r) => List.unmodifiable(
        List.generate(durations.length, (_) => r.nextInt(machineCount)))),
    evaluator:
        CallbackFitnessEvaluator((g) => machineLoads(g).reduce(max).toDouble()),
    selection: TournamentSelection(),
    crossover: const UniformCrossover(),
    mutation: const MachineAssignmentMutation(),
    objective: Objective.minimize,
    populationSize: 150,
    mutationRate: 0.5,
    targetFitness: lowerBound.toDouble(),
    maxGenerations: 500,
    seed: seed,
  ).run();
}

void main() {
  final result = solveSchedule();
  print('Machine per job: ${result.best.genome}; '
      'loads: ${machineLoads(result.best.genome)}; '
      'makespan: ${result.best.fitness}; stop: ${result.reason.name}');
}
