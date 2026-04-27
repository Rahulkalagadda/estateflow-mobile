import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_constants.dart';

final secureStorageProvider = Provider((ref) => const FlutterSecureStorage());

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref);
});

class ApiClient {
  final Dio _dio;
  final Ref _ref;
  bool _isRefreshing = false;

  ApiClient(this._ref) : _dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl)) {
    final storage = _ref.read(secureStorageProvider);
    
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await storage.read(key: 'jwt_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401 && !_isRefreshing) {
            _isRefreshing = true;
            try {
              final refreshToken = await storage.read(key: 'refresh_token');
              if (refreshToken != null) {
                final response = await _dio.post('/auth/refresh', data: {'refreshToken': refreshToken});
                final newAccessToken = response.data['data']['accessToken'];
                final newRefreshToken = response.data['data']['refreshToken'];

                await _ref.read(authProvider.notifier).updateTokens(newAccessToken, newRefreshToken);

                // Retry original request
                final opts = e.requestOptions;
                opts.headers['Authorization'] = 'Bearer $newAccessToken';
                final retryRes = await _dio.fetch(opts);
                _isRefreshing = false;
                return handler.resolve(retryRes);
              }
            } catch (refreshError) {
              _isRefreshing = false;
              await _ref.read(authProvider.notifier).logout();
              return handler.next(e);
            }
          }

          // Basic Retry Logic for network errors
          if (_shouldRetry(e) && (e.requestOptions.extra['retries'] ?? 0) < 3) {
            e.requestOptions.extra['retries'] = (e.requestOptions.extra['retries'] ?? 0) + 1;
            try {
              await Future.delayed(const Duration(milliseconds: 1000));
              final response = await _dio.fetch(e.requestOptions);
              return handler.resolve(response);
            } catch (retryError) {
              return handler.next(retryError is DioException ? retryError : e);
            }
          }

          return handler.next(e);
        },
      ),
    );
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError ||
        (err.response?.statusCode != null && err.response!.statusCode! >= 500);
  }

  Dio get dio => _dio;
}
