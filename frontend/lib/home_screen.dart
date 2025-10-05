import 'package:flutter/material.dart';
import 'theme.dart';
import 'history_screen.dart';
import 'pharmacies_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0; // 0: Home, 1: History, 2: Pharmacies

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    Widget homeBody() {
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            // Headline
            RichText(
              text: TextSpan(
                style: t.displaySmall?.copyWith(height: 1.25),
                children: const [
                  TextSpan(text: 'Verify your Medicine validity\nin '),
                  TextSpan(
                    text: 'Seconds',
                    style: TextStyle(color: kBrandPrimary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Caption (force exactly two lines max)
            const Text(
              'Scan and verify your medication using our\nbarcode scanning feature',
              style: TextStyle(color: kTextSecondary, fontSize: 18, height: 1.35),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
            ),

            // Bring buttons a bit higher: remove giant Spacer; use modest space instead
            const SizedBox(height: 28),

            // Primary action
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pushNamed(context, '/scan'),
                child: const Text('Scan the Product'),
              ),
            ),
            const SizedBox(height: 12),

            // Secondary action
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pushNamed(context, '/manual'),
                child: const Text('Enter GTIN Number Manually'),
              ),
            ),
          ],
        ),
      );
    }

    Widget body() {
      if (_tab == 0) return homeBody();
      if (_tab == 1) return const HistoryScreen();
      return const PharmaciesScreen();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('')),
      body: body(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.local_pharmacy_rounded), label: 'Pharmacies'),
        ],
      ),
    );
  }
}
