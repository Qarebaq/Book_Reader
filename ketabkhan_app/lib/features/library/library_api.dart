import '../../core/api_client.dart';
import '../books/book_models.dart';

class LibraryApi {
  LibraryApi(this._client);
  final ApiClient _client;

  Future<List<BookSummary>> myLibrary() async {
    final res = await _client.dio.get('/api/v1/library');
    final list = (res.data as List).cast<Map<String, dynamic>>();
    return list.map(BookSummary.fromJson).toList();
  }
}
