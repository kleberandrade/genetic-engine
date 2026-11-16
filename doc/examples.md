# Learn by solving small problems

Run these from the repository root after `dart pub get`. The examples are pure
Dart and can supply the optimization logic for Flutter or a Dart service. UI,
transport and isolate ownership stay in the application; see [integration](integration.md).
The SUS examples require the 0.4 source revision until that version is published.

| Problem and command (`dart run example/…`) | Genome | Objective | Main lesson |
| --- | --- | --- | --- |
| [OneMax](../example/genetic_engine_example.dart): `genetic_engine_example.dart` | 32 booleans | Maximize true bits | First complete evolution loop |
| [Sphere](../example/minimize.dart): `minimize.dart` | Bounded real coordinates | Minimize x² + y² | Objective direction and tolerance |
| [Custom mutation](../example/custom_mutation.dart): `custom_mutation.dart` | Integer | Minimize a cost | Implement a small strategy interface |
| [Travelling salesman](../example/travelling_salesman.dart): `travelling_salesman.dart` | Permutation of eight cities | Minimize closed-tour distance | PMX, reversal and fractional elitism |
| [Eight queens](../example/eight_queens.dart): `eight_queens.dart` | Permutation of rows by column | Minimize diagonal conflicts | Encode structural constraints and use SUS |
| [Password](../example/password.dart): `password.dart` | Seven bounded letter indices | Maximize matching positions | Custom alphabet mutation and SUS |
| [Knapsack](../example/knapsack.dart): `knapsack.dart` | One boolean per item | Maximize feasible value | Finite penalties and feasibility checks |

## Eight queens: prevent some invalid states by representation

An entry at column `c` records the queen's row. A permutation guarantees one queen
per column and one per row before evaluation. Only diagonals can conflict: two
columns attack when their row difference equals their column difference.
`PartiallyMappedCrossover` and `SwapMutation` preserve the permutation. An ordinary
single-point crossover could duplicate rows and break that guarantee.

Fitness is the number of attacking diagonal pairs; zero is the known target.
The objective is minimization, but SUS still requires larger **weights** for
preferred parents: `1 / (1 + conflicts)` supplies this ordering. The seed-42
example is checked for a genuine valid board, not merely a reported fitness.

## Password: define every gene's domain

The deliberately known teaching target is `GENETIC`. Each gene is an index into
`ABCDEFGHIJKLMNOPQRSTUVWXYZ`. The evaluator counts matching positions;
`UniformCrossover` recombines letters and `LetterMutation` draws a bounded letter.
SUS weights are `matches + 1`, so even zero-match candidates can be sampled.
The integer representation does not itself constrain arbitrary custom operators:
the factory and mutation must honor the alphabet bounds.

This is a toy string-matching optimization exercise, not a password recovery tool.
Changing alphabet, text length or selection pressure changes convergence.

## Knapsack: constraints belong to the problem

Six items have independent weights and values. A boolean gene includes or excludes
one item; a bag has capacity ten. The evaluator gives overweight bags fitness −1,
otherwise their total value. Since every value in this fixture is positive, this
penalty puts infeasible bags below all feasible ones. Tournament selection works
directly with this negative score. Passing it unmodified as a SUS weight would
be invalid. Another problem might need repair, a stronger penalty, or a different
representation; do not reuse −1 without checking the objective's range.

The example prints both weight and value, so feasibility remains visible. Its
test enumerates all 64 bags to establish an independent optimum for this tiny
instance. Exhaustive enumeration is a test oracle here, not part of the GA loop.

## Inspiration and verification limits

GeneticSharp's [sample catalogue](https://github.com/giacomelli/GeneticSharp#samples)
includes eight queens, password, TSP and numerical optimization. Those problem
families inspired this learning path. The Dart implementations, fixtures and tests
are original; no GeneticSharp implementation code was copied. Knapsack adds an
explicit constraint-handling lesson. This is a curated set, not feature parity.

The new example tests verify seed 42: zero diagonal conflicts, exact target text,
and a feasible optimal small knapsack. Seeded reproducibility applies to the same
SDK, strategy configuration and fitness behavior. A different seed or larger
instance can stop at its generation cap without reaching an optimum. Always check
`result.reason`, independently verify feasibility, and distinguish best-ever
fitness from a guarantee of global optimality.
