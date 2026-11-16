# Engineering workflow

This repository is a pure Dart genetic algorithm framework. Keep Flutter, IO,
HTTP, execution workers and fuzzy logic outside its core.

## Changes

- Work in verifiable steps: make it work, make it right, follow practice.
- Reproduce behavior with a public-API test before changing it; observe the
  expected failure. Pin behavior before a structural refactor.
- Put one decision in one place. Prefer typed strategy composition over runtime
  type checks, registries, or inheritance from the engine.
- Model genomes as immutable values. Never mutate parents or share run state.
- Validate configuration at construction and fitness at the callback boundary.
- Follow the source map and dependency rules in `doc/architecture.md`.
- Use `lib/genetic_engine.dart` in tests and examples rather than internal paths.
- Run the checks in CONTRIBUTING.md, and keep docs and changelog synchronized.
- Keep a concise action/reason/validation log in `doc/engineering_log.md`.
- Commit in focused, ordered units; push the completed work to the main line.

## Quality tools

Use crapper, dryer (threshold 0.8), and mutator when they support the source
language. Their current installed versions do not analyze Dart: empty reports
must be recorded as unsupported, never as a successful metric or mutation score.
Use the Dart analyzer and meaningful behavioral tests for this package.

Do not delete unrelated worktrees, caches, or uncommitted changes.
