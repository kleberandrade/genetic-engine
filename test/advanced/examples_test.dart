import 'package:test/test.dart';
import '../../example/eight_queens.dart' as queens;
import '../../example/password.dart' as password;
import '../../example/knapsack.dart' as knapsack;

void main() {
  test('eight queens finds a valid board with the documented seed', () {
    final solution = queens.solveEightQueens().best.genome;
    expect(solution.toSet(), {0, 1, 2, 3, 4, 5, 6, 7});
    expect(queens.diagonalConflicts(solution), 0);
  });
  test('password converges to the known teaching target', () {
    final solution = password.solvePassword().best.genome;
    expect(solution.map((i) => password.alphabet[i]).join(), password.target);
  });
  test(
      'knapsack is feasible and matches an exhaustive oracle on the tiny instance',
      () {
    var optimum = 0;
    for (var mask = 0; mask < 1 << knapsack.items.length; mask++) {
      final bag = knapsack.totals(
          List.generate(knapsack.items.length, (i) => (mask & (1 << i)) != 0));
      if (bag.weight <= knapsack.capacity && bag.value > optimum) {
        optimum = bag.value;
      }
    }
    final bag = knapsack.totals(knapsack.solveKnapsack().best.genome);
    expect(bag.weight, lessThanOrEqualTo(knapsack.capacity));
    expect(bag.value, optimum);
  });
}
