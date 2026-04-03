import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/ai_repository.dart';

final aiRepositoryProvider = Provider<AiRepository>((ref) {
  return AiRepository();
});

class AiState {
  final bool isAnalyzing;
  final Map<String, dynamic>? parsedData;
  final String? error;

  AiState({
    this.isAnalyzing = false,
    this.parsedData,
    this.error,
  });

  AiState copyWith({
    bool? isAnalyzing,
    Map<String, dynamic>? parsedData,
    String? error,
    bool clearError = false,
  }) {
    return AiState(
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      parsedData: parsedData ?? this.parsedData,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class AiNotifier extends StateNotifier<AiState> {
  final AiRepository _repository;

  AiNotifier(this._repository) : super(AiState());

  Future<bool> analyzeText(String userText) async {
    state = state.copyWith(isAnalyzing: true, clearError: true);
    final result = await _repository.parseExpense(userText);
    
    if (result != null) {
      state = state.copyWith(isAnalyzing: false, parsedData: result);
      return true;
    } else {
      state = state.copyWith(isAnalyzing: false, error: 'Không thể phân tích, vui lòng thử lại.');
      return false;
    }
  }

  void reset() {
    state = AiState();
  }
}

final aiProvider = StateNotifierProvider<AiNotifier, AiState>((ref) {
  final repository = ref.watch(aiRepositoryProvider);
  return AiNotifier(repository);
});
