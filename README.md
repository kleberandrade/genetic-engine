# genetic_engine

A dependency-free genetic algorithm framework for Dart services and Flutter apps.
Independent of fuzzy logic, machine learning libraries, and Flutter itself.

## Quick start

```dart
import 'package:genetic_engine/genetic_engine.dart';

void main() {
  final result = GeneticAlgorithm<List<bool>>(
    create: (r) => List.unmodifiable(List.generate(32, (_) => r.nextBool())),
    fitness: (g) => g.where((bit) => bit).length.toDouble(),
    select: tournamentSelection(),
    crossover: singlePointCrossover,
    mutate: bitFlipMutation,
    mutationRate: 0.3,
    targetFitness: 32,
    maxGenerations: 200,
    seed: 42,
  ).run();
  print(result.best.fitness);
}
```

Until published, add a local path dependency pointing to this directory.

## Framework contract

The generic type `T` represents a genome. Supply `create`, `fitness`, `select`,
`crossover`, and `mutate` callbacks. Custom classes and integer genomes work
without subclassing. Fitness is synchronous and must return a finite double;
negative values are supported. Exceptions propagate unchanged.

Genomes must be immutable, and operators must return new genomes rather than
mutate parents. Built-in operators return unmodifiable lists. Custom objects
remain the caller's responsibility, including nested mutable fields.

Tournament selection samples population indices with replacement. Populations
are sorted best first for either objective. A child starts from a selected
parent; crossover and mutation are applied independently at their configured
probabilities. Mutation rate is per child, not per gene. One child is produced
per reproduction event. Elites survive without mutation or re-evaluation.
Use deterministic fitness when relying on elitism.

| Representation | Crossover | Mutation |
| --- | --- | --- |
| Binary lists | Single point, uniform | Bit flip |
| Integer lists | Single point, uniform | Custom callback |
| Real lists | Single point, uniform | Bounded random reset |
| Permutations | Order | Swap |
| Custom objects | Custom callback | Custom callback |

Use `Objective.minimize` for costs and distances. Invalid solutions can receive
a finite penalty; constraints, feasibility checks, and repair belong in your
callbacks. No built-in constraint solver or multi-objective optimizer is included.

## Execution and stopping

`maxGenerations` counts breeding steps; generation zero is always evaluated.
`onGeneration` receives a ranked, unmodifiable population after each evaluation.
`best` in the final result is the best ever observed, even with elitism disabled.

Stopping precedence is target fitness, cancellation, stagnation, then generation
limit. Stagnation counts consecutive generations without strict improvement.
`shouldStop` is checked between generations, after the progress callback; it
cannot interrupt an individual evaluation. History is not retained automatically.
A fixed seed repeats the run for deterministic callbacks using only the provided
random source within the same Dart runtime. Cross-runtime sequences are not promised.

## Flutter and Dart APIs

The core uses no `dart:io` or Flutter imports. Calls run synchronously. For native
Flutter apps or CPU-heavy Dart services, invoke the entire run in `Isolate.run`
and return the result. Captured values and results must be isolate-sendable.
For live progress or external cancellation across isolates, wire a worker with
ports; this package does not provide an isolate executor. Flutter web requires
a web worker or another application-level scheduling strategy for heavy work.

Genetic algorithms are stochastic heuristics: they do not guarantee a global
optimum. Start with the supplied defaults and measure results on your problem.

## Examples and validation

```sh
dart pub get
dart analyze
dart test
dart run example/genetic_engine_example.dart
dart run example/minimize.dart
```

MIT licensed. Initial version; package name availability and publication pending.
