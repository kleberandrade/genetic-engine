# genetic_engine

[![pub package](https://img.shields.io/pub/v/genetic_engine.svg)](https://pub.dev/packages/genetic_engine)
[![API reference](https://img.shields.io/badge/API-reference-blue.svg)](https://pub.dev/documentation/genetic_engine/latest/)
[![Dart CI](https://github.com/kleberandrade/genetic-engine/actions/workflows/ci.yml/badge.svg)](https://github.com/kleberandrade/genetic-engine/actions/workflows/ci.yml)
[![Published consumers](https://github.com/kleberandrade/genetic-engine/actions/workflows/consumers.yml/badge.svg)](https://github.com/kleberandrade/genetic-engine/actions/workflows/consumers.yml)
[![pub points](https://img.shields.io/pub/points/genetic_engine)](https://pub.dev/packages/genetic_engine/score)
[![Dart SDK](https://img.shields.io/badge/Dart-%3E%3D3.3.0-blue?logo=dart)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Latest tag](https://img.shields.io/github/v/tag/kleberandrade/genetic-engine)](https://github.com/kleberandrade/genetic-engine/tags)

A **pure Dart genetic algorithm framework** for Flutter apps and Dart APIs.
Compose typed strategies for your problem without modifying the evolution loop.
No runtime dependencies, Flutter imports, or connection to a fuzzy engine.

Published on [pub.dev](https://pub.dev/packages/genetic_engine) by the verified
publisher [kleberandrade.dev](https://pub.dev/publishers/kleberandrade.dev).

## Installation

```yaml
dependencies:
  genetic_engine: ^0.3.1
```

Or add it from your project directory:

```sh
dart pub add genetic_engine
```

For Flutter projects, `flutter pub add genetic_engine` works too. Import
`package:genetic_engine/genetic_engine.dart` to use the framework.

The current source revision prepares **0.4.0**, adding batch selection and SUS.
Until 0.4.0 is published, use a local `path: ../genetic_engine` dependency for
those additions. The hosted consumer CI remains pinned to published 0.3.1.

## Your first optimization

A genetic algorithm creates candidate solutions, evaluates them, selects parents,
and generates new candidates using crossover and mutation. It repeats this
process until a stopping condition holds. Higher fitness is better by default.

This example asks for 32 binary genes all equal to `true`:

```dart
import 'package:genetic_engine/genetic_engine.dart';

void main() {
  final engine = GeneticAlgorithm<List<bool>>(
    factory: CallbackGenomeFactory((r) =>
        List.unmodifiable(List.generate(32, (_) => r.nextBool()))),
    evaluator: CallbackFitnessEvaluator(
        (g) => g.where((bit) => bit).length.toDouble()),
    selection: TournamentSelection(),
    crossover: SinglePointCrossover(),
    mutation: const BitFlipMutation(),
    mutationRate: 0.3,
    maxGenerations: 200,
    targetFitness: 32,
    seed: 42,
  );
  final result = engine.run();
  print(result.best.fitness);
}
```

Use `Objective.minimize` to optimize costs or distances. A genetic algorithm is a
stochastic heuristic: it does not guarantee the global optimum.

## Choose strategies

| Representation | Crossover | Mutation |
| --- | --- | --- |
| Binary list | `SinglePointCrossover`, `UniformCrossover` | `BitFlipMutation` |
| Integer list | `SinglePointCrossover`, `UniformCrossover` | Your `Mutation<List<int>>` |
| Real list | `SinglePointCrossover`, `UniformCrossover` | `RealResetMutation` |
| Permutation | `OrderCrossover`, `CycleCrossover`, `PartiallyMappedCrossover` | `SwapMutation`, `InsertionMutation`, `ReverseSequenceMutation` |
| Custom immutable object | Your `Crossover<T>` | Your `Mutation<T>` |

`TournamentSelection<T>` supports either objective, including negative fitness.
The main problem extension points are interfaces: `GenomeFactory`, `FitnessEvaluator`,
`Selection`, `Crossover`, and `Mutation`. Functions can be wrapped using the
`Callback...` adapters or passed to `GeneticAlgorithm.withCallbacks`.

## Select parents with SUS

Use `batchSelection:` instead of `selection:` to sample a whole parent pool with
stochastic universal sampling. For a nonnegative matching score:

```dart
batchSelection: StochasticUniversalSamplingSelection<List<bool>>(
  weight: (candidate) => candidate.fitness + 1,
),
```

SUS uses one random offset and equally spaced pointers. Weights must be finite
and nonnegative; for nonnegative minimization costs, one possible transform is
`1 / (1 + candidate.fitness)`. The engine samples two parents per nonelite child,
shuffles the pool and then applies crossover/mutation rates. See the
[selection guide](doc/selection.md) for quotas, zero weights and pairing semantics.
Existing single-parent strategies keep their original on-demand behavior.

## Runnable examples

| Problem | What you learn |
| --- | --- |
| [OneMax](example/genetic_engine_example.dart) | Binary genomes and a known target |
| [Numerical minimization](example/minimize.dart) | Real genes and objective direction |
| [Travelling salesman](example/travelling_salesman.dart) | Permutations, PMX and fractional elitism |
| [Eight queens](example/eight_queens.dart) | Constraint-preserving encoding and SUS |
| [Password](example/password.dart) | Custom letter mutation and SUS |
| [Knapsack](example/knapsack.dart) | Finite penalties and feasibility |
| [Custom mutation](example/custom_mutation.dart) | Implementing a framework interface |

```sh
dart run example/eight_queens.dart
dart run example/password.dart
dart run example/knapsack.dart
```

The [example walkthroughs](doc/examples.md) explain the genome, fitness,
constraints and checks for each problem. Eight queens, password, TSP and function
optimization follow problem families in the GeneticSharp sample catalogue;
all Dart implementations are original.

## Learn and contribute

- [Published consumer validation and benchmark methodology](doc/validation.md)
- [Parent selection, SUS and batch extension](doc/selection.md)
- [Examples and problem modeling](doc/examples.md)
- [Operator catalogue, elitism and composable stopping](doc/operators.md)
- [Papers, implementation references and provenance](doc/references.md)
- [Getting started, terminology and parameter guide](doc/getting_started.md)
- [Architecture and dependency rules](doc/architecture.md)
- [Custom operators and problem constraints](doc/extending.md)
- [Flutter and Dart service integration](doc/integration.md)
- [Migration from pre-release 0.1](doc/migration.md)
- [Contributing](CONTRIBUTING.md), [changelog](CHANGELOG.md)
- [Engineering log and verification limits](doc/engineering_log.md)

## Development

```sh
dart pub get
dart format --output=none --set-exit-if-changed lib test example tool
dart analyze --fatal-infos
dart test
dart run example/genetic_engine_example.dart
dart run example/minimize.dart
dart run example/custom_mutation.dart
dart run example/travelling_salesman.dart
dart run example/eight_queens.dart
dart run example/password.dart
dart run example/knapsack.dart
dart pub publish --dry-run
```

MIT © 2026 Kleber Andrade.
