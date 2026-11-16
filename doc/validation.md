# Published package validation

Version under test: **genetic_engine 0.3.1** from pub.dev. Its quality report was
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
| Dart VM | Hosted resolution; binary optimum; native isolate; minimization; PMX invariants |
| Flutter | Hosted resolution; analysis; compute callback; widget renders the result; release web compilation |

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
to 0.3.1 deliberately; testing the published version and testing the working tree
serve different purposes.

The `Published package consumers` workflow runs both jobs. Its success and summary
are the evidence of actual hosted installation, distinct from the local baseline.
Do not mark these checks as passed until their jobs have completed successfully.

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

## Next development boundary

Batch selection (including stochastic universal sampling) needs a genuine batch
contract. Parallel or isolate execution needs explicit progress, cancellation and
sendability semantics. Establish the consumer and benchmark evidence first, then
add those capabilities in separately testable changes rather than altering the
published 0.3.1 behavior during validation.
