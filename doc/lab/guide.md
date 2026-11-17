# Evolution Lab: scenarios and controls

![Conceptual cover: binary candidates converge toward a complete individual](cover.svg)

This original conceptual illustration is not an application screenshot. Real
captures and validation scope are recorded in [validation](validation.md).

## Run a reproducible experiment

The **Language / Idioma** selector switches between English and Brazilian
Portuguese without restarting the search. It also translates chart labels,
validation errors, screen-reader descriptions and built-in Material controls.
A paused run remains paused, a running run keeps running, and configuration,
seed, population and history are retained. Reloading the page starts in English.

Choose a scenario, population (40, 100 or 200), parent selection, operator pair,
probabilities and seed. Configuration changes restart the experiment. Enter a
seed from 0 to 2147483647 and press **Restart** to apply it. Defaults use seed 42,
100 individuals, tournament selection, 80% crossover and 30% mutation.

Generation zero is evaluated immediately. **Step** computes one further generation;
**Run** advances at most one generation every 70 ms. **Pause** retains the iterator,
population, random sequence and history; **Resume** continues it. **Cancel** discards
the iterator and stops pending work while retaining the displayed results.
**Restart** cancels the timer, clears history and reproduces generation zero using
the current seed and controls. Controls are locked during running/paused states;
restart to unlock them. An invalid seed reports an error without replacing the run.

## OneMax

A genome has 32 binary genes. Teal cells contain 1 and pale cells contain 0; the
textual genome conveys the same information without color. Fitness is **32 minus
the number of ones**, so zero is the optimum. This is the minimization form of
OneMax. Compare single-point and uniform crossover; both use one-bit flip mutation.
Mutation probability is per child, not per gene.

## Eight queens

Each genome is a permutation of rows 0–7, one queen per column. Rows and columns
are unique by construction; fitness counts attacking diagonal pairs. Zero is a
valid solution. The board and textual row sequence show the best current candidate.
Compare PMX plus swap against order crossover plus reverse-sequence mutation.
Permutations remain valid; arbitrary binary crossover would violate this model.

## Travelling salesman

Eight fixed cities use normalized coordinates, no map service or location data.
City labels 0–7 match the genome. The last city connects to the first. Fitness is
the sum of Euclidean distances around this closed tour. Reversal/rotation can
encode the same route. Compare PMX/swap and order/reverse without duplicating cities.
There is no optimum target configured: execution stops at generation 300.

## Read the results

Lower fitness is better in every scenario. **Best** is the best individual in the
ranked population; one unchanged elite makes it also best so far. **Mean** includes
all candidates. The history shows solid teal best and dashed amber mean with
numeric axes. Ranked population shows the top eight scores and an expandable
list of every individual's fitness and genome. The legend, textual genomes,
labels, keyboard controls and semantic chart descriptions complement the drawings.

Tournament uses the package defaults; rank selection uses rank weights; stochastic
universal sampling (SUS) uses positive weights `1 / (1 + fitness)`. These teaching
choices are not interchangeable performance claims. The engine's crossover and
mutation rates operate independently. An unchanged elite is not mutated.

## Limits and runtime boundaries

The lab keeps at most 301 generations and 200 individuals per generation. Each
`moveNext()` is synchronous CPU work. The browser receives control between bounded
generations, but this is not a web worker or a guarantee for arbitrary expensive
fitness functions. Large/custom problems belong in an external worker. Native
isolate/compute behavior is covered elsewhere, not by this lab's widget tests.

Search may stagnate or hit its limit. A good seed does not prove optimality. Seed
replay is verified on this toolchain; random sequences are not promised identical
across SDK/platform versions. Pause excludes further computations, but generic
core time-based termination includes paused wall time. The lab uses generation
and fitness limits only. No persistence, network API, telemetry, or pub.dev
publication is part of this application.

## References and credits

- [Public package source](../../lib/genetic_engine.dart), MIT © Kleber Andrade.
- [Selection semantics](../selection.md) and [operator guide](../operators.md).
- [Dart Iterable API](https://api.dart.dev/dart-core/Iterable-class.html).
- [Flutter web deployment](https://docs.flutter.dev/deployment/web) and
  [base URL configuration](https://docs.flutter.dev/ui/navigation/url-strategies).
- Flutter and Material dependencies retain their upstream licenses; the web build
  includes dependency notices. The lab drawings and captures were made for this repo.

## Five practical exercises

1. **Replay a seed.** Step OneMax ten times, record best/mean, restart with the same
   controls and repeat. Complete when all eleven observations, including generation
   zero, match.
2. **Measure mutation's effect.** Compare rates 0 and 0.8 over five seeds with all
   other controls fixed. Complete with a record of final fitness and generation
   count for all ten runs, without claiming a universal winner.
3. **Validate queens.** Reach fitness zero and reconstruct the board from the row
   sequence. Complete when every row/column is unique and no diagonal pair attacks.
4. **Check a closed tour.** Copy a salesman genome and sum all eight edge distances,
   including the return edge, using the coordinates in `lab_model.dart`. Complete
   when the result matches the displayed fitness to three decimals.
5. **Verify lifecycle controls.** Run, pause, wait, resume, cancel and restart.
   Complete when pause/cancel freeze generation count, resume advances it, and
   restart reproduces generation zero for the same controls and seed.
