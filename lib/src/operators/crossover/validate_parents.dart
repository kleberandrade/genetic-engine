void validateParents<T>(List<T> a, List<T> b) {
  if (a.isEmpty || a.length != b.length) {
    throw ArgumentError('Parents must have equal, nonzero lengths');
  }
}

void validatePermutationParents<T>(List<T> a, List<T> b) {
  validateParents(a, b);
  final genes = a.toSet();
  if (genes.length != a.length ||
      b.toSet().length != b.length ||
      !genes.containsAll(b)) {
    throw ArgumentError(
        'Parents must be permutations of the same unique genes');
  }
}
