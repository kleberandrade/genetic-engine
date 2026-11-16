# genetic_engine

[![Dart CI](https://github.com/kleberandrade/genetic-engine/actions/workflows/ci.yml/badge.svg)](https://github.com/kleberandrade/genetic-engine/actions/workflows/ci.yml)
[![Dart SDK](https://img.shields.io/badge/Dart-%3E%3D3.3.0-blue?logo=dart)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Latest tag](https://img.shields.io/github/v/tag/kleberandrade/genetic-engine)](https://github.com/kleberandrade/genetic-engine/tags)

A **pure Dart genetic algorithm framework** for Flutter apps and Dart APIs.
Compose typed strategies for your problem without modifying the evolution loop.
No runtime dependencies, Flutter imports, or connection to a fuzzy engine.

**Status:** pre-release 0.2.0. GitHub source is available; pub.dev publication is
pending. Badges describe CI, SDK requirements, license and tags; there is no
claim of pub.dev availability or a package score before publication.

## Install from source

```yaml
dependencies:
  genetic_engine:
    git:
      url: https://github.com/kleberandrade/genetic-engine.git
      ref: v0.2.0
```

For local development, use `path: ../genetic_engine` instead. After publication,
this dependency can be replaced with the corresponding hosted version.

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
| Permutation | `OrderCrossover` | `SwapMutation` |
| Custom immutable object | Your `Crossover<T>` | Your `Mutation<T>` |

`TournamentSelection<T>` supports either objective, including negative fitness.
All five extension points are interfaces: `GenomeFactory`, `FitnessEvaluator`,
`Selection`, `Crossover`, and `Mutation`. Functions can be wrapped using the
`Callback...` adapters or passed to `GeneticAlgorithm.withCallbacks`.

## Learn and contribute

- [Getting started, terminology and parameter guide](docs/getting_started.md)
- [Architecture and dependency rules](docs/architecture.md)
- [Custom operators and problem constraints](docs/extending.md)
- [Flutter and Dart service integration](docs/integration.md)
- [Migration from pre-release 0.1](docs/migration.md)
- [Contributing](CONTRIBUTING.md), [changelog](CHANGELOG.md)
- [Engineering log and verification limits](docs/engineering_log.md)

Executable examples: [binary search](example/genetic_engine_example.dart),
[numerical minimization](example/minimize.dart), and
[custom integer mutation](example/custom_mutation.dart).

## Development

```sh
dart pub get
dart format --output=none --set-exit-if-changed lib test example
dart analyze --fatal-infos
dart test
dart run example/genetic_engine_example.dart
dart run example/minimize.dart
dart run example/custom_mutation.dart
dart pub publish --dry-run
```

MIT © 2026 Kleber Andrade.
