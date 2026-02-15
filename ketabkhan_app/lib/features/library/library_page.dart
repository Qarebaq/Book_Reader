import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';
import '../auth/auth_controller.dart';
import 'library_api.dart';
import 'library_models.dart';

final libraryApiProvider = Provider<LibraryApi>((ref) {
  final client = ref.read(apiClientProvider);
  return LibraryApi(client);
});

final libraryProvider = FutureProvider<List<Book>>((ref) async {
  final api = ref.read(libraryApiProvider);
  return api.myLibrary();
});

class LibraryPage extends ConsumerWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(libraryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('کتابخانه'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authControllerProvider).logout();
              if (context.mounted) Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: booksAsync.when(
        data: (books) => ListView.separated(
          itemCount: books.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final b = books[i];
            return ListTile(
              title: Text(b.title),
              subtitle: Text(b.publisher),
              leading: const Icon(Icons.menu_book),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('خطا: $e'),
        ),
      ),
    );
  }
}
