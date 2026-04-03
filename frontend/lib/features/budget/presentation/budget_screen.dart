import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../../categories/providers/category_provider.dart';
import '../providers/budget_provider.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsState = ref.watch(transactionProvider);
    final budgetsState = ref.watch(budgetProvider);
    final categoriesState = ref.watch(categoryProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Quản lý ngân sách', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
              // TODO: Mở Form thêm Ngân sách
            },
          ),
        ],
      ),
      body: budgetsState.when(
        data: (budgets) {
          return transactionsState.when(
            data: (transactions) {
              return categoriesState.when(
                data: (categories) => _buildBody(context, budgets, transactions, categories),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => const Center(child: Text('Lỗi tải danh mục')),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => const Center(child: Text('Lỗi tải giao dịch')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => const Center(child: Text('Lỗi tải ngân sách')),
      ),
    );
  }

  Widget _buildBody(BuildContext context, List<dynamic> budgets, List<dynamic> transactions, List<dynamic> categories) {
    final now = DateTime.now();
    double totalBudgetLimit = 0;
    double totalSpentAcrossBudgets = 0;

    // Tính toán chi tiêu cho từng ngân sách
    final List<Map<String, dynamic>> budgetReports = [];

    for (var budget in budgets) {
      final categoryId = budget['category_id'];
      final limit = (budget['limit_amount'] as num).toDouble();
      totalBudgetLimit += limit;

      // Lấy tên danh mục
      final category = categories.firstWhere((c) => c['id'] == categoryId, orElse: () => {'name': 'Không tên'});

      // Tính tổng chi tiêu cho category này trong tháng hiện tại
      double spent = 0;
      for (var tx in transactions) {
        final txDate = DateTime.parse(tx['created_at'].toString());
        if (tx['type'] == 'out' && tx['category_id'] == categoryId && txDate.month == now.month && txDate.year == now.year) {
          spent += (tx['amount'] as num).toDouble();
        }
      }
      
      totalSpentAcrossBudgets += spent;
      budgetReports.add({
        'name': category['name'],
        'limit': limit,
        'spent': spent,
        'color': _getCategoryColor(category['name']),
      });
    }

    // Nếu không có ngân sách nào, hiển thị lời nhắc
    if (budgets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_balance_wallet_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text('Bạn chưa thiết lập ngân sách nào.', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: () {}, child: const Text('Thiết lập ngay')),
          ],
        ),
      );
    }

    final double totalPercent = totalBudgetLimit > 0 ? totalSpentAcrossBudgets / totalBudgetLimit : 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBudgetSummaryCard(totalSpentAcrossBudgets, totalBudgetLimit, totalPercent),
          const SizedBox(height: 32),
          const Text('Chi tiết ngân sách tháng này', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...budgetReports.map((report) => _buildCategoryBudget(report['name'], report['limit'], report['spent'], report['color'])),
        ],
      ),
    );
  }

  Color _getCategoryColor(String name) {
    if (name.contains('Ăn uống')) return Colors.orange;
    if (name.contains('Di chuyển')) return Colors.blue;
    if (name.contains('Mua sắm')) return Colors.purple;
    if (name.contains('Hóa đơn')) return Colors.red;
    return Colors.teal;
  }

  Widget _buildBudgetSummaryCard(double totalSpent, double totalLimit, double percent) {
    final bool isOver = totalSpent > totalLimit;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tổng ngân sách tháng này', style: TextStyle(color: Colors.grey, fontSize: 14)),
              Text('${NumberFormat('#,###').format(totalLimit)} ₫', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percent > 1.0 ? 1.0 : percent,
              minHeight: 12,
              backgroundColor: Colors.grey[200],
              color: isOver ? Colors.red : Colors.blue,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Đã tiêu: ${NumberFormat('#,###').format(totalSpent)} ₫', style: TextStyle(color: isOver ? Colors.red : Colors.black87, fontWeight: FontWeight.bold)),
              Text('${(percent * 100).toStringAsFixed(1)}%', style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBudget(String label, double limit, double spent, Color color) {
    final double percent = spent / limit;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
              Text('${NumberFormat('#,###').format(spent)} / ${NumberFormat('#,###').format(limit)}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent > 1.0 ? 1.0 : percent,
              minHeight: 6,
              backgroundColor: color.withAlpha(20),
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
