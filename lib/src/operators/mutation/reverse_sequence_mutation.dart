import 'dart:math';
import '../../contracts/mutation.dart';

/// Reverses a random segment of at least two genes; preserves permutations.
final class ReverseSequenceMutation<T> implements Mutation<List<T>> {
  const ReverseSequenceMutation();
  @override
  List<T> mutate(List<T> genome, Random random) {
    if (genome.isEmpty) throw ArgumentError('Genome cannot be empty');
    final result = genome.toList();
    if (result.length < 2) return List.unmodifiable(result);
    final start = random.nextInt(result.length - 1);
    final end = start + 2 + random.nextInt(result.length - start - 1);
    result.replaceRange(start, end, result.sublist(start, end).reversed);
    return List.unmodifiable(result);
  }
}
