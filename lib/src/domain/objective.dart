/// Direction used consistently for ranking, targets, and improvement.
enum Objective {
  maximize,
  minimize;

  /// Whether [a] strictly improves upon [b].
  bool isBetter(double a, double b) =>
      this == Objective.maximize ? a > b : a < b;
}
