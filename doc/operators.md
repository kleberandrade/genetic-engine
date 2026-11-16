# Operator catalogue

## Survival and parent selection are different

`elitism: 2` keeps two top candidates unchanged. Alternatively, pass
`elitePolicy: FractionalElitism(0.1)` to keep floor(10% of the population).
An explicit policy overrides the legacy integer; `effectiveElitism` reports the
resolved count. Policies implement `Elitism` and are resolved at construction.
At least one offspring slot must remain. Elites are not re-evaluated.

`EliteSelection` merely chooses the top parent for reproduction; crossover and
mutation may still change its child. It does not itself preserve a survivor.

| Parent selector | Distribution | Objective handling |
| --- | --- | --- |
| Tournament | Best of sampled ranks, with replacement | Best-first population |
| Elite | Always best | Best-first population |
| Truncation | Uniform among ceil(fraction × n) top candidates | Best-first population |
| Rank | Descending weights n through 1 | Best-first population |
| SUS (batch) | Equally spaced pointers with one random offset | Caller supplies the weight transform |
| Roulette | Proportional to supplied finite, nonnegative weights | Caller supplies the weight transform |

For nonnegative maximization scores use
`RouletteWheelSelection<MyGenome>(weight: (c) => c.fitness)`. For a nonnegative
minimization cost, one possible transform is `1 / (1 + c.fitness)`. These are
examples, not universal transforms for arbitrary scores. Rank selection avoids
fitness scaling altogether. Roulette normalizes by its largest weight to avoid
sum overflow; all-zero weights fall back to uniform sampling.

SUS implements `BatchSelection`, configured via `batchSelection:` rather than
`selection:`. See [batch sampling and pairing](selection.md) for its complete
contract, quotas and differences from roulette.

## Crossover and mutation

| Operator | Representation | Result |
| --- | --- | --- |
| Single point, uniform, two point | Fixed-length lists | One immutable child; duplicates allowed |
| Order, cycle (CX), partially mapped (PMX) | Unique permutations with equal gene sets | One immutable permutation |
| Bit flip | Binary list | One flipped position |
| Real reset | Real list | One new bounded value |
| Swap | Any nonempty list | Two distinct positions exchanged |
| Insertion | Any nonempty list | One gene moved to another final index |
| Reverse sequence | Any nonempty list | Segment reversal |
| Partial shuffle | Any nonempty list | Segment shuffled; may remain unchanged |

Single-element mutations return an unchanged copy when no move is possible,
except bit flip and real reset. Empty genomes are rejected. See
[algorithm references and exact variants](references.md) before comparing results
with another library. The supplied random source must be used by custom operators.

## Composable termination

```dart
termination: OrTermination([
  StagnationLimit(40),
  TimeLimit(Duration(seconds: 2)),
]),
maxGenerations: 500,
```

Built-ins are `GenerationLimit`, `FitnessTarget`, `StagnationLimit`, `TimeLimit`,
`AndTermination` and `OrTermination`. Implement `Termination.isMet(EvolutionState)`
for custom conditions. State contains generation index, best-ever fitness,
stagnation count, objective and elapsed time, including initial evaluation.
Conditions must be stateless so repeated runs remain independent. Empty AND/OR
lists are rejected. Conditions are copied into an unmodifiable list.

Legacy target, cancellation and stagnation checks retain precedence; then custom
termination is checked; the hard generation limit always remains active. Leave
legacy target/stagnation options unset when those conditions should participate
only inside an AND expression. A custom condition stops with
`StopReason.customTermination`. Time and cancellation are cooperative and cannot
interrupt a fitness call.

## Deliberate scope

This release provides a curated operator set, not feature parity with GeneticSharp.
SUS uses an explicit batch-parent contract. Variable-length chromosomes,
three-parent crossover, parallel fitness execution, multi-objective optimization
and island models remain future work. Isolate integration stays application-owned.
