import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'simple_language_service.dart';
import 'theme.dart';
import 'splash_screen.dart';
import 'home_screen.dart';
import 'manual_entry_screen.dart';
import 'result_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Flutter error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('Flutter Error: ${details.exception}');
    debugPrint('Stack: ${details.stack}');
  };
  
  // Start the app first so UI can render immediately
  runApp(
    ChangeNotifierProvider(
      create: (context) => SimpleLanguageService(),
      child: const MedGuardApp(),
    ),
  );
  
  // Initialize Supabase in the background (non-blocking)
  Future.microtask(() async {
    try {
      // Load environment variables from .env file
      await dotenv.load(fileName: '.env');
      debugPrint('✅ .env file loaded successfully');
      
      // Initialize Supabase with credentials from environment variables
      final supabaseUrl = dotenv.env['SUPABASE_URL'];
      final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];
      
      debugPrint('Supabase URL: ${supabaseUrl != null ? "✅ Set" : "❌ Missing"}');
      debugPrint('Supabase Key: ${supabaseAnonKey != null ? "✅ Set" : "❌ Missing"}');
      
      if (supabaseUrl == null || supabaseAnonKey == null) {
        debugPrint('❌ Missing Supabase credentials');
        return;
      }
      
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
      debugPrint('✅ Supabase initialized successfully');
    } catch (e, stackTrace) {
      // Log error and continue - app will show error screen if needed
      debugPrint('❌ Error during initialization: $e');
      debugPrint('Stack trace: $stackTrace');
      // Continue anyway - some features might work without Supabase
    }
  });
}

class MedGuardApp extends StatelessWidget {
  const MedGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Set error widget builder globally
    ErrorWidget.builder = (FlutterErrorDetails details) {
      debugPrint('ErrorWidget caught: ${details.exception}');
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${details.exception}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/');
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    };
    
    return MaterialApp(
      title: 'MedGuard',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: kBrandPrimary,
          primary: kBrandPrimary,
          surface: kAppBg,
          background: kAppBg,
        ),
      ),
      routes: {
        '/home': (_) => const HomeScreen(),
        '/manual': (_) => const ManualEntryScreen(),
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
      home: const SplashScreen(), // Show splash screen immediately
    );
  }
}
