import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/history_provider.dart';
import '../presentation/transaction_filter_modal.dart';
import '../../transactions/presentation/transaction_detail_modal.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsState = ref.watch(filteredTransactionsProvider);
    final filter = ref.watch(historyFilterProvider);

    final bool hasFilter = filter.type != 'all' || filter.categoryIds.isNotEmpty || filter.startDate != null;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Lịch sử giao dịch', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: hasFilter ? Colors.blue : Colors.black87),
            onPressed: () => _showFilterModal(context),
          ),
        ],
      ),
      body: Column(
        children: [
          if (hasFilter) _buildActiveFilterBar(ref),
          Expanded(
            child: transactionsState.when(
              data: (transactions) {
                if (transactions.isEmpty) {
                  return const Center(child: Text('Không tìm thấy giao dịch nào khớp với bộ lọc'));
                }

                // Sắp xếp mới nhất lên đầu (đã sort ở provider gốc nhưng sort lại cho chắc)
                final sortedList = List<dynamic>.from(transactions);
                sortedList.sort((a, b) => (b['created_at'] ?? '').compareTo(a['created_at'] ?? ''));

                return ListView.builder(
                  itemCount: sortedList.length,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemBuilder: (context, index) {
                    final tx = sortedList[index];
                    final isIncome = tx['type'] == 'in';
                    final amountStr = NumberFormat('#,###').format((tx['amount'] as num).toDouble());
                    final color = isIncome ? Colors.green : Colors.orange;
                    
                    return ListTile(
                      onTap: () => _showTransactionDetailDialog(context, tx),
                      leading: CircleAvatar(
                        backgroundColor: color.withAlpha(30),
                        child: Icon(isIncome ? Icons.payments : Icons.restaurant, color: color),
                      ),
                      title: Text(tx['note'] ?? 'Giao dịch', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(tx['created_at'].toString().substring(0, 16)),
                      trailing: Text(
                        '${isIncome ? '+' : '-'}$amountStr ₫',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isIncome ? Colors.green : Colors.black87,
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => const Center(child: Text('Lỗi tải dữ liệu')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFilterBar(WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.blue.withAlpha(10),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 16, color: Colors.blue),
          const SizedBox(width: 8),
          const Expanded(child: Text('Đang áp dụng bộ lọc', style: TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.w500))),
          TextButton(
            onPressed: () => ref.read(historyFilterProvider.notifier).state = TransactionFilter(),
            child: const Text('Xóa lọc', style: TextStyle(fontSize: 12, color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showFilterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const TransactionFilterModal(),
    );
  }

  void _showTransactionDetailDialog(BuildContext context, Map<String, dynamic> tx) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TransactionDetailModal(transaction: tx),
    );
  }
}
