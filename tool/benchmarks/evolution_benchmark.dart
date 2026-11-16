import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:genetic_engine/genetic_engine.dart';

final class Trial {
  final String problem;
  final int population;
  final int seed;
  final int microseconds;
  final int generations;
  final double initial;
  final double best;
  final bool success;
  Trial(this.problem, this.population, this.seed, this.microseconds,
      this.generations, this.initial, this.best, this.success);
  Map<String, Object> toJson() => {
        'problem': problem,
        'population': population,
        'seed': seed,
        'microseconds': microseconds,
        'generations': generations,
        'initialFitness': initial,
        'bestFitness': best,
        'success': success,
      };
}

Trial measure<T>(String problem, int population, int seed,
    GeneticAlgorithm<T> algorithm, bool Function(double) isSuccess) {
  var initial = double.nan;
  final watch = Stopwatch()..start();
  final result = algorithm.run(onGeneration: (g) {
    if (g.index == 0) initial = g.best.fitness;
  });
  watch.stop();
  return Trial(
      problem,
      population,
      seed,
      watch.elapsedMicroseconds,
      result.lastGeneration.index,
      initial,
      result.best.fitness,
      isSuccess(result.best.fitness));
}

Trial runTrial(String problem, int population, int seed) {
  switch (problem) {
    case 'OneMax32':
      return measure(
          problem,
          population,
          seed,
          GeneticAlgorithm<List<bool>>(
            factory: CallbackGenomeFactory((r) =>
                List.unmodifiable(List.generate(32, (_) => r.nextBool()))),
            evaluator: CallbackFitnessEvaluator(
                (g) => g.where((b) => b).length.toDouble()),
            selection: TournamentSelection(),
            crossover: SinglePointCrossover(),
            mutation: const BitFlipMutation(),
            mutationRate: 0.3,
            populationSize: population,
            maxGenerations: 200,
            targetFitness: 32,
            seed: seed,
          ),
          (score) => score == 32);
    case 'Sphere2D':
      return measure(
          problem,
          population,
          seed,
          GeneticAlgorithm<List<double>>(
            factory: CallbackGenomeFactory((r) => List.unmodifiable(
                List.generate(2, (_) => r.nextDouble() * 10 - 5))),
            evaluator: CallbackFitnessEvaluator(
                (g) => g.fold<double>(0, (sum, x) => sum + x * x)),
            selection: TournamentSelection(),
            crossover: UniformCrossover(),
            mutation: RealResetMutation(min: -5, max: 5),
            mutationRate: 0.5,
            objective: Objective.minimize,
            populationSize: population,
            maxGenerations: 500,
            targetFitness: 0.001,
            seed: seed,
          ),
          (score) => score <= 0.001);
    case 'CircleTSP8':
      final cities =
          List.generate(8, (i) => Point(cos(i * pi / 4), sin(i * pi / 4)));
      final target = 16 * sin(pi / 8) + 1e-9;
      return measure(
          problem,
          population,
          seed,
          GeneticAlgorithm<List<int>>(
            factory: CallbackGenomeFactory((r) =>
                List.unmodifiable(List.generate(8, (i) => i)..shuffle(r))),
            evaluator: CallbackFitnessEvaluator((tour) {
              var distance = 0.0;
              for (var i = 0; i < tour.length; i++) {
                distance += cities[tour[i]]
                    .distanceTo(cities[tour[(i + 1) % tour.length]]);
              }
              return distance;
            }),
            selection: const RankSelection(),
            crossover: const PartiallyMappedCrossover(),
            mutation: const ReverseSequenceMutation(),
            mutationRate: 0.3,
            elitePolicy: FractionalElitism(0.1),
            objective: Objective.minimize,
            populationSize: population,
            maxGenerations: 200,
            targetFitness: target,
            seed: seed,
          ),
          (score) => score <= target);
    default:
      throw ArgumentError.value(problem, 'problem');
  }
}

double median(Iterable<num> values) {
  final sorted = values.map((v) => v.toDouble()).toList()..sort();
  final mid = sorted.length ~/ 2;
  return sorted.length.isOdd
      ? sorted[mid]
      : (sorted[mid - 1] + sorted[mid]) / 2;
}

void main(List<String> args) {
  if (args.length != 2) {
    throw ArgumentError(
        'Usage: evolution_benchmark.dart OUTPUT_DIR SOURCE_LABEL');
  }
  final started = DateTime.now().toUtc();
  const problems = ['OneMax32', 'Sphere2D', 'CircleTSP8'];
  const populations = [50, 100, 250];
  final trials = <Trial>[];
  for (final problem in problems) {
    for (final population in populations) {
      runTrial(problem, population, 9999); // Warmup excluded from results.
      for (var seed = 0; seed < 10; seed++) {
        trials.add(runTrial(problem, population, seed));
      }
    }
  }
  final report = {
    'schemaVersion': 1,
    'source': args[1],
    'startedAtUtc': started.toIso8601String(),
    'runtime': 'Dart VM (JIT)',
    'sdk': Platform.version,
    'os': Platform.operatingSystem,
    'processors': Platform.numberOfProcessors,
    'warmupRunsPerConfiguration': 1,
    'seeds': List.generate(10, (i) => i),
    'trials': trials.map((trial) => trial.toJson()).toList(),
  };
  final output = Directory(args[0])..createSync(recursive: true);
  File('${output.path}/benchmark.json').writeAsStringSync(
      '${const JsonEncoder.withIndent('  ').convert(report)}\n');
  final markdown = StringBuffer('''# Genetic engine benchmark

Source: ${args[1]}. Runtime: Dart VM (JIT), ${Platform.operatingSystem},
${Platform.numberOfProcessors} logical processors. SDK: ${Platform.version.split('(').first.trim()}.
Measured at ${started.toIso8601String()}.

10 seeds (0–9) per configuration; one excluded warmup run. Timing includes
initialization and evolution inside run(), excludes engine construction, and is
wall-clock rather than CPU time. No absolute performance threshold is enforced.

| Problem | Population | Targets reached | Median ms | P95 ms | Median generations |
| --- | ---: | ---: | ---: | ---: | ---: |
''');
  for (final problem in problems) {
    for (final population in populations) {
      final group = trials
          .where((t) => t.problem == problem && t.population == population)
          .toList();
      final times = group.map((t) => t.microseconds).toList()..sort();
      final p95 = times[(times.length * 0.95).ceil() - 1] / 1000;
      markdown.writeln('| $problem | $population | '
          '${group.where((t) => t.success).length}/${group.length} | '
          '${(median(times) / 1000).toStringAsFixed(3)} | '
          '${p95.toStringAsFixed(3)} | '
          '${median(group.map((t) => t.generations)).toStringAsFixed(1)} |');
    }
  }
  markdown.writeln();
  markdown.write('''
Targets: OneMax32 = 32 (200 generations); Sphere2D <= 0.001 on [-5,5]²
(500 generations); CircleTSP8 <= 16*sin(pi/8)+1e-9 (200 generations).
Success means reaching that configured target, not a general global-optimum
guarantee. Exact parameter choices are in the benchmark source. These small
problems are diagnostic baselines, not evidence about larger production tasks.
Hardware, SDK, GC and JIT warmup affect times; do not compare unlike environments
as if this were a controlled library comparison. Raw per-seed results include
initial fitness, final fitness, generations, elapsed time and success.
''');
  File('${output.path}/benchmark.md').writeAsStringSync(markdown.toString());
  stdout.write(markdown);
}
