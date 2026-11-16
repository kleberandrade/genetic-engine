# Parent selection: on demand or in batches

Selection chooses parents; elitism carries survivors unchanged. These are
independent decisions. The engine ranks candidates best first for both objectives.

## Choose a contract

| Contract | Engine parameter | Sampling lifetime |
| --- | --- | --- |
| `Selection<T>.select(ranked, random)` | `selection:` | One call for each parent actually needed |
| `BatchSelection<T>.selectMany(ranked, count, random)` | `batchSelection:` | One call per generation that breeds children |

Supply exactly one parameter. Existing `selection:` configurations and
`withCallbacks` retain their on-demand behavior and random-call order. The
`selection` field is now nullable because a batch engine has no single selector;
see [migration](migration.md) if your code reads that field directly.

## Stochastic universal sampling (SUS)

Use `StochasticUniversalSamplingSelection<T>` through **`batchSelection:`**:

```dart
batchSelection: StochasticUniversalSamplingSelection<List<bool>>(
  weight: (candidate) => candidate.fitness + 1,
),
```

This transformation is appropriate when fitness is a nonnegative count, such as
OneMax or matching letters. For a nonnegative minimization cost, use for example
`1 / (1 + candidate.fitness)`. Neither formula is valid for every possible score.
The engine does not silently reverse or shift weights: larger weight always
means more expected parent copies. Use tournament or rank selection when no
meaningful weight transformation is available.

Given weights `[1, 2, 3, 4]` and a batch of ten parents, the total is ten, the
pointer spacing is one, and one random offset in `[0, 1)` locates all ten
pointers. The candidates receive `[1, 2, 3, 4]` copies. With a batch of seven,
the expected copies are `[0.7, 1.4, 2.1, 2.8]`: each actual count is a floor or
ceiling of its expectation (subject to floating-point precision). These copies
are correlated; SUS is not independent roulette sampling repeated ten times.
It controls allocation spread, without guaranteeing better optimization results.

Weights are evaluated once per candidate per batch. They must be finite and
nonnegative. They are divided by their largest value before summing to avoid
overflow. Zero-weight candidates receive no copies unless **every** weight is
zero; then SUS uses equal masses and equally spaced sampling over the population.
Very small relative weights can underflow to zero with floating-point arithmetic.
Count zero returns an immutable empty list without inspecting the population or
consuming randomness. Negative counts and positive counts with no population
are rejected. Results are immutable and follow population order.

## How the engine forms children

For `N` population slots and `E` elites, the engine requests `2 × (N − E)` parents
in one batch. It checks that the custom selector returns exactly that many,
copies and shuffles the batch with the run's random source, then allocates a pair
to each child. Shuffling removes population-order grouping while preserving
sampled multiplicities. The first parent is the starting child. The second is
used only when the crossover-rate trial succeeds; mutation follows its own trial.
An unused second parent is discarded rather than carried into the next pair.
Thus quotas apply to the **sampled pool**, not necessarily to used crossover
parents when crossover is below one. Elites are outside the sampling budget.

No batch is requested if the engine stops at generation zero. The engine retains
no parent pool between generations or runs. Custom selectors must also avoid
shared run state and must treat populations and genomes as read-only.

## Implement a custom batch selector

Implement `BatchSelection<T>` and return exactly `count` genomes. Use only the
provided `Random`; never create a separate random source. The population is
already ranked, so rank-based batch selection need not interpret raw fitness.
Return immutable genomes even though the engine defensively copies the list.
Test quotas or distribution, invalid inputs, seed repeatability and a complete
engine run through the public package import.

See [research references](references.md) for Baker's SUS publication and
[the eight queens example](../example/eight_queens.dart) for minimization with SUS.
