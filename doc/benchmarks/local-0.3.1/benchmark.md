# Genetic engine benchmark

Source: workspace-lib-identical-to-v0.3.1. Runtime: Dart VM (JIT), macos,
8 logical processors. SDK: 3.11.5.
Measured at 2026-11-16T15:43:34.047336Z.

10 seeds (0–9) per configuration; one excluded warmup run. Timing includes
initialization and evolution inside run(), excludes engine construction, and is
wall-clock rather than CPU time. No absolute performance threshold is enforced.

| Problem | Population | Targets reached | Median ms | P95 ms | Median generations |
| --- | ---: | ---: | ---: | ---: | ---: |
| OneMax32 | 50 | 10/10 | 1.222 | 3.468 | 15.5 |
| OneMax32 | 100 | 10/10 | 1.115 | 1.370 | 11.0 |
| OneMax32 | 250 | 10/10 | 2.237 | 3.155 | 9.5 |
| Sphere2D | 50 | 10/10 | 0.634 | 0.896 | 25.0 |
| Sphere2D | 100 | 10/10 | 0.467 | 0.710 | 11.0 |
| Sphere2D | 250 | 10/10 | 1.128 | 2.214 | 10.0 |
| CircleTSP8 | 50 | 10/10 | 0.941 | 2.173 | 6.0 |
| CircleTSP8 | 100 | 10/10 | 0.733 | 1.275 | 4.5 |
| CircleTSP8 | 250 | 10/10 | 0.856 | 1.585 | 3.5 |

Targets: OneMax32 = 32 (200 generations); Sphere2D <= 0.001 on [-5,5]²
(500 generations); CircleTSP8 <= 16*sin(pi/8)+1e-9 (200 generations).
Success means reaching that configured target, not a general global-optimum
guarantee. Exact parameter choices are in the benchmark source. These small
problems are diagnostic baselines, not evidence about larger production tasks.
Hardware, SDK, GC and JIT warmup affect times; do not compare unlike environments
as if this were a controlled library comparison. Raw per-seed results include
initial fitness, final fitness, generations, elapsed time and success.
