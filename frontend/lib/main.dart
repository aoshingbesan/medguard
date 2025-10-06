import 'package:flutter/material.dart';
import 'theme.dart';
import 'splash_screen.dart';
import 'home_screen.dart';
import 'manual_entry_screen.dart';
import 'result_screen.dart';
import 'scan_screen.dart';

void main() => runApp(const MedGuardApp());

class MedGuardApp extends StatelessWidget {
  const MedGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MedGuard',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      routes: {
        '/': (_) => const SplashScreen(),
        '/home': (_) => const HomeScreen(),
        '/manual': (_) => const ManualEntryScreen(),
        '/scan': (_) => const ScanScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/result') {
          final args = settings.arguments as Map<String, dynamic>? ?? {};
          final verified = args['verified'] == true;
          final data = args['data'] as Map<String, dynamic>?;
          return MaterialPageRoute(
            builder: (_) => ResultScreen(verified: verified, data: data),
          );
        }
        return null;
      },
      initialRoute: '/',
    );
  }
}
