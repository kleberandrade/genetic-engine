# Changelog

All notable changes are recorded here. Source tags and hosted publication are
separate: the versions below describe source revisions, not pub.dev availability.

## Unreleased

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
