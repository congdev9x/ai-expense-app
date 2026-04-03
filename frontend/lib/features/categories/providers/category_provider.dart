import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/category_repository.dart';

final categoryRepoProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository();
});

final categoryProvider = StateNotifierProvider<CategoryNotifier, AsyncValue<List<dynamic>>>((ref) {
  final repo = ref.watch(categoryRepoProvider);
  return CategoryNotifier(repo);
});

class CategoryNotifier extends StateNotifier<AsyncValue<List<dynamic>>> {
  final CategoryRepository repo;

  CategoryNotifier(this.repo) : super(const AsyncValue.loading()) {
    loadCategories();
  }

  Future<void> loadCategories() async {
    state = const AsyncValue.loading();
    try {
      final data = await repo.getCategories();
      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
