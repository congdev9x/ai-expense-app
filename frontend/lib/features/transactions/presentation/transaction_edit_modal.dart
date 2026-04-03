import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../categories/providers/category_provider.dart';
import '../providers/transaction_provider.dart';

class TransactionEditModal extends ConsumerStatefulWidget {
  final Map<String, dynamic> transaction;

  const TransactionEditModal({super.key, required this.transaction});

  @override
  ConsumerState<TransactionEditModal> createState() => _TransactionEditModalState();
}

class _TransactionEditModalState extends ConsumerState<TransactionEditModal> {
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  late TextEditingController _dateController;
  late String _txType;
  late int _categoryId;

  @override
  void initState() {
    super.initState();
    final tx = widget.transaction;
    final amountStr = NumberFormat('#,###').format((tx['amount'] ?? 0).toDouble());
    _amountController = TextEditingController(text: amountStr);
    _noteController = TextEditingController(text: tx['note'] ?? '');
    
    final dateStr = (tx['created_at'] ?? '').toString();
    _dateController = TextEditingController(text: dateStr.length >= 10 ? dateStr.substring(0, 10) : '');
    
    _txType = tx['type'] ?? 'out';
    _categoryId = tx['category_id'] ?? 1;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(_dateController.text) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
         _dateController.text = pickedDate.toString().substring(0, 10);
      });
    }
  }

  Future<void> _updateTransaction() async {
    final cleanAmountString = _amountController.text.replaceAll(',', '').replaceAll('.', '');
    final Map<String, dynamic> txData = {
      'amount': int.tryParse(cleanAmountString) ?? 0,
      'type': _txType,
      'category_id': _categoryId,
      'note': _noteController.text,
      'created_at': '${_dateController.text}T12:00:00Z',
    };
    
    final isSaved = await ref.read(transactionProvider.notifier).updateTransaction(widget.transaction['id'], txData);
    
    if (isSaved) {
      if (mounted) {
        Navigator.pop(context, true); // Đóng modal và trả về true để báo reload Detail UI
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật giao dịch thành công!'), backgroundColor: Colors.green),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật thất bại. Vui lòng thử lại!'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryState = ref.watch(categoryProvider);

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   const Text('Sửa Giao Dịch', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                   IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context))
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   const Text('Loại Giao Dịch:', style: TextStyle(fontWeight: FontWeight.w500)),
                   ToggleButtons(
                     borderRadius: BorderRadius.circular(8),
                     isSelected: [_txType == 'out', _txType == 'in'],
                     onPressed: (index) => setState(() => _txType = index == 0 ? 'out' : 'in'),
                     children: const [
                       Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Chi Tiền', style: TextStyle(color: Colors.red))),
                       Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Thu Thêm', style: TextStyle(color: Colors.green))),
                     ],
                   )
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Số tiền', suffixText: '₫', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _noteController,
                decoration: const InputDecoration(labelText: 'Nội dung', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectDate(context),
                      child: AbsorbPointer(
                        child: TextField(
                          controller: _dateController,
                          decoration: const InputDecoration(labelText: 'Ngày', border: OutlineInputBorder(), suffixIcon: Icon(Icons.calendar_today)),
                          readOnly: true, 
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: categoryState.when(
                      data: (categories) {
                        final hasCategory = categories.any((c) => c['id'] == _categoryId);
                        if (!hasCategory && categories.isNotEmpty) {
                          _categoryId = categories.first['id'];
                        }
                        return DropdownButtonFormField<int>(
                          value: _categoryId,
                          isExpanded: true,
                          decoration: const InputDecoration(labelText: 'Danh mục', border: OutlineInputBorder()),
                          items: categories.map<DropdownMenuItem<int>>((c) {
                            return DropdownMenuItem<int>(value: c['id'], child: Text(c['name']));
                          }).toList(),
                          onChanged: (val) { if (val != null) setState(() => _categoryId = val); },
                        );
                      },
                      loading: () => const CircularProgressIndicator(),
                      error: (_, __) => const Text('Lỗi DM'),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _updateTransaction,
                  icon: const Icon(Icons.save),
                  label: const Text('Lưu Thay Đổi', style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
