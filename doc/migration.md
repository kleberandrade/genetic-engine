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

## 0.3 → 0.4: optional batch parent selection

Existing constructor calls with `selection:` and all `withCallbacks` calls keep
their behavior. To use SUS, replace `selection:` with `batchSelection:`; supply
exactly one. No built-in `Selection` implementation needs a new method.

The public `engine.selection` field changes from `Selection<T>` to
`Selection<T>?`, because engines configured with batches have no single selector.
Code reading that field directly must handle null or retain its own selector
reference. The new `engine.batchSelection` field is also nullable. This source
compatibility change is released as minor version 0.4 before 1.0.
