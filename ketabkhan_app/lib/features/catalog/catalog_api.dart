import 'package:dio/dio.dart';
import '../../core/api_client.dart';
import '../books/book_models.dart';

class CatalogApi {
  CatalogApi(this._client);
  final ApiClient _client;

  Future<List<BookSummary>> listBooks() async {
    final res = await _client.dio.get('/api/v1/books');
    final list = (res.data as List).cast<Map<String, dynamic>>();
    return list.map(BookSummary.fromJson).toList();
  }

  Future<BookDetail> getBook(int id) async {
    final res = await _client.dio.get('/api/v1/books/$id');
    return BookDetail.fromJson(res.data as Map<String, dynamic>);
  }

  Future<BookDetail> purchase(int id) async {
    final res = await _client.dio.post('/api/v1/books/$id/purchase');
    return BookDetail.fromJson(res.data as Map<String, dynamic>);
  }

  Future<List<int>> downloadEncrypted(int id) async {
    final res = await _client.dio.get<List<int>>(
      '/api/v1/books/$id/download',
      options: Options(responseType: ResponseType.bytes),
    );
    return res.data ?? <int>[];
  }
}
