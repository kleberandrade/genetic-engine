import 'dart:math';
import 'package:genetic_engine/genetic_engine.dart';

final class DecrementMutation implements Mutation<int> {
  @override
  int mutate(int genome, Random random) => genome > 0 ? genome - 1 : 0;
}

void main() {
  final result = GeneticAlgorithm<int>(
    factory: CallbackGenomeFactory((_) => 5),
    evaluator: CallbackFitnessEvaluator((g) => g.toDouble()),
    selection: TournamentSelection(),
    crossover: CallbackCrossover((a, b, _) => a),
    mutation: DecrementMutation(),
    objective: Objective.minimize,
    mutationRate: 1,
    targetFitness: 0,
    seed: 42,
  ).run();
  print('Custom mutation: ${result.best.genome}; ${result.reason.name}');
}
