class TransferResult {
  final int totalSkeds;
  final int successCount;
  final int failedCount;
  final List<String> errors;

  TransferResult({
    required this.totalSkeds,
    required this.successCount,
    required this.failedCount,
    required this.errors,
  });

  bool get isFullSuccess => failedCount == 0;
  bool get isPartialSuccess => successCount > 0 && failedCount > 0;
  bool get isFullFailure => successCount == 0 && failedCount > 0;
}
