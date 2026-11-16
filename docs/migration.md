# Pre-release 0.1 → 0.2

This is a breaking source change before the first hosted release. Strategy names
that were function typedefs are now interfaces.

| 0.1 | 0.2 class-oriented constructor |
| --- | --- |
| `create: fn` | `factory: CallbackGenomeFactory(fn)` |
| `fitness: fn` | `evaluator: CallbackFitnessEvaluator(fn)` |
| `select: tournamentSelection()` | `selection: TournamentSelection()` |
| `crossover: singlePointCrossover` | `crossover: SinglePointCrossover()` |
| `mutate: bitFlipMutation` | `mutation: const BitFlipMutation()` |

The shortest migration for existing function configurations is changing
`GeneticAlgorithm<T>(...)` to `GeneticAlgorithm<T>.withCallbacks(...)`.
The previous convenience operator functions remain available and delegate to the
new strategy implementations. Numerical settings and evolution behavior retain
their meaning. Do not persist enum ordinal indices; use names.
