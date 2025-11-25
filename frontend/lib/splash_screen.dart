import 'package:flutter/material.dart';
import 'theme.dart';
import 'home_screen.dart';
import 'widgets/academic_disclaimer.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    debugPrint('🟢 SplashScreen: Initializing...');
    // Wait a frame to ensure the splash screen renders first
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigateToHome();
    });
  }

  Future<void> _navigateToHome() async {
    if (_hasNavigated) return; // Prevent multiple navigations
    
    debugPrint('🟢 SplashScreen: Starting navigation timer...');
    
    // Wait 2 seconds minimum
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted || _hasNavigated) {
      debugPrint('❌ SplashScreen: Not mounted or already navigated');
      return;
    }
    
    debugPrint('🟢 SplashScreen: Attempting navigation...');
    _hasNavigated = true;
    
    try {
      // Use direct navigation (more reliable)
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) {
            debugPrint('✅ SplashScreen: Navigating to HomeScreen');
            return const HomeScreen();
          }),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('❌ SplashScreen: Navigation error: $e');
      debugPrint('❌ SplashScreen: Stack: $stackTrace');
      
      // Try named route as fallback
      if (mounted && !_hasNavigated) {
        try {
          Navigator.pushReplacementNamed(context, '/home');
          debugPrint('✅ SplashScreen: Fallback navigation successful');
        } catch (e2) {
          debugPrint('❌ SplashScreen: All navigation methods failed: $e2');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('SplashScreen building...');
    
    return Scaffold(
      backgroundColor: kBrandPrimary,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: kBrandPrimary,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'MedGuard',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 40,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const AcademicDisclaimer(),
          ],
        ),
      ),
    );
  }
}
