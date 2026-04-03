import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? errorMessage;

  AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(AuthState(isLoading: true)) {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    final token = await _repository.getToken();
    state = state.copyWith(
      isAuthenticated: token != null,
      isLoading: false,
    );
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final success = await _repository.login(email, password);
    state = state.copyWith(
      isAuthenticated: success,
      isLoading: false,
      errorMessage: success ? null : "Đăng nhập thất bại. Kiểm tra lại thông tin.",
    );
    return success;
  }

  Future<bool> register(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final success = await _repository.register(email, password);
    state = state.copyWith(
      isAuthenticated: success,
      isLoading: false,
      errorMessage: success ? null : "Đăng ký thất bại. Email có thể đã tồn tại.",
    );
    return success;
  }

  Future<void> logout() async {
    await _repository.removeToken();
    state = state.copyWith(isAuthenticated: false);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});

final authModeProvider = StateProvider<bool>((ref) => true); // true = login, false = register
