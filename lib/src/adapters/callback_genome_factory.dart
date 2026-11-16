import 'dart:math';
import '../contracts/genome_factory.dart';

/// Adapts a function to [GenomeFactory].
final class CallbackGenomeFactory<T> implements GenomeFactory<T> {
  final T Function(Random random) callback;
  const CallbackGenomeFactory(this.callback);
  @override
  T create(Random random) => callback(random);
}
