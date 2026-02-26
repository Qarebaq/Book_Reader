import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';
import '../books/book_models.dart';
import 'catalog_api.dart';
import 'book_detail_page.dart';

final catalogApiProvider = Provider<CatalogApi>((ref) {
  final client = ref.read(apiClientProvider);
  return CatalogApi(client);
});

final catalogProvider = FutureProvider<List<BookSummary>>((ref) async {
  final api = ref.read(catalogApiProvider);
  return api.listBooks();
});

class CatalogPage extends ConsumerStatefulWidget {
  const CatalogPage({super.key});

  @override
  ConsumerState<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends ConsumerState<CatalogPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final booksAsync = ref.watch(catalogProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('کاتالوگ'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'جستجو کتاب...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => _query = v.trim()),
            ),
          ),
          Expanded(
            child: booksAsync.when(
              data: (books) {
                final filtered = _query.isEmpty
                    ? books
                    : books.where((b) => b.title.contains(_query)).toList();
                if (filtered.isEmpty) {
                  return const Center(child: Text('کتابی پیدا نشد'));
                }
                return ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final b = filtered[i];
                    return ListTile(
                      title: Text(b.title),
                      subtitle: Text(b.publisher),
                      trailing: Text('${b.price} تومان'),
                      leading: const Icon(Icons.menu_book),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => BookDetailPage(bookId: b.id)),
                        );
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('خطا: $e')),
            ),
          ),
        ],
      ),
    );
  }
}
