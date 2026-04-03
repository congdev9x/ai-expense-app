import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../categories/providers/category_provider.dart';
import '../providers/history_provider.dart';

class TransactionFilterModal extends ConsumerStatefulWidget {
  const TransactionFilterModal({super.key});

  @override
  ConsumerState<TransactionFilterModal> createState() => _TransactionFilterModalState();
}

class _TransactionFilterModalState extends ConsumerState<TransactionFilterModal> {
  late String _selectedType;
  late List<int> _selectedCategoryIds;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    final currentFilter = ref.read(historyFilterProvider);
    _selectedType = currentFilter.type;
    _selectedCategoryIds = List.from(currentFilter.categoryIds);
    _startDate = currentFilter.startDate;
    _endDate = currentFilter.endDate;
  }

  void _resetFilters() {
    setState(() {
      _selectedType = 'all';
      _selectedCategoryIds = [];
      _startDate = null;
      _endDate = null;
    });
  }

  void _applyFilters() {
    ref.read(historyFilterProvider.notifier).state = TransactionFilter(
      type: _selectedType,
      categoryIds: _selectedCategoryIds,
      startDate: _startDate,
      endDate: _endDate,
    );
    Navigator.pop(context);
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesState = ref.watch(categoryProvider);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Bộ lọc giao dịch', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: _resetFilters,
                  child: const Text('Đặt lại'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Loại giao dịch', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildTypeChip('Tất cả', 'all'),
                const SizedBox(width: 8),
                _buildTypeChip('Thu nhập', 'in'),
                const SizedBox(width: 8),
                _buildTypeChip('Chi tiêu', 'out'),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Khoảng thời gian', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            InkWell(
              onTap: _selectDateRange,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 18, color: Colors.blue),
                    const SizedBox(width: 12),
                    Text(
                      _startDate == null ? 'Chọn khoảng ngày' : '${DateFormat('dd/MM/yyyy').format(_startDate!)} - ${DateFormat('dd/MM/yyyy').format(_endDate!)}',
                      style: TextStyle(color: _startDate == null ? Colors.grey : Colors.black87),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Danh mục', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            categoriesState.when(
              data: (categories) => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categories.map((cat) {
                  final isSelected = _selectedCategoryIds.contains(cat['id']);
                  return FilterChip(
                    label: Text(cat['name'] ?? 'Chưa tên'),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedCategoryIds.add(cat['id']);
                        } else {
                          _selectedCategoryIds.remove(cat['id']);
                        }
                      });
                    },
                    selectedColor: Colors.blue.withAlpha(40),
                    checkmarkColor: Colors.blue,
                  );
                }).toList(),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => const Text('Lỗi tải danh mục'),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Áp dụng bộ lọc', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeChip(String label, String value) {
    final isSelected = _selectedType == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedType = value);
        }
      },
      selectedColor: Colors.blue.withAlpha(40),
      labelStyle: TextStyle(color: isSelected ? Colors.blue : Colors.black87),
    );
  }
}
