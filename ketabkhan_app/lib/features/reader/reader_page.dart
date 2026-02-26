import 'package:flutter/material.dart';

class ReaderPage extends StatelessWidget {
  const ReaderPage({super.key, required this.bookId, required this.title});

  final int bookId;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: const Center(
        child: Text('Reader coming soon: page view, notes, highlights, themes.'),
      ),
    );
  }
}
