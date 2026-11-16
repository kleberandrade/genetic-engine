# Getting started

## Vocabulary

| Term | Meaning in this framework |
| --- | --- |
| Gene | One component of a solution, such as a boolean or numeric parameter |
| Genome | A whole solution, represented by your immutable type `T` |
| Candidate | A genome with its finite fitness score |
| Population | The candidates evaluated in one generation, ranked best first |
| Fitness | The numeric quality or cost returned by your evaluator |
| Selection | Choosing a parent from the ranked population |
| Crossover | Combining two parents into one child |
| Mutation | Changing a child to explore other possibilities |
| Elitism | Carrying top candidates into the next generation unchanged |
| Generation | One evaluated population; the initial population is generation zero |
| Stagnation | Consecutive generations without strict best-ever improvement |

## Model a problem in five steps

1. Choose a genome that can express valid solutions. A permutation is useful for
   ordering tasks; a real list is useful for tuning numeric parameters.
2. Implement a factory. Use its `Random` argument to generate varied solutions.
3. Define fitness. Use `Objective.minimize` for a cost, and maximize for a score.
   Negative scores are valid; NaN and infinities are rejected.
4. Choose compatible operators. A regular list crossover can duplicate elements,
   so use `OrderCrossover` and `SwapMutation` for permutations.
5. Configure limits and examine the result. Test multiple seeds before trusting
   performance on a real-world problem.

The [README example](../example/genetic_engine_example.dart) solves OneMax.
The [minimization example](../example/minimize.dart) minimizes x² + y² on [-5, 5].
Its known optimum is zero, which makes it useful to verify objective direction.

## Parameters

| Parameter | Default | Semantics |
| --- | --- | --- |
| `populationSize` | 100 | Candidates per generation; at least 2 |
| `maxGenerations` | 100 | Breeding steps; zero still evaluates the initial population |
| `elitism` | 1 | Unchanged survivors; from 0 to populationSize − 1 |
| `crossoverRate` | 0.8 | Probability of crossover per child |
| `mutationRate` | 0.1 | Probability of mutation per child, not per gene |
| `objective` | maximize | Ranking, target and improvement direction |
| `targetFitness` | null | Inclusive target checked against best-ever fitness |
| `stagnationLimit` | null | Positive number of generations without strict improvement |
| `seed` | null | Seed for a new random source on each run |

Crossover and mutation are independent events. A child can receive both, one,
or neither. Each reproduction produces one child. Tournament selection samples
with replacement and chooses the best-ranked sampled parent.

## Progress and results

```dart
final result = engine.run(
  onGeneration: (generation) {
    print('${generation.index}: ${generation.best.fitness}');
  },
  shouldStop: () => cancelled,
);
```

Here `engine` is your configured algorithm and `cancelled` is an application-owned
boolean. The callback runs for generation zero and each later generation.
`Generation.population` is an unmodifiable ranked list. Its genomes must also be
immutable. `meanFitness` reports the population mean.

`result.best` is the best candidate ever observed; with elitism disabled it can
differ from `result.lastGeneration.best`. History is not stored automatically;
collect statistics in `onGeneration` if needed.

Stop priority is target, cancellation, stagnation, then custom termination, then generation limit. A
cancellation callback cannot interrupt a fitness evaluation. A seeded run is
repeatable with deterministic callbacks using only the supplied random source
on the same Dart runtime; cross-runtime random sequences are not promised.
