import 'package:flutter/material.dart';
import 'features/auth/login_page.dart';
import 'features/auth/register_page.dart';
import 'features/library/library_page.dart';
import 'features/catalog/catalog_page.dart';

class KetabkhanApp extends StatelessWidget {
  const KetabkhanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'کتابخان',
      theme: ThemeData(useMaterial3: true),
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginPage(),
        '/register': (_) => const RegisterPage(),
        '/library': (_) => const LibraryPage(),
        '/catalog': (_) => const CatalogPage(),
      },
    );
  }
}
