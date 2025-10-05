import 'package:flutter/material.dart';
import 'theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) Navigator.pushReplacementNamed(context, '/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBrandPrimary,
      body: Center(
        child: Text('MedGuard',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            color: Colors.white, fontWeight: FontWeight.w700, fontSize: 40)),
      ),
    );
  }
}
