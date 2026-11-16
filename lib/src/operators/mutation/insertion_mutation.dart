import 'dart:math';
import '../../contracts/mutation.dart';

/// Moves one gene to a different final index; preserves permutations.
final class InsertionMutation<T> implements Mutation<List<T>> {
  const InsertionMutation();
  @override
  List<T> mutate(List<T> genome, Random random) {
    if (genome.isEmpty) throw ArgumentError('Genome cannot be empty');
    final result = genome.toList();
    if (result.length < 2) return List.unmodifiable(result);
    final from = random.nextInt(result.length);
    var to = random.nextInt(result.length - 1);
    if (to >= from) to++;
    final gene = result.removeAt(from);
    result.insert(to, gene);
    return List.unmodifiable(result);
  }
}
