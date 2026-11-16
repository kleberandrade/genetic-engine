import 'dart:math';
import 'engine.dart';

/// Tournament selection consumes a population ranked best first. Works for
/// either objective, negative fitness, and ties.
Selection<T> tournamentSelection<T>({int size = 3}) {
  if (size < 1) throw ArgumentError.value(size, 'size');
  return (ranked, random) {
    if (ranked.isEmpty) throw ArgumentError('Population cannot be empty');
    var winner = random.nextInt(ranked.length);
    for (var i = 1; i < size; i++) {
      winner = min(winner, random.nextInt(ranked.length));
    }
    return ranked[winner].genome;
  };
}

void _checkParents<T>(List<T> a, List<T> b) {
  if (a.isEmpty || a.length != b.length) {
    throw ArgumentError('Parents must have equal, nonzero lengths');
  }
}

/// One-point crossover for fixed-length binary, integer, or real genomes.
List<T> singlePointCrossover<T>(List<T> a, List<T> b, Random random) {
  _checkParents(a, b);
  final point = a.length == 1 ? 1 : 1 + random.nextInt(a.length - 1);
  return List.unmodifiable([...a.take(point), ...b.skip(point)]);
}

/// Chooses each gene independently from either parent.
List<T> uniformCrossover<T>(List<T> a, List<T> b, Random random) {
  _checkParents(a, b);
  return List.unmodifiable(
      List.generate(a.length, (i) => random.nextBool() ? a[i] : b[i]));
}

/// Permutation-safe order crossover. Parents must contain the same unique genes.
List<T> orderCrossover<T>(List<T> a, List<T> b, Random random) {
  _checkParents(a, b);
  final genes = a.toSet();
  if (genes.length != a.length ||
      b.toSet().length != b.length ||
      !genes.containsAll(b)) {
    throw ArgumentError(
        'Parents must be permutations of the same unique genes');
  }
  final start = random.nextInt(a.length);
  final end = start + 1 + random.nextInt(a.length - start);
  final segment = a.sublist(start, end);
  final remaining = b.where((gene) => !segment.contains(gene)).iterator;
  return List.unmodifiable(List.generate(a.length, (i) {
    if (i >= start && i < end) return a[i];
    remaining.moveNext();
    return remaining.current;
  }));
}

/// Flips one bit. Does not mutate the input.
List<bool> bitFlipMutation(List<bool> genome, Random random) {
  if (genome.isEmpty) throw ArgumentError('Genome cannot be empty');
  final result = genome.toList();
  final index = random.nextInt(result.length);
  result[index] = !result[index];
  return List.unmodifiable(result);
}

/// Swaps two distinct positions, preserving permutation validity.
List<T> swapMutation<T>(List<T> genome, Random random) {
  if (genome.isEmpty) throw ArgumentError('Genome cannot be empty');
  final result = genome.toList();
  if (result.length > 1) {
    final a = random.nextInt(result.length);
    var b = random.nextInt(result.length - 1);
    if (b >= a) b++;
    final value = result[a];
    result[a] = result[b];
    result[b] = value;
  }
  return List.unmodifiable(result);
}

/// Resets one real-valued gene within inclusive configured bounds.
Mutation<List<double>> realResetMutation(
    {required double min, required double max}) {
  if (!min.isFinite || !max.isFinite || min > max || !(max - min).isFinite) {
    throw ArgumentError('Bounds must be finite and ordered');
  }
  return (genome, random) {
    if (genome.isEmpty) throw ArgumentError('Genome cannot be empty');
    final result = genome.toList();
    result[random.nextInt(result.length)] =
        min + random.nextDouble() * (max - min);
    return List.unmodifiable(result);
  };
}
