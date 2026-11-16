import 'dart:math';
import '../../contracts/mutation.dart';

/// Shuffles a random segment of at least two genes; it may remain unchanged.
final class PartialShuffleMutation<T> implements Mutation<List<T>> {
  const PartialShuffleMutation();
  @override
  List<T> mutate(List<T> genome, Random random) {
    if (genome.isEmpty) throw ArgumentError('Genome cannot be empty');
    final result = genome.toList();
    if (result.length < 2) return List.unmodifiable(result);
    final start = random.nextInt(result.length - 1);
    final end = start + 2 + random.nextInt(result.length - start - 1);
    final segment = result.sublist(start, end)..shuffle(random);
    result.replaceRange(start, end, segment);
    return List.unmodifiable(result);
  }
}
