import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/models/user_model.dart';

class AuthState {
  final bool isLoading;
  final UserModel? user;
  final String? accessToken;
  final String? refreshToken;
  final String? error;

  AuthState({
    this.isLoading = false,
    this.user,
    this.accessToken,
    this.refreshToken,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    UserModel? user,
    String? accessToken,
    String? refreshToken,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      error: error ?? this.error,
    );
  }

  bool get isAuthenticated {
    final authenticated = accessToken != null && user != null;
    print('Checking isAuthenticated: $authenticated (token: ${accessToken != null}, user: ${user != null})');
    return authenticated;
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final storage = ref.watch(secureStorageProvider);
  return AuthNotifier(apiClient, storage);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiClient _apiClient;
  final FlutterSecureStorage _storage;

  AuthNotifier(this._apiClient, this._storage) : super(AuthState()) {
    _init();
  }

  Future<void> _init() async {
    state = state.copyWith(isLoading: true);
    final accessToken = await _storage.read(key: 'jwt_token');
    final refreshToken = await _storage.read(key: 'refresh_token');
    final userJson = await _storage.read(key: 'user_data');
    
    if (accessToken != null && userJson != null) {
      try {
        final user = UserModel.fromJson(jsonDecode(userJson));
        state = state.copyWith(
          isLoading: false, 
          accessToken: accessToken, 
          refreshToken: refreshToken,
          user: user
        );
      } catch (e) {
        await logout();
      }
    } else {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiClient.dio.post('/auth/login', data: {
        'email': email, 
        'password': password
      });
      
      final data = response.data['data'];
      print('Login Response Data: $data');
      final accessToken = data['accessToken'];
      final refreshToken = data['refreshToken'];
      final user = UserModel.fromJson(data['user']);
      print('Parsed User: ${user.email}');

      await _storage.write(key: 'jwt_token', value: accessToken);
      await _storage.write(key: 'refresh_token', value: refreshToken);
      await _storage.write(key: 'user_data', value: jsonEncode(user.toJson()));

      state = state.copyWith(
        isLoading: false, 
        accessToken: accessToken, 
        refreshToken: refreshToken,
        user: user
      );
      print('Auth State updated. Authenticated: ${state.isAuthenticated}');
      return true;
    } catch (e) {
      String errorMessage = 'Login failed';
      if (e is DioException) {
        if (e.response?.statusCode == 403) {
          errorMessage = e.response?.data['message'] ?? 'Account restricted. Contact support.';
        } else if (e.response?.statusCode == 401) {
          errorMessage = 'Invalid email or password';
        } else {
          errorMessage = e.response?.data['message'] ?? 'Connection error';
        }
      }
      state = state.copyWith(isLoading: false, error: errorMessage);
      return false;
    }
  }

  Future<bool> activate(String token, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiClient.dio.post('/auth/activate', data: {
        'token': token,
        'password': password
      });

      final data = response.data['data'];
      final accessToken = data['accessToken'];
      final refreshToken = data['refreshToken'];
      final user = UserModel.fromJson(data['user']);

      await _storage.write(key: 'jwt_token', value: accessToken);
      await _storage.write(key: 'refresh_token', value: refreshToken);
      await _storage.write(key: 'user_data', value: jsonEncode(user.toJson()));

      state = state.copyWith(
        isLoading: false,
        accessToken: accessToken,
        refreshToken: refreshToken,
        user: user
      );
      return true;
    } catch (e) {
      String errorMessage = 'Activation failed';
      if (e is DioException) {
        errorMessage = e.response?.data['message'] ?? 'Invalid or expired token';
      }
      state = state.copyWith(isLoading: false, error: errorMessage);
      return false;
    }
  }

  Future<void> updateTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: 'jwt_token', value: accessToken);
    await _storage.write(key: 'refresh_token', value: refreshToken);
    state = state.copyWith(accessToken: accessToken, refreshToken: refreshToken);
  }

  Future<void> logout() async {
    try {
      await _apiClient.dio.post('/auth/logout');
    } catch (e) {
      // Ignore logout error if already expired
    }
    await _storage.delete(key: 'jwt_token');
    await _storage.delete(key: 'refresh_token');
    await _storage.delete(key: 'user_data');
    state = AuthState();
  }
}
