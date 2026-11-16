# Changelog

All notable changes are recorded here. Source tags and hosted publication are
separate: the versions below describe source revisions, not pub.dev availability.

## Unreleased

- Confirm hosted 0.4.0 publication and 160/160 pub.dev points; update installation.
- Pin independent Dart/Flutter consumers to hosted 0.4.0 and exercise SUS in native
  isolates, Flutter compute, widget rendering and release web compilation.
- Add task scheduling and bounded parameter-fitting examples with independent
  checks of schedule optimality and fitting error.
- Add a 180-run selector comparison with raw per-seed evidence, shared evaluation
  budgets and explicit interpretation limits; run it in hosted consumer CI.

## 0.4.0 — 2026-11-16

- Add `BatchSelection<T>` and genuine stochastic universal sampling with explicit
  weights, one random offset, normalized masses and an all-zero uniform fallback.
- Sample and shuffle one parent pool per generation, keeping elites separate;
  preserve existing on-demand selection behavior and random-call order.
- Require exactly one of `selection` and `batchSelection`. The public `selection`
  field is now nullable; direct field readers must handle batch configurations.
- Share roulette/SUS weight validation without changing roulette's distribution.
- Add original eight queens, password and knapsack examples with solution checks.
- Expand README, architecture, migration, selection and example walkthroughs;
  reference Baker's SUS publication and GeneticSharp's sample catalogue.

- Add isolated Dart and Flutter consumer checks pinned to hosted version 0.3.1,
  including native compute/widget validation and a release web build.
- Add a reproducible multi-seed benchmark and source-labeled local baseline.
- Exclude development tooling from future package archives.

## 0.3.1 — 2026-11-16

- Add braces to the mutation branch and empty AND/OR termination guards,
  resolving the three lints reported by pub.dev for version 0.3.0.
- Enforce `curly_braces_in_flow_control_structures` in local analysis and CI.
- Include the hosted-installation README and package/API badges in the next
  published archive.
- Preserve runtime behavior, public APIs and supported SDK constraints.

## 0.3.0 — 2026-11-16

- Add pluggable fixed/fractional elitism and the effective survivor count.
- Add elite, rank, truncation and explicit-weight roulette selection.
- Add two-point, cycle (CX), and partially mapped (PMX) crossover.
- Add insertion, reverse-sequence and partial-shuffle mutation.
- Add stateless generation, fitness, stagnation and elapsed-time termination,
  composed with AND/OR, while retaining legacy stopping and a hard generation cap.
- Add a travelling salesman example and deterministic operator semantics tests.
- Map implementations to research articles and acknowledge GeneticSharp as
  architectural inspiration without copying implementation code.
- Record eleven desired repository topics separately from the five pub.dev topics.

## 0.2.1 — 2026-11-16

- Move documentation from `docs/` to the conventional `doc/` directory.
- Update documentation links and contributor instructions.
- Preserve the already published v0.2.0 source tag.

## 0.2.0 — 2026-11-16

### Breaking changes

- Replace function typedef extension points with `GenomeFactory`,
  `FitnessEvaluator`, `Selection`, `Crossover`, and `Mutation` interfaces.
- Use `factory`, `evaluator`, `selection`, `crossover`, and `mutation` in the main
  constructor. Existing callback configurations move to `.withCallbacks`.
- Move implementation files into domain, contracts, adapters, engine and operator
  folders. Only the package entry point is a supported import path.

### Added

- Concrete tournament selection, single-point/uniform/order crossover, and
  bit-flip/swap/real-reset mutation strategies.
- Callback adapters, public contract tests and operator invariant tests.
- Beginner, architecture, extension, integration and migration guides.
- Contribution guide, issue and pull request templates, repository badges.
- CI matrix for minimum and stable Dart, examples and publication dry-run.

### Preserved

- Seeded runs, objective direction, elites, progress, cancellation, stopping
  priority and best-ever result semantics.
- Operator convenience functions, now delegating to concrete strategies.

## 0.1.0 — 2026-11-16

- Initial generic genetic algorithm with maximization and minimization.
- Tournament selection, elitism, seeded runs and generation callbacks.
- Binary, real and permutation operators.
- Target, stagnation, generation-limit and cooperative cancellation stops.
- Executable examples and deterministic behavioral tests.
