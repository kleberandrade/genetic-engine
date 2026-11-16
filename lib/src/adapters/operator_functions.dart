import 'dart:math';
import '../domain/candidate.dart';
import '../operators/selection/tournament_selection.dart';
import '../operators/crossover/single_point_crossover.dart';
import '../operators/crossover/uniform_crossover.dart';
import '../operators/crossover/order_crossover.dart';
import '../operators/mutation/bit_flip_mutation.dart';
import '../operators/mutation/swap_mutation.dart';
import '../operators/mutation/real_reset_mutation.dart';

/// Function form of [TournamentSelection].
T Function(List<Candidate<T>>, Random) tournamentSelection<T>({int size = 3}) =>
    TournamentSelection<T>(size: size).select;

/// Function form of [SinglePointCrossover].
List<T> singlePointCrossover<T>(List<T> a, List<T> b, Random r) =>
    SinglePointCrossover<T>().cross(a, b, r);

/// Function form of [UniformCrossover].
List<T> uniformCrossover<T>(List<T> a, List<T> b, Random r) =>
    UniformCrossover<T>().cross(a, b, r);

/// Function form of [OrderCrossover].
List<T> orderCrossover<T>(List<T> a, List<T> b, Random r) =>
    OrderCrossover<T>().cross(a, b, r);

/// Function form of [BitFlipMutation].
List<bool> bitFlipMutation(List<bool> g, Random r) =>
    const BitFlipMutation().mutate(g, r);

/// Function form of [SwapMutation].
List<T> swapMutation<T>(List<T> g, Random r) => SwapMutation<T>().mutate(g, r);

/// Function form of [RealResetMutation].
List<double> Function(List<double>, Random) realResetMutation(
        {required double min, required double max}) =>
    RealResetMutation(min: min, max: max).mutate;
