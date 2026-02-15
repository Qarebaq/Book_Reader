import '../../core/api_client.dart';
import 'library_models.dart';

class LibraryApi {
  LibraryApi(this._client);
  final ApiClient _client;

  Future<List<Book>> myLibrary() async {
    final res = await _client.dio.get('/api/v1/library');
    final list = (res.data as List).cast<Map<String, dynamic>>();
    return list.map(Book.fromJson).toList();
  }
}
