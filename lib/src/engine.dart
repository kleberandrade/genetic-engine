import 'dart:math';

/// All callbacks must use the supplied random source for reproducible runs.
typedef GenomeFactory<T> = T Function(Random random);
typedef Fitness<T> = double Function(T genome);
typedef Crossover<T> = T Function(T first, T second, Random random);
typedef Mutation<T> = T Function(T genome, Random random);
typedef Selection<T> = T Function(List<Candidate<T>> ranked, Random random);

enum Objective { maximize, minimize }

enum StopReason { generationLimit, targetFitness, stagnation, cancelled }

/// A scored genome. Custom genomes must be immutable.
class Candidate<T> {
  final T genome;
  final double fitness;
  const Candidate(this.genome, this.fitness);
}

/// Immutable population statistics. Generation zero is the initial population.
class Generation<T> {
  final int index;
  final List<Candidate<T>> population;
  Candidate<T> get best => population.first;
  double get meanFitness => population.fold<double>(
      0, (sum, candidate) => sum + candidate.fitness / population.length);
  Generation(this.index, List<Candidate<T>> population)
      : population = List.unmodifiable(population);
}

class EvolutionResult<T> {
  final Candidate<T> best;
  final Generation<T> lastGeneration;
  final StopReason reason;
  const EvolutionResult(this.best, this.lastGeneration, this.reason);
}

/// Synchronous, CPU-bound evolution. In Flutter native apps, run in an isolate
/// when the workload is significant. Callbacks must not mutate parent genomes.
class GeneticAlgorithm<T> {
  final GenomeFactory<T> create;
  final Fitness<T> fitness;
  final Crossover<T> crossover;
  final Mutation<T> mutate;
  final Selection<T> select;
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
    required this.create,
    required this.fitness,
    required this.crossover,
    required this.mutate,
    required this.select,
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

  bool _better(double a, double b) =>
      objective == Objective.maximize ? a > b : a < b;

  /// Cancel is checked between generations, including before breeding.
  /// Exceptions from user callbacks propagate to the caller.
  EvolutionResult<T> run({
    void Function(Generation<T>)? onGeneration,
    bool Function()? shouldStop,
  }) {
    final random = Random(seed);
    Candidate<T> evaluate(T genome) {
      final score = fitness(genome);
      if (!score.isFinite) throw StateError('Fitness must be finite');
      return Candidate(genome, score);
    }

    Generation<T> rank(int index, List<Candidate<T>> population) {
      population.sort((a, b) => objective == Objective.maximize
          ? b.fitness.compareTo(a.fitness)
          : a.fitness.compareTo(b.fitness));
      return Generation(index, population);
    }

    var generation =
        rank(0, List.generate(populationSize, (_) => evaluate(create(random))));
    var best = generation.best;
    var stagnant = 0;
    while (true) {
      onGeneration?.call(generation);
      StopReason? reason;
      if (targetFitness != null && !_better(targetFitness!, best.fitness)) {
        reason = StopReason.targetFitness;
      } else if (shouldStop?.call() ?? false) {
        reason = StopReason.cancelled;
      } else if (stagnationLimit != null && stagnant >= stagnationLimit!) {
        reason = StopReason.stagnation;
      } else if (generation.index >= maxGenerations) {
        reason = StopReason.generationLimit;
      }
      if (reason != null) return EvolutionResult(best, generation, reason);
      final next = generation.population.take(elitism).toList();
      while (next.length < populationSize) {
        var child = select(generation.population, random);
        if (random.nextDouble() < crossoverRate) {
          child =
              crossover(child, select(generation.population, random), random);
        }
        if (random.nextDouble() < mutationRate) child = mutate(child, random);
        next.add(evaluate(child));
      }
      generation = rank(generation.index + 1, next);
      if (_better(generation.best.fitness, best.fitness)) {
        best = generation.best;
        stagnant = 0;
      } else {
        stagnant++;
      }
    }
  }
}
