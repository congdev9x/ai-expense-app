import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/budget_repository.dart';

final budgetRepoProvider = Provider<BudgetRepository>((ref) {
  return BudgetRepository();
});

final budgetProvider = StateNotifierProvider<BudgetNotifier, AsyncValue<List<dynamic>>>((ref) {
  final repo = ref.watch(budgetRepoProvider);
  return BudgetNotifier(repo);
});

class BudgetNotifier extends StateNotifier<AsyncValue<List<dynamic>>> {
  final BudgetRepository repo;

  BudgetNotifier(this.repo) : super(const AsyncValue.loading()) {
    loadBudgets();
  }

  Future<void> loadBudgets() async {
    state = const AsyncValue.loading();
    try {
      final data = await repo.getBudgets();
      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> addBudget(Map<String, dynamic> budgetData) async {
    try {
      final result = await repo.createBudget(budgetData);
      if (state is AsyncData) {
        final currentList = state.value!;
        state = AsyncValue.data([...currentList, result]);
      } else {
        await loadBudgets();
      }
      return true;
    } catch (e) {
      print('Add budget error: $e');
      return false;
    }
  }
}
