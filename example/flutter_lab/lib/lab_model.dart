import 'dart:math';

import 'package:genetic_engine/genetic_engine.dart';

enum Problem {
  oneMax('OneMax', 'Turn all 32 genes on. Fitness counts missing bits.'),
  queens('Eight queens', 'Place eight queens with no diagonal conflicts.'),
  salesman(
    'Travelling salesman',
    'Visit eight cities and return to the start.',
  );

  const Problem(this.label, this.description);
  final String label;
  final String description;
}

enum ParentSelection { tournament, rank, sus }

const cities = <Point<double>>[
  Point(.15, .20),
  Point(.46, .12),
  Point(.80, .18),
  Point(.90, .50),
  Point(.78, .82),
  Point(.50, .88),
  Point(.18, .76),
  Point(.08, .46),
];

double fitness(Problem problem, List<int> genome) {
  switch (problem) {
    case Problem.oneMax:
      return genome.where((bit) => bit == 0).length.toDouble();
    case Problem.queens:
      var conflicts = 0;
      for (var a = 0; a < 8; a++) {
        for (var b = a + 1; b < 8; b++) {
          if ((genome[a] - genome[b]).abs() == b - a) {
            conflicts++;
          }
        }
      }
      return conflicts.toDouble();
    case Problem.salesman:
      return List.generate(
        8,
        (i) => cities[genome[i]].distanceTo(cities[genome[(i + 1) % 8]]),
      ).reduce((a, b) => a + b);
  }
}

class LabConfig {
  const LabConfig({
    this.problem = Problem.oneMax,
    this.population = 100,
    this.seed = 42,
    this.selection = ParentSelection.tournament,
    this.alternative = false,
    this.mutationRate = .3,
    this.crossoverRate = .8,
  });
  final Problem problem;
  final int population, seed;
  final ParentSelection selection;
  final bool alternative;
  final double mutationRate, crossoverRate;

  GeneticAlgorithm<List<int>> engine() {
    final binary = problem == Problem.oneMax;
    final Crossover<List<int>> crossover = binary
        ? (alternative
              ? const UniformCrossover<int>()
              : const SinglePointCrossover<int>())
        : (alternative
              ? const OrderCrossover<int>()
              : const PartiallyMappedCrossover<int>());
    final Mutation<List<int>> mutation = binary
        ? CallbackMutation((g, r) {
            final child = g.toList();
            final i = r.nextInt(child.length);
            child[i] = 1 - child[i];
            return List.unmodifiable(child);
          })
        : (alternative
              ? const ReverseSequenceMutation<int>()
              : const SwapMutation<int>());
    return GeneticAlgorithm(
      factory: CallbackGenomeFactory(
        (r) => List.unmodifiable(
          binary
              ? List.generate(32, (_) => r.nextBool() ? 1 : 0)
              : (List.generate(8, (i) => i)..shuffle(r)),
        ),
      ),
      evaluator: CallbackFitnessEvaluator((g) => fitness(problem, g)),
      selection: switch (selection) {
        ParentSelection.tournament => TournamentSelection(),
        ParentSelection.rank => const RankSelection(),
        ParentSelection.sus => null,
      },
      batchSelection: selection == ParentSelection.sus
          ? StochasticUniversalSamplingSelection(
              weight: (c) => 1 / (1 + c.fitness),
            )
          : null,
      crossover: crossover,
      mutation: mutation,
      objective: Objective.minimize,
      populationSize: population,
      mutationRate: mutationRate,
      crossoverRate: crossoverRate,
      maxGenerations: 300,
      targetFitness: problem == Problem.salesman ? null : 0,
      seed: seed,
    );
  }
}
