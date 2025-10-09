// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';
import 'router/app_router.dart';
import 'package:go_router/go_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RoomLedgerApp());
}

class RoomLedgerApp extends StatelessWidget {
  const RoomLedgerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'RoomLedger',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF2962FF),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF6F7FB),
      ),
      routerConfig: appRouter,
    );
  }
}
