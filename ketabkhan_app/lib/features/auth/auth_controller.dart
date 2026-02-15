import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';
import '../../core/token_storage.dart';
import 'auth_api.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());

final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.read(tokenStorageProvider);
  return ApiClient(storage);
});

final authApiProvider = Provider<AuthApi>((ref) {
  final client = ref.read(apiClientProvider);
  return AuthApi(client);
});

final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController(ref);
});

class AuthController {
  AuthController(this.ref);
  final Ref ref;

  Future<void> register(String email, String password) async {
    final api = ref.read(authApiProvider);
    final storage = ref.read(tokenStorageProvider);
    final token = await api.register(email: email, password: password);
    await storage.saveToken(token.accessToken);
  }

  Future<void> login(String email, String password) async {
    final api = ref.read(authApiProvider);
    final storage = ref.read(tokenStorageProvider);
    final token = await api.login(email: email, password: password);
    await storage.saveToken(token.accessToken);
  }

  Future<void> logout() async {
    await ref.read(tokenStorageProvider).clearToken();
  }
}
