// Mengimpor pustaka antarmuka Material Design utama dari framework Flutter
import 'package:flutter/material.dart';

// Impor halaman Splash Screen
import 'pages/splash_screen_page.dart';

// Fungsi utama (entry point) aplikasi
void main() {
  runApp(const SmartKasirApp());
}

// Deklarasi kelas root aplikasi turunan StatelessWidget
class SmartKasirApp extends StatelessWidget {
  const SmartKasirApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartKasir',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0EA5E9), // Biru Muda / Sky Blue Segar & Modern
          primary: const Color(0xFF0EA5E9),
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Color(0xFF0EA5E9),
          foregroundColor: Colors.white,
        ),
      ),
      // Titik awal aplikasi dibuka pertama kali melalui SplashScreenPage()
      home: const SplashScreenPage(),
    );
  }
}
