import 'dart:math';
import '../contracts/mutation.dart';

/// Adapts a function to [Mutation].
final class CallbackMutation<T> implements Mutation<T> {
  final T Function(T genome, Random random) callback;
  const CallbackMutation(this.callback);
  @override
  T mutate(T genome, Random random) => callback(genome, random);
}
