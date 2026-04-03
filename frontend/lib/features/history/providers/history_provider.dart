import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../transactions/providers/transaction_provider.dart';

class TransactionFilter {
  final String type; // 'all', 'in', 'out'
  final List<int> categoryIds;
  final DateTime? startDate;
  final DateTime? endDate;

  TransactionFilter({
    this.type = 'all',
    this.categoryIds = const [],
    this.startDate,
    this.endDate,
  });

  TransactionFilter copyWith({
    String? type,
    List<int>? categoryIds,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return TransactionFilter(
      type: type ?? this.type,
      categoryIds: categoryIds ?? this.categoryIds,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}

final historyFilterProvider = StateProvider<TransactionFilter>((ref) {
  return TransactionFilter();
});

final filteredTransactionsProvider = Provider<AsyncValue<List<dynamic>>>((ref) {
  final transactionsState = ref.watch(transactionProvider);
  final filter = ref.watch(historyFilterProvider);

  return transactionsState.whenData((transactions) {
    return transactions.where((tx) {
      // Lọc theo Type
      if (filter.type != 'all' && tx['type'] != filter.type) {
        return false;
      }

      // Lọc theo Category
      if (filter.categoryIds.isNotEmpty && !filter.categoryIds.contains(tx['category_id'])) {
        return false;
      }

      // Lọc theo Date
      final txDate = DateTime.parse(tx['created_at'].toString());
      if (filter.startDate != null && txDate.isBefore(filter.startDate!)) {
        return false;
      }
      if (filter.endDate != null && txDate.isAfter(filter.endDate!.add(const Duration(days: 1)))) {
        return false;
      }

      return true;
    }).toList();
  });
});
