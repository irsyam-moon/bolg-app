import 'package:flutter/material.dart';
import 'pages/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blog Dark App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0B132B),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0B132B),
          elevation: 0,
        ),
        cardColor: const Color(0xFF1C2541),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF48CAE4),
          foregroundColor: Colors.black,
        ),
      ),
      home: const HomePage(),
    );
  }
}
