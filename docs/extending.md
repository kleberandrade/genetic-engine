# Extend the framework

Implement only the strategy you need. For an integer genome representing a cost,
this mutation moves a positive value one step toward zero:

```dart
import 'dart:math';
import 'package:genetic_engine/genetic_engine.dart';

final class DecrementMutation implements Mutation<int> {
  @override
  int mutate(int genome, Random random) => genome > 0 ? genome - 1 : 0;
}
```

Use it in the named `mutation` parameter of `GeneticAlgorithm<int>`. The runnable
[custom mutation example](../example/custom_mutation.dart) shows the full setup.
There is no registration step or engine modification.

For crossover, implement `Crossover<T>.cross(first, second, random)`. For selection,
implement `Selection<T>.select(ranked, random)`. The input is always ranked best
first, regardless of maximization or minimization; a custom selector should not
assume larger raw fitness is always better.

Use `CallbackGenomeFactory`, `CallbackFitnessEvaluator`, `CallbackSelection`,
`CallbackCrossover`, or `CallbackMutation` to adapt functions. For an entire
function-based configuration, use `GeneticAlgorithm<T>.withCallbacks` with
`create`, `fitness`, `select`, `crossover`, and `mutate`.

## Representation rules

- Do not mutate parent genomes or population lists. Return an immutable child.
- Use only the random source passed to your strategy for seeded reproducibility.
- Keep fitness deterministic and finite. Exceptions propagate to the caller.
- Repair invalid children inside your operator, or penalize them with a finite
  fitness score in the evaluator. Repair and penalty policies are domain choices.
- Keep callback state local to a run when sharing an engine between callers.

For example, a knapsack genome can be a boolean list. Its evaluator adds selected
item values and applies a finite penalty if the total weight exceeds capacity.
The engine does not know about weights, capacity or items.

## Tests for a new strategy

Check representation validity, unchanged inputs, boundary values and output
immutability. For a random operator, test invariants across many seeds rather
than demanding one incidental random sequence. Run it through the public engine
against a small problem with a known optimum or deterministic outcome.
