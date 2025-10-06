import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';

void main() {
  runApp(const RoomLedgerApp());
}

class RoomLedgerApp extends StatelessWidget {
  const RoomLedgerApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF1E3A5F); // dark navy (matches your mock)
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RoomLedger',
      theme: ThemeData(
        primaryColor: primary,
        colorScheme: ColorScheme.fromSeed(seedColor: primary).copyWith(primary: primary),
        scaffoldBackgroundColor: const Color(0xFFF5F7FB),
        appBarTheme: const AppBarTheme(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
    );
  }
}
