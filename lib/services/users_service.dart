import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_client.dart';
import '../core/models/user_model.dart';

final usersServiceProvider = Provider<UsersService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return UsersService(apiClient);
});

class UsersService {
  final ApiClient _apiClient;

  UsersService(this._apiClient);

  Future<List<UserModel>> fetchTeamMembers() async {
    try {
      final response = await _apiClient.dio.get('/users');
      return (response.data['data'] as List).map((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch team members: $e');
    }
  }
}
