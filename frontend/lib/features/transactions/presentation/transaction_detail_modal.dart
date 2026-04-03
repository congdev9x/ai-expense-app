import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/transaction_provider.dart';
import 'transaction_edit_modal.dart';

class TransactionDetailModal extends ConsumerWidget {
  final Map<String, dynamic> transaction;

  const TransactionDetailModal({super.key, required this.transaction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isIncome = transaction['type'] == 'in';
    final amountStr = NumberFormat('#,###').format((transaction['amount'] as num).toDouble());
    final color = isIncome ? Colors.green : Colors.orange;
    final icon = isIncome ? Icons.payments : Icons.restaurant;
    final note = transaction['note'] ?? 'Không có ghi chú';
    final date = transaction['created_at'].toString().substring(0, 10);
    final categoryId = transaction['category_id'] ?? '-';

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Chi tiết Giao dịch',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
              const SizedBox(height: 16),
              
              // Icon and Amount
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 48),
              ),
              const SizedBox(height: 16),
              Text(
                (isIncome ? '+' : '-') + amountStr + ' ₫',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: isIncome ? Colors.green : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isIncome ? 'Thu nhập' : 'Chi tiêu',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),
              
              // Details
              _buildDetailRow(Icons.description_outlined, 'Ghi chú', note),
              const Divider(height: 24),
              _buildDetailRow(Icons.category_outlined, 'Danh mục', 'Danh mục $categoryId'),
              const Divider(height: 24),
              _buildDetailRow(Icons.calendar_today_outlined, 'Thời gian', date),
              
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                         Navigator.pop(context); // Đóng modal hiện tại
                         showModalBottomSheet(
                           context: context,
                           isScrollControlled: true,
                           backgroundColor: Colors.transparent,
                           builder: (context) => TransactionEditModal(transaction: transaction),
                         );
                      },
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      label: const Text('Sửa', style: TextStyle(color: Colors.blue)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.blue),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                         final confirm = await showDialog<bool>(
                           context: context,
                           builder: (context) => AlertDialog(
                             title: const Text('Xóa giao dịch?'),
                             content: const Text('Bạn có chắc chắn muốn xóa giao dịch này không? Hành động này không thể hoàn tác.'),
                             actions: [
                               TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy', style: TextStyle(color: Colors.grey))),
                               TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xóa', style: TextStyle(color: Colors.red))),
                             ],
                           ),
                         );
                         if (confirm == true) {
                            final success = await ref.read(transactionProvider.notifier).deleteTransaction(transaction['id']);
                            if (success && context.mounted) {
                               Navigator.pop(context);
                               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xóa giao dịch'), backgroundColor: Colors.red));
                            }
                         }
                      },
                      icon: const Icon(Icons.delete),
                      label: const Text('Xóa', style: TextStyle(fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[600], size: 24),
        const SizedBox(width: 16),
        Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 16)),
        const Spacer(),
        Text(
          value, 
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
          textAlign: TextAlign.right,
        ),
      ],
    );
  }
}
