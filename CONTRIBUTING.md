# Contributing

Thank you for helping improve genetic_engine. Use issues for reproducible bugs,
questions and proposals, and pull requests for focused changes.

## Development setup

1. Install a supported Dart SDK (>=3.3.0, <4.0.0). Flutter is optional.
2. Fork and clone the repository, then create a branch from `main`.
3. Run `dart pub get` and `dart test` before editing.

## Change workflow

- For a behavior change, first write a public-API test and see it fail for the
  expected reason. For refactoring, pin behavior before moving code.
- Keep one decision in one place. Implement strategy-specific behavior behind a
  contract; the engine must not depend on concrete genetic operators.
- Preserve immutable inputs and supplied-random-source semantics.
- Add Dartdoc for public APIs, update examples and the relevant guide, and add an
  entry under `Unreleased` in `CHANGELOG.md`.
- Describe the problem, resulting behavior, validation and source compatibility
  in the pull request. Include small reproduction cases rather than private data.

## Required checks

```sh
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
dart run example/task_scheduling.dart
dart run example/parameter_fitting.dart
dart pub publish --dry-run
```

The CI workflow runs these checks with both the minimum SDK and stable Dart.
If dependencies stop resolving on the minimum SDK, fix the dependency constraints
or deliberately raise and document the supported SDK floor.

Tests should verify consumer-visible behavior, invalid input boundaries,
representation invariants and compatibility with both objectives. Avoid asserting
only implementation details or an incidental random sequence.

## Releases

Maintain semantic versions. Before 1.0, an incompatible public API change advances
the minor version. Update pubspec and changelog together, run all checks, create
an annotated `vX.Y.Z` Git tag, and push it. Version tags run validation and then create a GitHub release
from `doc/releases/X.Y.Z.md`; include that notes file before tagging.
A source tag does not imply a pub.dev
publication. Hosted publication is a separate maintainer action after validation.

The local `crapper`, `dryer` and `mutator` tools do not currently support Dart.
Their empty output is not evidence of low complexity, no duplication, or mutation
coverage. Record tool limitations honestly and use Dart-aware checks.

Contributions are licensed under the repository's MIT license.

## Repository topics

The desired GitHub topics are recorded in `.github/topics.json`. A maintainer
with an authenticated GitHub CLI and repository administration permission can
apply them with:

```sh
gh api --method PUT repos/kleberandrade/genetic-engine/topics --input .github/topics.json
```

Committing that file alone does not change GitHub's repository metadata. The
package's five pub.dev topics are configured independently in `pubspec.yaml`.


## Published consumer validation

After source checks pass, the dedicated `Published package consumers` workflow
resolves the pinned hosted version in fresh Dart and Flutter projects. Run
`bash tool/validate_consumers.sh dart` and the `flutter` variant when developing
those checks. See `doc/validation.md` for exact scope and evidence limitations.

For selector experiments, run `dart run tool/benchmarks/selection_benchmark.dart
.consumer-reports source-checkout`. Keep raw seed results and environment metadata;
report target success and actual evaluation counts alongside timing.

## Flutter evolution lab

The optional application in `example/flutter_lab` uses Flutter 3.50.0 / Dart
3.14.0 and its committed lockfile. It consumes the checkout rather than hosted
0.4.0. From that directory run `flutter pub get --enforce-lockfile`,
`flutter analyze --fatal-infos`, `flutter test`, then
`flutter build web --release --base-href /genetic-engine/
--no-web-resources-cdn --no-wasm-dry-run`. The `Flutter evolution lab` workflow
performs core and application checks before Pages deployment on main. Do not add
Flutter imports or scheduling policy to the core library.
