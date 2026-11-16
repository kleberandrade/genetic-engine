import 'dart:math';
import '../../contracts/mutation.dart';

/// Swaps two distinct positions, preserving permutation validity.
final class SwapMutation<T> implements Mutation<List<T>> {
  const SwapMutation();
  @override
  List<T> mutate(List<T> genome, Random random) {
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
}
