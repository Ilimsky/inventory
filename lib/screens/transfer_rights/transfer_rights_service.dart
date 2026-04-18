import 'package:flutter/foundation.dart';
import '../../models/Sked.dart';
import '../../models/Employee.dart';
import '../../services/api_service.dart';
import 'transfer_reason.dart';
import 'transfer_result.dart';

class TransferRightsService {
  final ApiService apiService;

  TransferRightsService(this.apiService);

  Future<List<Sked>> fetchActiveSkeds(int fromEmployeeId) async {
    try {
      final allSkeds = await apiService.fetchAllSkeds();
      return allSkeds
          .where((s) =>
      s.employeeId == fromEmployeeId &&
          !s.isWrittenOff &&
          !s.numberReleased)
          .toList();
    } catch (e) {
      debugPrint('[TransferRightsService] fetchActiveSkeds error: $e');
      rethrow;
    }
  }

  Future<TransferResult> transferAll({
    required Employee fromEmployee,
    required Employee toEmployee,
    required List<Sked> skeds,
    required TransferReason reason,
    String? additionalComment,
    void Function(int completed, int total)? onProgress,
    void Function(int skedId)? onSuccess,
  }) async {
    int successCount = 0;
    final List<String> errors = [];
    final total = skeds.length;

    for (int i = 0; i < skeds.length; i++) {
      final sked = skeds[i];
      var comment = '';

      try {
        comment = _buildComment(
          originalComment: sked.comments,
          fromEmployee: fromEmployee,
          toEmployee: toEmployee,
          reason: reason,
          additionalComment: additionalComment,
        );

        await apiService.updateSked(
          sked.id,
          skedNumber: sked.skedNumber,
          departmentId: sked.departmentId,
          employeeId: toEmployee.id,
          assetCategory: sked.assetCategory,
          dateReceived: sked.dateReceived,
          itemName: sked.itemName,
          serialNumber: sked.serialNumber,
          count: sked.count,
          measure: sked.measure,
          price: sked.price,
          place: sked.place,
          comments: comment,
          available: sked.available,
        );

        onSuccess?.call(sked.id);
        successCount++;
      } on TypeError catch (e) {
        debugPrint('[TransferRightsService] sked ${sked.id}: response parse skipped ($e)');
        onSuccess?.call(sked.id);
        successCount++;
      } catch (e) {
        errors.add('${sked.itemName} (ID: ${sked.id}): $e');
        debugPrint('[TransferRightsService] Failed to transfer sked ${sked.id}: $e');
      }

      onProgress?.call(i + 1, total);
    }

    return TransferResult(
      totalSkeds: total,
      successCount: successCount,
      failedCount: errors.length,
      errors: errors,
    );
  }

  String _buildComment({
    required String originalComment,
    required Employee fromEmployee,
    required Employee toEmployee,
    required TransferReason reason,
    String? additionalComment,
  }) {
    final date = _formatDate(DateTime.now());
    final parts = [
      '${reason.commentPrefix}.',
      'От: ${fromEmployee.name}.',
      'Кому: ${toEmployee.name}.',
      'Дата: $date.',
      if (additionalComment != null && additionalComment.trim().isNotEmpty)
        additionalComment.trim(),
      // if (originalComment.isNotEmpty) originalComment,
    ];
    return parts.join(' ');
  }

  String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}.'
          '${dt.month.toString().padLeft(2, '0')}.'
          '${dt.year}';
}