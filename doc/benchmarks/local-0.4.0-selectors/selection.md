# Selector comparison

Source: source-v0.4.0-library. Runtime: Dart VM (JIT), macos,
8 logical processors. SDK: 3.11.5.
Measured at 2026-11-16T16:42:01.280387Z.

30 seeds (0–29), one excluded warmup per configuration; configuration order is
shuffled for each seed. Population 100, one elite, crossover rate 0.8.
Each selector starts with the same population for a given problem and seed.

| Problem | Selector | Target hits | Median best fitness | Median evaluations | Median generations | Median ms | P95 ms |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: |
| OneMax32 | Tournament3 | 30/30 | 32.0000 | 1189.0 | 11.0 | 1.208 | 1.398 |
| OneMax32 | Roulette | 30/30 | 32.0000 | 4753.0 | 47.0 | 32.206 | 59.998 |
| OneMax32 | SUS | 30/30 | 32.0000 | 4208.5 | 41.5 | 4.280 | 7.120 |
| Sphere2D | Tournament3 | 30/30 | 0.000540848 | 1387.0 | 13.0 | 0.583 | 1.191 |
| Sphere2D | Roulette | 30/30 | 0.000421756 | 1337.5 | 12.5 | 8.365 | 28.683 |
| Sphere2D | SUS | 30/30 | 0.000576172 | 1733.5 | 16.5 | 0.760 | 2.962 |
## Interpretation and limits

OneMax32 maximizes matches with target 32, mutation 0.3 and a 200-generation cap.
Sphere2D minimizes x²+y² on [-5,5]² with target 0.001, mutation 0.5 and a
500-generation cap. Max evaluation budgets are 19,900 and 49,600 respectively:
100 initial candidates plus 99 evaluations per generation. Target hits stop early;
median evaluations therefore compare actual work as well as capped runs.

Roulette and SUS use identical explicit weights: fitness+1 for OneMax and
1/(1+fitness) for Sphere. Tournament samples three candidates. Selection pressure
is not calibrated to be equal across strategies. SUS reserves two sampled parents
per offspring and discards unused second parents when crossover is skipped.
Trajectories consume randomness differently after identical initialization.

Timing covers initialization and evolution inside run(), excluding engine
construction and report writing. These are wall-clock times; all runs contribute
to medians, including failures to reach target. With 30 samples, nearest-rank P95
is the 29th sorted value. Hardware, SDK, JIT, GC and thermal load affect timings.
One warmup does not eliminate these effects; no time threshold gates CI.

These two small landscapes and fixed parameters do not establish a universally
best selector. Fitness scaling changes roulette/SUS pressure and can dominate
the difference between sampling methods. Target counts describe this experiment,
not a global optimum guarantee. Raw per-seed records include initial and best
fitness, actual evaluations, generations, duration and stop reason.
