import 'dart:math';
import '../domain/candidate.dart';
import '../contracts/selection.dart';

/// Adapts a function to [Selection].
final class CallbackSelection<T> implements Selection<T> {
  final T Function(List<Candidate<T>> ranked, Random random) callback;
  const CallbackSelection(this.callback);
  @override
  T select(List<Candidate<T>> ranked, Random random) =>
      callback(ranked, random);
}
