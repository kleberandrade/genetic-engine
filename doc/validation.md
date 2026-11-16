# Published package validation

Version under test: **genetic_engine 0.4.0** from pub.dev. Its quality report was
observed at **160/160**, including **50/50** static-analysis points on 2026-11-16.
[Current pub.dev report](https://pub.dev/packages/genetic_engine/score).

## Independent consumers

`tool/validate_consumers.sh` creates temporary projects outside the repository,
pins the exact hosted version and verifies its lockfile and resolved cache path.
There is no path dependency, dependency override or import of repository source.
The temporary projects are removed by the script's exit trap. Templates have a
`.template` extension so Flutter-only imports do not enter core package analysis.
Development tooling is excluded from package uploads by `.pubignore`.

| Consumer | Checks |
| --- | --- |
| Dart VM | Hosted resolution; tournament/SUS binary optima; native isolates; minimization; PMX invariants |
| Flutter | Hosted resolution; analysis; tournament/SUS compute callbacks; widget renders the result; release web compilation |

The Flutter test verifies a real result computed by the published engine, not a
mocked text value. The web step establishes compilation for the browser target;
it is not an end-to-end browser or mobile-device test. No Android/iOS native build
or device-performance claim is made.

Run with SDK executables on PATH:

```sh
bash tool/validate_consumers.sh dart
bash tool/validate_consumers.sh flutter
```

An optional `CONSUMER_REPORT_DIR` selects where lockfiles and benchmark evidence
are retained. `GENETIC_ENGINE_VERSION` accepts an exact stable version. CI pins it
to 0.4.0 deliberately; testing the published version and testing the working tree
serve different purposes.

The workflow now exercises published SUS in addition to the existing tournament,
minimization and permutation checks. It also generates the selector comparison
inside the fresh hosted Dart project. Both updated jobs passed on 2026-11-16 in
[run 43910958812](https://github.com/kleberandrade/genetic-engine/actions/runs/43910958812)
for commit `c3c5f4b`:

- Hosted Dart 0.4.0 resolution, tournament/SUS, native isolates and both benchmarks:
  passed in 21 seconds.
- Hosted Flutter 0.4.0 analysis, tournament/SUS compute, widget rendering and
  release web compilation: passed in 1 minute 1 second.
- Both evidence artifacts are present, retaining exact-version hosted lockfiles
  and the Dart reports. The 180-target success claim below refers to the committed
  local comparison; no unread CI per-seed values are substituted for it.

[Source CI run 43910958932](https://github.com/kleberandrade/genetic-engine/actions/runs/43910958932)
also passed on Dart 3.3.0 and stable, including 53 tests, analysis, all nine
examples and publication dry-run. Source and hosted checks serve different roles.

### Historical consumer evidence (0.3.1)

Both consumers passed on 2026-11-16 in
[run 43900206559](https://github.com/kleberandrade/genetic-engine/actions/runs/43900206559)
for commit `897fd20`: Dart plus benchmarks passed in 16 seconds, and Flutter
compute/widget checks and release web compilation passed in 1 minute 20 seconds.
Both artifacts were uploaded. All 90 baseline targets were reached. This remains
historical evidence for 0.3.1, not validation of the newer hosted pin.

## Performance and convergence baseline

The benchmark runs OneMax32, Sphere2D and an eight-city unit-circle TSP at population
sizes 50, 100 and 250, using seeds 0–9. Each configuration gets one excluded warmup.
Report median and P95 wall time, median generations and target success count;
retain initial/final fitness and elapsed time for each individual seed.

- [Local report](benchmarks/local-0.3.1/benchmark.md)
- [Local raw results](benchmarks/local-0.3.1/benchmark.json)
- [Benchmark implementation](../tool/benchmarks/evolution_benchmark.dart)

The local report uses the working tree's library after verifying it is identical
to the v0.3.1 library. It does not claim to install the hosted package locally.
CI executes the same benchmark inside the independently resolved hosted Dart
consumer. Reports have separate source labels and environment metadata.

These are tiny diagnostic problems, not a production capacity test. A single
warmup does not eliminate all JIT/GC effects. All timings are environment-specific;
use larger representative problems and repeated controlled runs before choosing
production defaults. A target hit measures that target, not a global guarantee.

No time threshold is used as a CI gate: shared runners are too variable for that.
Correctness tests and hosted integration failures remain hard failures.

## Selector comparison (0.4.0)

- [Local comparison report](benchmarks/local-0.4.0-selectors/selection.md)
- [Raw per-seed results](benchmarks/local-0.4.0-selectors/selection.json)
- [Benchmark source](../tool/benchmarks/selection_benchmark.dart)

```sh
dart run tool/benchmarks/selection_benchmark.dart .consumer-reports source-checkout
```

The local library was verified unchanged from v0.4.0. Two problems, three
selectors and 30 seeds give 180 measured runs, plus six excluded warmups. The
experiment fixes population, elites, crossover/mutation settings and per-problem
generation caps. It records actual fitness evaluations because target hits stop
early. Each selector starts with the same initial population for each seed;
configuration order is shuffled to reduce systematic timing-order effects.

All 180 local runs reached their configured target. For OneMax32 the median
fitness-evaluation counts were 1,189 (tournament), 4,753 (roulette) and 4,208.5
(SUS). For Sphere2D they were 1,387, 1,337.5 and 1,733.5 respectively. This does
not establish a universal ranking: tournament pressure and fitness-proportionate
pressure are not calibrated to match. The weight transform is identical between
roulette and SUS within each problem. Library roulette evaluates weights per
parent draw; SUS evaluates them once per batch, affecting measured runtime.

Raw results and the report record runtime/SDK/hardware context, failures as well
as successes, and timing methodology. CI repeats the same comparison with
`pub.dev:0.4.0` as the source label; hosted timing results should be interpreted
within their own environment, separately from this macOS baseline.

## Next development boundary

SUS now has its explicit batch contract. Execution parallelism still requires
separate progress, cancellation and sendability semantics. Keep those concerns
outside the core until their contracts and consumer behavior can be verified.
