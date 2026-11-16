import 'dart:math';
import '../../contracts/mutation.dart';

/// Replaces one real gene in [min, max), or exactly min for equal bounds.
final class RealResetMutation implements Mutation<List<double>> {
  final double min;
  final double max;
  RealResetMutation({required this.min, required this.max}) {
    if (!min.isFinite || !max.isFinite || min > max || !(max - min).isFinite) {
      throw ArgumentError('Bounds must be finite and ordered');
    }
  }
  @override
  List<double> mutate(List<double> genome, Random random) {
    if (genome.isEmpty) throw ArgumentError('Genome cannot be empty');
    final result = genome.toList();
    result[random.nextInt(result.length)] =
        min + random.nextDouble() * (max - min);
    return List.unmodifiable(result);
  }
}
