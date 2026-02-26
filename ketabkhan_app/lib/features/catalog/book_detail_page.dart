import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/book_cache.dart';
import '../../core/drm.dart';
import '../books/book_models.dart';
import 'catalog_api.dart';
import '../reader/reader_page.dart';

final bookCacheProvider = Provider<BookCache>((ref) => BookCache());

class BookDetailPage extends ConsumerStatefulWidget {
  const BookDetailPage({super.key, required this.bookId});

  final int bookId;

  @override
  ConsumerState<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends ConsumerState<BookDetailPage> {
  bool _loading = false;

  Future<BookDetail> _load() async {
    final api = ref.read(catalogApiProvider);
    return api.getBook(widget.bookId);
  }

  Future<void> _purchase() async {
    setState(() => _loading = true);
    try {
      final api = ref.read(catalogApiProvider);
      await api.purchase(widget.bookId);
      if (!mounted) return;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('خرید انجام شد')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطا: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _downloadAndOpen(BookDetail book) async {
    setState(() => _loading = true);
    try {
      final api = ref.read(catalogApiProvider);
      final encrypted = await api.downloadEncrypted(widget.bookId);
      final cache = ref.read(bookCacheProvider);
      await cache.storeEncrypted(widget.bookId.toString(), encrypted);
      final decrypted = drmXor(encrypted);
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ReaderPage(bookId: book.id, title: book.title)),
      );
      // TODO: pass decrypted bytes to reader for rendering.
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطا: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<BookDetail>(
      future: _load(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          if (snapshot.hasError) {
            return Scaffold(body: Center(child: Text('خطا: ${snapshot.error}')));
          }
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final book = snapshot.data!;
        return Scaffold(
          appBar: AppBar(title: Text(book.title)),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(book.publisher, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                Text(book.description ?? 'بدون توضیح'),
                const Spacer(),
                if (!book.purchased)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _purchase,
                      child: _loading ? const CircularProgressIndicator() : Text('خرید ${book.price} تومان'),
                    ),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : () => _downloadAndOpen(book),
                      child: _loading ? const CircularProgressIndicator() : const Text('مطالعه'),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
