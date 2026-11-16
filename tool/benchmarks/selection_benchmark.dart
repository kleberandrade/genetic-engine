import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:genetic_engine/genetic_engine.dart';
import 'evolution_benchmark.dart' show median;

const problems = ['OneMax32', 'Sphere2D'];
const selectors = ['Tournament3', 'Roulette', 'SUS'];
const population = 100;
const seedCount = 30;

Map<String, Object> runSelectionTrial(
    String problem, String selector, int seed) {
  var evaluations = 0;
  double? initial;
  final watch = Stopwatch();
  Map<String, Object> measure<T>(GeneticAlgorithm<T> engine, double target) {
    watch.start();
    final result = engine.run(onGeneration: (g) {
      if (g.index == 0) initial = g.best.fitness;
    });
    watch.stop();
    return {
      'problem': problem,
      'selector': selector,
      'seed': seed,
      'microseconds': watch.elapsedMicroseconds,
      'generations': result.lastGeneration.index,
      'evaluations': evaluations,
      'initialFitness': initial!,
      'bestFitness': result.best.fitness,
      'success': problem == 'OneMax32'
          ? result.best.fitness >= target
          : result.best.fitness <= target,
      'stopReason': result.reason.name,
    };
  }

  Selection<T>? single<T>(double Function(Candidate<T>) weight) =>
      switch (selector) {
        'Tournament3' => TournamentSelection<T>(size: 3),
        'Roulette' => RouletteWheelSelection<T>(weight: weight),
        'SUS' => null,
        _ => throw ArgumentError.value(selector, 'selector'),
      };
  BatchSelection<T>? batch<T>(double Function(Candidate<T>) weight) =>
      selector == 'SUS'
          ? StochasticUniversalSamplingSelection<T>(weight: weight)
          : null;

  switch (problem) {
    case 'OneMax32':
      double weight(Candidate<List<bool>> c) => c.fitness + 1;
      return measure(
          GeneticAlgorithm<List<bool>>(
            factory: CallbackGenomeFactory((r) =>
                List.unmodifiable(List.generate(32, (_) => r.nextBool()))),
            evaluator: CallbackFitnessEvaluator((g) {
              evaluations++;
              return g.where((b) => b).length.toDouble();
            }),
            selection: single(weight),
            batchSelection: batch(weight),
            crossover: const SinglePointCrossover(),
            mutation: const BitFlipMutation(),
            populationSize: population,
            elitism: 1,
            crossoverRate: 0.8,
            mutationRate: 0.3,
            maxGenerations: 200,
            targetFitness: 32,
            seed: seed,
          ),
          32);
    case 'Sphere2D':
      double weight(Candidate<List<double>> c) => 1 / (1 + c.fitness);
      return measure(
          GeneticAlgorithm<List<double>>(
            factory: CallbackGenomeFactory((r) => List.unmodifiable(
                List.generate(2, (_) => r.nextDouble() * 10 - 5))),
            evaluator: CallbackFitnessEvaluator((g) {
              evaluations++;
              return g.fold<double>(0, (sum, x) => sum + x * x);
            }),
            selection: single(weight),
            batchSelection: batch(weight),
            crossover: const UniformCrossover(),
            mutation: RealResetMutation(min: -5, max: 5),
            populationSize: population,
            elitism: 1,
            crossoverRate: 0.8,
            mutationRate: 0.5,
            maxGenerations: 500,
            targetFitness: 0.001,
            objective: Objective.minimize,
            seed: seed,
          ),
          0.001);
    default:
      throw ArgumentError.value(problem, 'problem');
  }
}

void main(List<String> args) {
  if (args.length != 2) {
    throw ArgumentError(
        'Usage: selection_benchmark.dart OUTPUT_DIR SOURCE_LABEL');
  }
  final started = DateTime.now().toUtc();
  final configurations = [
    for (final problem in problems)
      for (final selector in selectors) (problem: problem, selector: selector),
  ];
  for (final config in configurations) {
    runSelectionTrial(config.problem, config.selector, 9999);
  }
  final trials = <Map<String, Object>>[];
  for (var seed = 0; seed < seedCount; seed++) {
    final order = configurations.toList()..shuffle(Random(seed + 1701));
    for (final config in order) {
      trials.add(runSelectionTrial(config.problem, config.selector, seed));
    }
  }
  final output = Directory(args[0])..createSync(recursive: true);
  final report = {
    'schemaVersion': 1,
    'source': args[1],
    'startedAtUtc': started.toIso8601String(),
    'sdk': Platform.version,
    'os': Platform.operatingSystem,
    'processors': Platform.numberOfProcessors,
    'runtime': 'Dart VM (JIT)',
    'seeds': List.generate(seedCount, (i) => i),
    'population': population,
    'elitism': 1,
    'crossoverRate': 0.8,
    'warmupRunsPerConfiguration': 1,
    'configurationOrder': 'Shuffled each seed with Random(seed + 1701)',
    'settings': {
      'OneMax32': {
        'weight': 'fitness + 1',
        'mutationRate': 0.3,
        'generationCap': 200,
        'evaluationCap': 19900,
        'target': 32
      },
      'Sphere2D': {
        'weight': '1 / (1 + fitness)',
        'mutationRate': 0.5,
        'generationCap': 500,
        'evaluationCap': 49600,
        'target': 0.001
      },
    },
    'trials': trials,
  };
  File('${output.path}/selection.json').writeAsStringSync(
      '${const JsonEncoder.withIndent('  ').convert(report)}\n');
  final markdown = StringBuffer('''# Selector comparison

Source: ${args[1]}. Runtime: Dart VM (JIT), ${Platform.operatingSystem},
${Platform.numberOfProcessors} logical processors. SDK: ${Platform.version.split('(').first.trim()}.
Measured at ${started.toIso8601String()}.

30 seeds (0–29), one excluded warmup per configuration; configuration order is
shuffled for each seed. Population 100, one elite, crossover rate 0.8.
Each selector starts with the same population for a given problem and seed.

| Problem | Selector | Target hits | Median best fitness | Median evaluations | Median generations | Median ms | P95 ms |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: |
''');
  for (final config in configurations) {
    final group = trials
        .where((t) =>
            t['problem'] == config.problem && t['selector'] == config.selector)
        .toList();
    final times = group.map((t) => t['microseconds'] as int).toList()..sort();
    markdown.writeln('| ${config.problem} | ${config.selector} | '
        '${group.where((t) => t['success'] == true).length}/${group.length} | '
        '${median(group.map((t) => t['bestFitness'] as num)).toStringAsPrecision(6)} | '
        '${median(group.map((t) => t['evaluations'] as num)).toStringAsFixed(1)} | '
        '${median(group.map((t) => t['generations'] as num)).toStringAsFixed(1)} | '
        '${(median(times) / 1000).toStringAsFixed(3)} | '
        '${(times[(times.length * 0.95).ceil() - 1] / 1000).toStringAsFixed(3)} |');
  }
  markdown.write('''
## Interpretation and limits

OneMax32 maximizes matches with target 32, mutation 0.3 and a 200-generation cap.
Sphere2D minimizes x²+y² on [-5,5]² with target 0.001, mutation 0.5 and a
500-generation cap. Max evaluation budgets are 19,900 and 49,600 respectively:
100 initial candidates plus 99 evaluations per generation. Target hits stop early;
median evaluations therefore compare actual work as well as capped runs.

Roulette and SUS use identical explicit weights: fitness+1 for OneMax and
1/(1+fitness) for Sphere. Tournament samples three candidates. Selection pressure
is not calibrated to be equal across strategies. SUS reserves two sampled parents
per offspring and discards unused second parents when crossover is skipped.
Trajectories consume randomness differently after identical initialization.

Timing covers initialization and evolution inside run(), excluding engine
construction and report writing. These are wall-clock times; all runs contribute
to medians, including failures to reach target. With 30 samples, nearest-rank P95
is the 29th sorted value. Hardware, SDK, JIT, GC and thermal load affect timings.
One warmup does not eliminate these effects; no time threshold gates CI.

These two small landscapes and fixed parameters do not establish a universally
best selector. Fitness scaling changes roulette/SUS pressure and can dominate
the difference between sampling methods. Target counts describe this experiment,
not a global optimum guarantee. Raw per-seed records include initial and best
fitness, actual evaluations, generations, duration and stop reason.
''');
  File('${output.path}/selection.md').writeAsStringSync(markdown.toString());
  stdout.write(markdown);
}
