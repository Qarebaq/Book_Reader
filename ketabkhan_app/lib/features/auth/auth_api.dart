import 'package:dio/dio.dart';
import '../../core/api_client.dart';
import 'auth_models.dart';

class AuthApi {
  AuthApi(this._client);
  final ApiClient _client;

  Future<TokenResponse> register({required String email, required String password}) async {
    final res = await _client.dio.post(
      '/api/v1/auth/register',
      data: {'email': email, 'password': password},
    );
    return TokenResponse.fromJson(res.data as Map<String, dynamic>);
  }

  Future<TokenResponse> login({required String email, required String password}) async {
    final res = await _client.dio.post(
      '/api/v1/auth/login',
      data: {'email': email, 'password': password},
    );
    return TokenResponse.fromJson(res.data as Map<String, dynamic>);
  }
}
