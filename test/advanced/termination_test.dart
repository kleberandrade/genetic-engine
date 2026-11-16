import 'package:genetic_engine/genetic_engine.dart';
import 'package:test/test.dart';

GeneticAlgorithm<int> engine(Termination termination, {int cap = 3}) =>
    GeneticAlgorithm.withCallbacks(
      create: (_) => 5,
      fitness: (g) => g.toDouble(),
      select: (ranked, _) => ranked.first.genome,
      crossover: (a, b, _) => a,
      mutate: (g, _) => g,
      termination: termination,
      maxGenerations: cap,
    );

void main() {
  test('generation cap still bounds an unmet composite', () {
    final result =
        engine(AndTermination([GenerationLimit(10), FitnessTarget(100)])).run();
    expect(result.lastGeneration.index, 3);
    expect(result.reason, StopReason.generationLimit);
  });
  test('zero time limit stops after initial evaluation', () {
    final result = engine(TimeLimit(Duration.zero)).run();
    expect(result.lastGeneration.index, 0);
    expect(result.reason, StopReason.customTermination);
  });
  test('stateless policy and engine can be reused without shared counters', () {
    final algorithm = engine(StagnationLimit(2));
    expect(algorithm.run().lastGeneration.index, 2);
    expect(algorithm.run().lastGeneration.index, 2);
  });
  test('fitness target follows minimization including negative fitness', () {
    final state = EvolutionState(
        generation: 0,
        bestFitness: -5,
        stagnantGenerations: 0,
        objective: Objective.minimize,
        elapsed: Duration.zero);
    expect(FitnessTarget(-4).isMet(state), isTrue);
    expect(FitnessTarget(-6).isMet(state), isFalse);
  });
  test('invalid and empty policy configurations are rejected', () {
    expect(() => GenerationLimit(-1), throwsArgumentError);
    expect(() => StagnationLimit(0), throwsArgumentError);
    expect(() => TimeLimit(Duration(seconds: -1)), throwsArgumentError);
    expect(() => FitnessTarget(double.nan), throwsArgumentError);
    expect(() => AndTermination([]), throwsArgumentError);
    expect(() => OrTermination([]), throwsArgumentError);
  });
  test('composite snapshots conditions rather than sharing mutable input', () {
    final conditions = <Termination>[GenerationLimit(0)];
    final both = AndTermination(conditions);
    final either = OrTermination(conditions);
    conditions.add(GenerationLimit(10));
    final state = EvolutionState(
        generation: 0,
        bestFitness: 0,
        stagnantGenerations: 0,
        objective: Objective.maximize,
        elapsed: Duration.zero);
    expect(both.isMet(state), isTrue);
    expect(either.isMet(state), isTrue);
    expect(() => both.conditions.clear(), throwsUnsupportedError);
  });
}
