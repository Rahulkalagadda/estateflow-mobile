import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/network/api_client.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final storage = ref.watch(secureStorageProvider);
  return AuthService(apiClient, storage);
});

class AuthService {
  // final ApiClient _apiClient;
  final FlutterSecureStorage _storage;

  AuthService(ApiClient apiClient, this._storage);

  Future<bool> login(String email, String password) async {
    try {
      // Simulate API call for now since we don't have a real backend
      await Future.delayed(const Duration(seconds: 1));

      // Example implementation:
      // final response = await _apiClient.dio.post('/auth/login', data: {
      //   'email': email,
      //   'password': password,
      // });
      // final token = response.data['token'];

      final token = "fake_jwt_token_for_$email";
      await _storage.write(key: 'jwt_token', value: token);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'jwt_token');
    return token != null;
  }
}
