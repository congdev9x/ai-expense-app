import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:intl/intl.dart';
import '../providers/ai_provider.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../../categories/providers/category_provider.dart';

class AiInputModal extends ConsumerStatefulWidget {
  const AiInputModal({super.key});

  @override
  ConsumerState<AiInputModal> createState() => _AiInputModalState();
}

class _AiInputModalState extends ConsumerState<AiInputModal> {
  int _currentIndex = 0;
  final _textController = TextEditingController();
  
  // Speech to text
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _voiceText = '';

  // Confirm State
  bool _isConfirming = false;
  Map<String, dynamic>? _pendingTxData;

  // Form Controllers
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _dateController = TextEditingController();
  int _categoryId = 1;
  String _txType = 'out';
  
  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  @override
  void dispose() {
    _textController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _listenVoice() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: \$val'),
        onError: (val) => print('onError: \$val'),
      );
      if (available) {
        setState(() {
          _isListening = true;
          _voiceText = 'Đang nghe...';
        });
        _speech.listen(
          onResult: (val) => setState(() {
            _voiceText = val.recognizedWords;
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
      if (_voiceText.isNotEmpty && _voiceText != 'Đang nghe...') {
        // Tự động phân tích khi dừng nói
        _analyzeInput(text: _voiceText);
      }
    }
  }

  void _analyzeInput({String? text}) async {
    final input = text ?? _textController.text;
    if (input.trim().isEmpty) return;

    final success = await ref.read(aiProvider.notifier).analyzeText(input);
    
    if (success && mounted) {
      final parsedData = ref.read(aiProvider).parsedData;
      
      final noteText = parsedData?['note'] ?? '';
      final amountValue = parsedData?['amount'] ?? 0;
      final categoryId = parsedData?['category_id'] ?? 1;
      final dateStr = parsedData?['date'];
      final transactionType = parsedData?['type'] ?? 'out';

      // Chuyển sang màn hình Confirm Form
      setState(() {
        _isConfirming = true;
        _noteController.text = noteText;
        _amountController.text = NumberFormat('#,###').format(amountValue).toString();
        
        // Date parsing: AI có thể trả về yyyy-mm-dd
        String displayDate = DateTime.now().toString().substring(0, 10);
        if (dateStr != null && dateStr.toString().length >= 10) {
           displayDate = dateStr.toString().substring(0, 10);
        }
        _dateController.text = displayDate;
        
        _categoryId = categoryId;
        _txType = transactionType;
      });
      
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ref.read(aiProvider).error ?? 'Có lỗi xảy ra'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _saveConfirmedTransaction() async {
     // Gọi API lưu mới Giao dịch dựa trên Dữ liệu trong Form xác nhận
      final cleanAmountString = _amountController.text.replaceAll(',', '').replaceAll('.', '');
      final Map<String, dynamic> txData = {
        'amount': int.tryParse(cleanAmountString) ?? 0,
        'type': _txType,
        'category_id': _categoryId,
        'note': _noteController.text,
        'created_at': '${_dateController.text}T12:00:00Z',
      };
      
      final isSaved = await ref.read(transactionProvider.notifier).addTransaction(txData);

      if (mounted) {
        Navigator.pop(context); // Đóng modal
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã lưu giao dịch thành công!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );
      }
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
         // Cập nhật giá trị yyyy-MM-dd sau khi chọn Lịch
         _dateController.text = pickedDate.toString().substring(0, 10);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final aiState = ref.watch(aiProvider);
    final categoryState = ref.watch(categoryProvider);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _isConfirming ? 'Xác nhận thông tin' : 'Nhập liệu thông minh',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
            const SizedBox(height: 16),
            if (_isConfirming) _buildConfirmForm(categoryState) else ...[
              _buildInputTabs(),
              const SizedBox(height: 24),
              _buildInputContent(),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: aiState.isAnalyzing || (!_isConfirming && _currentIndex == 0 && _textController.text.isEmpty) || (!_isConfirming && _currentIndex == 1 && _isListening) 
                    ? null 
                    : () => _isConfirming ? _saveConfirmedTransaction() : _analyzeInput(),
                icon: aiState.isAnalyzing 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Icon(_isConfirming ? Icons.check_circle : Icons.auto_awesome, color: Colors.white),
                label: Text(
                  aiState.isAnalyzing ? 'Đang phân tích...' : (_isConfirming ? 'Xác nhận & Lưu' : 'Phân tích Giao dịch'),
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isConfirming ? Colors.green : Theme.of(context).colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            if (_isConfirming) ...[
               const SizedBox(height: 12),
               SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => setState(() => _isConfirming = false),
                  child: const Text('Huỷ bản nháp', style: TextStyle(color: Colors.grey)),
                ),
               )
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildInputTabs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTabItem(0, Icons.chat_bubble_outline, 'Văn bản'),
        const SizedBox(width: 16),
        _buildTabItem(1, Icons.mic_none, 'Giọng nói'),
        const SizedBox(width: 16),
        _buildTabItem(2, Icons.document_scanner_outlined, 'Quét hóa đơn'),
      ],
    );
  }

  Widget _buildTabItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    final primaryColor = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: () {
        if (_isListening) _listenVoice(); // Tắt mic nếu đang chạy
        setState(() => _currentIndex = index);
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? primaryColor.withAlpha(30) : Colors.grey[100],
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? primaryColor : Colors.transparent,
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              color: isSelected ? primaryColor : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? primaryColor : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputContent() {
    switch (_currentIndex) {
      case 0:
        return _buildTextContent();
      case 1:
        return _buildVoiceContent();
      case 2:
        return _buildScannerContent();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTextContent() {
    final isAnalyzing = ref.watch(aiProvider).isAnalyzing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Bạn đã tiêu gì hôm nay?', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: _textController,
          enabled: !isAnalyzing,
          onChanged: (val) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Ví dụ: Mới đi ăn trưa bún chả hết 35k...',
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 8),
        Text(
          'AI sẽ tự động nhận diện số tiền, danh mục và ngày tháng ghi chú.',
          style: TextStyle(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic),
        )
      ],
    );
  }

  Widget _buildVoiceContent() {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text('Nhấn vào micro để nói', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: _listenVoice,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isListening ? Colors.red.withAlpha(30) : Theme.of(context).colorScheme.primary.withAlpha(30),
                border: Border.all(
                  color: _isListening ? Colors.red : Theme.of(context).colorScheme.primary,
                  width: 3,
                )
              ),
              child: Icon(
                _isListening ? Icons.stop : Icons.mic,
                size: 48,
                color: _isListening ? Colors.red : Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _voiceText.isEmpty ? 'Sẵn sàng ghi âm' : _voiceText,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _isListening ? Colors.red : Colors.black87,
              fontWeight: _isListening ? FontWeight.bold : FontWeight.w500,
              fontSize: 16,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildScannerContent() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
      ),
      child: Column(
        children: [
          Icon(Icons.camera_alt_outlined, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Chụp hoặc chọn ảnh hóa đơn\nđể AI quét thông tin',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add_photo_alternate_outlined),
            label: const Text('Chọn ảnh biên lai'),
          )
        ],
      ),
    );
  }

  Widget _buildConfirmForm(AsyncValue<List<dynamic>> categoryState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
          decoration: const InputDecoration(
            labelText: 'Số tiền',
            suffixText: '₫',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _noteController,
          decoration: const InputDecoration(
            labelText: 'Nội dung',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer( // Ngăn chặn bàn phím ảo đẩy lên
                  child: TextField(
                    controller: _dateController,
                    decoration: const InputDecoration(
                      labelText: 'Ngày',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true, 
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: categoryState.when(
                data: (categories) {
                  // Đảm bảo item _categoryId có trong danh sách 
                  final hasCategory = categories.any((c) => c['id'] == _categoryId);
                  if (!hasCategory && categories.isNotEmpty) {
                    _categoryId = categories.first['id'];
                  }
                  return DropdownButtonFormField<int>(
                    value: _categoryId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Danh Mục',
                      border: OutlineInputBorder(),
                    ),
                    items: categories.map<DropdownMenuItem<int>>((cat) {
                      return DropdownMenuItem<int>(
                        value: cat['id'],
                        child: Text(cat['name'], overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _categoryId = val!),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => const Text('Lỗi tải danh mục'),
              ),
            )
          ],
        ),
      ],
    );
  }
}

