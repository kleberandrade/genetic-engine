# Flutter and Dart service integration

The framework is synchronous and imports no Flutter or `dart:io` libraries.
Heavy optimization blocks whichever isolate calls `run`.

## Native Flutter apps

For CPU-heavy runs on native platforms, put the entire optimization inside
`Isolate.run`. Build the engine inside the worker and return a sendable result:

```dart
import 'dart:isolate';
import 'package:genetic_engine/genetic_engine.dart';

Future<double> optimize() => Isolate.run(() {
  final result = GeneticAlgorithm<List<double>>(
    factory: CallbackGenomeFactory(
        (r) => List.unmodifiable([r.nextDouble(), r.nextDouble()])),
    evaluator: CallbackFitnessEvaluator(
        (g) => g.fold<double>(0, (sum, x) => sum + x * x)),
    selection: TournamentSelection(),
    crossover: UniformCrossover(),
    mutation: RealResetMutation(min: 0, max: 1),
    objective: Objective.minimize,
    seed: 42,
  ).run();
  return result.best.fitness;
});
```

Call `optimize` from your controller or service. Data captured by the worker and
its results must be isolate-sendable. This convenience pattern returns a final
result, not live progress. For progress or external cancellation use a dedicated
worker with ports and application-owned messaging. A stop callback observes state
in its own isolate; changing a boolean in the UI isolate does not change it.

Flutter web needs a web worker or a different application-level scheduling
strategy for heavy work. Wrapping a synchronous run in `Future` alone does not
move CPU work off the UI thread. This package includes no worker executor.

## Dart APIs

Validate request size and parameters at the HTTP boundary, map input to immutable
genomes, run a bounded optimization in an appropriate worker, and serialize only
the result required by the client. Keep independent runs' state separate. Bound
concurrency so expensive optimization does not exhaust request-serving capacity.

`maxGenerations`, population size and cancellation checks bound breeding work,
but cannot interrupt one slow fitness call. If evaluations need remote IO, this
synchronous evaluator contract is not an asynchronous scheduling API.
