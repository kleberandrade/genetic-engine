import 'package:test/test.dart';
import '../../example/task_scheduling.dart' as scheduling;
import '../../example/parameter_fitting.dart' as fitting;

void main() {
  test(
      'schedule assigns every job and reaches the independent load lower bound',
      () {
    final result = scheduling.solveSchedule();
    expect(result.best.genome.length, scheduling.durations.length);
    final loads = List.filled(scheduling.machineCount, 0);
    for (var i = 0; i < scheduling.durations.length; i++) {
      expect(result.best.genome[i],
          inInclusiveRange(0, scheduling.machineCount - 1));
      loads[result.best.genome[i]] += scheduling.durations[i];
    }
    final total = scheduling.durations.reduce((a, b) => a + b);
    final lowerBound = (total / scheduling.machineCount).ceil();
    expect(loads.reduce((a, b) => a > b ? a : b), lowerBound);
    expect(result.best.fitness, lowerBound.toDouble());
  });
  test('fitted line meets its error target on known observations', () {
    final result = fitting.fitLine();
    final coefficients = result.best.genome;
    var squaredError = 0.0;
    for (final x in [-2.0, -1.0, 0.0, 1.0, 2.0]) {
      final residual = coefficients[0] * x + coefficients[1] - (2 * x + 1);
      squaredError += residual * residual;
    }
    expect(squaredError / 5, lessThanOrEqualTo(0.01));
    expect(result.best.fitness, closeTo(squaredError / 5, 1e-12));
    expect(coefficients[0], closeTo(2, 0.1));
    expect(coefficients[1], closeTo(1, 0.1));
  });
}
