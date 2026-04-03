import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/nav_provider.dart';
import '../../ai_input/presentation/ai_input_modal.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../../transactions/presentation/transaction_detail_modal.dart';
import '../../auth/providers/auth_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildAppBar(ref),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBalanceCard(context, ref),
                    const SizedBox(height: 24),
                    _buildQuickActions(ref),
                    const SizedBox(height: 24),
                    _buildRecentTransactionsHeader(ref),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            _buildTransactionsList(ref),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAIInputDialog(context);
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        icon: const Icon(Icons.auto_awesome, color: Colors.white),
        label: const Text('Nhập AI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // .... (AppBar và BalanceCard giữ nguyên) ....

  // ==== App Bar ====
  Widget _buildAppBar(WidgetRef ref) {
    return SliverAppBar(
      floating: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Xin chào!', style: TextStyle(fontSize: 14, color: Colors.grey)),
          Text('Người dùng AI', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.black87),
          onPressed: () {},
        ),
        PopupMenuButton<String>(
          icon: const CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'),
          ),
          onSelected: (value) {
            if (value == 'logout') {
              ref.read(authProvider.notifier).logout();
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Text('Đăng xuất', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        )
      ],
    );
  }

  // ==== Balance Card ====
  Widget _buildBalanceCard(BuildContext context, WidgetRef ref) {
    final transactionsState = ref.watch(transactionProvider);
    double totalBalance = 0;
    double totalIncome = 0;
    double totalExpense = 0;

    if (transactionsState is AsyncData) {
      for (var tx in transactionsState.value!) {
        final amount = (tx['amount'] as num).toDouble();
        if (tx['type'] == 'in') {
          totalIncome += amount;
          totalBalance += amount;
        } else {
          totalExpense += amount;
          totalBalance -= amount;
        }
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.tertiary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withAlpha(80),
            blurRadius: 16,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tổng số dư',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            '${NumberFormat('#,###').format(totalBalance)} ₫',
            style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildIncomeExpenseStat(Icons.arrow_downward, 'Thu nhập', '${NumberFormat('#,###').format(totalIncome)} ₫', Colors.greenAccent),
              _buildIncomeExpenseStat(Icons.arrow_upward, 'Đã chi', '${NumberFormat('#,###').format(totalExpense)} ₫', Colors.redAccent),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildIncomeExpenseStat(IconData icon, String label, String amount, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.white.withAlpha(40), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            Text(amount, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        )
      ],
    );
  }

  // ==== Quick Actions ====
  Widget _buildQuickActions(WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildActionItem(Icons.pie_chart, 'Thống kê', Colors.blue, () => ref.read(navIndexProvider.notifier).state = 1),
        _buildActionItem(Icons.account_balance_wallet, 'Ngân sách', Colors.orange, () => ref.read(navIndexProvider.notifier).state = 2),
        _buildActionItem(Icons.history, 'Lịch sử', Colors.purple, () => ref.read(navIndexProvider.notifier).state = 1),
        _buildActionItem(Icons.more_horiz, 'Thêm', Colors.grey, () {}),
      ],
    );
  }

  Widget _buildActionItem(IconData icon, String label, Color color, VoidCallback onTap) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black87)),
      ],
    );
  }

  // ==== Transactions Section ====
  Widget _buildRecentTransactionsHeader(WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Giao dịch gần đây',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        TextButton(
          onPressed: () => ref.read(navIndexProvider.notifier).state = 1,
          child: const Text('Xem tất cả'),
        )
      ],
    );
  }

  Widget _buildTransactionsList(WidgetRef ref) {
    final transactionsState = ref.watch(transactionProvider);

    return transactionsState.when(
      data: (transactions) {
        if (transactions.isEmpty) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(child: Text('Chưa có giao dịch nào')),
            ),
          );
        }

        // Sắp xếp giảm dần theo thời gian (mới nhất lên đầu)
        final sortedList = List<dynamic>.from(transactions);
        sortedList.sort((a, b) {
            final dateA = DateTime.parse(a['created_at'].toString());
            final dateB = DateTime.parse(b['created_at'].toString());
            return dateB.compareTo(dateA);
        });

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final tx = sortedList[index];
              final isIncome = tx['type'] == 'in';
              final amountStr = NumberFormat('#,###').format((tx['amount'] as num).toDouble());
              final color = isIncome ? Colors.green : Colors.orange;
              final icon = isIncome ? Icons.payments : Icons.restaurant;
              final isNew = tx['isNew'] == true;
              
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: isNew ? Colors.amber.withAlpha(20) : Colors.white,
                    border: isNew ? Border.all(color: Colors.amber, width: 1.5) : null,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(10),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: ListTile(
                    onTap: () => _showTransactionDetailDialog(context, tx),
                    contentPadding: const EdgeInsets.all(12),
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withAlpha(30),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: color),
                    ),
                    title: Text(tx['note'] ?? 'Giao dịch', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Text('Danh mục ${tx['category_id']} • ${tx['created_at'].toString().substring(0, 10)}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    trailing: Text(
                      '${isIncome ? '+' : '-'}$amountStr ₫',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isIncome ? Colors.green : Colors.black87,
                      ),
                    ),
                  ),
                ),
              );
            },
            childCount: transactions.length,
          ),
        );
      },
      loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
      error: (e, st) => SliverToBoxAdapter(child: Center(child: Text('Lỗi tải GD'))),
    );
  }

  // ==== Modal Nhập liệu bằng AI ====
  void _showAIInputDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AiInputModal(),
    );
  }

  // ==== Modal Xem chi tiết Giao dịch ====
  void _showTransactionDetailDialog(BuildContext context, Map<String, dynamic> tx) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TransactionDetailModal(transaction: tx),
    );
  }
}
