import 'dart:math';
import '../../contracts/crossover.dart';
import 'validate_parents.dart';

/// Copies a segment of first and repairs conflicting second-parent genes by
/// following the segment mapping (PMX). Requires unique permutation genes.
final class PartiallyMappedCrossover<T> implements Crossover<List<T>> {
  const PartiallyMappedCrossover();
  @override
  List<T> cross(List<T> a, List<T> b, Random random) {
    validatePermutationParents(a, b);
    final start = random.nextInt(a.length);
    final end = start + 1 + random.nextInt(a.length - start);
    final mapping = {for (var i = start; i < end; i++) a[i]: i};
    final child = a.toList();
    for (var i = 0; i < a.length; i++) {
      if (i >= start && i < end) continue;
      var gene = b[i];
      while (mapping.containsKey(gene)) {
        gene = b[mapping[gene]!];
      }
      child[i] = gene;
    }
    return List.unmodifiable(child);
  }
}
