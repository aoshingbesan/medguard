import 'package:flutter/material.dart';
import 'theme.dart';

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

    Widget body() {
      if (_tab == 0) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              RichText(
                text: TextSpan(
                  style: t.displaySmall?.copyWith(height: 1.25),
                  children: const [
                    TextSpan(text: 'Verify your Medicine validity\nin '),
                    TextSpan(text: 'Seconds', style: TextStyle(color: kBrandPrimary)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Scan and Verify your medication using our\nbarcode scanning feature',
                style: TextStyle(color: kTextSecondary, fontSize: 18, height: 1.35),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pushNamed(context, '/scan'),
                  child: const Text('Scan the Product'),
                ),
              ),
              const SizedBox(height: 14),
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
      } else if (_tab == 1) {
        return const _DisabledPlaceholder(title: 'History');
      } else {
        return const _DisabledPlaceholder(title: 'Pharmacies');
      }
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
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Pharmacies'),
        ],
      ),
    );
  }
}

class _DisabledPlaceholder extends StatelessWidget {
  final String title;
  const _DisabledPlaceholder({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('$title (coming soon)', style: Theme.of(context).textTheme.bodyMedium),
    );
  }
}
