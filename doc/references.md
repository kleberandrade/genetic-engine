# Algorithm references and implementation provenance

The implementations in this package are original Dart code. Papers below support
the algorithm concepts; they do not endorse this package or prove its performance.

## Sources

**[R1] Darrell Whitley (1994). A Genetic Algorithm Tutorial.** Statistics and
Computing 4, 65–85. [Author's university-hosted manuscript](https://www.cs.colostate.edu/~cs540/spr2019/more_assignments/WhitleyTutorial.pdf).
Background for generational evolution, fitness-proportionate selection, ranking
and tournament selection. This package keeps objective evaluation separate from
roulette weights, so a cost or negative score needs an explicit weight transform.

**[R2] P. Larrañaga, C. M. H. Kuijpers, R. H. Murga, I. Inza and S. Dizdarevic
(1999). Genetic Algorithms for the Travelling Salesman Problem: A Review of
Representations and Operators.** Artificial Intelligence Review 13, 129–170.
[DOI](https://doi.org/10.1023/A:1006529012972),
[university-hosted paper](https://cig.fi.upm.es/wp-content/uploads/2024/01/Genetic-algorithms-for-the-travelling-salesman-problem-A-review-of-representations-and-operators.pdf).
Relevant sections: 4.3.1 PMX, 4.3.2 CX, 4.3.14 insertion, 4.3.15 simple inversion,
and 4.3.17 scramble mutation. Our reverse-sequence mutation is simple inversion,
not the variant that also relocates the reversed segment.

**[R3] D. Whitley (1989). The GENITOR Algorithm and Selection Pressure: Why
Rank-Based Allocation of Reproductive Trials is Best.** Proceedings of the Third
International Conference on Genetic Algorithms, 116–121.
[Author's publication list](https://www.cs.colostate.edu/~whitley/research/publications.php).
Conceptual context for rank-based selection. `RankSelection` uses the explicitly
documented descending weights n through 1, rather than claiming to reproduce
GENITOR's full steady-state replacement algorithm.

**[R4] GeneticSharp — giacomelli/GeneticSharp.**
[Repository and feature catalogue](https://github.com/giacomelli/GeneticSharp).
Architectural inspiration for pluggable operators and composable terminations.
Its README feature and sample catalogues inspired organization and problem
families; no implementation code was copied.

**[R5] James Edward Baker (1987). Reducing Bias and Inefficiency in the Selection
Algorithm.** Proceedings of the Second International Conference on Genetic
Algorithms, 14–21. [Proceedings scan](https://gpbib.cs.ucl.ac.uk/icga/icga1987-ocr.pdf).
SUS uses a single random start and equally spaced pointers to allocate a batch.
This package adds explicit weight validation, equal-mass fallback for all-zero
weights and an engine-owned shuffle before pairing. These are documented package
policies, not a claim of reproducing an entire historical GA configuration.

## Traceability

| Implemented area | Basis | Package-specific decision |
| --- | --- | --- |
| Roulette and tournament selection | R1 | Explicit roulette weights; zero-weight uniform fallback |
| Linear rank selection | R1, R3 | Best-first weights n, n−1, …, 1 |
| SUS | R5 | Batch contract; explicit weights; shuffled parent pairing |
| Learning examples | R4 sample catalogue | Original Dart eight queens, password, TSP and numerical problems; additional knapsack lesson |
| PMX and CX | R2 | One offspring; CX alternates cycles deterministically |
| Insertion, reverse and shuffle | R2 | Immutable lists and validated boundaries |
| Strategy interfaces, AND/OR stopping | R4 | Dart composition and stateless per-run observations |
| Fixed/fractional elites | Generational survival policy | Top survivors unchanged; fraction rounds down |

For interval-based operators, the start is sampled first and the end is sampled
from the remaining suffix. This is an explicitly chosen cut distribution; it is
not uniform sampling over all unordered pairs of boundaries. The existing
`OrderCrossover` fills unselected positions in linear second-parent order; it is
not presented as an exact circular OX1 implementation.

Operator semantics are pinned by deterministic cut tests and permutation
invariants in `test/advanced/`. These tests establish behavior, not comparative
benchmark performance. No claim of algorithm superiority is made.
