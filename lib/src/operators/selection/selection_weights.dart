import 'dart:math';
import '../../domain/candidate.dart';

/// Validates each supplied weight once and scales before summing to avoid overflow.
/// Zero weights remain zero; the caller chooses the all-zero fallback.
List<double> selectionWeights<T>(
    List<Candidate<T>> ranked, double Function(Candidate<T>) weight) {
  if (ranked.isEmpty) throw ArgumentError('Population cannot be empty');
  final weights = ranked.map(weight).toList();
  if (weights.any((w) => !w.isFinite || w < 0)) {
    throw ArgumentError('Weights must be finite and nonnegative');
  }
  final scale = weights.reduce(max);
  return scale == 0 ? weights : weights.map((w) => w / scale).toList();
}
