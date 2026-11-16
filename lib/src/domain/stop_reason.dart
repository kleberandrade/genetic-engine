/// Why evolution finished. See GeneticAlgorithm for stopping priority.
enum StopReason {
  targetFitness,
  cancelled,
  stagnation,
  generationLimit,
  customTermination
}
