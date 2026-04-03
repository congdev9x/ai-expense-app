import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/transaction_repository.dart';

final transactionRepoProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository();
});

final transactionProvider = StateNotifierProvider<TransactionNotifier, AsyncValue<List<dynamic>>>((ref) {
  final repo = ref.watch(transactionRepoProvider);
  return TransactionNotifier(repo);
});

class TransactionNotifier extends StateNotifier<AsyncValue<List<dynamic>>> {
  final TransactionRepository repo;

  TransactionNotifier(this.repo) : super(const AsyncValue.loading()) {
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    state = const AsyncValue.loading();
    try {
      final data = await repo.getTransactions();
      // Sắp xếp mới nhất lên đầu
      data.sort((a, b) => (b['created_at'] ?? '').compareTo(a['created_at'] ?? ''));
      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> addTransaction(Map<String, dynamic> txData) async {
    try {
      final newTx = await repo.createTransaction(txData);
      // Đánh dấu bản ghi này vừa mới được add
      newTx['isNew'] = true;
      if (state is AsyncData) {
        final currentList = state.value!;
        state = AsyncValue.data([newTx, ...currentList]);
      } else {
        await loadTransactions();
      }
      return true;
    } catch (e) {
      print('Add transaction error: $e');
      return false;
    }
  }

  Future<bool> updateTransaction(int id, Map<String, dynamic> txData) async {
    try {
      final updatedTx = await repo.updateTransaction(id, txData);
      if (state is AsyncData) {
        final currentList = state.value!;
        final index = currentList.indexWhere((tx) => tx['id'] == id);
        if (index != -1) {
          final newList = List<dynamic>.from(currentList);
          newList[index] = updatedTx;
          state = AsyncValue.data(newList);
        } else {
           await loadTransactions();
        }
      }
      return true;
    } catch (e) {
      print('Update transaction error: \$e');
      return false;
    }
  }

  Future<bool> deleteTransaction(int id) async {
    try {
      await repo.deleteTransaction(id);
      if (state is AsyncData) {
        final currentList = state.value!;
        final newList = currentList.where((tx) => tx['id'] != id).toList();
        state = AsyncValue.data(newList);
      }
      return true;
    } catch (e) {
      print('Delete transaction error: \$e');
      return false;
    }
  }
}
