void validateParents<T>(List<T> a, List<T> b) {
  if (a.isEmpty || a.length != b.length) {
    throw ArgumentError('Parents must have equal, nonzero lengths');
  }
}
