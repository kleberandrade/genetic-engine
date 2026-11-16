import 'dart:math';
import '../../contracts/mutation.dart';

/// Flips one bit. Does not mutate the input.
final class BitFlipMutation implements Mutation<List<bool>> {
  const BitFlipMutation();
  @override
  List<bool> mutate(List<bool> genome, Random random) {
    if (genome.isEmpty) throw ArgumentError('Genome cannot be empty');
    final result = genome.toList();
    final index = random.nextInt(result.length);
    result[index] = !result[index];
    return List.unmodifiable(result);
  }
}
