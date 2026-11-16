import 'dart:math';
import '../contracts/genome_factory.dart';
import '../adapters/callback_genome_factory.dart';
import '../contracts/fitness_evaluator.dart';
import '../adapters/callback_fitness_evaluator.dart';
import '../contracts/selection.dart';
import '../adapters/callback_selection.dart';
import '../contracts/crossover.dart';
import '../adapters/callback_crossover.dart';
import '../contracts/mutation.dart';
import '../adapters/callback_mutation.dart';
import '../domain/candidate.dart';
import '../domain/generation.dart';
import '../domain/evolution_result.dart';
import '../domain/objective.dart';
import '../domain/stop_reason.dart';

/// Synchronous, CPU-bound evolution. In Flutter native apps, run in an isolate
/// when the workload is significant. Callbacks must not mutate parent genomes.
final class GeneticAlgorithm<T> {
  final GenomeFactory<T> factory;
  final FitnessEvaluator<T> evaluator;
  final Crossover<T> crossover;
  final Mutation<T> mutation;
  final Selection<T> selection;
  final Objective objective;
  final int populationSize;
  final int maxGenerations;
  final int elitism;
  final int? stagnationLimit;
  final double crossoverRate;
  final double mutationRate;
  final double? targetFitness;
  final int? seed;

  GeneticAlgorithm({
    required this.factory,
    required this.evaluator,
    required this.crossover,
    required this.mutation,
    required this.selection,
    this.objective = Objective.maximize,
    this.populationSize = 100,
    this.maxGenerations = 100,
    this.elitism = 1,
    this.stagnationLimit,
    this.crossoverRate = 0.8,
    this.mutationRate = 0.1,
    this.targetFitness,
    this.seed,
  }) {
    if (populationSize < 2) throw ArgumentError('populationSize must be >= 2');
    if (maxGenerations < 0) throw ArgumentError('maxGenerations must be >= 0');
    if (elitism < 0 || elitism >= populationSize) {
      throw ArgumentError('elitism must be >= 0 and < populationSize');
    }
    if (stagnationLimit != null && stagnationLimit! < 1) {
      throw ArgumentError('stagnationLimit must be positive');
    }
    for (final rate in [crossoverRate, mutationRate]) {
      if (!rate.isFinite || rate < 0 || rate > 1) {
        throw ArgumentError('Rates must be finite and between 0 and 1');
      }
    }
    if (targetFitness != null && !targetFitness!.isFinite) {
      throw ArgumentError('targetFitness must be finite');
    }
  }

  /// Function-oriented entry point using the same strategy-based engine.
  factory GeneticAlgorithm.withCallbacks({
    required T Function(Random random) create,
    required double Function(T genome) fitness,
    required T Function(List<Candidate<T>> ranked, Random random) select,
    required T Function(T first, T second, Random random) crossover,
    required T Function(T genome, Random random) mutate,
    Objective objective = Objective.maximize,
    int populationSize = 100,
    int maxGenerations = 100,
    int elitism = 1,
    int? stagnationLimit,
    double crossoverRate = 0.8,
    double mutationRate = 0.1,
    double? targetFitness,
    int? seed,
  }) =>
      GeneticAlgorithm(
          factory: CallbackGenomeFactory(create),
          evaluator: CallbackFitnessEvaluator(fitness),
          selection: CallbackSelection(select),
          crossover: CallbackCrossover(crossover),
          mutation: CallbackMutation(mutate),
          objective: objective,
          populationSize: populationSize,
          maxGenerations: maxGenerations,
          elitism: elitism,
          stagnationLimit: stagnationLimit,
          crossoverRate: crossoverRate,
          mutationRate: mutationRate,
          targetFitness: targetFitness,
          seed: seed);

  Candidate<T> _evaluate(T genome) {
    final score = evaluator.evaluate(genome);
    if (!score.isFinite) throw StateError('Fitness must be finite');
    return Candidate(genome, score);
  }

  Generation<T> _rank(int index, List<Candidate<T>> population) {
    population.sort((a, b) => objective == Objective.maximize
        ? b.fitness.compareTo(a.fitness)
        : a.fitness.compareTo(b.fitness));
    return Generation(index, population);
  }

  T _reproduce(List<Candidate<T>> ranked, Random random) {
    var child = selection.select(ranked, random);
    if (random.nextDouble() < crossoverRate) {
      child = crossover.cross(child, selection.select(ranked, random), random);
    }
    if (random.nextDouble() < mutationRate)
      child = mutation.mutate(child, random);
    return child;
  }

  Generation<T> _advance(Generation<T> current, Random random) {
    final next = current.population.take(elitism).toList();
    while (next.length < populationSize) {
      next.add(_evaluate(_reproduce(current.population, random)));
    }
    return _rank(current.index + 1, next);
  }

  StopReason? _stopReason(Generation<T> generation, Candidate<T> best,
      int stagnant, bool Function()? shouldStop) {
    final target = targetFitness;
    if (target != null && !objective.isBetter(target, best.fitness)) {
      return StopReason.targetFitness;
    }
    if (shouldStop?.call() ?? false) return StopReason.cancelled;
    final limit = stagnationLimit;
    if (limit != null && stagnant >= limit) return StopReason.stagnation;
    if (generation.index >= maxGenerations) return StopReason.generationLimit;
    return null;
  }

  /// Evaluates generation zero, then breeds until a stopping condition holds.
  /// Cancel is checked between generations, after [onGeneration]. Exceptions
  /// propagate. Each call owns its random source, population, and counters.
  EvolutionResult<T> run({
    void Function(Generation<T>)? onGeneration,
    bool Function()? shouldStop,
  }) {
    final random = Random(seed);
    var generation = _rank(
        0,
        List.generate(
            populationSize, (_) => _evaluate(factory.create(random))));
    var best = generation.best;
    var stagnant = 0;
    while (true) {
      onGeneration?.call(generation);
      final reason = _stopReason(generation, best, stagnant, shouldStop);
      if (reason != null) return EvolutionResult(best, generation, reason);
      generation = _advance(generation, random);
      if (objective.isBetter(generation.best.fitness, best.fitness)) {
        best = generation.best;
        stagnant = 0;
      } else {
        stagnant++;
      }
    }
  }
}
